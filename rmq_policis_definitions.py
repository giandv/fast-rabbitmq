import os
import sys
import fileinput

ha_policies  ="["
rabbit_nodes = int(sys.argv[1])
virtual_host = sys.argv[2]

if rabbit_nodes > 1:
    ha_policies+="{\"vhost\":\"/"+virtual_host+"\",\"name\":\"ha-mode\",\"pattern\":\".*\",\"apply-to\":\"queues\",\"definition\":{\"ha-mode\":\"all\",\"ha-sync-mode\":\"automatic\"},\"priority\":1}"

ha_policies+="]"

with open('/etc/rabbitmq/definitions.json', 'r') as file :
  filedata = file.read()

# Replace the target string
filedata = filedata.replace('RABBIT_MQ_POLICIES', ha_policies)

# Write the file out again
with open('/etc/rabbitmq/definitions.json', 'w') as file:
  file.write(filedata)
