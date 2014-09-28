--============================================================================
Editor = 
{
    Enabled = false,
    EditWayPoints = 0,
    EditFloors = 0,
    EditAcousticEnvs = false,    
    EditAreas = false,
    EditLights = false,
    EditSounds = false,
    EditBillboardsAndDecals = false,
    SelObj = nil, -- reference to selected object
    ToSelObj = nil,
    ObjEdited = false,
    LockMouse = false,
    LockAxis = false,
    IsRect = false,
    ofx=0,  
    ofy=0,
    Axis = "X",
    LMX=0,LMY=0,
    matLight = -1,
    matSound = -1,
    dir = Vector:New(0,0,0),
}
--============================================================================
function Editor:Init()
    if not self.Enabled then return end
    EWayPoints:Init()    
    if Lev then EDITOR.OnMsg("SelectObject",Lev._Name) end

    self.matLight = MATERIAL.Create("Editor/light")
    self.matSound = MATERIAL.Create("Editor/sound")    
end
--============================================================================
function Editor:Tick(delta)
    
    local menuActive = PMENU.Active()
    if not self.Enabled or menuActive then return end
    self.ObjEdited  = false

    local dx = (OMX - MX) * 0.05
    local dy = (OMY - MY) * 0.05
    self.LockMouse = false
        
    if MOUSE.RB() == 1 or MOUSE.LB() == 1 or MOUSE.MB() == 1 then
        self.LMX = MX
        self.LMY = MY
        self.ofx = 0
        self.ofy = 0
    end
   
    if INP.Key(Keys.LeftShift) == 2 then        
        self.ObjEdited = self:ObjectControl(dx,dy,delta)        
        if not self.ObjEdited then
            GObjects:EditTick(delta)
        elseif self.SelObj.EditTick then            
            self.SelObj:EditTick(delta)
        end
        if self.EditWayPoints == 1 then 
            EWayPoints:Tick(delta) 
        elseif self.EditFloors == 1 then 
            EFloors:Tick(delta) 
        elseif not self.ObjEdited then 
            self.ToSelObj = self:TrySelectObject()
        end        
            
        if INP.Key(Keys.K0)== 1 and self.SelObj and (self.SelObj.Rot or self.SelObj._Rot) then
            if self.SelObj.Rot then 
                self.SelObj.Rot = Quaternion:New()
                self.SelObj.Rot:ToEntity(self.SelObj._Entity)
            end
            if self.SelObj._Rot then 
                self.SelObj._Rot = Quaternion:New()
                self.SelObj._Rot:ToEntity(self.SelObj._Entity)
            end
        end
        if MOUSE.LB() == 1 or MOUSE.RB() == 1 then 
            self.IsRect = true  
        end
    else
        self:CameraControl(dx,dy,delta)
    end    
    
    if self.SelObj then
        if self.SelObj.Synchronize then self.SelObj:Synchronize() end
        if self.SelObj._Synchronize then self.SelObj:_Synchronize() end
    end

    if MOUSE.LB() == 3 or MOUSE.RB() == 3  or self.SelObj then  
        self.IsRect = false 
    end
    
    if self.LockMouse == true then
        MX,MY = self.LMX,self.LMY            
        MOUSE.SetPos(MX,MY)        
    end     
    
    if self.ToSelObj then
        self.SelObj = self.ToSelObj
        EDITOR.OnMsg("SelectObject",self.SelObj._Name) 
        if self.SelObj == Player then 
            self.SelObj = nil 
        end 
    end
    self.ToSelObj = nil    
    
    if INP.Key(Keys.LeftShift) == 2 and INP.Key(Keys.Z)== 1 and
       self.SelObj and self.SelObj._Entity then        
        
        local active = ENTITY.PO_IsEnabled(self.SelObj._Entity)
        if active then 
            Game:Print("Physics Object - deactivated")            
        else
            Game:Print("Physics Object - activated")
        end
        ENTITY.PO_Enable(self.SelObj._Entity,not active)
        
        if ENTITY.GetType(self.SelObj._Entity) ==  ETypes.Model then        
            active = MDL.IsRagdoll(self.SelObj._Entity)        
            if active then 
                Game:Print("Ragdoll - deactivated")
            else
                Game:Print("Ragdoll - activated")
            end
            MDL.EnableRagdoll(self.SelObj._Entity,not active,ECollisionGroups.RagdollNonColliding)
        end
    end    
    
    if self.SelObj and self.SelObj._ToKill then self.SelObj = nil end
    
