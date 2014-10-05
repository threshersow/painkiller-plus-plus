--============================================================================
-- SpawnPoint class
--============================================================================
CSpawnPoint =
{
    GroupCount = 5,
    GroupDelay = 3,
    GroupSize = 1,
    EachDelay = 0.3,
    StartDelay = 0,
    SpawnTemplate = "DevilMonk.CActor",
    SpawnFX = "MonsterSpawn.CAction",
    WalkArea = "",
    NotCountable = false,
    OnFinishAction = {}, -- compatibility
    Actions = {
        OnLastMonsterDie    = {},
        OnMonsterSpawn    = {},
    },   
    Pos = Vector:New(0,0,0),    
    SpawnAngle = {
        Value = 0,
        Enabled = false,
    },
    _SpawnCount = 0,
    _IvCnt = 0,
    _Class = "CSpawnPoint", 
    _SpawnedMonsters = {},
    _SpawnedMonstersCount = 0,
    _SpawnedMonstersCountActual = 0,
}
Inherit(CSpawnPoint,CObject)
--============================================================================
function CSpawnPoint:OnClone(old)
    if old == CSpawnPoint then 
        self.Pos = OppositeToCamera() 
    else 
        self.Pos.X = old.Pos.X - 0.5
        self.Pos.Z = old.Pos.Z - 0.5
    end
end
--============================================================================
function CSpawnPoint:Apply(old)            
    if self.OnFinishAction and table.getn(self.OnFinishAction) > 0 then 
   		if not self.Actions then		-- hack dla compatibility
			self.Actions = Clone(self.s_SubClassParams.Actions)
		end
        self.Actions.OnLastMonsterDie = self.OnFinishAction  
    end
    self.OnFinishAction  = nil

    self._IvCnt = self.StartDelay
    if self.EachDelay < 0.5 then self.EachDelay  = 0.5 end

    -- compatibility
    local i = string.find(self.SpawnTemplate,"^",1,true)
    if i then self.SpawnTemplate = string.sub(self.SpawnTemplate,1,i-1).."_"..string.sub(self.SpawnTemplate,i+1) end
end
--============================================================================
function CSpawnPoint:Tick(delta)
    if not self._Launched then return end
    
    if self._SpawnedMonstersCount > 0 then
        -- patrze, ktore monstery sa juz zabite
        for i,v in self._SpawnedMonsters do
            if v._ToKill or v._died then 
                table.remove(self._SpawnedMonsters,i) 
                self._SpawnedMonstersCount = self._SpawnedMonstersCount -1
            end
        end        

        if self.GroupDelay < 0 then
            if self._SpawnedMonstersCount > 0 then
                return
            else
                self._IvCnt = math.abs(self.GroupDelay)
            end
        end
                
        if self._SpawnedMonstersCount <= 0 and self._SpawnCount >= self.GroupCount then 
            if self.Actions then
                self:LaunchAction(self.Actions.OnLastMonsterDie)
            end
            GObjects:ToKill(self)
            return
        end        
    end
    
    if self._SpawnCount >= self.GroupCount then return end    

    if Game.BulletTime and self.GroupCount == 1 and self.GroupSize == 1 then
        delta = delta / INP.GetTimeMultiplier() 
    end    
    
    self._IvCnt = self._IvCnt - delta    
    if self._IvCnt < 0 then    
        
        self._SpawnedMonstersCount = self._SpawnedMonstersCount + self.GroupSize
        local t = 0
        for i=1,self.GroupSize do 
            local action = {}
            table.insert(action,{"Wait:"..tostring(t)})
            table.insert(action,{"L:p:Spawn()","monster"})			
            AddAction(action,self)
            t = t + self.EachDelay
        end
    
        self._IvCnt = self.GroupDelay
        self._SpawnCount = self._SpawnCount + 1
                
    end        
