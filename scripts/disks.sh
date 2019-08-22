
echo "Running disk setup..."

diskCount=$(echo $json | jq -r $CONFIG_LOCATION.disk_count)

# iscsiadm discovery/login
# loop over various ip's but needs to only attempt disks that actually
# do/will exist.
if [ $diskCount -gt 0 ] ;
then
  echo "Number of disks diskCount: $diskCount"
  for n in `seq 2 $((diskCount+1))`; do
    echo "Disk $((n-2)), attempting iscsi discovery/login of 169.254.2.$n ..."
    success=1
    while [[ $success -eq 1 ]]; do
      iqn=$(iscsiadm -m discovery -t sendtargets -p 169.254.2.$n:3260 | awk '{print $2}')
      if  [[ $iqn != iqn.* ]] ;
      then
        echo "Error: unexpected iqn value: $iqn"
        sleep 10s
        continue
      else
        echo "Success for iqn: $iqn"
        success=0
      fi
    done
    iscsiadm -m node -o update -T $iqn -n node.startup -v automatic
    iscsiadm -m node -T $iqn -p 169.254.2.$n:3260 -l
  done
else
  echo "Zero block volumes, not calling iscsiadm, diskCount: $diskCount"
fi

# We continue here, only creating iscsi devices
echo "Continuing, RAID and filesystem creation handled by scylla_setup"
