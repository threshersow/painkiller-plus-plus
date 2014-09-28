--==========================================================================
-- NETWORK COMMUNICATION
--==========================================================================
Network = {
	_cntRegisteredMethods = 0,
	_cntRegisteredMethodParams = 0,
}

NCallOn = {
	Server                = 1,
	SingleClient          = 2,
	AllClients            = 3, -- w przypadku dedicated server, nie odpala sie na serwerze
	ServerAndSingleClient = 4,
	ServerAndAllClients   = 5,
}

NMode = {
	Unreliable        = 0,
	Reliable          = 1,
	ReliableForSingle = 2,
}
Network.SortedMethods = {}

PK_NETVERSION = "0.0"

-- Arg types:
-- e - entity (by index)
-- s - string with '\0'
-- c - char
-- b - byte
-- B - bool
-- u - unsigned short
-- i - int
-- f - float
-- ? - unknown ... first string is a params info
-- x - how many arg packs (max 255)

Network.mt = {}
Network.mt.__call = function(tbl,...)

	if Game.GMode == GModes.SingleGame then
		if tbl[4] == NMode.ReliableForSingle or tbl[3] == NCallOn.SingleClient or tbl[3] == NCallOn.ServerAndSingleClient then
			table.remove(arg,1)
		end
		tbl[6](nil,unpack(arg))
		return
	end

	local reliable = true
	if tbl[4] == NMode.Unreliable then reliable = false end

	if tbl[3] == NCallOn.Server then
		--Game:Print("NCallOn.Server")
		if Game.GMode == GModes.MultiplayerServer or Game.GMode == GModes.DedicatedServer then
			tbl[6](nil,unpack(arg))
		else
			SendNetMethod(tbl,ServerID,true,reliable,unpack(arg))
		end
		return
	end

	if tbl[3] == NCallOn.AllClients then
		--Game:Print("NCallOn.AllClients")
		local cID = nil
		if tbl[4] == NMode.ReliableForSingle then
			reliable = true
			cID = arg[1]
			table.remove(arg,1)
		end
		SendNetMethod(tbl,cID,false,reliable,unpack(arg))
		if Game.GMode == GModes.MultiplayerServer then
			tbl[6](nil,unpack(arg))
		end
		return
	end

	if tbl[3] == NCallOn.ServerAndAllClients then
		--Game:Print("NCallOn.ServerAndAllClients")
		local cID = nil
		if tbl[4] == NMode.ReliableForSingle then
			reliable = true
			cID = arg[1]
			table.remove(arg,1)
		end

		SendNetMethod(tbl,cID,false,reliable,unpack(arg))

		if Game.GMode == GModes.MultiplayerServer or Game.GMode == GModes.DedicatedServer then
			tbl[6](nil,unpack(arg))
		end
		return
	end

	if tbl[3] == NCallOn.SingleClient then
		--Game:Print("NCallOn.SingleClient")
		local cID = arg[1]
		table.remove(arg,1)
		if Game.GMode == GModes.MultiplayerServer and cID == ServerID then
			tbl[6](nil,unpack(arg))
		else
			SendNetMethod(tbl,cID,true,reliable,unpack(arg))
		end
		return
	end

	if tbl[3] == NCallOn.ServerAndSingleClient then
		--Game:Print("NCallOn.ServerAndSingleClient")
		local cID = arg[1]
		table.remove(arg,1)
		if Game.GMode == GModes.MultiplayerServer and cID == ServerID then
			tbl[6](nil,unpack(arg))
		else
			SendNetMethod(tbl,cID,reliable,true,unpack(arg))
			tbl[6](nil,unpack(arg))
		end
		return
	end

end
------------------------------------------------------------------------------
function RawCallMethod(tbl,...)
	tbl[6](nil,unpack(arg))
