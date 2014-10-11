--============================================================================
PSpectatorControler.player = -1
o.angX = 0
o.angY = 0
o.mode = 1
o._entCam = nil
o._lastCamPos = Vector:New(0,0,0)
o._currentCamPos = Vector:New(0,0,0)
o._newCamPos = Vector:New(0,0,0)
o._desiredCamPos = Vector:New(0,0,0)
o._lastCamAng = Vector:New(0,0,0)
o._currentCamAng = Vector:New(0,0,0)
o._newCamAng = Vector:New(0,0,0)
o._desiredCamAng = Vector:New(0,0,0)
o.averagetickcountang = 10
o.tickcountang = 1
o.averagetickcountpos = 10
o.tickcountpos = 1
o.cameraframes = 0
o.autocameraframes = 0
o.autocameraswitch = 0
o.autocameramode= 0
o.cameraposition = Vector:New(0,0,0)
o.goodstatic = 0
o.autoineyes = 0

CameraStates = 
{
    Float = 0,
    InEyes   = 1,
    Pivot = 2,
    Static  = 3,
    Follow = 4,
    Auto = 5,
    Mapview = 6
}

--Inherit(PSpectatorControler,CProcess)
--============================================================================
function PSpectatorControler:New()
    local p = Clone(self)--PSpectatorControler)
    return p
end
--============================================================================
function PSpectatorControler:SetPlayerVisibility(e,enable,state)
     
    ENTITY.EnableDraw(e,enable,true)    
	
    
    --[[
    MDL.SetMeshVisibility(e,"-all-",true)
    
    if enable then
        MDL.SetMeshVisibility(e,"PKW_korpusShape",false)
        MDL.SetMeshVisibility(e,"PKW_HeadShape",false)
        MDL.SetMeshVisibility(e,"ASG_bodyShape",false)
        MDL.SetMeshVisibility(e,"stake",false)
        MDL.SetMeshVisibility(e,"rl",false)
        MDL.SetMeshVisibility(e,"pCylinderShape1",false)
        MDL.SetMeshVisibility(e,"pCylinderShape2",false)
        MDL.SetMeshVisibility(e,"polySurfaceShape450",false)
        MDL.SetMeshVisibility(e,"polySurfaceShape455",false)
    end
    
    if state then
        -- painkiller
        if state == 1 or state == 11 or state == 12 or state == 13 then
            MDL.SetMeshVisibility(e,"PKW_korpusShape",enable)
        end
        -- shotgun
        if state == 2 or state == 21 then
            MDL.SetMeshVisibility(e,"ASG_bodyShape",enable)
        end
        -- stakegun
        if state == 3 or state == 31 then
            MDL.SetMeshVisibility(e,"stake",enable)
        end            
        -- minigun
        if state == 4 or state == 41 then
            MDL.SetMeshVisibility(e,"rl",enable)
        end
        -- spawara
        if state == 5 or state == 51 then
            MDL.SetMeshVisibility(e,"pCylinderShape1",enable)
            MDL.SetMeshVisibility(e,"pCylinderShape2",enable)
            MDL.SetMeshVisibility(e,"polySurfaceShape450",enable)
            MDL.SetMeshVisibility(e,"polySurfaceShape455",enable)
        end
    end
    
    if not enable then
        MDL.SetMeshVisibility(e,"-invert-")
    end 
    --]]    
