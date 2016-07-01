/*
 * Copyright © 2015 Copyright(c) Coweaver, Inc. and others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.ptn.impl;

import org.opendaylight.controller.md.sal.binding.api.DataBroker;
import org.opendaylight.controller.sal.binding.api.BindingAwareBroker.ProviderContext;
import org.opendaylight.controller.sal.binding.api.BindingAwareBroker.RpcRegistration;
import org.opendaylight.controller.sal.binding.api.BindingAwareProvider;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.PtnService;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.TsdnInventoryService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PtnProvider implements BindingAwareProvider, AutoCloseable {

    private static final Logger LOG = LoggerFactory.getLogger(PtnProvider.class);
    private RpcRegistration <PtnService> ptnService;
	private RpcRegistration <TsdnInventoryService> tsdnInventoryService;
    
    @Override
    public void onSessionInitiated(ProviderContext session) {
        LOG.info("PtnProvider Session Initiated");
        
        DataBroker db = session.getSALService(DataBroker.class);
        tsdnInventoryService = session.addRpcImplementation(TsdnInventoryService.class, new TsdnInventoryImpl(db));
        ptnService = session.addRpcImplementation(PtnService.class,  new PtnImpl(db));
    }

    @Override
    public void close() throws Exception {
        LOG.info("PtnProvider Closed");     
        if (ptnService != null)
        	ptnService.close();
        if (tsdnInventoryService != null)
        	tsdnInventoryService.close();
    }
}
