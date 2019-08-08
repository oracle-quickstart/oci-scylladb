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
# add repo
curl -o /etc/yum.repos.d/scylla.repo -L http://repositories.scylladb.com/scylla/repo/972d2ab5-0c40-4576-aa49-824cc06cd24a/centos/scylladb-3.0.repo
# install
yum install -y scylla-3.0.9

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
sed -e "s/endpoint_snitch:.*/endpoint_snitch: GossipingPropertyFileSnitch/g" > $CONF.new
mv $CONF.new $CONF

echo "Setup $RACKDC ..."
echo -e "\n#\n# Deployment generated\n#" >> $RACKDC
echo "dc=$dc_name" >> $RACKDC
echo "rack=$rack" >> $RACKDC
echo "prefer_local=true" >> $RACKDC

#
#| sed -e "s:\(.*- \)/var/lib/cassandra/data.*:\1$data_file_directories:" \
#| sed -e "s:.*\(commitlog_directory\:\).*:commitlog_directory\: $commitlog_directory:" \
#| sed -e "s:.*\(saved_caches_directory\:\).*:saved_caches_directory\: $saved_caches_directory:" \

echo "Call scylla_io_setup..."
scylla_io_setup
echo "Enable and start scylla-server..."
systemctl enable scylla-server
systemctl start scylla-server
