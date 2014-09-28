--============================================================================
-- Base game object class
--============================================================================
-- dorobic flagi czy tick/update ma byc wywolywany dla obiektow
CObject = 
{
    Pos = Vector:New(0,0,0),
    Visible = true,
    BaseObj = "", -- Ancestor
    Actions = {
        OnPlay = {},
        --OnLaunch = {},
        OnKill   = {},
    },
    --_Timers = {}, -- {func,interval,timer}
    _ToKill = false,
    _Entity = nil, -- Entity C++ pointer
    _Class = "CObject",
    _Name = "NoName",
    s_Editor = {
    },
}
-- prefixy:
-- _   tymczasowe, nie do zapisu
-- r_  referencja do innego obiektu - zapisywana jest tylko nazwa obiektu
-- s_  static, statyczna tablica nie kopiowana do dziecka przy klonowaniu
--============================================================================
--function CObject:AfterLoad()
--end
--============================================================================
--function CObject:LoadData()
--end
--============================================================================
--function CObject:Delete()
--end
--============================================================================
function CObject:Apply(old)
end
--============================================================================
--function CObject:Is(class)
--    if self._Class == class then return true else return false end
--end
--============================================================================
--function CObject:Update()
--end
--============================================================================
--function CObject:Tick(delta)
--end
--============================================================================
--function CObject:Render(delta)
--end
--============================================================================
--function CObject:Synchronize()
--end
--============================================================================
function CObject:PO_Create(bodytype,scale,collisiongroup)
    if not ENTITY.PO_Exist(self._Entity) then
        if not scale then scale = -1  end
        ENTITY.SetPosition(self._Entity,self.Pos.X,self.Pos.Y,self.Pos.Z)
        self.Rot:ToEntity(self._Entity)
        ENTITY.PO_Create(self._Entity,bodytype,scale,collisiongroup)
        if self.Restitution then  ENTITY.PO_SetRestitution(self._Entity,self.Restitution) end
        if self.Mass then  ENTITY.PO_SetMass(self._Entity,self.Mass) end        
        if self.Softness then 
            ENTITY.PO_SetFreedomOfRotation(self._Entity,4,self.Softness)        
        else
            ENTITY.PO_SetFreedomOfRotation(self._Entity,3)
        end
        if self.Mass then ENTITY.PO_SetMass(self._Entity,self.Mass) end
        if self.Restitution then ENTITY.PO_SetRestitution(self._Entity,self.Restitution) end
        if self._Class == "CItem" then
			ENTITY.PO_SetFriction(self._Entity,1)
		end
        if self.Friction then ENTITY.PO_SetFriction(self._Entity,self.Friction) end
        if self.LinearDamping then ENTITY.PO_SetLinearDamping(self._Entity,self.LinearDamping) end
        if self.AngularDamping then ENTITY.PO_SetAngularDamping(self._Entity,self.AngularDamping) end
        if self.Pinned then 
            -- bug havoka
            ENTITY.PO_SetPinned(self._Entity,true)
            ENTITY.PO_Activate(self._Entity,true)
        end
    end
    ENTITY.PO_Activate(self._Entity,true)
end
--============================================================================
function CObject:AddTimer(funcname,interval)
	if not self._Timers then
		self._Timers = {}
	end

    table.insert(self._Timers, {funcname,interval,0,self[funcname]})
    if self ~= Lev then AddObjToTable(GObjects.TimerList,self) end
end
--============================================================================
function CObject:RemoveTimer(funcname)
	if self._Timers then
		for i,v in self._Timers do
			if v[1] == funcname then
				table.remove(self._Timers,i)
				break
			end
		end
	end
end
--============================================================================
function CObject:ReleaseTimers()
    self._Timers = nil
end
--============================================================================
function CObject:TickTimers(delta)
	if not self._Timers then return end

	for i,v in self._Timers do
        v[3] = v[3] + delta
        local cnt = math.floor(v[3]/v[2])
        --Game:Print(cnt)
		while cnt > 0 do
            v[4](self,delta)
            cnt = cnt - 1
            --Game:Print("tick")
            if self._ToKill or (not self._Timers or table.getn(self._Timers) == 0) then break end

            v[3] = v[3] - v[2]
		end                
	end   
end
--============================================================================
function CObject:InDeathZone()
    Game:Print("InDeathZone: "..self._Name)
