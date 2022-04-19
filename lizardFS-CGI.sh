echo "update & upgrade of debian"
sleep 1
apt-get update -y
apt-get upgrade -y
echo "installation of lizardfs dependency"
sleep 1
apt-get install -y lsb-release wget gnupg apt-transport-https dpkg-dev gzip
echo "add the package to sources.list"
sleep 1
echo 'deb [trusted=yes] https://dev.lizardfs.com/packages/ bullseye/' | tee /etc/apt/sources.list.d/lizardfs.list
apt-get update 2>&1 | sed -ne 's?^.*NO_PUBKEY ??p' | xargs -r -- apt-key adv --keyserver keyserver.ubuntu.com --recv-keys
apt-get upgrade -y

echo "installation of lizardfs CGI"
apt-get install -y lizardfs-common lizardfs-cgi lizardfs-adm