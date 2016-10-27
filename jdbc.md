## install
```
feature:install odl-dlux-all
feature:install odl-restconf-all 
feature:install odl-mdsal-all 
feature:repo-add mvn:org.ops4j.pax.jdbc/pax-jdbc-features/0.8.0/xml/features
feature:install pax-jdbc-mysql pax-jdbc-config

cp ptn/etc/org.ops4j.datasource-ptn.cfg ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/etc/

cp ptn/api/target/ptn-api-1.0.0-SNAPSHOT.jar ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/ 
cp ptn/impl/target/ptn-impl-1.0.0-SNAPSHOT.jar ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/
```
