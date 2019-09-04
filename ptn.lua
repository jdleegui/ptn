-- Coweaver PTN EMS TCP/RS232 common protocol
-- Lee Jeong Dong : jdeegui@gamil.com
-- Last Modified:2019-07-24
ptnems_protocol = Proto("PTN",  "PTN EMS Protocol")

-- Header fields
msg_hdr         = ProtoField.uint16("ptn_wdm.hdr"     , "HEADER" , base.HEX)
msg_len         = ProtoField.uint16("ptn_wdm.len"     , "LENGTH" , base.DEC)
msg_fid         = ProtoField.uint16("ptn_wdm.fid"     , "FID" , base.DEC)
msg_ser         = ProtoField.uint16("ptn_wdm.serial"  , "SERIAL" , base.HEX)
msg_seq         = ProtoField.uint16("ptn_wdm.segment" , "SEGMNT" , base.HEX)
msg_sys         = ProtoField.uint8 ("ptn_wdm.device"  , "SYSTEM" , base.HEX)
msg_ret         = ProtoField.uint8 ("ptn_wdm.return"  , "RESULT" , base.DEC)
msg_key         = ProtoField.uint32("ptn_wdm.hash4"   , "PACKET" , base.HEX)
msg_src_add     = ProtoField.ipv4  ("ptn_wdm.src_ip"  , "SRC_IP")
msg_src_idx     = ProtoField.uint8 ("ptn_wdm.src_id"  , "SRC_ID")
msg_dst_add     = ProtoField.ipv4  ("ptn_wdm.dst_ip"  , "DST_IP")
msg_dst_idx     = ProtoField.uint8 ("ptn_wdm.dst_id"  , "DST_ID")
msg_crc         = ProtoField.uint16("ptn_wdm.crc16"   , "CRC16" , base.HEX)
msg_mac			= ProtoField.ether("ptn_wdm.macaddr"  , "MAC")
msg_uint64      = ProtoField.uint64("ptn_wdm.uint64"  , "uint64")
msg_uint32      = ProtoField.uint32("ptn_wdm.uint32"  , "uint32")
msg_uint16      = ProtoField.uint16("ptn_wdm.uint16"  , "uint16")
msg_uint08      = ProtoField.uint8 ("ptn_wdm.uint08"  , "uint08")

msg_cfg_type	= ProtoField.uint8 ("ptn_wdm.char"    , "SYS_TYPE", base.HEX)
msg_tid_name    = ProtoField.string("ptn_wdm.string"  , "TID_NAME", base.ASCII)

-- Payload fields
flags           = ProtoField.int32 ("ptn_wdm.flags"           , "flags"             , base.DEC)
full_coll_name  = ProtoField.string("ptn_wdm.full_coll_name"  , "fullCollectionName", base.ASCII)
number_to_skip  = ProtoField.int32 ("ptn_wdm.number_to_skip"  , "numberToSkip"      , base.DEC)
number_to_return= ProtoField.int32 ("ptn_wdm.number_to_return", "numberToReturn"    , base.DEC)
query           = ProtoField.string("ptn_wdm.query"           , "query"             , base.ASCII)

response_flags  = ProtoField.int32 ("ptn_wdm.response_flags"  , "responseFlags"     , base.DEC)
cursor_id       = ProtoField.int64 ("ptn_wdm.cursor_id"       , "cursorId"          , base.DEC)
starting_from   = ProtoField.int32 ("ptn_wdm.starting_from"   , "startingFrom"      , base.DEC)
number_returned = ProtoField.int32 ("ptn_wdm.number_returned" , "numberReturned"    , base.DEC)
documents       = ProtoField.string("ptn_wdm.documents"       , "documents"         , base.ASCII)

ptnems_protocol.fields = {
  msg_hdr, msg_len, msg_fid, msg_ser, msg_seq, msg_sys, msg_ret, msg_key, msg_src_add, msg_src_idx, msg_dst_add, msg_dst_idx, msg_crc, -- Header
  msg_cfg_type, msg_tid_name, msg_mac, -- CONFIG
  msg_uint64, msg_uint32, msg_uint16, msg_uint08,
  flags, full_coll_name, number_to_skip, number_to_return, query,      -- OP_QUERY
  response_flags, cursor_id, starting_from, number_returned, documents -- OP_REPLY
}

