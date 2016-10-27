
# Setup environment
## Install JDK
```
sudo apt-get update
sudo apt-get dist-upgrade
sudo apt-get install openjdk-8-jre-headless
sudo apt-get install openjdk-8-jre
sudo apt-get install openjdk-8-jdk
sudo apt-get install maven
javac -version
export JAVA_HOME='/usr/lib/jvm/java-8-openjdk-amd64'
```
## Install maven and eclipse
```
sudo apt-cache search eclipse
sudo apt-cache search maven
sudo apt-get install maven
```   
## Copy maven environment for ODL
- [Boron] : ( http://docs.opendaylight.org/en/stable-boron/developer-guide/developing-apps-on-the-opendaylight-controller.html )
```
cp -n ~/.m2/settings.xml{,.orig};
wget -q -O - https://raw.githubusercontent.com/opendaylight/odlparent/stable/boron/settings.xml > ~/.m2/settings.xml
ls ~/.m2
ls ~/.m2/settings.xml
```
## Remove existing repository if exist
```
mv ~/.m2/repository/ ~/BAK/
```
# Create project
## Make project based on '1.1.3-Beryllium-SR3' using the snapshot architype (*recomend*)
```
mvn archetype:generate -DarchetypeGroupId=org.opendaylight.controller \
-DarchetypeArtifactId=opendaylight-startup-archetype \
-DarchetypeRepository=http://nexus.opendaylight.org/content/repositories/opendaylight.snapshot/ \
-DarchetypeCatalog=http://nexus.opendaylight.org/content/repositories/opendaylight.snapshot/archetype-catalog.xml \
-DarchetypeVersion=1.1.3-Beryllium-SR3
```
## Make project based on '1.1.3-Beryllium-SR3' using the public general architype 
```
mvn archetype:generate -DarchetypeGroupId=org.opendaylight.controller \
-DarchetypeArtifactId=opendaylight-startup-archetype \
-DarchetypeRepository=https://nexus.opendaylight.org/content/repositories/public/ \
-DarchetypeCatalog=https://nexus.opendaylight.org/content/repositories/public/archetype-catalog.xml \
-DarchetypeVersion=1.1.3-Beryllium-SR3
```
```
Define value for property 'groupId': : com.lgu
Define value for property 'artifactId': : ptn
Define value for property 'package':  com.lgu: : 
Define value for property 'classPrefix':  Ptn: : 
Define value for property 'copyright': : LGU.   
```
## Import created maven project from eclipse 
- Import only ap and impl
```
Import maven project into workspace > Select ptn
Select api and ptn (i.e. exclude karaf,features,artifacts,it)
```
## Remove unnecessaried files related with config and yang from impl
```
Remove ptn-impl/src/test/java (PtnModuleFactoryTest.java, PtnModuleTest.java) (22:25)
Remove ptn-impl/src/main/yang (ptn-impl.yang) (23:35)
Remove ptn-impl/src/main/yang-gen-config (AbstractPtnModuleFactory.java, AbstractPtnModuleFactory.java, PtnModuleMXBean.java)
Remove ptn-impl/src/main/java/PtnModule.java
Remove ptn-impl/src/main/java/PtnModuleFactory.java
```
## Remove test XML category from impl/pom.xml
```
    <!-- Testing Dependencies -->
    <!--
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <scope>test</scope>
    </dependency>
    -->
    <!--
    <dependency>
      <groupId>org.mockito</groupId>
      <artifactId>mockito-all</artifactId>
      <scope>test</scope>
    </dependency>
    -->
```
## Insert apache.felix plugins when build the project
```
  </dependencies>
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.felix</groupId>
        <artifactId>maven-bundle-plugin</artifactId>
        <extensions>true</extensions>
          <configuration>
            <instructions>
              <Bundle-Name>ptn_manager</Bundle-Name>
              <Bundle-Activator>com.lgu.impl.PtnProvider</Bundle-Activator>
              <!-- Export-Package>!*</Export-Package -->            
            </instructions>
          </configuration>
      </plugin>
    </plugins>
  </build>
</project>
```
# Basic modification to meet with the basic purpose of TSDN project.
## Change existing java code like the same as following.
```
package com.lgu.impl;

import org.opendaylight.controller.sal.binding.api.BindingAwareBroker.ProviderContext;
import org.opendaylight.controller.sal.binding.api.BindingAwareProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PtnProvider implements BindingAwareProvider /*, AutoCloseable*/ {

    private static final Logger LOG = LoggerFactory.getLogger(PtnProvider.class);

    @Override
    public void onSessionInitiated(ProviderContext session) {
        LOG.info("PtnProvider Session Initiated");
    }

//  @Override
//  public void close() throws Exception {
//      LOG.info("PtnProvider Closed");
//  }
}
```
## Add Registering provider.
```
package tsdn.demo.impl;

import org.opendaylight.controller.sal.binding.api.AbstractBrokerAwareActivator;
import org.opendaylight.controller.sal.binding.api.BindingAwareBroker;
import org.opendaylight.controller.sal.binding.api.BindingAwareBroker.ProviderContext;
import org.opendaylight.controller.sal.binding.api.BindingAwareProvider;
import org.osgi.framework.BundleContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Tsdn_demoProvider extends AbstractBrokerAwareActivator implements BindingAwareProvider {

    private static final Logger LOG = LoggerFactory.getLogger(Tsdn_demoProvider.class);

    @Override
    public void onSessionInitiated(ProviderContext session) {
        LOG.info("Tsdn_demoProvider Session Initiated");
    }

    @Override
    protected void onBrokerAvailable(BindingAwareBroker broker, BundleContext arg1) {
        LOG.info("Tsdn_demoProvider onBrokerAvailable");
        broker.registerProvider(this);
    }
}
```
## Download Pre-built zip ODL
```
Download Pre-built zip file "https://nexus.opendaylight.org/content/repositories/opendaylight.release/org/opendaylight/integration/distribution-karaf/0.4.4-Beryllium-SR4/distribution-karaf-0.4.4-Beryllium-SR4.zip"

rm -R distribution-karaf-0.4.4-Beryllium-SR4/
unzip ~/Downloads/distribution-karaf-0.4.4-Beryllium-SR4.zip ./
./distribution-karaf-0.4.4-Beryllium-SR4/bin/karaf 
```
## Run OpendayLight PreBuild distribution and trace log.
```
unzip distribution-karaf-0.4.4-Beryllium-SR4.zip 
distribution-karaf-0.4.4-Beryllium-SR4 ~/workspace/
workspace/distribution-karaf-0.4.4-Beryllium-SR4/bin/karaf
tail -F distribution-karaf-0.4.4-Beryllium-SR4/data/log/karaf.log 
```
## Install basic features which required to run our project.
- [Install DLUX] opendaylight-user@root>feature:install odl-dlux-all
- [Install RESTCONF] opendaylight-user@root>feature:install odl-restconf-all 
- [Install MDSAL] opendaylight-user@root>feature:install odl-mdsal-all 
```
feature:install odl-dlux-all
feature:install odl-restconf-all 
feature:install odl-mdsal-all 
```
# Deploy package
## Compile API folder first and copy the created jar into the deploy folder.
```
~/workspace/ptn/api/mvn clean install -DskipTests -Dcheckstyle.skip=true
cp ptn/api/target/ptn-api-1.0.0-SNAPSHOT.jar ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/
```
## Look carefully if there's any error in the distributed jar file.
```
opendaylight-user@root>log:tail
tail -F distribution-karaf-0.4.4-Beryllium-SR4/data/log/karaf.log 
```
## Compile impl folder next and copy the created jar into the same deploy folder.
```
~/workspace/ptn/impl$ mvn clean install -DskipTests -Dcheckstyle.skip=true
cp ptn/impl/target/ptn-impl-1.0.0-SNAPSHOT.jar ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/
```
## Confirm the expected log message.
```
$ tail -F distribution-karaf-0.4.4-Beryllium-SR4/data/log/karaf.log
 | 265 - com.lgu.ptn-impl - 1.0.0.SNAPSHOT | PtnProvider onBrokerAvailable
 | 265 - com.lgu.ptn-impl - 1.0.0.SNAPSHOT | PtnProvider Session Initiated
```
# Add RPC
## Edit ptn-api/src/main/yang/ptn.yang
```
module ptn {
    yang-version 1;
    namespace "urn:opendaylight:params:xml:ns:yang:ptn";
    prefix "ptn";

    revision "2015-01-05" {
        description "Initial revision of ptn model";
    }
    
    rpc hello-world {
        input {
            leaf name{
                type string;
            }
        }
        output {
            leaf result {
                type string;
            }
        }
    }
}
```
## Remove previously distributed deploy JAR with the KARAF still running.
```
rm ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/ptn-api-1.0.0-SNAPSHOT.jar 
rm ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/ptn-impl-1.0.0-SNAPSHOT.jar 
```
## Shutdown the karaf and return. Do not kill the karaf.
```
opendaylight-user@root> system:shutdown
#./distribution-karaf-0.4.4-Beryllium-SR4/bin/karaf 
```
# Connect generated RPC call from java service.
## Add override method and RpcRegister
```
Right click in the class PtnProvider > Source > Override/Implemented mehtods
Select stopImpl
```
[ ] OnBroker removed (BindingAwareBroker, BundleContext)
[ ] startImpl(BundleContext)
[x] stopImpl(BundleContext)
```
/*
 * Copyright © 2015 LGU. and others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package com.lgu.impl;

import org.opendaylight.controller.sal.binding.api.AbstractBrokerAwareActivator;
import org.opendaylight.controller.sal.binding.api.BindingAwareBroker;
import org.opendaylight.controller.sal.binding.api.BindingAwareBroker.ProviderContext;
import org.opendaylight.controller.sal.binding.api.BindingAwareBroker.RpcRegistration;
import org.opendaylight.controller.sal.binding.api.BindingAwareProvider;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.PtnService;
import org.osgi.framework.BundleContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PtnProvider extends AbstractBrokerAwareActivator implements BindingAwareProvider {

	private static final Logger LOG = LoggerFactory.getLogger(PtnProvider.class);
    RpcRegistration<PtnService> ptnRegister;

    @Override
    public void onSessionInitiated(ProviderContext session) {
        LOG.info("PtnProvider Session Initiated");
    }
    
	@Override
	protected void onBrokerAvailable(BindingAwareBroker broker, BundleContext arg1) {
		LOG.info("PtnProvider onBrokerAvailable");
		broker.registerProvider(this);
	}
    
	@Override
	protected void stopImpl(BundleContext context) {
		LOG.info("stopImpl");
		super.stopImpl(context);
		ptnRegister.close();
	}
}
```
## Add RPC implementation
```
/*
 * Copyright © 2015 LGU. and others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package com.lgu.impl;

import org.opendaylight.controller.sal.binding.api.AbstractBrokerAwareActivator;
import org.opendaylight.controller.sal.binding.api.BindingAwareBroker;
import org.opendaylight.controller.sal.binding.api.BindingAwareBroker.ProviderContext;
import org.opendaylight.controller.sal.binding.api.BindingAwareBroker.RpcRegistration;
import org.opendaylight.controller.sal.binding.api.BindingAwareProvider;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.PtnService;
import org.osgi.framework.BundleContext;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PtnProvider extends AbstractBrokerAwareActivator implements BindingAwareProvider {

	private static final Logger LOG = LoggerFactory.getLogger(PtnProvider.class);
    RpcRegistration<PtnService> ptnRegister;

    @Override
    public void onSessionInitiated(ProviderContext session) {
        LOG.info("PtnProvider Session Initiated");
        session.addRpcImplementation(PtnService.class, new HelloWorldServiceImpl());
    }

	@Override
	protected void onBrokerAvailable(BindingAwareBroker broker, BundleContext arg1) {
		LOG.info("PtnProvider onBrokerAvailable");
		broker.registerProvider(this);
	}
	@Override
	protected void stopImpl(BundleContext context) {
		// TODO Auto-generated method stub
		super.stopImpl(context);
		ptnRegister.close();
	}	
}
```
## Add HelloWorldServiceImpl class (Use eclipse code assister)
```
/*
 * Copyright © 2015 LGU. and others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package com.lgu.impl;

import java.util.concurrent.Future;

import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.HelloWorldInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.HelloWorldOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.HelloWorldOutputBuilder;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.PtnService;
import org.opendaylight.yangtools.yang.common.RpcResult;
import org.opendaylight.yangtools.yang.common.RpcResultBuilder;

public class HelloWorldServiceImpl implements PtnService {

	@Override
	public Future<RpcResult<HelloWorldOutput>> helloWorld(HelloWorldInput input) {

        String result = "Hello " + input.getName();
        return RpcResultBuilder.success(
                new HelloWorldOutputBuilder()
                    .setResult(result)
                    .build()).buildFuture();
	}
}
```
## Compile the impl and deploy it on to the running karaf.
```
$ mvn clean install -DskipTests -Dcheckstyle.skip=true
$ cp ptn/api/target/ptn-api-1.0.0-SNAPSHOT.jar ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/
$ cp ptn/impl/target/ptn-impl-1.0.0-SNAPSHOT.jar ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/
```
## Confirm the result log and test if the desired out string is displayed in the DLUX web page 
```
```
