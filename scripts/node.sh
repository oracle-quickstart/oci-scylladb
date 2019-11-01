echo "ScyllaDB install/setup"


#######################################################
##################### Disable firewalld ###############
#######################################################
systemctl stop firewalld
systemctl disable firewalld

#######################################################
##################### Install/config scylladb #########
#######################################################

# Remove abrt
yum remove -y abrt
# install epel
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install epel-release wget
# add repo
wget -O /etc/yum.repos.d/scylla.repo http://repositories.scylladb.com/scylla/repo/972d2ab5-0c40-4576-aa49-824cc06cd24a/centos/scylladb-2019.1.repo
# install
yum -y install scylla-enterprise

# config files
CONF="/etc/scylla/scylla.yaml"
cp $CONF $CONF.bak
RACKDC="/etc/scylla/cassandra-rackdc.properties"

seed_count=3
seeds=$(host scylladb-node-0 | awk '/has address/ { print $4 }')

for n in `seq 1 $((seed_count-1))`; do
   ip=$(host scylladb-node-$n | awk '/has address/ { print $4 }')
   seeds="$seeds,$ip"
done

dc_name="mydc"
rack=$faultdomain

echo "Setup $CONF ..."
cat $CONF | \
sed -e "s/- seeds:.*/- seeds: \"$seeds\"/g" | \
sed -e "s/listen_address:.*/listen_address: $private_ip/g" | \
sed -e "s/# broadcast_address:.*/broadcast_address: $private_ip/g" | \
sed -e "s/rpc_address:.*/rpc_address: 0.0.0.0/g" | \
sed -e "s/# broadcast_rpc_address:.*/broadcast_rpc_address: $public_ip/g" | \
sed -e "s/endpoint_snitch:.*/endpoint_snitch: GossipingPropertyFileSnitch/g" | \
sed -e "s/# authenticator:.*/authenticator: PasswordAuthenticator/g" | \
sed -e "s/# authorizer:.*/authorizer: CassandraAuthorizer/g" > $CONF.new
mv $CONF.new $CONF

echo "Setup $RACKDC ..."
echo -e "\n#\n# Deployment generated\n#" >> $RACKDC
echo "dc=$dc_name" >> $RACKDC
echo "rack=$rack" >> $RACKDC
echo "prefer_local=true" >> $RACKDC

# find all iscsi block volumes
if [ $diskCount -gt 0 ]; then
  disks=$(ls /dev/disk/by-path/ip-169.254*)
  echo "Block devices found: $disks"
fi

if [[ $shape == *"Dense"* ]] || [[ $shape == *"HPC"* ]]; then
  echo "Running on Dense/HPC shape, ignoring any block volumes for local NVME..."
  disks=$(ls /dev/nvme*n1)
  echo "NVME found: $disks"
fi

nic=$(ip link show | awk -F":" '/ens/ { print $2 }' | tr -d ' ')
#overide nic value for HPC shape
if [[ $shape == *"HPC"* ]]; then
  nic=$(ip link show | awk -F":" '/eno2/ { print $2 }' | tr -d ' ')
  echo "HPC shape ussing nic: $nic"
fi

if [ -z "$disks"]; then
  echo "No block or nvme disks"
  echo "Call scylla_setup with nic: $nic and --no-raid-setup"
  scylla_setup \
   --no-ec2-check \
   --nic $nic \
   --no-raid-setup
else
  #must resolve possible symlinks, trim trailing whitespace, make comma separated
  disks=$(realpath $disks | tr '\n' ' ' | awk '{$1=$1;print}' | tr ' ' ',')
  echo "Call scylla_setup with nic: $nic and disks: $disks"
  scylla_setup \
   --no-ec2-check \
   --nic $nic \
   --disks $disks
fi


echo "Enable and start scylla-server..."
systemctl enable scylla-server
systemctl start scylla-server

sleep 30s
nodetool status

if [ $(hostname) == "scylladb-node-0" ]
then
  echo "Calling pw change on scylladb-node-0..."
  cqlsh -u cassandra -p cassandra -e "ALTER USER cassandra WITH PASSWORD '$newpw';"
else
  echo "Not node-0, finished"
fi
