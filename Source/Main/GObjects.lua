--============================================================================
-- Game Objects collection
--============================================================================
GObjects = Array:New()
GObjects.Tick2List = {}
GObjects.Tick3List = {}
GObjects.TickListActors = {}
GObjects.TickListItems = {}
GObjects.TickListRest = {}
GObjects.RenderList = {}
GObjects.PostRenderList = {}
GObjects.UpdateListActors = {}
GObjects.UpdateListItems = {}
GObjects.UpdateListRest = {}
GObjects.SynchronizeList = {}
GObjects.TimerList = {}
GObjects.CheckPoints = {}
GObjects.ObjNames = {}
Actors = {} -- CActor
--============================================================================
function GObjects:Add(name,obj)
    _G[name] = obj
    obj._Name = name

    if obj.BaseObj == "" then obj.BaseObj = obj._Class end   
    Array.Add(self,obj)
    
    self:AddToTables(obj)
        
    return obj
end

--============================================================================
function GObjects:AddToTables(obj)
    if obj._Class == "CActor" then
        AddObjToTable(Actors, obj)
        self.ObjNames[obj._Name] = true
    end
    if obj.BaseObj == "CheckPoint.CItem" or obj.BaseObj == "EndOfGame.CItem" or obj.BaseObj == "EndOfLevel.CItem" or obj.BaseObj == "pentakl.CItem" or obj.BaseObj == "C5L3_Krzyz.CItem" then
		AddObjToTable(self.CheckPoints,obj)
    end
    
    if obj.Tick      then
		if obj._Class == "CActor" then 
			AddObjToTable(self.TickListActors,obj)
		else
			if obj._Class == "CItem" then 
				AddObjToTable(self.TickListItems,obj)
			else
				AddObjToTable(self.TickListRest,obj)
			end
		end
	end
    
    if obj.Update      then
		if obj._Class == "CActor" then 
			AddObjToTable(self.UpdateListActors,obj)
		else
			if obj._Class == "CItem" then 
				AddObjToTable(self.UpdateListItems,obj)
			else
				AddObjToTable(self.UpdateListRest,obj)
			end
		end
	end
    if obj.Tick2       then AddObjToTable(self.Tick2List,obj) end
    if obj.Tick3       then AddObjToTable(self.Tick3List,obj) end
    if obj.Render      then AddObjToTable(self.RenderList,obj) end
    if obj.PostRender      then AddObjToTable(self.PostRenderList,obj) end
    if obj.Synchronize then AddObjToTable(self.SynchronizeList,obj) end
    if obj._Timers and table.getn(obj._Timers)>0 then AddObjToTable(self.TimerList,obj) end
end
--============================================================================
function GObjects:Apply()
   	PMENU.SetLoadingScreenOverall( PMENU.GetLoadingScreenOverall() + table.getn(self.Elements), 20 )
    for i,o in self.Elements do 
		PMENU.LoadingProgress()
        if o._dontFirstApply then
            o._dontFirstApply = nil                        
        else
            o:Apply()
        end
    end
end
--============================================================================
function GObjects:AfterLoad()
    if Lev.AfterLoad then
	    Lev:AfterLoad()
	end
    for i,o in self.Elements do 
        if o.AfterLoad then
	        o:AfterLoad()
	    end
    end
end
--============================================================================
function GObjects:Update()
    Lev:Update()
    
    local func = function(i,v) v:Update() end
    local func2 = function(i,v) v:PreUpdate() end       -- sprawdzanie tylko widocznosci AI

	luaProfiler_LOGIC3a()
    for i,v in self.UpdateListActors do
        ENTITY.RemoveRagdollFromIntersectionSolver(v._Entity)
    end
    if Player then
        ENTITY.RemoveFromIntersectionSolver(Player._Entity)
    end
    
    table.foreachi(self.UpdateListActors , func2)
    
    for i,v in self.UpdateListActors do
        ENTITY.AddRagdollToIntersectionSolver(v._Entity)
    end
    if Player then
        ENTITY.AddToIntersectionSolver(Player._Entity)
    end
    
    table.foreachi(self.UpdateListActors , func)
    
    luaProfiler_LOGIC3b()
    
    table.foreachi(self.UpdateListItems , func)
    
    luaProfiler_LOGIC3c()
    table.foreachi(self.UpdateListRest , func)
    
    if debugMarek then
        Game.UPDATEOBJCNTa = table.getn(self.UpdateListActors)
        Game.UPDATEOBJCNTi = table.getn(self.UpdateListItems)
        Game.UPDATEOBJCNTr = table.getn(self.UpdateListRest)
    end
    
    self:DeleteKilled()    
