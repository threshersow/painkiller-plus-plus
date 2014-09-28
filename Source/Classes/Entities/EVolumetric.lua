--============================================================================
-- EVolumetric
--============================================================================
EVolumetric =
{
    Color = Color:New(255,255,255,0),
    End = 20,

    _MapEntity = true,
    _Name = "Entity",
    _Class = "EVolumetric",
    s_Editor = {}
}
--============================================================================
function EVolumetric:Apply(old)
    FOGVOL.Setup(self._Entity,self.Color:Compose(),self.End)    
end
--============================================================================
function EVolumetric:Get(entity,nofile)
    self._Entity = entity
    if nofile then
        self.Color.R,self.Color.G,self.Color.B,self.End = FOGVOL.GetProperties(self._Entity)
    end
end
--============================================================================
