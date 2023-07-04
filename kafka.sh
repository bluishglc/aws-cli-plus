#!/bin/bash
MSK_VERSION=2.8.1
echo "export KAFKA_CLIENT_HOME=/opt/kafka_2.13-$MSK_VERSION;export PATH=$KAFKA_CLIENT_HOME/bin:\$PATH" > /etc/profile.d/kafka-client.sh
source /etc/profile.d/kafka-client.sh
sudo -i -u ec2-user source /etc/profile.d/kafka-client.sh

wget https://archive.apache.org/dist/kafka/$MSK_VERSION/kafka_2.13-$MSK_VERSION.tgz -P /tmp
tar -xzf /tmp/kafka_2.13-$MSK_VERSION.tgz -C /opt
wget https://github.com/aws/aws-msk-iam-auth/releases/download/v1.1.6/aws-msk-iam-auth-1.1.6-all.jar -P $KAFKA_CLIENT_HOME/libs

cat << EOF > $KAFKA_CLIENT_HOME/config/client.properties
security.protocol=SASL_SSL
sasl.mechanism=AWS_MSK_IAM
sasl.jaas.config=software.amazon.msk.auth.iam.IAMLoginModule required
sasl.client.callback.handler.class=software.amazon.msk.auth.iam.IAMClientCallbackHandler
EOF

# clean kakfa

export KAFKA_BROKERS="b-2.kafkacluster2.05u9as.c7.kafka.us-east-1.amazonaws.com:9092,b-1.kafkacluster2.05u9as.c7.kafka.us-east-1.amazonaws.com:9092,b-3.kafkacluster2.05u9as.c7.kafka.us-east-1.amazonaws.com:9092"

kafka-topics.sh --bootstrap-server $KAFKA_BROKERS --delete --topic '.*connect.*'

kafka-topics.sh --bootstrap-server $KAFKA_BROKERS --delete --topic '.*fullfillment.*'

kafka-topics.sh --bootstrap-server $KAFKA_BROKERS --list

# monitor topics

kafka-console-consumer.sh --bootstrap-server $KAFKA_BROKERS --topic schemahistory.fullfillment --from-beginning

kafka-console-consumer.sh --bootstrap-server $KAFKA_BROKERS --topic fullfillment.cdc_test_db.person --from-beginning

