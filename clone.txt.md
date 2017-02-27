# example text
mvn archetype:generate -DarchetypeGroupId=org.opendaylight.controller -DarchetypeArtifactId=opendaylight-startup-archetype \
-DarchetypeRepository=http://nexus.opendaylight.org/content/repositories/opendaylight.snapshot/ \
-DarchetypeCatalog=http://nexus.opendaylight.org/content/repositories/opendaylight.snapshot/archetype-catalog.xml

Define value for property 'groupId': : org.opendaylight.ptn
Define value for property 'artifactId': : ptn
Define value for property 'version': 1.0-SNAPSHOT: : 1.0.0-SNAPSHOT
Define value for property 'package': org.opendaylight.hello: :
Define value for property 'classPrefix': ${artifactId.substring(0,1).toUpperCase()}${artifactId.substring(1)}
Define value for property 'copyright': : Copyright(c) Coweaver, Inc.

vim "ptn/api/src/main/yang/ptn.yang"
module ptn {
    yang-version 1;
    namespace "urn:opendaylight:params:xml:ns:yang:ptn";
    prefix "ptn";

    revision "2015-01-05" {
        description "Initial revision of ptn model";
    }

    rpc ems-version {
        input {
            leaf query {
                type string;
            }
        }
        output {
            leaf version {
                type string;
            }
        }
    }
}
    
