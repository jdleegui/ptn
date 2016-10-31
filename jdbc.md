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
## Coding like this, for example
```
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
mvn install:install-file -Dfile=/lib/cfg.jar -DgroupId=com.ptn -DartifactId=cfg -Dversion=1.0.0 -Dpackaging=jar
cp /ib/cfg.jar ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/
```
## Deploy
```
mvn clean install -DskipTests -Dcheckstyle.skip=true > /tmp/error.txt
rm ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/ptn-impl-1.0.0-SNAPSHOT.jar
cp target/ptn-impl-1.0.0-SNAPSHOT.jar ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/
```
