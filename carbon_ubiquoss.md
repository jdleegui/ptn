## Create sample project
```
mvn archetype:generate -DarchetypeGroupId=org.opendaylight.controller -DarchetypeArtifactId=opendaylight-startup-archetype -DarchetypeRepository=http://nexus.opendaylight.org/content/repositories/opendaylight.release/ -DarchetypeCatalog=remote -DarchetypeVersion=1.3.1-Carbon
```
## Input groupid, copyright.
```
Define value for property 'groupId': kr.re.etri.hello
Define value for property 'artifactId': hello
[INFO] Using property: version = 0.1.0-SNAPSHOT
Define value for property 'package' kr.re.etri.hello: : 
Define value for property 'classPrefix' Hello: : 
Define value for property 'copyright': 2017 etri
[INFO] Using property: copyrightYear = 2017
Confirm properties configuration:
groupId: kr.re.etri.hello
artifactId: hello
version: 0.1.0-SNAPSHOT
package: kr.re.etri.hello
classPrefix: Hello
copyright: 2017 etri
copyrightYear: 2017
```
