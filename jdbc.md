## Re-Install KARAF
```
cd ~/workspace/
rm -R distribution-karaf-0.4.4-Beryllium-SR4/
unzip ~/Downloads/distribution-karaf-0.4.4-Beryllium-SR4.zip
./distribution-karaf-0.4.4-Beryllium-SR4/bin/karaf
```
## Install feature
```
feature:install odl-dlux-all
feature:install odl-restconf-all 
feature:install odl-mdsal-all 
feature:install pax-jdbc-mariadb pax-jdbc-config
feature:repo-add mvn:org.ops4j.pax.jdbc/pax-jdbc-features/0.8.0/xml/features
```
## mysql config
```
cd ~/workspace/
$ cat ptn/etc/org.ops4j.datasource-ptn.cfg 
serverName=192.168.123.117
portNumber=3306
databaseName=netmngr
user=root
password=root
```
## copy
```
cp ptn/etc/org.ops4j.datasource-ptn.cfg ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/etc/
```
## Deploy API
```
rm ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/ptn-api-1.0.0-SNAPSHOT.jar
cp ptn/api/target/ptn-api-1.0.0-SNAPSHOT.jar ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/ 
```
## Deploy IMPL
```
rm ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/ptn-impl-1.0.0-SNAPSHOT.jar
cp ptn/impl/target/ptn-impl-1.0.0-SNAPSHOT.jar ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/
```

## Check LOG
```
tail -F distribution-karaf-0.4.4-Beryllium-SR4/data/log/karaf.log 
```