end
--============================================================================
removedtimers = {}       
function TickT(i,v) 
    v:TickTimers(DELTA)
    if not v._Timers or table.getn(v._Timers) == 0 then
        table.insert(removedtimers,v)
    end
end
--============================================================================
function GObjects:Tick(delta)
    --if true then return end
    self:DeleteKilled() -- after physics collision callbacks
    Lev:Synchronize()
    Lev:Tick(delta)
     
    removedtimers = {}
    
    local func = function(i,v) v:Synchronize() end
    table.foreachi(self.SynchronizeList , func)
    
    func = function(i,v) v:Tick(delta) end
    luaProfiler_LOGIC2a()
    table.foreachi(self.TickListActors , func)
    luaProfiler_LOGIC2b()
    table.foreachi(self.TickListItems , func)
    luaProfiler_LOGIC2c()
    table.foreachi(self.TickListRest , func)
    
    Game.TICKOBJCNTa = table.getn(self.TickListActors)
    Game.TICKOBJCNTi = table.getn(self.TickListItems)
    Game.TICKOBJCNTr = table.getn(self.TickListRest)
    
    Lev:TickTimers(delta)
    table.foreachi(self.TimerList , TickT)    
    
    func = function (i,v) RemoveObjFromTable(self.TimerList,v) end
    table.foreachi(removedtimers , func)

    self:DeleteKilled()
end
--============================================================================
function GObjects:Synchronize(delta)
    --if true then return end
    Lev:Synchronize()
    --for i,o in self.Elements do 
    --    o:Synchronize()
    --end
    table.foreachi(self.SynchronizeList , function(i,v) v:Synchronize() end)
end
--============================================================================
function GObjects:Render(delta)
    --Lev:Render()
    --for i,o in self.Elements do 
    --    o:Render(delta)
    --end
    table.foreachi(self.RenderList , function(i,v) v:Render(delta) end)

end
--============================================================================
function GObjects:PostRender(delta)
    --Lev:Render()
    --for i,o in self.Elements do 
    --    o:Render(delta)
    --end
    table.foreachi(self.PostRenderList , function(i,v) v:PostRender(delta) end)

end
--============================================================================
function GObjects:Tick2(delta)
    if Lev.Tick2 then Lev:Tick2(delta) end
    table.foreachi(self.Tick2List , function(i,v) v:Tick2(delta) end)
end
--============================================================================
function GObjects:Tick3(delta)
    if Lev.Tick3 then Lev:Tick3(delta) end
    table.foreachi(self.Tick3List , function(i,v) v:Tick3(delta) end)
end
--============================================================================
function GObjects:EditRender(delta)
    if Lev.EditRender then Lev:EditRender() end
    for i,o in self.Elements do 
        if o.EditRender then o:EditRender(delta) end
    end
end
--============================================================================
function GObjects:EditTick(delta)
    for i,o in self.Elements do 
        if o.EditTick then o:EditTick(delta) end
        if o.Synchronize then o:Synchronize() end
        if o._Synchronize then o:_Synchronize() end
    end
