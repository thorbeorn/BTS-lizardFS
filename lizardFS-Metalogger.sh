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

echo "installation of lizardfs Metalogger"
apt-get install -y lizardfs-common lizardfs-metalogger lizardfs-adm
cp /usr/share/doc/lizardfs-metalogger/examples/mfsmetalogger.cfg /etc/lizardfs/mfsmetalogger.cfg
sed -i 's/LIZARDFSMETALOGGER_ENABLE=false/LIZARDFSMETALOGGER_ENABLE=true/g' /etc/default/lizardfs-metalogger
sed -i 's/\# WORKING_USER = lizardfs/WORKING_USER = lizardfs/g' /etc/lizardfs/mfsmetalogger.cfg
sed -i 's/\# WORKING_GROUP = lizardfs/WORKING_GROUP = lizardfs/g' /etc/lizardfs/mfsmetalogger.cfg
read -r -p "insert the dns name of the lizardfs master ?" response1
sed -i 's/\# MASTER_HOST = mfsmaster/MASTER_HOST = '$response1'/g' /etc/lizardfs/mfsmetalogger.cfg
systemctl enable lizardfs-metalogger.service
systemctl start lizardfs-metalogger.service