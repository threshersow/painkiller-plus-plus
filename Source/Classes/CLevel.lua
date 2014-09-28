--============================================================================
-- Level class
--============================================================================
CLevel = 
{
    Ang = Vector:New(0,0,0),
    Pos = Vector:New(0,0,0),
    Ambient = Color:New(50,50,50,0),
	GunAmbientMultiplier = 0.5,
    Name = "No Name Level",
    _MagicCard = nil,
	_CardTask = "",
    _freeMSlot = 0,
    _songInSlot = {[0]="",[1]=""},
    Map = "",
    Scale = 0.3,
    MusicTimeOut = 0,
    IsUnderwater = false,
	Overbright = false,
    --PhysicsMap = "",
    FarClipDist = 1024,
    Acoustics = 
    {
        Room = 
        {
          Type       = 0,
          Intensity  = 1,
          SwitchTime = 2, 
        },
        Player = 
        {
            Spurs  = true,
            Ground = 0,
        }
    },
    _Atmospheric = {
    },
    WayPointsMap = "",
    _checkRoomTypeDelay = 0,
    
    Music = 
    {
        Ambient = {},
        Battle = {},
    },
	
	Water = 
	{
		FresnelBias = 0,
		FresnelExponent = 2,
		DeepWaterColor = Color:New(150,150,100,0),
		ShallowWaterColor = Color:New(100,100,100,0),
		BumpHeight = 0.05,
		WaveAmplitude = 1,
		WaveFrequency = 1,		
		WaveSpeed = 1,
		WaterAmount = 1,
		ReflectionAmount = 1,
		WaterLevel = 0,
		ReflectScene = false,
		RefractScene = false,
		Pan = Vector:New(0.00172, 0.003, 0),
		Tile = Vector:New(17.5, 10, 1),
	},
    
    DemonFX = 
    {
        Scale = 4,
        Bias = -2.7,
		MBlur = 0.7,
    },

    BloomFX =
    {
        LuminanceThreshold = 0.25,
	Multiplier = 1,
	OverlayColor = Color:New(128,128,128,0),
	DimScale = 0.8,
    },
    
    ShadowMaps = 
    {
        Number = 24,
        Size = 128,
    },
    
    Volumetrics = {}, -- old, only for compatibility
    Physics = {
        ActiveMeshesMassScale = 1.0,
        DefaultMeshFriction = 0.5,
        DefaultMeshRestitution= 0.5,
        Deactivator = 
        {
            Delay = 5.0,
            MaxPosDiff = 0.3,
        }
    },
    SoundFalloffSpeed = 2,
    DynamicLighting = 
    {
        SpecularColor = Color:New(128,128,128,0),
        SpecularPower = 20,        
    },
    DirLight = 
    {
        Dir = Vector:New(-0.7,-0.7,-0.7),
        Color = Color:New(150,150,100,0),
        Intensity = 1,
    },  
    Fog = 
    {
        Mode		= 0, -- 0=no fog, 1=exp, 2=exp2, 3=linear
        Start		= 0,
        End		    = 90,
        Density		= 0.002,
        Color = Color:New(255,150,150,0),
    },
    DetailMap =
    {
        Tex = "special/detail",
        TileU = 8.2,
        TileV = 7.1,
    },
    CubeMap =
    {
        Tex = "",
    },
	RTCubeMap = false,
    NormalMap =
    {
        Tex = "",
    },
    SkySpecularCubeMap =
    {
	Tex = "",
    },
    Sky = {},
    SkyDome = 
    {
        _Layers = 0,
        Map = "",
		LowQuality = 
		{
			_Layers = 0,
			Map = "",
			Tex = "clouds",
			Height = 0,
			Angle = 0,
		},
        Layer1 = 
        {
            Tex_Mask   = "white",
            Tex_LMap   = "white",
            Tex1 = "clouds",
            Tex1RotSpeed   = 0, -- uv-rotation speed
            Tex1PanUSpeed  = 0, -- cloud layer 1 u-translation speed
            Tex1PanVSpeed  = 0, -- cloud layer 1 v-translation speed
            Tex1TileU	   = 1,	 -- cloud layer 1 u-tiling
            Tex1TileV	   = 1,	 -- cloud layer 1 v-tiling
            Tex2 = "clouds",
            Tex2RotSpeed   = 0, -- uv-rotation speed
            Tex2PanUSpeed  = 0, -- cloud layer 1 u-translation speed
            Tex2PanVSpeed  = 0, -- cloud layer 1 v-translation speed
            Tex2TileU	   = 1,	 -- cloud layer 1 u-tiling
            Tex2TileV	   = 1,	 -- cloud layer 1 v-tiling
        },
        Layer2 = 
        {
            Tex_Mask   = "white",
            Tex_LMap   = "white",
            Tex1 = "clouds",
            Tex1RotSpeed   = 0, -- uv-rotation speed
            Tex1PanUSpeed  = 0, -- cloud layer 1 u-translation speed
            Tex1PanVSpeed  = 0, -- cloud layer 1 v-translation speed
            Tex1TileU	   = 1,	 -- cloud layer 1 u-tiling
            Tex1TileV	   = 1,	 -- cloud layer 1 v-tiling
            Tex2 = "clouds",
            Tex2RotSpeed   = 0, -- uv-rotation speed
            Tex2PanUSpeed  = 0, -- cloud layer 1 u-translation speed
            Tex2PanVSpeed  = 0, -- cloud layer 1 v-translation speed
            Tex2TileU	   = 1,	 -- cloud layer 1 u-tiling
            Tex2TileV	   = 1,	 -- cloud layer 1 v-tiling
        },
        Layer3 = 
        {
            Tex_Mask   = "white",
            Tex_LMap   = "white",
            Tex1 = "clouds",
            Tex1RotSpeed   = 0, -- uv-rotation speed
            Tex1PanUSpeed  = 0, -- cloud layer 1 u-translation speed
            Tex1PanVSpeed  = 0, -- cloud layer 1 v-translation speed
            Tex1TileU	   = 1,	 -- cloud layer 1 u-tiling
            Tex1TileV	   = 1,	 -- cloud layer 1 v-tiling
            Tex2 = "clouds",
            Tex2RotSpeed   = 0, -- uv-rotation speed
            Tex2PanUSpeed  = 0, -- cloud layer 1 u-translation speed
            Tex2PanVSpeed  = 0, -- cloud layer 1 v-translation speed
            Tex2TileU	   = 1,	 -- cloud layer 1 u-tiling
            Tex2TileV	   = 1,	 -- cloud layer 1 v-tiling
        },
        Layer4 = 
        {
            Tex_Mask   = "white",
            Tex_LMap   = "white",
            Tex1 = "clouds",
            Tex1RotSpeed   = 0, -- uv-rotation speed
            Tex1PanUSpeed  = 0, -- cloud layer 1 u-translation speed
            Tex1PanVSpeed  = 0, -- cloud layer 1 v-translation speed
            Tex1TileU	   = 1,	 -- cloud layer 1 u-tiling
            Tex1TileV	   = 1,	 -- cloud layer 1 v-tiling
            Tex2 = "clouds",
            Tex2RotSpeed   = 0, -- uv-rotation speed
            Tex2PanUSpeed  = 0, -- cloud layer 1 u-translation speed
            Tex2PanVSpeed  = 0, -- cloud layer 1 v-translation speed
            Tex2TileU	   = 1,	 -- cloud layer 1 u-tiling
            Tex2TileV	   = 1,	 -- cloud layer 1 v-tiling
        }
    },
    _Class = "CLevel",
    
    s_Editor = {
        Map                = { "BrowseEdit",  {"*.dat;*.mpk", "data\\maps\\",false} },
        WayPointsMap       = { "BrowseEdit",  {"*.wpm;*.wps", "data\\maps\\",false} },
        ["Music.Ambient.[new]"]  = { "BrowseEdit",  {"*.mp3", "data\\music\\",true} },
        ["Music.Battle.[new]"]   = { "BrowseEdit",  {"*.mp3", "data\\music\\",true} },

        FarClipPlane       = { "SpinEdit"  ,  {"%.0f", 0, 4096, 1} },
        
        ["Fog.Mode"]       = { "ComboBox"  , {"No Fog|0", "Exp|1", "Exp2|2", "Linear|3"} },
        ["Fog.Start"]      = { "SpinEdit"  , {"%.1f", 0, 1000, 0.1} },
        ["Fog.End"]        = { "SpinEdit"  , {"%.1f", 0, 1000, 0.1} },
        ["Fog.Density"]    = { "SpinEdit"  , {"%.3f", 0, 10, 0.001} },
        
        ["Sky.Mode"]       = { "ComboBox"  , {"No Sky|0", "Normal|1"} },
        ["Sky.RotSpeed"]   = { "SpinEdit"  , {"%.3f", 0, 10, 0.001} },
        ["Sky.Pan1Speed"]  = { "SpinEdit"  , {"%.3f", 0, 10, 0.001} },
        ["Sky.Pan2Speed"]  = { "SpinEdit"  , {"%.3f", 0, 10, 0.001} },
        ["Sky.Scale"]      = { "SpinEdit"  , {"%.1f", 0, 1000, 0.1} },
        ["Sky.YOffset"]    = { "SpinEdit"  , {"%.1f", -1000, 1000, 0.1} },
        ["Sky.Tile1"]      = { "SpinEdit"  , {"%.1f", 0, 1000, 0.1} },
        ["Sky.Tile2"]      = { "SpinEdit"  , {"%.1f", 0, 1000, 0.1} },
        ["Sky.Tex_Back"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["Sky.Tex_Cloud1"] = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["Sky.Tex_Cloud2"] = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["Sky.Tex_Mask"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        
        ["SkyDome.Map"] = { "BrowseEdit",  {"*.dat;*.mpk", "data\\maps\\",false} },
        ["SkyDome.LowQuality.Map"] = { "BrowseEdit",  {"*.dat;*.mpk", "data\\maps\\",false} },
        ["SkyDome.LowQuality.Tex"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["SkyDome.Layer1.Tex_Mask"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["SkyDome.Layer1.Tex_LMap"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["SkyDome.Layer1.Tex1"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["SkyDome.Layer1.Tex2"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["SkyDome.Layer2.Tex_Mask"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["SkyDome.Layer2.Tex_LMap"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["SkyDome.Layer2.Tex1"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["SkyDome.Layer2.Tex2"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["SkyDome.Layer3.Tex_Mask"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["SkyDome.Layer3.Tex_LMap"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["SkyDome.Layer3.Tex1"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["SkyDome.Layer3.Tex2"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["SkyDome.Layer4.Tex_Mask"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["SkyDome.Layer4.Tex_LMap"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["SkyDome.Layer4.Tex1"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },
        ["SkyDome.Layer4.Tex2"]   = { "BrowseEdit", {"*.*", "data\\textures\\skies\\",true} },

        ["CubeMap.Tex"]   = { "BrowseEdit", {"*.*", "data\\textures\\",true} },
        ["NormalMap.Tex"]   = { "BrowseEdit", {"*.*", "data\\textures\\",true} },
        ["DetailMap.Tex"]   = { "BrowseEdit", {"*.*", "data\\textures\\",true} },
        
        Acoustics = { "ComboBox", {"Generic|0", "PaddedCell|1", "Room|2", "Bathroom|3",
                                  "LivingRoom|4", "StoneRoom|5","Auditorium|6", "ConcertHall|7","Cave|8",
                                  "Arena|9", "Hangar|10", "CarpetedHallway|11", "Hallway|12",	"StoneCorridor|13",
                                  "Alley|14", "Forest|15", "City|16", "Mountains|17", "Quarry|18", "Plain|19",
                                  "ParkingLot|20", "SewerPipe|21", "UnderWater|22", "Drugged|23", "Dizzy|24",
                                  "Psychotic|25"}},
        ["Acoustics.Room.Type"] = { "ComboBox", Acoustics.RoomTypes},
        ["Acoustics.Player.Ground"] = { "ComboBox", Acoustics.GroundTypes},
    },
	_ColParams = {			-- domyslne parametry do kolzji meshy z grup 20..30
		--particlesOnCollision = "butk",
		--particlesOnCollisionSize = 0.12,
		collisionMinimumStrength = 3.0,
		amountReportingCollisions = 1.0,
		miminalMassReportingCollision = 50,
		collisionMinimumFrequency = 1.0,
		maximalMassReportingCollision = 5000,
	},
}
Inherit(CLevel,CObject)
--============================================================================
function CLevel:New(map,wpm,scale)
    local lev = Clone(CLevel)
    lev.Map = map
    lev.WayPointsMap = wpm
    lev.Scale = scale
    return lev
end
--============================================================================
function CLevel:Delete()
    if self.CustomDelete then
        self:CustomDelete()
    end
    SOUND.StreamPause(0)    
    SOUND.StreamPause(1)
    if self._rain then
		SOUND2D.Delete(self._rain)
		self._rain = nil
    end
    for i,o in self._Atmospheric do      
        if o[2] then
            PARTICLE.Die(o[2])
            o[2] = nil
        end       
	end
    SOUND.StreamDelete(0)
    SOUND.StreamDelete(1)
end
--============================================================================
function CLevel:Apply(old)
    
    local i=1
    local from=-2
    local to=2
    local radius=10
    for x=from,to do
        for z=from,to do
            self._Atmospheric[i] = {}
            self._Atmospheric[i][3]=Vector:New(x*radius,0,z*radius)   
            i=i+1
        end
    end
    
    -- kompatybilnosc dla starszych leveli
    local p = self.Physics
    if self.ActiveMeshesMassScale then 
        p.ActiveMeshesMassScale = self.ActiveMeshesMassScale
        self.ActiveMeshesMassScale = nil
    end                

    if not old or (old.Map ~= self.Map or old.Scale ~= self.Scale) then
        if WORLD.GetFileName() == self.Map then -- already loaded
            WORLD.Release(false) -- world release without map
        else
            WORLD.Release(true) -- full world release with current map
            WORLD.LoadMap("../Data/Maps/"..self.Map,self._Name,self.Scale,self.Overbright,self.RTCubeMap,self.ShadowMaps.Size,self.ShadowMaps.Number)        
            WORLD.Init(p.ActiveMeshesMassScale,p.DefaultMeshFriction,p.DefaultMeshRestitution,p.Deactivator.Delay,p.Deactivator.MaxPosDiff)
        end                        
    end

    self.Ang.Z = 0
    CAM.SetAng(self.Ang.X,self.Ang.Y,self.Ang.Z)   
    CAM.SetPos(self.Pos.X,self.Pos.Y,self.Pos.Z)        

    self.Sky = nil        
    -- temporary
    if type(self.Fog) ~= "table" then -- XXX zabezpieczenie przed starymi levelami                
        self.Fog = CLevel.Fog
        self.Sky = CLevel.Sky
    end


    -- for compatibility
    if type(self.Music) == "string" then
        local m = self.Music
        self.Music = Clone(CLevel.Music)
        self.Music.Ambient = m
        self.Music.Battle = self.MusicBattle
        self.MusicBattle = nil
        self.MusicVolume = nil
    end 
    if type(self.Music.Ambient) == "string" then        
        if self.Music.Ambient ~= "" then
            self.Music.Ambient = {self.Music.Ambient}
        end
    end
    if type(self.Music.Battle) == "string" then
        self.Music.Battle = {self.Music.Battle}
    end
    self.Music.AmbientVolume = nil
    self.Music.BattleVolume  = nil        
    
    -- for 2CD PL version
    local n = table.getn(self.Music.Ambient)
    if n > 1 then
        if not FS.File_Exist("../data/music/"..self.Music.Ambient[2]..".mp3") then
            self.Music.Ambient = {self.Music.Ambient[1]}
        end
    end    
  
    for i,p in Acoustics.GroundTypes do
        local i = string.find(p,"|",1,true)
        if i and self.Acoustics.Player.Ground == tonumber(string.sub(p,i+1)) then
            self.Acoustics.Player._GroundName = string.sub(p,1,i-1)
            break
        end
    end
    
    -- konwersja nazwy meshy na male litery
    if Lev.ActiveMeshesData then
        local array = {}
        for i,o in Lev.ActiveMeshesData do        
            local lcase = string.lower(i)
            array[lcase] = o
        end            
        Lev.ActiveMeshesData = array
    end


    self:SetupMap(old)

    if self._MeshesCollisions then
		for i,v in self._MeshesCollisions do
			local ok = ENTITY.EnableCollisionsToMesh(true, i, self.MeshesCollisionsMinDelay, self.MeshesCollisionsMinStr)
			if not ok then	
				Game:Print("ERROR:EnableCollisionsToMesh, mesh not found "..i)
			end
		end
	end
	
	local colParams = self._ColParams
	for i=20,30 do
		local count = ENTITY.EnableCollisionsToAll(true, colParams.collisionMinimumFrequency, colParams.collisionMinimumStrength,
			colParams.miminalMassReportingCollision, colParams.maximalMassReportingCollision, colParams.amountReportingCollisions * 100, i)
		if debugMarek then Game:Print(i.." Enable collision to "..count.." meshes")  end

		PHYSICS.ActiveMeshGroupSetActivationParams(i, true, colParams.collisionMinimumFrequency, colParams.collisionMinimumStrength,
			colParams.miminalMassReportingCollision,	colParams.maximalMassReportingCollision, colParams.amountReportingCollisions * 100,
			colParams.timeToLive,colParams.timeToLiveRandomize)
	end

    if self._musicStarted then self:StartMusic() end
    self:Synchronize()    
end
--============================================================================
function CLevel:SetupMap(old)
    if not old or old.WayPointsMap ~= self.WayPointsMap then
        -- load waypoints
        WPT.Load("../Data/Maps/"..self.WayPointsMap)
    end                       

    self._orgPos = Clone(self.Pos)
    self._orgAng = Clone(self.Ang)

    WORLD.BloomFXParams(self.BloomFX.LuminanceThreshold,self.BloomFX.Multiplier,self.BloomFX.OverlayColor:Compose(),self.BloomFX.DimScale)

    local f = self.Fog
    WORLD.SetupFog(f.Mode,f.Start * (Cfg.ClipPlane+100)/200,f.End * (Cfg.ClipPlane+100)/200,f.Density,f.Color:Compose())        
    local s = self.Sky
    
    WORLD.SetFarClipDist(self.FarClipDist * (Cfg.ClipPlane+100)/200)
    self.Volumetrics = nil
    	
	self:ReloadSky(old)
    
    local d = self.DirLight
    if d.Enabled then d.Enabled = nil end
    WORLD.SetDirLight(d.Dir.X,d.Dir.Y,d.Dir.Z,d.Color:Compose(),d.Intensity)
    
    local c = self.DynamicLighting.SpecularColor
    WORLD.SetDynamicSpecular(c.R,c.G,c.B,self.DynamicLighting.SpecularPower)

    SOUND.Set3DSoundFalloff(self.SoundFalloffSpeed)
    if Cfg.EAXAcoustics then
        if self.Acoustics.Room.Type == 0 then
            SOUND.SetRoomType(self.Acoustics.Room.Type,0,self.Acoustics.Room.SwitchTime)
        else
            SOUND.SetRoomType(self.Acoustics.Room.Type,self.Acoustics.Room.Intensity,self.Acoustics.Room.SwitchTime)
        end
    end
    
    WORLD.DemonFXParams(self.DemonFX.Scale,self.DemonFX.Bias,1-self.DemonFX.MBlur,self.DemonFX.MBlur)
	local d = self.Water.DeepWaterColor
	local s = self.Water.ShallowWaterColor
	WORLD.SetupWater(self.Water.FresnelBias, self.Water.FresnelExponent,
		self.Water.BumpHeight, self.Water.WaveAmplitude, self.Water.WaveFrequency, 
		d.R,d.G,d.B, s.R,s.G,s.B, self.Water.WaveSpeed, 
		self.Water.WaterAmount, self.Water.ReflectionAmount, self.Water.WaterLevel,
		self.Water.ReflectScene, self.Water.RefractScene,
		self.Water.Pan.X, self.Water.Pan.Y, self.Water.Tile.X, self.Water.Tile.Y)
            
    WORLD.AmbientColor(self.Ambient.R,self.Ambient.G,self.Ambient.B,self.GunAmbientMultiplier)
    WORLD.MakeUnderwater( self.IsUnderwater )

    if not old or old.DetailMap.Tex ~= self.DetailMap.Tex then
        self:ReloadDetailMaps()
    end
    if not old or old.CubeMap.Tex ~= self.CubeMap.Tex then
        MESH.SetDefaultCubeMaps(self.CubeMap.Tex)
    end
    if not old or old.NormalMap.Tex ~= self.NormalMap.Tex then
        MESH.SetDefaultNormalMaps(self.NormalMap.Tex)
    end
    
    self._CurMusic = self.Music
end

function CLevel:OnCollision(x,y,z,e,h_me,meshName)
	local cg = PHYSICS.GetHavokBodyActiveGroup(h_me)
	local sound = SoundsDefsGroups[cg]
	if sound then
        local colParams = self._ColParams
        if colParams.particlesOnCollision then
			AddPFX(colParams.particlesOnCollision, colParams.particlesOnCollisionSize*FRand(0.7,1.0), Vector:New(x,y,z))
		end
		local path = ""
		if sound.path then
			path = sound.path
		end
		local snd = sound.samples[math.random(1,table.getn(sound.samples))]
		PlaySound3D(path..snd,x,y,z,sound.dist1,sound.dist2)
	else
		--if debugMarek then Game:Print("Default: oncol = "..cg.." nod def") end
		if self._MeshesCollisions then
			local str = ENTITY.GetName(meshName)
			--local str2 = ENTITY.GetName(e)
			--Game:Print("kolizja z meshem: "..str.." "..str2)
			local snd = self._MeshesCollisions[str]
			if snd then
				local c = math.random(1,table.getn(snd.samples))
				local snds = snd.samples[c]
				--Game:Print(" >>> kolizja z meshem SOUND! "..str.." "..snds)
				local path = ""
				if snd.path then
					path = snd.path
				end

				PlaySound3D(path..snds, x,y,z, snd.dist1, snd.dist2)
			else
				Game:Print(" >>> kolizja z meshem nie ma SOUND... "..str)
			end
			if self.MeshesCollisionsFX then
				local size = FRand(0.5,0.6)
				if self.MeshesCollisionsFXSize then
					size = self.MeshesCollisionsFXSize * FRand(0.8,1.0)
				end
				AddPFX(self.MeshesCollisionsFX,size,Vector:New(x,y,z))
			end
		end

	end
	if self.CustomOnCollision then
		self:CustomOnCollision(cg,x,y,z)
	end
end





--===========================================================================
function CLevel:ReloadDetailMaps()
	if Cfg.DetailTextures == true then
		MESH.SetDefaultDetailMaps(self.DetailMap.Tex,self.DetailMap.TileU,self.DetailMap.TileV)
	else
		MESH.SetDefaultDetailMaps("",self.DetailMap.TileU,self.DetailMap.TileV)
	end
end
--===========================================================================
function CLevel:ReloadSky(old)
	-- first try to load high quality sky (may pass empty map name to force low quality model)
    if not old or (old.SkyDome.Map ~= self.SkyDome.Map) then
		if Cfg.RenderSky == 2 then
			self.SkyDome._Layers = WORLD.LoadSky("../Data/Maps/"..self.SkyDome.Map)
		else
			self.SkyDome._Layers = WORLD.LoadSky("")
		end
    end

	if self.SkyDome._Layers ~= 0 then 
		for i=1,self.SkyDome._Layers do
			local layer = self.SkyDome["Layer"..i]
			local same = false

			if old then 
				same = true
				local oldlayer = old.SkyDome["Layer"..i]
				for i,o in layer do
					if o ~= oldlayer[i] then
						same = false
						break
					end
				end
			end
			
			if not same then 
				WORLD.SetupSkyLayer(i-1,layer.Tex_Mask,layer.Tex_LMap,
					layer.Tex1,layer.Tex1RotSpeed,layer.Tex1PanUSpeed,layer.Tex1PanVSpeed,layer.Tex1TileU,layer.Tex1TileV,
					layer.Tex2,layer.Tex2RotSpeed,layer.Tex2PanUSpeed,layer.Tex2PanVSpeed,layer.Tex2TileU,layer.Tex2TileV)
			end
		end	
	else
		-- loading high quality sky failed, try loading low quality one (may pass empty map name to force no sky model)
		-- NOTE: we may be running DX7 class hw
		if not old 
			or (self.SkyDome._Layers ~= old.SkyDome._Layers) 
			or (old.SkyDome.LowQuality.Map ~= self.SkyDome.LowQuality.Map) 
			or (old.SkyDome.LowQuality.Height ~= self.SkyDome.LowQuality.Height) 
			or (old.SkyDome.LowQuality.Angle ~= self.SkyDome.LowQuality.Angle) then
			if Cfg.RenderSky ~= 0 then
				self.SkyDome.LowQuality._Layers = WORLD.LoadLowQualitySky(
					"../Data/Maps/"..self.SkyDome.LowQuality.Map, self.SkyDome.LowQuality.Height, self.SkyDome.LowQuality.Angle)
			end
		end
	
		-- setup layers (if any)	
		for i=1,self.SkyDome.LowQuality._Layers do
			WORLD.SetupSkyLayer(i-1,"","",
				self.SkyDome.LowQuality.Tex,0,0,0,0,0,
				"",0,0,0,0,0)
		end
	end
	
	WORLD.InitSky()
end
--============================================================================
function CLevel:StartMusic()
	if Game.GMode ~= GModes.DedicatedServer then
        SOUND.StreamSetVolume(0,0)
        SOUND.StreamSetVolume(1,0)
        self:StartMusicEx(true)
		
        --[[
        self._fade = false
		self._ambient = true
		local n = table.getn(self.Music.Ambient)
		if n > 0 then
			SOUND.StreamLoad(0,self.Music.Ambient[math.random(1,n)])    
		else
			SOUND.StreamLoad(0,"")    
		end
		SOUND.StreamSetVolume(0,Cfg.AmbientVolume)
		SOUND.StreamPlay(0)    
	    
		local n = table.getn(self.Music.Battle)
		if n > 0 then
			SOUND.StreamLoad(1,self.Music.Battle[math.random(1,n)])    
		else
			SOUND.StreamLoad(1,"")    
		end
		SOUND.StreamSetVolume(1,0)
	    
		if Game.GMode ~= GModes.SingleGame then
			SOUND.StreamLoad(2,"painkiller-stats-loop")
			SOUND.StreamSetVolume(2,0)
		end
        --]]
	    
		self._musicStarted = true
	end
end
--============================================================================
function CLevel:Tick(delta)
end
--============================================================================
--[[function CLevel:Tick2(delta)
    for i,o in self._Atmospheric do
        if o[2] then
            ENTITY.SetPosition(o[2],PX+o[3].X,PY+o[3].Y,PZ+o[3].Z)
        end
    end
end--]]
--============================================================================
function CLevel:Update()
    
    -- storm lighting
    self._disableStormLighting = nil
    local env =  WORLD.FindEnvironmentAtPoint(PX,PY,PZ)
    if env then
        local obj = EntityToObject[env]
        if obj and obj.DisableStormLighting then
            self._disableStormLighting = true
        end            
    end
    
    -- check room type
    self._checkRoomTypeDelay = self._checkRoomTypeDelay - 1
    if self._checkRoomTypeDelay < 0 then
        local aRoom = self.Acoustics.Room.Type
        local aIntensity = self.Acoustics.Room.Intensity
        local aSwitchTime = self.Acoustics.Room.SwitchTime
                
        self._CurMusic = self.Music
        local mEnv = nil
        self._r_CurAcEnv = nil        
        local p = {}        
        local isInside = false
        for i,o in GObjects.Elements do 
            if o._IsAE then -- AcousticEnviroment
                if o:IsInside(PX,PY+1,PZ) then
                    self._r_CurAcEnv = o
                    aRoom = o.Room.Type
                    aIntensity = o.Room.Intensity
                    aSwitchTime = o.Room.SwitchTime
                end
            elseif o._IsME then -- MusicEnviroment
                if o:IsInside(PX,PY+1,PZ) then
                    self._CurMusic = Clone(o.Music)
                    if not o.Music.AmbientOverwrite then self._CurMusic.Ambient = self.Music.Ambient end
                    if not o.Music.BattleOverwrite then self._CurMusic.Battle = self.Music.Battle end
                    mEnv = o
                end
            else -- ParticleEnviroment
				if o._IsPE then
					if not isInside and o:IsInside(PX,PY+1,PZ) then
						isInside = o.SoundLoop
					end

					if  Cfg.WeatherEffects == true then
						for ii,oo in self._Atmospheric do
							if p[ii] ~= "none" then
								local inside
								if o.ParticleFX == "none" then
									inside = o:IsInsideExtruded(PX+oo[3].X,PY+oo[3].Y,PZ+oo[3].Z,5,0,5)
								else
									inside = o:IsInsideExtruded(PX+oo[3].X,PY+oo[3].Y,PZ+oo[3].Z,-5,0,-5)
								end
								if inside then 
									p[ii] = o.ParticleFX
								end
							end
						end
					end
                end
            end
        end
        
        if self._lastMEnvironment ~= mEnv then
            --Game:Print(self._CurMusic.Ambient[1])
            self:StartMusicEx(self._ambient,true)
            self._lastMEnvironment = mEnv
        end

        if Cfg.EAXAcoustics then
            if aRoom == 0 then
                SOUND.SetRoomType(aRoom,0,aSwitchTime)
            else
                SOUND.SetRoomType(aRoom,aIntensity,aSwitchTime)
            end
        else
            SOUND.SetRoomType(0,0,0)
        end
        --Game:Print("SOUND.SetRoomType:" .. a )
		
		for i,o in self._Atmospheric do
			if o[2] then
				ENTITY.SetPosition(o[2],PX+o[3].X,PY+o[3].Y,PZ+o[3].Z)
			end
		end
		
		if not self._rain and isInside then
			--Game:Print(self._Name.." create rain "..isInside)
			self._rain = SOUND2D.Create(isInside)	--isInside
			SOUND2D.SetLoopCount(self._rain, 0)
			SOUND2D.SetVolume(self._rain, 0, 0.0)
			SOUND2D.Play(self._rain)
		end
        
        if self._rain then
            if isInside then
                SOUND2D.SetVolume(self._rain, 100, 1.0)
            else
                SOUND2D.SetVolume(self._rain, 0, 1.0)
            end
        end
        
        self._checkRoomTypeDelay = 0.5 * 30 -- 0.5 sec
        
        for ii,oo in self._Atmospheric do      
            if (oo[1] ~= p[ii]) then
           
                if oo[1] then
                    --Game:Print("Remove PFX"..ii.." @ "..oo[3].X.." "..oo[3].Y.." "..oo[3].Z)
                    PARTICLE.Die(oo[2])
                    oo[2] = nil
                end            
                
                oo[1] = p[ii]
                
                if oo[1] then
                    --Game:Print("Add PFX"..ii.." @ "..oo[3].X.." "..oo[3].Y.." "..oo[3].Z)
                    if oo[1] ~= "none" then
                        oo[2] = AddPFX(oo[1],1,Vector:New(PX+oo[3].X,PY+oo[3].Y,PZ+oo[3].Z))
                    end
                end
            end
        end
    end  
    
    if Game.GMode ~= GModes.SingleGame or CONSOLE.DemoIsPlaying() then return end
    
    if not self.disableChangeMusic then
		self:TryToChangeMusic()
	end
end
--============================================================================
function CLevel:Synchronize()
    -- synchronization with  C++ object
    if not MOUSE.IsLocked() then 
        CAM.SetAng(self.Ang.X,self.Ang.Y,self.Ang.Z)
        CAM.SetPos(self.Pos.X,self.Pos.Y,self.Pos.Z)
    else
        self.Ang:Set(CAM.GetAng())
        self.Pos:Set(CAM.GetPos())
    end
    
    --if INP.Key(Keys.F11) == 1 then
    --    self:StartBattleMusic()
    --end
    
    --if INP.Key(Keys.F12) == 1 then
    --    self:StartAmbientMusic()
    --end
end
--============================================================================
function CLevel:OnPlay(firstTime)    
end
--============================================================================
function CLevel:StartMusicEx(ambient,force)
    if force then
        local pcs = GObjects:GetElementsWithFieldValue("BaseName","PMusicFade*")
        for i,p in pcs do GObjects:ToKill(p) end
    end    
    
    if not force and (self._fade or (self._ambient == ambient)) then 
        return         
    end
    
    self._ambient = ambient
    
    local vol = Cfg.AmbientVolume
    local music = self._CurMusic.Ambient        
    local fadeTime = 5
    
    if not ambient then 
        vol = Cfg.MusicVolume 
        music = self._CurMusic.Battle
        fadeTime = 2
    end

    local prevVolume = SOUND.StreamGetVolume(self._freeMSlot)
    local n = table.getn(music)
    if n >= 1 then
        local song = music[math.random(1,n)]
        if self._songInSlot[self._freeMSlot] == song then 
            SOUND.StreamResume(self._freeMSlot) -- kontynuacja
            Game:Print("  SONG - Continue: "..self._freeMSlot..", "..song)
        else
            SOUND.StreamLoad(self._freeMSlot,song)    
            SOUND.StreamPlay(self._freeMSlot) 
            self._songInSlot[self._freeMSlot] = song
            Game:Print("  SONG - Start: "..self._freeMSlot..", "..song)
        end
    else
        local lastSlot = 0
        if self._freeMSlot == 0 then lastSlot = 1 end
        AddObject(Templates["PMusicFade.CProcess"]:New(lastSlot,SOUND.StreamGetVolume(lastSlot),0,fadeTime,"SOUND.StreamPause("..lastSlot..");Lev._fade=false"))
        return
    end
        
    AddObject(Templates["PMusicFade.CProcess"]:New(self._freeMSlot,prevVolume,vol,fadeTime))
    if self._freeMSlot == 1 then self._freeMSlot = 0 else self._freeMSlot = 1 end
    AddObject(Templates["PMusicFade.CProcess"]:New(self._freeMSlot,SOUND.StreamGetVolume(self._freeMSlot),0,fadeTime,"SOUND.StreamPause("..self._freeMSlot..");Lev._fade=false"))
    self._fade = true
end
--============================================================================
function CLevel:StartAmbientMusic()
    --Game:Print("StartAmbientMusic()")
    if self._fade or self._ambient then return end
    --Game:Print("poszlo")
    self._fade = true
    self._ambient = true
    
    local n = table.getn(self._CurMusic.Ambient)
    if n > 1 then
        SOUND.StreamLoad(0,self._CurMusic.Ambient[math.random(1,n)])    
        SOUND.StreamPlay(0) 
    else
        SOUND.StreamResume(0) -- kontynuacja
    end
    
    AddObject(Templates["PMusicFade.CProcess"]:New(1,SOUND.StreamGetVolume(1),0,5,"SOUND.StreamPause(1);Lev._fade=false"))
    AddObject(Templates["PMusicFade.CProcess"]:New(0,SOUND.StreamGetVolume(0),Cfg.AmbientVolume,5))
end
--============================================================================
function CLevel:StartBattleMusic()
    --Game:Print("StartBattleMusic()")
    if self._fade or not self._ambient then return end
    --Game:Print("poszlo")
    self._fade = true
    self._ambient = false
    
    local n = table.getn(self._CurMusic.Battle)
    if n > 1 then
        SOUND.StreamLoad(1,self._CurMusic.Battle[math.random(1,n)])    
        SOUND.StreamPlay(1) 
    else
        SOUND.StreamResume(1) -- kontynuacja
    end
    
    AddObject(Templates["PMusicFade.CProcess"]:New(1,SOUND.StreamGetVolume(1),Cfg.MusicVolume,2))
    AddObject(Templates["PMusicFade.CProcess"]:New(0,SOUND.StreamGetVolume(0),0,2,"SOUND.StreamPause(0);Lev._fade=false"))
end
--============================================================================
function CLevel:TryToChangeMusic()

    if Game.IsDemon then return end
    if not Hud.r_closestEnemy and Hud._nearestCheckPoint then    
        self.MusicTimeOut = 0
    end
    
    if Hud.r_closestEnemy and table.getn(self._CurMusic.Battle) and Cfg.MusicVolume > 0 then 
        self:StartMusicEx(false)
        --self:StartBattleMusic()
        self.MusicTimeOut = 6 * 30        
    end
    
    if self.MusicTimeOut > 0 then
        self.MusicTimeOut = self.MusicTimeOut - 1
    else
        self:StartMusicEx(true)
        --self:StartAmbientMusic()
    end
end
--============================================================================
function CLevel:EditRender(delta)
    if Editor.SelObj ~= self then  return end
    
    if not Editor.EditLights then return end    
    local d = self.DirLight
    local pos = OppositeToCamera() 
    R3D.DrawDirLight(d.Color:Compose(),pos.X, pos.Y, pos.Z,d.Dir.X,d.Dir.Y,d.Dir.Z) 
end
--============================================================================
function CLevel:LookAt(obj)
    if not obj then 
        MsgBox("Object nof found!") 
        return
    end
    local x,y,z = CAM.GetForwardVector()
    local px,py,pz = obj.Pos:Get()
    if obj._Entity and obj._Entity > 0 then
        px,py,pz = ENTITY.GetCenter(obj._Entity)
    end
    if obj.Points and obj.Points[1] then px,py,pz = obj.Points[1]:Get() end
    self.Pos:Set(px - x*3,py - y*3,pz - z*3)
    self:Synchronize()
end
--============================================================================
function CLevel:Precache()
    Game:Print(" --- PRECACHE:")
    local fname = string.sub(self.Map,1,-4) .. "cache"
    local f = io.open (fname,"r")
    if not f then return end
    
    for line in f:lines() do
        Game:Print("  caching: "..line)
        local sep1 = string.find(line,":")
        local tp = string.sub(line,1,sep1-1)
        local params = string.sub(line,sep1+2)
        
        --dostring("CLevel.Precache"..tp.."("..params..")")           
        --Game:Print(tp)
        --Game:Print(file)
        --Game:Print(scale)
    end
    io.close(f)    
end
--============================================================================
function Level_GetActiveMeshesData(mesh)
    if not Lev.ActiveMeshesData then return 1 end
    for i,o in Lev.ActiveMeshesData do
        if string.find(mesh,i,1,true) then return o[1] end
    end
    return 1
end
--============================================================================
function CLevel:GetCardStatus()
	return 0
end
--============================================================================
function CLevel:GiveCard()
	if self._MagicCard then
		Game.CardsAvailable[self._MagicCard.index] = true
	end
end
--============================================================================
function CLevel:GetCardName()
	if self._MagicCard then
		return self._MagicCard.name,self._MagicCard.desc,self._MagicCard.cost
	else
		return "","",0
	end
end
--============================================================================
function CLevel:GetCardBigImage()
	if self._MagicCard then
		return self._MagicCard.bigImage
	else
		return ""
	end
end
--============================================================================