end
--============================================================================
function PSpectatorControler:Init()
		Hud.Enabled = false
		MOUSE.Lock(true)
		self._entCam =  ENTITY.Create(ETypes.Mesh,"../Data/Items/granat.dat","polySurfaceShape234",1)   
		ENTITY.PO_Create(self._entCam,BodyTypes.Sphere,0.3,ECollisionGroups.InsideItems)
		ENTITY.PO_EnableGravity(self._entCam,false)
		ENTITY.PO_SetMovedByExplosions(self._entCam, false) 
		ENTITY.PO_HideFromPrediction(self._entCam)
		ENTITY.SetPosition(self._entCam,Lev.Pos.X,Lev.Pos.Y,Lev.Pos.Z)
		self._lastCamPos:Set(Lev.Pos)
		ENTITY.PO_SetMissile( self._entCam, MPProjectileTypes.Spectator )
    Mapview:Load(Lev.Map)  
    self._matMapView            = MATERIAL.Create("../PKPlusData/Textures/Electro.tga", TextureFlags.NoLOD + TextureFlags.NoMipMaps)  
    local filename = string.gsub (Lev.Map,"(%a+).mpk", "%1")
    self._matMapView = MATERIAL.Create("../mapview/"..filename..".tga", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
    --MsgBox("../mapview/"..filename..".tga")
    	self._matAmmoMiniIcon = MATERIAL.Create("HUD/minigun", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
	self._matAmmoRocketIcon = MATERIAL.Create("HUD/rocket", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
	self._matAmmoIcon = MATERIAL.Create("HUD/kolki", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
	self._matAmmoRocketIcon = MATERIAL.Create("HUD/rocket", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
	self._matAmmoIcon1 = MATERIAL.Create("HUD/bolty", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
	self._matAmmoIcon2 = MATERIAL.Create("HUD/kulki", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
	self._matAmmoIconED = MATERIAL.Create("HUD/ikona_szuriken", TextureFlags.NoLOD)
	self._matAmmoElectroIcon = MATERIAL.Create("HUD/ikona_electro", TextureFlags.NoLOD)
	self._matAmmoOpenIcon = MATERIAL.Create("HUD/painkiller_open", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
	self._matAmmoCloseIcon = MATERIAL.Create("HUD/painkiller_close", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
	self._matInfinity = MATERIAL.Create("HUD/infinity", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
	self._matAmmoIconRFT = MATERIAL.Create("HUD/rifle", TextureFlags.NoLOD)
	self._matAmmoElectroIcon = MATERIAL.Create("HUD/ikona_flamer", TextureFlags.NoLOD)
	self._matAmmoIconSG = MATERIAL.Create("HUD/shell", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
	self._matFreezerIcon = MATERIAL.Create("HUD/ikona_freezer", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
        self._matMapViewBluePlayerIcon = MATERIAL.Create("../PKPlusData/Textures/team_blue.tga", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
        self._matMapViewRedPlayerIcon = MATERIAL.Create("../PKPlusData/Textures/team_red.tga", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
        self._matMapViewRespawn = MATERIAL.Create("../PKPlusData/Textures/respawn.tga", TextureFlags.NoLOD + TextureFlags.NoMipMaps)
 
end
--============================================================================
function PSpectatorControler:Delete()
    local ps = Game.PlayerStats[self.player]
    if ps and ps._Entity and ps._Entity ~=0 and ps.Spectator == 0 then            
        self:SetPlayerVisibility(ps._Entity,true)
    end
end
--============================================================================
function PSpectatorControler:NextPlayer(tab,idx)
    local getnext
    for i,o in tab do
		self:SetPlayerVisibility(o._Entity,true)
        if getnext and o.Spectator == 0 then
            -- next
            return i,o
        end
        if idx == i then
          getnext = true  
        end
    end
    -- first
    for i,o in tab do
        if o.Spectator == 0 then
            return i,o
        end
    end    
end
--============================================================================
function PSpectatorControler:PostRender(delta)
if(not Hud) then return end
	local w,h = R3D.ScreenSize()
	
	if Cfg.DisableHud then return end
	
        local cameramode = "FLOATCAM"
        if(self.mode==0)then cameramode = "FLOATCAM" end
        if(self.mode==1)then cameramode = "EYECAM" end
        if(self.mode==2)then cameramode = "PIVOTCAM" end
        if(self.mode==3)then cameramode = "STATICCAM" end
        if(self.mode==4)then cameramode = "FOLLOWCAM" end
        if(self.mode==5)then cameramode = "AUTOCAM" end
        local cmx = (w/2-1.5*HUD.GetTextWidth(cameramode)/2)
        local cmy = h-28*h/480
        
        HUD.PrintXY(cmx+2,cmy+2,cameramode,"Impact",0,0,0,36)
				HUD.PrintXY(cmx,cmy,cameramode,"Impact",160,160,160,36)

    if not (MPCfg.GameMode == "Last Man Standing" and (MPCfg.GameState == GameStates.Playing or MPCfg.GameState == GameStates.Finished)) then
        --HUD.PrintXY(w-HUD.GetTextWidth(Languages.Texts[726])-10*w/1024+1,h-30*h/768+1,Languages.Texts[726],"Impact",10,10,10,26*h/480)
        --HUD.PrintXY(w-HUD.GetTextWidth(Languages.Texts[726])-10*w/1024,h-30*h/768,Languages.Texts[726],"Impact",230,161,97,26*h/480)
    end

    local ps = Game.PlayerStats[self.player]
    if ps then
    	  local pnx = w/2-1.8*HUD.GetTextWidth(HUD.StripColorInfo(ps.Name))/2
    	  local pny = 125*h/768
        HUD.PrintXY(-1,pny+3,HUD.StripColorInfo(ps.Name),"Impact",0,0,0,60)
        HUD.PrintXY(-1,pny,ps.Name,"Impact",255,255,255,60)
        
        if(Cfg.MapView)then
        	self:DrawMapview() 
        end
        
    end

	Hud:DrawTeamScores(self.player)
	if self.player ~= -1 and self.mode == CameraStates.Follow or self.player ~= -1 and self.mode == CameraStates.Auto and self.autoineyes == 1 then
		self:SpectatorHUD()
	end
	if self.player ~= -1 and self.mode == CameraStates.InEyes or self.player ~= -1 and self.mode == CameraStates.Auto and self.autoineyes == 1 then
		Hud:QuadRGBA(Hud._matCrosshair,w/2,h/2,Hud.CrossScale,true,255,255,255,Cfg.CrosshairTrans/100.0*96)
		self:SpectatorHUD()
	end
end
--============================================================================
function PSpectatorControler:Teleport(x,y,z,a) 
    ENTITY.SetPosition(self._entCam,x,y,z)
    self._lastCamPos:Set(x,y,z)
    ENTITY.SetOrientation(self._entCam,a)
    CAM.SetAng(-a / (math.pi/180) - 180, 0, 0)
end
--============================================================================
function PSpectatorControler:InterpolatePosition()  
        -- interpolation
        if(((self._newCamPos.X ~= self._desiredCamPos.X) or self._newCamPos.Y ~= self._desiredCamPos.Y) or (self._newCamPos.Z ~= self._desiredCamPos.Z)) then      
		self._lastCamPos:Set(self._newCamPos.X,self._newCamPos.Y,self._newCamPos.Z)
		self._newCamPos:Set(self._desiredCamPos.X,self._desiredCamPos.Y,self._desiredCamPos.Z)
		self.averagetickcountpos = self.averagetickcountpos - (self.averagetickcountpos - self.tickcountpos)/100.0
        	if(self.averagetickcountpos==0)then self.averagetickcountpos = 1 end
		self.tickcountpos = 0	
	end
        local diff = Vector:New(0,0,0) 
        diff.X = self._newCamPos.X - self._lastCamPos.X
        diff.Y = self._newCamPos.Y - self._lastCamPos.Y
        diff.Z = self._newCamPos.Z - self._lastCamPos.Z  
        self._currentCamPos.X = self._lastCamPos.X + diff.X / (self.averagetickcountpos * 1.0)
        self._currentCamPos.Y = self._lastCamPos.Y + diff.Y / (self.averagetickcountpos * 1.0)
        self._currentCamPos.Z = self._lastCamPos.Z + diff.Z / (self.averagetickcountpos * 1.0)
 	self.tickcountpos = self.tickcountpos + 1
        CAM.SetPos(self._currentCamPos.X,self._currentCamPos.Y,self._currentCamPos.Z)
end
--============================================================================
function PSpectatorControler:InterpolateAngle()  
        -- interpolation
        if(((self._newCamAng.X ~= self._desiredCamAng.X) or self._newCamAng.Y ~= self._desiredCamAng.Y) or (self._newCamAng.Z ~= self._desiredCamAng.Z)) then      
		self._lastCamAng:Set(self._newCamAng.X,self._newCamAng.Y,self._newCamAng.Z)
		self._newCamAng:Set(self._desiredCamAng.X,self._desiredCamAng.Y,self._desiredCamAng.Z)
		self.averagetickcountang = self.averagetickcountang - (self.averagetickcountang - self.tickcountang)/100.0
        	if(self.averagetickcountang==0)then self.averagetickcountang = 1 end
		self.tickcountang = 0	
	end		
        local diff = Vector:New(0,0,0) 
        diff.X = self._newCamAng.X - self._lastCamAng.X
        diff.Y = self._newCamAng.Y - self._lastCamAng.Y
        diff.Z = self._newCamAng.Z - self._lastCamAng.Z  
        self._currentCamAng.X = self._lastCamAng.X + diff.X / (self.averagetickcountang * 1.0)
        self._currentCamAng.Y = self._lastCamAng.Y + diff.Y / (self.averagetickcountang * 1.0)
        self._currentCamAng.Z = self._lastCamAng.Z + diff.Z / (self.averagetickcountang * 1.0)
 	self.tickcountang = self.tickcountang + 1
        CAM.SetAng(self._currentCamAng.X,self._currentCamAng.Y,self._currentCamAng.Z)
end
--============================================================================
function PSpectatorControler:Float() 

    if not MOUSE.IsLocked() then return end 
    local dx,dy = MOUSE.GetDelta()
    if Cfg.InvertMouse then dy = - dy end
 
        local ax,ay,az = CAM.GetAng()
        ax = ax + dx        
        ay = ay + dy
        
        if ay > 80  then  ay = 80 end
        if ay < -80 then  ay = -80 end
    
        CAM.SetAng(ax,ay,az)
        self._desiredCamAng:Set(ax,ay,az)
        local ox,oy,oz = CAM.GetPos()
        local move = Vector:New(0,0,0)
        -- Camera movement
        if INP.Action(Actions.Forward) then 
            local x,y,z = CAM.GetForwardVector() 
            move:Add(x,y,z)
        end
        if INP.Action(Actions.Backward) then 
            local x,y,z = CAM.GetForwardVector()
            move:Sub(x,y,z)
        end
        if INP.Action(Actions.Right) then 
            local x,y,z = CAM.GetRightVector() 
            move:Add(x,y,z)
        end
        if INP.Action(Actions.Left) then 
            local x,y,z = CAM.GetRightVector() 
            move:Sub(x,y,z)
        end                    
        move:Normalize()
        ENTITY.SetVelocity(self._entCam,move.X*15,move.Y*15,move.Z*15)
        -- interpolation
        if(true)then
        local x,y,z = ENTITY.GetWorldPosition(self._entCam)    
        local destPos = Vector:New(x,y,z)
        local diff = destPos:Copy()
        diff:Sub(self._lastCamPos)
        if diff:Len() < 3 then
            destPos.X = self._lastCamPos.X + diff.X * 0.33
            destPos.Y = self._lastCamPos.Y + diff.Y * 0.33
            destPos.Z = self._lastCamPos.Z + diff.Z * 0.33
        end
        self._lastCamPos = destPos
        CAM.SetPos(destPos.X,destPos.Y,destPos.Z)
        self._desiredCamPos:Set(destPos.X,destPos.Y,destPos.Z)
        end
end
--============================================================================
function PSpectatorControler:InEyes() 
        local ps = Game.PlayerStats[self.player]
        if ps and ps._Entity and ps._Entity ~=0 and ps.Spectator == 0 and ps._animproc then   		
		self:SetPlayerVisibility(ps._Entity,false,ps._animproc.State)
		local ap = ps._animproc                
		local x,y,z = ENTITY.PO_GetPawnHeadPos(ps._Entity) 
		local a = ENTITY.GetOrientation(ps._Entity)
		local ax = -a / (math.pi/180) - 180
		local ay = ap._LastPitch / (math.pi/180)
		local az = 0
		CAM.SetAng(ax,ay,az)
		self._desiredCamAng:Set(ax,ay,az)
		CAM.SetPos(x,y,z)	
		self._desiredCamPos:Set(x,y,z)
	end
end
--============================================================================
function PSpectatorControler:Pivot() 
    if not MOUSE.IsLocked() then return end 
    local dx,dy = MOUSE.GetDelta()
    if Cfg.InvertMouse then dy = - dy end
    local ps = Game.PlayerStats[self.player]
    if ps and ps._Entity and ps._Entity ~=0 and ps.Spectator == 0 and ps._animproc then  
	self:SetPlayerVisibility(ps._Entity,true,ps._animproc.State)
	local v = Vector:New(0,0,5)
	self.angX = self.angX + dy/40
	self.angY = self.angY + dx/40
	v:Rotate(self.angX,self.angY,0)
                
	local px,py,pz = ENTITY.GetPosition(ps._Entity)
	py = py + 0.8
	local b,d,x,y,z = WORLD.LineTraceFixedGeom(px,py,pz,px+v.X, py+v.Y, pz+v.Z)
	if not b then
		x,y,z = px+v.X, py+v.Y, pz+v.Z
	else
		v:Normalize()
		x,y,z = x-v.X*0.3,y-v.Y*0.3,z-v.Z*0.3
	end
	CAM.SetPos(x,y,z)
	CAM.SetAngRad(-self.angY,-self.angX,0)
	self._desiredCamAng:Set(-self.angY,-self.angX,0)	
	self._desiredCamPos:Set(x,y,z)
    end
end
--============================================================================
function PSpectatorControler:Follow() 
    if not MOUSE.IsLocked() then return end 
    local dx,dy = MOUSE.GetDelta()
    if Cfg.InvertMouse then dy = - dy end
    local ps = Game.PlayerStats[self.player]
    if ps and ps._Entity and ps._Entity ~=0 and ps.Spectator == 0 and ps._animproc then  
	self:SetPlayerVisibility(ps._Entity,true,ps._animproc.State)
	local v = Vector:New(0,0,4)
	local ap = ps._animproc                
	local x,y,z = ENTITY.PO_GetPawnHeadPos(ps._Entity) 
	local a = ENTITY.GetOrientation(ps._Entity)
	local ax = -a / (math.pi/180) - 180
	local ay = ap._LastPitch / (math.pi/180) - 60
	v:Rotate(ay*(math.pi/180),-ax*(math.pi/180),0)    
	local px,py,pz = ENTITY.GetPosition(ps._Entity)
	py = py + 0.8
	local b,d,x,y,z = WORLD.LineTraceFixedGeom(px,py,pz,px+v.X, py+v.Y, pz+v.Z)
	if not b then
		x,y,z = px+v.X, py+v.Y, pz+v.Z
	else
		v:Normalize()
		x,y,z = x-v.X*0.3,y-v.Y*0.3,z-v.Z*0.3
	end
	CAM.SetPos(x,y,z)
	CAM.SetAngRad(ax*(math.pi/180),30*(math.pi/180),0)
	self._desiredCamAng:Set(ax*(math.pi/180),ay*(math.pi/180)+30*(math.pi/180),0)	
	self._desiredCamPos:Set(x,y,z)
    end
end
--============================================================================
function PSpectatorControler:Static() 
    if not MOUSE.IsLocked() then return end 
    local dx,dy = MOUSE.GetDelta()
    if Cfg.InvertMouse then dy = - dy end
    local ps = Game.PlayerStats[self.player]
    if ps and ps._Entity and ps._Entity ~=0 and ps.Spectator == 0 and ps._animproc then  
    local psx,psy,psz = ENTITY.GetPosition(ps._Entity)
    local min = 100000000 
    if(self.cameraframes  == 0 )then
	    local areas,cnt = GObjects:GetElementsWithFieldValue("_Name","PlayerRespawn*") 
	    for i=1,cnt do    
	        local area = areas[i]  
	        local p = area.Points[1]
	        local b,d,x,y,z = WORLD.LineTraceFixedGeom(psx,psy,psz,p.X,p.Y,p.Z)
	    	if(not b and Dist3D(psx,psy,psz,p.X,p.Y,p.Z) < min) then	
		    	self.cameraposition.X = p.X
		    	self.cameraposition.Y = p.Y
		    	self.cameraposition.Z = p.Z
		    	goodstatic = 1
		    	min = Dist3D(psx,psy,psz,self.cameraposition.X,self.cameraposition.Y,self.cameraposition.Z)
	    	end
	   end
	   self.cameraframes = 1
   end
   if(self.cameraframes>0)then self.cameraframes = self.cameraframes + 1 end
   if(self.cameraframes==60)then self.cameraframes = 0 end  
	self:SetPlayerVisibility(ps._Entity,true,ps._animproc.State)
	px = self.cameraposition.X
	py = self.cameraposition.Y
	pz = self.cameraposition.Z
	py=py+1
	CAM.SetPos(px,py,pz)
	local v = Vector:New((psx-px),(psy-py),(psz-pz))
	v.Y=v.Y+0.8
	v:Normalize()
	local arm = self:Length2D(v.X,v.Z)
	if(v.X<=0 and v.X ~= 0)then
		self.angle = math.atan(v.Z/v.X) * (180/math.pi) - 90
	end
	if(v.X>0 and v.X ~= 0)then
		self.angle = math.atan(v.Z/v.X) * (180/math.pi) + 90
	end
	if(arm~=0)then
		self.angle2 = -math.atan(v.Y/arm) * (180/math.pi)
	end
	self.x = v.X
	self.y = v.Y
	self.z = v.Z
	if self and self.angle and self.angle2 then
		CAM.SetAngRad(self.angle / (180/math.pi),self.angle2 / (180/math.pi),0) 
		self._desiredCamAng:Set(self.angle / (180/math.pi),self.angle2 / (180/math.pi),0)	
		self._desiredCamPos:Set(px,py,pz)
	end
    end
end
--============================================================================
function PSpectatorControler:Auto() 
	-- Should be done off gametime, but nm..
	if(self.autocameraframes == 0)then
		-- Change mode
		self.goodstatic = 0
		self.autocameramode = (math.random(4))
		if(self.autocameramode > 0)then self:Static() end
		if(self.autocameramode > 1 or self.goodstatic == 0)then self:InEyes() end
		if(self.autocameramode > 3)then self:Follow() end
		self.autocameraswitch = math.random(10)*60 + 125
		self.autocameraframes = 1
	end
	if(self.autocameramode > 0)then 
	self:Static() 
	self.autoineyes = 0 
	end
	if(self.autocameramode > 1)then 
	self:InEyes() 
	self.autoineyes = 1 
	end
	if(self.autocameramode > 3)then 
	self:Follow() 
	self.autoineyes = 1 
	end
	if(self.autocameraframes>0)then self.autocameraframes = self.autocameraframes + 1 end
	if(self.autocameraframes>self.autocameraswitch) then self.autocameraframes = 0 end
end
--============================================================================
function PSpectatorControler:Tick3(delta)   
    if self.mode == CameraStates.InEyes then
	self:InEyes()
	--self:InterpolatePosition()
	--self:InterpolateAngle() 	
    elseif self.mode == CameraStates.Pivot then
	self:Pivot()
	--self:InterpolatePosition()  
	--self:InterpolateAngle() 
    elseif self.mode == CameraStates.Follow then
	self:Follow()
	--self:InterpolatePosition()  
	--self:InterpolateAngle() 
    elseif self.mode == CameraStates.Static then
	self:Static()
	--self:InterpolatePosition()  
	--self:InterpolateAngle() 
    elseif self.mode == CameraStates.Auto then
	self:Auto()
	--self:InterpolatePosition()  
	--self:InterpolateAngle() 
    else
	self:Float()
	--self:InterpolatePosition()  
	--self:InterpolateAngle()  
    end
    self:CameraModeSwitch()
    self:ForceSpecCheck()
    
    if(Cfg.CameraInterpolatePosition)then
   	self:InterpolatePosition()
    end
    if(Cfg.CameraInterpolateAngle)then
	self:InterpolateAngle() 
    end
    if(Cfg.ConfigMapView)then
    	self:MapViewConfigure()
    end

end
--============================================================================
function PSpectatorControler:CameraModeSwitch()

	if( MPCfg.GameMode == "Race") then 
		--for i,o in Game.PlayerStats do    			HIDES OTHER PLAYERS
			--self:SetPlayerVisibility(o._Entity,false)
		--end
		return 
	end -- Race Additions [ THRESHER ]
     
    if INP.Action(Actions.Fire) then
        if not self._fire then
            Game:Print(self.player)
            self.player = self:NextPlayer(Game.PlayerStats,self.player)
            if not self.player then self.player = -1 end
            Game:Print(self.player)
        end
        self._fire = true
    else
        self._fire = nil
    end

    if INP.Action(Actions.AltFire) then
        if not self._altfire then
            self.mode = CameraStates.Float
        end
        self._altfire = true
        for i,o in Game.PlayerStats do
		self:SetPlayerVisibility(o._Entity,true)
	end
    else
        self._altfire = nil
    end

    
    if INP.Action(Actions.NextWeapon) then
	self.mode = self.mode + 1
	GObjects:ToKill(Game._procStats) 
	Game._procStats = nil
	MPSTATS.Hide()
	if(self.mode>5)then self.mode=0 end
    end
    
    if INP.Action(Actions.PrevWeapon) then
	self.mode = self.mode - 1
	GObjects:ToKill(Game._procStats) 
	Game._procStats = nil
	MPSTATS.Hide()
	if(self.mode<0)then self.mode=5 end
    end  
end
--============================================================================
function PSpectatorControler:ForceSpecCheck()
    if not (MPCfg.GameMode == "Last Man Standing" and (MPCfg.GameState == GameStates.Playing or MPCfg.GameState == GameStates.Finished)) then
        if INP.Action(Actions.Jump) then
            INP.Reset()
            MPSTATS.Hide()
            if Game._procStats then
                GObjects:ToKill(Game._procStats)
                Game._procStats = nil
            end
            Game.PlayerSpectatorRequest(NET.GetClientID(),0)
        end
    end
end
--============================================================================
function PSpectatorControler:Length2D(x,y)
  return math.sqrt( (x)*(x) + (y)*(y) )
end
--============================================================================
function PSpectatorControler:Length3D(x,y,z)
  return math.sqrt( (x)*(x) + (y)*(y) + (z)*(z) )
end
--============================================================================
function PSpectatorControler:SpectatorHUD() 
	if(not Hud) then return end
	local w,h = R3D.ScreenSize() 
 
    local ps = Game.PlayerStats[self.player]
     if ps then  
        local trans = HUD.GetTransparency()
        local sizex, sizey = MATERIAL.Size(Hud._matHUDLeft)
	--Hud:QuadTrans(Hud._matHUDLeft,0,(768-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false,trans)
	--Hud:QuadTrans(Hud._matHUDRight,(1024-Cfg.HUDSize*sizex)*w/1024,(768-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false,trans)
	--self:Quad(Hud._matHealth,Cfg.HUDSize*17*w/1024,((768+Cfg.HUDSize*14)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
        local he = 0
        local armor = 0
        local ammo1 = 0
        local ammo2 = 0
	local currentweaponindex = 0
	local armortype = 0
	local font ="Impact"
        
	local pd = Game.PlayerData[ps.ClientID]
	if(pd ~= nil)then
	        he = math.floor(pd.Health)
	        armor = math.floor(pd.Armour)
	        ammo1 = pd.Ammo1
	        ammo2 = pd.Ammo2
		currentweaponindex = pd.Weapon
		armortype = pd.ArmorType
		--MsgBox(pd.Weapon)
	end
	
	local ammo1warning = nil
	local ammo2warning = nil

	
if Cfg.Simplehud == true then

	-- [ THRESHER ]
	-- BEGIN ITEM TIMERS
	--local armorsWeak    = GObjects:GetElementsWithFieldValue( "_Name", "ArmorWeak*" )
	--local armorsMedium = GObjects:GetElementsWithFieldValue( "_Name", "ArmorMedium*" )
	--local armorsStrong   = GObjects:GetElementsWithFieldValue( "_Name", "ArmorStrong*" )

	-- search for armor and mega health items and store them into tables
	--[[
	local armorInfos = {}
		table.insert( armorInfos, GObjects:GetElementsWithFieldValue( "_Name", "ArmorStrong*" ) )
		table.insert( armorInfos, GObjects:GetElementsWithFieldValue( "_Name", "ArmorMedium*" ) )
		table.insert( armorInfos, GObjects:GetElementsWithFieldValue( "_Name", "ArmorWeak*" ) )
		
	local megaInfos = GObjects:GetElementsWithFieldValue( "_Name", "MegaHealth*" )
	
	local armorTimerSize = table.getn( armorInfos )
	
	local armPos = 0
		
	
	if armorTimerSize > 0 then
		
		for i = 1, armorTimerSize, 1 do
			-- need to make this so that if there are two of the same armors, they won't stack on top of eachother		
			if( armorInfos[ i ].BaseObj == "ArmorStrong.CItem" ) then 
			
				--table.insert( itemTimerTable, armorInfos[ i ] )
				
				Hud:QuadTrans( Hud._matArmorRed, (003)*w/1024, ( (100) + armPos )*h/768, 1, false, 255 ) 
				if armorInfos[ i ]._Rst > 0 then HUD.PrintXY( (048)*w/1024, ( (105) + armPos )*h/768, math.ceil( armorInfos[ i ]._Rst - INP.GetTime() ), font, 255, 255, 255, 25 ) end
			end
			
			if( armorInfos[ i ].BaseObj == "ArmorMedium.CItem" ) then 
			
				--table.insert( itemTimerTable, armorInfos[ i ] )
			
				Hud:QuadTrans(Hud._matArmorYellow, (003)*w/1024,( (100) + armPos )*h/768,1,false,255)
				if armorInfos[ i ]._Rst > 0 then HUD.PrintXY( (048)*w/1024, ( (105) + armPos )*h/768, math.ceil( armorInfos[ i ]._Rst - INP.GetTime() ), font, 255, 255, 255, 25 ) end
			end
			
			if( armorInfos[ i ].BaseObj == "ArmorWeak.CItem" ) then 
			
				--table.insert( itemTimerTable, armorInfos[ i ] )
			
				Hud:QuadTrans(Hud._matArmorGreen, (003)*w/1024,( (100) + armPos )*h/768,1,false,255) 
				if armorInfos[ i ]._Rst > 0 then HUD.PrintXY( (048)*w/1024, ( (105) + armPos )*h/768, math.ceil( armorInfos[ i ]._Rst - INP.GetTime() ), font, 255, 255, 255, 25 ) end
			end
			
			armPos = armPos + 50
			
		end

	end
	
	if  table.getn( megaInfos ) > 0 then
		for i = 1, table.getn( megaInfos ), 1 do
		
			Hud:QuadRGBA( Hud._matHealth, (003)*w/1024, ( (100) + armPos )*h/768, 1, false, 0, 144, 200, 255 )
			if megaInfos[ i ]._Rst > 0 then HUD.PrintXY( (048)*w/1024, ( (105) + armPos )*h/768, math.ceil( megaInfos[ i ]._Rst - INP.GetTime() ), font, 255, 255, 255, 25 ) end
		
			armPos = armPos + 50
		end
	end
	]]--
	--[[ END ITEM TIMERS ]]--
	
        if armortype == 0 then
	Hud:QuadTrans(Hud._matArmorNormal,(007)*w/1024,(722)*h/768,1,false,255)		
            if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),722*h/768,armor,font,0,0,0,50) end
            HUD.PrintXY((052*w/1024),720*h/768,armor,font,255,0,0,50)
	end

        if armortype == 1 then
	Hud:QuadTrans(Hud._matArmorGreen,(007)*w/1024,(722)*h/768,1,false,255)
	if armor > 50 then
            if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),722*h/768,armor,font,0,0,0,50) end
            HUD.PrintXY((052*w/1024),720*h/768,armor,font,100,70,20,50)
		else
	
            if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),722*h/768,armor,font,0,0,0,50) end
            HUD.PrintXY((052*w/1024),720*h/768,armor,font,255,0,0,50)
	end
	end

        if armortype == 2 then
	Hud:QuadTrans(Hud._matArmorYellow,(007)*w/1024,(722)*h/768,1,false,255)
	if armor > 50 then
            if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),722*h/768,armor,font,0,0,0,50) end
            HUD.PrintXY((052*w/1024),720*h/768,armor,font,190,210,250,50)
		else

            if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),722*h/768,armor,font,0,0,0,50) end
            HUD.PrintXY((052*w/1024),720*h/768,armor,font,255,0,0,50)
	end
	end
 
       if armortype == 3 then
	Hud:QuadTrans(Hud._matArmorRed,(007)*w/1024,(722)*h/768,1,false,255)
	if armor > 50 then	
            if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),722*h/768,armor,font,0,0,0,50) end
            HUD.PrintXY((052*w/1024),720*h/768,armor,font,230,200,0,50)
		else
	
            if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),722*h/768,armor,font,0,0,0,50) end
            HUD.PrintXY((052*w/1024),720*h/768,armor,font,255,0,0,50)
	end
        end

	if currentweaponindex == 1 then   
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),672*h/768,"XXX",font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),670*h/768,"XXX",font,255,255,255,50)
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),722*h/768,"XXX",font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),720*h/768,"XXX",font,255,255,255,50)
		end	

    	if currentweaponindex == 2 then
	Hud:QuadTrans(Hud._matShell,(870)*w/1024,(670)*h/768,1,false,255)
	Hud:QuadTrans(Hud._matFreezer,(870)*w/1024,(720)*h/768,1,false,255)
	
	if ammo1 < 5 then 
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),672*h/768,ammo1,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),670*h/768,ammo1,font,255,0,0,50)
	 	 if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),722*h/768,ammo2,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),720*h/768,ammo2,font,255,255,255,50)
	else
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),672*h/768,ammo1,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),670*h/768,ammo1,font,255,255,255,50)
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),722*h/768,ammo2,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),720*h/768,ammo2,font,255,255,255,50)
		end
		end

	if currentweaponindex == 3 then
	Hud:QuadTrans(Hud._matStake,(870)*w/1024,(670)*h/768,1,false,255)
	if ammo2 <= 5 then 
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),672*h/768,ammo1,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),670*h/768,ammo1,font,255,0,0,50)
	else
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),672*h/768,ammo1,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),670*h/768,ammo1,font,255,255,255,50)
		end
		end
	if currentweaponindex == 3 then
	Hud:QuadTrans(Hud._matRocket,(870)*w/1024,(720)*h/768,1,false,255)
	if ammo2 <= 5 then
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),722*h/768,ammo2,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),720*h/768,ammo2,font,255,0,0,50)
	else
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),722*h/768,ammo2,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),720*h/768,ammo2,font,255,255,255,50)
		end
		end


	if currentweaponindex == 4 then
	Hud:QuadTrans(Hud._matRocket,(870)*w/1024,(670)*h/768,1,false,255)
	if ammo2 <= 5 then
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),672*h/768,ammo1,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),670*h/768,ammo1,font,255,0,0,50)
	else
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),672*h/768,ammo1,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),670*h/768,ammo1,font,255,255,255,50)
		end
		end
	if currentweaponindex == 4 then
	Hud:QuadTrans(Hud._matMinigun,(870)*w/1024,(720)*h/768,1,false,255)
	if ammo2 <= 20 then
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),722*h/768,ammo2,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),720*h/768,ammo2,font,255,0,0,50)
	else
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),722*h/768,ammo2,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),720*h/768,ammo2,font,255,255,255,50)
		end
		end

	if currentweaponindex == 5 then
	Hud:QuadTrans(Hud._matElectro,(870)*w/1024,(670)*h/768,1,false,255)
	if ammo1 <= 15 then 
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),672*h/768,ammo1,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),670*h/768,ammo1,font,255,0,0,50)
	else
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),672*h/768,ammo1,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),670*h/768,ammo1,font,255,255,255,50)
		end
		end

	if currentweaponindex == 5 then
	Hud:QuadTrans(Hud._matSzuriken,(870)*w/1024,(720)*h/768,1,false,255)
	if ammo2 <= 7 then 
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),722*h/768,ammo2,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),720*h/768,ammo2,font,255,0,0,50)
	else
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),722*h/768,ammo2,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),720*h/768,ammo2,font,255,255,255,50)
		end
		end

	Hud:QuadTrans(Hud._matHealth,(007)*w/1024,(670)*h/768,1,false,255)
	if he < 25 then
	if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),672*h/768,he,font,0,0,0,50) end
	HUD.PrintXY((052*w/1024),670*h/768,he,font,255,0,0,50)
	elseif he > 100 then
	if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),672*h/768,he,font,0,0,0,50) end
	HUD.PrintXY((052*w/1024),670*h/768,he,font,25,200,60,50)
	else
	if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),672*h/768,he,font,0,0,0,50) end
	HUD.PrintXY((052*w/1024),670*h/768,he,font,255,255,255,50)
	end