end
--============================================================================
function CSpawnPoint:Spawn()       
    if not self._FirstSpawn then 
        self._FirstSpawn = true
        if self.OnFirstSpawn then self:OnFirstSpawn() end
    end
    local newName = self._Name.."_"..self._SpawnedMonstersCountActual
    --local obj = GObjects:Add(TempObjName(),CloneTemplate(self.SpawnTemplate))
    --Game:Print(self._Name.."_"..self._SpawnedMonstersCountActual)
    --if debugMarek then
		while (getfenv()[newName]) do
			--MsgBox("ERROR: "..self._Name.."_"..self._SpawnedMonstersCountActual.." EXISTS!")
            self._SpawnedMonstersCountActual = self._SpawnedMonstersCountActual + 1
            newName = self._Name.."_"..self._SpawnedMonstersCountActual
		end
    --end
    
    local obj
    if Tweak.GlobalData.GermanVersion and Lev.Map == "C6L1_Orphanage.mpk" and
		(self.SpawnTemplate == "Girl.CActor" or self.SpawnTemplate == "Boy.CActor" or self.SpawnTemplate == "Bagbaby.CActor"
		or self.SpawnTemplate == "BreakBoy.CActor" or Templates[self.SpawnTemplate].BaseObj == "BreakBoy.CActor") then
		obj = GObjects:Add(newName,CloneTemplate("Corn.CActor"))
		obj.Health = obj.Health * 0.3
		obj.Scale = 1.1
		obj.AiParams.aiGoals = {"idle","attack", "hunt", "hear","flee"}
    else
		obj = GObjects:Add(newName,CloneTemplate(self.SpawnTemplate))
	end
	
    self._SpawnedMonstersCountActual = self._SpawnedMonstersCountActual + 1
    if self.NotCountable then
        obj.NotCountable = self.NotCountable
    end
    obj.Pos:Set(self.Pos)    
    if self.SpawnAngle and self.SpawnAngle.Enabled then
        if obj.angle then
            obj.angle = self.SpawnAngle.Value        
        end
        if obj.Rot then
            obj.Rot:FromEuler(0,-self.SpawnAngle.Value,0)
        end
    else
        obj.angle = math.atan2(Player.Pos.X - obj.Pos.X,Player.Pos.Z - obj.Pos.Z) -- front to player
    end
    if obj.angle then
        obj.angleDest = obj.angle
    end
    --obj.AIType = nil
    self:OnSpawn(obj)
    obj:Apply()
    if obj.Synchronize then obj:Synchronize() end
    
    local sfx = self.SpawnFX
    if sfx ~= "" and Game.BulletTime then
        sfx = "MonsterSpawn.CAction"
    end    
    if sfx ~= "" then
        
        ENTITY.EnableDraw(obj._Entity,false)
        local action = CloneTemplate(self.SpawnFX)            
        -- doklejam self.Actions.OnMonsterSpawn
        if self.Actions then
            for i,v in self.Actions.OnMonsterSpawn do
                table.insert(action.Sequence,{v})
            end
        end                        
        local fx = GObjects:Add(TempObjName(),action)        
        fx._ObjParent = obj
        fx:Apply()        
    else
        if self.Actions then
            obj:LaunchAction(self.Actions.OnMonsterSpawn)        
        end
    end
    
    if self._EnableDemonic then
        --Game:Print("enable demonic for "..obj._Name)
        ENTITY.EnableDemonic(obj._Entity,true,true)
        self._EnableDemonic = nil
    end

    table.insert(self._SpawnedMonsters,obj)    
    
    return obj
end
--============================================================================
-- to override
--============================================================================
--function CSpawnPoint:OnCheckStartupCondition()
--end
--============================================================================
function CSpawnPoint:OnSpawn(obj)
    --obj.Scale = FRand(0.8,1.2)
    if self.WalkArea ~= "" then
        obj.AiParams.walkArea = self.WalkArea
        --obj.AiParams.WalkAreaWhenAttack = true
    end
end
--============================================================================
