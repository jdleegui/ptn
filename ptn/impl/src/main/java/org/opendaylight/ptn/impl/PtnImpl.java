/*
 * Copyright © 2015 Copyright(c) Coweaver, Inc. and others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.ptn.impl;

import java.util.concurrent.Future;

import org.opendaylight.controller.md.sal.binding.api.DataBroker;
import org.opendaylight.controller.md.sal.binding.api.WriteTransaction;
import org.opendaylight.controller.md.sal.common.api.data.LogicalDatastoreType;
import org.opendaylight.controller.md.sal.common.api.data.TransactionCommitFailedException;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.HelloInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.HelloOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.HelloOutputBuilder;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.HelloRegistry;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.HelloRegistryBuilder;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.PtnService;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.hello.registry.HelloRegistryEntry;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.hello.registry.HelloRegistryEntryBuilder;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.hello.registry.HelloRegistryEntryKey;
import org.opendaylight.yangtools.yang.binding.InstanceIdentifier;
import org.opendaylight.yangtools.yang.common.RpcResult;
import org.opendaylight.yangtools.yang.common.RpcResultBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.util.concurrent.CheckedFuture;
import com.google.common.util.concurrent.Futures;

public class PtnImpl implements PtnService {
	
	private static final Logger LOG = LoggerFactory.getLogger(PtnImpl.class);
	private DataBroker db;

	public PtnImpl(DataBroker adb) {
		// TODO_Auto-generated constructor stub
		db = adb;
		LOG.info("PtnImpl::PtnImpl() cloning data broker "+db.toString());
		initializeDataTree(db);
	}

	
    private void initializeDataTree(DataBroker db) {
        LOG.info("PtnImpl::initializeDataTree() Preparing to initialize the greeting registry");
        WriteTransaction transaction = db.newWriteOnlyTransaction();
        InstanceIdentifier<HelloRegistry> iid = InstanceIdentifier.create(HelloRegistry.class);
        HelloRegistry helloRegistry = new HelloRegistryBuilder()
                .build();
        transaction.put(LogicalDatastoreType.OPERATIONAL, iid, helloRegistry);
        CheckedFuture<Void, TransactionCommitFailedException> future = transaction.submit();
        Futures.addCallback(future, new LoggingFuturesCallBack<>("PtnImpl::initializeDataTree() failed to create greeting registry ", LOG));
    }
    
	@Override
	public Future<RpcResult<HelloOutput>> hello(HelloInput input) {
    	// TODO_Auto-generated method stub
    	LOG.info("PtnImpl::hello input message="+input.getName());
    	HelloOutput output = new HelloOutputBuilder()
    			.setReply("PtnService reply of hello " + input.getName())
    			.build();
    	
    	writeToHelloRegistry(input, output);
    	return RpcResultBuilder.success(output).buildFuture();
	}
	
    private void writeToHelloRegistry(HelloInput input, HelloOutput output) {
        WriteTransaction transaction = db.newWriteOnlyTransaction();
        InstanceIdentifier<HelloRegistryEntry> iid = toInstanceIdentifier(input);
        HelloRegistryEntry greeting = new HelloRegistryEntryBuilder()
        		.setReply(output.getReply())
                .setName(input.getName())
                .build();
        transaction.put(LogicalDatastoreType.OPERATIONAL, iid, greeting);
        CheckedFuture<Void, TransactionCommitFailedException> future = transaction.submit();
        Futures.addCallback(future, new LoggingFuturesCallBack<Void>("Failed to write greeting to greeting registry", LOG));
    }

    private InstanceIdentifier<HelloRegistryEntry> toInstanceIdentifier( HelloInput input) {
        InstanceIdentifier<HelloRegistryEntry> iid = InstanceIdentifier.create(HelloRegistry.class)
            .child(HelloRegistryEntry.class, new HelloRegistryEntryKey(input.getName()));
        return iid;
    }

}