vim "ptn/impl/src/main/java/org/opendaylight/ptn/impl/PtnProvider.java"
/*
 * Copyright © 2015 Copyright(c) Coweaver, Inc. and others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.ptn.impl;

import org.opendaylight.controller.sal.binding.api.BindingAwareBroker.ProviderContext;
import org.opendaylight.controller.sal.binding.api.BindingAwareBroker.RpcRegistration;
import org.opendaylight.controller.sal.binding.api.BindingAwareProvider;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.PtnService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PtnProvider implements BindingAwareProvider, AutoCloseable {

    private static final Logger LOG = LoggerFactory.getLogger(PtnProvider.class);
    private RpcRegistration<PtnService> ptnService;

    @Override public void onSessionInitiated(ProviderContext session) {
        LOG.info("PtnProvider Session Initiated");
        ptnService = session.addRpcImplementation(PtnService.class, new EmsVersionImpl());
    }

    @Override public void close() throws Exception {
        LOG.info("PtnProvider Closed");
        if (ptnService != null) {
            ptnService.close();
        }
    }
}

vim "ptn/impl/src/main/java/org/opendaylight/ptn/impl/EmsVersionImpl.java"

/*
 * Copyright © 2015 Copyright(c) Coweaver, Inc. and others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.ptn.impl;

import java.util.concurrent.Future;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.PtnService;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.EmsVersionInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.EmsVersionOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.EmsVersionOutputBuilder;
import org.opendaylight.yangtools.yang.common.RpcResult;
import org.opendaylight.yangtools.yang.common.RpcResultBuilder;

public class EmsVersionImpl implements PtnService {
    @Override public Future<RpcResult<EmsVersionOutput>> emsVersion(EmsVersionInput input) {
        EmsVersionOutputBuilder ptnBuilder = new EmsVersionOutputBuilder();
        ptnBuilder.setVersion("Ptn " + input.getQuery());
        return RpcResultBuilder.success(ptnBuilder.build()).buildFuture();
    }
}

# default bundle
```
bundle:install mvn:commons-net/commons-net/3.3
feature:repo-add mvn:org.ops4j.pax.jdbc/pax-jdbc-features/0.8.0/xml/features
feature:install pax-jdbc-mariadb pax-jdbc-config
feature:install odl-mdsal-all odl-mdsal-binding odl-restconf-all odl-of-config-all odl-dlux-all webconsole
```
# basic deploy
```
cp /home/jdlee/workspace/CSU/SDK8/tsdn_plugin_api/target/tsdn-plugin-api-0.7.3.jar /home/jdlee/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/
cp /home/jdlee/workspace/SDK.SVN/tsdn.pluginsdk/tsdn_plugin_sample/manger4ventor/tsdn-plugin-manager-base-0.7.3.jar /home/jdlee/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/
cp /home/jdlee/workspace/SDK.SVN/tsdn.pluginsdk/tsdn_plugin_sample/manger4ventor/tsdn-plugin-manager4vendor-0.7.3.jar /home/jdlee/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/
cp /home/jdlee/workspace/SDK.SVN/tsdn.pluginsdk/tsdn_plugin_sample/manger4ventor/lgup.plugin.manager.cfg /home/jdlee/workspace/distribution-karaf-0.4.4-Beryllium-SR4/etc/
cp /home/jdlee/workspace/CSU/SDK8/tsdn_plugin_coweaver/target/tsdn-plugin-coweaver-0.7.3.jar /home/jdlee/workspace/distribution-karaf-0.4.4-Beryllium-SR4/deploy/

scp /home/jdlee/workspace/CSU/SDK8/tsdn_plugin_coweaver/target/tsdn-plugin-coweaver-0.7.3.jar lguplus@tsdn:/home/lguplus/Applications/distribution-karaf-0.4.4-Beryllium-SR4/deploy/
```
# check routine
```

lgup:discovery 7412_1 devices

lgup:request-info 7412_1 device 1.1.70.111
lgup:request-info 7412_1 device 1.1.70.112
lgup:request-info 7412_1 device 1.1.70.113
lgup:request-info 7412_1 device 1.1.70.114
lgup:request-info 7412_1 device 1.1.70.121
lgup:request-info 7412_1 device 1.1.70.122
lgup:request-info 7412_1 device 1.1.70.123
lgup:request-info 7412_1 device 1.1.70.124
lgup:request-info 7412_1 device 1.1.70.125
lgup:request-info 7412_1 device 1.1.70.126
lgup:request-info 7412_1 device 1.1.70.132
lgup:request-info 7412_1 device 1.1.70.133
lgup:request-info 7412_1 device 1.1.70.134
lgup:request-info 7412_1 device 1.1.70.135
lgup:request-info 7412_1 device 1.1.70.136
lgup:request-info 7412_1 device 1.1.70.137
lgup:request-info 7412_1 device 1.1.70.138
lgup:request-info 7412_1 device 1.1.70.151
lgup:request-info 7412_1 device 1.1.70.152
lgup:request-info 7412_1 device 1.1.70.153
lgup:request-info 7412_1 device 1.1.70.171

lgup:request-info 7412_1 device 5.1.1.1
lgup:request-info 7412_1 device 5.2.1.1
lgup:request-info 7412_1 device 5.3.1.1
lgup:request-info 7412_1 device 1.1.65.121
lgup:request-info 7412_1 device 1.1.65.111
lgup:request-info 7412_1 device 1.1.65.112
lgup:request-info 7412_1 device 1.1.65.113
lgup:request-info 7412_1 device 1.1.65.114
lgup:request-info 7412_1 device 1.1.65.114
lgup:request-info 7412_1 device 1.1.65.115
lgup:request-info 7412_1 device 1.1.65.122
lgup:request-info 7412_1 device 1.1.65.123
lgup:request-info 7412_1 device 1.1.65.124
lgup:request-info 7412_1 device 1.1.65.131
lgup:request-info 7412_1 device 1.1.65.132
lgup:request-info 7412_1 device 1.1.65.118
lgup:request-info 7412_1 device 1.1.65.119

lgup:discovery 7412_1 tunnels

lgup:discovery 7412_1 pws

lgup:request-info 7412_1 pw 1.tp_95JJJJHFR1_94GGGGMA01_7871
lgup:request-info 7412_1 pw 5012.tp_95PPPPCWV1_95PPPPCWV2_3079
lgup:request-info 7412_1 pw 3011.tp_95HHHHCWV3_94GGGGMA01_0010
lgup:request-info 7412_1 pw 1023.tp_95HHHHCWV3_94GGGGMA01_0010

lgup:request-info 7412_1 service 3011.3011.tp_95HHHHCWV3_94GGGGMA01_0010
lgup:request-info 7412_1 service 2011.1023.tp_92OOOOBA01_95PPPPCWV2_0020

lgup:request-info 7412_1 pw 5041.tp_95QQQQCWV2_92NNNNBA01_0031
lgup:request-info 7412_1 tunnel tp_95QQQQCWV2_94NNNNMA01_0030
lgup:request-info 7412_1 tunnel tp_92DDDDBA01_92KKKKBA01_0020 

lgup:request-info 7412_1 tunnel 1.1.70.152_tp_95QQQQCWV2_94NNNNMA01_0030
lgup:request-info 7412_1 pw 5041.tp_95QQQQCWV2_92NNNNBA01_0031
lgup:request-info 7412_1 service 5011.5041.tp_92KKKKBA01_95LLLLCWV01_0019

lgup:create 7412_1 tunnels /home/jdlee/tsdn_plugins/PluginID\[id\=7412\]/tunnel.json
lgup:create 7412_2 tunnels /tmp/tunnel_txt.json
lgup:create --pwn ghjhg  7412_1 pws /tmp/dbg_pw_local.json

lgup:request-info 7412_1 tunnel tp_95HHHHCWV3_95HHHHCWV1_0005
lgup:delete --help
lgup:delete 7412_1 tunnels tp_95HHHHCWV3_95HHHHCWV1_0005
lgup:delete 7412_1 pws 1111
lgup:delete 7412_1 pws 1111.tp_95HHHHCWV3_95GGGGMA01_0010

lgup:request-info 7412_1 pw 5041.tp_95QQQQCWV2_92NNNNBA01_0031
lgup:request-info 7412_1 pw 5061.tp_95QQQQCWV2_92NNNNBA01_0031
lgup:request-info 7412_1 pw 3011.tp_95HHHHCWV3_94GGGGMA01_0010
lgup:request-info 7412_1 pw 1023.tp_95HHHHCWV3_94GGGGMA01_0010

lgup:request-info 7412_1 service 5041.5041.tp_95QQQQCWV2_92NNNNBA01_0031
lgup:request-info 7412_1 service 5041.5061.tp_95QQQQCWV2_92NNNNBA01_0031
lgup:request-info 7412_1 service 3011.3011.tp_95HHHHCWV3_94GGGGMA01_0010
lgup:request-info 7412_1 service 1023.1023.tp_95HHHHCWV3_94GGGGMA01_0010
```
# config
```
jdlee@LeeJD:~$ cat ~/workspace/distribution-karaf-0.4.4-Beryllium-SR4/etc/lgup.plugin.manager.cfg 
plugins.rootDir=/home/jdlee/tsdn_plugins
plugin.count=1
plugin.1.id=7412
plugin.1.provider.count=1
plugin.1.provider.1.id=7412_1
plugin.1.provider.1.url=192.168.123.168
plugin.1.provider.1.userName=root
plugin.1.provider.1.password=root
jdlee@LeeJD:~$ 
```
# gadget
```
for f in log*; do xterm -fg white -bg black +sb -T $f -e tail -F $f & done
for f in log*; do xterm -fg white -bg darkblue -geometry 64X24 +sb -T $f -e tail -F $f & done
jdlee@LeeJD:~$ 
```
