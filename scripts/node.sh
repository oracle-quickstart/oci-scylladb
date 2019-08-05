echo "ScyllaDB install/setup"


#######################################################
##################### Disable firewalld ###############
#######################################################
systemctl stop firewalld
systemctl disable firewalld

#######################################################
##################### Install/config scylladb #########
#######################################################

echo "Testing... early exit"
exit 0
