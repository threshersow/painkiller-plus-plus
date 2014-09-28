--============================================================================
-- Vector 3D
--============================================================================
Vector = 
{
    X = 0,
    Y = 0,
    Z = 0,
    _Class = "Vector"
}
--============================================================================
function Vector:New(x,y,z)
    local v = Clone(Vector)
    v:Set(x,y,z)
    return v
end
--============================================================================
function Vector:New_FromEntity(entity)
    local v = Clone(Vector)
    v.X, v.Y, v.Z = ENTITY.GetPosition(entity)
    return v
end
--============================================================================
function Vector:ToEntity(e)
    ENTITY.SetPosition(e,self.X,self.Y,self.Z)
end
--============================================================================
function Vector:Copy()      -- potrzebne?
    return Clone(self)
end
--============================================================================
function Vector:Len()
    return math.sqrt(self.X*self.X + self.Y*self.Y+self.Z*self.Z)
end
--============================================================================
function Vector:Normalize()
    local m = self:Len()
    if m > 0.00001 then
        m = 1/m
        self.X = self.X * m
        self.Y = self.Y * m
        self.Z = self.Z * m
    else
        self.X = 0
        self.Y = 0
        self.Z = 0
    end
    return self
end
--============================================================================
function Vector:Set(x,y,z)
    if y == nil then
        self.X = x.X
        self.Y = x.Y
        self.Z = x.Z        
    else
        self.X = x
        self.Y = y
        self.Z = z
    end
end
--============================================================================
function Vector:Add(x,y,z)
    if y == nil then
        self.X = self.X + x.X
        self.Y = self.Y + x.Y
        self.Z = self.Z + x.Z        
    else
        self.X = self.X + x
        self.Y = self.Y + y
        self.Z = self.Z + z
    end
end
--============================================================================
function Vector:Interpolate(x,y,z,a)
    if z == nil then
        self.X = self.X + (x.X - self.X) * y
        self.Y = self.Y + (x.Y - self.Y) * y
        self.Z = self.Z + (x.Z - self.Z) * y 
    else
        self.X = self.X + (x - self.X) * a
        self.Y = self.Y + (y - self.Y) * a
        self.Z = self.Z + (z - self.Z) * a
    end
    return self
end
--============================================================================
function Vector:Sub(x,y,z)
    if y == nil then
        self.X = self.X - x.X
        self.Y = self.Y - x.Y
        self.Z = self.Z - x.Z        
    else
        self.X = self.X - x
        self.Y = self.Y - y
        self.Z = self.Z - z
    end
end
--============================================================================
function Vector:MulByFloat(a)
    self.X = self.X * a
    self.Y = self.Y * a
    self.Z = self.Z * a
end
--============================================================================
function Vector:Dot(x,y,z)
    if not y then
        return self.X * x.X + self.Y * x.Y + self.Z * x.Z
    else
        return self.X * x + self.Y * y + self.Z * z
    end
end
--============================================================================
function Vector:Get()
    return self.X,self.Y,self.Z
end
--============================================================================
function Vector:Dist(x,y,z)
    -- coords
    if y then return Dist3D(self.X,self.Y,self.Z,x,y,z) end
    -- vector
    return Dist3D(self.X,self.Y,self.Z,x.X,x.Y,x.Z)
end
--============================================================================
function Vector:Dist2D(x,y,z)
    -- coords
    if y then return Dist3D(self.X,0,self.Z,x,0,z) end
    -- vector
    return Dist3D(self.X,0,self.Z,x.X,0,x.Z)
end
--============================================================================
function Vector:ToString()
    return string.format("%.2f %.2f %.2f ",self.X,self.Y,self.Z)
end
--============================================================================
function Vector:SaveString()
    return "Vector:New("..self.X..","..self.Y..","..self.Z..")"
end
--============================================================================
function Vector:Compare(v)
    if self.X ~= v.X then return false end
    if self.Y ~= v.Y then return false end
    if self.Z ~= v.Z then return false end
    return true
end
--============================================================================
--function Vector:FromString(str)
--end
--============================================================================
function Vector:RotateZYX(az,ay,ax)
    -- Z
    local x = self.X * math.cos(az) - self.Y * math.sin(az)
    local y = self.X * math.sin(az) + self.Y * math.cos(az)
    self.X,self.Y = x,y
    -- Y
    local z = self.Z * math.cos(ay) - self.X * math.sin(ay)
    local x = self.Z * math.sin(ay) + self.X * math.cos(ay)
    self.Z,self.X = z,x
    -- X
    local y = self.Y * math.cos(ax) - self.Z * math.sin(ax)
    local z = self.Y * math.sin(ax) + self.Z * math.cos(ax)
    self.Y,self.Z = y,z
end
--============================================================================
function Vector:Rotate(ax,ay,az)
    -- X
    local y = self.Y * math.cos(ax) - self.Z * math.sin(ax)
    local z = self.Y * math.sin(ax) + self.Z * math.cos(ax)
    self.Y,self.Z = y,z
    -- Y
    local z = self.Z * math.cos(ay) - self.X * math.sin(ay)
    local x = self.Z * math.sin(ay) + self.X * math.cos(ay)
    self.Z,self.X = z,x
    -- Z
    local x = self.X * math.cos(az) - self.Y * math.sin(az)
    local y = self.X * math.sin(az) + self.Y * math.cos(az)
    self.X,self.Y = x,y
end
--============================================================================
