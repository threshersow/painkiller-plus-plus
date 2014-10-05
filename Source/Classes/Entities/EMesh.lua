--============================================================================
-- EMesh
--============================================================================
EMesh =
{
    Mass = -1,
    Collisions = 
    {
        Enabled = false,
        Sound = "",
        ParticleFX = "",
    },
    CubeMap = 
    {
        DefaultCubeTex = false,
        Tex = "",
    },
    DetailMap = 
    {
        DefaultDetailTex = true,
        Tex = "",
        TileMultiplier = 1,
    },
    NormalMap = 
    {
        DefaultNormalTex = false,
        Tex = "",
    },
    Specular =
    {
	Power = 8,
    	Lights = {},    
    },
    DefaultMaterial = "",
    LightMap = "",
    Textures = {},
    _MapEntity = true,
    _Name = "Entity",
    _Class = "EMesh",
    s_Editor = {
        ["CubeMap.Tex"]     	= { "BrowseEdit", {"*.*", "data\\textures\\",true} },
        ["DetailMap.Tex"]   	= { "BrowseEdit", {"*.*", "data\\textures\\",true} },
        ["NormalMap.Tex"]   	= { "BrowseEdit", {"*.*", "data\\textures\\",true} },
        ["Specular.Lights.[new]"] = { "ComboBox", "EMesh.FillSpecularLights" },
    }
}
EMeshFixed = EMesh
EMeshPhysical = EMesh
--============================================================================
function EMesh:Apply(old)
    local u = Lev.DetailMap.TileU*self.DetailMap.TileMultiplier
    local v = Lev.DetailMap.TileV*self.DetailMap.TileMultiplier
    
    if self.CubeMap.DefaultCubeTex then
        MESH.SetCubeMap(self._Entity,Lev.CubeMap.Tex)
    else
        MESH.SetCubeMap(self._Entity,self.CubeMap.Tex)
    end

    if self.DetailMap.DefaultDetailTex then
        MESH.SetDetailMap(self._Entity,Lev.DetailMap.Tex,u,v)
    else
        MESH.SetDetailMap(self._Entity,self.DetailMap.Tex,u,v)
    end

    if self.NormalMap.DefaultNormalTex then
        MESH.SetNormalMap(self._Entity,Lev.NormalMap.Tex)
    else
        MESH.SetNormalMap(self._Entity,self.NormalMap.Tex)
    end

    if self.DefaultMaterial ~= "" then
        MESH.SetDefaultMaterial(self._Entity,self.DefaultMaterial);
    end

    -- NOTE: order is important
    MESH.ResetSpecularLights(self._Entity)
    for i,x in self.Specular.Lights do
	local le = getfenv()[x]
	if le then
	    MESH.AddSpecularLight(self._Entity, le._Entity)
	end
    end
	
    MESH.SetSpecular(self._Entity, self.Specular.Power);
    
end

--============================================================================
function EMesh:Get(entity,nofile)
    self._Entity = entity
    if nofile then
        local u,v

        self.CubeMap.Tex       = MESH.GetCubeMap(entity)
        self.DetailMap.Tex,u,v = MESH.GetDetailMap(entity)
        self.NormalMap.Tex     = MESH.GetNormalMap(entity)
        
        if not self.CubeMap.Tex   then self.CubeMap.Tex = ""   end
        if not self.DetailMap.Tex then self.DetailMap.Tex = "" end
        if not self.NormalMap.Tex then self.NormalMap.Tex = "" end
        
        if Lev.DetailMap.TileU~=0 then
            self.TileMultiplier = u/Lev.DetailMap.TileU
        elseif Lev.DetailMap.TileV~=0 then
            self.TileMultiplier = v/Lev.DetailMap.TileV
        else
            self.TileMultiplier = 1
        end
    end

    self.LightMap          = MESH.GetLightMap(entity)
    self.Textures          = MESH.GetTextures(entity)
    self.Specular.Enabled = nil
end
--============================================================================

function EMesh:FillSpecularLights(old)
    tmp_tab = {"-remove-"}
    local lights = GObjects:GetAllObjectsByClass("CLight")
    for i,v in lights do
	local exists
	for j,x in self.Specular.Lights do
		if x == v._Name then
			exists = true
			break
		end
	end
	
	if not exists and (v.Type == 2 or v.Type == 3) then
            table.insert(tmp_tab,v._Name)
	end
    end	
end