end
--============================================================================
function GObjects:Clear()	    
    for i,o in self.Elements do 
        if not o._ToKill and o.OnToKill then o:OnToKill() end
        if o.Delete then
            o:Delete()
        end
        _G[o._Name] = nil
    end
    
    if Lev then 
        Lev:Delete()
        _G[Lev._Name] = nil
        Lev = nil
    end
    
    Array.Clear(self)        
    setmetatable(self.Elements,{__mode="vk"}) 

    self.TickListActors = {}
    setmetatable(self.TickListActors,{__mode="vk"}) 
    self.TickListItems = {}
    setmetatable(self.TickListItems,{__mode="vk"}) 
    self.TickListRest = {}
    setmetatable(self.TickListRest,{__mode="vk"}) 

    self.RenderList = {}
    setmetatable(self.RenderList,{__mode="vk"}) 

    self.PostRenderList = {}
    setmetatable(self.PostRenderList,{__mode="vk"}) 

    self.Tick2List = {}
    setmetatable(self.Tick2List,{__mode="vk"}) 

    self.Tick3List = {}
    setmetatable(self.Tick3List,{__mode="vk"}) 

    self.UpdateListActors = {}
    setmetatable(self.UpdateListActors,{__mode="vk"}) 
    self.UpdateListItems = {}
    setmetatable(self.UpdateListItems,{__mode="vk"}) 
    self.UpdateListRest = {}
    setmetatable(self.UpdateListRest,{__mode="vk"}) 


    self.SynchronizeList = {}
    setmetatable(self.SynchronizeList,{__mode="vk"}) 

    self.TimerList = {}
    setmetatable(self.TimerList,{__mode="vk"}) 
    
    Actors = {} -- CActor
    setmetatable(Actors,{__mode="vk"}) 
    
    self.CheckPoints = {}
    setmetatable(self.CheckPoints,{__mode="vk"})

    self.ObjNames = {}
end
--============================================================================
function GObjects:Delete(obj)	
    if obj == Editor.SelObj then Editor.SelObj=nil  end
    if not obj._ToKill and obj.OnToKill then obj:OnToKill() end
    if obj.Delete then
	    obj:Delete()    
	end
    self:FastRemove(obj)
    if obj._Class == "CActor" then
		for i,v in Actors do
			if i ~= "n" then
				if v == obj then
					table.remove(Actors, i)
					break
				end 
			end
		end
	end

	if obj.BaseObj == "CheckPoint.CItem" or obj.BaseObj == "EndOfGame.CItem" or obj.BaseObj == "EndOfLevel.CItem" or obj.BaseObj == "pentakl.CItem" then
		for i,v in self.CheckPoints do
				if v == obj then
					table.remove(self.CheckPoints, i)
					break
			end
		end
	end
    
    if obj.Tick      then
   		if obj._Class == "CActor" then 
			RemoveObjFromTable(self.TickListActors,obj)
		else
			if obj._Class == "CItem" then 
				RemoveObjFromTable(self.TickListItems,obj)
			else
				RemoveObjFromTable(self.TickListRest,obj)
			end
		end
	end
    
    if obj.Update      then
   		if obj._Class == "CActor" then 
			RemoveObjFromTable(self.UpdateListActors,obj)
		else
			if obj._Class == "CItem" then 
				RemoveObjFromTable(self.UpdateListItems,obj)
			else
                --MsgBox("remove: "..obj._Name.." "..obj._Class)
				RemoveObjFromTable(self.UpdateListRest,obj)
			end
		end
	end
    if obj.Render      then RemoveObjFromTable(self.RenderList,obj) end
    if obj.PostRender  then RemoveObjFromTable(self.PostRenderList,obj) end
    if obj.Tick2       then RemoveObjFromTable(self.Tick2List,obj) end
    if obj.Tick3       then RemoveObjFromTable(self.Tick3List,obj) end
    if obj.Synchronize then RemoveObjFromTable(self.SynchronizeList,obj) end
    RemoveObjFromTable(self.TimerList,obj)

    _G[obj._Name] = nil
end
--============================================================================
function GObjects:Clone(dstName,src)
    local obj = Clone(src)
    if obj.OnClone then obj:OnClone(src) end
    GObjects:Add(dstName,obj)
    return obj
end
--============================================================================
function GObjects:FindActorByModel(mdl)
    for i,o in self.Elements do 
        if o._Entity and o._Entity == mdl then
            return o
        end
    end
    return nil