function ptnems_protocol.dissector(buffer, pinfo, tree)
  length = buffer:len()
  if length == 0 then return end

  pinfo.cols.protocol = ptnems_protocol.name

  local subtree = tree:add(ptnems_protocol, buffer(), "PTN WDM EMS Protocol Data")

  -- Header
  local p_len = 0
  while (p_len < length) do
  local i = p_len
  subtree:add(msg_hdr, buffer(i,2))
  i = i+2
  local pay_len = buffer(i,2):uint()
  pay_len = pay_len-28
  subtree:add(msg_len, buffer(i,2))
  i = i+2
  local fid_code = buffer(i,2):uint()
  local sys_code = buffer(i+6,1):uint()
  local fid_name = get_cod_name(sys_code, fid_code)
  subtree:add(msg_fid, buffer(i,2)):append_text(" (" .. fid_name .. ")")
  i = i+2
  subtree:add(msg_ser, buffer(i,2))
  i = i+2
  subtree:add(msg_seq, buffer(i,2))
  i = i+2
  local sys_name = get_sys_name(sys_code)
  subtree:add(msg_sys, buffer(i,1)):append_text(" (" .. sys_name ..")")
  i = i+1
  subtree:add(msg_ret, buffer(i,1))
  i = i+1
  subtree:add(msg_key, buffer(i,4))
  i = i+4
  subtree:add(msg_src_add, buffer(i,4))
  i = i+4
  subtree:add(msg_src_idx, buffer(i,1))
  i = i+1
  subtree:add(msg_dst_add, buffer(i,4))
  i = i+4
  subtree:add(msg_dst_idx, buffer(i,1))
  i = i+1
  subtree:add(msg_crc, buffer(i,2))
  i = i+2
  -- Payload

  if fid_name == "SYS_GET_SYSTEM_FAN_INFO" then
  elseif fid_name == "NE_CONFIG" then
	subtree:add(msg_cfg_type, buffer(i,1))
	i = i+1
	subtree:add(msg_tid_name, buffer(i,21))
  elseif fid_name == "HELLO_ACK" then
	if (length <= i) then return end
	--while (i < length) do
	subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_ne_hello_ack_msg_t::upv.key_ring(i="..i..")len="..length..")")
	i = i+4
	subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_ne_hello_ack_msg_t::upv.version")
	i = i+4
	subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_ne_hello_ack_msg_t::upv.TIME::year")
	i = i+2
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_ne_hello_ack_msg_t::upv.TIME::month")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_ne_hello_ack_msg_t::upv.TIME::day")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_ne_hello_ack_msg_t::upv.TIME::hour")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_ne_hello_ack_msg_t::upv.TIME::min")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_ne_hello_ack_msg_t::upv.TIME::sec")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_ne_hello_ack_msg_t::upv.ne_id")
	i = i+1
	subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_ne_hello_ack_msg_t->ne_time")
	i = i+4
	subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_ne_hello_ack_msg_t::upv.ne_id")
	i = i+4
	subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_ne_hello_ack_msg_t->lsr_id")
	i = i+4
	subtree:add(msg_mac, buffer(i,6)):append_text(":smi_ne_hello_ack_msg_t->mac")
	i = i+6
	--end
  elseif fid_name == "GET_SLOT_PROVISION" then
    if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_slot_msg_status_info_t::smi_pid->pid_type(i="..i..")len="..length..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_slot_msg_status_info_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_slot_msg_status_info_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_slot_msg_status_info_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_slot_msg_status_info_t::smi_pid->port_id")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_slot_msg_status_info_t::flags")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_status_info_t->slot_id")
		i = i+1
		subtree:add(msg_uint16, buffer(i,1)):append_text(":smi_slot_msg_status_info_t::switch_group")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_status_info_t->installed")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_status_info_t->adminAct")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_status_info_t->svcType")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_status_info_t->is_active")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_status_info_t->sw_state")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_status_info_t->port_number,fpga_cot")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_status_info_t->vendor(enduro=0,saver=1)")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_status_info_t->wdm_degree_tx")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_status_info_t->wdm_degree_rx")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_status_info_t->add_drop_side")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_status_info_t->provision_card")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_status_info_t->dummy1")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_status_info_t->dummy2")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_status_info_t->dummy3")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_status_info_t->real_card")
		i = i+1
	end
  elseif fid_name == "SET_SLOT_PROVISION" then
    if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_slot_msg_cfg_info_t::smi_pid->pid_type(i="..i..")len="..length..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_slot_msg_cfg_info_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_slot_msg_cfg_info_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_slot_msg_cfg_info_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_slot_msg_cfg_info_t::smi_pid->port_id")
		i = i+2
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_cfg_info_t->slot_id")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_cfg_info_t->is_group")
		i = i+1
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_slot_msg_cfg_info_t->result")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_cfg_info_t->adminAct")
		i = i+1
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_slot_msg_cfg_info_t->flag")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_slot_msg_cfg_info_t->provision_card")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_cfg_info_t->wdm_degree_tx")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_cfg_info_t->wdm_degree_rx")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_slot_msg_cfg_info_t->ab_side")
		i = i+1
		subtree:add(buffer(i,18):string()):append_text(":smi_slot_msg_cfg_info_t->names")
		i = i+18
	end
  elseif fid_name == "SYS_SW_GET_PROM" or fid_name == "SYS_SW_SET_PROM" then
    if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":mib_rtrv_prom_ack->smi_pid->pid_type(i="..i..")len="..length..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":mib_rtrv_prom_ack->smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":mib_rtrv_prom_ack->smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":mib_rtrv_prom_ack->smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":mib_rtrv_prom_ack->smi_pid->port_id")
		i = i+2
		subtree:add(buffer(i,64):string()):append_text(":mib_rtrv_prom_ack->szfile")
		i = i+64
		subtree:add(msg_uint32, buffer(i,4)):append_text(":mib_rtrv_prom_ack->length")
		i = i+4
		j = 0
		while(j<4) do
			subtree:add(msg_uint32, buffer(i,4)):append_text(":mib_rtrv_prom_ack::mib_rtrv_prom_r->chksum.j="..j.."[0=FROM1,1=FROM2,2=RAM,3=RUN]")
			i = i+4
			subtree:add(msg_uint08, buffer(i,1)):append_text(":mib_rtrv_prom_ack::mib_rtrv_prom_r->active")
			i = i+1
			subtree:add(msg_uint16, buffer(i,2)):append_text(":mib_rtrv_prom_ack::mib_rtrv_prom_r->version")
			i = i+2
			subtree:add(msg_uint32, buffer(i,4)):append_text(":mib_rtrv_prom_ack::mib_rtrv_prom_r->length")
			i = i+4
			subtree:add(msg_uint16, buffer(i,2)):append_text(":mib_rtrv_prom_ack::mib_rtrv_prom_r::STIME->year")
			i = i+2
			subtree:add(msg_uint08, buffer(i,1)):append_text(":mib_rtrv_prom_ack::mib_rtrv_prom_r::STIME->month")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":mib_rtrv_prom_ack::mib_rtrv_prom_r::STIME->date")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":mib_rtrv_prom_ack::mib_rtrv_prom_r::STIME->hour")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":mib_rtrv_prom_ack::mib_rtrv_prom_r::STIME->min")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":mib_rtrv_prom_ack::mib_rtrv_prom_r::STIME->sec")
			i = i+1
			subtree:add(buffer(i,44):string()):append_text(":mib_rtrv_prom_ack::mib_rtrv_prom_r->szdesc")
			i = i+44
			j = j+1
		end
	end
  elseif fid_name == "SYS_GET_SYSTEM_ALARM_COND" or fid_name == "SYS_SET_SYSTEM_ALARM_COND"  or fid_name == "SYS_DEL_SYSTEM_ALARM_COND" then
    if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_oam_aaa_sev_t->flags(i="..i..")len="..length..")")
		i = i+4
		j = 0
		while(j<255) do
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_oam_aaa_sev_t::severity.j="..j.."[0=CRI,1=MAJ,2=MIN,3=NOALM]")
			i = i+1
			j = j+1
		end
	end
  elseif fid_name == "OTN_SET_OTU_PORT_CFG" or fid_name == "OTN_GET_OTU_PORT_CFG" then
    if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_otu_port_cfg_t->smi_pid->pid_type(i="..i..")len="..length..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_otu_port_cfg_t->smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_otu_port_cfg_t->smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_otu_port_cfg_t->smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_otu_port_cfg_t->smi_pid->port_id")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_otu_port_cfg_t->flag")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_otu_port_cfg_t->ifindex")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_otu_port_cfg_t->if_type")
		i = i+4
		subtree:add(buffer(i,32):string()):append_text(":smi_otu_port_cfg_t->smi_mpls_tunnel_idInfo_t->name")
		i = i+32
		subtree:add(buffer(i,32):string()):append_text(":smi_otu_port_cfg_t->smi_mpls_tunnel_idInfo_t->desc")
		i = i+32
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_otu_port_cfg_t->peer_node")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_otu_port_cfg_t->peer_slot")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_otu_port_cfg_t->peer_port")
		i = i+1
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_otu_port_cfg_t->shutdown")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_otu_port_cfg_t->active")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_otu_port_cfg_t->fec_type")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_otu_port_cfg_t->lambda")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_otu_port_cfg_t->lambda_fix")
		i = i+1
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_otu_port_cfg_t->sd_thr")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_otu_port_cfg_t->sf_thr")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_otu_port_cfg_t->ac_type")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_otu_port_cfg_t->clock_advertise")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_otu_port_cfg_t->llcf")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_otu_port_cfg_t->auto_nni")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_otu_port_cfg_t->form_factor")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_otu_port_cfg_t->dummy1")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_otu_port_cfg_t->dummy2")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_otu_port_cfg_t->dummy3")
		i = i+1
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_otu_port_cfg_t->stm_index")
		i = i+4
		j = 0
		while(j<16) do
			subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_otu_port_cfg_t->vc4_index")
			i = i+4
			j = j+1
		end
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_otu_port_cfg_t->link_up")
		i = i+1
		subtree:add(buffer(i,3):string()):append_text(":smi_otu_port_cfg_t->uchar_08_dummy[3]")
		i = i+3
		subtree:add(buffer(i,124):string()):append_text(":smi_otu_port_cfg_t->uint_32_dummy[31]")
		i = i+124
	end
  elseif fid_name == "UT_7400_FID_GET_LINK_PORT" or fid_name == "GET_LINK_PORT" then
    if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_get_link_port_t::smi_pid->pid_type(i="..i..")len="..length..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_get_link_port_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_get_link_port_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_get_link_port_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_get_link_port_t::smi_pid->port_id")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_get_link_port_t->ifindex")
		i = i+4
		local pdu_type = buffer(i,1):uint()
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->data_type(ETH(0),OSC(1),WSS(2),PRE(3),BST(4),CLK(5))")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->degree")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->side")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->iftype")
		i = i+1
		if (pdu_type == 1) then
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->osc_port.act")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->osc_port.shutdown")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->osc_port.dcc(DCC(1),2PLUS(2),PLUS(3)")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->osc_port.inband(AUTO(1),OSPF(2))")
			i = i+1
			subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_set_link_port_t->osc_port.peer_node")
			i = i+4
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->osc_port.peer_rack")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->osc_port.peer_slot")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->osc_port.peer_port")
			i = i+1
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_get_link_port_t->osc_port.distance")
			i = i+4
			subtree:add(buffer(i,63):string()):append_text(":smi_get_link_port_t->desc[63]")
			i = i+63
			subtree:add(buffer(i,13):string()):append_text(":smi_get_link_port_t->dummy[13]")
			i = i+13
		elseif (pdu_type == 2) then
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->wss_port.lambda")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->wss_port.add_port")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->wss_port.apc_mode(AUTO(1),MAN(2))")
			i = i+1
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_get_link_port_t->wss_port.attn")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_get_link_port_t->wss_port.out_pwr")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_get_link_port_t->wss_port.max")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_get_link_port_t->wss_port.min")
			i = i+4
			subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_get_link_port_t->wss_port.slice_from")
			i = i+2
			subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_get_link_port_t->wss_port.slice_to")
			i = i+2
			subtree:add(buffer(i,68):string()):append_text(":smi_get_link_port_t->dummy[68]")
			i = i+68
		elseif (pdu_type == 3 or pdu_type == 4) then
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->amp_port.amp_id(dummy)")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->amp_port.apc_mode(AUTO(1),MAN(2))")
			i = i+1
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_get_link_port_t->amp_port.attn")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_get_link_port_t->amp_port.max")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_get_link_port_t->amp_port.min")
			i = i+4
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->amp_port.amp_act")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->amp_port.tune")
			i = i+1
			subtree:add(buffer(i,75):string()):append_text(":smi_get_link_port_t->dummy[75]")
			i = i+75
		elseif (pdu_type == 5) then
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->ptp_port.act")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->ptp_port.oper")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->ptp_port.nego")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->ptp_port.dely")
			i = i+1
			subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_get_link_port_t->ptp_port.addr")
			i = i+4
			subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_get_link_port_t->ptp_port.mask")
			i = i+4
			subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_get_link_port_t->ptp_port.gate")
			i = i+4
			subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_get_link_port_t->ptp_port.speed(7777=40G,8888=100G,8080=200G)")
			i = i+2
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->ptp_port.duplex")
			i = i+1
			subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_get_link_port_t->ptp_port.vlan")
			i = i+2
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->ptp_port.cos")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->ptp_port.dly")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->ptp_port.net")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->ptp_port.utp_slot")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->ptp_port.utp_port")
			i = i+1
			subtree:add(buffer(i,65):string()):append_text(":smi_get_link_port_t->dummy[65]")
			i = i+65
		else
			subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_get_link_port_t->actype")
			i = i+4
			subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_get_link_port_t->prov_speed")
			i = i+2
			subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_get_link_port_t->status_speed")
			i = i+2
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->prov_duplex")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->status_duplex")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->prov_shutdown")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->status_shutdown")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->prov_auto_nego")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->prov_flow_control")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->prov_loopback")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->advertise")
			i = i+1
			subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_get_link_port_t->prov_media_ch")
			i = i+2
			subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_get_link_port_t->prov_jumbo")
			i = i+2
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->status_pause_tx")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->status_pause_rx")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->status_linkup")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->status_act")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->prov_llcf")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->fec_mode")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->combo_utp/form_factor")
			i = i+1
			subtree:add(buffer(i,64):string()):append_text(":smi_get_link_port_t->desc")
			i = i+64
		end
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->auto_nni")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->lag_id")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->module_type")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->wave_length")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_link_port_t->lambda_tunable")
		i = i+1
	end
  elseif fid_name == "UT_7400_FID_SET_LINK_PORT" or fid_name == "SET_LINK_PORT" then
    if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_set_link_port_t::smi_pid->pid_type(i="..i..")len="..length..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_set_link_port_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_set_link_port_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_set_link_port_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_set_link_port_t::smi_pid->port_id")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_set_link_port_t->result")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_set_link_port_t->ifindex")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_set_link_port_t->flags")
		i = i+4
		local pdu_type = buffer(i,1):uint()
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->pdu_type(ETH(0),OSC(1),WSS(2),PRE(3),BST(4),CLK(5))")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->degree")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->side")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->iftype")
		i = i+1
		if (pdu_type == 1) then
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->osc_port.act")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->osc_port.shutdown")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->osc_port.dcc_type(DCC(1),2PLUS(2),PLUS(3)")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->osc_port.inband(AUTO(1),OSPF(2))")
			i = i+1
			subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_set_link_port_t->osc_port.peer_node")
			i = i+4
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->osc_port.peer_rack")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->osc_port.peer_slot")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->osc_port.peer_port")
			i = i+1
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_set_link_port_t->osc_port.distance")
			i = i+4
			subtree:add(buffer(i,67):string()):append_text(":smi_set_link_port_t->osc_port.dummy")
			i = i+67
		elseif (pdu_type == 2) then
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->wss_port.act")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->wss_port.apc_mode(AUTO(1),MAN(2))")
			i = i+1
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_set_link_port_t->wss_port.output")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_set_link_port_t->wss_port.max")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_set_link_port_t->wss_port.min")
			i = i+4
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->wss_port.slice")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->wss_port.local_rack")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->wss_port.local_slot")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->wss_port.local_port")
			i = i+1
			subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_set_link_port_t->wss_port.peer_node")
			i = i+4
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->wss_port.peer_rack")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->wss_port.peer_slot")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->wss_port.peer_port")
			i = i+1
			subtree:add(buffer(i,57):string()):append_text(":smi_set_link_port_t->wss_port.dummy")
			i = i+57
		elseif (pdu_type == 3) then
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->amp_port.act")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->amp_port.edfa(AUTO(1),MAN(2))")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->amp_port.apc_mode(AUTO(1),MAN(2))")
			i = i+1
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_set_link_port_t->amp_port.gain")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_set_link_port_t->amp_port.max")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_set_link_port_t->amp_port.min")
			i = i+4
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->amp_port.local_rack")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->amp_port.local_slot")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->amp_port.local_port")
			i = i+1
			subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_set_link_port_t->amp_port.peer_node")
			i = i+4
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->amp_port.peer_rack")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->amp_port.peer_slot")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->amp_port.peer_port")
			i = i+1
			subtree:add(buffer(i,57):string()):append_text(":smi_set_link_port_t->amp_port.dummy")
			i = i+57
		elseif (pdu_type == 4) then
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->booster.act")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->booster.edfa(AUTO(1),MAN(2))")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->booster.apc_mode(AUTO(1),MAN(2))")
			i = i+1
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_set_link_port_t->booster.gain")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_set_link_port_t->booster.max")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_set_link_port_t->booster.min")
			i = i+4
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->booster.local_rack")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->booster.local_slot")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->booster.local_port")
			i = i+1
			subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_set_link_port_t->booster.peer_node")
			i = i+4
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->booster.peer_rack")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->booster.peer_slot")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->booster.peer_port")
			i = i+1
			subtree:add(buffer(i,57):string()):append_text(":smi_set_link_port_t->booster.dummy")
			i = i+57
		elseif (pdu_type == 5) then
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->ptp_port.act")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->ptp_port.oper")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->ptp_port.nego")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->ptp_port.dely")
			i = i+1
			subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_set_link_port_t->ptp_port.speed(7777=40G,8888=100G,8080=200G)")
			i = i+2
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->ptp_port.duplex")
			i = i+1
			subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_set_link_port_t->ptp_port.addr")
			i = i+4
			subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_set_link_port_t->ptp_port.mask")
			i = i+4
			subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_set_link_port_t->ptp_port.gate")
			i = i+4
			subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_set_link_port_t->ptp_port.vlan")
			i = i+2
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->ptp_port.cos")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->ptp_port.network")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->ptp_port.utp_slot")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->ptp_port.utp_port")
			i = i+1
			subtree:add(buffer(i,57):string()):append_text(":smi_set_link_port_t->ptp_port.dummy")
			i = i+57
		else
			subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_set_link_port_t->eth_port.actype")
			i = i+4
			subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_set_link_port_t->eth_port.speed")
			i = i+2
			subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_set_link_port_t->eth_port.media_ch")
			i = i+2
			subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_set_link_port_t->eth_port.mtu_size")
			i = i+2
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->eth_port.auto_nego")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->eth_port.duplex")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->eth_port.flow_control")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->eth_port.loopback")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->eth_port.shutdown")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->eth_port.act")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->eth_port.advertise")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->eth_port.llcf")
			i = i+1
			subtree:add(buffer(i,54):string()):append_text(":smi_set_link_port_t->eth_port.desc")
			i = i+54
			subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_set_link_port_t->eth_port.ip_address")
			i = i+4
			subtree:add(msg_mac, buffer(i,6)):append_text(":smi_set_link_port_t->eth_port.mac_addr")
			i = i+6
		end
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->is_active")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->auto_nni")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->combo/form_factor")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->fec_mode")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->wave_length")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_set_link_port_t->lambda_tunable")
		i = i+1
	end
  elseif fid_name == "SET_STM_INTERFACE" or fid_name == "GET_STM_INTERFACE" then
    if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_get_stm_port_t::smi_pid->pid_type(i="..i..")len="..length..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_get_stm_port_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_get_stm_port_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_get_stm_port_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_get_stm_port_t::smi_pid->port_id")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_get_stm_port_t->ifindex")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_get_stm_port_t->flag")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_stm_port_t->spif_type")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_stm_port_t->loopback")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_stm_port_t->shutdown")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_stm_port_t->adminAct")
		i = i+1
		subtree:add(msg_uint32, buffer(i,1)):append_text(":smi_get_stm_port_t->sdThres")
		i = i+1
		subtree:add(msg_uint32, buffer(i,1)):append_text(":smi_get_stm_port_t->sfThres")
		i = i+1
		subtree:add(buffer(i,16):string()):append_text(":smi_get_stm_port_t->j0MsgBuf")
		i = i+16
		subtree:add(msg_uint32, buffer(i,1)):append_text(":smi_get_stm_port_t->network")
		i = i+1
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_get_stm_port_t->sw_dir")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_stm_port_t->is_active")
		i = i+1
		subtree:add(buffer(i,64):string()):append_text(":smi_get_stm_port_t->desc")
		i = i+64
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_get_stm_port_t->llcf_delay")
		i = i+1
		subtree:add(buffer(i,11):string()):append_text(":smi_get_stm_port_t->dummy")
		i = i+11
	end
  elseif fid_name == "SYS_GET_LC_HW_VER" then
    if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_sys_hw_ver_t::smi_pid->pid_type(i="..i..")len="..length..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_sys_hw_ver_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_sys_hw_ver_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_sys_hw_ver_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_sys_hw_ver_t::smi_pid->port_id")
		i = i+2
		j = 0
		while(j<16) do
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_sys_hw_ver_t->smi_unit_hw_ver_t::slot_id")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_sys_hw_ver_t->smi_unit_hw_ver_t::not_installed")
			i = i+1
			subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_sys_hw_ver_t->smi_unit_hw_ver_t::card_type")
			i = i+4
			subtree:add(buffer(i,12):string()):append_text(":smi_sys_hw_ver_t->smi_unit_hw_ver_t::unit_ver")
			i = i+12
			subtree:add(buffer(i,12):string()):append_text(":smi_sys_hw_ver_t->smi_unit_hw_ver_t::fpga_ver")
			i = i+12
			subtree:add(buffer(i,16):string()):append_text(":smi_sys_hw_ver_t->smi_unit_hw_ver_t::hw_date")
			i = i+16
			subtree:add(buffer(i,8):string()):append_text(":smi_sys_hw_ver_t->smi_unit_hw_ver_t::cop_ver")
			i = i+8
			subtree:add(buffer(i,16):string()):append_text(":smi_sys_hw_ver_t->smi_unit_hw_ver_t::cop_date")
			i = i+16
			subtree:add(buffer(i,8):string()):append_text(":smi_sys_hw_ver_t->smi_unit_hw_ver_t::cop2_ver")
			i = i+8
			subtree:add(buffer(i,16):string()):append_text(":smi_sys_hw_ver_t->smi_unit_hw_ver_t::cop2_date")
			i = i+16
			j = j+1
		end
	end
  elseif fid_name == "CE_7200_FID_GET_MPLS_INTERFACE" or fid_name == "SMI_7400_FID_GET_MPLS_INTERFACE" then
    if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_interface_t::smi_pid->pid_type(i="..i..")len="..length..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_interface_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_interface_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_interface_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_interface_t::smi_pid->port_id")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_interface_t->ifindex")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_interface_t->flag")
		i = i+4
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_mpls_interface_t->result_addr")
		i = i+4
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_mpls_interface_t->peer_nodeId")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_interface_t->vid")
		i = i+2
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_interface_t->peer_slotId")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_interface_t->peer_portId")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_interface_t->is_tagged")
		i = i+1
		subtree:add(msg_mac, buffer(i,6)):append_text(":smi_mpls_interface_t->nhMac")
		i = i+6
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_interface_t->adminStatus")
		i = i+1
		subtree:add(buffer(i,49):string()):append_text(":smi_mpls_interface_t->names")
		i = i+49
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_interface_t->peer_shelfId")
		i = i+1
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_interface_t->all_bw")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_interface_t->use_bw")
		i = i+4
	end
	elseif fid_name == "SMI_U7400_FID_GET_PW_INTERFACE" or fid_name == "CE_7200_FID_GET_PW_INTERFACE" then
    if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t::smi_pid->pid_type(i="..i..")len="..length..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_pw_interface_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_pw_interface_t::smi_pid->port_id")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->pwidx")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->flags")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->result")
		i = i+4
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_pw_interface_t->peer_node_id")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->peer_ac_id")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->ac_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_pw_interface_t->vpn_id")
		i = i+2
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_pw_interface_t->flow_mode")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_pw_interface_t->control_word")
		i = i+1		
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.band")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_pw_interface_t->qos_info.tc")
		i = i+1
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.cos1.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.cos1.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.cos2.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.cos2.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.cos3.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.cos3.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.cos4.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.cos4.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.cos5.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.cos5.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.cos6.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.cos6.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.cos7.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.cos7.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.cos8.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->qos_info.cos8.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->edge_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->service_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->hop.inlabel")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->hop.out_label")
		i = i+4
		subtree:add(buffer(i,50):string()):append_text(":smi_pw_interface_t->hop.name")
		i = i+50
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->xcon_index")
		i = i+4
		subtree:add(buffer(i,14):string()):append_text(":smi_pw_interface_t->pwoam.megname")
		i = i+14
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_pw_interface_t::pwoam.mepid")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_pw_interface_t::pwoam.rmepid")
		i = i+2
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_pw_interface_t->pwoam.ccm")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_pw_interface_t->pwoam.enable")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_pw_interface_t->pwoam.meg_level")
		i = i+1
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pw_interface_t->pwoam.cc_exp")
		i = i+4
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_pw_interface_t->pwoam.peer_addr")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_pw_interface_t->pwoam.ais_relay")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_pw_interface_t->pwoam.csf_relay")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_pw_interface_t->pwoam.oam_active")
		i = i+1
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_pw_interface_t::pwoam.cvid")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_pw_interface_t::pwoam.svid")
		i = i+2
		subtree:add(buffer(i,127):string()):append_text(":smi_pw_interface_t->desc")
		i = i+127
	end
  elseif fid_name == "SET_SVC_REMARK_PROFILE" or fid_name == "GET_SVC_REMARK_PROFILE" then
    if (length <= i) then return end
    subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pid->pid_type(i="..i..")")
	i = i+4
	subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pid->ne_type")
	i = i+4
	subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_pid->card_id")
	i = i+4
	subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_pid->slot_id")
	i = i+2
	subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_pid->port_id")
	i = i+2
	subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_qos_remark_profile_t->flag")
	i = i+4
	subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_qos_remark_profile_t->direction")
	i = i+4
	subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_qos_remark_profile_t->profile_id")
	i = i+4
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.cos_ingress_map[0]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.cos_ingress_map[1]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.cos_ingress_map[2]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.cos_ingress_map[3]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.cos_ingress_map[4]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.cos_ingress_map[5]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.cos_ingress_map[6]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.cos_ingress_map[7]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.cos_egress_map[0]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.cos_egress_map[1]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.cos_egress_map[2]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.cos_egress_map[3]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.cos_egress_map[4]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.cos_egress_map[5]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.cos_egress_map[6]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.cos_egress_map[7]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.dscp_map[0]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.dscp_map[1]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.dscp_map[2]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.dscp_map[3]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.dscp_map[4]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.dscp_map[5]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.dscp_map[6]")
	i = i+1
	subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_qos_remark_profile_t->profile.dscp_map[7]")
	i = i+1
  elseif fid_name == "SMI_MSG_SYS_GET_TUNNEL_NOTE" or fid_name == "SMI_MSG_SYS_SET_TUNNEL_NOTE" then
  if (length <= i) then return end
	while (i < length) do
	    subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_note_t::smi_pid->pid_type(i="..i..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_note_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_note_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_note_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_note_t::smi_pid->port_id")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_note_t::smi_mpls_tunnel_idInfo_t->role")
		i = i+4
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_mpls_tunnel_note_t::smi_mpls_tunnel_idInfo_t->igr_node_id")
		i = i+4
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_mpls_tunnel_note_t::smi_mpls_tunnel_idInfo_t->egr_node_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_note_t::smi_mpls_tunnel_idInfo_t->igr_tunnel_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_note_t::smi_mpls_tunnel_idInfo_t->egr_tunnel_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_note_t::smi_mpls_tunnel_idInfo_t->assoticated_tunnel_id")
		i = i+2
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_note_t::smi_mpls_tunnel_idInfo_t->direction")
		i = i+1
		subtree:add(buffer(i,50):string()):append_text(":smi_mpls_tunnel_note_t::smi_mpls_tunnel_idInfo_t->names")
		i = i+50
		subtree:add(buffer(i,64):string()):append_text(":smi_mpls_tunnel_note_t::desc")
		i = i+64
	end
  elseif fid_name == "SMI_7400_FID_SET_MPLS_TUNNEL" or fid_name == "SMI_7400_FID_GET_MPLS_TUNNEL" or fid_name == "SMI_7400_FID_DEL_MPLS_TUNNEL" or
         fid_name == "CE_7200_FID_SET_MPLS_TUNNEL" or fid_name == "CE_7200_FID_GET_MPLS_TUNNEL" or fid_name == "CE_7200_FID_DEL_MPLS_TUNNEL" then
  if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t::smi_pid->pid_type(i="..i..")len="..length..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_t::smi_pid->port_id")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t::smi_mpls_tunnel_idInfo_t->role")
		i = i+4
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_mpls_tunnel_t::smi_mpls_tunnel_idInfo_t->igr_node_id")
		i = i+4
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_mpls_tunnel_t::smi_mpls_tunnel_idInfo_t->egr_node_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_t::smi_mpls_tunnel_idInfo_t->igr_tunnel_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_t::smi_mpls_tunnel_idInfo_t->egr_tunnel_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_t::smi_mpls_tunnel_idInfo_t->assoticated_tunnel_id")
		i = i+2
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_t::smi_mpls_tunnel_idInfo_t->direction")
		i = i+1
		subtree:add(buffer(i,50):string()):append_text(":smi_mpls_tunnel_t::smi_mpls_tunnel_idInfo_t->names")
		i = i+50
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.band")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.cos1.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.cos1.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.cos2.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.cos2.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.cos3.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.cos3.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.cos4.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.cos4.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.cos5.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.cos5.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.cos6.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.cos6.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.cos7.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.cos7.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.cos8.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->qos_info.cos8.eir")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_t->qos_info.tc")
		i = i+1
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->use_bw.cos1.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->use_bw.cos1.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->use_bw.cos2.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->use_bw.cos2.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->use_bw.cos3.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->use_bw.cos3.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->use_bw.cos4.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->use_bw.cos4.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->use_bw.cos5.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->use_bw.cos5.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->use_bw.cos6.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->use_bw.cos6.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->use_bw.cos7.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->use_bw.cos7.eir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->use_bw.cos8.cir")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t->use_bw.cos8.eir")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_t->mpls_prot.mode")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_t->mpls_prot.revertive")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_t->mpls_prot.is_use_aps")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_t->mpls_prot.dir_is_bi")
		i = i+1
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_t->mpls_prot.wtr_time")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_t->mpls_prot.wtr_left")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_t->mpls_prot.hold_off")
		i = i+2
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_t->active_path")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_t->sw_state")
		i = i+1
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_t::flags[0=CREATE,1=QOS,2=ASSO,3=NAME,4=PROT,5=WTR,6=HOLD,7=STACK]->"..tobits(buffer(i,4):uint()))
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_t->outer")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_t->cir_only")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_t->copper")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_t->result")
		i = i+1
	end
  elseif 
    fid_name == "CE_7200_FID_SET_MPLS_TUNNEL_LSP" or fid_name == "CE_7200_FID_GET_MPLS_TUNNEL_LSP" or fid_name == "CE_7200_FID_DEL_MPLS_TUNNEL_LSP" or
	fid_name == "SMI_7400_FID_SET_MPLS_TUNNEL_LSP" or fid_name == "SMI_7400_FID_GET_MPLS_TUNNEL_LSP" or  fid_name == "SMI_7400_FID_DEL_MPLS_TUNNEL_LSP" then
  if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_lsp_t::smi_pid->pid_type(i="..i..")len="..length..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_lsp_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_lsp_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_lsp_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_lsp_t::smi_pid->port_id")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_lsp_t::smi_mpls_tunnel_idInfo_t->role")
		i = i+4
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_mpls_tunnel_lsp_t::smi_mpls_tunnel_idInfo_t->igr_node_id")
		i = i+4
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_mpls_tunnel_lsp_t::smi_mpls_tunnel_idInfo_t->egr_node_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_lsp_t::smi_mpls_tunnel_idInfo_t->igr_tunnel_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_lsp_t::smi_mpls_tunnel_idInfo_t->egr_tunnel_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_lsp_t::smi_mpls_tunnel_idInfo_t->assoticated_tunnel_id")
		i = i+2
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t::smi_mpls_tunnel_idInfo_t->direction")
		i = i+1
		subtree:add(buffer(i,50):string()):append_text(":smi_mpls_tunnel_lsp_t::smi_mpls_tunnel_idInfo_t->names")
		i = i+50
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_lsp_t::tunnel_w_lspInfo->in_label")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_lsp_t::tunnel_w_lspInfo->out_label")
		i = i+4
		subtree:add(buffer(i,50):string()):append_text(":smi_mpls_tunnel_lsp_t::tunnel_w_lspInfo->->link")
		i = i+50
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_lsp_t::tunnel_p_lspInfo->in_label")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_lsp_t::tunnel_p_lspInfo->out_label")
		i = i+4
		subtree:add(buffer(i,50):string()):append_text(":smi_mpls_tunnel_lsp_t::tunnel_p_lspInfo->link")
		i = i+50
		subtree:add(buffer(i,13):string()):append_text(":smi_mpls_tunnel_lsp_t::w_lsp_oam_info::->meg_name")
		i = i+13
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_lsp_t::w_lsp_oam_info::->mep_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_lsp_t::w_lsp_oam_info::smi_mep_info_t->remp_id")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_lsp_t::w_lsp_oam_info->smi_ccm_type_t::ccm_interval")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t::w_lsp_oam_info->smi_ccm_type_t::enable")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t::w_lsp_oam_info->smi_ccm_type_t::lm_enable")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t::w_lsp_oam_info->cc_status")
		i = i+1
		subtree:add(buffer(i,13):string()):append_text(":smi_mpls_tunnel_lsp_t::p_lsp_oam_info::->meg_name")
		i = i+13
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_lsp_t::p_lsp_oam_info::->mep_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_mpls_tunnel_lsp_t::p_lsp_oam_info::smi_mep_info_t->remp_id")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_lsp_t::p_lsp_oam_info->smi_ccm_type_t::ccm_interval")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t::p_lsp_oam_info->smi_ccm_type_t::enable")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t::p_lsp_oam_info->smi_ccm_type_t::lm_enable")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t::p_lsp_oam_info->cc_status")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t->smi_oam_lck_ais_tx_t::lock_tx_enable")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t->smi_oam_lck_ais_tx_t::ais_tx_enable")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t->smi_oam_lck_ais_tx_t::lck_ais_interval")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t->smi_oam_lck_ais_rx_t::lck_ais_w_rx_enable")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t->smi_oam_lck_ais_rx_t::lck_ais_w_rx_interval")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t->smi_oam_lck_ais_rx_t::lck_ais_p_rx_enable")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t->smi_oam_lck_ais_rx_t::lck_ais_p_rx_interval")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t->smi_oam_csf_t::csf_enable")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t->smi_oam_csf_t::csf_interval")
		i = i+1
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_mpls_tunnel_lsp_t->flags")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t->outer")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t->bfd_type")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t->bfd_ping")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t->result")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_mpls_tunnel_lsp_t->is_wp")
		i = i+1
	end
  elseif fid_name == "CMD_ON_DEMAND_OAM" or fid_name == "RESULT_ON_DEMAND_OAM" then
  if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_on_demand_oam_cmd_t::smi_pid->pid_type(i="..i..")len="..length..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_on_demand_oam_cmd_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_on_demand_oam_cmd_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_on_demand_oam_cmd_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_on_demand_oam_cmd_t::smi_pid->port_id")
		i = i+2
		subtree:add(buffer(i,13):string()):append_text(":smi_on_demand_oam_cmd_t::smi_mep_info_t->meg_name")
		i = i+13
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_on_demand_oam_cmd_t::smi_mep_info_t->mep_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_on_demand_oam_cmd_t::smi_mep_info_t->rmep_id")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_on_demand_oam_cmd_t::command")
		i = i+4

		subtree:add(msg_uint32,  buffer(i    ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param1::smi_oam_lb_result_t->transaction_id")
		subtree:add(msg_uint32,  buffer(i+4  ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param1::smi_oam_lb_result_t->result")
		subtree:add(msg_uint32,  buffer(i+8  ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param1::smi_oam_lb_result_t->tx_cnt")
		subtree:add(msg_uint32,  buffer(i+12 ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param1::smi_oam_lb_result_t->rx_cnt")
		subtree:add(msg_dst_add, buffer(i+16 ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param1::smi_oam_lb_result_t->rmip_ip")
		
		subtree:add(msg_uint32,  buffer(i    ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param2::smi_oam_pw_lb_result_t->transaction_id")
		subtree:add(msg_uint32,  buffer(i+4  ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param2::smi_oam_pw_lb_result_t->result")
		subtree:add(msg_uint32,  buffer(i+8  ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param2::smi_oam_pw_lb_result_t->tx_cnt")
		subtree:add(msg_uint32,  buffer(i+12 ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param2::smi_oam_pw_lb_result_t->rx_cnt")
		subtree:add(msg_dst_add, buffer(i+16 ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param2::smi_oam_pw_lb_result_t->rmip_ip")
		subtree:add(msg_uint32,  buffer(i+20 ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param2::smi_oam_pw_lb_result_t->recv_edge")
		
		subtree:add(msg_uint32,  buffer(i    ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param3::smi_oam_lm_result_t->transaction_id")
		subtree:add(msg_uint32,  buffer(i+4  ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param3::smi_oam_lm_result_t->result")
		subtree:add(msg_uint32,  buffer(i+8  ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param3::smi_oam_lm_result_t->tx_cnt")
		subtree:add(msg_uint32,  buffer(i+12 ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param3::smi_oam_lm_result_t->rx_cnt")
		subtree:add(msg_dst_add, buffer(i+16 ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param3::smi_oam_lm_result_t->rmip_ip")
		subtree:add(msg_uint32,  buffer(i+20 ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param3::smi_oam_lm_result_t->recv_edge")
		
		subtree:add(msg_uint32,  buffer(i    ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param4::smi_oam_dm_result_t->transaction_id")
		subtree:add(msg_uint32,  buffer(i+4  ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param4::smi_oam_dm_result_t->result")
		subtree:add(msg_uint32,  buffer(i+8  ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param4::smi_oam_dm_result_t->dmm_delay")
		subtree:add(msg_uint32,  buffer(i+12 ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param4::smi_oam_dm_result_t->tx_cnt")
		subtree:add(msg_uint32,  buffer(i+16 ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param4::smi_oam_dm_result_t->rx_cnt")
		subtree:add(msg_uint32,  buffer(i+20 ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param4::smi_oam_dm_result_t->delay_variation")

		subtree:add(msg_uint32,  buffer(i    ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->transaction_id")
		subtree:add(msg_uint32,  buffer(i+4  ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->result")
		subtree:add(msg_uint32,  buffer(i+8  ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->seq_no_err")
		subtree:add(msg_uint32,  buffer(i+12 ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->crc_err")
		subtree:add(msg_uint32,  buffer(i+16 ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->rx_length")
		subtree:add(msg_uint32,  buffer(i+20 ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->rx_bit_error")
		subtree:add(msg_uint08,  buffer(i+21 ,1)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->seq_no_err")
		subtree:add(msg_uint08,  buffer(i+22 ,1)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->crc_err")
		subtree:add(msg_uint08,  buffer(i+23 ,1)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->rx_length")
		subtree:add(msg_uint08,  buffer(i+24 ,1)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->rx_bit_error")
		subtree:add(msg_uint32,  buffer(i+25 ,4)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->frame_rx_count")
		subtree:add(msg_uint16,  buffer(i+29 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type01")
		subtree:add(msg_uint16,  buffer(i+31 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type02")
		subtree:add(msg_uint16,  buffer(i+33 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type03")
		subtree:add(msg_uint16,  buffer(i+35 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type04")
		subtree:add(msg_uint16,  buffer(i+37 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type05")
		subtree:add(msg_uint16,  buffer(i+39 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type06")
		subtree:add(msg_uint16,  buffer(i+41 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type07")
		subtree:add(msg_uint16,  buffer(i+43 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type08")
		subtree:add(msg_uint16,  buffer(i+45 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type09")
		subtree:add(msg_uint16,  buffer(i+47 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type10")
		subtree:add(msg_uint16,  buffer(i+49 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type11")
		subtree:add(msg_uint16,  buffer(i+51 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type12")
		subtree:add(msg_uint16,  buffer(i+53 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type13")
		subtree:add(msg_uint16,  buffer(i+55 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type14")
		subtree:add(msg_uint16,  buffer(i+57 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type15")
		subtree:add(msg_uint16,  buffer(i+59 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type16")
		subtree:add(msg_uint16,  buffer(i+61 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type17")
		subtree:add(msg_uint16,  buffer(i+63 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type18")
		subtree:add(msg_uint16,  buffer(i+65 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type19")
		subtree:add(msg_uint16,  buffer(i+67 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type20")
		subtree:add(msg_uint16,  buffer(i+69 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type21")
		subtree:add(msg_uint16,  buffer(i+71 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type22")
		subtree:add(msg_uint16,  buffer(i+73 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type23")
		subtree:add(msg_uint16,  buffer(i+75 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type24")
		subtree:add(msg_uint16,  buffer(i+77 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type25")
		subtree:add(msg_uint16,  buffer(i+79 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type26")
		subtree:add(msg_uint16,  buffer(i+81 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type27")
		subtree:add(msg_uint16,  buffer(i+83 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type28")
		subtree:add(msg_uint16,  buffer(i+85 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type29")
		subtree:add(msg_uint16,  buffer(i+87 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type30")
		subtree:add(msg_uint16,  buffer(i+89 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type31")
		subtree:add(msg_uint16,  buffer(i+91 ,2)):append_text(":smi_on_demand_oam_cmd_t::union_param5::smi_oam_tst_rx_result_t->receive_type32")
		
		i = i+4
		i = i+4

		i = i+4
		i = i+4
		i = i+4
		i = i+4

		i = i+1
		i = i+1
		i = i+1
		i = i+1

		i = i+4
		
		i = i+2
		i = i+2
		i = i+2
		i = i+2
		i = i+2
		i = i+2
		i = i+2
		i = i+2

		i = i+2
		i = i+2
		i = i+2
		i = i+2
		i = i+2
		i = i+2
		i = i+2
		i = i+2

		i = i+2
		i = i+2
		i = i+2
		i = i+2
		i = i+2
		i = i+2
		i = i+2
		i = i+2

		i = i+2
		i = i+2
		i = i+2
		i = i+2
		i = i+2
		i = i+2
		i = i+2
		i = i+2
	end	
  elseif fid_name == "SMI_EVENT_SYS_MSG_SWITCH" then
    if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_sw_msg_t::smi_pid->pid_type(i="..i..")len="..length..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_sw_msg_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_sw_msg_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_sw_msg_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_sw_msg_t::smi_pid->port_id")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_sw_msg_t->sw_cmd")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_sw_msg_t->msg_type")
		i = i+1
		
		subtree:add(msg_uint08, buffer(i+0,1)):append_text(":smi_sw_msg_t->union1.papa.from")
		subtree:add(msg_uint08, buffer(i+1,1)):append_text(":smi_sw_msg_t->union1.papa.to")

		subtree:add(msg_uint08, buffer(i+0,1)):append_text(":smi_sw_msg_t->union2.slot_port.type")
		subtree:add(msg_uint08, buffer(i+1,1)):append_text(":smi_sw_msg_t->union2.slot_port.from_slot")
		subtree:add(msg_uint08, buffer(i+2,1)):append_text(":smi_sw_msg_t->union2.slot_port.from_slot_type")
		subtree:add(msg_uint08, buffer(i+3,1)):append_text(":smi_sw_msg_t->union2.slot_port.from_port")
		subtree:add(msg_uint08, buffer(i+4,1)):append_text(":smi_sw_msg_t->union2.slot_port.to_slot")
		subtree:add(msg_uint08, buffer(i+5,1)):append_text(":smi_sw_msg_t->union2.slot_port.to_port")
		
		subtree:add(msg_uint32, buffer(i+0,4)):append_text(":smi_sw_msg_t->union3.tunnel.role")
		subtree:add(msg_dst_add, buffer(i+4,4)):append_text(":smi_sw_msg_t->union3.tunnel.igr_node_id")
		subtree:add(msg_dst_add, buffer(i+8,4)):append_text(":smi_sw_msg_t->union3.tunnel.egr_node_id")
		subtree:add(msg_uint16, buffer(i+12,2)):append_text(":smi_sw_msg_t->union3.tunnel.igr_tunnel_id")
		subtree:add(msg_uint16, buffer(i+14,2)):append_text(":smi_sw_msg_t->union3.tunnel.egr_tunnel_id")
		subtree:add(msg_uint16, buffer(i+16,2)):append_text(":smi_sw_msg_t->union3.tunnel.assciate_id")
		subtree:add(msg_uint08, buffer(i+18,1)):append_text(":smi_sw_msg_t->union3.tunnel.is_uni")
		subtree:add(buffer(i+19,50):string()):append_text(":smi_sw_msg_t->union3.tunnel.name")
		subtree:add(msg_uint08, buffer(i+69,1)):append_text(":smi_sw_msg_t->union3.is_remote")
		subtree:add(msg_uint08, buffer(i+70,1)):append_text(":smi_sw_msg_t->union3.from_lsp")
		subtree:add(msg_uint08, buffer(i+71,1)):append_text(":smi_sw_msg_t->union3.to_lsp")
		subtree:add(msg_uint08, buffer(i+72,1)):append_text(":smi_sw_msg_t->union3.from_lsp_type")
		subtree:add(msg_uint08, buffer(i+73,1)):append_text(":smi_sw_msg_t->union3.to_lsp_type")
		subtree:add(msg_uint32, buffer(i+74,4)):append_text(":smi_sw_msg_t->union3.from_index")
		subtree:add(msg_uint32, buffer(i+78,4)):append_text(":smi_sw_msg_t->union3.to_index")
		subtree:add(buffer(i+82,50):string()):append_text(":smi_sw_msg_t->union3.from_name")
		subtree:add(buffer(i+132,50):string()):append_text(":smi_sw_msg_t->union3.to_name")

		subtree:add(msg_uint08, buffer(i+0,1)):append_text(":smi_sw_msg_t->union4.clock_mode")
		subtree:add(msg_uint08, buffer(i+1,1)):append_text(":smi_sw_msg_t->union4.clock_mode.from_src")
		subtree:add(msg_uint08, buffer(i+2,1)):append_text(":smi_sw_msg_t->union4.clock_mode.to_src")
		subtree:add(msg_uint32, buffer(i+3,4)):append_text(":smi_sw_msg_t->union4.clock_mode.from_index")
		subtree:add(msg_uint32, buffer(i+7,4)):append_text(":smi_sw_msg_t->union4.clock_mode.to_index")
		
		subtree:add(msg_uint08, buffer(i+0,1)):append_text(":smi_sw_msg_t->union5.clk_module.from_module")
		subtree:add(msg_uint08, buffer(i+1,1)):append_text(":smi_sw_msg_t->union5.clk_module.to_module")

		subtree:add(msg_uint08, buffer(i+0,1)):append_text(":smi_sw_msg_t->union6.clk_module.from_mode")
		subtree:add(msg_uint08, buffer(i+1,1)):append_text(":smi_sw_msg_t->union6.clk_module.to_mode")
		
		subtree:add(msg_uint32, buffer(i+0,4)):append_text(":smi_sw_msg_t->union7.ar_prg.prg_id")
		subtree:add(buffer(i+4,33):string()):append_text(":smi_sw_msg_t->union7.prg.name")
		subtree:add(msg_uint32, buffer(i+37,4)):append_text(":smi_sw_msg_t->union7.prg.state")		
		subtree:add(msg_uint08, buffer(i+41,1)):append_text(":smi_sw_msg_t->union7.prg.from_slot")
		subtree:add(msg_uint08, buffer(i+42,1)):append_text(":smi_sw_msg_t->union7.prg.from_port")
		subtree:add(msg_uint08, buffer(i+43,1)):append_text(":smi_sw_msg_t->union7.prg.to_slot")
		subtree:add(msg_uint08, buffer(i+44,1)):append_text(":smi_sw_msg_t->union7.prg.to_port")

		subtree:add(buffer(i+0,31):string()):append_text(":smi_sw_msg_t->union8.svc.name")
		subtree:add(msg_uint08, buffer(i+32,1)):append_text(":smi_sw_msg_t->union8.svc.remote")
		subtree:add(msg_uint32, buffer(i+33,4)):append_text(":smi_sw_msg_t->union8.svc.reason")
		subtree:add(msg_uint08, buffer(i+34,1)):append_text(":smi_sw_msg_t->union8.svc.from")
		subtree:add(msg_uint08, buffer(i+35,1)):append_text(":smi_sw_msg_t->union8.svc.to")
		subtree:add(msg_uint16, buffer(i+36,2)):append_text(":smi_sw_msg_t->union8.svc.ac_id")

		subtree:add(msg_uint32, buffer(i+0 ,4)):append_text(":smi_sw_msg_t->union9.odu.smi_pid->pid_type")
		subtree:add(msg_uint32, buffer(i+4 ,4)):append_text(":smi_sw_msg_t->union9.odu.smi_pid->ne_type")
		subtree:add(msg_uint32, buffer(i+8 ,4)):append_text(":smi_sw_msg_t->union9.odu.smi_pid->card_id")
		subtree:add(msg_uint16, buffer(i+12,2)):append_text(":smi_sw_msg_t->union9.odu.smi_pid->slot_id")
		subtree:add(msg_uint16, buffer(i+14,2)):append_text(":smi_sw_msg_t->union9.odu.smi_pid->port_id")
		subtree:add(msg_uint16, buffer(i+16,2)):append_text(":smi_sw_msg_t->union9.odu.trail_id")
		subtree:add(msg_dst_add, buffer(i+20,4)):append_text(":smi_sw_msg_t->union9.odu.lsr_id")
		subtree:add(buffer(i+24,20):string()):append_text(":smi_sw_msg_t->union9.odu.name")
		subtree:add(buffer(i+44,12):string()):append_text(":smi_sw_msg_t->union9.odu.desc")

		i = i+182
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_sw_msg_t->reason")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_sw_msg_t->e_time")
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_sw_msg_t::e_time(i="..i..")len="..length..")")
		i = i+4
	end
  elseif fid_name == "SMI_EVENT_SYS_MSG_EVENT" then
    if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_evt_msg_t::smi_pid->pid_type(i="..i..")len="..length..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_evt_msg_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_evt_msg_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_evt_msg_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_evt_msg_t::smi_pid->port_id")
		i = i+2
--		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_evt_msg_t->sw_cmd")
--		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_evt_msg_t->msg_type")
		local pdu_type = buffer(i,1):uint()
		i = i+1
		if (pdu_type == 11) then
			subtree:add(msg_uint08, buffer(i+ 0,1)):append_text(":smi_evt_msg_t->evt_data.smi_bw_overbooked_t.if_type")
			subtree:add(msg_uint32, buffer(i+ 1,4)):append_text(":smi_evt_msg_t->evt_data.smi_bw_overbooked_t.u.smi_mif_info_t.if_index")
			subtree:add(buffer(5+i,52):string()):   append_text(":smi_evt_msg_t->evt_data.smi_bw_overbooked_t.u.smi_mif_info_t.name")
			subtree:add(msg_uint16, buffer(i+57,2)):append_text(":smi_evt_msg_t->evt_data.smi_bw_overbooked_t.u.smi_mif_info_t.slot_id")
			subtree:add(msg_uint16, buffer(i+59,2)):append_text(":smi_evt_msg_t->evt_data.smi_bw_overbooked_t.u.smi_mif_info_t.port_id")

			
			subtree:add(msg_uint32, buffer(i+ 1,4)):append_text(":smi_evt_msg_t->evt_data.smi_bw_overbooked_t.u.smi_alarm_pid_eth_t.tunnel_addr.index")
			subtree:add(msg_uint32, buffer(i+ 5,4)):append_text(":smi_evt_msg_t->evt_data.smi_bw_overbooked_t.u.smi_alarm_pid_eth_t.tunnel_addr.instance")

			subtree:add(msg_uint32, buffer(i+ 9,4)):append_text(":smi_evt_msg_t->evt_data.smi_bw_overbooked_t.u.smi_alarm_pid_eth_t.lsr_id")
			subtree:add(msg_uint32, buffer(i+13,4)):append_text(":smi_evt_msg_t->evt_data.smi_bw_overbooked_t.u.smi_alarm_pid_eth_t.s_index")
			subtree:add(msg_uint32, buffer(i+17,4)):append_text(":smi_evt_msg_t->evt_data.smi_bw_overbooked_t.u.smi_alarm_pid_eth_t.s_instance")
			subtree:add(msg_uint32, buffer(i+21,4)):append_text(":smi_evt_msg_t->evt_data.smi_bw_overbooked_t.u.smi_alarm_pid_eth_t.si_lsrid")
			subtree:add(buffer(25+i,50):string()):   append_text(":smi_evt_msg_t->evt_data.smi_bw_overbooked_t.u.smi_alarm_pid_eth_t.tname")
			
			subtree:add(msg_uint08, buffer(i+75,1)):append_text(":smi_evt_msg_t->evt_data.smi_bw_overbooked_t.bw_type")
			subtree:add(msg_uint32, buffer(i+76,4)):append_text(":smi_evt_msg_t->evt_data.smi_bw_overbooked_t.cir_use_bw")
			subtree:add(msg_uint32, buffer(i+80,4)):append_text(":smi_evt_msg_t->evt_data.smi_bw_overbooked_t.cir_all_bw")
			subtree:add(msg_uint32, buffer(i+84,4)):append_text(":smi_evt_msg_t->evt_data.smi_bw_overbooked_t.use_pir_bw")
			subtree:add(msg_uint32, buffer(i+88,4)):append_text(":smi_evt_msg_t->evt_data.smi_bw_overbooked_t.all_pir_bw")
		elseif (pdu_type == 25) then
			subtree:add(msg_uint08, buffer(i+ 0,1)):append_text(":smi_evt_msg_t->evt_data.battery.test_starta(1=START,2=END)")
			subtree:add(msg_uint08, buffer(i+ 1,1)):append_text(":smi_evt_msg_t->evt_data.battery.test_startb(1=START,2=END)")
			subtree:add(msg_uint08, buffer(i+ 2,1)):append_text(":smi_evt_msg_t->evt_data.battery.test_startc(1=START,2=END)")
			subtree:add(msg_uint08, buffer(i+ 3,1)):append_text(":smi_evt_msg_t->evt_data.battery.test_startd(1=START,2=END)")
			subtree:add(msg_uint08, buffer(i+ 4,1)):append_text(":smi_evt_msg_t->evt_data.battery.test_waya(1=MAN,2=AUTO)")
			subtree:add(msg_uint08, buffer(i+ 5,1)):append_text(":smi_evt_msg_t->evt_data.battery.test_wayb(1=MAN,2=AUTO)")
			subtree:add(msg_uint08, buffer(i+ 6,1)):append_text(":smi_evt_msg_t->evt_data.battery.test_wayc(1=MAN,2=AUTO)")
			subtree:add(msg_uint08, buffer(i+ 7,1)):append_text(":smi_evt_msg_t->evt_data.battery.test_wayd(1=MAN,2=AUTO)")
			subtree:add(msg_uint32, buffer(i+ 8,4):float()):append_text(":smi_evt_msg_t->evt_data.battery.cell1_4")
			subtree:add(msg_uint32, buffer(i+12,4):float()):append_text(":smi_evt_msg_t->evt_data.battery.cell1_7")
			subtree:add(msg_uint32, buffer(i+16,4):float()):append_text(":smi_evt_msg_t->evt_data.battery.cell1_10")
			subtree:add(msg_uint32, buffer(i+20,4):float()):append_text(":smi_evt_msg_t->evt_data.battery.cell2_4")
			subtree:add(msg_uint32, buffer(i+24,4):float()):append_text(":smi_evt_msg_t->evt_data.battery.cell2_7")
			subtree:add(msg_uint32, buffer(i+28,4):float()):append_text(":smi_evt_msg_t->evt_data.battery.cell2_10")
			subtree:add(msg_uint32, buffer(i+32,4):float()):append_text(":smi_evt_msg_t->evt_data.battery.cell3_4")
			subtree:add(msg_uint32, buffer(i+36,4):float()):append_text(":smi_evt_msg_t->evt_data.battery.cell3_7")
			subtree:add(msg_uint32, buffer(i+40,4):float()):append_text(":smi_evt_msg_t->evt_data.battery.cell3_10")
			subtree:add(msg_uint32, buffer(i+44,4):float()):append_text(":smi_evt_msg_t->evt_data.battery.cell4_4")
			subtree:add(msg_uint32, buffer(i+48,4):float()):append_text(":smi_evt_msg_t->evt_data.battery.cell4_7")
			subtree:add(msg_uint32, buffer(i+52,4):float()):append_text(":smi_evt_msg_t->evt_data.battery.cell4_10")
		end
	-- 	subtree:add(msg_uint08, buffer(i+0,1)):append_text(":smi_evt_msg_t->union1.papa.from")
	-- 	subtree:add(msg_uint08, buffer(i+1,1)):append_text(":smi_evt_msg_t->union1.papa.to")
	-- 
	-- 	subtree:add(msg_uint08, buffer(i+0,1)):append_text(":smi_evt_msg_t->union2.slot_port.type")
	-- 	subtree:add(msg_uint08, buffer(i+1,1)):append_text(":smi_evt_msg_t->union2.slot_port.from_slot")
	-- 	subtree:add(msg_uint08, buffer(i+2,1)):append_text(":smi_evt_msg_t->union2.slot_port.from_slot_type")
	-- 	subtree:add(msg_uint08, buffer(i+3,1)):append_text(":smi_evt_msg_t->union2.slot_port.from_port")
	-- 	subtree:add(msg_uint08, buffer(i+4,1)):append_text(":smi_evt_msg_t->union2.slot_port.to_slot")
	-- 	subtree:add(msg_uint08, buffer(i+5,1)):append_text(":smi_evt_msg_t->union2.slot_port.to_port")
	-- 	
	-- 	subtree:add(msg_uint32, buffer(i+0,4)):append_text(":smi_evt_msg_t->union3.tunnel.role")
	-- 	subtree:add(msg_dst_add, buffer(i+4,4)):append_text(":smi_evt_msg_t->union3.tunnel.igr_node_id")
	-- 	subtree:add(msg_dst_add, buffer(i+8,4)):append_text(":smi_evt_msg_t->union3.tunnel.egr_node_id")
	-- 	subtree:add(msg_uint16, buffer(i+12,2)):append_text(":smi_evt_msg_t->union3.tunnel.igr_tunnel_id")
	-- 	subtree:add(msg_uint16, buffer(i+14,2)):append_text(":smi_evt_msg_t->union3.tunnel.egr_tunnel_id")
	-- 	subtree:add(msg_uint16, buffer(i+16,2)):append_text(":smi_evt_msg_t->union3.tunnel.assciate_id")
	-- 	subtree:add(msg_uint08, buffer(i+18,1)):append_text(":smi_evt_msg_t->union3.tunnel.is_uni")
	-- 	subtree:add(buffer(i+19,50):string()):append_text(":smi_evt_msg_t->union3.tunnel.name")
	-- 	subtree:add(msg_uint08, buffer(i+69,1)):append_text(":smi_evt_msg_t->union3.is_remote")
	-- 	subtree:add(msg_uint08, buffer(i+70,1)):append_text(":smi_evt_msg_t->union3.from_lsp")
	-- 	subtree:add(msg_uint08, buffer(i+71,1)):append_text(":smi_evt_msg_t->union3.to_lsp")
	-- 	subtree:add(msg_uint08, buffer(i+72,1)):append_text(":smi_evt_msg_t->union3.from_lsp_type")
	-- 	subtree:add(msg_uint08, buffer(i+73,1)):append_text(":smi_evt_msg_t->union3.to_lsp_type")
	-- 	subtree:add(msg_uint32, buffer(i+74,4)):append_text(":smi_evt_msg_t->union3.from_index")
	-- 	subtree:add(msg_uint32, buffer(i+78,4)):append_text(":smi_evt_msg_t->union3.to_index")
	-- 	subtree:add(buffer(i+82,50):string()):append_text(":smi_evt_msg_t->union3.from_name")
	-- 	subtree:add(buffer(i+132,50):string()):append_text(":smi_evt_msg_t->union3.to_name")
	-- 
	-- 	subtree:add(msg_uint08, buffer(i+0,1)):append_text(":smi_evt_msg_t->union4.clock_mode")
	-- 	subtree:add(msg_uint08, buffer(i+1,1)):append_text(":smi_evt_msg_t->union4.clock_mode.from_src")
	-- 	subtree:add(msg_uint08, buffer(i+2,1)):append_text(":smi_evt_msg_t->union4.clock_mode.to_src")
	-- 	subtree:add(msg_uint32, buffer(i+3,4)):append_text(":smi_evt_msg_t->union4.clock_mode.from_index")
	-- 	subtree:add(msg_uint32, buffer(i+7,4)):append_text(":smi_evt_msg_t->union4.clock_mode.to_index")
	-- 	
	-- 	subtree:add(msg_uint08, buffer(i+0,1)):append_text(":smi_evt_msg_t->union5.clk_module.from_module")
	-- 	subtree:add(msg_uint08, buffer(i+1,1)):append_text(":smi_evt_msg_t->union5.clk_module.to_module")
	-- 
	-- 	subtree:add(msg_uint08, buffer(i+0,1)):append_text(":smi_evt_msg_t->union6.clk_module.from_mode")
	-- 	subtree:add(msg_uint08, buffer(i+1,1)):append_text(":smi_evt_msg_t->union6.clk_module.to_mode")
	-- 	
	-- 	subtree:add(msg_uint32, buffer(i+0,4)):append_text(":smi_evt_msg_t->union7.ar_prg.prg_id")
	-- 	subtree:add(buffer(i+4,33):string()):append_text(":smi_evt_msg_t->union7.prg.name")
	-- 	subtree:add(msg_uint32, buffer(i+37,4)):append_text(":smi_evt_msg_t->union7.prg.state")		
	-- 	subtree:add(msg_uint08, buffer(i+41,1)):append_text(":smi_evt_msg_t->union7.prg.from_slot")
	-- 	subtree:add(msg_uint08, buffer(i+42,1)):append_text(":smi_evt_msg_t->union7.prg.from_port")
	-- 	subtree:add(msg_uint08, buffer(i+43,1)):append_text(":smi_evt_msg_t->union7.prg.to_slot")
	-- 	subtree:add(msg_uint08, buffer(i+44,1)):append_text(":smi_evt_msg_t->union7.prg.to_port")
	-- 
	-- 	subtree:add(buffer(i+0,31):string()):append_text(":smi_evt_msg_t->union8.svc.name")
	-- 	subtree:add(msg_uint08, buffer(i+32,1)):append_text(":smi_evt_msg_t->union8.svc.remote")
	-- 	subtree:add(msg_uint32, buffer(i+33,4)):append_text(":smi_evt_msg_t->union8.svc.reason")
	-- 	subtree:add(msg_uint08, buffer(i+34,1)):append_text(":smi_evt_msg_t->union8.svc.from")
	-- 	subtree:add(msg_uint08, buffer(i+35,1)):append_text(":smi_evt_msg_t->union8.svc.to")
	-- 	subtree:add(msg_uint16, buffer(i+36,2)):append_text(":smi_evt_msg_t->union8.svc.ac_id")
	-- 
	-- 	subtree:add(msg_uint32, buffer(i+0 ,4)):append_text(":smi_evt_msg_t->union9.odu.smi_pid->pid_type")
	-- 	subtree:add(msg_uint32, buffer(i+4 ,4)):append_text(":smi_evt_msg_t->union9.odu.smi_pid->ne_type")
	-- 	subtree:add(msg_uint32, buffer(i+8 ,4)):append_text(":smi_evt_msg_t->union9.odu.smi_pid->card_id")
	-- 	subtree:add(msg_uint16, buffer(i+12,2)):append_text(":smi_evt_msg_t->union9.odu.smi_pid->slot_id")
	-- 	subtree:add(msg_uint16, buffer(i+14,2)):append_text(":smi_evt_msg_t->union9.odu.smi_pid->port_id")
	-- 	subtree:add(msg_uint16, buffer(i+16,2)):append_text(":smi_evt_msg_t->union9.odu.trail_id")
	-- 	subtree:add(msg_dst_add, buffer(i+20,4)):append_text(":smi_evt_msg_t->union9.odu.lsr_id")
	-- 	subtree:add(buffer(i+24,20):string()):append_text(":smi_evt_msg_t->union9.odu.name")
	-- 	subtree:add(buffer(i+44,12):string()):append_text(":smi_evt_msg_t->union9.odu.desc")
	-- 
	 	i = i+91
	-- 	subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_evt_msg_t->reason")
	-- 	i = i+4
	-- 	subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_evt_msg_t->e_time")
	-- 	subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_evt_msg_t::e_time(i="..i..")len="..length..")")
	-- 	i = i+4
	end
  elseif fid_name == "GET_LED_STATUS" then
  if (length <= i) then return end
	if sys_name == "CE740E" then
		while (i < length) do
			subtree:add(msg_uint16, buffer(i,2)):append_text(":emsagt_smi_led_status_t::main_sts(i="..i..")")
			i = i+2
			subtree:add(msg_uint16, buffer(i,2)):append_text(":emsagt_smi_led_status_t::clk_sts")
			i = i+2
			subtree:add(msg_uint16, buffer(i,2)):append_text(":emsagt_smi_led_status_t::ces_sts")
			i = i+2
			subtree:add(msg_uint16, buffer(i,2)):append_text(":emsagt_smi_led_status_t::ptp_sts")
			i = i+2
			j = 0
			while(j<7) do
				subtree:add(msg_uint16, buffer(i,2)):append_text(":emsagt_smi_led_status_t::link_sts["..j.."]")
				i = i+2	
				j = j+1
			end
		end
	elseif sys_name == "CE7610"  or sys_name == "CE7611" then
		while (i < length) do
			subtree:add(msg_uint16, buffer(i,2)):append_text(":emsagt_smi_761x_led_status_t::main_sts(i="..i..")")
			subtree:add(buffer(i,2):bitfield(0,0)):append_text(":ACT");
			subtree:add(buffer(i,2):bitfield(1,1)):append_text(":SCE");
			subtree:add(buffer(i,2):bitfield(2,2)):append_text(":CRI");
			subtree:add(buffer(i,2):bitfield(3,3)):append_text(":MAJ");
			subtree:add(buffer(i,2):bitfield(4,4)):append_text(":MIN");
			subtree:add(buffer(i,2):bitfield(5,5)):append_text(":MIN");
			subtree:add(buffer(i,2):bitfield(6,6)):append_text(":STA");
			subtree:add(buffer(i,2):bitfield(7,7)):append_text(":SYN");
			i = i+2
			subtree:add(msg_uint16, buffer(i,2)):append_text(":emsagt_smi_761x_led_status_t::clk_sts")
			i = i+2
			subtree:add(msg_uint16, buffer(i,2)):append_text(":emsagt_smi_761x_led_status_t::ces_sts")
			i = i+2
			subtree:add(msg_uint16, buffer(i,2)):append_text(":emsagt_smi_761x_led_status_t::ptp_sts")
			i = i+2
			j = 0
			while(j<12) do
				subtree:add(msg_uint16, buffer(i,2)):append_text(":emsagt_smi_761x_led_status_t::link_sts["..j.."]")
				i = i+2	
				j = j+1
			end
		end
	elseif sys_name == "CE73K0" then
		while (i < length) do
			subtree:add(msg_uint16, buffer(i,2)):append_text(":emsagt_smi_led_73K0_status_t::main_sts(i="..i..")")
			subtree:add(buffer(i,2):bitfield(0,0)):append_text(":ACT");
			subtree:add(buffer(i,2):bitfield(1,1)):append_text(":SCE");
			subtree:add(buffer(i,2):bitfield(2,2)):append_text(":CRI");
			subtree:add(buffer(i,2):bitfield(3,3)):append_text(":MAJ");
			subtree:add(buffer(i,2):bitfield(4,4)):append_text(":MIN");
			subtree:add(buffer(i,2):bitfield(5,5)):append_text(":MIN");
			subtree:add(buffer(i,2):bitfield(6,6)):append_text(":STA");
			subtree:add(buffer(i,2):bitfield(7,7)):append_text(":SYN");
			i = i+2
			subtree:add(msg_uint16, buffer(i,2)):append_text(":emsagt_smi_led_73K0_status_t::clk_sts")
			i = i+2
			subtree:add(msg_uint16, buffer(i,2)):append_text(":emsagt_smi_led_73K0_status_t::ces_sts")
			i = i+2
			subtree:add(msg_uint16, buffer(i,2)):append_text(":emsagt_smi_led_73K0_status_t::ptp_sts")
			i = i+2
			j = 0
			while(j<12) do
				subtree:add(msg_uint16, buffer(i,2)):append_text(":emsagt_smi_led_73K0_status_t::link_sts["..j.."]->"..tobits(buffer(i,2):uint()))
				-- subtree:add(byte2bin(buffer(i,2)))
				i = i+2	
				j = j+1
			end
		end
	else
		while (i < length) do
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::smi_pid->pid_type(i="..i..")")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::smi_pid->ne_type")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::smi_pid->card_id")
			i = i+4
			subtree:add(msg_uint16, buffer(i,2)):append_text(":slot_led_8300_t::smi_pid->slot_id")
			i = i+2
			subtree:add(msg_uint16, buffer(i,2)):append_text(":slot_led_8300_t::smi_pid->port_id")
			i = i+2
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::dmmmy_main_sts")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::dmmmy_clk_sts")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::dmmmy_ces_sts")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::dmmmy_ptp_sts")
			i = i+4
			subtree:add(msg_uint64, buffer(i,8)):append_text(":slot_led_8300_t::link_sts[0]")
			i = i+8
			subtree:add(msg_uint64, buffer(i,8)):append_text(":slot_led_8300_t::link_sts[1]")
			i = i+8
			subtree:add(msg_uint64, buffer(i,8)):append_text(":slot_led_8300_t::link_sts[2]")
			i = i+8
			subtree:add(msg_uint64, buffer(i,8)):append_text(":slot_led_8300_t::link_sts[3]")
			i = i+8
			subtree:add(msg_uint64, buffer(i,8)):append_text(":slot_led_8300_t::link_sts[4]")
			i = i+8
			subtree:add(msg_uint64, buffer(i,8)):append_text(":slot_led_8300_t::link_sts[5]")
			i = i+8
			subtree:add(msg_uint64, buffer(i,8)):append_text(":slot_led_8300_t::link_sts[6]")
			i = i+8
			subtree:add(msg_uint64, buffer(i,8)):append_text(":slot_led_8300_t::link_sts[7]")
			i = i+8
			subtree:add(msg_uint64, buffer(i,8)):append_text(":slot_led_8300_t::link_sts[8]")
			i = i+8
			subtree:add(msg_uint64, buffer(i,8)):append_text(":slot_led_8300_t::link_sts[9]")
			i = i+8
			subtree:add(msg_uint64, buffer(i,8)):append_text(":slot_led_8300_t::link_sts[10]")
			i = i+8
			subtree:add(msg_uint64, buffer(i,8)):append_text(":slot_led_8300_t::link_sts[11]")
			i = i+8
			subtree:add(msg_uint64, buffer(i,8)):append_text(":slot_led_8300_t::link_sts[12]")
			i = i+8
			subtree:add(msg_uint64, buffer(i,8)):append_text(":slot_led_8300_t::link_sts[13]")
			i = i+8
			subtree:add(msg_uint64, buffer(i,8)):append_text(":slot_led_8300_t::link_sts[14]")
			i = i+8
			subtree:add(msg_uint64, buffer(i,8)):append_text(":slot_led_8300_t::link_sts[15]")
			i = i+8
			subtree:add(msg_uint64, buffer(i,8)):append_text(":slot_led_8300_t::link_sts[16]")
			i = i+8
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::card_sts[0]")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::card_sts[1]")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::card_sts[2]")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::card_sts[3]")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::card_sts[4]")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::card_sts[5]")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::card_sts[6]")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::card_sts[7]")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::card_sts[8]")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::card_sts[9]")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::card_sts[10]")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::card_sts[11]")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":slot_led_8300_t::card_sts[12]")
			i = i+4
		end
	end
  elseif fid_name == "SYS_SW_PROM_ACTIVE" then
    if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":mib_set_prom::smi_pid->pid_type(i="..i..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":mib_set_prom::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":mib_set_prom::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":mib_set_prom::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":mib_set_prom::smi_pid->port_id")
		i = i+2
		subtree:add(msg_uint08, buffer(i,1)):append_text("mib_set_prom(1=BANK1,2=BANK2)")
		i = i+1
	end
  elseif fid_name == "OTN_GET_OTU_TS_MAP_STATE" or fid_name == "OTN_SET_OTU_TS_MAP_STATE" or fid_name == "OTN_DEL_OTU_TS_MAP_STATE" then
  if (length <= i) then return end
	while (i < length) do
	    subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_otu_port_ts_mapping_status_t::smi_pid->pid_type(i="..i..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_otu_port_ts_mapping_status_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_otu_port_ts_mapping_status_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_otu_port_ts_mapping_status_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_otu_port_ts_mapping_status_t::smi_pid->port_id")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_otu_port_ts_mapping_status_t::if_index")
		i = i+4
		j = 0
		while(j<80) do
			subtree:add(msg_uint08, buffer(i,1)):append_text("["..j.."](ho:type(0:NONE,1:ODU0,2:ODU1,5:ODU2,8:ODU3,11:ODU4)")
			i = i+1
			subtree:add(msg_uint16, buffer(i,2)):append_text("["..j.."]smi_otu_port_ts_mapping_status_t::smi_oduk_ts_mapping_status:ho:trail_id")
			i = i+2
			subtree:add(msg_dst_add, buffer(i,4)):append_text("["..j.."]smi_otu_port_ts_mapping_status_t::smi_oduk_ts_mapping_status:ho:trail_ip")
			i = i+4
			subtree:add(msg_uint08, buffer(i,1)):append_text("["..j.."]mo:type(0:NONE,1:ODU0,2:ODU1,5:ODU2,8:ODU3,11:ODU4)")
			i = i+1
			subtree:add(msg_uint16, buffer(i,2)):append_text("["..j.."]smi_otu_port_ts_mapping_status_t::smi_oduk_ts_mapping_status:mo:trail_id")
			i = i+2
			subtree:add(msg_dst_add, buffer(i,4)):append_text("["..j.."]smi_otu_port_ts_mapping_status_t::smi_oduk_ts_mapping_status:mo:trail_ip")
			i = i+4
			subtree:add(msg_uint08, buffer(i,1)):append_text("["..j.."]lo:type(0:NONE,1:ODU0,2:ODU1,5:ODU2,8:ODU3,11:ODU4)")
			i = i+1
			subtree:add(msg_uint16, buffer(i,2)):append_text("["..j.."]smi_otu_port_ts_mapping_status_t::smi_oduk_ts_mapping_status:lo:trail_id")
			i = i+2
			subtree:add(msg_dst_add, buffer(i,4)):append_text("["..j.."]smi_otu_port_ts_mapping_status_t::smi_oduk_ts_mapping_status:lo:trail_ip")
			i = i+4
			subtree:add(msg_uint08, buffer(i,1)):append_text("["..j.."]map_type(0:NONE,1:SVC,2:XCON,3:MPLS,4:SDH,5:PDH")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text("["..j.."]smi_otu_port_ts_mapping_status_t::smi_oduk_ts_mapping_status:ho:slice")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text("["..j.."]smi_otu_port_ts_mapping_status_t::smi_oduk_ts_mapping_status:ho:ac_bind_cnt")
			i = i+1
			j = j+1
		end
	end
  elseif fid_name == "OTN_ADD_ODU_BIND_SVC" or fid_name == "OTN_DEL_ODU_BIND_SVC" then
  if (length <= i) then return end
	while (i < length) do
	    subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_bind_service_add_t::svc_type[1=SVC,2=SDH,4=MPLS,8=PDH](i="..i..")")
		i = i+4
	    subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_bind_service_add_t::smi_pid->pid_type(i="..i..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_bind_service_add_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_bind_service_add_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_odu_bind_service_add_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_odu_bind_service_add_t::smi_pid->port_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_odu_bind_service_add_t::trail_id")
		i = i+2
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_odu_bind_service_add_t::egress_ip")
		i = i+4
		
		subtree:add(msg_uint32, buffer(i+0,4)):append_text(":smi_odu_bind_service_add_t::union:ptn:ac_id")
		subtree:add(buffer(i+4,32):string()):   append_text(":smi_odu_bind_service_add_t::union:ptn:svc_name")

		subtree:add(msg_uint32,  buffer(i+0,4)):append_text(":smi_odu_bind_service_add_t::union:mpls:ifindex")
		subtree:add(msg_dst_add, buffer(i+4,4)):append_text(":smi_odu_bind_service_add_t::union:mpls:peer_node")
		subtree:add(msg_uint08, buffer(i+8,1)):append_text(":smi_odu_bind_service_add_t::union:mpls:shelf_id")
		subtree:add(msg_uint08, buffer(i+9,1)):append_text(":smi_odu_bind_service_add_t::union:mpls:slot_id")
		subtree:add(msg_uint08, buffer(i+10,1)):append_text(":smi_odu_bind_service_add_t::union:mpls:port_id")
		subtree:add(msg_mac, buffer(i+11,6)):append_text(":smi_odu_bind_service_add_t::union:mpls:mac")
		subtree:add(msg_uint08, buffer(i+17,1)):append_text(":smi_odu_bind_service_add_t::union:mpls:vtag")
		subtree:add(msg_uint16, buffer(i+18,2)):append_text(":smi_odu_bind_service_add_t::union:mpls:vid")
		subtree:add(buffer(i+20,50):string()):   append_text(":smi_odu_bind_service_add_t::union:mpos:mpls_name")

		subtree:add(msg_uint32, buffer(i+0,4)):append_text(":smi_odu_bind_service_add_t::union:sdh:ac_id")
		subtree:add(buffer(i+4,32):string()):   append_text(":smi_odu_bind_service_add_t::union:sdh:sdh_vc4")
		subtree:add(msg_uint32,  buffer(i+36,4)):append_text(":smi_odu_bind_service_add_t::union:sdh:service_id")

		subtree:add(msg_uint32, buffer(i+0,4)):append_text(":smi_odu_bind_service_add_t::union:pdh:ac_id")
		subtree:add(buffer(i+4,32):string()):   append_text(":smi_odu_bind_service_add_t::union:pdh:stm_if")
		-- i = i+4  =  4  -- ptn:peer node
		-- i = i+32 = 36  -- ptn:peer name
		--
		-- i = i+4  =  4  -- mpls:ifindex
		-- i = i+4  =  8  -- mpls:peer_node
		-- i = i+1  =  9  -- mpls:shelf
		-- i = i+1  = 10  -- mpls:slot
		-- i = i+1  = 11  -- mpls:port
		-- i = i+6  = 17  -- mpls:mac
		-- i = i+1  = 18  -- mpls:tagged
		-- i = i+2  = 20  -- mpls:vlan_id
		-- i = i+50 = 70  -- mpls:name
		--
		-- i = i+4  =  4  -- sdh:ifindex
		-- i = i+32 = 36  -- sdh:sdh_vc4
		-- i = i+36 = 40  -- sdh:service_id
		--
		-- i = i+4  =  4  -- pdh:ifindex
		-- i = i+32 = 36  -- pdh:stm_if
		--
		i = i + 158
	end
elseif fid_name == "SYS_GET_PORT_MODULE" then
  if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_cfp_module_info_t::smi_pid->pid_type(i="..i..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_cfp_module_info_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_cfp_module_info_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_cfp_module_info_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_cfp_module_info_t::smi_pid->port_id")
		i = i+2

		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_cfp_module_info_t::ddm_valid")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_cfp_module_info_t::module_type")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_cfp_module_info_t::reach")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_cfp_module_info_t::connector")
		i = i+1
		local pdu_type = buffer(i,1):uint()
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_cfp_module_info_t::pdu_type(2=WSS,3=PRE,4=BST)")
		i = i+1
		subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::distance")
		i = i+4
		subtree:add(buffer(i,16):string()):append_text("smi_cfp_module_info_t::vendor")
		i = i+16
		subtree:add(buffer(i,16):string()):append_text("smi_cfp_module_info_t::partnumber")
		i = i+16
		subtree:add(buffer(i,16):string()):append_text("smi_cfp_module_info_t::serial")
		i = i+16
		subtree:add(buffer(i,16):string()):append_text("smi_cfp_module_info_t::date")
		i = i+10
		if (pdu_type == 2) then
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.wss.attn")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.wss.set")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.wss.min")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.wss.max")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.wss.real")
			i = i+4
			subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_cfp_module_info_t::optic_power.wss.lambda")
			i = i+1
			i = i+69
		elseif (pdu_type == 3) then
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.pre.inp")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.pre.dcf1.out")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.pre.dcf1.attn")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.pre.dcf2.inp")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.pre.drop_out")
			i = i+4
			i = i+70
		elseif (pdu_type == 4) then
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.bst.inp")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.bst.out")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.bst.gain")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.bst.out.attn")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.bst.real_out")
			i = i+4
			i = i+70
		else
			j = 0
			while(j<5) do
		 	subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_cfp_module_info_t::optic_power.cfp.wavelength")
		 	i = i+2
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.cfp.rx_power")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.cfp.bias")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.cfp.tx_pwr")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::optic_power.cfp.temperature")
			i = i+4
		 	j = j+1
		 end
		end
		subtree:add(msg_uint32, buffer(i,4):float()):append_text(":smi_cfp_module_info_t::vcc")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_cfp_module_info_t::dummy1")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_cfp_module_info_t::dummy2")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_cfp_module_info_t::dummy3")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_cfp_module_info_t::dummy4")
		i = i+4
	  end
	elseif fid_name == "OTN_GET_WDM_BIND_XC" or fid_name == "OTN_GET_WDM_BIND_XC" then
	if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_wss_xc_t::smi_pid->pid_type(i="..i..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_wss_xc_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_wss_xc_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_wss_xc_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_wss_xc_t::smi_pid->port_id")
		i = i+2
		j = 0
		while(j<88) do
			subtree:add(msg_uint08, buffer(i,1)):append_text("["..j.."]smi_wss_xc_t::flags")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text("["..j.."]smi_wss_xc_t::lambda")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text("["..j.."]smi_wss_xc_t::slot")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text("["..j.."]smi_wss_xc_t::port")
			i = i+1
			subtree:add(msg_dst_add, buffer(i,4)):append_text("["..j.."]smi_wss_xc_t:peer_node")
			i = i+4
			subtree:add(msg_uint08, buffer(i,1)):append_text("["..j.."]smi_wss_xc_t::peer_slot")
			i = i+1
			subtree:add(msg_uint08, buffer(i,1)):append_text("["..j.."]smi_wss_xc_t::peer_port")
			i = i+1
			subtree:add(buffer(i,12):string()):   append_text("["..j.."]smi_wss_xc_t::desc")
			i = i+12
			j = j+1
		end
	end
  elseif fid_name == "OTN_SET_ODU_TRAIL_CFG" or fid_name == "OTN_DEL_ODU_TRAIL_CFG"  or fid_name == "OTN_GET_ODU_TRAIL_CFG" then
    if (length <= i) then return end
	while (i < length) do
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_trail_cfg_t::smi_pid->pid_type(i="..i..")len="..length..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_trail_cfg_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_trail_cfg_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_odu_trail_cfg_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_odu_trail_cfg_t::smi_pid->port_id")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_trail_cfg_t->flag")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_odu_trail_cfg_t->trail_id")
		i = i+2
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_odu_trail_cfg_t->egr_lsr_id")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_trail_cfg_t->if_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_trail_cfg_t->mux_layer")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_trail_cfg_t->ilkn_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_trail_cfg_t->map_type")
		i = i+4
		subtree:add(buffer(i,20):string()):append_text(":smi_odu_trail_cfg_t->names")
		i = i+20
		subtree:add(buffer(i,11):string()):append_text(":smi_odu_trail_cfg_t->dummy")
		i = i+11
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->auto_nni")
		i = i+1
		subtree:add(buffer(i,32):string()):append_text(":smi_odu_trail_cfg_t->desc")
		i = i+32
		subtree:add(buffer(i,20):string()):append_text(":smi_odu_trail_cfg_t->w_trail->name")
		i = i+20
		subtree:add(buffer(i,12):string()):append_text(":smi_odu_trail_cfg_t->w_trail->pad")
		i = i+12
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_odu_trail_cfg_t->w_trail->peer")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->w_trail->slot")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->w_trail->port")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->w_trail->slice")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->w_trail->ts_start")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->w_trail->ts_count")
		i = i+1
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_odu_trail_cfg_t->w_trail->encryption")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->w_trail->pm_mon")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->w_trail->tcm_pm_mon")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->w_trail->alm_mon")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->w_trail->tcm_alm_mon")
		i = i+1
		subtree:add(buffer(i,20):string()):append_text(":smi_odu_trail_cfg_t->p_trail->name")
		i = i+20
		subtree:add(buffer(i,12):string()):append_text(":smi_odu_trail_cfg_t->p_trail->pad")
		i = i+12
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_odu_trail_cfg_t->p_trail->peer")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->p_trail->slot")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->p_trail->port")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->p_trail->slice")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->p_trail->ts_start")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->p_trail->ts_count")
		i = i+1
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_odu_trail_cfg_t->p_trail->encryption")
		i = i+4
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->p_trail->pm_mon")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->p_trail->tcm_pm_mon")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->p_trail->alm_mon")
		i = i+1
		subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_odu_trail_cfg_t->p_trail->tcm_alm_mon")
		i = i+1
	end
  elseif fid_name == "OTN_SET_ODU_TRAIL_PROTECTION_CFG" or fid_name == "OTN_GET_ODU_TRAIL_PROTECTION_CFG" then
  if (length <= i) then return end
	while (i < length) do
	    subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_trail_protection_cfg_t::smi_pid->pid_type(i="..i..")")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_trail_protection_cfg_t::smi_pid->ne_type")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_trail_protection_cfg_t::smi_pid->card_id")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_odu_trail_protection_cfg_t::smi_pid->slot_id")
		i = i+2
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_odu_trail_protection_cfg_t::smi_pid->port_id")
		i = i+2
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_trail_protection_cfg_t::flag")
		i = i+4
		subtree:add(msg_uint16, buffer(i,2)):append_text(":smi_odu_trail_protection_cfg_t::trail_id")
		i = i+2
		subtree:add(msg_dst_add, buffer(i,4)):append_text(":smi_odu_trail_protection_cfg_t::egress_ip")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_trail_protection_cfg_t::mode(0=1+1,1=1:1)")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_trail_protection_cfg_t::dir(0=UNI,1=BI)")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_trail_protection_cfg_t::oper_mode(0=NON-REV,1=REV)")
		i = i+4
		subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_odu_trail_protection_cfg_t::wtr_time_(sec)")
		i = i+4
	end
  elseif fid_name == "SYS_GET_SYSTEM_EVENT_HISTORY" or fid_name == "SYS_GET_SYSTEM_EVENT_HISTORY" then
  if (length <= i) then return end
	while (i < length) do
	    subtree:add(msg_uint08, buffer(i,1)):append_text(":smi_sw_msg_info_t::count(i="..i..")")
		i = i+1
		j = 0
		while(j<7) do

			subtree:add(msg_uint32, buffer(i,4)):append_text(":_smi_sw_msg_t::smi_pid->pid_type(i="..j..")")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":_smi_sw_msg_t::smi_pid->ne_type")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":_smi_sw_msg_t::smi_pid->card_id")
			i = i+4
			subtree:add(msg_uint16, buffer(i,2)):append_text(":_smi_sw_msg_t::smi_pid->slot_id")
			i = i+2
			subtree:add(msg_uint16, buffer(i,2)):append_text(":_smi_sw_msg_t::smi_pid->port_id")
			i = i+2
			subtree:add(msg_uint32, buffer(i,4)):append_text(":_smi_sw_msg_t::sw_cmd")
			i = i+4
			subtree:add(msg_uint08, buffer(i,1)):append_text(":_smi_sw_msg_t::msg_type")
			i = i+1

			subtree:add(msg_uint08, buffer(i+0,1)):append_text(":_smi_sw_msg_t::union_papa::from_papa")
			subtree:add(msg_uint08, buffer(i+1,1)):append_text(":_smi_sw_msg_t::union_papa::to_papa")
			
			subtree:add(msg_uint32, buffer(i+0,4)):append_text("::_smi_sw_msg_t::union_tnl::smi_mpls_tunnel_idInfo_t->role")
			subtree:add(msg_dst_add, buffer(i+4,4)):append_text(":_smi_sw_msg_t::union_tnl::smi_mpls_tunnel_idInfo_t->igr_node_id")
			subtree:add(msg_dst_add, buffer(i+8,4)):append_text(":_smi_sw_msg_t::union_tnl::smi_mpls_tunnel_idInfo_t->egr_node_id")
			subtree:add(msg_uint16, buffer(i+12,2)):append_text(":_smi_sw_msg_t::union_tnl::smi_mpls_tunnel_idInfo_t->igr_tunnel_id")
			subtree:add(msg_uint16, buffer(i+14,2)):append_text(":_smi_sw_msg_t::union_tnl::smi_mpls_tunnel_idInfo_t->egr_tunnel_id")
			subtree:add(msg_uint16, buffer(i+16,2)):append_text(":_smi_sw_msg_t::union_tnl::smi_mpls_tunnel_idInfo_t->assoticated_tunnel_id")
			subtree:add(msg_uint08, buffer(i+18,1)):append_text(":_smi_sw_msg_t::union_tnl::smi_mpls_tunnel_idInfo_t->direction")
			subtree:add(buffer(i+19,50):string()):append_text(":_smi_sw_msg_t::union_tnl::smi_mpls_tunnel_idInfo_t->names")
			subtree:add(msg_uint08, buffer(i+69,1)):append_text(":_smi_sw_msg_t::union_tnl::smi_mpls_tunnel_idInfo_t->is_remote")
			subtree:add(msg_uint08, buffer(i+70,1)):append_text(":_smi_sw_msg_t::union_tnl::smi_mpls_tunnel_idInfo_t->from_lsp")
			subtree:add(msg_uint08, buffer(i+71,1)):append_text(":_smi_sw_msg_t::union_tnl::smi_mpls_tunnel_idInfo_t->to_lsp")
			subtree:add(msg_uint08, buffer(i+72,1)):append_text(":_smi_sw_msg_t::union_tnl::smi_mpls_tunnel_idInfo_t->from_lsp_type")
			subtree:add(msg_uint08, buffer(i+73,1)):append_text(":_smi_sw_msg_t::union_tnl::smi_mpls_tunnel_idInfo_t->to_lsp_type")
			subtree:add(msg_uint32, buffer(i+74,4)):append_text(":_smi_sw_msg_t::union_tnl::smi_mpls_tunnel_idInfo_t->from_ifindex")
			subtree:add(msg_uint32, buffer(i+78,4)):append_text(":_smi_sw_msg_t::union_tnl::smi_mpls_tunnel_idInfo_t->to_ifindex")
			subtree:add(buffer(i+82,50):string()):append_text(":_smi_sw_msg_t::union_tnl::smi_mpls_tunnel_idInfo_t->from_names")
			subtree:add(buffer(i+132,50):string()):append_text(":_smi_sw_msg_t::union_tnl::smi_mpls_tunnel_idInfo_t->to_names")
			
			subtree:add(msg_uint32, buffer(i+0,4)):append_text(":_smi_sw_msg_t::union_odu::smi_pid->pid_type")
			subtree:add(msg_uint32, buffer(i+4,4)):append_text(":_smi_sw_msg_t::union_odu::smi_pid->ne_type")
			subtree:add(msg_uint32, buffer(i+8,4)):append_text(":_smi_sw_msg_t::union_odu::smi_pid->card_id")
			subtree:add(msg_uint16, buffer(i+12,2)):append_text(":_smi_sw_msg_t::union_odu::smi_pid->slot_id")
			subtree:add(msg_uint16, buffer(i+14,2)):append_text(":_smi_sw_msg_t::union_odu::smi_pid->port_id")
			subtree:add(msg_uint16, buffer(i+16,2)):append_text(":_smi_sw_msg_t::union_odu::trail_id")
			subtree:add(msg_dst_add, buffer(i+18,4)):append_text(":_smi_sw_msg_t::union_odu::egress_ip")
			subtree:add(buffer(i+22,32):string()):append_text(":_smi_sw_msg_t::union_odu::names")
			subtree:add(msg_uint32, buffer(i+54,4)):append_text(":_smi_sw_msg_t::union_odu::reason")
			subtree:add(msg_uint32, buffer(i+58,4)):append_text(":_smi_sw_msg_t::union_odu::from")
			subtree:add(msg_uint32, buffer(i+62,4)):append_text(":_smi_sw_msg_t::union_odu::to")

			i = i+4
			i = i+4
			i = i+4
			i = i+2
			i = i+2
			i = i+2
			i = i+1
			i = i+50
			i = i+1
			i = i+1
			i = i+1
			i = i+1
			i = i+1
			i = i+4
			i = i+4
			i = i+50
			i = i+50

			subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_sw_msg_t->reason")
			i = i+4
			subtree:add(msg_uint32, buffer(i,4)):append_text(":smi_sw_msg_t->e_time")
			i = i+4

			j = j+1
		end
	end
  elseif fid_name == "OP_QUERY" then
    local flags_number = buffer(16,4):le_uint()
    local flags_description = get_flag_description(flags_number)
    subtree:add(flags,      buffer(16,4)):append_text(" (" .. flags_description .. ")")

    -- Loop over string
    local string_length

    for i = 20, length - 1, 1 do
      if (buffer(i,1):le_uint() == 0) then
        string_length = i - 20
        break
      end
    end

    subtree:add(full_coll_name,   buffer(20,string_length))
    subtree:add(number_to_skip,   buffer(20+string_length,4))
    subtree:add(number_to_return, buffer(24+string_length,4))
    subtree:add(query,            buffer(28+string_length,length-string_length-28))
  elseif fid_name == "OP_REPLY" then
    local response_flags_number = buffer(16,4):le_uint()
    local response_flags_description = get_response_flag_description(response_flags_number)
    
    subtree:add(response_flags,   buffer(16,4)):append_text(" (" .. response_flags_description .. ")")
    subtree:add(cursor_id,        buffer(20,8))
    subtree:add(starting_from,    buffer(28,4))
    subtree:add(number_returned,  buffer(32,4))
    subtree:add(documents,        buffer(36,length-36))
  end
  p_len = p_len + i
  end
end

function reverse(t)
  local nt = {} -- new table
  local size = #t + 1
  for k,v in ipairs(t) do
    nt[size - k] = v
  end
  return nt
end

function tobits(num)
    local t={}
    while num>0 do
        rest=num%2
        t[#t+1]=rest
        num=(num-rest)/2
    end
    t = reverse(t)
    return table.concat(t)
end

function byte2bin(n)
  local t = {}
  for i=7,0,-1 do
    t[#t+1] = math.floor(n / 2^i)
    n = n % 2^i
   end
  return table.concat(t)
end

function get_fid_name(fid)
  local fid_name = "Unknown"

      if fid ==    1 then fid_name = "OP_REPLY"
  elseif fid == 2001 then fid_name = "OP_UPDATE"
  elseif fid == 2002 then fid_name = "OP_INSERT"
  elseif fid == 2003 then fid_name = "RESERVED"
  elseif fid == 2004 then fid_name = "OP_QUERY"
  elseif fid == 2005 then fid_name = "OP_GET_MORE"
  elseif fid == 2006 then fid_name = "OP_DELETE"
  elseif fid == 2007 then fid_name = "OP_KILL_CURSORS"
  elseif fid == 2010 then fid_name = "OP_COMMAND"
  elseif fid ==    2 then fid_name = "OP_STATUS"
  elseif fid ==    3 then fid_name = "OP_ALARM"
  elseif fid ==    4 then fid_name = "OP_HELLO"
  elseif fid == 2011 then fid_name = "OP_COMMANDREPLY" end

  return fid_name
end

function get_cod_name(sys_code,fid_code)
	local code_name = "Unknown"

	    if fid_code == 0x0001 then code_name = "NE_CONFIG"
	elseif fid_code == 0x0002 then code_name = "NE_STATUS"
	elseif fid_code == 0x0003 then code_name = "NE_ALARM"
	elseif fid_code == 0x0004 then code_name = "HELLO_ACK"
	elseif fid_code == 0x0005 then code_name = "EMS_MSG"
	elseif fid_code == 0x0006 then code_name = "EMS_MSG"
	elseif fid_code == 0x0007 then code_name = "EMS_MSG"
	elseif fid_code == 0x0008 then code_name = "NE_CONFIG"
	elseif fid_code == 0x000D then code_name = "SET_SLOT_PROVISION"
	elseif fid_code == 0x000E then code_name = "DEL_SLOT_PROVISION"
	elseif fid_code == 0x000F then code_name = "GET_SLOT_PROVISION"
	elseif fid_code == 0x0030 then code_name = "GET_SYSTEM_INFO"
	elseif fid_code == 0x0031 then code_name = "SET_SYSTEM_INFO"
	elseif fid_code == 0x0032 then code_name = "DEL_SYSTEM_INFO"
	elseif fid_code == 0x0043 then code_name = "SYS_SW_GET_PROM"
	elseif fid_code == 0x0044 then code_name = "SYS_SW_SET_PROM"
	elseif fid_code == 0x0045 then code_name = "SYS_SW_PROM_UPDATE"
	elseif fid_code == 0x0046 then code_name = "SYS_SW_UPDATE_REBOOT"
	elseif fid_code == 0x0047 then code_name = "SMI_MSG_SYS_SW_UPDATE_REBOOT"
	elseif fid_code == 0x0048 then code_name = "SYS_SW_PROM_ACTIVE"
	elseif fid_code == 0x0061 then code_name = "SET_MEM_OVER_THRLD"
	elseif fid_code == 0x0083 then code_name = "SYS_GET_SYSTEM_GM_EVENT_HIST"
	elseif fid_code == 0x0084 then code_name = "SYS_DEL_SYSTEM_GM_EVENT_HIST"
	elseif fid_code == 0x0087 then code_name = "SYS_GET_SYSTEM_TCA_EVENT_HIST"
	elseif fid_code == 0x0088 then code_name = "SYS_DEL_SYSTEM_TCA_EVENT_HIST"
	elseif fid_code == 0x0099 then code_name = "SYS_GET_SYSTEM_ACO"
	elseif fid_code == 0x009A then code_name = "SYS_SET_SYSTEM_ACO"
	elseif fid_code == 0x009B then code_name = "SYS_CMD_SYSTEM_ACO"
	elseif fid_code == 0x0070 then code_name = "SYS_GET_SYSTEM_FAN_INFO"
	elseif fid_code == 0x0080 then code_name = "SYS_GET_SYSTEM_TEMP_INFO"
	elseif fid_code == 0x0082 then code_name = "MSG_SYS_GET_PSU_INFO"
	elseif fid_code == 0x0085 then code_name = "SYS_GET_SYSTEM_EVENT_HISTORY"
	elseif fid_code == 0x0086 then code_name = "SYS_DEL_SYSTEM_EVENT_HISTORY"
	elseif fid_code == 0x0090 then code_name = "SYS_GET_SYSTEM_ALARM_COND"
	elseif fid_code == 0x0091 then code_name = "SYS_SET_SYSTEM_ALARM_COND"  
	elseif fid_code == 0x0092 then code_name = "SYS_DEL_SYSTEM_ALARM_COND"
	elseif fid_code == 0x00B0 then code_name = "SYS_GET_SYSTEM_NTP_INFO"
	elseif fid_code == 0x00B1 then code_name = "SYS_SET_SYSTEM_NTP_INFO"
	elseif fid_code == 0x00B2 then code_name = "SYS_CMD_SYSTEM_NTP_INFO"
	elseif fid_code == 0x00C0 then code_name = "SYS_GET_SYS_LOG_SERVER"
	elseif fid_code == 0x00C1 then code_name = "SYS_SET_SYS_LOG_SERVER"
	elseif fid_code == 0x00D1 then code_name = "SYS_SET_SYSTEM_TIME"
	elseif fid_code == 0x00D2 then code_name = "SYS_GET_SYSTEM_TIME"
	elseif fid_code == 0x00D3 then code_name = "SYS_GET_SYSTEM_RTC_UPDATE"
	elseif fid_code == 0x00D4 then code_name = "SYS_SET_SYSTEM_RTC_UPDATE"
	elseif fid_code == 0x00D5 then code_name = "SYS_CMD_SYSTEM_RTC_UPDATE"
	elseif fid_code == 0x00F1 then code_name = "SYS_SYSCONF_BACKUP"
	elseif fid_code == 0x00F2 then code_name = "SYS_SYSCONF_RESTORE"
	elseif fid_code == 0x00F5 then code_name = "SYS_CMD_SAVE_CONF"
	elseif fid_code == 0x0130 then code_name = "SYS_SET_EMS_REGISTER"
	elseif fid_code == 0x0131 then code_name = "SYS_GET_EMS_REGISTER"
	elseif fid_code == 0x0132 then code_name = "SYS_DEL_EMS_REGISTER"
	elseif fid_code == 0x0140 then code_name = "SYS_GET_LC_INVENTORY"
	elseif fid_code == 0x0142 then code_name = "SYS_GET_LC_HW_VER"
	elseif fid_code == 0x0143 then code_name = "SYS_GET_ACL_FPGA_VER"
	elseif fid_code == 0x0150 then code_name = "SYS_GET_CMD_HISTORY"
	elseif fid_code == 0x0151 then code_name = "SYS_DEL_CMD_HISTORY"
	elseif fid_code == 0x0152 then code_name = "SYS_GET_SYS_USER_LOG_HISTORY"
	elseif fid_code == 0x0153 then code_name = "SYS_GET_EMS_USER_LOG_HISTORY"
	elseif fid_code == 0x0154 then code_name = "SYS_DEL_SYS_USER_LOG_HISTORY"
	elseif fid_code == 0x0155 then code_name = "SYS_DEL_EMS_USER_LOG_HISTORY"
	elseif fid_code == 0x0160 then code_name = "SMI_FID_SYS_GET_PTLM_IN"
	elseif fid_code == 0x0161 then code_name = "SMI_FID_SYS_SET_PTLM_IN"
	elseif fid_code == 0x0162 then code_name = "SMI_FID_SYS_GET_PTLM_OUT"
	elseif fid_code == 0x0163 then code_name = "SMI_FID_SYS_SET_PTLM_OUT"
	elseif fid_code == 0x0170 then code_name = "SYS_CMD_TEST_LED"
	elseif fid_code == 0x0171 then code_name = "SYS_CMD_TEST_BUZZER"
	elseif fid_code == 0x0172 then code_name = "SYS_GET_PORT_MODULE"
	elseif fid_code == 0x0180 then code_name = "SYS_GET_PM_ENABLE"
	elseif fid_code == 0x0181 then code_name = "SYS_SET_PM_ENABLE"
	elseif fid_code == 0x0182 then code_name = "SYS_DEL_PM_ENABLE"
	elseif fid_code == 0x0183 then code_name = "SYS_GET_PM_STATUS"
	elseif fid_code == 0x0184 then code_name = "SYS_DEL_PM_STATUS"
	elseif fid_code == 0x0185 then code_name = "SYS_GET_TCA_CONFIG"
	elseif fid_code == 0x0186 then code_name = "SYS_SET_TCA_CONFIG"
	elseif fid_code == 0x0187 then code_name = "SYS_DEL_TCA_CONFIG"
	elseif fid_code == 0x0190 then code_name = "SYS_PM_TM_SET_PORT"
	elseif fid_code == 0x0191 then code_name = "SYS_PM_TM_DEL_PORT"
	elseif fid_code == 0x0192 then code_name = "SYS_PM_TM_GET_PORT"
	elseif fid_code == 0x0193 then code_name = "SYS_PM_TM_SET_LSP"
	elseif fid_code == 0x0194 then code_name = "SYS_PM_TM_DEL_LSP"
	elseif fid_code == 0x0195 then code_name = "SYS_PM_TM_GET_LSP"
	elseif fid_code == 0x0196 then code_name = "SYS_PM_TM_SET_PW"
	elseif fid_code == 0x0197 then code_name = "SYS_PM_TM_DEL_PW"
	elseif fid_code == 0x0198 then code_name = "SYS_PM_TM_GET_PW"
	elseif fid_code == 0x0200 then code_name = "SYS_PROTECTION_SWITCH"
	elseif fid_code == 0x0201 then code_name = "SYS_PM_GET_LSP_STATUS"
	elseif fid_code == 0x0202 then code_name = "SYS_PM_GET_PW_STATUS"
	elseif fid_code == 0x0203 then code_name = "SYS_PM_GET_AC_STATUS"
	elseif fid_code == 0x0205 then code_name = "SYS_BMT_SET_LSP_LOC"
	elseif fid_code == 0x0206 then code_name = "SYS_BMT_GET_LSP_LOC"
	elseif fid_code == 0x0207 then code_name = "SYS_BMT_SET_PHY"
	elseif fid_code == 0x0208 then code_name = "SYS_BMT_GET_PHY"
	elseif fid_code == 0x0209 then code_name = "SYS_PM_GET_TDMPW_COUNTER"
	elseif fid_code == 0x020A then code_name = "SYS_PM_INIT_TDMPW_COUNTER"
	elseif fid_code == 0x0210 then code_name = "SYS_GET_NVRAM_CMD"
	elseif fid_code == 0x0211 then code_name = "SYS_SET_NVRAM_CMD"
	elseif fid_code == 0x0212 then code_name = "SYS_GET_NVRAM_SUMMARY_STATE"
	elseif fid_code == 0x0213 then code_name = "SYS_GET_NVRAM_STATUS"
	elseif fid_code == 0x0221 then code_name = "SYS_GET_MPLS_PM_EN"
	elseif fid_code == 0x0222 then code_name = "SYS_SET_MPLS_PM_EN"
	elseif fid_code == 0x0223 then code_name = "SYS_DEL_MPLS_PM_EN"
	elseif fid_code == 0x0224 then code_name = "SYS_GET_CARRIER_DELAY"
	elseif fid_code == 0x0225 then code_name = "SYS_SET_CARRIER_DELAY"
	elseif fid_code == 0x0226 then code_name = "SYS_DEL_CARRIER_DELAY"
	elseif fid_code == 0x0227 then code_name = "SYS_GET_OPTIC_THRESHOLD"
	elseif fid_code == 0x0228 then code_name = "SYS_SET_OPTIC_THRESHOLD"
	elseif fid_code == 0x0229 then code_name = "SYS_DEL_OPTIC_THRESHOLD"
	elseif fid_code == 0x022A then code_name = "SYS_GET_SNMP"
	elseif fid_code == 0x022B then code_name = "SYS_SET_SNMP"
	elseif fid_code == 0x022C then code_name = "SYS_DEL_SNMP"
	elseif fid_code == 0x022D then code_name = "SYS_GET_MNG_IP_FILTER"
	elseif fid_code == 0x022E then code_name = "SYS_SET_MNG_IP_FILTER"
	elseif fid_code == 0x022F then code_name = "SYS_UNSET_MNG_IP_FILTER"
	elseif fid_code == 0x0230 then code_name = "SYS_GET_PORT_SCHEDULE"
	elseif fid_code == 0x0231 then code_name = "SYS_SET_PORT_SCHEDULE"
	elseif fid_code == 0x0232 then code_name = "SYS_DEL_PORT_SCHEDULE"
	elseif fid_code == 0x0233 then code_name = "SYS_GET_POLICER"
	elseif fid_code == 0x0234 then code_name = "SMI_MSG_SYS_SET_POLICER"
	elseif fid_code == 0x0236 then code_name = "SYS_GET_TEMPER"
	elseif fid_code == 0x0237 then code_name = "SYS_SET_TEMPER"
	elseif fid_code == 0x0238 then code_name = "SYS_GET_COS_BAND"
	elseif fid_code == 0x0239 then code_name = "SYS_SET_COS_BAND"
	elseif fid_code == 0x023A then code_name = "GET_LED_STATUS"
	elseif fid_code == 0x023C then code_name = "CPU_IDLE_STATUS"
	elseif fid_code == 0x023D then code_name = "CPU_OVER_THRESHOLD"
	elseif fid_code == 0x023F then code_name = "SYS_GET_REMOTE_RESET"
	elseif fid_code == 0x0240 then code_name = "SYS_SET_REMOTE_RESET"
	elseif fid_code == 0x0243 then code_name = "SYS_ICMP_TEST"
	elseif fid_code == 0x0244 then code_name = "SYS_ICMP_TEST_BREAK"
	elseif fid_code == 0x0245 then code_name = "SYS_SET_SELF_LOOP_FILTER"
	elseif fid_code == 0x0246 then code_name = "SYS_UNSET_SELF_LOOP_FILTER"
	elseif fid_code == 0x0247 then code_name = "SYS_GET_SELF_LOOP_FILTER"
	elseif fid_code == 0x0248 then code_name = "SYS_FTP_DOWNLOAD"
	elseif fid_code == 0x0281 then code_name = "SYS_GET_AUTO_ID"
	elseif fid_code == 0x0282 then code_name = "SYS_GET_SYSTEM_RESOURCE"
	elseif fid_code == 0x0283 then code_name = "SYS_COMPARE_GNE_NE_LST"
	elseif fid_code == 0x0300 then code_name = "SYS_SUB_ALM_DETAIL"
	elseif fid_code == 0x0301 then code_name = "SYS_GET_AUTO_DISCOVERY"
	elseif fid_code == 0x0302 then code_name = "SYS_GET_GNE_CHECKSUM"
	elseif fid_code == 0x0303 then code_name = "SYS_SET_GNE_AGENT"
	elseif fid_code == 0x0304 then code_name = "SYS_LOG_OUTPUT_GET"
	elseif fid_code == 0x0305 then code_name = "SYS_LOG_OUTPUT_SET"
	elseif fid_code == 0x0306 then code_name = "SYS_CRC_SHUTDOWN_GET"
	elseif fid_code == 0x0307 then code_name = "SYS_CRC_SHUTDOWN_SET"
	elseif fid_code == 0x0308 then code_name = "SYS_HOT_SWAP_GET"
	elseif fid_code == 0x0309 then code_name = "SYS_HOT_SWAP_SET"
	elseif fid_code == 0x030A then code_name = "SYS_GET_RTK_SW_LINK_STATE"
	elseif fid_code == 0x0310 then code_name = "SYS_SNMP_PROXY_GET"
	elseif fid_code == 0x0311 then code_name = "SYS_SNMP_PROXY_SET"
	elseif fid_code == 0x0312 then code_name = "SYS_SNMP_PROXY_UNSET"
	elseif fid_code == 0x0313 then code_name = "SYS_BATTERY_GET"
	elseif fid_code == 0x0314 then code_name = "SYS_BATTERY_THRED_GET"
	elseif fid_code == 0x0315 then code_name = "SYS_BATTERY_THRED_SET"
	elseif fid_code == 0x0316 then code_name = "SYS_SET_ICC"
	elseif fid_code == 0x0317 then code_name = "SYS_UNSET_ICC"
	elseif fid_code == 0x0318 then code_name = "SYS_GET_ICC"
	elseif fid_code == 0x0319 then code_name = "SYSTEM_SUMMARY"
	elseif fid_code == 0x0320 then code_name = "SYS_CRC_BLOCK_GET"
	elseif fid_code == 0x0321 then code_name = "SYS_CRC_BLOCK_SET"
	elseif fid_code == 0x0322 then code_name = "SYS_CRC_BLOCK_PM_GET"
	elseif fid_code == 0x0323 then code_name = "SYS_RESTORE_FACTORY"
	elseif fid_code == 0x0324 then code_name = "SYS_GET_SW_OS_INFO"
	elseif fid_code == 0x0325 then code_name = "SYS_SET_BATT_EXPIRED"
	elseif fid_code == 0x0326 then code_name = "SYS_GET_BATT_EXPIRED"
	elseif fid_code == 0x0327 then code_name = "SYS_GET_DEV_POWER"
	elseif fid_code == 0x0330 then code_name = "GET_LIST_RING_PT"
	elseif fid_code == 0x0331 then code_name = "GET_RING_PT"
	elseif fid_code == 0x0332 then code_name = "SET_RING_PT"
	elseif fid_code == 0x0333 then code_name = "SYS_GET_OPTIC_TUNABLE"
	elseif fid_code == 0x0334 then code_name = "SYS_SET_OPTIC_TUNABLE"
	elseif fid_code == 0x0335 then code_name = "SYS_GET_FABRIC_SERDES_LINK"
	elseif fid_code == 0x0336 then code_name = "SYS_GET_PETRA_B_SERDES_LINK"
	elseif fid_code == 0x0337 then code_name = "SYS_GET_FABRIC_SERDES_STAT"
	elseif fid_code == 0x0338 then code_name = "SYS_GET_PETRA_B_SERDES_STAT"
	elseif fid_code == 0x0339 then code_name = "SYS_CLEAR_SERDES_STAT"
	elseif fid_code == 0x0340 then code_name = "SYS_GET_SYSTEM_MTTF"
	elseif fid_code == 0x0341 then code_name = "SYS_SET_SYSTEM_MTTF"
	elseif fid_code == 0x0342 then code_name = "SYS_GET_SLOT_TYPE_MTTF"
	elseif fid_code == 0x0343 then code_name = "SYS_SET_SLOT_TYPE_MTTF"
	elseif fid_code == 0x0350 then code_name = "SMI_MSG_SYS_GET_TUNNEL_NOTE"
	elseif fid_code == 0x0351 then code_name = "SMI_MSG_SYS_SET_TUNNEL_NOTE"
	elseif fid_code == 0x0900 then code_name = "SYS_CMD_CHK_CLIENT"
	elseif fid_code == 0x100A then code_name = "SET_LINK_PORT"
	elseif fid_code == 0x100B then code_name = "GET_LINK_PORT"
	elseif fid_code == 0x100C then code_name = "DEL_LINK_PORT"
	elseif fid_code == 0x1004 then code_name = "GET_PORT_STATS"
	elseif fid_code == 0x1005 then code_name = "DEL_PORT_STATS"
	elseif fid_code == 0x1007 then code_name = "PORT_RESET"
	elseif fid_code == 0x1017 then code_name = "GET_RATE_LIMIT"
	elseif fid_code == 0x1018 then code_name = "SET_RATE_LIMIT"
	elseif fid_code == 0x1019 then code_name = "GET_STORM_CONTROL"
	elseif fid_code == 0x101A then code_name = "SET_STORM_CONTROL"
	elseif fid_code == 0x1020 then code_name = "PORT_GET_STATISTICS"
	elseif fid_code == 0x1021 then code_name = "PORT_INIT_STATISTICS"
	elseif fid_code == 0x1022 then code_name = "PORT_GET_TRAFFIC_THRES"
	elseif fid_code == 0x1023 then code_name = "PORT_SET_TRAFFIC_THRES"
	elseif fid_code == 0x1024 then code_name = "PORT_SET_ETH_DROP_THRES"
	elseif fid_code == 0x1025 then code_name = "PORT_GET_ETH_DROP_THRES"
	elseif fid_code == 0x1026 then code_name = "PORT_SET_ETH_DROP_EN"
	elseif fid_code == 0x1027 then code_name = "PORT_GET_ETH_DROP_EN"
	elseif fid_code == 0x3010 then code_name = "SET_AC_INTERFACE"
	elseif fid_code == 0x3011 then code_name = "GET_AC_INTERFACE"
	elseif fid_code == 0x3012 then code_name = "DEL_AC_INTERFACE"
	elseif fid_code == 0x3011 then code_name = "SET_SVC_TC_COS_PROFILE"
	elseif fid_code == 0x3012 then code_name = "GET_SVC_TC_COS_PROFILE"
	elseif fid_code == 0x3013 then code_name = "UNSET_SVC_TC_COS_PROFILE"
	elseif fid_code == 0x302E then code_name = "SET_MPLS_TUNNEL_LSP_CHANGE"
	elseif fid_code == 0x302F then code_name = "CMD_MPLS_TUNNEL"
	elseif fid_code == 0x3030 then code_name = "CMD_MPLS_TUNNEL_BY_PORT"
	elseif fid_code == 0x3035 then code_name = "SET_MPLS_TRANSIT_HOP_CHANGE"
	elseif fid_code == 0x3044 then code_name = "SET_PW_CONTROL_WORD"
	elseif fid_code == 0x3045 then code_name = "GET_PW_CONTROL_WORD"
	elseif fid_code == 0x3050 then code_name = "GET_MAC_FILTERING"
	elseif fid_code == 0x3051 then code_name = "SET_MAC_FILTERING"
	elseif fid_code == 0x3052 then code_name = "UNSET_MAC_FILTERING"
	elseif fid_code == 0x400A then code_name = "SET_PORT_OSPF_P2P_IP"
	elseif fid_code == 0x400B then code_name = "GET_PORT_OSPF_P2P_IP"
	elseif fid_code == 0x400C then code_name = "DEL_PORT_OSPF_P2P_IP"
	elseif fid_code == 0x4014 then code_name = "SET_OSPF_AREA"
	elseif fid_code == 0x4015 then code_name = "GET_OSPF_AREA"
	elseif fid_code == 0x4016 then code_name = "DEL_OSPF_AREA"
	elseif fid_code == 0x4017 then code_name = "SET_OSPF_IF"
	elseif fid_code == 0x4018 then code_name = "GET_OSPF_IF"
	elseif fid_code == 0x4019 then code_name = "DEL_OSPF_IF"
	elseif fid_code == 0x401b then code_name = "GET_DCC_STATUS"
	elseif fid_code == 0x401c then code_name = "SET_OSPF_IF_DEACTVATION"
	elseif fid_code == 0x401d then code_name = "UNSET_OSPF_IF_DEACTVATION"
	elseif fid_code == 0x401e then code_name = "GET_DCC_ROUTE_INFO"
	elseif fid_code == 0x5001 then code_name = "SET_STM_INTERFACE"
	elseif fid_code == 0x5002 then code_name = "GET_STM_INTERFACE"
	elseif fid_code == 0x5003 then code_name = "DEL_STM_INTERFACE"
	elseif fid_code == 0x5004 then code_name = "SET_TDM_AC_INTERFACE"
	elseif fid_code == 0x5005 then code_name = "GET_TDM_AC_INTERFACE"
	elseif fid_code == 0x5006 then code_name = "DEL_TDM_AC_INTERFACE"
	elseif fid_code == 0x5007 then code_name = "SET_TDM_PW_INTERFACE"
	elseif fid_code == 0x5008 then code_name = "GET_TDM_PW_INTERFACE"
	elseif fid_code == 0x5009 then code_name = "DEL_TDM_PW_INTERFACE"
	elseif fid_code == 0x500A then code_name = "SET_STM_MUX"
	elseif fid_code == 0x500B then code_name = "GET_STM_MUX"
	elseif fid_code == 0x500C then code_name = "DEL_STM_MUX"
	elseif fid_code == 0x500D then code_name = "GET_STM_TRAIL_MSG"
	elseif fid_code == 0x5101 then code_name = "SET_PDH_INTERFACE"
	elseif fid_code == 0x5102 then code_name = "GET_PDH_INTERFACE"
	elseif fid_code == 0x5103 then code_name = "DEL_PDH_INTERFACE"
	elseif fid_code == 0x5104 then code_name = "SET_PDH_TDM_AC_INTERFACE"
	elseif fid_code == 0x5105 then code_name = "GET_PDH_TDM_AC_INTERFACE"
	elseif fid_code == 0x5106 then code_name = "DEL_PDH_TDM_AC_INTERFACE"
	elseif fid_code == 0x5107 then code_name = "SET_PDH_TDM_PW_INTERFACE"
	elseif fid_code == 0x5108 then code_name = "GET_PDH_TDM_PW_INTERFACE"
	elseif fid_code == 0x5109 then code_name = "DEL_PDH_TDM_PW_INTERFACE"
	elseif fid_code == 0x510F then code_name = "GET_PDH_ACR_STAT"
	elseif fid_code == 0x5201 then code_name = "SET_CHANNEL_SLOT"
	elseif fid_code == 0x5202 then code_name = "GET_CHANNEL_SLOT"
	elseif fid_code == 0x5203 then code_name = "SET_ANALOG_PORT"
	elseif fid_code == 0x5204 then code_name = "GET_ANALOG_PORT"
	elseif fid_code == 0x5205 then code_name = "SET_DIGITAL_PORT"
	elseif fid_code == 0x5206 then code_name = "GET_DIGITAL_PORT"
	elseif fid_code == 0x5207 then code_name = "SET_DS0_ANALOG_TEST_TONE"
	elseif fid_code == 0x5208 then code_name = "GET_DS0_ANALOG_TEST_TONE"
	elseif fid_code == 0x5209 then code_name = "SET_DS0_ANALOG_MAKE_BUSY"
	elseif fid_code == 0x520A then code_name = "GET_DS0_ANALOG_MAKE_BUSY"
	elseif fid_code == 0x520B then code_name = "SET_DS0_LOOP_BACK"
	elseif fid_code == 0x520C then code_name = "GET_DS0_LOOP_BACK"
	elseif fid_code == 0x520D then code_name = "SET_DS0_TEST_PATTERN_GEN"
	elseif fid_code == 0x520E then code_name = "GET_DS0_TEST_PATTERN_GEN"
	elseif fid_code == 0x520F then code_name = "SET_DS0_CLOCK_CONFIG"
	elseif fid_code == 0x5210 then code_name = "GET_DS0_CLOCK_CONFIG"
	elseif fid_code == 0x5211 then code_name = "GET_DS0_CLOCK_STATUS"
	elseif fid_code == 0x5212 then code_name = "GET_INVENTORY_STATUS"
	elseif fid_code == 0x5213 then code_name = "GET_HW_INFO_STATUS"
	elseif fid_code == 0x5214 then code_name = "GET_CU_SLOT_ALARM_STATUS"
	elseif fid_code == 0x5215 then code_name = "GET_CU_SLOT_OPER_STATUS"
	elseif fid_code == 0x5216 then code_name = "GET_CU_PORT_OPER_STATUS"
	elseif fid_code == 0x2010 then code_name = "SET_MAC_LIMIT_PROFILE"
	elseif fid_code == 0x2011 then code_name = "GET_MAC_LIMIT_PROFILE"
	elseif fid_code == 0x2012 then code_name = "DEL_MAC_LIMIT_PROFILE"
	elseif fid_code == 0x2113 then code_name = "SET_LOADBALANCE"
	elseif fid_code == 0x2114 then code_name = "GET_LOADBALANCE"
	elseif fid_code == 0x2115 then code_name = "DEL_LOADBALANCE"
	elseif fid_code == 0x2116 then code_name = "SET_LAG"
	elseif fid_code == 0x2117 then code_name = "GET_LAG"
	elseif fid_code == 0x2118 then code_name = "DEL_LAG"
	elseif fid_code == 0x2119 then code_name = "SET_MIRROR"
	elseif fid_code == 0x212A then code_name = "GET_MIRROR"
	elseif fid_code == 0x212B then code_name = "DEL_MIRROR"
	elseif fid_code == 0x212C then code_name = "GET_MIRROR_CE7320"
	elseif fid_code == 0x2014 then code_name = "SET_TPID_PROFILE"
	elseif fid_code == 0x2015 then code_name = "GET_TPID_PROFILE"
	elseif fid_code == 0x2016 then code_name = "UNSET_TPID_PROFILE"
	elseif fid_code == 0x2018 then code_name = "SET_SVC_VLANEDIT"
	elseif fid_code == 0x2019 then code_name = "GET_SVC_VLANEDIT"
	elseif fid_code == 0x201A then code_name = "UNSET_SVC_VLANEDIT"
	elseif fid_code == 0x201C then code_name = "SET_PW_TPID_PROFILE"
	elseif fid_code == 0x201D then code_name = "GET_PW_TPID_PROFILE"
	elseif fid_code == 0x201E then code_name = "UNSET_PW_TPID_PROFILE"
	elseif fid_code == 0x2109 then code_name = "GET_SYS_LACP_STATUS"
	elseif fid_code == 0x2110 then code_name = "SET_SYS_LACP_PRIORITY"
	elseif fid_code == 0x2111 then code_name = "UNSET_SYS_LACP_PRIORITY"
	elseif fid_code == 0x2112 then code_name = "GET_SYS_LACP_PRIORITY"
	elseif fid_code == 0x2130 then code_name = "SET_ACL"
	elseif fid_code == 0x2131 then code_name = "GET_ACL"
	elseif fid_code == 0x2132 then code_name = "UNSET_ACL"
	elseif fid_code == 0x2133 then code_name = "SET_ACL_FPGA"
	elseif fid_code == 0x2134 then code_name = "GET_ACL_FPGA"
	elseif fid_code == 0x2135 then code_name = "UNSET_ACL_FPGA"
	elseif fid_code == 0x2136 then code_name = "SET_LLDP_CONFIG"
	elseif fid_code == 0x2137 then code_name = "GET_LLDP_CONFIG"
	elseif fid_code == 0x2138 then code_name = "UNSET_LLDP_CONFIG"
	elseif fid_code == 0x2139 then code_name = "GET_LLDP_STATISTICS"
	elseif fid_code == 0x213A then code_name = "CLEAR_LLDP_STATISTICS"
	elseif fid_code == 0x213B then code_name = "SET_EFM"
	elseif fid_code == 0x213C then code_name = "GET_EFM"
	elseif fid_code == 0x213E then code_name = "GET_EFM_DETAIL"
	elseif fid_code == 0x213D then code_name = "GET_LLDP_REMOTE_STS"
	elseif fid_code == 0x2140 then code_name = "GET_SECURITY"
	elseif fid_code == 0x2141 then code_name = "SET_SECURITY"
	elseif fid_code == 0x2142 then code_name = "UNSET_SECURITY"
	elseif fid_code == 0x2143 then code_name = "SET_L2CP"
	elseif fid_code == 0x2144 then code_name = "GET_L2CP"
	elseif fid_code == 0x600A then code_name = "SET_CLOCK"
	elseif fid_code == 0x600B then code_name = "GET_CLOCK"
	elseif fid_code == 0x600C then code_name = "DEL_CLOCK"
	elseif fid_code == 0x600D then code_name = "CMD_CLOCK"
	elseif fid_code == 0x7301 then code_name = "OTN_SET_OTU_PORT_CFG"
	elseif fid_code == 0x7302 then code_name = "OTN_GET_OTU_PORT_CFG"
	elseif fid_code == 0x7303 then code_name = "OTN_SET_OTU_TTI_CFG"
	elseif fid_code == 0x7304 then code_name = "OTN_DEL_OTU_TTI_CFG"
	elseif fid_code == 0x7305 then code_name = "OTN_GET_OTU_TTI_CFG"
	elseif fid_code == 0x7306 then code_name = "OTN_SET_SDH_TTI_CFG"
	elseif fid_code == 0x7307 then code_name = "OTN_DEL_SDH_TTI_CFG"
	elseif fid_code == 0x7308 then code_name = "OTN_GET_SDH_TTI_CFG"
	elseif fid_code == 0x7309 then code_name = "OTN_GET_OTU_TTI_STATE"
	elseif fid_code == 0x730A then code_name = "OTN_GET_SDH_TTI_STATE"
	elseif fid_code == 0x730B then code_name = "OTN_CMD_OTU_LOOPBACK"
	elseif fid_code == 0x730C then code_name = "OTN_GET_OTU_LOOPBACK"
	elseif fid_code == 0x730D then code_name = "OTN_GET_OTU_TS_MAP_STATE"
	elseif fid_code == 0x730E then code_name = "OTN_SET_OTU_TS_MAP_STATE"
	elseif fid_code == 0x730F then code_name = "OTN_DEL_OTU_TS_MAP_STATE"
	elseif fid_code == 0x7310 then code_name = "OTN_SET_ODU_TRAIL_CFG"
	elseif fid_code == 0x7311 then code_name = "OTN_DEL_ODU_TRAIL_CFG"
	elseif fid_code == 0x7312 then code_name = "OTN_GET_ODU_TRAIL_CFG"
	elseif fid_code == 0x7313 then code_name = "OTN_ADD_ODU_BIND_SVC"
	elseif fid_code == 0x7314 then code_name = "OTN_DEL_ODU_BIND_SVC"
	elseif fid_code == 0x7315 then code_name = "OTN_GET_ODU_BIND_SVC"
	elseif fid_code == 0x7317 then code_name = "OTN_GET_WDM_BIND_XC"
	elseif fid_code == 0x7318 then code_name = "OTN_SET_WDM_BIND_XC"
	elseif fid_code == 0x7320 then code_name = "OTN_SET_ODU_TRAIL_PROTECTION_CFG"
	elseif fid_code == 0x7321 then code_name = "OTN_GET_ODU_TRAIL_PROTECTION_CFG"
	elseif fid_code == 0x7322 then code_name = "OTN_GET_ODU_TRAIL_PROTECTION_STAT"
	elseif fid_code == 0x7323 then code_name = "OTN_CMD_ODU_TRAIL_PROTECTION"
	elseif fid_code == 0x7325 then code_name = "OTN_CMD_ODU_TRAIL_LOOPBACK"
	elseif fid_code == 0x7326 then code_name = "OTN_GET_ODU_TRAIL_LOOPBACK"
	elseif fid_code == 0x7330 then code_name = "OTN_SET_ODU_TRAIL_TTI_CFG"
	elseif fid_code == 0x7331 then code_name = "OTN_DEL_ODU_TRAIL_TTI_CFG"
	elseif fid_code == 0x7332 then code_name = "OTN_GET_ODU_TRAIL_TTI_CFG"
	elseif fid_code == 0x7333 then code_name = "OTN_SET_ODU_TCM_TTI_CFG"
	elseif fid_code == 0x7334 then code_name = "OTN_DEL_ODU_TCM_TTI_CFG"
	elseif fid_code == 0x7335 then code_name = "OTN_GET_ODU_TCM_TTI_CFG"
	elseif fid_code == 0x7336 then code_name = "OTN_GET_ODU_TTI_STATE"
	elseif fid_code == 0x7337 then code_name = "OTN_GET_ODU_TCM_TTI_STATE"
	elseif fid_code == 0x7340 then code_name = "OTN_SET_ODU_XC_CFG"
	elseif fid_code == 0x7341 then code_name = "OTN_DEL_ODU_XC_CFG"
	elseif fid_code == 0x7342 then code_name = "OTN_GET_ODU_XC_CFG"
	elseif fid_code == 0x7350 then code_name = "OTN_SET_OTU_PM_THRESHOLD"
	elseif fid_code == 0x7351 then code_name = "OTN_GET_OTU_PM_THRESHOLD"
	elseif fid_code == 0x7352 then code_name = "OTN_SET_ODU_PM_THRESHOLD"
	elseif fid_code == 0x7353 then code_name = "OTN_GET_ODU_PM_THRESHOLD"
	elseif fid_code == 0x7354 then code_name = "OTN_SET_OTU_PM_MONITOR_ENABLE"
	elseif fid_code == 0x7355 then code_name = "OTN_GET_OTU_PM_MONITOR_ENABLE"
	elseif fid_code == 0x7356 then code_name = "OTN_CMD_ON_DEMAND_ODU_DM"
	elseif fid_code == 0x7357 then code_name = "OTN_GET_ON_DEMAND_ODU_DM"
	elseif fid_code == 0x8000 then code_name = "SMI_EVENT_SYS_MSG_ALARM"
	elseif fid_code == 0x8001 then code_name = "SMI_EVENT_SYS_MSG_TCA_REPORT"
	elseif fid_code == 0x8002 then code_name = "SMI_EVENT_SYS_MSG_SWITCH"
	elseif fid_code == 0x8003 then code_name = "SMI_EVENT_SYS_MSG_EVENT"
	elseif fid_code == 0x8004 then code_name = "SMI_EVENT_SYS_MSG_ETC_EVENT"
	elseif fid_code == 0x8005 then code_name = "SMI_EVENT_SYS_MSG_PM_REPORT"
	elseif fid_code == 0x8006 then code_name = "SMI_EVENT_SYS_MSG_CONFIG_CHANGE"
	elseif fid_code == 0x303F then code_name = "SET_PW_XCONNECT"
	elseif fid_code == 0x3040 then code_name = "GET_PW_XCONNECT"
	elseif fid_code == 0x3041 then code_name = "DEL_PW_XCONNECT"
	elseif fid_code == 0x3042 then code_name = "GET_PW_DEL_HISTORY"
	elseif fid_code == 0x3043 then code_name = "SET_PW_RECREATE"
	elseif fid_code == 0x304B then code_name = "GET_VPLS_MAC"
	elseif fid_code == 0x304C then code_name = "SET_VPLS_MAC"
	elseif fid_code == 0x304D then code_name = "DEL_VPLS_MAC"
	elseif fid_code == 0x304E then code_name = "CLR_VPLS_MAC"
	elseif fid_code == 0x3058 then code_name = "GET_TRK_CON_MIS"
	elseif fid_code == 0x3059 then code_name = "SET_TRK_CON_MIS"
	elseif fid_code == 0x305A then code_name = "UNSET_TRK_CON_MIS"
	elseif fid_code == 0x3065 then code_name = "SET_MPLS_IF_BW_THRESHOLD"
	elseif fid_code == 0x3066 then code_name = "GET_MPLS_IF_BW_THRESHOLD"
	elseif fid_code == 0x3067 then code_name = "DEL_MPLS_IF_BW_THRESHOLD"
	elseif fid_code == 0x306F then code_name = "SET_MPLS_TUNNEL_BW_THRESHOLD"
	elseif fid_code == 0x3070 then code_name = "GET_MPLS_TUNNEL_BW_THRESHOLD"
	elseif fid_code == 0x3071 then code_name = "DEL_MPLS_TUNNEL_BW_THRESHOLD"
	elseif fid_code == 0x3072 then code_name = "GET_MS_PW_DEL_HISTORY"
	elseif fid_code == 0x3073 then code_name = "SET_MS_PW_RECREATE"
	elseif fid_code == 0x3074 then code_name = "GET_OUT_VID"
	elseif fid_code == 0x3075 then code_name = "SET_OUT_VID"
	elseif fid_code == 0x3076 then code_name = "SET_CHANGE_SVC_LINK"
	elseif fid_code == 0x307A then code_name = "SET_SVC_REMARK_PROFILE"
	elseif fid_code == 0x307B then code_name = "GET_SVC_REMARK_PROFILE"
	elseif fid_code == 0x460D then code_name = "CMD_ON_DEMAND_OAM"
	elseif fid_code == 0x460E then code_name = "RESULT_ON_DEMAND_OAM"
	elseif fid_code == 0x460F then code_name = "CMD_ON_DEMAND_PW_OAM"
	elseif fid_code == 0x4610 then code_name = "RESULT_ON_DEMAND_PW_OAM"
	elseif fid_code == 0x4614 then code_name = "SET_PW_OAM"
	elseif fid_code == 0x4615 then code_name = "GET_PW_OAM"
	elseif fid_code == 0x4616 then code_name = "UNSET_PW_OAM"
	elseif fid_code == 0x461E then code_name = "SET_SERVICE_CFM"
	elseif fid_code == 0x461F then code_name = "GET_SERVICE_CFM"
	elseif fid_code == 0x4620 then code_name = "UNSET_SERVICE_CFM"
	elseif fid_code == 0x4628 then code_name = "SET_LINK_OAM"
	elseif fid_code == 0x4629 then code_name = "GET_LINK_OAM"
	elseif fid_code == 0x462a then code_name = "UNSET_LINK_OAM"
	elseif fid_code == 0x4632 then code_name = "SET_SECOND_LINK_OAM"
	elseif fid_code == 0x4633 then code_name = "GET_SECOND_LINK_OAM"
	elseif fid_code == 0x4634 then code_name = "UNSET_SECOND_LINK_OAM"
	elseif fid_code == 0x4635 then code_name = "SET_SERV_OAM_PROTECT_MODE"
	elseif fid_code == 0x4636 then code_name = "GET_SERV_OAM_PROTECT_MODE"
	elseif fid_code == 0x4637 then code_name = "UNSET_SERV_OAM_PROTECT_MODE"
	elseif fid_code == 0x4638 then code_name = "SET_SERV_OAM_PROTECT_CMD"
	elseif fid_code == 0x4639 then code_name = "GET_SERV_OAM_PROTECT_CMD"
	elseif fid_code == 0x463A then code_name = "UNSET_SERV_OAM_PROTECT_CMD"
	elseif fid_code == 0x463B then code_name = "SET_SERV_OAM_PROTECT_BY_PORT"
	elseif fid_code == 0x463C then code_name = "SET_SERV_MODE"
	elseif fid_code == 0x463D then code_name = "GET_SERV_MODE"
	elseif fid_code == 0x463E then code_name = "UNSET_SERV_MODE"
	elseif fid_code == 0x463F then code_name = "SET_SERV_SD_TAG_OPER"
	elseif fid_code == 0x4640 then code_name = "GET_SERV_SD_TAG_OPER"
	elseif fid_code == 0x4701 then code_name = "SET_PW_REDUNDANCY_GROUP"
	elseif fid_code == 0x4702 then code_name = "GET_PW_REDUNDANCY_GROUP"
	elseif fid_code == 0x4703 then code_name = "UNSET_PW_REDUNDANCY_GROUP"
	elseif fid_code == 0x4704 then code_name = "SET_PW_REDUN_SWITCH"
	elseif fid_code == 0x4705 then code_name = "GET_PW_REDUN_SWITCH"
	else   code_name = "Unknown" end

	local sys_name = get_sys_name(sys_code)
	if code_name == "Unknown" then
		if sys_name == "CE7200" or sys_name == "CE8300" or sys_name == "CE7300" then
			code_name1 = get_cot_cod_name(fid_code)
		else code_name2 = get_rot_cod_name(fid_code) end
		if code_name1 ~= "Unknown" then code_name = code_name1;
		elseif code_name2 ~= "Unknown" then code_name = code_name2;
		end
	end
	return code_name
end

function get_cot_cod_name(fid_code)
	local code_name = "Unknown"
	    if fid_code == 0x0041 then code_name = "SET_SW_UPDATE_INFO"
	elseif fid_code == 0x0050 then code_name = "GET_SYSTEM_CPU_INFO"
	elseif fid_code == 0x0051 then code_name = "SET_SYSTEM_CPU_THRESHOLD"
	elseif fid_code == 0x0060 then code_name = "GET_SYSTEM_MEMORY_INFO"
	elseif fid_code == 0x0061 then code_name = "SET_SYSTEM_MEMORY_THRESHOLD"
	elseif fid_code == 0x0070 then code_name = "GET_SYSTEM_FAN_INFO"
	elseif fid_code == 0x0071 then code_name = "SET_SYSTEM_FAN_OPER"
	elseif fid_code == 0x0080 then code_name = "GET_SYSTEM_TEMP_INFO"
	elseif fid_code == 0x0081 then code_name = "SET_SYSTEM_TEMPERATURE_OVER"
	elseif fid_code == 0x0093 then code_name = "GET_SYSTEM_ALARM_REPORT"
	elseif fid_code == 0x0094 then code_name = "DEL_SYSTEM_ALARM_REPORT"
	elseif fid_code == 0x0095 then code_name = "GET_SYSTEM_ALARM_HISTORY"
	elseif fid_code == 0x0096 then code_name = "DEL_SYSTEM_ALARM_HISTORY"
	elseif fid_code == 0x0097 then code_name = "GET_SYSTEM_ALARM_AUTO_REPORT"
	elseif fid_code == 0x3014 then code_name = "CE_7200_FID_SET_SVC_PROFILE"
	elseif fid_code == 0x3015 then code_name = "CE_7200_FID_GET_SVC_PROFILE"
	elseif fid_code == 0x3016 then code_name = "CE_7200_FID_DEL_SVC_PROFILE"	
	elseif fid_code == 0x3017 then code_name = "CE_7200_FID_SET_SVC_INTERFACE"
	elseif fid_code == 0x3018 then code_name = "CE_7200_FID_GET_SVC_INTERFACE"
	elseif fid_code == 0x3019 then code_name = "CE_7200_FID_DEL_SVC_INTERFACE"
	elseif fid_code == 0x301E then code_name = "CE_7200_FID_SET_MPLS_INTERFACE"
	elseif fid_code == 0x301F then code_name = "CE_7200_FID_GET_MPLS_INTERFACE"
	elseif fid_code == 0x3020 then code_name = "CE_7200_FID_DEL_MPLS_INTERFACE"
	elseif fid_code == 0x3028 then code_name = "CE_7200_FID_SET_MPLS_TUNNEL"
	elseif fid_code == 0x3029 then code_name = "CE_7200_FID_GET_MPLS_TUNNEL"
	elseif fid_code == 0x302A then code_name = "CE_7200_FID_DEL_MPLS_TUNNEL"
	elseif fid_code == 0x302B then code_name = "CE_7200_FID_SET_MPLS_TUNNEL_LSP"
	elseif fid_code == 0x302C then code_name = "CE_7200_FID_GET_MPLS_TUNNEL_LSP"
	elseif fid_code == 0x302D then code_name = "CE_7200_FID_DEL_MPLS_TUNNEL_LSP"
	elseif fid_code == 0x3032 then code_name = "CE_7200_FID_SET_MPLS_TRANSIT"
	elseif fid_code == 0x3033 then code_name = "CE_7200_FID_GET_MPLS_TRANSIT"
	elseif fid_code == 0x3034 then code_name = "CE_7200_FID_DEL_MPLS_TRANSIT"
	elseif fid_code == 0x303C then code_name = "CE_7200_FID_SET_PW_INTERFACE"
	elseif fid_code == 0x303D then code_name = "CE_7200_FID_GET_PW_INTERFACE"
	elseif fid_code == 0x303E then code_name = "CE_7200_FID_DEL_PW_INTERFACE"
	elseif fid_code == 0x3046 then code_name = "CE_7200_FID_SET_VPLS"
	elseif fid_code == 0x3047 then code_name = "CE_7200_FID_GET_VPLS"
	elseif fid_code == 0x3048 then code_name = "CE_7200_FID_DEL_VPLS"
	else   code_name = "Unknown" end
	return code_name
end

function get_rot_cod_name(fid_code)
	local code_name = "Unknown"
	    if fid_code == 0x0022 then code_name = "SMI_UT7400_MSG_SYS_GET_SYSTEM_ALARM_REPORT"
	elseif fid_code == 0x0023 then code_name = "SMI_UT7400_MSG_SYS_DEL_SYSTEM_ALARM_REPORT"
	elseif fid_code == 0x0024 then code_name = "SMI_UT7400_MSG_SYS_GET_SYSTEM_ALARM_HISTORY"
	elseif fid_code == 0x0025 then code_name = "SMI_UT7400_MSG_SYS_DEL_SYSTEM_ALARM_HISTORY"
	elseif fid_code == 0x1001 then code_name = "UT_7400_FID_SET_LINK_PORT"
	elseif fid_code == 0x1002 then code_name = "UT_7400_FID_GET_LINK_PORT"
	elseif fid_code == 0x1003 then code_name = "UT_7400_FID_DEL_LINK_PORT"
	elseif fid_code == 0x3014 then code_name = "SMI_7400_FID_SET_MPLS_INTERFACE"
	elseif fid_code == 0x3015 then code_name = "SMI_7400_FID_GET_MPLS_INTERFACE"
	elseif fid_code == 0x3016 then code_name = "SMI_7400_FID_DEL_MPLS_INTERFACE"
	elseif fid_code == 0x3017 then code_name = "SMI_U7400_FID_SET_SVC_PROFILE"
	elseif fid_code == 0x3018 then code_name = "SMI_U7400_FID_GET_SVC_PROFILE"
	elseif fid_code == 0x3019 then code_name = "SMI_U7400_FID_DEL_SVC_PROFILE"
	elseif fid_code == 0x301A then code_name = "SMI_U7400_FID_SET_SVC_INTERFACE"
	elseif fid_code == 0x301B then code_name = "SMI_U7400_FID_GET_SVC_INTERFACE"
	elseif fid_code == 0x301C then code_name = "SMI_U7400_FID_DEL_SVC_INTERFACE"
	elseif fid_code == 0x301E then code_name = "SMI_7400_FID_SET_MPLS_TUNNEL"
	elseif fid_code == 0x301F then code_name = "SMI_7400_FID_GET_MPLS_TUNNEL"
	elseif fid_code == 0x3020 then code_name = "SMI_7400_FID_DEL_MPLS_TUNNEL"
	elseif fid_code == 0x3021 then code_name = "SMI_7400_FID_SET_MPLS_TUNNEL_LSP"
	elseif fid_code == 0x3022 then code_name = "SMI_7400_FID_GET_MPLS_TUNNEL_LSP"
	elseif fid_code == 0x3023 then code_name = "SMI_7400_FID_DEL_MPLS_TUNNEL_LSP"
	elseif fid_code == 0x3028 then code_name = "SMI_U7400_FID_SET_MPLS_TRANSIT"
	elseif fid_code == 0x3029 then code_name = "SMI_U7400_FID_GET_MPLS_TRANSIT"
	elseif fid_code == 0x302A then code_name = "SMI_U7400_FID_DEL_MPLS_TRANSIT"
	elseif fid_code == 0x3032 then code_name = "SMI_U7400_FID_SET_PW_INTERFACE"
	elseif fid_code == 0x3033 then code_name = "SMI_U7400_FID_GET_PW_INTERFACE"
	elseif fid_code == 0x3034 then code_name = "SMI_U7400_FID_DEL_PW_INTERFACE"
	elseif fid_code == 0x3060 then code_name = "SMI_U7400_FID_SET_VPLS"
	elseif fid_code == 0x3061 then code_name = "SMI_U7400_FID_GET_VPLS"
	elseif fid_code == 0x3062 then code_name = "SMI_U7400_FID_DEL_VPLS"
	elseif fid_code == 0x3010 then code_name = "SMI_U7400_FID_SET_AC_INTERFACE"
	elseif fid_code == 0x3011 then code_name = "SMI_U7400_FID_GET_AC_INTERFACE"
	elseif fid_code == 0x3012 then code_name = "SMI_U7400_FID_DEL_AC_INTERFACE"
	elseif fid_code == 0x3070 then code_name = "SMI_U7400_FID_SET_MAC_LIMIT_PROFILE"
	elseif fid_code == 0x3071 then code_name = "SMI_U7400_FID_GET_MAC_LIMIT_PROFILE"
	elseif fid_code == 0x3072 then code_name = "SMI_U7400_FID_DEL_MAC_LIMIT_PROFILE"
	elseif fid_code == 0x0040 then code_name = "UT_7400_SMI_MSG_SYS_SW_UPDATE_OPEN"
	elseif fid_code == 0x0041 then code_name = "UT_7400_SMI_MSG_SYS_SW_UPDATE_WRITE"
	elseif fid_code == 0x0042 then code_name = "UT_7400_SMI_MSG_SYS_SW_UPDATE_CLOSE"
	elseif fid_code == 0x004B then code_name = "UT_7400_SMI_MSG_SYS_SW_PROV_BACKUP"
	elseif fid_code == 0x004C then code_name = "UT_7400_SMI_MSG_SYS_SW_PROV_RESTORE"
	else   code_name = "Unknown" end
	return code_name
end

function get_sys_name(sys)
  local sys_name = "Unknown"
      if sys == 0x00 then sys_name = "EMS   "
  elseif sys == 0x01 then sys_name = "WCU   "
  elseif sys == 0x02 then sys_name = "CCU   "
  elseif sys == 0x03 then sys_name = "RCU   "
  elseif sys == 0x04 then sys_name = "SROADM"
  elseif sys == 0x05 then sys_name = "PSEUDO"
  elseif sys == 0x06 then sys_name = "POINTS"
  elseif sys == 0x07 then sys_name = "CE7200"
  elseif sys == 0x08 then sys_name = "CE7300"
  elseif sys == 0x09 then sys_name = "CE7400"
  elseif sys == 0x07 then sys_name = "UT7200"
  elseif sys == 0x08 then sys_name = "UT7300"
  elseif sys == 0x09 then sys_name = "UT7400"
  elseif sys == 0x0A then sys_name = "CE7300"
  elseif sys == 0x0B then sys_name = "CE7400"
  elseif sys == 0x0C then sys_name = "CE73K0"
  elseif sys == 0x0D then sys_name = "CE7300"
  elseif sys == 0x0E then sys_name = "CE7510"
  elseif sys == 0x0F then sys_name = "CE7533"
  elseif sys == 0x10 then sys_name = "CE7511"
  elseif sys == 0x11 then sys_name = "CE7534"
  elseif sys == 0x12 then sys_name = "CE7515"
  elseif sys == 0x13 then sys_name = "ACCESS"
  elseif sys == 0x14 then sys_name = "CE7611"
  elseif sys == 0x15 then sys_name = "CE7610"
  elseif sys == 0x16 then sys_name = "CE8300"
  elseif sys == 0x16 then sys_name = "UT8300"
  elseif sys == 0x17 then sys_name = "CE9200"
  elseif sys == 0x17 then sys_name = "UT9200"
  elseif sys == 0x18 then sys_name = "CE740E"
  elseif sys == 0x18 then sys_name = "UT740E"
  elseif sys == 0x19 then sys_name = "CE5100"
  elseif sys == 0x19 then sys_name = "UT5100"
  elseif sys == 0x1A then sys_name = "CE5200"
  elseif sys == 0x1A then sys_name = "UT5200"
  elseif sys == 0x1B then sys_name = "CE5300"
  elseif sys == 0x1B then sys_name = "UT5300"
  elseif sys == 0x1C then sys_name = "CE5400"
  elseif sys == 0x1C then sys_name = "UT5400"
  elseif sys == 0x1D then sys_name = "CE5500"
  elseif sys == 0x1D then sys_name = "UT5500"
  elseif sys == 0x1E then sys_name = "CE9000"
  elseif sys == 0x1E then sys_name = "UT9000"
  elseif sys == 0x1F then sys_name = "CE9100"
  elseif sys == 0x1F then sys_name = "UT9100"
  elseif sys == 0x20 then sys_name = "CE1830"
  elseif sys == 0x20 then sys_name = "UT1830"
  elseif sys == 0x21 then sys_name = "CE9300"
  elseif sys == 0x21 then sys_name = "UT9300"
  elseif sys == 0x22 then sys_name = "CE9400"
  elseif sys == 0x22 then sys_name = "UT9400"
  elseif sys == 0x23 then sys_name = "CE9500"
  elseif sys == 0x23 then sys_name = "UT9500"
  elseif sys == 0x24 then sys_name = "MAX   " end
  return sys_name
end

function get_flag_description(flags)
  local flags_description = "Unknown"

      if flags == 0 then flags_description = "Reserved"
  elseif flags == 1 then flags_description = "TailableCursor"
  elseif flags == 2 then flags_description = "SlaveOk.Allow"
  elseif flags == 3 then flags_description = "OplogReplay"
  elseif flags == 4 then flags_description = "NoCursorTimeout"
  elseif flags == 5 then flags_description = "AwaitData"
  elseif flags == 6 then flags_description = "Exhaust"
  elseif flags == 7 then flags_description = "Partial"
  elseif 8 <= flags and flags <= 31 then flags_description = "Reserved" end

  return flags_description
end

function get_response_flag_description(flags)
  local flags_description = "Unknown"

      if flags == 0 then flags_description = "CursorNotFound"
  elseif flags == 1 then flags_description = "QueryFailure"
  elseif flags == 2 then flags_description = "ShardConfigStale"
  elseif flags == 3 then flags_description = "AwaitCapable"
  elseif 4 <= flags and flags <= 31 then flags_description = "Reserved" end

  return flags_description
end

local tcp_port = DissectorTable.get("tcp.port")
tcp_port:add(3408, ptnems_protocol)
