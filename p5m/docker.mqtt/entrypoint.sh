#!/usr/bin/bash

# Start the first process
/usr/sbin/mosquitto -c /mosquitto/config/mosquitto.conf &

# Start the second process
/usr/bin/perl /sardin/scripts/vac-sardin-mqtt.pl &

# Wait for any process to exit
wait -n
  
# Exit with status of process that exited first
exit $?
