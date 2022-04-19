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

echo "installation of lizardfs MASTER"
apt-get install -y lizardfs-common lizardfs-master lizardfs-adm
cp /var/lib/lizardfs/metadata.mfs.empty /var/lib/lizardfs/metadata.mfs
cp /usr/share/doc/lizardfs-master/examples/mfsmaster.cfg /etc/lizardfs/mfsmaster.cfg
sed -i 's/\# PERSONALITY = master/PERSONALITY = master/g' /etc/lizardfs/mfsmaster.cfg
sed -i 's/\# WORKING_USER = lizardfs/WORKING_USER = lizardfs/g' /etc/lizardfs/mfsmaster.cfg
sed -i 's/\# WORKING_GROUP = lizardfs/WORKING_GROUP = lizardfs/g' /etc/lizardfs/mfsmaster.cfg
sed -i 's/\# EXPORTS_FILENAME = \/etc\/lizardfs\/mfsexports.cfg/EXPORTS_FILENAME = \/etc\/lizardfs\/mfsexports.cfg/g' /etc/lizardfs/mfsmaster.cfg
sed -i 's/\# DATA_PATH = \/var\/lib\/lizardfs/DATA_PATH = \/var\/lib\/lizardfs/g' /etc/lizardfs/mfsmaster.cfg
sed -i 's/LIZARDFSMASTER_ENABLE=false/LIZARDFSMASTER_ENABLE=true/g' /etc/default/lizardfs-master
cp /usr/share/doc/lizardfs-master/examples/mfsexports.cfg /etc/lizardfs/mfsexports.cfg
systemctl enable lizardfs-master.service
systemctl start lizardfs-master.service

echo "rename of serveur and reboot"
sleep 1
hostnamectl set-hostname lizardfs-master
echo "if you don't want to reboot now, use ctrl+C (reboot need later) else just wait 6 seconds"
sleep 6
reboot now