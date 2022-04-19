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

echo "installation of lizardfs chunk"
sleep 1
apt-get install -y lizardfs-common lizardfs-chunkserver xfsprogs
cp /usr/share/doc/lizardfs-chunkserver/examples/mfschunkserver.cfg /etc/lizardfs/mfschunkserver.cfg
cp /usr/share/doc/lizardfs-chunkserver/examples/mfshdd.cfg /etc/lizardfs/mfshdd.cfg
modprobe -v xfs
echo "you have $(fdisk -l | grep "Disque" | cut -d' ' -f2 | cut -d':' -f1 | wc -l) disks installed :"
echo "$(fdisk -l | grep "Disque" | cut -d' ' -f2 | cut -d':' -f1)"
echo "please selecte the disks you want to use for the chunkserver(the disk selected will be erased)"
read -p 'Disk name(separate by ";"): ' disks
echo "you have selected the following disks :"
export IFS=";"
for word in $disks; do
  echo "$word"
done
read -r -p "do you want to use the following disks for the chunkserver ? (y/n) ? " response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
then
    for word in $disks; do
        sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk $word
n
p
1


w
EOF
        mkfs.xfs -f $word"1"
        echo $word"1 /mnt/"$(echo $word | cut -d'/' -f3) " xfs defaults 0 0" >> /etc/fstab
        mkdir -p /mnt/$(echo $word | cut -d'/' -f3) && mount /mnt/$(echo $word | cut -d'/' -f3)
        chown -R lizardfs:lizardfs /mnt/$(echo $word | cut -d'/' -f3)
        echo "/mnt/"$(echo $word | cut -d'/' -f3) >> /etc/lizardfs/mfshdd.cfg
    done
else
    exit
fi
sed -i 's/LIZARDFSCHUNKSERVER_ENABLE=false/LIZARDFSCHUNKSERVER_ENABLE=true/g' /etc/default/lizardfs-chunkserver
sed -i 's/\# WORKING_USER = lizardfs/WORKING_USER = lizardfs/g' /etc/lizardfs/mfschunkserver.cfg
sed -i 's/\# WORKING_GROUP = lizardfs/WORKING_GROUP = lizardfs/g' /etc/lizardfs/mfschunkserver.cfg
read -r -p "insert the dns name of the lizardfs master ?" response1
sed -i 's/\# MASTER_HOST = mfsmaster/MASTER_HOST = '$response1'/g' /etc/lizardfs/mfschunkserver.cfg
read -r -p "insert the name of this chunk server ?" response2
sed -i 's/\# LABEL = _/LABEL = '$response2'/g' /etc/lizardfs/mfschunkserver.cfg
systemctl enable lizardfs-chunkserver.service
systemctl start lizardfs-chunkserver.service


echo "rename of serveur and reboot"
sleep 1
hostnamectl set-hostname $response2
echo "if you don't want to reboot now, use ctrl+C (reboot need later) else just wait 6 seconds"
sleep 6
reboot now