end
--============================================================================
--function CObject:FlipZ()
--    if self.Pos then self.Pos.Z = -self.Pos.Z end
--end
--============================================================================
--[[GetProxy = 
{
    Position = function (obj) 
        MsgBox("get")
        if obj._Entity then 
            local x,y,z = ENTITY.GetPosition(obj._Entity)
            return {X=x,X=y,Z=z}
        end
        return obj.Pos 
    end
}
--============================================================================
SetProxy = 
{
    Position = function (obj) 
        MsgBox("set")
        if obj._Entity then 
            local x,y,z = ENTITY.GetPosition(obj._Entity)
            return {X=x,X=y,Z=z}
        end
        return obj.Pos 
    end
}
--============================================================================
function GetObjIndex(obj,field) 
    local func = GetProxy[field]
    if func then return func(obj) end
    return nil
end
--============================================================================
function SetObjIndex(obj,field) 
    local func = GetProxy[field]
    if func then return func(obj) end
    return nil
end--]]
--============================================================================
--setmetatable(CObject,{__index=GetObjIndex,__newindex=SetObjIndex}) 

--CObject.__newindex = SetObjIndex
--MsgBox(CObject.Position.Y)
----CObject.Position = 10
--MsgBox(CObject.Position.Y)
--============================================================================
function AddObject(template,scale,pos,rot,collect)
    local obj = template
    if type(obj) == "string" then obj = CloneTemplate(template) end
    if scale and obj.Scale then obj.Scale = obj.Scale * scale end
    if scale and obj.Size then obj.Size = obj.Size * scale end
    if pos then obj.Pos:Set(pos) end
    if rot then obj.Rot = Clone(rot) end
    if obj.Apply then
        obj:Apply()
    end
    obj._dontFirstApply = true
    if not collect and obj._Entity then
        EntityToObject[obj._Entity] = nil        
    else
        GObjects:Add(TempObjName(),obj)
    end
    return obj, obj._Entity
end
--============================================================================
function CObject:BindSound(soundname,fstart,fend,looped,joint,ox,oy,oz,doNotAutodelete,disablePitch)
    local snd, idx = ENTITY.Create(ETypes.Sound)
    if ox then ENTITY.SetPosition(snd,ox,oy,oz) end    
    WORLD.AddEntity(snd)
    if joint and type(joint) == "string" then
		joint = MDL.GetJointIndex(self._Entity, joint)
    end
    ENTITY.RegisterChild(self._Entity,snd,true,joint)
    local interval = 0
    if not looped then interval = -1 end 
    
    SND.Setup3D(snd,soundname,fstart,fend,interval,nil,doNotAutodelete)
    SND.Play(snd)
    if disablePitch then
        local snd = SND.GetSound3DPtr(snd)
        SOUND3D.DisableRandomize(snd)
    end
    return snd, idx
end
--============================================================================
function CObject:LaunchAction(tbl,...)
	if not tbl then return end
    if table.getn(tbl) == 0 then return end
    local action = {}    
    for i,v in tbl do
        table.insert(action,{v})
    end
    AddAction(action,self,nil,unpack(arg))
end
--============================================================================
function CObject:BindToObject(parent,jointname)
    ENTITY.PO_Remove(self._Entity)
    local joint = MDL.GetJointIndex(parent._Entity,jointname)
    ENTITY.ComputeChildMatrix(self._Entity,parent._Entity,joint)
    ENTITY.RegisterChild(parent._Entity,self._Entity,true,joint)    
    GObjects:ToKill(self,true)
end
--============================================================================
function CObject:GetSndInfo(sndID,onlyName,stereo)
    
    if not self.s_SubClass.SoundsDefinitions then return sndId end
    
    local path = self.s_SubClass.SoundsDefinitions.path
    local sndDef = self.s_SubClass.SoundsDefinitions[sndID]

	if not sndDef then
		sndDef = SoundsDefs[sndID]
	end
    
    if not sndDef then
        --Game:Print(self._Name.." sndDEF nor found: "..sndID)
        return sndId
    end
    
    if sndDef.path then path = sndDef.path  end
    
    local name = nil
    if stereo and sndDef.samples_stereo then
        name = sndDef.samples_stereo[math.random(1, table.getn(sndDef.samples))]
    end
    
    if not name then
        name = sndDef.samples[math.random(1, table.getn(sndDef.samples))]
    end

    --Game:Print(name)

    local volume = 100
    if sndDef.volume then volume= sndDef.volume end

    local dist_1 = 15
    if self.s_SubClass.SoundsDefinitions.dist1 then dist_1 = self.s_SubClass.SoundsDefinitions.dist1 end
    if sndDef.dist1 then dist_1 = sndDef.dist1 end
    
    local dist_2 = 40
    if self.s_SubClass.SoundsDefinitions.dist2 then dist_2 = self.s_SubClass.SoundsDefinitions.dist2 end
    if sndDef.dist2 then dist_2 = sndDef.dist2 end
    
    local disablePitch = false
    if self.s_SubClass.SoundsDefinitions.disablePitch then disablePitch = self.s_SubClass.SoundsDefinitions.disablePitch end
    if sndDef.disablePitch then disablePitch = sndDef.disablePitch end
    
    if string.find(name,"$/") then
        name = string.gsub(name,"$/","")
        path = nil
    end
    
    if not path then path = "" end
	if onlyName then
		return path.."/"..name
	end
    return path.."/"..name, volume, dist_1, dist_2, disablePitch