end
--============================================================================
function Editor:TrySelectObject()
    if MOUSE.LB() == 1 then
	local useHavok = (INP.Key(Keys.A) == 2)
        local e = ENTITY.Pick(MX,MY,useHavok)        
        --Game:Print(e)
        local obj = EntityToObject[e]
        if obj then Game:Print(obj._Name) end
        self:SelectObject(obj)
        --if INP.Key(Keys.A) == 2 and e>0 and not obj then
	if e>0 and not obj then
            if ENTITY.GetType(e) ==  ETypes.Mesh then        
                Editor_EditEntity(e,"EMesh")
                EDITOR.OnMsg("SelectObject","EdEntity")         
            end
        end
        return obj
    end
    return nil
end
--============================================================================
function Editor:ObjectControl(dx,dy,delta)    
    if not self.SelObj or not self.SelObj.Pos then return false end                      
    if self.SelObj._Class == "CArea" then return false end

    local obj = self.SelObj      
    local ox,oy,oz = obj.Pos:Get()
    
    if obj._Entity and obj._Class ~= "CDecal" then ox,oy,oz = ENTITY.GetPosition(obj._Entity) end
    if obj.Impulse and INP.Key(Keys.Q) == 2 then 
        ox,oy,oz = obj.Impulse.Pos:Get() 
        ox = ox + obj.Pos.X
        oy = oy + obj.Pos.Y
        oz = oz + obj.Pos.Z
    end

    local ax,ay,az = 0,0,0
    if obj.angle then ax,ay,az = 0, obj.angle, 0  end
    if obj.Rot   then ax,ay,az = 0,0,0            end

    local rot = nil
    if INP.Key(Keys.LeftCtrl) == 2 then rot = self.SelObj.Rot end    
    local edited,x,y,z,ax,ay,az = Editor:MoveByAxis(ox,oy,oz,ax,ay,az,rot)        
    if edited then 
        if obj.Impulse and INP.Key(Keys.Q) == 2 then 
            obj.Impulse.Rot:RotateByAngleAxis(ax,self.dir.X,self.dir.Y,self.dir.Z)
            obj.Impulse.Pos:Set(x-obj.Pos.X,y-obj.Pos.Y,z-obj.Pos.Z)
        else    
            if obj._Entity and obj._Class ~= "CDecal" then ENTITY.SetVelocity(obj._Entity,0,0,0) end
            if obj.Rot then            
                if obj._Entity and obj._Class ~= "CDecal" then obj.Rot:FromEntity(obj._Entity) end                                
                obj.Rot:RotateByAngleAxis(ax,self.dir.X,self.dir.Y,self.dir.Z)
                if obj._Entity and obj._Class ~= "CDecal" then
                    obj.Rot:ToEntity(obj._Entity)
                    obj.Rot:FromEntity(obj._Entity) -- normalized
                end
            elseif obj._Rot then            
                obj._Rot:RotateByAngleAxis(ax,self.dir.X,self.dir.Y,self.dir.Z)                
            elseif obj.angle then
                if obj._Entity then ENTITY.SetOrientation(obj._Entity,obj.angle-ax) end
                obj.angle = obj.angle-ax
                obj._angleDest = obj.angle
            end
            if obj._Entity and obj._Class ~= "CDecal" then ENTITY.SetPosition(obj._Entity,x,y,z) end
    
            if obj.Synchronize then obj:Synchronize() end
            if obj._Synchronize then obj:_Synchronize() end
            
            obj.Pos:Set(x,y,z)
            if obj.EditOnChangePosition then obj:EditOnChangePosition() end
        end
    end
    
    return edited
