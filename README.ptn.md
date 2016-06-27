1.  guide : https://github.com/opendaylight/docs/blob/master/manuals/developer-guide/src/main/asciidoc/developing-app.adoc
mvn archetype:generate -DarchetypeGroupId=org.opendaylight.controller -DarchetypeArtifactId=opendaylight-startup-archetype \
-DarchetypeRepository=https://nexus.opendaylight.org/content/repositories/public/ \
-DarchetypeCatalog=https://nexus.opendaylight.org/content/repositories/public/archetype-catalog.xml 

Define value for property 'groupId': : org.opendaylight.ptn
Define value for property 'artifactId': : ptn
Define value for property 'version': 1.0-SNAPSHOT: : 1.0.0-SNAPSHOT
Define value for property 'package': org.opendaylight.hello: :
Define value for property 'classPrefix': ${artifactId.substring(0,1).toUpperCase()}${artifactId.substring(1)}
Define value for property 'copyright': : Copyright(c) Coweaver, Inc.
