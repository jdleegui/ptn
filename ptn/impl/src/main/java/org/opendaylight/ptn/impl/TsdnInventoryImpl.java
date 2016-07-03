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
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.HelloRegistry;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ptn.rev150105.HelloRegistryBuilder;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.DeleteAccessIfInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.DeleteAccessIfOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.DeleteCompletePathSetProvisionServiceInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.DeleteCompletePathSetProvisionServiceOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.DeleteDelegatedServiceInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.DeleteDelegatedServiceOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.DeleteTunnelInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.DeleteTunnelOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.DeleteTunnelXcInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.DeleteTunnelXcOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetAccessIfInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetAccessIfOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetCompletePathSetProvisionServiceInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetCompletePathSetProvisionServiceOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetDelegatedServiceInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetDelegatedServiceOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetNodeConnectorInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetNodeConnectorOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetNodeInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetNodeListInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetNodeListOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetNodeOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetTunnelInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetTunnelOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetTunnelXcInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetTunnelXcOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.SetAccessIfInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.SetAccessIfOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.SetCompletePathSetProvisionServiceInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.SetCompletePathSetProvisionServiceOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.SetDelegatedServiceInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.SetDelegatedServiceOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.SetTunnelInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.SetTunnelOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.SetTunnelXcInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.SetTunnelXcOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.TsdnInventoryService;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.UpdateAccessIfInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.UpdateAccessIfOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.UpdateCompletePathSetProvisionServiceInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.UpdateCompletePathSetProvisionServiceOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.UpdateDelegatedServiceInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.UpdateDelegatedServiceOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.UpdateTunnelInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.UpdateTunnelOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.UpdateTunnelXcInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.UpdateTunnelXcOutput;
import org.opendaylight.yangtools.yang.binding.InstanceIdentifier;
import org.opendaylight.yangtools.yang.common.RpcResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.util.concurrent.CheckedFuture;
import com.google.common.util.concurrent.Futures;

public class TsdnInventoryImpl implements TsdnInventoryService {

	private static final Logger LOG = LoggerFactory.getLogger(TsdnInventoryImpl.class);
	private DataBroker db;

	public TsdnInventoryImpl(DataBroker adb) {
		// TODO_Auto-generated constructor stub
		db = adb;
		LOG.info("TsdnInventoryImpl::TsdnInventoryService() cloning data broker " + db.toString());
		initializeDataTree(db);
	}

	private void initializeDataTree(DataBroker db) {
		LOG.info("TsdnInventoryImpl::initializeDataTree() preparing to initialize the greeting registry");
		WriteTransaction transaction = db.newWriteOnlyTransaction();
		InstanceIdentifier<HelloRegistry> iid = InstanceIdentifier.create(HelloRegistry.class);
		//NodesBuilder();
		new NodesBuiler();
		HelloRegistry helloRegistry = new HelloRegistryBuilder().build();
		transaction.put(LogicalDatastoreType.OPERATIONAL, iid, helloRegistry);
		CheckedFuture<Void, TransactionCommitFailedException> future = transaction.submit();
		Futures.addCallback(future, new LoggingFuturesCallBack<>(
				"TsdnInventoryImpl::initializeDataTree() failed to create greeting registry ", LOG));
	}

	@Override
	public Future<RpcResult<UpdateDelegatedServiceOutput>> updateDelegatedService(UpdateDelegatedServiceInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<GetDelegatedServiceOutput>> getDelegatedService(GetDelegatedServiceInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<SetTunnelOutput>> setTunnel(SetTunnelInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<DeleteTunnelXcOutput>> deleteTunnelXc(DeleteTunnelXcInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<UpdateCompletePathSetProvisionServiceOutput>> updateCompletePathSetProvisionService(
			UpdateCompletePathSetProvisionServiceInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<SetCompletePathSetProvisionServiceOutput>> setCompletePathSetProvisionService(
			SetCompletePathSetProvisionServiceInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<DeleteAccessIfOutput>> deleteAccessIf(DeleteAccessIfInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<UpdateTunnelOutput>> updateTunnel(UpdateTunnelInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<SetTunnelXcOutput>> setTunnelXc(SetTunnelXcInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<SetAccessIfOutput>> setAccessIf(SetAccessIfInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<DeleteDelegatedServiceOutput>> deleteDelegatedService(DeleteDelegatedServiceInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<DeleteTunnelOutput>> deleteTunnel(DeleteTunnelInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<GetNodeConnectorOutput>> getNodeConnector(GetNodeConnectorInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<DeleteCompletePathSetProvisionServiceOutput>> deleteCompletePathSetProvisionService(
			DeleteCompletePathSetProvisionServiceInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<GetNodeListOutput>> getNodeList(GetNodeListInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<GetTunnelOutput>> getTunnel(GetTunnelInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<GetCompletePathSetProvisionServiceOutput>> getCompletePathSetProvisionService(
			GetCompletePathSetProvisionServiceInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<SetDelegatedServiceOutput>> setDelegatedService(SetDelegatedServiceInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<GetNodeOutput>> getNode(GetNodeInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<UpdateTunnelXcOutput>> updateTunnelXc(UpdateTunnelXcInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<GetTunnelXcOutput>> getTunnelXc(GetTunnelXcInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<UpdateAccessIfOutput>> updateAccessIf(UpdateAccessIfInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<GetAccessIfOutput>> getAccessIf(GetAccessIfInput input) {
		// TODO Auto-generated method stub
		return null;
	}

}
