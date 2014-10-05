--============================================================================
-- Billboard class
--============================================================================
CBillboard =
{
    Pos = Vector:New(0,0,0),
    Color = Color:New(255,255,255,255),
    Texture = "banka",
    BlendMode = 1,
    Alpha = 0.5,
    Size	= 5,
    Corona = 
    {
        Enabled = false,
        FadeInTime	= 0.5,
        FadeOutTime	= 0.5,
        TraceMargin = 1,
        MinDistance	= 5,
        MaxDistance	= 20,
        MinSize	= 0.8,
        OffDistance	= 70,
    },
    _Class = "CBillboard",
}
Inherit(CBillboard,CObject)
--============================================================================
function CBillboard:OnClone(old)
    if old == CBillboard then 
        self.Pos = OppositeToCamera() 
    else 
        self.Pos.X = old.Pos.X - 1
        self.Pos.Z = old.Pos.Z - 1
    end
    self._Entity = nil
end
--============================================================================
function CBillboard:Delete()
    WORLD.RemoveEntity(self._Entity)
    ENTITY.Release(self._Entity)
    self._Entity = nil
end
--============================================================================
function CBillboard:Apply(old)
    if not old or old.Corona.Texture ~= self.Corona.Texture then 
        ENTITY.Release(self._Entity)
        self._Entity = ENTITY.Create(ETypes.Billboard,"Script",self._Name)        
    end    
    
    -- tryb konwersji ze swiatel
    if self.Active then self.Active = nil end
    if self.Visible then self.Visible = nil end
    self.IsDynamic = nil
    self.Type = nil
    self.Intensity = nil
    self.Range = nil
    self.StartFalloff = nil
    self.Direction = nil
    self.InheritFrom = nil
    if self.Corona.Texture then
        self.Texture = self.Corona.Texture
        self.Corona.Texture = nil
        if self.Corona.Billboard ~= nil then
            self.Corona.Enabled = not self.Corona.Billboard
            self.Corona.Billboard = nil
        else
            self.Corona.Enabled = true
        end
    end  
    if self.Corona.BlendMode then
        self.BlendMode = self.Corona.BlendMode
        self.Corona.BlendMode = nil
    end  
    if self.Corona.AlphaMax then
        self.Alpha = self.Corona.AlphaMax
        self.Corona.AlphaMax = nil
    end  
    if self.Corona.MaxRadius then
        self.Size = self.Corona.MaxRadius
        self.Corona.MaxRadius = nil
    end  
    if self.Corona.MinRadius then
        self.Corona.MinSize = self.Corona.MinRadius
        self.Corona.MinRadius = nil
    end  
    -- tryb konwersji ze swiatel
    
    local c = self.Corona
    local ctex = "Particles/"..self.Texture
    BILLBOARD.SetupCorona(self._Entity,self.Alpha,c.FadeInTime,c.FadeOutTime,c.MinSize,c.MinDistance,
         self.Size,c.MaxDistance,c.OffDistance,c.TraceMargin,ctex,self.Color:Compose(),self.BlendMode,not self.Corona.Enabled)    
    ENTITY.SetPosition(self._Entity,self.Pos.X,self.Pos.Y,self.Pos.Z)
    WORLD.AddEntity(self._Entity)
end
--============================================================================
--function CBillboard:Synchronize()
    -- synchronization with  C++ object
--    ENTITY.SetPosition(self._Entity,self.Pos.X,self.Pos.Y,self.Pos.Z)
--end
--============================================================================