else
	if(currentweaponindex==2)then
		ammo1warning = CPlayer.s_SubClass.AmmoWarning[Shotgun]
		ammo2warning = CPlayer.s_SubClass.AmmoWarning[IceBullets]
	end
	if(currentweaponindex==3)then
		ammo1warning = CPlayer.s_SubClass.AmmoWarning[Stakes]
		ammo2warning = CPlayer.s_SubClass.AmmoWarning[Grenades]
	end
	if(currentweaponindex==4)then
		ammo1warning = CPlayer.s_SubClass.AmmoWarning[Shotgun]
		ammo2warning = CPlayer.s_SubClass.AmmoWarning[MiniGun]
	end
	if(currentweaponindex==5)then
		ammo1warning = CPlayer.s_SubClass.AmmoWarning[Shurikens]
		ammo2warning = CPlayer.s_SubClass.AmmoWarning[Electro]
	end
	if(currentweaponindex==6)then
		ammo1warning = CPlayer.s_SubClass.AmmoWarning[Rifle]
		ammo2warning = nil
	end
	if(currentweaponindex==7)then
		ammo1warning = CPlayer.s_SubClass.AmmoWarning[Bolt]
		ammo2warning = CPlayer.s_SubClass.AmmoWarning[HeaterBomb]
	end

	Hud:DrawDigitsText(Cfg.HUDSize*52*w/1024,((768+Cfg.HUDSize*16)-Cfg.HUDSize*sizey)*h/768,string.sub(string.format("%03d",he),-3),0.9 * Cfg.HUDSize,CPlayer.HealthWarning)
	Hud:DrawDigitsText(Cfg.HUDSize*52*w/1024,((768+Cfg.HUDSize*50)-Cfg.HUDSize*sizey)*h/768,string.sub(string.format("%03d",armor),-3),0.9 * Cfg.HUDSize,nil)
  	Hud:DrawDigitsText((1024-118*Cfg.HUDSize)*w/1024,((768+Cfg.HUDSize*16)-Cfg.HUDSize*sizey)*h/768,string.sub(string.format("%03d",ammo1),-3),0.9 * Cfg.HUDSize,ammo1warning)
  	Hud:DrawDigitsText((1024-118*Cfg.HUDSize)*w/1024,((768+Cfg.HUDSize*50)-Cfg.HUDSize*sizey)*h/768,string.sub(string.format("%03d",ammo2),-3),0.9 * Cfg.HUDSize,ammo2warning)
	
    if currentweaponindex == 1 then
	Hud:Quad(self._matAmmoOpenIcon,(1024-62*Cfg.HUDSize)*w/1024,((768+Cfg.HUDSize*12)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
	Hud:Quad(self._matAmmoCloseIcon,(1024-62*Cfg.HUDSize)*w/1024,((768+Cfg.HUDSize*50)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
    elseif  Currentweaponindex == 2 then
	Hud:Quad(self._matAmmoIconSG,(1024-52*Cfg.HUDSize)*w/1024,((768+Cfg.HUDSize*11)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
	Hud:Quad(self._matFreezerIcon,(1024-55*Cfg.HUDSize)*w/1024,((768+Cfg.HUDSize*46)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
    elseif  currentweaponindex == 3 then
	Hud:Quad(self._matAmmoIcon,(1024-52*Cfg.HUDSize)*w/1024,((768+Cfg.HUDSize*11)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
	Hud:Quad(self._matAmmoRocketIcon,(1024-52*Cfg.HUDSize)*w/1024,((768+Cfg.HUDSize*49)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
    elseif  currentweaponindex == 4 then
	Hud:Quad(self._matAmmoMiniIcon,(1024-52*Cfg.HUDSize)*w/1024,((768+Cfg.HUDSize*49)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
	Hud:Quad(self._matAmmoRocketIcon,(1024-52*Cfg.HUDSize)*w/1024,((768+Cfg.HUDSize*17)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
    elseif  currentweaponindex == 5 then
	Hud:Quad(self._matAmmoIconED,(1024-56*Cfg.HUDSize)*w/1024,((768+Cfg.HUDSize*11)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
	Hud:Quad(self._matAmmoElectroIcon,(1024-52*Cfg.HUDSize)*w/1024,((768+Cfg.HUDSize*42)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
    elseif  currentweaponindex == 6 then
	Hud:Quad(self._matAmmoIconRFT,(1024-56*Cfg.HUDSize)*w/1024,((768+Cfg.HUDSize*12)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
	Hud:Quad(self._matAmmoElectroIcon,(1024-52*Cfg.HUDSize)*w/1024,((768+Cfg.HUDSize*47)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
    elseif  currentweaponindex == 7 then
	Hud:Quad(self._matAmmoIcon1,(1024-52*Cfg.HUDSize)*w/1024,((768+Cfg.HUDSize*11)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
	Hud:Quad(self._matAmmoIcon2,(1024-52*Cfg.HUDSize)*w/1024,((768+Cfg.HUDSize*49)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
    end
    
        if armortype == 0 then
            Hud:Quad(Hud._matArmorNormal,Cfg.HUDSize*17*w/1024,((768+Cfg.HUDSize*49)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
        elseif armortype == 1 then
            Hud:Quad(Hud._matArmorGreen,Cfg.HUDSize*17*w/1024,((768+Cfg.HUDSize*49)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
        elseif armortype == 2 then
            Hud:Quad(Hud._matArmorYellow,Cfg.HUDSize*17*w/1024,((768+Cfg.HUDSize*49)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
        elseif armortype == 3 then
            Hud:Quad(Hud._matArmorRed,Cfg.HUDSize*17*w/1024,((768+Cfg.HUDSize*49)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
	end
	
	--Hud:QuadRGBA(Hud._matCrosshair,w/2,h/2,Hud.CrossScale,true,255,255,255,Cfg.CrosshairTrans/100.0*96)
	Hud:Quad(Hud._matHealth,Cfg.HUDSize*17*w/1024,((768+Cfg.HUDSize*14)-Cfg.HUDSize*sizey)*h/768,Cfg.HUDSize,false)
	end
   end  
end
--============================================================================
function PSpectatorControler:DrawMapview() 
    if(not Hud) then return end
    local w,h = R3D.ScreenSize()
   
    --if(Mapview.globalscale==nil)then Mapview.globalscale = 2.0 end
    --if(Mapview.globaltranslatex==nil)then Mapview.globaltranslatex = 0.0 end
    --if(Mapview.globaltranslatey==nil)then Mapview.globaltranslatey = 0.0 end
    --if(Mapview.globaltranslaterot==nil)then Mapview.globaltranslaterot = 0.0 end
    --if(Mapview.imagescale ==nil)then Mapview.imagescale  = 2.0 end
    --if(Mapview.imagetranslatex==nil)then Mapview.imagetranslatex = 0.0 end
    --if(Mapview.imagetranslatey==nil)then Mapview.imagetranslatey = 300.0 end	
		   
	--MsgBox(globalscale)

    local sizex, sizey = MATERIAL.Size(self._matMapView)
    
    if(sizex==0)then sizex = 1 end
    if(sizey==0)then sizey = 1 end

    local xscale = 1.0
    if(w ~= 0.0)then
    	xscale = w / 800
    end
    local yscale = 1.0
    if(h ~= 0.0)then
    	yscale = h / 600
    end
    
    if(Cfg.ConfigMapView)then   
	    HUD.PrintXY(w/3,h/1.5,
	    "Scale (weapon1/2):"..tostring(Mapview.globalscale)..
	    "\nTransx (weapon3/4): "..tostring(Mapview.globaltranslatex)..
	    "\nTransy (weapon5/6):"..tostring(Mapview.globaltranslatey).. 
	    "\nTranslaterot (weapon7/8): "..tostring(Mapview.globaltranslaterot*180/math.pi)..
	    "\nIMAGE Scale (weapon8/9):"..tostring(Mapview.imagescale)..
	    "\nIMAGE Transx (weapon10/11): "..tostring(Mapview.imagetranslatex)..
	    "\nIMAGE Transy (weapon12/13):"..tostring(Mapview.imagetranslatey).. 
	    "\nScalex:"..tostring(xscale).."    sizex:"..tostring(sizex).. 
	    "\nScaley:"..tostring(yscale) .."    sizey:"..tostring(sizey)
	    ,"Impact",255,255,255,14*yscale)
    end
    
    local ix = Mapview.imagetranslatex
    local iy = Mapview.imagetranslatey
    local iw = Mapview.imagescale*sizex
    local id = Mapview.imagescale*sizey

--MsgBox("ix:"..tostring(ix).."iy:"..tostring(iy).."iw:"..tostring(iw).."id:"..tostring(id))
  
   HUD.DrawQuadRGBA(self._matMapView,xscale*ix,yscale*iy,xscale*iw,yscale*id,255,255,255,255)
   
    for id, ps in Game.PlayerStats do
    	if ps and ps._Entity and ps._Entity ~=0 and ps.Spectator == 0 and ps._animproc then  
    		local psx,pspiey,psz = ENTITY.GetPosition(ps._Entity)
    		
        	--psx = psx * math.cos(Mapview.globaltranslaterot) + psz * math.sin(Mapview.globaltranslaterot)
    		--psz = psx * math.cos(Mapview.globaltranslaterot) - psz * math.sin(Mapview.globaltranslaterot)
    
    		--MsgBox("localglobalscale:"..tostring(localglobalscale).."localimagescale:"..tostring(localimagescale).."localglobaltranslatex:"..tostring(localglobaltranslatex).."id:"..tostring(id))
   
    		local px = psx * Mapview.globalscale * Mapview.imagescale + Mapview.globaltranslatex * Mapview.imagescale
    		local py = psz * Mapview.globalscale * Mapview.imagescale + Mapview.globaltranslatey * Mapview.imagescale
    				
       		if(px < ix) then Mapview.globaltranslatex = (ix / Mapview.imagescale) - psx * Mapview.globalscale end
    		if(py < iy) then Mapview.globaltranslatey = (iy / Mapview.imagescale) - psz * Mapview.globalscale end
    		
    		if(px > (ix + iw)) then Mapview.globaltranslatex = ((ix + iw)/ Mapview.imagescale) - psx*Mapview.globalscale end
    		if(py > (Mapview.imagetranslatey + Mapview.imagescale*sizey)) then Mapview.globaltranslatey = ((Mapview.imagetranslatey + Mapview.imagescale*sizey)/ Mapview.imagescale) - psz*Mapview.globalscale end

		px = psx * Mapview.globalscale * Mapview.imagescale + Mapview.globaltranslatex * Mapview.imagescale
		py = psz * Mapview.globalscale * Mapview.imagescale + Mapview.globaltranslatey * Mapview.imagescale

    		if(ps.Team == 0)then		
    			if(yscale*py-yscale*18>0)then
    			HUD.PrintXY(xscale*px,yscale*py-yscale*18,ps.Name,"Impact",230,161,97,yscale*16)
    			end
    			HUD.DrawQuadRGBA(self._matMapViewBluePlayerIcon,xscale*px-xscale*20/2,yscale*py-yscale*20/2,xscale*20,yscale*20,255,255,255,255)
    		else
   			if(yscale*py-yscale*18>0)then
   			HUD.PrintXY(xscale*px,yscale*py-yscale*18,ps.Name,"Impact",230,161,97,yscale*16)
   			end
    			HUD.DrawQuadRGBA(self._matMapViewRedPlayerIcon,xscale*px-xscale*20/2,yscale*py-yscale*20/2,xscale*20,yscale*20,255,255,255,255)	--Hud:DrawQuadRGBA(Hud._matMapViewRedPlayerIcon,psx*playersscale+playertranslationx,psz*playersscale+playertranslationy,10,10,255,255,255,960)
  		end
    	end
    end
    if(Cfg.MapViewShowRespawns)then 
	    local areas,cnt = GObjects:GetElementsWithFieldValue("_Name","PlayerRespawn*") 
	    for i=1,cnt do    
	        local area = areas[i]  
	        local p = area.Points[1]
	        local px = p.X * Mapview.globalscale * Mapview.imagescale + Mapview.globaltranslatex * Mapview.imagescale
    		local py = p.Z * Mapview.globalscale * Mapview.imagescale + Mapview.globaltranslatey * Mapview.imagescale
	    	HUD.DrawQuadRGBA(self._matMapViewRespawn,xscale*px-xscale*20/2 ,yscale*py-yscale*20,xscale*20,yscale*20,255,255,255,255)
	    end

    end  
end
--============================================================================
--============================================================================
function PSpectatorControler:MapViewConfigure()
    if INP.Action(Actions.Weapon1) then
	Mapview.globalscale = Mapview.globalscale - 0.001
    end
    if INP.Action(Actions.Weapon2) then
	Mapview.globalscale = Mapview.globalscale + 0.001
    end   
    if INP.Action(Actions.Weapon3) then
	Mapview.globaltranslatex = Mapview.globaltranslatex - 1
    end
    if INP.Action(Actions.Weapon4) then
	Mapview.globaltranslatex = Mapview.globaltranslatex + 1
    end
     if INP.Action(Actions.Weapon5) then
	Mapview.globaltranslatey = Mapview.globaltranslatey - 1
    end   
    if INP.Action(Actions.Weapon6) then
	Mapview.globaltranslatey = Mapview.globaltranslatey + 1
    end
    if INP.Action(Actions.Weapon7) then
    	Mapview.globaltranslaterot = Mapview.globaltranslaterot - math.pi/200
    end 
    if INP.Action(Actions.Weapon8) then
    	Mapview.globaltranslaterot = Mapview.globaltranslaterot + math.pi/200
    end 
    if(Mapview.globaltranslaterot>=math.pi)then Mapview.globaltranslaterot=math.pi end
    if(Mapview.globaltranslaterot<=-math.pi)then Mapview.globaltranslaterot=-math.pi end
    
    if INP.Action(Actions.Weapon9) then
	Mapview.imagescale = Mapview.imagescale - 0.01
    end
    if INP.Action(Actions.Weapon10) then
	Mapview.imagescale = Mapview.imagescale + 0.01
    end
    if INP.Action(Actions.Weapon11) then
	Mapview.imagetranslatex = Mapview.imagetranslatex - 1
    end
    if INP.Action(Actions.Weapon12) then
	Mapview.imagetranslatex = Mapview.imagetranslatex + 1
    end   
    if INP.Action(Actions.Weapon13) then
	Mapview.imagetranslatey = Mapview.imagetranslatey - 1
    end
    if INP.Action(Actions.Weapon14) then
	Mapview.imagetranslatey = Mapview.imagetranslatey + 1
    end
    Mapview:Save(Lev.Map)  
end
