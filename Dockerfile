FROM mongo:3.2

ARG KEY_REP_SET
ARG PORT=27017

RUN mkdir /opt/mongo
ADD scripts/mongo_setup_users.sh /opt/mongo/mongo_setup_users.sh
ADD scripts/mongo_setup_repset.sh /opt/mongo/mongo_setup_repset.sh
ADD scripts/mongo_check_state.sh /opt/mongo/mongo_check_state.sh
ADD scripts/mongo_check_mongod_running.sh /opt/mongo/mongo_check_mongod_running.sh
ADD scripts/run.sh /opt/mongo/run.sh

RUN echo $KEY_REP_SET >> /opt/mongo/mongodb-keyfile

RUN chown -R mongodb:mongodb /opt/mongo
RUN chmod -R 777 /opt/mongo

USER mongodb

EXPOSE $PORT

CMD ["/opt/mongo/run.sh"]
