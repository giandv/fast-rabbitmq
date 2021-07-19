import os
import sys
import fileinput

password = sys.argv[1]

with open('/etc/rabbitmq/definitions.json', 'r') as file :
  filedata = file.read()

# Replace the target string
filedata = filedata.replace('RABBIT_MQ_PASSWORD', password)

# Write the file out again
with open('/etc/rabbitmq/definitions.json', 'w') as file:
  file.write(filedata)

