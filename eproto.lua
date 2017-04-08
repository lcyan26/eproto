--
-- Created by IntelliJ IDEA.
-- User: AppleTree
-- Date: 17/1/15
-- Time: 下午10:32
-- To change this template use File | Settings | File Templates.
--

local eproto_cpp = require("eproto_cpp")
local print = print
local class = require("class")

--[[
#define PROTO_TYPE_LUA_TABLE 0
#define PROTO_TYPE_PROTO_TABLE 1
#define PROTO_TYPE_PROTO_ARRAY 2
#define PROTO_TYPE_ELEMENT 3

local proto1 = {
	[1] = "key1";
	[2] = "key2";
}
local proto2 = {
	[1] = "key3";
	[2] = "key4";
	[3] = {eproto.proto_table, "key5", "proto1"};
}
eproto.register("proto1", proto1)
eproto.register("proto2", proto2)
--]]

local eproto = class("eproto")

eproto.lua_table 	= 0		-- could be a lua table or array, or normal lua datas (string,number,boolean)
eproto.proto_table 	= 1		-- another proto message
eproto.proto_array 	= 2		-- aonther proto message array
eproto.element 		= 3		-- normal element of lua type, could be string/boolean/number/table

local eproto_infos = eproto.infos or {}
eproto.infos = eproto_infos
local eproto_ids = eproto.ids or {}
eproto.ids = eproto_ids

local function merge_info(info, oldInfo)
	if oldInfo == nil then
		return info
	end
	for k=1,#info do
		if oldInfo[k] == nil then
			oldInfo[k] = info[k]
		end
	end
	return oldInfo
end

function eproto.register(name, info)
	info = merge_info(info, eproto_infos[name])
	eproto_infos[name] = info
	local id = eproto_cpp.proto(name, info)
	eproto_ids[name] = id
	print("eproto.register", name, id)
	return id
end

function eproto.info(name)
	return eproto_infos[name]
end
function eproto.id(name)
	return eproto_ids[name]
end

function eproto.checkProtoID(name)
	local id = eproto_ids[name]
	if id == nil then
		id = eproto_cpp.protoID(name)
		if id == 0 then
			return
		end
		eproto_ids[name] = id
	end
	return id
end

function eproto.encode(name, data)
	local id = eproto.checkProtoID(name)
	if id ~= nil then
		return eproto_cpp.encode(id, data)
	else
		print("eproto.encode not found", name)
	end
end
function eproto.decode(name, data)
	local id = eproto.checkProtoID(name)
	if id ~= nil then
		return eproto_cpp.decode(id, data)
	else
		print("eproto.decode not found", name)
	end
end

return eproto

