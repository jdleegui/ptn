# PTN (Packet Transport Network)

## 0. Setup environment
```
git init
git add README.md
git commit -m "first commit"
git remote add origin https://github.com/jdleegui/ptn.git
git push -u origin master
git add README.md && git commit -m "Update README.md" && git push -u origin master
```
## 1. Create project.
- [APP CREATING GUIDE] ( https://github.com/opendaylight/docs/blob/master/manuals/developer-guide/src/main/asciidoc/developing-app.adoc )
- [YANG GUIDE] ( https://wiki.onosproject.org/display/ONOS/YANG+utils#YANGutils-Namespace )
``` 
mvn archetype:generate -DarchetypeGroupId=org.opendaylight.controller -DarchetypeArtifactId=opendaylight-startup-archetype \
-DarchetypeRepository=https://nexus.opendaylight.org/content/repositories/public/ \
-DarchetypeCatalog=https://nexus.opendaylight.org/content/repositories/public/archetype-catalog.xml
```
- [ Create New Project in eclipse GUI mode ]
```
- File > New > Other > Maven Project > Next > Opendaylight(public)
  (If the ODL(public) not exist, then create it with category as 'https://nexus.opendaylight.org/content/repositories/public/')
- Select the 'opendaylight-startup-archetype'
```
## 2. Define default project name
```
Define value for property 'groupId': : org.opendaylight.ptn
Define value for property 'artifactId': : ptn
Define value for property 'version': 1.0-SNAPSHOT: : 1.0.0-SNAPSHOT
Define value for property 'package': org.opendaylight.ptn: :
Define value for property 'classPrefix': ${artifactId.substring(0,1).toUpperCase()}${artifactId.substring(1)}
Define value for property 'copyright': : Copyright(c) Lguplus, Inc.
```
- [In GUI mode, the postfix of 'package' is duplicated, trim it. say 'org.opendaylight.ptn.ptn'
```

```
## 3. Add yang files
- Two files required to be downloaded and put them all together. ietf-inet-types.yang and yang-ext.yang
- The revision date should be replaced with new updated revision date '2013-07-15'
- confer yang to java in https://wiki.onosproject.org/display/ONOS/YANG+utils#YANGutils-Namespace
- remove java folder if some error remained still after clean after you change yang files.
```
git add ptn/api/src/main/yang/ietf-inet-types.yang 
git add ptn/api/src/main/yang/mpls-tp-connection.yang 
git add ptn/api/src/main/yang/mpls-tp-general-types.yang
git add ptn/api/src/main/yang/mpls-tp-inventory.yang
git add ptn/api/src/main/yang/mpls-tp-provision.yang
git add ptn/api/src/main/yang/mpls-tp-service.yang
git add ptn/api/src/main/yang/mpls-tp-topology-discovery.yang
git add ptn/api/src/main/yang/mpls-tp-topology-inventory.yang
git add ptn/api/src/main/yang/ptn-port.yang
git add ptn/api/src/main/yang/tsdn-access-if.yang
git add ptn/api/src/main/yang/tsdn-connection.yang
git add ptn/api/src/main/yang/tsdn-general-types.yang
git add ptn/api/src/main/yang/tsdn-inventory.yang
git add ptn/api/src/main/yang/tsdn-network-topology.yang
git add ptn/api/src/main/yang/tsdn-node.yang
git add ptn/api/src/main/yang/tsdn-port.yang
git add ptn/api/src/main/yang/tsdn-service.yang
git add ptn/api/src/main/yang/tsdn-topology-discovery.yang
git add ptn/api/src/main/yang/tsdn-tunnel-xc.yang
git add ptn/api/src/main/yang/tsdn-tunnel.yang
git add ptn/api/src/main/yang/yang-ext.yang 
```
## 4.Configuration to call karaf
```
tsdn:~/Documents/distribution-karaf-0.4.4-Beryllium-SR4.0.8.0/etc$vim lgup.plugin.manager.cfg 
tsdn:~/Documents/distribution-karaf-0.4.4-Beryllium-SR4.0.8.0/etc$cat lgup.plugin.manager.cfg 
plugins.rootDir=/Users/jdleegui/tsdn_plugins
plugin.manager.log.on=true
plugin.manager.jdbc.datasource.default_name=ds-oracledb
plugin.manager.log_level=debug
plugin.count=1
plugin.1.id=7412
plugin.1.provider.count=1
plugin.1.provider.1.id=7412_1
plugin.1.provider.1.url=172.31.12.127
plugin.1.provider.1.userName=admin
plugin.1.provider.1.password=admin
tsdn:~/Documents/distribution-karaf-0.4.4-Beryllium-SR4.0.8.0/etc$
tsdn:~/Documents/workspace/CSU/SDK_0_8_0/tsdn_plugin_api$
tsdn:~/Documents/workspace/CSU/SDK_0_8_0/tsdn_plugin_api$mvn clean install -DskipTests -Dcheskstyle.skip=true > /tmp/error.txt && cp target/tsdn-plugin-api-0.8.0.jar ~/Documents/distribution-karaf-0.4.4-Beryllium-SR4.0.8.0/deploy/tsdn-plugin-api-0.8.0.jar 
tsdn:~/Documents/workspace/CSU/SDK_0_8_0/tsdn_plugin_api$mvn clean install -DskipTests -Dcheckstyle.skip=true > /tmp/error.txt && cp target/tsdn-plugin-api-0.8.0.jar ~/Documents/distribution-karaf-0.4.4-Beryllium-SR4.0.8.0/deploy/tsdn-plugin-api-0.8.0.jar 
```