end
--============================================================================
function GObjects:FindByName(name)
    for i,o in self.Elements do 
        if o._Name and o._Name == name then
            return o
        end
    end
    return nil
end
--============================================================================
function GObjects:GetAllObjectsByClass(class)
    local tab = {}
    for i,o in self.Elements do 
        if o._Class and o._Class == class then
            table.insert(tab,o)
        end
    end
    return tab
end
--============================================================================
function GObjects:Rename(obj,newname)
    if not obj then return end
    
    local old = Clone(obj)
    
    local oldname = obj._Name    
    getfenv()[newname] = obj
    obj._Name = newname
    getfenv()[oldname] = nil
    
    obj:Apply(old)
end
--============================================================================
function GObjects:SaveToCurrentLevel(obj)
    if not obj then return end
    local path = "../Data/Levels/"..Lev._Name.."/"
        
    if obj._MapEntity then
        path = path.."MapEntities".."/"
    elseif obj._Class ~= "CLevel" then
        path = path..obj._Class.."/"
    end
    
    FS.CreateDirectory(path)
    SaveObject(path..obj._Name.."."..obj._Class,obj)    
end
--============================================================================
function GObjects:Rescale(factor,class)
    if not class then Lev:Rescale(factor) end
    for i,o in self.Elements do 
        if not class or (class == o._Class) then
            if o.Rescale then o:Rescale(factor) end
        end
    end
end
--============================================================================
function GObjects:FlipZ(factor)
    Lev:FlipZ(factor)
    for i,o in self.Elements do 
        o:FlipZ(factor)
    end
end
--============================================================================
function GObjects:ResetObject(obj)
    local name,class = obj._Name,obj._Class
    ENTITY.PO_Enable(obj._Entity,false)    
    self:ToKill(obj)
    self:DeleteKilled()    
    local o  = LoadObj("../Data/Levels/"..Lev._Name.."/"..class.."/"..name.."."..class,true)
    GObjects:Add(name,o)
    o:Apply()
    if o.AfterLoad then o:AfterLoad() end
end
--============================================================================
function GObjects:Save(class)
    local path = "../Data/Levels/"..Lev._Name.."/"..class.."/"
    FS.CreateDirectory(path)
    for i,o in self.Elements do 
        if not class or (class == o._Class) then
            SaveObject(path..o._Name.."."..o._Class,o)
        end
    end        
end
--============================================================================
function empty()
end
--============================================================================
ToKillArray = {}
function GObjects:ToKill(obj,no_entity)
    if not obj then return end
    if obj._ToKill then return end
    if no_entity then
        obj._NoEntity = true
    else
		if Game.GMode == GModes.SingleGame then
			ENTITY.EnableCollisions(obj._Entity, false)
		end
    end
    obj._ToKill = true
    if obj.OnToKill then obj:OnToKill() end

    if obj.Actions then
	    obj:LaunchAction(obj.Actions.OnKill)
	end

    obj:ReleaseTimers()
    
    obj.Tick = empty
    obj.Update = empty
    obj.Synchronize = empty
    obj.Render = empty
    obj.PostRender = empty
    obj.Tick2 = empty
    obj.Tick3 = empty
    if Editor.SelObj == obj then Editor.SelObj = nil end
    
    table.insert(ToKillArray,obj)
end
--============================================================================
function GObjects:DeleteKilled()
    local array = TableClone(ToKillArray)
    ToKillArray = {}
    for i,v in array do
        if EntityToObject[v._Entity] then
            EntityToObject[v._Entity] = nil
        end
        if v._NoEntity then v._Entity = 0 end   
        GObjects:Delete(v)
    end
end
--============================================================================
function GObjects:RefreshFromTemplates()
    if true then return end ---XXX
    -- trzeba stworzyc obiekt z templata i zaladowac go z pliku
    -- po prostu LoadObj    
    
    for i,o in self.Elements do 
        if o.Template and string.len(o.Template) > 2 then            
            local old = Clone(o)
            Inherit(o,LoadTemplate(o.Template),true)
            o:Apply(old)
            old = nil
        else
            o.Template = nil
        end
    end        
end
--============================================================================
