RabbitMQ image, based on version 3.8.3, useful for quickly configuring:
- a custom virtual host
- a custom virtual host user with administrator privileges
- rapid definition of HA mode policy, based on full node mirroring.
- easy integration with the rabbitmq_peer_discovery_k8s plugin, within a kubernetes cluster, enabling peer_discovery if we have more than one RabbitMQ node in the replicaset.

This project can be easily integrated into your docker-compose network in the following way:


Definition in docker compose:

	  fast-rabbitmq:
		image: fast-rabbitmq
		container_name: 'fast-rabbitmq'
		build:
			context: fast-rabbitmq
			args:
				- RABBIT_MQ_NODES=<NUMBER_NODES>
				- RABBIT_MQ_PASSWORD=<ADMINISTRATOR_PASSWORD>
				- RABBIT_MQ_USERNAME=<ADMINISTRATOR_USERNAME>
				- RABBIT_MQ_VIRTUAL_HOST=<NAME_VUIRTUAL_HOST>
		ports:
			- 15672:15672
		networks:
			- <network_name>
				
In defining the docker-compose it is important to explain the RABBIT_MQ_NODES parameter. This specifies the number of nodes of RabbitMQ, in a docker environment we recommend having only one node, while in a kubernetes environment this number is according to your configuration, so any number greater than 1 enables peer_discovery [https://www.rabbitmq.com/cluster-formation.html]. The cluster_formation definition is present in the rabbit.conf file.
All peer discovery mechanisms assume that newly joining nodes will be able to contact their peers in the cluster and authenticate with them successfully.
There are various modes of discovery in this project we preferred to use the one based on the [Config file](https://www.rabbitmq.com/cluster-formation.html#peer-discovery-classic-config) (rabbit.conf).
