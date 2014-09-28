--============================================================================
-- Environment class
--============================================================================
CEnvironment =
{
    Rot = Quaternion:New(),
    Ambient = 
    {
        Overwrite = false,
        Color = Color:New(30,30,30,0),
    },
    DirLight = 
    {
        Overwrite = false,
        Dir = Vector:New(-0.7,-0.7,-0.7),
        Color = Color:New(100,100,100,0),
        Intensity = 1.0,
		FadeTime = 1.0,
    },  
    Fog = 
    {
        Overwrite	= false,
        Start		= 0,
        End		    = 90,
        Density		= 0.002,
        Color = Color:New(255,255,255,0),
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
		ReflectScale = 0.25,
		RefractScale = 0.25,
		PlaneShift = 0.2,
		Pan1 = Vector:New(0,0,0),
		Pan2 = Vector:New(0,0,0),
		Tile1 = Vector:New(1,1,1),
		Tile2 = Vector:New(1,1,1),
	    	ReflectList = {},    
		ReflectRadius = 1024,
		ReflectDist = 256,
		ReflectSky = false,
	},

    DisableStormLighting = false, -- storm lighting
    DependentLights = {},    
    Size = 
    {
        Width  = 2,
        Height = 4,
        Depth  = 1,
    },        
    Pos = Vector:New(0,0,0),
    _Class = "CEnvironment",
}
Inherit(CEnvironment,CObject)
--============================================================================
function CEnvironment:OnClone(old)
    if old == CEnvironment then 
        self.Pos = OppositeToCamera() 
    else
        self.Pos.X = old.Pos.X - 0.5
        self.Pos.Z = old.Pos.Z - 0.5
    end
    self._Entity = nil
end
--============================================================================
function CEnvironment:Delete()
    WORLD.RemoveEntity(self._Entity)
    ENTITY.Release(self._Entity)
    self._Entity = nil
end
--============================================================================
function CEnvironment:Apply(old)
     if not old or old._Name ~= self._Name then 
        ENTITY.Release(self._Entity)
        if EntityToObject[self._Entity] then
            EntityToObject[self._Entity] = nil
        end        
        self._Entity = ENTITY.Create(ETypes.Environment,"Script",self._Name)
        WORLD.AddEntity(self._Entity)
        EntityToObject[self._Entity] = self
    end        
    
    ENVIRONMENT.SetAmbient(self._Entity,self.Ambient.Overwrite,self.Ambient.Color:Compose())
    local f = self.Fog
    if not f then
		f = self.s_SubClassParams.Fog
	end
    ENVIRONMENT.SetFog(self._Entity,f.Overwrite,f.Start,f.End,f.Density,f.Color:Compose())
    local d = self.DirLight

	local dc = self.Water.DeepWaterColor
	local sc = self.Water.ShallowWaterColor
	ENVIRONMENT.SetWater(self._Entity,self.Water.FresnelBias, self.Water.FresnelExponent,
		self.Water.BumpHeight, self.Water.WaveAmplitude, self.Water.WaveFrequency, 
		dc.R,dc.G,dc.B, sc.R,sc.G,sc.B, self.Water.WaveSpeed, 
		self.Water.WaterAmount, self.Water.ReflectionAmount, self.Water.WaterLevel,
		self.Water.ReflectScene, self.Water.RefractScene,
		self.Water.ReflectScale, self.Water.RefractScale,
		self.Water.PlaneShift, self.Water.ReflectRadius, self.Water.ReflectDist, self.Water.ReflectSky,
		self.Water.Pan1.X, self.Water.Pan1.Y,
		self.Water.Tile1.X, self.Water.Tile1.Y,
		self.Water.Pan2.X, self.Water.Pan2.Y,
		self.Water.Tile2.X, self.Water.Tile2.Y)

	ENVIRONMENT.ResetReflectList(self._Entity)
	for i,v in self.Water.ReflectList do
		ENVIRONMENT.AddReflectMesh(self._Entity,v)		
	end
    
ENVIRONMENT.SetDirLight(self._Entity,d.Overwrite,d.Dir.X,d.Dir.Y,d.Dir.Z,d.Color:Compose(),d.Intensity,d.FadeTime)

    local w,h,d = self.Size.Width/2,self.Size.Height/2,self.Size.Depth/2    
    ENTITY.SetLocalBBox(self._Entity,-w,-h,-d,w,h,d)   

    ENTITY.SetPosition(self._Entity,self.Pos.X,self.Pos.Y,self.Pos.Z)
    self.Rot:ToEntity(self._Entity)
    self:SetDependentLights()
    if old then
		WORLD.UpdateAllEntities()
	end
end
--============================================================================
function CEnvironment:RestoreFromSave()
    self:Apply()
end
--============================================================================
function CEnvironment:AfterLoad()
    self:SetDependentLights()
end
--============================================================================
function CEnvironment:SetDependentLights()
    ENVIRONMENT.RemoveLights(self._Entity)
    local l = self.DependentLights
	if l then
        for i,v in l do
            local obj = FindObj(v)
            if obj then ENVIRONMENT.AddLight(self._Entity,obj._Entity) end
        end    
    end
end
--============================================================================
function MinMax(array)    
    local m = array[1]
    for i,v in array do
        if math.abs(v) > math.abs(m) then m = v end
    end
    return m
end
--============================================================================
function CEnvironment:IsInside(x,y,z)    
    local w = self.Size.Width  / 2
    local h = self.Size.Height / 2
    local d = self.Size.Depth  / 2

    if x >= self.Pos.X - w and x <= self.Pos.X + w and 
       y >= self.Pos.Y - h and y <= self.Pos.Y + h and 
       z >= self.Pos.Z - d and z <= self.Pos.Z + d then
           return true
    end
    return false
end
--============================================================================
--CEnvironment:MultiplyAllEnvironment("*",1,1,1)
--"*" leci po wszystkich lub szuka substringow
function CEnvironment:MultiplyAllEnvironment(searchString,ambientCol,dirCol,dirintensity)
    local tmp = GObjects:GetAllObjectsByClass("CEnvironment")	
    for i, o in tmp do
		if (searchString == "*" or string.find(o._Name , searchString) ) then
			Game:Print("found = "..o._Name)			
			o.Ambient.Color.R = o.Ambient.Color.R * ambientCol
			o.Ambient.Color.G = o.Ambient.Color.G * ambientCol
			o.Ambient.Color.B = o.Ambient.Color.B * ambientCol
			o.DirLight.Color.R = o.DirLight.Color.R * dirCol
			o.DirLight.Color.G = o.DirLight.Color.G * dirCol
			o.DirLight.Color.B = o.DirLight.Color.B * dirCol
			o.DirLight.Intensity = o.DirLight.Intensity * dirintensity	
		end			
		
    end
end
--============================================================================