end
--============================================================================
function Editor:CameraControl(dx,dy,delta)
       
    local cpos = Clone(Lev.Pos)
    local cang = Clone(Lev.Ang)
    local move = Vector:New(0,0,0)

    -- Krystian: The three keys below added for Omni ( wanted to check out sniper mode )
    --[[
    local CameraFOV = R3D.GetCameraFOV()
    if INP.Key(Keys.Equal) == 2 then 
        CameraFOV = CameraFOV + 1
    end
    if INP.Key(Keys.Minus) == 2 then 
        CameraFOV = CameraFOV - 1
    end
    if INP.Key(Keys.Backslash) == 2 then 
        CameraFOV = 90
    end
    R3D.SetCameraFOV( CameraFOV )
    ]]--

    if INP.Key(Keys.LeftCtrl) ~= 2 then 
        -- Camera movement
        if INP.Key(Keys.W) == 2 then 
            local x,y,z = CAM.GetForwardVector() 
            move:Add(x,y,z)
        end
        if INP.Key(Keys.S) == 2 then 
            local x,y,z = CAM.GetForwardVector() 
            move:Sub(x,y,z)
        end
        if INP.Key(Keys.D) == 2 then 
            local x,y,z = CAM.GetRightVector() 
            move:Add(x,y,z)
        end
        if INP.Key(Keys.A) == 2 then 
            local x,y,z = CAM.GetRightVector() 
            move:Sub(x,y,z)
        end        
    end
    
    -- only for keyboards
    move:MulByFloat(delta*35)
      
    if MOUSE.LB() == 2 then  
        local fx,fy,fz = CAM.GetForwardVector() 
        move:Add(fx*dy,fy*dy,fz*dy)        
        self.LockMouse = true        
    end   

    if MOUSE.RB() == 2 and MOUSE.LB() ~= 2  then  
        cang.X = cang.X - dx * 3
        cang.Y = cang.Y - dy * 3
        Lev.Ang:Set(cang)
        self.LockMouse = true
    end   
  
    if MOUSE.LB() == 2 and MOUSE.RB() == 2 then  
        move = Vector:New(0,0,0)
        local ux,uy,uz = CAM.GetUpVector() 
        local rx,ry,rz = CAM.GetRightVector()             
        move:Add(ux*dy+rx*-dx,uy*dy+ry*-dx,uz*dy+rz*-dx)
        self.LockMouse = true
    end   
    
    cpos.X = cpos.X + move.X * 0.8
    cpos.Y = cpos.Y + move.Y * 0.8
    cpos.Z = cpos.Z + move.Z * 0.8
    Lev.Pos:Set(cpos)
end
--============================================================================
function Editor:Render(delta)
    
    if not self.Enabled then return end          
    --R3D.RenderLine(1,1,1,1,1,1,R3D.RGB(200,0,0))
    GObjects:EditRender(delta)
    if self.SelObj and self.SelObj.Pos and self.SelObj._Class ~= "CArea" then
        if self.SelObj.Impulse and INP.Key(Keys.Q) == 2 then 
            self:DrawAxis(self.SelObj.Impulse.Pos.X+self.SelObj.Pos.X,self.SelObj.Impulse.Pos.Y+self.SelObj.Pos.Y,self.SelObj.Impulse.Pos.Z+self.SelObj.Pos.Z)
        else
            if INP.Key(Keys.LeftCtrl) == 2 then 
                self:DrawAxis(self.SelObj.Pos.X,self.SelObj.Pos.Y,self.SelObj.Pos.Z,self.SelObj.Rot)
            else
                self:DrawAxis(self.SelObj.Pos:Get())
            end
        end
    end

    if self.IsRect then
        HUD.DrawRect(self.LMX,self.LMY,MX,MY,R3D.RGB(55,255,55))
    end
       
    if self.SelObj and self.SelObj._Entity then 
        ENTITY.RenderBBox(self.SelObj._Entity) 
    end
    if self.EditWayPoints == 1 then EWayPoints:Render() end        
