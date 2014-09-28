--============================================================================
-- Box class
--============================================================================
CBox =
{
    Size = 
    {
        Width  = 2,
        Height = 4,
        Depth  = 1,
    },  
    Actions = {
        OnTouch    = {},
    },   
    TouchAction = {},  -- for compatibility
    ToLaunch = {}, 
    Pos = Vector:New(0,0,0),
    --Ang = Vector:New(0,0,0),
    --HasRegion = false,
    _Class = "CBox",
}
Inherit(CBox,CObject)
--============================================================================
function CBox:OnClone(old)
    if old == CBox then 
        self.Pos = OppositeToCamera() 
    else
        self.Pos.X = old.Pos.X - 0.5
        self.Pos.Z = old.Pos.Z - 0.5
    end
    self._Entity = nil
end
--============================================================================
function CBox:Apply(old)
    if self.TouchAction and table.getn(self.TouchAction) > 0 then 
        if not self.Actions then
			self.Actions = {}
		end
        self.Actions.OnTouch = self.TouchAction 
    end
    self.TouchAction = nil
    if self.HasRegion then
        --ENTITY.Release(self._Entity)
        --self._Entity = ENTITY.Create(ETypes.Region)
        --REGION.BuildFromPoint(self._Entity,self.Points)
        --WORLD.AddEntity(self._Entity,true)
    end
    if self.OnApply then self:OnApply() end
end

--============================================================================
function CBox:IsInside(x,y,z)    
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
function CBox:IsInsideExtruded(x,y,z,ex,ey,ez)    
    local w = self.Size.Width  / 2 + ex
    local h = self.Size.Height / 2 + ey
    local d = self.Size.Depth  / 2 + ez

    if x >= self.Pos.X - w and x <= self.Pos.X + w and 
       y >= self.Pos.Y - h and y <= self.Pos.Y + h and 
       z >= self.Pos.Z - d and z <= self.Pos.Z + d then
           return true
    end
    return false
end

--============================================================================
function CBox:LaunchObjects()
    if self.Actions then
        self:LaunchAction(self.Actions.OnTouch)
    end
    
    Game:Print(self._Name.." lunch")
    for i,v in self.ToLaunch do
        local obj = _G[v]
        if obj then 
			Game:Print(self._Name.." launch "..obj._Name)
            if obj.OnLaunch then obj:OnLaunch() end
            obj._Launched = true 
        end
    end
    
end
--============================================================================
function CreateRegion(width,height,depth)
    
    local w = width  / 2
    local h = height / 2
    local d = depth  / 2

    local p = {}    
    p[1] = Vector:New(-w,-h,-d)
    p[2] = Vector:New(-w,-h,d)
    p[3] = Vector:New(w,-h,d)
    p[4] = Vector:New(w,-h,-d)
    p[5] = Vector:New(-w,h,-d)
    p[6] = Vector:New(-w,h,d)
    p[7] = Vector:New(w,h,d)
    p[8] = Vector:New(w,h,-d)

    local e = ENTITY.Create(ETypes.Region)    
    REGION.BuildFromPoint(e,p)
    WORLD.AddEntity(e,true)
    return e
end
