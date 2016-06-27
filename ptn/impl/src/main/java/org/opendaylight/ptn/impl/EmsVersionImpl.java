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