end
--============================================================================
function CObject:Snd2D(id,v)
    local snd,vol,d1,d2,dPitch = self:GetSndInfo(id,nil,true)
    if v then vol = v end
    SOUND.Play2D(snd,vol,false,dPitch)            
end
--============================================================================
function CObject:Snd3D(id,x,y,z)
    local snd,vol,r1,r2,dPitch = self:GetSndInfo(id)
    if not snd then
		return
	end

    if not x then
        x,y,z = ENTITY.GetPosition(self._Entity)
    end
    return SOUND.Play3D(snd,x,y,z,r1,r2,dPitch)            
end
--============================================================================
function CObject:SndEnt(id,entity)
    if not entity then return end    
    local player = EntityToObject[entity]    
    if player and player == Player then -- my player plays 2D
        local snd,vol,r1,r2,dPitch = self:GetSndInfo(id,nil,true)
        SOUND.Play2D(snd,vol,false,dPitch)
        --MsgBox("Player")
    else
        local snd,vol,r1,r2,dPitch = self:GetSndInfo(id)
        local x,y,z = ENTITY.GetPosition(entity)
        if ENTITY.PO_GetType(entity) == BodyTypes.Player then
            x,y,z = ENTITY.PO_GetPawnHeadPos(entity)
        end
        SOUND.Play3D(snd,x,y,z,r1,r2,dPitch) 
    end
end
--============================================================================
function CObject:PlaySound(tableR, dist1, dist2, j, noRandomize,x,y,z)
	local name
    local path = nil
	local dist_1 = 12
	local dist_2 = 40
	local joint = j
	local disablePitch = noRandomize
	
	if type(tableR) == "string" then				-- z tablicy definicji
        if self.s_SubClass and self.s_SubClass.SoundsDefinitions then
            path = self.s_SubClass.SoundsDefinitions.path
            local sndDef = self.s_SubClass.SoundsDefinitions[tableR]
            if not sndDef then
				sndDef = SoundsDefs[tableR]
			end
            if sndDef then
                if sndDef.playChance then
                    if FRand(0,1) > sndDef.playChance then
                        return
                    end
                end
                
                if sndDef.path then 
                    path = sndDef.path
                end
    
                name = sndDef.samples[math.random(1, table.getn(sndDef.samples))]
                if self.s_SubClass.SoundsDefinitions.dist1 then 
                    dist_1 = self.s_SubClass.SoundsDefinitions.dist1 
                end
                if sndDef.dist1 then
                    dist_1 = sndDef.dist1
                end
                if self.s_SubClass.SoundsDefinitions.dist2 then 
                    dist_2 = self.s_SubClass.SoundsDefinitions.dist2 
                end
                if sndDef.dist2 then
                    dist_2 = sndDef.dist2
                end
                if sndDef.joint then
                    joint = sndDef.joint
                end
                
                if self.s_SubClass.SoundsDefinitions.disablePitch then disablePitch = true end
                if sndDef.disablePitch then
                    disablePitch = true
                end
            else
                name = tableR
            end
        else
            name = tableR
        end
	else
		name = tableR[math.random(1, table.getn(tableR))]
		if dist1 then
			dist_1 = dist1
		end
		if dist2 then
			dist_2 = dist2
		end
	end
	
	if name ~= "" then
		local res = string.find(name,"$/")
		local sndDir
		 
		if res then
			name = string.gsub(name,"$/","")
			sndDir = ""
		else
            if path then
                sndDir = path .. "/"
            else
                sndDir = self._SoundDirectory
            end
		end

		if not sndDir then
			sndDir = ""
		end
		
		if joint then
			x,y,z = self:GetJointPos(joint)
		else
			if not z then
				x,y,z = self.Pos.X,self.Pos.Y,self.Pos.Z
			end
		end
		return PlaySound3D(sndDir..name,x,y,z,dist_1,dist2, disablePitch)
	end
end
--============================================================================
function CObject:ReplaceFunction(oldname,newname)
    self[oldname] = self[newname]
    if not self.___funcs then
        self.___funcs = {}
    end
    table.insert(self.___funcs,{oldname,newname})
end
--============================================================================
function CObject:RestoreReplacedFunctions()
    if not self.___funcs then return end
    for i,o in self.___funcs do
        self[o[1]] = self[o[2]]            
    end
end
--============================================================================
