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
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.DeleteMplsIfInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.DeleteMplsIfOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.DeletePwInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.DeletePwOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.DeletePwXcInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.DeletePwXcOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.DeleteVpnInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.DeleteVpnOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.GetMplsIfInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.GetMplsIfOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.GetPwInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.GetPwOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.GetPwXcInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.GetPwXcOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.GetVpnInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.GetVpnOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.MplsTpInventoryService;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.SetMplsIfInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.SetMplsIfOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.SetPwInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.SetPwOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.SetPwXcInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.SetPwXcOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.SetVpnInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.SetVpnOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.UpdateMplsIfInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.UpdateMplsIfOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.UpdatePwInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.UpdatePwOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.UpdatePwXcInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.UpdatePwXcOutput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.UpdateVpnInput;
import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.mpls.tp.inventory.rev150105.UpdateVpnOutput;
import org.opendaylight.yangtools.yang.common.RpcResult;


public class MplsTpInventoryImpl implements MplsTpInventoryService {

	public MplsTpInventoryImpl(DataBroker db) {
		// TODO Auto-generated constructor stub
	}

	@Override
	public Future<RpcResult<GetPwOutput>> getPw(GetPwInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<SetVpnOutput>> setVpn(SetVpnInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<UpdateMplsIfOutput>> updateMplsIf(UpdateMplsIfInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<DeletePwXcOutput>> deletePwXc(DeletePwXcInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<DeleteMplsIfOutput>> deleteMplsIf(DeleteMplsIfInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<SetPwXcOutput>> setPwXc(SetPwXcInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<UpdateVpnOutput>> updateVpn(UpdateVpnInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<UpdatePwXcOutput>> updatePwXc(UpdatePwXcInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<SetMplsIfOutput>> setMplsIf(SetMplsIfInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<DeleteVpnOutput>> deleteVpn(DeleteVpnInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<GetMplsIfOutput>> getMplsIf(GetMplsIfInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<DeletePwOutput>> deletePw(DeletePwInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<UpdatePwOutput>> updatePw(UpdatePwInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<SetPwOutput>> setPw(SetPwInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<GetVpnOutput>> getVpn(GetVpnInput input) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public Future<RpcResult<GetPwXcOutput>> getPwXc(GetPwXcInput input) {
		// TODO Auto-generated method stub
		return null;
	}

}
