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
## Make project based on '1.1.4-Beryllium-SR4' using the snapshot architype (*recomend*)
```
mvn archetype:generate -DarchetypeGroupId=org.opendaylight.controller \
-DarchetypeArtifactId=opendaylight-startup-archetype \
-DarchetypeRepository=http://nexus.opendaylight.org/content/repositories/opendaylight.snapshot/ \
-DarchetypeCatalog=http://nexus.opendaylight.org/content/repositories/opendaylight.snapshot/archetype-catalog.xml \
-DarchetypeVersion=1.1.4-Beryllium-SR4
```
- Check version : ( https://nexus.opendaylight.org/content/repositories/public/org/opendaylight/controller/opendaylight-startup-archetype/ )

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
## Remove useless files related with config and yang from impl
```
rm pom.xml
rm -R ptn/artifacts/
rm -R ptn/features/
rm -R karaf/
rm -R it
rm -R impl/src/test/
rm -R impl/src/main/config/
rm -R impl/src/main/yang/
rm -R impl/src/main/java/org/
$ tree
.
├── api
│   ├── pom.xml
│   └── src
│       └── main
│           └── yang
│               └── ptn.yang
└── impl
    ├── pom.xml
    └── src
        └── main
            └── java
                └── com
                    └── lgu
                        └── impl
                            └── PtnProvider.java
11 directories, 4 files
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
- Defined Yang : ( https://github.com/YangModels/yang/tree/master/standard/ietf/RFC )
- Defined Yang : ( https://github.com/YangModels/yang/blob/master/experimental/odp/opendaylight-inventory.yang )
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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class HelloWorldServiceImpl implements PtnService {
	
	private static final Logger LOG = LoggerFactory.getLogger(HelloWorldServiceImpl.class);

	@Override
	public Future<RpcResult<HelloWorldOutput>> helloWorld(HelloWorldInput input) {

		LOG.info("Input "+input.getName().toString());
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
$ rm -R distribution-karaf-0.4.4-Beryllium-SR4/
$ unzip ~/Downloads/distribution-karaf-0.4.4-Beryllium-SR4.zip 
$ ./distribution-karaf-0.4.4-Beryllium-SR4/bin/karaf 

opendaylight-user@root>feature:install odl-dlux-all
opendaylight-user@root>feature:install odl-restconf-all 
opendaylight-user@root>feature:install odl-mdsal-all 

| 263 - com.lgu.ptn-impl - 1.0.0.SNAPSHOT | PtnProvider onBrokerAvailable
| 263 - com.lgu.ptn-impl - 1.0.0.SNAPSHOT | PtnProvider Session Initiated
| 263 - com.lgu.ptn-impl - 1.0.0.SNAPSHOT | Input aaa

```
## Without DLUX, you can check the result in 'http://localhost:8181/apidoc/explorer/index.html#!/ptn(2015-01-05)'
### input : 
```
http://localhost:8181/apidoc/explorer/index.html#!/ptn(2015-01-05)

{
  "input" : {
    "ptn:name" : "PTN"
  }
}
```
### result :
```
{
  "output": {
    "result": "Hello PTN"
  }
}
```
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
feature:repo-add mvn:org.ops4j.pax.jdbc/pax-jdbc-features/0.8.0/xml/features
feature:install pax-jdbc-mariadb pax-jdbc-config
```
## Add dependency
```
    <dependency>
      <groupId>org.osgi</groupId>
      <artifactId>org.osgi.compendium</artifactId>
      <version>4.3.1</version>
    </dependency>
```
## Coding like this, for example
```
./eclipse/java-latest-released/eclipse/eclipse -Data /home/jdlee/workspace/SDN/
/*
 * Copyright © 2015 LGU. and others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package com.lgu.impl;

import com.lgu.impl.HelloWorldServiceImpl;
import java.util.Collection;
import java.util.Properties;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.sql.ConnectionPoolDataSource;
import javax.sql.DataSource;
import javax.sql.PooledConnection;

import org.opendaylight.controller.sal.binding.api.AbstractBrokerAwareActivator;
import org.opendaylight.controller.sal.binding.api.BindingAwareBroker;
import org.opendaylight.controller.sal.binding.api.BindingAwareBroker.ProviderContext;
import org.opendaylight.controller.sal.binding.api.BindingAwareBroker.RpcRegistration;
import org.opendaylight.controller.sal.binding.api.BindingAwareProvider;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.PtnService;

import org.osgi.framework.BundleContext;
import org.osgi.framework.InvalidSyntaxException;
import org.osgi.framework.ServiceReference;
import org.osgi.service.jdbc.DataSourceFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PtnProvider extends AbstractBrokerAwareActivator implements BindingAwareProvider {
	
	private static final Logger LOG = LoggerFactory.getLogger(PtnProvider.class);
	private RpcRegistration<PtnService> ptnRegister;
	private BundleContext context = null;	
	private DataSource ds = null;
	
	@Override
	public void onSessionInitiated(ProviderContext session) {
		
		LOG.info("PtnProvider Session Initiated.");
		
		session.addRpcImplementation(PtnService.class, new HelloWorldServiceImpl());
		
		LOG.info("PtnProvider Session Creating Thread.");
		
		testConnection();
		new Thread(){
			public void run(){
				testConnection();
			}
		}.start();
	}
	
	private void testConnection() {
		
		Collection<ServiceReference<org.osgi.service.jdbc.DataSourceFactory>> dataSourceFactoryReferences = null;
		
		try {
			dataSourceFactoryReferences = context.getServiceReferences(DataSourceFactory.class, "(osgi.jdbc.driver.name=mariadb)");
		} catch (InvalidSyntaxException e1) {
			LOG.error(e1.getMessage(),e1);
		}
		
		if( dataSourceFactoryReferences != null ){
			org.osgi.service.jdbc.DataSourceFactory dsFactory = null;
			LOG.info("dataSourceFactoryReferences size:"+dataSourceFactoryReferences.size());
			for( ServiceReference<org.osgi.service.jdbc.DataSourceFactory> sr : dataSourceFactoryReferences ){
				LOG.info("DataSourceFactory service reference : "+sr);
				dsFactory = context.getService(sr);
				LOG.info("DataSourceFactory : " + dsFactory);
				if( dsFactory != null ) {
					break;
				}
			}
			if( dsFactory != null ){
				PooledConnection pc = null;
				try {
					Properties p = new Properties();
					p.put(org.osgi.service.jdbc.DataSourceFactory.JDBC_DATABASE_NAME, "netmngr");
					p.put(org.osgi.service.jdbc.DataSourceFactory.JDBC_USER, "root");
					p.put(org.osgi.service.jdbc.DataSourceFactory.JDBC_PASSWORD, "root");
					p.put(org.osgi.service.jdbc.DataSourceFactory.JDBC_SERVER_NAME, "192.168.123.117");
					ConnectionPoolDataSource cpds = dsFactory.createConnectionPoolDataSource(p);                			
					pc = cpds.getPooledConnection();
					
					testConnection(pc.getConnection());
					LOG.info("test DataSourceFactory complete");
					
				} catch (SQLException e) {
					LOG.error(e.getMessage(),e);
				}finally{
					if( pc != null ){
						try { pc.close(); } catch (SQLException e) { }
					}
				}  
			}
		}
	}
	
	private void testConnection(Connection conn) throws SQLException {
		Statement stmt = null;
		ResultSet rst = null;
		
		try {
			stmt = conn.createStatement();
			rst = stmt.executeQuery("select * from config group by id");
			while(rst.next()){
				LOG.info("1 column:"+rst.getString(1));
			}
			
		} finally{
			if( rst != null ){
				try { rst.close(); } catch (SQLException e) { }
			}
			if( stmt != null ){
				try { stmt.close(); } catch (SQLException e) { }
			}
			if( conn != null ){
				try { conn.close(); } catch (SQLException e) { }
			}
		}
	}
	
	@Override
	protected void onBrokerAvailable(BindingAwareBroker broker, BundleContext ctx) {
		LOG.info("PtnProvider onBrokerAvailable");
		context = ctx;
		broker.registerProvider(this);
	}
	
	@Override
	protected void stopImpl(BundleContext context) {
		super.stopImpl(context);
		LOG.info("PtnProvider stopImpl");
		if (ptnRegister != null)
		{
			LOG.info("PtnProvider closing ptnRegister");
			ptnRegister.close();
		}
	}
	
}

```
## Compile 
```
rm ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/ptn-impl-1.0.0-SNAPSHOT.jar
mvn clean install -DskipTests -Dcheckstyle.skip=true > /tmp/error.txt
tail -F /tmp/error.txt
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
## Add POM to access local library
```
    <dependency>
      <groupId>com.ptn</groupId>
      <artifactId>cfg</artifactId>
      <version>1.0.0</version>
    </dependency>
```
## Add extra code to access external library
```
import org.opendaylight.sdn.ptn.impl.CsuCfg;

CsuCfg c = new CsuCfg();
if (c != null) {
	LOG.info(c.toString());
	LOG.info(c.TstMySql());
}
```
## Add library and deploy on the running KARAF machine
```
mvn install:install-file -Dfile=/lib/cfg.jar -DgroupId=com.ptn -DartifactId=cfg -Dversion=1.0.3 -Dpackaging=jar
rm ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/cfg.jar
cp /lib/cfg.jar ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/
```
## Deploy
```
mvn clean install -DskipTests -Dcheckstyle.skip=true > /tmp/error.txt
rm ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/ptn-impl-1.0.0-SNAPSHOT.jar
cp target/ptn-impl-1.0.0-SNAPSHOT.jar ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/
```
## ETC
```
mvn install:install-file -Dfile=/lib/NetMngr.jar -DgroupId=com.lgu -DartifactId=NetMngr -Dversion=1.0.0 -Dpackaging=jar

```
