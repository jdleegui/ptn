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
import org.opendaylight.controller.md.sal.binding.api.ReadOnlyTransaction;
import org.opendaylight.controller.md.sal.binding.api.WriteTransaction;
import org.opendaylight.controller.md.sal.common.api.data.LogicalDatastoreType;
import org.opendaylight.controller.md.sal.common.api.data.ReadFailedException;
import org.opendaylight.controller.md.sal.common.api.data.TransactionCommitFailedException;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ietf.inet.types.rev130715.IpAddress;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.ietf.inet.types.rev130715.Ipv4Address;
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
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetNodeOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetTunnelInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetTunnelOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetTunnelXcInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.GetTunnelXcOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.Nodes;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.NodesBuilder;
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
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.nodes.Node;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.nodes.NodeBuilder;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.nodes.NodeKey;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.node.rev150105.NodeId;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.node.rev150105.NodeStatusType;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.node.rev150105.NodeType;
import org.opendaylight.yangtools.yang.binding.InstanceIdentifier;
import org.opendaylight.yangtools.yang.common.RpcResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Optional;
import com.google.common.util.concurrent.CheckedFuture;
import com.google.common.util.concurrent.Futures;

public class TsdnInventoryImpl implements TsdnInventoryService {

	private static final Logger LOG = LoggerFactory.getLogger(TsdnInventoryImpl.class);
	private DataBroker db;

	public TsdnInventoryImpl(DataBroker adb) {
		// TODO_Auto-generated constructor stub
		db = adb;
		initializeDataTree(adb);
		
		LOG.info("TsdnInventoryImpl started");
		LOG.info("TsdnInventoryImpl is " + toString());

		for (int i = 1; i < 20; i++) {			
			writeToNodes(NodeId.getDefaultInstance("Node"+i));
		}
	}
	
    private void initializeDataTree(DataBroker adb) {
    	LOG.info("TsdnInventoryImpl cunstructor : preparing to initializeDataTree for the nodes.");
        WriteTransaction transaction = adb.newWriteOnlyTransaction();
        
        InstanceIdentifier < Nodes > iid = InstanceIdentifier.create( Nodes.class);
        Nodes nodes = new NodesBuilder().build();
        transaction.put(LogicalDatastoreType.OPERATIONAL, iid, nodes);
        CheckedFuture<Void, TransactionCommitFailedException> future = transaction.submit();
        Futures.addCallback(future, new LoggingFuturesCallBack<>("Failed to create nodes", LOG));
    }
    
    private void writeToNodes(NodeId input) {
    	LOG.info("TsdnInventoryImpl:writeToNodes"+input.toString());
        WriteTransaction transaction = db.newWriteOnlyTransaction();
        InstanceIdentifier<Node> iid = toInstanceIdentifier(input);
        Node node = new NodeBuilder()
				.setHardware("a")
				.setHardware("YsKim/JsPark/SsLim/SwWhang")
				.setSoftware("MJSeo/HhChoi/NwLee/KsKim")				
				.setNodeId(input)
				.setLocalId("Local ID")
				.setName("Name")
				.setNodeType(NodeType.Ptn)         
				.setIpAddress(new IpAddress(Ipv4Address.getDefaultInstance("50.23.21.5")))
				.setManufacturer("Coweaver")
				.setManufacturerModelName("ut7200")
				.setSerialNumber("1234567890")
				.setNodeStatus(NodeStatusType.Normal)
				.setNodeConnector(null)				
        		.build();
        transaction.put(LogicalDatastoreType.OPERATIONAL, iid, node);
        CheckedFuture<Void, TransactionCommitFailedException> future = transaction.submit();
        Futures.addCallback(future, new LoggingFuturesCallBack<Void>("Failed to write nodes to node", LOG));
        readFromNodeId(input);
    }  

	private NodeId readFromNodeId(NodeId nodeId) {
		ReadOnlyTransaction transaction = db.newReadOnlyTransaction();
		InstanceIdentifier <Node> iid = toInstanceIdentifier(nodeId);
		CheckedFuture<Optional<Node>, ReadFailedException> future =
			transaction.read(LogicalDatastoreType.CONFIGURATION, iid);
		Optional<Node> optional = Optional.absent();
		try {
			optional = future.checkedGet();
		} catch (ReadFailedException e) {
			LOG.warn("Reading node input failed:", e);
		}
		if(optional.isPresent()) {
			nodeId = optional.get().getNodeId();
		}
		return nodeId;
	}

    private InstanceIdentifier<Node> toInstanceIdentifier(NodeId input) {
        InstanceIdentifier<Node> iid = InstanceIdentifier.create(Nodes.class)
        		.child(Node.class, new NodeKey(input));    	
        return iid;
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
