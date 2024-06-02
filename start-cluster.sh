#!/bin/bash
JVM_OPTS="$JVM_OPTS -Dcassandra.jmx.remote.port=7199" cassandra -Dcassandra.config=file:///Users/user_name/cassandra/node1/cassandra.yaml
JVM_OPTS="$JVM_OPTS -Dcassandra.jmx.remote.port=7200" cassandra -Dcassandra.config=file:///Users/user_name/cassandra/node2/cassandra.yaml
JVM_OPTS="$JVM_OPTS -Dcassandra.jmx.remote.port=7201" cassandra -Dcassandra.config=file:///Users/user_name/cassandra/node3/cassandra.yaml
JVM_OPTS="$JVM_OPTS -Dcassandra.jmx.remote.port=7202" cassandra -Dcassandra.config=file:///Users/user_name/cassandra/node4/cassandra.yaml


