import sys
rabbit_nodes = int(sys.argv[1])
if rabbit_nodes is None or not rabbit_nodes > 1:
	lines = []
	with open('/etc/rabbitmq/rabbitmq.conf') as infile:
		for line in infile:
			if not ("cluster_formation") in line:
				lines.append(line)

	with open('/etc/rabbitmq/rabbitmq.conf', 'w') as outfile:
		for line in lines:
			outfile.write(line)
