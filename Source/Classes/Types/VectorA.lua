--============================================================================
-- Vector 3D +  Orientation
--============================================================================
VectorA = 
{
    X = 0,
    Y = 0,
    Z = 0,
    A = 0, -- Angle
    _Class = "VectorA"
}
Inherit(VectorA,Vector)
--============================================================================
function VectorA:New(x,y,z,a)
    local v = Clone(VectorA)
    v:Set(x,y,z,a)
    return v
end
--============================================================================
function VectorA:Set(x,y,z,a)
    if y == nil then
        self.X = x.X
        self.Y = x.Y
        self.Z = x.Z 
        if x.A then self.A = x.A end
    else
        self.X = x
        self.Y = y
        self.Z = z
        if a then self.A = a end
    end
end
--============================================================================
function VectorA:ToString()
    return string.format("%.2f %.2f %.2f %2f ",self.X,self.Y,self.Z,self.A)
end
--============================================================================
function VectorA:SaveString()
    return "VectorA:New("..self.X..","..self.Y..","..self.Z..","..self.A..")"
end
--============================================================================
function Vector:Compare(v)
    if self.X ~= v.X then return false end
    if self.Y ~= v.Y then return false end
    if self.Z ~= v.Z then return false end
    if self.A ~= v.A then return false end
    return true
end
--============================================================================
--function VectorA:FromString(str)
--end
--============================================================================

