/*
 * Copyright © 2015 Copyright(c) Coweaver, Inc. and others.  All rights reserved.
 *
 * This program and the accompanying materials are made available under the
 * terms of the Eclipse Public License v1.0 which accompanies this distribution,
 * and is available at http://www.eclipse.org/legal/epl-v10.html
 */
package org.opendaylight.ptn.impl;
import java.lang.reflect.Type;

import org.opendaylight.yang.gen.v1.urn.opendaylight.params.xml.ns.yang.tsdn.inventory.rev150105.nodes.Node;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;

public class TsdnNodeSerializer implements JsonSerializer <Node> {
	
	private static 	final Logger LOG = LoggerFactory.getLogger(TsdnNodeSerializer.class);

	@Override
	public JsonElement serialize(Node src, Type typeOfSrc, JsonSerializationContext context) {
		// TODO_Auto-generated method stub
		LOG.info("TsdnNodeSerializer:starting serialize");
		final JsonObject jsonObject = new JsonObject();
		final JsonObject jsonNodeInterface = new JsonObject();
		jsonNodeInterface.addProperty("nodeId", src.getNodeId().toString());
		jsonNodeInterface.addProperty("hardware", src.getHardware());
		jsonNodeInterface.addProperty("serialNumber", src.getSerialNumber());
		LOG.info("TsdnNodeSerializer:starting return");
		return jsonObject; 
	}

}