end
------------------------------------------------------------------------------
function Network:RegisterMethod(name,sendto,mode,args)
	local i2,o2
	for i2,o2 in Network.SortedMethods do
		if o2[2] == name then
			Game:Print("Network method: '"..name.."' is already registered!!!")
			table.remove(Network.SortedMethods,i2)
			--return
		end
	end

	dostring("tmpfunc = "..name)
	for i2,o2 in Network.SortedMethods do
		if o2[2] == name then
			EDITOR.OutputText(name.." - already registered")
			table.remove(Network.SortedMethods,i2)
			--return
		end -- already registered
	end

	tmptbl = {0,name,sendto,mode,args,tmpfunc}

	--EDITOR.OutputText("RegisterMethod: "..name)
	table.insert(Network.SortedMethods,tmptbl)
	table.sort(Network.SortedMethods,function (a,b) return a[2] < b[2] end)

	--EDITOR.OutputText("Sorted: "..name)
	for i2,o2 in Network.SortedMethods do
		--EDITOR.OutputText(i2.." - "..Network.SortedMethods[i2][2])
		o2[1] = i2
	end
	self._cntRegisteredMethods = table.getn(self.SortedMethods)
	--self._cntRegisteredMethodParams = self._cntRegisteredMethodParams + string.len(args)
	self._cntRegisteredMethodParams = 0
	for i5,v5 in Network.SortedMethods do
		if v5[5] then
			self._cntRegisteredMethodParams = self._cntRegisteredMethodParams + string.len(v5[5])
		end
	end

	PK_NETVERSION = tostring(Network._cntRegisteredMethods).."."..tostring(Network._cntRegisteredMethodParams)

	--EDITOR.OutputText("PK_VERSION: "..PK_VERSION)
	--EDITOR.OutputText("PK_NETVERSION: "..PK_NETVERSION)
	--MsgBox(Network.SortedMethods[1][1])

	dostring(name .. " = tmptbl")
	dostring("setmetatable("..name..",Network.mt)")

	tmpfunc = nil
	tmptbl = nil
end
msgnr = 0
------------------------------------------------------------------------------
function SendNetMethod(event,clientID,singleClient,reliable,...)

	local msg = NET.MsgCreate()
	--MsgBox(event[2])
	--if event[1] ~= 31 and event[1] ~= 32 then
	--    Game:Print("* SendNetEvent: "..event[1].." - "..event[2])
	--end

	NET.MsgWriteVar(msg,"b",event[1]) -- uin

	local is = 1
	local ia = 1
	local howmanyargspacks = 1
	local params = event[5]
	--if string.sub(params,1,1) == "?" then params = arg[1]; is = 2; an = 2 end
	if string.sub(params,1,1) == "x" then
		howmanyargspacks = arg[1]
		is = 2
		ia = 2
		NET.MsgWriteVar(msg,"b",howmanyargspacks)
	end

	for h=1,howmanyargspacks do
		for i=is,string.len(params) do
			--Game:Print(string.sub(params,i,i))
			NET.MsgWriteVar(msg,string.sub(params,i,i),arg[ia])
			ia = ia + 1
		end
	end

	--if reliable then Game:Print(event[2]) end

	NET.MsgSend(msg,reliable,singleClient,clientID)
	msgnr = msgnr +1
end
------------------------------------------------------------------------------
function GetNetEvent(msg,clientID)
	local euin = NET.MsgReadVar(msg,"b")
	local event = Network.SortedMethods[euin]
	if not event then
		if euin then
			Game:Print("Illegal network method:"..euin)
		else
			Game:Print("Illegal network method: ???")
		end
		return
	end

	local params = event[5]
	local is = 1
	local ia = 1
	local howmanyargspacks = 1
	local args = {}

	if string.sub(params,1,1) == "x" then
		howmanyargspacks = NET.MsgReadVar(msg,"b")
		args[1] = howmanyargspacks
		is = 2
		ia = 2
	end

	for h=1, howmanyargspacks do
		for i=is,string.len(params) do
			--Game:Print(string.sub(params,i,i))
			args[ia] = NET.MsgReadVar(msg,string.sub(params,i,i))
			ia = ia + 1
		end
	end
	table.setn(args,ia-1) -- wymagane, inaczej przy nil'ach konczyl unpack'a
	
	-- DEBUG TESTING
	--Game:Print("* GetNetEvent: After Decompose")
	--	local a1 = INP.GetTimeFromTimerReset()		-- ###Marek, test szybkosci dzialania funkcji
	--CONSOLE_AddMessage(tostring(event[2]))
	
	-- IGNORE TELEPORT CONFIRMATION
	if (tostring(event[2]) == "Teleport.MovePlayer") then  return end
	
	event[6](nil,unpack(args))
	--    local a2 = INP.GetTimeFromTimerReset()
end
--============================================================================