end
--============================================================================
function Editor:OnMsg(msg,value)    
    if msg == "OnEnableWPEdit" then self.EditWayPoints = value end    
    if msg == "OnEnableFloorsEdit" then self.EditFloors = value end
    if msg == "OnEnableAreas" then self.EditAreas = value end
    if msg == "OnEnableLights" then self.EditLights = value end
    if msg == "OnEnableSounds" then self.EditSounds = value end
    if msg == "OnEnableAcousticEnvs" then self.EditAcousticEnvs = value end    
    self.SelObj = nil    
end
--============================================================================
function Editor:SelectObject(obj)
    EdEntity = nil
    if not obj then 
        self.SelObj = nil 
        return
    end      
    self.ToSelObj = obj    
    if obj.Synchronize then obj:Synchronize() end
    if obj._Synchronize then obj:_Synchronize() end
end
--============================================================================
function Editor:FindFreeName(name)    
    
    local l = string.len(name)
    for i=l,1,-1 do 
        local code = string.byte(string.sub(name,i,i))
        if  code < string.byte('0') or code > string.byte('9') then
            name = string.sub(name,1,i)
            break
        end
    end
        
    for i=1,9999 do
        local fname = name .. string.format("%03d",i)
        if not getfenv()[fname] then return fname end
    end
    return TempObjName()
end
--============================================================================
function Editor:CloneObject(obj,thesameplace)    
    local o = GObjects:Clone(self:FindFreeName(obj._Name),obj)   
    if not thesameplace then
        o.Pos = OppositeToCamera()
    else
        o.Pos = Clone(obj.Pos)
    end    
    o:Apply()    
    EDITOR.OnMsg("SelectObject",o._Name) 
    ENTITY.PO_Enable(o._Entity,false)
    return o
end
--============================================================================
function Editor:AddObject(obj,name)
    if not name then name = self:FindFreeName(obj._Name.."_") end 
    local o = GObjects:Add(name,obj)   
    o.Pos = OppositeToCamera()
    o:Apply()
    EDITOR.OnMsg("SelectObject",name) 
    return o
end
--============================================================================
function Editor:DrawAxis(x,y,z,rot)    
   
    local l = R3D.DistToCamera(x,y,z) * 0.20    
    local bs = l * 0.04
    
    local x1,y1,z1 = l,0,0
    if rot then x1,y1,z1 = rot:TransformVector(x1,y1,z1) end
    R3D.RenderLine(x,y,z,x+x1,y+y1,z+z1,R3D.RGB(200,0,0),false)
    R3D.RenderBox(x+x1-bs,y+y1-bs,z+z1-bs,x+x1+bs,y+y1+bs,z+z1+bs,R3D.RGB(200,100,100),false)
    
    local x1,y1,z1 = 0,l,0
    if rot then x1,y1,z1 = rot:TransformVector(x1,y1,z1) end
    R3D.RenderLine(x,y,z,x+x1,y+y1,z+z1,R3D.RGB(0,200,0),false)
    R3D.RenderBox(x+x1-bs,y+y1-bs,z+z1-bs,x+x1+bs,y+y1+bs,z+z1+bs,R3D.RGB(100,200,100),false)

    local x1,y1,z1 = 0,0,l
    if rot then x1,y1,z1 = rot:TransformVector(x1,y1,z1) end
    R3D.RenderLine(x,y,z,x+x1,y+y1,z+z1,R3D.RGB(0,0,200),false)
    R3D.RenderBox(x+x1-bs,y+y1-bs,z+z1-bs,x+x1+bs,y+y1+bs,z+z1+bs,R3D.RGB(100,100,200),false)
        

    R3D.RenderBox(x-bs,y-bs,z-bs,x+bs,y+bs,z+bs,R3D.RGB(50,50,50),false)
