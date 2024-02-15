# Correcting ipsetup bug
#   => Issue: ipsetup doesn't create http-proxy file
# Property of IBM
# Created by Michaël Le Marec


read -p "Please enter your proxy settings (e.g. http://proxy.example.com:80): " proxySettings

ip a | grep eth0
read -p "Please enter IP of instance:" ipAddress

sudo cat > /etc/systemd/system/containerd.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=$proxySettings"
Environment="HTTPS_PROXY=$proxySettings"
Environment="NO_PROXY=$ipAddress, 10.233.0.1, node1, 127.0.0.1, 127.0.0.0"
EOF

echo "### Reload & Restart containerd service"
sudo systemctl daemon-reload 
sudo systemctl restart containerd


containerdEnv=$(systemctl show containerd --property Environment)
echo "### Verify that containerd is using the proxy: "
echo $containerdEnv

read -p "Waiting on your validation. [ENTER] or Ctrl+C "

echo "### Trying to pull the t8c-operator image"
imageCR="icr.io/cpopen/t8c-operator:42.48"
sudo docker pull $imageCR
if [ $? == 1 ]; then
  echo ""
  echo "##### ERROR #####"
  echo ""
fi