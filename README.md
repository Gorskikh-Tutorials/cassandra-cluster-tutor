# cassandra-cluster-tutor
### Tutorial for running Cassandra cluster on MacOS

1. *Create folders for future 4 nodes:*

```
mkdir -p ~/cassandra/node1 ~/cassandra/node2 ~/cassandra/node3 ~/cassandra/node4
```

```
cp /opt/homebrew/etc/cassandra/cassandra.yaml ~/cassandra/node1/  
cp /opt/homebrew/etc/cassandra/cassandra.yaml ~/cassandra/node2/  
cp /opt/homebrew/etc/cassandra/cassandra.yaml ~/cassandra/node3/  
cp /opt/homebrew/etc/cassandra/cassandra.yaml ~/cassandra/node4/
```
```
cp /opt/homebrew/etc/cassandra/cassandra.yaml ~/cassandra/node1/data  
cp /opt/homebrew/etc/cassandra/cassandra.yaml ~/cassandra/node2/data  
cp /opt/homebrew/etc/cassandra/cassandra.yaml ~/cassandra/node3/data  
cp /opt/homebrew/etc/cassandra/cassandra.yaml ~/cassandra/node4/data
```
```
cp /opt/homebrew/etc/cassandra/cassandra.yaml ~/cassandra/node1/commitlog  
cp /opt/homebrew/etc/cassandra/cassandra.yaml ~/cassandra/node2/commitlog  
cp /opt/homebrew/etc/cassandra/cassandra.yaml ~/cassandra/node3/commitlog  
cp /opt/homebrew/etc/cassandra/cassandra.yaml ~/cassandra/node4/commitlog
```

<br>

2. *For each node copy default config `.yml` file:*    

```
cp /opt/homebrew/etc/cassandra/cassandra.yaml ~/cassandra/node1/saved_caches  
cp /opt/homebrew/etc/cassandra/cassandra.yaml ~/cassandra/node2/saved_caches  
cp /opt/homebrew/etc/cassandra/cassandra.yaml ~/cassandra/node3/saved_caches  
cp /opt/homebrew/etc/cassandra/cassandra.yaml ~/cassandra/node4/saved_caches
```

<br>

2.1. *Node-Specific Settings*  

Each node in the cluster must have a unique configuration for certain settings:  `listen_address`
This should be the IP address of the node. For a local setup, you can use localhost or `127.0.0.1` and unique ports for each node.  

Example for Node 1:
```
listen_address: 127.0.0.1
listen_port: 7000
```
Example for Node 2:
```
listen_address: 127.0.0.1
listen_port: 7001
```

<br>

- `rpc_address`  
This is the address for client communication. It can be localhost or 127.0.0.1.

Example for Node 1:
```
rpc_address: 127.0.0.1
```
Example for Node 2:
```
rpc_address: 127.0.0.1
```

<br>

- `storage_port`  
Port for inter-node communication (default is 7000).

Example for Node 1:
```
storage_port: 7000
```
Example for Node 2:
```
storage_port: 7001
```  
  
<br>

- `native_transport_port`  
Port for native protocol clients (CQL).

Example for Node 1:
```
native_transport_port: 9042
```
Example for Node 2:
```
native_transport_port: 9043
```

2.2. *Cluster-Wide Settings*

These settings should be consistent across all nodes in the cluster.

<br>

- `cluster_name`  
  Set a name for your cluster.  
  
```
  cluster_name: 'TestCluster'
```  
  
<br>

- `seeds`  
A comma-separated list of IP addresses used to bootstrap the gossip process. Typically, the first node started will be the seed.

Example for all nodes:
```
seed_provider:
  - class_name: org.apache.cassandra.locator.SimpleSeedProvider
    parameters:
         - seeds: "127.0.0.1:7000,127.0.0.1:7001"
```  

<br>

- `data_file_directories`   
Directory where SSTables are stored. Ensure this path is different for each node if they are on the same machine.

Example for Node 1:
```
data_file_directories:
    - /var/lib/cassandra/node1/data
```  

<br>

- `commitlog_directory`  
Directory for commit logs. Again, ensure this path is unique for each node.

Example for Node 1:
```
commitlog_directory: /var/lib/cassandra/node1/commitlog
```


<br>

2.3. *Additional Considerations*
- `saved_caches_directory`:   
Directory for saved caches, unique per node.

Example for Node 1:
```
saved_caches_directory: /var/lib/cassandra/saved_caches1
```

<br>

- `JMX Ports`  
Each node should have a unique JMX port for monitoring.

Example for Node 1:
```
jmx_port: 7199
```

<br>

* additional ability to cpecify some configs is using `JVM_OPTS` when start cluster. Example:  
```
JVM_OPTS="$JVM_OPTS -Dcassandra.jmx.remote.port=7199"
```

<br>

2.3.1. *Configs example for Node 1*
```
cluster_name: 'TestCluster'
listen_address: 127.0.0.1
listen_port: 7000
rpc_address: 127.0.0.1
rpc_port: 9042
storage_port: 7000
native_transport_port: 9042
seed_provider:
  - class_name: org.apache.cassandra.locator.SimpleSeedProvider
    parameters:
         - seeds: "127.0.0.1:7000,127.0.0.1:7001"
data_file_directories:
    - /var/lib/cassandra/data1
commitlog_directory: /var/lib/cassandra/commitlog1
saved_caches_directory: /var/lib/cassandra/saved_caches1
jmx_port: 7199
```

<br>

3. *After configuring the `cassandra.yaml` file for each node you need to run each node with specific configs:*   

```
cassandra -Dcassandra.config=file:///Users/user_name/cassandra/node1/cassandra.yaml
or with JVM_OPTS
JVM_OPTS="$JVM_OPTS -Dcassandra.jmx.remote.port=7199" cassandra -Dcassandra.config=file:///Users/user_name/cassandra/node1/cassandra.yaml
```

<br>

4. *As soon as cluster run you need to connect to CQL:*
```
cqlsh 127.0.0.1 9043 -u cassandra -p cassandra
```
`9043` port is `native_transport_port` config from `yaml` file

<br>

5. *And redistribute the default `system_auth` kyspace and specify replication factor:*  
```
ALTER KEYSPACE system_auth 
WITH replication = {
    'class': 'NetworkTopologyStrategy', 
    'replication_factor' : 3
};
```

Or use this script if you have several datacenters and want to specify replication factor for each DC granually:
```
ALTER KEYSPACE system_auth 
WITH replication = {
    'class': 'NetworkTopologyStrategy', 
    'DC1': 3,
    'DC2': 2
};
```

Useful Link: 
 - https://docs.vultr.com/how-to-deploy-a-multi-node-apache-cassandra-database-cluster-on-ubuntu-22-04
