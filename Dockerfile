FROM rabbitmq:3.8.3-management
ADD rabbitmq.conf /etc/rabbitmq

# https://stackoverflow.com/questions/30747469/how-to-add-initial-users-when-starting-a-rabbitmq-docker-container#answer-62026712

ARG RABBIT_MQ_USERNAME
ARG RABBIT_MQ_PASSWORD
ARG RABBIT_MQ_VIRTUAL_HOST
ARG RABBIT_MQ_NODES

# https://stackoverflow.com/questions/1955505/parsing-json-with-unix-tools#answer-8400375
#rabbitmqctl list_users --formatter=json | python -c 'import json,sys;obj=json.load(sys.stdin);print obj[0]["user"]' Comando utile per iterare sugli utenti, capire se serve

# Copy SALT Python script generation.
COPY ./rmq_passwd_hash.py /etc/rabbitmq/rmq_passwd_hash.py
RUN chown rabbitmq:rabbitmq /etc/rabbitmq/rmq_passwd_hash.py

# Copy Password Python replacer.
COPY ./rmq_passwd_substitution.py /etc/rabbitmq/rmq_passwd_substitution.py
RUN chown rabbitmq:rabbitmq /etc/rabbitmq/rmq_passwd_substitution.py

# Copy Python policies definitions.
COPY ./rmq_policis_definitions.py /etc/rabbitmq/rmq_policis_definitions.py
RUN chown rabbitmq:rabbitmq /etc/rabbitmq/rmq_policis_definitions.py

# Copy Python cluster rules definitions.
COPY ./rmq_cluster_definitions.py /etc/rabbitmq/rmq_cluster_definitions.py
RUN chown rabbitmq:rabbitmq /etc/rabbitmq/rmq_cluster_definitions.py

# Generate definitions.json file.
RUN echo "{\"users\":[{\"name\":\"RABBIT_MQ_USERNAME\",\"password_hash\":\"RABBIT_MQ_PASSWORD\",\"hashing_algorithm\":\"rabbit_password_hashing_sha256\",\"tags\":\"administrator\"}],\"vhosts\":[{\"name\":\"/RABBIT_MQ_VIRTUAL_HOST\"}],\"permissions\":[{\"user\":\"RABBIT_MQ_USERNAME\",\"vhost\":\"/RABBIT_MQ_VIRTUAL_HOST\",\"configure\":\".*\",\"write\":\".*\",\"read\":\".*\"}],\"parameters\":[],\"policies\":RABBIT_MQ_POLICIES,\"queues\":[],\"exchanges\":[],\"bindings\":[]}" > /etc/rabbitmq/definitions.json
RUN chown rabbitmq:rabbitmq /etc/rabbitmq/rabbitmq.conf /etc/rabbitmq/definitions.json

# Replace Guest username.
RUN sed -i "s/RABBIT_MQ_USERNAME/${RABBIT_MQ_USERNAME}/g" /etc/rabbitmq/definitions.json

# Replace Virtual Host.
RUN sed -i "s/RABBIT_MQ_VIRTUAL_HOST/${RABBIT_MQ_VIRTUAL_HOST}/g" /etc/rabbitmq/definitions.json

# Definition queue policies and set it on /etc/rabbitmq/definitions.json
RUN python /etc/rabbitmq/rmq_policis_definitions.py ${RABBIT_MQ_NODES} ${RABBIT_MQ_VIRTUAL_HOST}

# Definition cluster rules on /etc/rabbitmq/rabbitmq.conf
RUN python /etc/rabbitmq/rmq_cluster_definitions.py ${RABBIT_MQ_NODES}

# Replace Guest password.
RUN python /etc/rabbitmq/rmq_passwd_substitution.py $(python /etc/rabbitmq/rmq_passwd_hash.py ${RABBIT_MQ_PASSWORD})

# Delete Python script from RabbitMQ Container.
RUN rm -rf /etc/rabbitmq/rmq_cluster_definitions.py
RUN rm -rf /etc/rabbitmq/rmq_passwd_hash.py
RUN rm -rf /etc/rabbitmq/rmq_passwd_substitution.py
RUN rm -rf /etc/rabbitmq/rmq_policis_definitions.py

# Enable plugin with Dockerfile - reference: https://stackoverflow.com/questions/46112177/rabbitmq-with-with-docker-compose-rabbitmq-config-file-gets-replaced-on-run#answer-46114088
WORKDIR /var/lib/rabbitmq/
RUN rabbitmq-plugins enable rabbitmq_peer_discovery_k8s
RUN rabbitmq-plugins list

# Start RabbitMQ container.
CMD ["rabbitmq-server"]
