declare -i version
version=$(dpkg -l openmediavault | grep ^ii | awk '{ print $3 }' | cut -d"." -f1)
echo $version 
if [ $version -eq 4 ]; then
  echo "Downloading omv-extras.org plugin for openmediavault 4.x ..."
  file="omvextras4.deb"
elif [ $version -eq 3 ]; then
  echo "Downloading omv-extras.org plugin for openmediavault 3.x ..."
  file="omvextras3.deb"
elif [ $version -eq 2 ]; then
  echo "Downloading omv-extras.org plugin for openmediavault 2.x ..."
  file="omvextras.deb"
else
  echo "Unsupported version of openmediavault"
  exit 0
fi
if [ -f "${file}" ]; then
  rm ${file}
fi
wget http://omv-extras.org/${file}
if [ -f "${file}" ]; then
  dpkg -i ${file}
  if [ $? -gt 0 ]; then
    echo "Installing other dependencies ..."
    apt-get -f install
  fi
  echo "Updating repos ..."
  apt-get update
else
  echo "There was a problem downloading the package."
fi
sudo apt-get install apt-transport-https ca-certificates curl gnupg software-properties-common 
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt-get update
sudo apt-get install docker-ce xorg i965-va-driver x264 x265 kodi kodi-pvr-iptvsimple openmediavault-remotedesktop
docker pull nextcloud
docker pull openhab/openhab:2.2.0-amd64-debian
docker pull onlyoffice/documentserver
docker run -i -t -d -P --restart always -p 82:80 onlyoffice/documentserver
docker run -d -P --restart always -p 9000:80 nextcloud 
docker run -it --name openhab -P --restart always --net=host openhab/openhab:2.2.0-amd64-debian
cd /etc/X11/
/etc/init.d/gdm stop || /etc/init.d/gdm3 stop || /etc/init.d/kdm stop || /etc/init.d/xdm stop || /etc/init.d/lightdm stop
Xorg -configure
sudo reboot now
