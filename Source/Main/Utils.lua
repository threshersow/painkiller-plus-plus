--============================================================================
-- Utilities library
--============================================================================
function TableMerge(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
                if type(t1[k] or false) == "table" then
                        TableMerge(t1[k] or {}, t2[k] or {})
                else
                        t1[k] = v
                end
        else
                t1[k] = v
        end
    end
    return t1
end
--============================================================================
function Clone(t)
    if not t then return nil end   
    local new = {}
    local i, v = next(t, nil) 
    while i do        
        -- LUA PLUS if type(v)== "table" and not getmetatable(v).__call and string.sub(i,1,2) ~= "s_" and string.sub(i,1,3) ~= "Obj" and string.sub(i,1,4) ~= "_Obj"  then
        if type(v)== "table" and not getmetatable(v) and string.sub(i,1,2) ~= "s_" and string.sub(i,1,3) ~= "Obj" and string.sub(i,1,4) ~= "_Obj" and string.sub(i,1,2) ~= "r_"  and string.sub(i,1,3) ~= "_r_" then
            v = Clone(v)
        end
        new[i] = v          
        i, v = next(t, i) 
    end
    return new
end
--============================================================================
function TableClone(t)
    local new = {}
    local i, v = next(t, nil) 
    while i do
        new[i] = v
        i, v = next(t, i) 
    end
    return new
end
--============================================================================
function PureClone(t)
    if not t then return nil end   
    local new = {}
    local i, v = next(t, nil) 
    while i do
        if type(v)=="table" then v = PureClone(v) end
        new[i] = v
        i, v = next(t, i) 
    end
    return new
end
--===============================================
function Inherit(obj,t,override)
    if not t then return nil end
    local i, v = next(t, nil)
    while i do
        if not getmetatable(v) and type(v)=="table" and string.sub(i,1,3) ~= "Obj"  and string.sub(i,1,4) ~= "_Obj" and string.sub(i,1,2) ~= "r_"  and string.sub(i,1,3) ~= "_r_" then
            if not obj[i] then obj[i] = {} end
            Inherit(obj[i],v,override)
        else
            if override then
                obj[i] = v
            else
                if obj[i] == nil then
                    obj[i] = v
                end
            end
        end
        i, v = next(t, i)
    end
end
--============================================================================
function InheritFunctionsAndStatics(obj,t)
    if not t then return nil end
    local i, v = next(t, nil)
    while i do
        if obj[i] == nil and (getmetatable(v) or type(v)=="function" or string.sub(i,1,2) == "s_") then
            obj[i] = v
        elseif obj[i] and type(obj[i]) == "table" and type(v) == "table" then
            InheritFunctionsAndStatics(obj[i],v) -- poniewaz sa zaglebione funkcje w _CustomAiStates
        end
        i, v = next(t, i)
    end
end
--============================================================================
function dostring(str)
    --DoString(str)
    local f = loadstring(str)
    f()
end
--============================================================================
function Dist2D(x,y,x1,y1)
  return math.sqrt( (x-x1)*(x-x1) + (y-y1)*(y-y1) )
end
--============================================================================
function Dist3D(x,y,z,x1,y1,z1)
  return math.sqrt( (x-x1)*(x-x1) + (y-y1)*(y-y1) + (z-z1)*(z-z1) )
end
--====================================================
function AngDist(a1,a2)

    local d1 = math.mod( math.abs(a2-a1) , 2*math.pi)
	local d2=2*math.pi-d1
	local m=math.min(d1,d2)

	if (d1<d2) then
		if(a2>=a1) then m=d1 else m=-d1 end
	else
		if(a2>=a1) then m=-d2 else m=d2 end
    end

    return math.mod(m,math.pi*2)
end
--============================================================================
function SaveTable(f,tab,name,diff,parent) 
    local i, v = next(tab, nil)
    while i do
        if not getmetatable(v) and string.sub(i,1,1) ~= '_' and string.sub(i,1,2) ~= "s_" and type(v) ~= "function" then
            local np
            if parent then np = parent[i] end
            if type(v) == "table" then                
                if string.sub(i,1,3) ~= "Obj" and string.sub(i,1,4) ~= "_Obj" and string.sub(i,1,2) ~= "r_"  and string.sub(i,1,3) ~= "_r_" then
                    -- save table (recursive)
                    local typ = "{}"                    
                    --if v._Class then typ = "Clone("..v._Class ..")" end
                    if type(i) == "number" then
                        if v.SaveString then 
                            if not (diff and np and v:Compare(np)) then                
                                f:write(name..'['..i..'] = '..v:SaveString()..'\n')
                            end                            
                        else
                            if not (diff and np) then                
                                f:write(name..'['..i..'] = '..typ..'\n')                            
                            end
                            SaveTable(f,v,name..'['..i..']',diff,np)
                        end
                    else
                        if v.SaveString then 
                            if not (diff and np and v:Compare(np)) then
                                f:write(name..'.'..i..' = '..v:SaveString()..'\n')
                            end
                        else
                            if not (diff and np) then                
                                f:write(name..'.'..i..' = '..typ..'\n')
                            end
                            SaveTable(f,v,name..'.'..i,diff,np)
                        end
                    end
                else 
                    -- save GO (convert reference to name)
                    f:write(name..'.'..i..' = "'..v._Name..'"\n')
                end
            else
                -- save single property
                if not (diff and np~=nil and np == v) then                
                    local val =  v                
                    if type(v) == "string" then 
                        val = string.format('%q',val)
                    end                
                    if type(v) == "boolean" and v == true then val = "true" end                                
                    if type(v) == "boolean" and v == false then val = "false" end                                
                    if type(i) == "number" then
                        f:write(name..'['..i..'] = '..val..'\n')
                    else
                        f:write(name..'.'..i..' = '..val..'\n')
                    end
                end
            end
        end
        i, v = next(tab, i)
    end
end
--============================================================================
function IsObjRef(tab) 
    if tab._Name and tab._Name ~= "NoName" and ( getfenv()[tab._Name] or GObjects.ObjNames[tab._Name] ) then
        return true
    end
    return false
end
--============================================================================
function SaveFullTable(f,tab,name)
	if not tab then return end        
    for i,v in tab do
        local itype = type(i)
        local vtype = type(v)
        if (itype == "number" or (itype == "string" and string.sub(i,1,2) ~= "s_")) and vtype ~= "function" and not getmetatable(v) then
            if vtype == "table" then                
                if not IsObjRef(v) then
                    -- save table (recursive)
                    local typ = "{}"                    
                    --if v._Class then typ = "Clone("..v._Class ..")" end
                    if itype == "number" then
                        if v.SaveString then 
                            FS.File_Write(f,name..'['..i..'] = '..v:SaveString()..'\n')
                        else
                            FS.File_Write(f,name..'['..i..'] = '..typ..'\n')                            
                            SaveFullTable(f,v,name..'['..i..']')
                        end
                    else
                        if v.SaveString then 
                            FS.File_Write(f,name..'.'..i..' = '..v:SaveString()..'\n')
                        else
                            FS.File_Write(f,name..'.'..i..' = '..typ..'\n')
                            SaveFullTable(f,v,name..'.'..i)
                        end
                    end
                else 
                    -- save GO (convert reference to name)
                    if itype == "number" then
                        FS.File_Write(f,name..'['..i..'] = "ref:'..v._Name..'"\n')
                    else
                        FS.File_Write(f,name..'.'..i..' = "ref:'..v._Name..'"\n')
                    end
                end
            else
                local val =  v                
                if vtype == "string" then 
                    val = string.format('%q',val)
                end                
                if vtype == "boolean" and v == true then val = "true" end                                
                if vtype == "boolean" and v == false then val = "false" end                                
                if vtype == "userdata" then val = '"unknown_pointer"' end
                if vtype == "nil" then val = 'nil' end                
                if itype == "number" then
                    FS.File_Write(f,name..'['..i..'] = '..val..'\n')
                else
                    FS.File_Write(f,name..'.'..i..' = '..val..'\n')
                end
            end
        end
    end
end
--============================================================================
function SaveObject(filename,obj)
    SaveObj(filename,obj)
end
--============================================================================
function ParseFileName(fname) 
    
    local l = string.len(fname)
    for n=l,1,-1 do 
        local ch = string.sub(fname,n,n)
        if  ch == "/" or ch == "\\" then 
            fname = string.sub(fname,n+1)
            break
        end
    end            
    
    local i = string.find(fname,".",1,true)
    if i then 
        return string.sub(fname,1,i-1),string.sub(fname,i+1,-1)    
    else
        return fname
    end
end
--============================================================================
function GetBasePath(fname)     
    local l = string.len(fname)
    for n=l,1,-1 do 
        local ch = string.sub(fname,n,n)
        if  ch == "/" or ch == "\\" then 
            return string.sub(fname,1,n)
        end
    end            
    return fname
end
--============================================================================
--[[function GModifyVariables(obj)    
    o = obj; v = obj.Vars; m = obj._Memory -- set temporary globals        
    -- do modification
    o._Behaviors[o.BName][5]()
    -- clipping to ranges
    local i, var = next(v, nil)
    while i do
        if var < 0 then v[i] = 0 end
        if var > 100 then v[i] = 100 end
        i, var = next(v, i)
    end    
end
--============================================================================
function GChooseBehavior(obj)        
    o = obj; v = obj.Vars; m = obj._Memory -- set temporary globals

    local bname = o.BName
    local weight = 0
    
    local i, b = next(o._Behaviors, nil)
    while i do
        if b[4]() and  b[1]>=weight then 
            bname = i
            weight = b[1]
        end
        i, b = next(o._Behaviors, i)
    end    

    local ret = false
    if o.BName ~= bname then ret = true end
    o.BName = bname
    return ret
end--]]
--============================================================================
function FRand(mn,mx)
    mn = mn*1000
    if mx then
        mx = mx*1000
        return math.random(mn,mx)*0.001
    else
        return math.random(mn)*0.001
    end
end
--============================================================================
function Chance(var)
    if var>=1 and math.random(var) == math.floor(var) then return true end
    return false
end
--============================================================================
function f2(val)
    return string.format("%.2f",val)
end
--============================================================================
function OppositeToCamera()
    if not Lev then return Vector:New(0,0,0) end
    local x,y,z = CAM.GetForwardVector()
    return Vector:New(Lev.Pos.X + x*4,Lev.Pos.Y + y*4,Lev.Pos.Z + z*4)
end
--============================================================================
function TraceFromCamera(length)
    local cx,cy,cz = CAM.GetPos() 
    local fx,fy,fz = CAM.GetForwardVector() 
    ENTITY.RemoveFromIntersectionSolver(Player._Entity)
    local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTrace(cx,cy,cz,cx+fx*length,cy+fy*length,cz+fz*length)    
    ENTITY.AddToIntersectionSolver(Player._Entity)    
    return b,d,x,y,z,-nx,-ny,-nz,he,e
end
--============================================================================
function TraceFromPlayerToPoint(entity,dx,dy,dz)    
    local cx,cy,cz = ENTITY.PO_GetPawnHeadPos(entity)
    ENTITY.RemoveFromIntersectionSolver(entity)
    local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTrace(cx,cy,cz,dx,dy,dz)
    ENTITY.AddToIntersectionSolver(entity)    
    return b,d,x,y,z,nx,ny,nz,he,e
end
--============================================================================
function CloneTemplate(template)
    -- compatibility
    local i = string.find(template,"^",1,true)
    if i then template = string.sub(template,1,i-1).."_"..string.sub(template,i+1) end

    if not template then
		Game:Print("template not found "..template)
		return nil
    end    

    local obj = CloneObj(template,true)
    if not obj then MsgBox("Template not found :"..template) end
    if obj.OnInitTemplate then obj:OnInitTemplate() end -- temporary
    return obj
end
--============================================================================
function TempObjName()
    local name = "Tmp"..math.random(9)..GObjects:Count()..math.random(9)..math.random(9)..math.random(9)..math.random(9)
    if _G[name] ~= nil then return TempObjName() end
    return name 
end
--============================================================================
function FindTemplate(path, name)
    local files = FS.FindFiles(path.."/*.*",1,0)
    for i=1,table.getn(files) do
		if name == files[i] then
			return LoadObj(path.."/"..files[i], true)
		end
    end    
    local dirs = FS.FindFiles(path.."/*.*",0,1)
    for i=1,table.getn(dirs) do
        local obj = FindTemplate(path.."/"..dirs[i], name)
        if obj then
			return obj
        end
    end
    return
end



--============================================================================
function LoadObjIndex(obj,key)
	local t = rawget(obj,key)
	if t then return t end
	
    if not key then
		--MsgBox("LoadObjIndex no key "..GetCallStackInfo(2))
        return
    end
    if not TemplatesPaths[key] then
		local objnew = FindTemplate("../Data/LScripts/Templates", key)
		if objnew then
			rawset(obj,key,objnew)
			return objnew
		else
			objnew = FindTemplate("../Data/Levels/"..Lev._Name.."/Templates", key)
			if objnew then
				rawset(obj,key,objnew)
				return objnew
			else
				Game:Print("==Template not Found: "..key)
				return
			end
		end
    end
	--MsgBox("LoadObjIndex "..key.."   "..TemplatesPaths[key].path.."   "..GetCallStackInfo(2))
	if debugGC then
		collectgarbage(0)
		local gccount = GetGCCount()
		if not lastGC then lastGC = gccount end
		-------Game:Print(" LoadTemplate: "..key.." last obj memory usage: "..(gccount - lastGC))
		lastGC = gccount
		--MsgBox("### LoadObj? ".." "..key.." "..TemplatesPaths[key].path)
	end
	local objnew = LoadObj(TemplatesPaths[key].path, true)
	if objnew then
		--objnew._IsLevelTemplate = TemplatesPaths[key].leveltemplate			-- ### potrzebne?
		rawset(obj,key,objnew)
		--table.setconstant(rawget(obj,key))		--?
		TemplatesPaths[key] = nil
		
		return objnew
	else
		MsgBox("!!! LoadObjI NOT OK ")
	end
end


function LoadTML(path,file,leveltemplate)
    if TemplatesPaths[file]	then
		return
	end				-- juz zaladowany (moze jakies dziecko go potrzebowalo?)
	
	if Game.GMode == GModes.SingleGame then
		TemplatesPaths[file] = {
			path = path.."/"..file,
			levtml = leveltemplate,
		}
	else
		--local fname, ext = ParseFileName(file)
		if Templates[file] then return end
		local tml = LoadObj(path.."/"..file,true)
		tml._IsLevelTemplate = leveltemplate
		Templates[file] = tml
	end
end
--============================================================================
function PreloadTemplates(path,leveltemplates)
    --setmetatable(Templates,{__mode="k"})
    local files = FS.FindFiles(path.."/*.C*",1,0)
    for i=1,table.getn(files) do
        LoadTML(path,files[i],leveltemplates)
        PMENU.LoadingProgress()
    end
    local dirs = FS.FindFiles(path.."/*.*",0,1)
    for i=1,table.getn(dirs) do
		if Game.GMode == GModes.SingleGame or (Game.GMode ~= GModes.SingleGame and
		 not leveltemplates and dirs[i] ~= "Monsters" and dirs[i] ~= "Items" and dirs[i] ~= "Treasures") then
			PreloadTemplates(path.."/"..dirs[i],leveltemplates)
	    end
    end    
end
--============================================================================
function BindPoint(e,ox,oy,oz)
    local a = -ENTITY.GetOrientation(e)    
    local ex,ey,ez = ENTITY.GetPosition(e)    
    local x = ex + (math.cos(a)*ox - math.sin(a)*oz)
    local z = ez + (math.sin(a)*ox + math.cos(a)*oz)    
    local y = ey + oy
    return x,y,z
end
--============================================================================
function Text2Tab(txt,sep)
    local tab = {}
    local n = 1
    while 1 do
        local p = string.find(txt,sep,1,true)
        if not p then
            tab[n]  = txt
            n = n+1
            break
        end
        table.insert(tab,string.sub(txt,1,p-1))
        txt = string.sub(txt,p+1)
        n = n+1
    end
    return tab,n-1
end
--============================================================================
function DeathEffect(entity,model)
    local tdj = SubClasses.CActor[model].DeathJoints
    if tdj then
        for i=1,table.getn(tdj) do
            local idx = MDL.GetJointIndex(entity,tdj[i])
            if idx > -1 then
                local x,y,z = MDL.GetJointPos(entity,idx)
                AddParticleFX(x,y,z,"Death")
            end
        end
    end        
end
--============================================================================
function FindObj(name)
    -- szukam wsrod templatow   ENGLISH: looking through templates
    if not name or name == "" then return end

    o = _G[name]
    if not o then o = Templates[name] end

    return o
end
--============================================================================
function CloneObj(obj,inherit) -- nazwa lub referencja, czy dziedziczy po nim czy tylko kopiuje   ENGLISH: name or reference, whether inherited or just copy it
    
    local baseobj
    local objname
    
    if type(obj) == "string" then -- po nazwie        
        baseobj = obj
        obj = FindObj(baseobj)        
    else -- po referencji
        if obj._Name ~= "NoName" then 
            baseobj = obj._Name
        else
            baseobj = obj._Class
        end        
    end
    
    if not obj then
        MsgBox("CloneObj: not obj "..GetCallStackInfo(2))
        return
    end

    local newobj = Clone(obj)    
    
    if newobj.OnClone then newobj:OnClone(obj) end        
    if inherit then newobj.BaseObj = baseobj end    
    
    return newobj
end
--============================================================================
function SaveObj(filename,obj)
    if obj.NotSaveable then return end
    local f = io.open (filename,"w")
    if not f then 
        Game:Print("- Cannot save file: "..filename.." - read only?")
        return 
    end
    local base = obj._Class
    if obj.BaseObj and string.len(obj.BaseObj) > 2 then
        base = obj.BaseObj
    end
    SaveTable(f,obj,"o",true,FindObj(base))        
    Game:Print("+ Object :'"..obj._Name.."' saved as: '"..filename.."'")    
    io.close(f)
end



--============================================================================
function SaveFullObj(filename,obj)
    local f = FS.File_Open(filename)
    if not f then 
        Game:Print("- Cannot save file: "..filename.." - read only?")
        return 
    end
    
    SaveFullTable(f,obj,"o")  
    if obj._Name then
        Game:Print("+ Object :'"..obj._Name.."' saved as: '"..filename.."'")    
    end
    FS.File_Close(f)
end



--============================================================================
function LoadObj(path,templatemode)
    local name, ext = ParseFileName(path)    
    local backup = getfenv()[name]
    
    local newobj = {_Name = "NoName"} -- musi cos zawierac
    getfenv()[name] = newobj

    o = newobj
    FS.GetBaseObjInfo(path)
    if not newobj.BaseObj or newobj.BaseObj == "" then
        newobj.BaseObj = ext
    end
    
    local baseobj = FindObj(newobj.BaseObj)
    if not baseobj then -- brak bazowego obiektu    
        -- rekurencyjnie ladujemy bazowy obiekt
        local tml = LoadObj(GetBasePath(path)..newobj.BaseObj,true)
        --Game:Print("Nie bylo: "..GetBasePath(path)..newobj.BaseObj)
        Templates[newobj.BaseObj] = tml
        baseobj = FindObj(newobj.BaseObj)
        if not baseobj then 
            MsgBox(path..":\nBaseObj:  '"..newobj.BaseObj.."' not found!!!")
            return nil
        end
    end
    
    newobj = CloneObj(newobj.BaseObj,true)
    getfenv()[name] = newobj -- poniewaz jest juz inny obiekt
        
    if templatemode then  -- kazdy template musi miec swoja instancje statycznej tablicy s_SubClass
        if newobj.s_SubClass then newobj.s_SubClass = PureClone(newobj.s_SubClass) end
    end
    
    o = newobj

	if XBOX then    
		mt = getmetatable(o) 
		setmetatable(o,{ __index = LoadObjCItem})
	end
    
    DoFile(path,false)    
       
    newobj._Name = name
    newobj._Class = ext

    --MsgBox(newobj._Name)
    --MsgBox(getfenv()[name]._Name)
    
    -- load additional script file
    local fileLua = string.gsub(path,"%."..ext,".lua")
    DoFile(fileLua,false)
    fileLua = string.gsub(path,"%."..ext,".soundsDef")
    DoFile(fileLua,false)
    fileLua = string.gsub(path,"%."..ext,".particlesDef")
    DoFile(fileLua,false)
    
    if EditorFiles then
		fileLua = string.gsub(path,"%."..ext,".editor")
		DoFile(fileLua,false)
    end

	if XBOX then
		setmetatable(o,mt) 
		mt = nil
	end

	--if o.Pos then			-- UGLY HACK: narazie: zeby template nie mial t.s. pozycji co tworzony obiekt (edytor+save)
	--	o.Pos.Y = o.Pos.Y + 0.01
	--end
    
    getfenv()[name] = backup        
    return newobj    
end
--===============================================
function CompareObjToBaseObjVar(obj,basename,fullkey)
    local bo = FindObj(basename)
    if not bo then return false end
    
    local keys = Text2Tab(fullkey,".")
    local n = table.getn(keys)    
    for i=1,n do
        obj = obj[keys[i]]
        bo = bo[keys[i]]
        if bo == nil then return false end
        if type(obj) ~= "table" then
            if bo ~= obj then return false end
        end        
    end    
    
    return true
end
--============================================================================
function CheckStartGlass(he,x,y,z,activationRadius,vx,vy,vz)
    if WORLD.CheckStartGlass(he,x,y,z,activationRadius,vx,vy,vz) then
        Game:OnBrokenGlass(x,y,z)
        return true
    end    
    return false
end
--============================================================================
function LookAtEntity(e)
    local x,y,z = CAM.GetForwardVector()
    local ex,ey,ez = ENTITY.GetCenter(e)
    Lev.Pos:Set(ex - x*3,ey - y*3,ez - z*3)
    Lev:Synchronize()
end
--============================================================================
function LookAt(ex,ey,ez)
    local x,y,z = CAM.GetForwardVector()
    Lev.Pos:Set(ex - x*3,ey - y*3,ez - z*3)
    Lev:Synchronize()
end
--============================================================================
function GenerateTreasures(parent,treasures)
    for i,o in treasures do
        local count = o[1]
		local x,y,z = ENTITY.GetPosition(parent._Entity)
        
        for ii=1,count do        
            local cn = string.len(o[2]) - 1
            local r = FRand(0,1)
            
            local c = math.floor(r*cn+0.5) + 1            
            local nm = string.sub(i,1,-2) .. string.upper(string.sub(o[2],c,c)) .. ".CItem"
            --Game:Print(nm)
        
            local obj = GObjects:Add(TempObjName(),CloneTemplate(nm))
            obj.Pos.X = x + FRand(-0.2,0.2)
            obj.Pos.Y = y + FRand( 0.0,0.2)
            obj.Pos.Z = z + FRand(-0.2,0.2)
            obj.Rot:FromEuler(FRand(-3.14,3.14), FRand(-3.14,3.14), FRand(-3.14,3.14))
            obj:Apply()
            obj:Synchronize()
        end
    end
    
end
--============================================================================
function GetNearestLiveActor()
    local dist = 99999
    local closest = nil
    if Player then
        for i,v in Actors do
            if v.Health > 0 and v._AIBrain and not v.NotCountable then
                local d = Dist3D(Player._groundx,Player._groundy, Player._groundz,v._groundx,v._groundy,v._groundz)
                if d < dist then
                    dist = d
                    closest = v
                end
            end
        end
    end
	return closest
end
--============================================================================
function GetNearestCheckPoint()
	local dist = 99999
	local closest = nil
	local isPent = true

	if not Player then return nil end

	for i,v in GObjects.CheckPoints do
		if v.Frozen == false and v.BaseObj ~= "pentakl.CItem" and v.BaseObj ~= "C5L3_Krzyz.CItem" then
			local d = Dist3D(Player._groundx,Player._groundy, Player._groundz,v.Pos.X,v.Pos.Y,v.Pos.Z)
			if d < dist then
				dist = d
				closest = v
			end
		end
	end

	if closest then return closest, true end

	for i,v in GObjects.CheckPoints do
		if v.BaseObj == "C5L3_Krzyz.CItem" and v.Glow then
			local d = Dist3D(Player._groundx,Player._groundy, Player._groundz,v.Pos.X,v.Pos.Y,v.Pos.Z)
			if d < dist then
				dist = d
				closest = v
--				isPent = false
			end
		end
	end

	if closest then return closest, isPent end

	for i,v in GObjects.CheckPoints do
		if v.BaseObj == "pentakl.CItem" and ENTITY.IsDrawEnabled(v._Entity) then
			local d = Dist3D(Player._groundx,Player._groundy, Player._groundz,v.Pos.X,v.Pos.Y,v.Pos.Z)
			if d < dist then
				dist = d
				closest = v
--				isPent = false
			end
		end
	end

	return closest, isPent
end
--============================================================================
function TrimLeft(str)
    while 1 do
        if string.sub(str,1,1) == " "  then
            str = string.sub(str,2)
        else
            break
        end
    end
    return str
end
--============================================================================
function TrimRight(str)
    while 1 do
        local l = string.len(str)
        local ch = string.sub(str,l)
        if ch == " " or ch == "\n" or ch== "\r" then
            str = string.sub(str,1,l-1)
        else
            break
        end
    end
    return str
end
--============================================================================
function Trim(str)
    str = TrimLeft(str)
    return TrimRight(str)
end
--============================================================================
function BindFX(entity,name,scale,joint,ox,oy,oz,cox,coy,coz,ax,ay,az)
    local pfx = AddPFX(name,scale,rot)   
    ENTITY.RegisterChild(entity,pfx,true)    
    if type(joint) == "string" then joint = MDL.GetJointIndex(entity, joint) end
    if ox then
        PARTICLE.SetParentOffset(pfx,ox,oy,oz,joint,cox,coy,coz,ax,ay,az)
    else
        PARTICLE.SetParentOffset(pfx,0,0,0,joint,cox,coy,coz,ax,ay,az)
    end
    return pfx
end
--============================================================================
function BindSoundToEntity(entity,soundname,fstart,fend,looped,joint,ox,oy,oz,delay,velFactor,dontautodelete)
    local snd,idx = ENTITY.Create(ETypes.Sound)
    if ox then ENTITY.SetPosition(snd,ox,oy,oz) end    
    if not ox and ENTITY.PO_GetType(entity) == BodyTypes.Player then
        --local px,py,pz = ENTITY.GetPosition(entity)
        --local hx,hy,hz = ENTITY.PO_GetPawnHeadPos(entity)
        --ENTITY.SetPosition(hx-px, hy-py, hz-pz)
        --Game:Print("player correction: "..hx-px..", "..hy-py..", "..hz-pz)
        ENTITY.SetPosition(0, 2, 0) -- head        
    end 
    WORLD.AddEntity(snd)
    ENTITY.RegisterChild(entity,snd,true,joint)
    local interval = 0
    if not looped then interval = -1 end 
    SND.Setup3D(snd,soundname,fstart,fend,interval,nil,dontautodelete)
    SND.Play(snd,delay)
    if velFactor then SND.SetVelocityScaleFactor(snd,velFactor) end
    return snd, idx
end
--============================================================================
function BindTrailToEntity(entity,name,joint,ox,oy,oz)
    local e = ENTITY.Create(ETypes.Trail,name,"trail")
    if ox then ENTITY.SetPosition(e,ox,oy,oz) end
    if joint and joint == -1 then joint = nil end
    ENTITY.AttachTrailToBones(entity,e,joint)
    WORLD.AddEntity(e)
    return e
end 
--============================================================================
function QuadSound(pe)
    local player = EntityToObject[pe]
    --if not player then return end
    
    local wm = ENTITY.GetChildByName(pe,"items/item-wm-loop-mono") 
    local quad = ENTITY.GetChildByName(pe,"items/item-quad-loop-mono") 
    
    if quad ~= 0 then 
        if player and player == Player then
            SOUND.Play2D("items/item-quad-use-mono",100,true,true) 
        else
            local x,y,z = ENTITY.GetPosition(pe)
            PlaySound3D("items/item-quad-use-mono",x,y+2,z,15,50,player,true) 
        end
    end
    
    if wm ~= 0 then 
        if player and player == Player then
            SOUND.Play2D("items/item-wm-use-mono",100,true,true) 
        else
            local x,y,z = ENTITY.GetPosition(pe)
            PlaySound3D("items/item-wm-use-mono",x,y+2,z,15,50,player,true) 
        end
    end
         
end
--============================================================================
function Explosion(x,y,z,explosionStrength,explosionRange,clientID,attackType,damage,factorY)
    PlayLogicSound("EXPLOSION",x,y,z,15,30)
    if Game.GMode == GModes.SingleGame then 
        WORLD.Explosion2(x,y,z,explosionStrength,explosionRange,clientID,attackType,damage)    
    else        
        WORLD.MultiplayerExplosion(x,y,z,explosionStrength,explosionRange,clientID,attackType,damage,factorY)
    	--ENTITY.GetVelocity(Game.PlayerStats[666]._Entity
    	--local x,y,z = ENTITY.GetPosition(Game.PlayerStats[666]._Entity)
    	--ENTITY.SetPosition(Game.PlayerStats[666]._Entity,x,y+0.1,z)
    	--MsgBox("BANG"..clientID)
    	--if(clientID==666)then MsgBox("BANG"..clientID) Game.botshock = true end
    end    
    LastExplosion = {x,y,z,explosionStrength,explosionRange}
end
--============================================================================
function RadiusRandom2D(radius)
    local a = FRand(-radius,radius)
    local radius = radius - math.abs(a)/2
    local b = FRand(-radius,radius)
    if math.random(0,1) == 0 then return a,b end
    return b,a
end

function CanBurning(obj)
    return obj and obj.OnDamage and not obj.notBleeding and not obj.DisableFreeze and not (obj._Class == "CItem" and not obj.DestroyPack)        
end

function BurnObject(obj)
    if CanBurning(obj) then
        if not obj._burning then 
            local p = Templates["PBurningObject.CProcess"]:New(obj) 
            p:Init()
            GObjects:Add(TempObjName(),p)
        end  
    end
end
--============================================================================
function GlobalAIDisable()
	for i,v in Actors do
		if v.AIenabled then v.AIenabled = false end
	end
end
--============================================================================
function IsBooH()
    if __IsBooH then return __IsBooH end
    __IsBooH = FS.File_Exist("../Data/Maps/C6L6_Colloseum.mpk")
    return __IsBooH
end
--============================================================================
