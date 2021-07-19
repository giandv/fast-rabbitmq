RabbitMQ image, based on version 3.8.3, useful for quickly configuring:
- a custom virtual host
- a custom virtual host user with administrator privileges
- rapid definition of HA mode policy, based on full node mirroring.
- easy integration with the rabbitmq_peer_discovery_k8s plugin, within a kubernetes cluster, enabling peer_discovery if we have more than one RabbitMQ node in the replicaset.