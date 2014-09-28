--============================================================================
-- Light class
--============================================================================
CLight =
{
    Type = 0,    
    IsDynamic = false,    
    IsFakeSpecular = false,
    LitParent = false,
    Pos = Vector:New(0,0,0),
    Color = Color:New(255,255,255,0),
	Intensity = 1,
    Direction = Vector:New(0,-1,0),
    StartFalloff = 2,
    Range = 3,
    ConeAngle = 90,
    Projector = "",
    Important = false,
    _Class = "CLight",

}
Inherit(CLight,CObject)
--============================================================================
function CLight:OnClone(old)
    if old == CLight then 
        self.Pos = OppositeToCamera() 
    else 
        self.Pos.X = old.Pos.X - 1
        self.Pos.Z = old.Pos.Z - 1
    end
    self._Entity = 0
end
--============================================================================
function CLight:Delete()
    WORLD.RemoveEntity(self._Entity)
    ENTITY.Release(self._Entity)
    EntityToObject[self._Entity] = nil
    self._Entity = nil
end
--============================================================================
function CLight:LoadData()
    ENTITY.Release(self._Entity)
    self._Entity = ENTITY.Create(ETypes.Light,"Script",self._Name)
    WORLD.AddEntity(self._Entity)
    EntityToObject[self._Entity] = self
end
--============================================================================
function CLight:Apply(old)
    if not old or (old.Type ~= self.Type) then 
        self:LoadData() 
    end    
    
    --- XXX compatybility mode
    if self.Radius then 
        self.Range = self.Radius 
        self.Radius = nil
    end
    
    if old and self.Range ~= old.Range then
        self.StartFalloff = self.StartFalloff*(self.Range/old.Range)
    end
    
    if self.StartFalloff > self.Range then
        self.StartFalloff = self.Range
    end
    
    LIGHT.Setup(self._Entity,self.Type,self.Color:Compose(),
                self.Direction.X,self.Direction.Y,self.Direction.Z,self.Intensity)    
    LIGHT.SetFalloff(self._Entity,self.StartFalloff,self.Range,self.ConeAngle)
    LIGHT.SetDynamicFlag(self._Entity,self.IsDynamic)       
    LIGHT.SetFakeSpecularFlag(self._Entity,self.IsFakeSpecular)
    LIGHT.SetLitParentFlag(self._Entity,self.LitParent)
	LIGHT.SetProjector(self._Entity,self.Projector)
    LIGHT.SetImportant(self._Entity,self.Important)
    ENTITY.SetPosition(self._Entity,self.Pos.X,self.Pos.Y,self.Pos.Z)

end
--============================================================================
--function CLight:Synchronize()
    -- synchronization with  C++ object
--    ENTITY.SetPosition(self._Entity,self.Pos.X,self.Pos.Y,self.Pos.Z)
--end
--============================================================================
function CreateLight(x,y,z,r,g,b,range1,range2,intensity)
    --Log("*CreateLight 1\n")
    --Log(GetCallStackInfo(2).."\n")
    --Log("*CreateLight 2\n")
    local e = ENTITY.Create(ETypes.Light)
    --Log("*CreateLight 3\n")
    ENTITY.SetPosition(e,x,y,z)
    --Log("*CreateLight 4\n")
    WORLD.AddEntity(e)
    --Log("*CreateLight 5\n")
    LIGHT.Setup(e,2,R3D.RGBA(r,g,b,255),0,0,0,intensity,"")
    LIGHT.SetFalloff(e,range1,range2)
    LIGHT.SetDynamicFlag(e,true)
    --Log("*CreateLight 6\n")
    return e
end
--============================================================================
function AddLight(template,scale,pos)
    local obj = CloneTemplate(template)
    --obj.Scale = obj.Scale * scale
    obj.Pos:Set(pos)
    obj:Apply()    
    LIGHT.SetDynamicFlag(obj._Entity,true)
    return obj._Entity
end
--============================================================================