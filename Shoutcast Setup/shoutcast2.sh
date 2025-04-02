#!/bin/sh

# Continue Shoutcast setup in webpage
cd ~/shoutcast_server
# Edit sc_serv.conf
echo "Editing sc_serv.conf to add streamid_1=1..."
sudo apt install nano -y
echo "streamid_1=1" | sudo tee -a sc_serv.conf

# Verify Shoutcast is running
echo "Shoutcast server should now be running in the pane to the left"
# ... (rest of the script like Nginx, Certbot, etc., continues unchanged)

echo "Starting Shoutcast setup. This requires manual configuration in your browser."
echo "After running setup.sh, configure Shoutcast in your browser at http://$(ip route get 8.8.8.8 | awk '{ print $NF; exit }'):8000:"
echo "1. Set Source Password:"
echo "2. Set Admin Password:"
echo "3. Leave User ID and License ID blank, keep port 8000, and proceed through Stages 1-4."
read -p "Press ENTER to continue..."

# Edit sc_serv.conf
echo "Editing sc_serv.conf to add streamid_1=1..."
sudo apt install nano -y
echo "streamid_1=1" | sudo tee -a sc_serv.conf

# Get streamname from user
echo "Please enter the name of the stream. e.g *stream1234*.egihosting.com"
read -s STREAM_NAME

#Install Nginx
echo "Installing Nginx..."
sudo apt install nginx -y

#Create and configure Nginx file
echo "Creating Nginx configuration for Shoutcast..."
NGINX_CONF="/etc/nginx/conf.d/shoutcast.conf"
sudo bash -c "cat > $NGINX_CONF << EOL
server {
    listen 80;
    listen [::]:80;
    server_name $STREAM_NAME;
    proxy_set_header Host \$host;
    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Host \$host;
    proxy_set_header X-Forwarded-Server \$host;
    location / {
        proxy_set_header Accept-Encoding ' ';
        proxy_set_header Accept ' ';
        proxy_pass http://127.0.0.1:8000/;
        sub_filter ':8000/' '/';
        sub_filter 'localhost' '$STREAM_NAME';
        sub_filter 'localhost' \$host;
    }
}
EOL"

# Allow Nginx through firewall
echo "Allowing Nginx Full through firewall..."
sudo ufw allow 'Nginx Full'

# Installing Certbot
echo "Installing Certbot for Nginx..."
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:certbot/certbot -y
sudo apt install python-certbot-nginx -y
sudo certbot --nginx --agree-tos -d $STREAM_NAME --non-interactive

# Installing Stunnel
echo "Installing Stunnel..."
sudo apt install stunnel -y
cd /etc/stunnel
echo "Creating Stunnel configuration..."
sudo bash -c "cat > stunnel.conf << EOL
client = no
[shoutcast]
accept = 8002
connect = localhost:8000
cert = /etc/letsencrypt/live/$STREAM_NAME/fullchain.pem
key = /etc/letsencrypt/live/$STREAM_NAME/privkey.pem
options = NO_TLSv1
options = NO_TLSv1.1
options = NO_SSLv2
options = NO_SSLv3
sslVersion = all
EOL"

# Start Stunnel
echo "Starting Stunnel..."
sudo /usr/bin/stunnel &