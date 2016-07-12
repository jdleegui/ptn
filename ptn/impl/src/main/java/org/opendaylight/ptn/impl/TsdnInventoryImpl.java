/*
 * Copyright © 2015 Copyright(c) Coweaver, Inc. and others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.ptn.impl;

import java.util.ArrayList;
import java.util.concurrent.Future;

import org.opendaylight.controller.md.sal.binding.api.DataBroker;
import org.opendaylight.controller.md.sal.binding.api.ReadOnlyTransaction;
import org.opendaylight.controller.md.sal.binding.api.WriteTransaction;
import org.opendaylight.controller.md.sal.common.api.data.LogicalDatastoreType;
import org.opendaylight.controller.md.sal.common.api.data.ReadFailedException;
import org.opendaylight.controller.md.sal.common.api.data.TransactionCommitFailedException;
import org.opendaylight.controller.sal.binding.api.BindingAwareBroker.ProviderContext;
import org.opendaylight.controller.sal.binding.api.BindingAwareBroker.RoutedRpcRegistration;
import org.opendaylight.yang.gen.v1.urn.ietf.params.xml.ns.yang.ietf.inet.types.rev130715.IpAddress;
import org.opendaylight.yang.gen.v1.urn.ietf.params.xml.ns.yang.ietf.inet.types.rev130715.Ipv4Address;
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
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.node.rev150105.NodeContext;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.node.rev150105.NodeId;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.node.rev150105.NodeRef;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.node.rev150105.NodeStatusType;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.node.rev150105.NodeType;
import org.opendaylight.yangtools.yang.binding.InstanceIdentifier;
import org.opendaylight.yangtools.yang.common.RpcResult;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Optional;
import com.google.common.util.concurrent.CheckedFuture;
import com.google.common.util.concurrent.Futures;
//import com.google.gson.Gson;
//import com.google.gson.GsonBuilder;


public class TsdnInventoryImpl implements TsdnInventoryService {

	private static final Logger LOG = LoggerFactory.getLogger(TsdnInventoryImpl.class);
	private DataBroker db;
	private ArrayList <Node> nodeList;
	private Nodes nodes = null;
	private ProviderContext session;
//	private final Gson gsonTsdnNodeInterface;
//	private GsonBuilder gsonTsdnNodeBuilder;
	private RoutedRpcRegistration<TsdnInventoryService> reg;
	
	public TsdnInventoryImpl(DataBroker adb) {
		// TODO_Auto-generated constructor stub
		db = adb;
		LOG.info("TsdnInventoryImpl::TsdnInventoryImpl(db) cloning data broker " + db.toString());
		initializeDataTree(db);
	}  
	
	public TsdnInventoryImpl(ProviderContext asession) {
		// TODO_Auto-generated constructor stub
		session = asession;
		db = session.getSALService(DataBroker.class);
		LOG.info("TsdnInventoryImpl::TsdnInventoryImpl(session) cloning data broker " + db.toString());

//		gsonTsdnNodeBuilder.registerTypeAdapter(Node.class, new TsdnNodeSerializer());
//		LOG.info("TsdnInventoryImpl::IsdnInventoryImpl() Trying to prettyPrinting()");
//		gsonTsdnNodeBuilder.setPrettyPrinting();
//		LOG.info("TsdnInventoryImpl::IsdnInventoryImpl() Trying to bring()");
//		gsonTsdnNodeInterface = gsonTsdnNodeBuilder.create();
//		LOG.info("TsdnInventoryImpl::IsdnInventoryImpl() Trying to end create()");
		
		
	}  
	
	private void writeToNodes(NodeId input) {
		LOG.info("TsdnInventoryImpl:writeToNodes(NodeId input="+input.toString()+").");
		WriteTransaction transaction = db.newWriteOnlyTransaction();
		InstanceIdentifier<Node> iid = toInstanceIdentifier(input);
		Node node = new NodeBuilder()				
				.setHardware("[NODE_COWAVER_HARDWARE]")
				.setIpAddress(new IpAddress(Ipv4Address.getDefaultInstance("50.23.21.5")))
				.setKey(new NodeKey(input))
				.setLocalId("[NODE_COWAVER_LOCAL_ID]")
				.setManufacturer("[NODE_COWAVER_MANUFACTURER]")
				.setManufacturerModelName("[NODE_COWAVER_MODEL_NAME]")
				.setName("[NODE_COWAVER_NAME]")
				.setNodeConnector(null)
				.setNodeId(input)
				.setNodeStatus(NodeStatusType.Normal)
				.setNodeType(NodeType.Ptn)         
				.setSerialNumber("[NODE_COWAVER_SERIAL_NUMBER]")
				.setSoftware("[NODE_COWAVER_SOFTWARE]")				
				.setTopologyRef(null)
				.build();
		
		NodeRef nodeRef = createNodeRef(input.toString());
		LOG.info("will regist "+input.toString()+"."+nodeRef.getValue());
		//session.addRoutedRpcImplementation(TsdnInventoryImpl.class, node);
		reg.registerPath(NodeContext.class, nodeRef.getValue());

		LOG.info("TsdnInventoryImpl:writeToNodes with instance ("+iid.toString()+node.getNodeId().toString()+").");
		LOG.info("TsdnInventoryImpl:writeToNodes with node ("+node.toString()+").");
		transaction.put(LogicalDatastoreType.OPERATIONAL, iid, node);
		CheckedFuture<Void, TransactionCommitFailedException> future = transaction.submit();
		Futures.addCallback(future, new LoggingFuturesCallBack<Void>("TsdnInventoryImpl::writeToNodes(IndeId input) failed to write nodes to node", LOG));
		readFromNodeId(input);
	}

	public void setRegister(RoutedRpcRegistration<TsdnInventoryService> firstReg) {
		// TODO_Auto-generated method stub
		this.reg = firstReg;
		for (int i = 1; i < 20; i++) { 
			writeToNodes(NodeId.getDefaultInstance("Node"+i));
		}
	}
	
	// https://git.opendaylight.org/gerrit/gitweb?p=controller.git;a=blob;f=opendaylight/md-sal/sal-binding-it/src/test/java/org/opendaylight/controller/test/sal/binding/it/RoutedServiceTest.java;h=d49d6f0e25e271e43c8550feb5eef63d96301184;hb=HEAD
	// https://github.com/opendaylight/docs/blob/master/manuals/developer-guide/src/main/asciidoc/controller/md-sal-rpc-routing.adoc
	private static NodeRef createNodeRef(String string) {
		NodeKey key = new NodeKey(new NodeId(string));
		InstanceIdentifier<Node> path = InstanceIdentifier.builder(Nodes.class).child(Node.class, key).build();
		return new NodeRef(path);
	}
	
	private NodeId readFromNodeId(NodeId nodeId) {
		LOG.info("TsdnInventoryImpl:readFromNodeId(NodeId input="+nodeId.toString()+").");
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

	private void initializeDataTree(DataBroker db) {
		LOG.info("TsdnInventoryImpl::initializeDataTree() preparing to initialize the nodes");
		WriteTransaction transaction = db.newWriteOnlyTransaction();
		InstanceIdentifier<Nodes> iid = InstanceIdentifier.create(Nodes.class);
		
		Node node = new NodeBuilder()
				.setHardware("[coweaver_hward_ware]")
				.setHardware("[Node:HW:YsKim/JsPark/SsLim/SwWhang]")
				.setSoftware("[Node:SW:MJSeo/HhChoi/NwLee/KsKim]")				
				.setNodeId(NodeId.getDefaultInstance("Node"))
				.setLocalId("Local ID")
				.setName("[Node:CoweaverName]")
				.setNodeType(NodeType.Ptn)         
				.setIpAddress(new IpAddress(Ipv4Address.getDefaultInstance("50.23.21.5")))
				.setManufacturer("[Coweaver]")
				.setManufacturerModelName("[COWEVER-UT7200]")
				.setSerialNumber("[COW-010-3227-1453]")
				.setNodeStatus(NodeStatusType.Normal)
				.setNodeConnector(null)
				.build();
		
		nodeList = new ArrayList<Node>();
		nodeList.add(node);
		
		nodes = new NodesBuilder()
				.setNode(nodeList)
				.build();
		LOG.info("TsdnInventoryImpl:initializeDatrTree with instance ("+iid.toString()+").");
		transaction.put(LogicalDatastoreType.OPERATIONAL, iid, nodes);
		CheckedFuture<Void, TransactionCommitFailedException> future = transaction.submit();
		Futures.addCallback(future, new LoggingFuturesCallBack<>(
				"TsdnInventoryImpl::initializeDataTree() failed to create initialize data tree ", LOG));
	}

	@SuppressWarnings("unused")
	private void initializeDataTree2(DataBroker db) {
		LOG.info("TsdnInventoryImpl::initializeDataTree() preparing to initialize data tree2");
		WriteTransaction transaction = db.newWriteOnlyTransaction();
		InstanceIdentifier<Node> iid = InstanceIdentifier.create(Node.class);
		Node node = new NodeBuilder()
				.setHardware("[coweaver_hward_ware]")
				.setHardware("[Node:HW:YsKim/JsPark/SsLim/SwWhang]")
				.setSoftware("[Node:SW:MJSeo/HhChoi/NwLee/KsKim]")				
				.setNodeId(NodeId.getDefaultInstance("Node"))
				.setLocalId("Local ID")
				.setName("[Node:CoweaverName]")
				.setNodeType(NodeType.Ptn)         
				.setIpAddress(new IpAddress(Ipv4Address.getDefaultInstance("50.23.21.5")))
				.setManufacturer("[Coweaver]")
				.setManufacturerModelName("[COWEVER-UT7200]")
				.setSerialNumber("[COW-010-3227-1453]")
				.setNodeStatus(NodeStatusType.Normal)
				.setNodeConnector(null)							
				.build();
		transaction.put(LogicalDatastoreType.OPERATIONAL, iid, node);
		CheckedFuture<Void, TransactionCommitFailedException> future = transaction.submit();
		Futures.addCallback(future, new LoggingFuturesCallBack<>(
				"TsdnInventoryImpl::initializeDataTree() failed to create greeting registry ", LOG));
	}

	@SuppressWarnings("unused")
	private void initializeDataTree1(DataBroker db) {
		LOG.info("TsdnInventoryImpl::initializeDataTree() preparing to initialize the greeting registry");
		WriteTransaction transaction = db.newWriteOnlyTransaction();
		InstanceIdentifier<Nodes> iid = InstanceIdentifier.create(Nodes.class);
		Nodes nodes = new NodesBuilder()
				.build();
		transaction.put(LogicalDatastoreType.OPERATIONAL, iid, nodes);
		CheckedFuture<Void, TransactionCommitFailedException> future = transaction.submit();
		Futures.addCallback(future, new LoggingFuturesCallBack<>(
				"TsdnInventoryImpl::initializeDataTree() failed to create greeting registry ", LOG));
	}

	@Override
	public Future<RpcResult<UpdateDelegatedServiceOutput>> updateDelegatedService(UpdateDelegatedServiceInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl::updateDelegatedService called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<GetDelegatedServiceOutput>> getDelegatedService(GetDelegatedServiceInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl:: called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<SetTunnelOutput>> setTunnel(SetTunnelInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl::setTunnel(SetTunnelInput input) called ("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<DeleteTunnelXcOutput>> deleteTunnelXc(DeleteTunnelXcInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl:: called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<UpdateCompletePathSetProvisionServiceOutput>> updateCompletePathSetProvisionService(
			UpdateCompletePathSetProvisionServiceInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl:: called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<SetCompletePathSetProvisionServiceOutput>> setCompletePathSetProvisionService(
			SetCompletePathSetProvisionServiceInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl:: called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<DeleteAccessIfOutput>> deleteAccessIf(DeleteAccessIfInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl:: called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<UpdateTunnelOutput>> updateTunnel(UpdateTunnelInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl:: called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<SetTunnelXcOutput>> setTunnelXc(SetTunnelXcInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl:: called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<SetAccessIfOutput>> setAccessIf(SetAccessIfInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl:: called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<DeleteDelegatedServiceOutput>> deleteDelegatedService(DeleteDelegatedServiceInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl:: called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<DeleteTunnelOutput>> deleteTunnel(DeleteTunnelInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl:: called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<GetNodeConnectorOutput>> getNodeConnector(GetNodeConnectorInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl:: called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<DeleteCompletePathSetProvisionServiceOutput>> deleteCompletePathSetProvisionService(
			DeleteCompletePathSetProvisionServiceInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl::deleteCompletePathSetPrivisionService called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<GetTunnelOutput>> getTunnel(GetTunnelInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl::getTunnel called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<GetCompletePathSetProvisionServiceOutput>> getCompletePathSetProvisionService(
			GetCompletePathSetProvisionServiceInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl::getCompletePathSEtPrivisionService called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<SetDelegatedServiceOutput>> setDelegatedService(SetDelegatedServiceInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl::setDelegatedService called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<GetNodeOutput>> getNode(GetNodeInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl::getNode called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<UpdateTunnelXcOutput>> updateTunnelXc(UpdateTunnelXcInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl::updateTunnelXc called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<GetTunnelXcOutput>> getTunnelXc(GetTunnelXcInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl::getTunnelXc called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<UpdateAccessIfOutput>> updateAccessIf(UpdateAccessIfInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl::updateAccessIf called("+input.toString()+").");
		return null;
	}

	@Override
	public Future<RpcResult<GetAccessIfOutput>> getAccessIf(GetAccessIfInput input) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnInventoryImpl::getAccessIf called("+input.toString()+").");
		return null;
	}

}
