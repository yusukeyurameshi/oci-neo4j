#!/usr/bin/env bash
echo "Running $0"

public_ip=$(oci-public-ip -j | jq '.publicIp' | tr -d '"')
private_ip=$(hostname -I)

#######################################################
##################### Disable firewalld ###############
#######################################################
systemctl stop firewalld
systemctl disable firewalld


#######################################################
##################### Attach Block Volume #############
#######################################################
cp /etc/motd /etc/motd.bkp
cat << EOF > /etc/motd
 
I have been modified by cloud-init at $(date)
 
EOF
 
yum install -y python-oci-cli
systemctl enable ocid.service
systemctl start ocid.service
systemctl status ocid.service


#######################################################
##################### Install/config Neo4j ############
#######################################################
wget -O /tmp/neotechnology.gpg.key http://debian.neo4j.org/neotechnology.gpg.key
rpm --import /tmp/neotechnology.gpg.key

cat <<EOF>  /etc/yum.repos.d/neo4j.repo
[neo4j]
name=Neo4j Yum Repo
baseurl=http://yum.neo4j.org/stable
enabled=1
gpgcheck=1
EOF

export NEO4J_ACCEPT_LICENSE_AGREEMENT=yes
yum install -y neo4j-enterprise



#######################################################
########### Format and Mount Block Volume #############
#######################################################

parted --script /dev/sdb \
    mklabel gpt \
    mkpart primary 1MiB 699GiB 

vgcreate vgneo4j /dev/sdb1
lvcreate -L 698G -n lvdata vgneo4j
mkfs.xfs /dev/vgneo4j/lvdata

mkdir -p /neo4j/data

partprobe

blkid| grep lvdata| awk '{print $2" /neo4j/data xfs defaults,_netdev,_netdev 0 0"}'>>/etc/fstab

mount -a

chown neo4j:neo4j -R /neo4j

#######################################################
####################### change the config #############
#######################################################

cp /etc/neo4j/neo4j.conf /etc/neo4j/neo4j.conf.bak

sed -i -e 's/dbms.directories.data=\/var\/lib\/neo4j\/data/dbms.directories.data=\/neo4j\/data/g' /etc/neo4j/neo4j.conf

sed -i -e '/dbms.connectors.default_listen_address=0.0.0.0/ s/^#//g' /etc/neo4j/neo4j.conf
sed -i -e "s/#dbms.connectors.default_advertised_address=localhost/dbms.connectors.default_advertised_address=$private_ip/g" /etc/neo4j/neo4j.conf

sed -i -e 's/#dbms.mode=CORE/dbms.mode=READ_REPLICA/g' /etc/neo4j/neo4j.conf
#sed -i -e '/causal_clustering.minimum_core_cluster_size_at_formation=3/ s/^#//g' /etc/neo4j/neo4j.conf
#sed -i -e '/causal_clustering.minimum_core_cluster_size_at_runtime=3/ s/^#//g' /etc/neo4j/neo4j.conf
#sed -i -e 's/#causal_clustering.discovery_listen_address=:5000/causal_clustering.discovery_listen_address=0.0.0.0:5000/g' /etc/neo4j/neo4j.conf

#this list should be built and not hard coded
list="core-0:5000,core-1:5000,core-2:5000"
sed -i -e "s/#causal_clustering.initial_discovery_members=localhost:5000,localhost:5001,localhost:5002/causal_clustering.initial_discovery_members=$list/g" /etc/neo4j/neo4j.conf

systemctl start neo4j
systemctl enable neo4j