end
--============================================================================
function Editor:MoveByAxis(x,y,z,ax,ay,az,rot)
    
    local edited = false        
    local sx,sy,sz = R3D.VectorToScreen(x,y,z)            
    local l = R3D.DistToCamera(x,y,z) * 0.20

    if MOUSE.LB() == 1 or  (MOUSE.RB() == 1 and (self.SelObj.Ang or self.SelObj.Rot or self.SelObj._Rot or self.SelObj.angle))then          
        
        local x1,y1,z1 = l,0,0
        if rot then x1,y1,z1 = rot:TransformVector(x1,y1,z1) end
        local sx1,sy1 = R3D.VectorToScreen(x+x1,y+y1,z+z1)    
        if R3D.DistToLine2D(MX,MY,sx,sy,sx1,sy1) < 10 then 
            self.LockAxis = true
            self.Axis = 'X'
            edited = true
            self.dir:Set(x1,y1,z1)
        end

        local x1,y1,z1 = 0,0,l
        if rot then x1,y1,z1 = rot:TransformVector(x1,y1,z1) end
        local sx1,sy1 = R3D.VectorToScreen(x+x1,y+y1,z+z1)    
        if R3D.DistToLine2D(MX,MY,sx,sy,sx1,sy1) < 10 then 
            self.LockAxis = true
            self.Axis = 'Z'
            edited = true
            self.dir:Set(x1,y1,z1)
        end

        local x1,y1,z1 = 0,l,0
        if rot then x1,y1,z1 = rot:TransformVector(x1,y1,z1) end
        local sx1,sy1 = R3D.VectorToScreen(x+x1,y+y1,z+z1)    
        if R3D.DistToLine2D(MX,MY,sx,sy,sx1,sy1) < 10 then 
            self.LockAxis = true
            self.Axis = 'Y'
            edited = true
            self.dir:Set(x1,y1,z1)
        end
        
         if R3D.DistToLine2D(MX,MY,sx,sy,sx,sy) < 10 then 
            self.LockAxis = true
            self.Axis = 'Free'
            edited = true
        end

        self.ofx = math.floor(MX - sx)
        self.ofy = math.floor(MY - sy)        
        if MOUSE.RB() == 1 and ax then self.Axis = 'A' .. self.Axis end
    end
   
    if self.LockAxis then          
        if MOUSE.LB() == 2 then -- position            
            local nx,ny,nz = R3D.ScreenTo3D(MX-self.ofx,MY-self.ofy,sz)
            if self.Axis == 'Free' then
                x,y,z = nx,ny,nz
            else
                x,y,z =  R3D.ClosestPointOnLine(nx,ny,nz,x-self.dir.X*1000,y-self.dir.Y*1000,z-self.dir.Z*1000,x+self.dir.X*1000,y+self.dir.Y*1000,z+self.dir.Z*1000)
            end    
        end
        
        if MOUSE.RB() == 2 then -- rotation            
            if math.abs(OMX-MX) > math.abs(OMY-MY) then
                ax = (OMX-MX)/100
            else
                ax = (OMY-MY)/100
            end
            if self.Axis == 'AZ' then ax = -ax end
            self.LockMouse = true
        end
        edited = true
    end
    
    if MOUSE.LB() == 3 or MOUSE.RB() == 3 then  
        self.LockAxis = false
    end
    
    return edited,x,y,z,ax,ay,az
end
--============================================================================
function GetJointPos(model,jointname,x,y,z)
    local j = MDL.GetJointIndex(model,jointname)
    if not x then x=0;y=0;z=0 end
    return  MDL.TransformPointByJoint(model,j,x,y,z)
end
--============================================================================
function Editor_EditEntity(entity,class)
    if entity <=0 then return end
    local obj = EntityToObject[entity]
    if obj then 
        Editor:SelectObject(obj)
        EdEntity = obj
    elseif getfenv()[class] then
        local eo = Clone(getfenv()[class])
        eo._Name = ENTITY.GetName(entity)
        eo._Entity = entity        
        local nofile = true
        local fname = "../Data/Levels/"..Lev._Name.."/MapEntities/"..eo._Name.."."..eo._Class
        local f = io.open (fname,"r")        
        if f ~= nil then 
            nofile = false 
            io.close(f)
        end        
        o = eo
        DoFile(fname,false)
        eo:Get(entity,nofile)
        Editor.SelObj = eo
        EdEntity = eo
    else
        Editor:SelectObject(nil)
    end
end
--============================================================================
