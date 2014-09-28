--============================================================================
-- Quaternion
--============================================================================
Quaternion = 
{
    W = 1,
    X = 0,
    Y = 0,
    Z = 0,
    _Class = "Quaternion"
}
--============================================================================
function Quaternion:New(w,x,y,z)
    local v = Clone(Quaternion)
    if w then 
        v:Set(w,x,y,z)
    else
        v:Set(1,0,0,0)
    end
    return v
end
--============================================================================
function Quaternion:New_FromNormal(nx,ny,nz)
    local q = Clone(Quaternion)
    q:FromNormalY(nx,ny,nz)
    return q
end
--============================================================================
function Quaternion:New_FromNormalZ(nx,ny,nz)
    local q = Clone(Quaternion)
    q:FromNormalZ(nx,ny,nz)
    return q
end
--============================================================================
function Quaternion:New_FromNormalY(nx,ny,nz)       -- ZMIENIC: ts. co fromZ
    local q = Clone(Quaternion)
    q:FromNormalZ(nx,ny,nz)
    return q
end
--============================================================================
function Quaternion:New_FromNormalX(nx,ny,nz)          -- ZMIENIC: ts. co fromZ
    local q = Clone(Quaternion)
    q:FromNormalZ(nx,ny,nz)
    return q
end
--============================================================================
function Quaternion:New_FromEntity(e)
    local q = Clone(Quaternion)
    q:FromEntity(e)
    return q
end
--============================================================================
function Quaternion:New_FromEuler(ax,ay,az)
    local q = Clone(Quaternion)
    q:FromEuler(ax,ay,az)
    return q
end
--============================================================================
function Quaternion:New_FromEulerZYX(ax,ay,az)
    local q = Clone(Quaternion)
    q:FromEulerZYX(ax,ay,az)
    return q
end
--============================================================================
function Quaternion:Set(w,x,y,z)
    if x == nil then
        self.W = x.W 
        self.X = x.X
        self.Y = x.Y
        self.Z = x.Z 
    else
        self.W = w
        self.X = x
        self.Y = y
        self.Z = z
    end
end
--============================================================================
function Quaternion:FromEuler(ax,ay,az)
    self.W, self.X, self.Y, self.Z = EulerToQuat(ax,ay,az)
end
--============================================================================
function Quaternion:FromEulerZYX(ax,ay,az)
    self.W, self.X, self.Y, self.Z = EulerToQuat(az, ay, ax)
end
--============================================================================
--[[function Quaternion:FromNormal(nx,ny,nz)
    local ay = math.atan2(nx,-nz) + math.pi/2
    self:FromEuler(0,ay,-math.pi/2 + ny*math.pi/2)    
end--]]
--============================================================================
function Quaternion:FromNormalZ(nx,ny,nz)
    self.W, self.X, self.Y, self.Z = NormalZToQuat(nx,ny,nz)
end
function Quaternion:FromNormalY(nx,ny,nz)
    self.W, self.X, self.Y, self.Z = NormalYToQuat(nx,ny,nz)
end
function Quaternion:FromNormalX(nx,ny,nz)
    self.W, self.X, self.Y, self.Z = NormalXToQuat(nx,ny,nz)
end
--Quaternion.FromNormal001 = Quaternion.FromNormalZ   -- WYWALIC: ts. co FromEulerZYX
--Quaternion.FromNormal = Quaternion.FromNormalY
--============================================================================
function Quaternion:ToEuler()
    return QuatToEuler(self.W, self.X, self.Y, self.Z)
end
--============================================================================
--function Quaternion:FromString(str)
--end
--============================================================================
function Quaternion:SaveString()
    return "Quaternion:New("..self.W..","..self.X..","..self.Y..","..self.Z..")"
end
--============================================================================
function Quaternion:FromEntity(e)
    self.W, self.X, self.Y, self.Z = ENTITY.GetRotationQ(e)
end
--============================================================================
function Quaternion:TransformVector(x,y,z)
    if y == nil then
        x = x.X
        y = x.Y
        z = x.Z
    end
    return VectorRotateByQuat(x,y,z,self.W,self.X,self.Y,self.Z)
end
--============================================================================
function Quaternion:InverseTransformVector(x,y,z)
    if y == nil then
        x = x.X
        y = x.Y
        z = x.Z
    end
    return VectorInverseRotateByQuat(x,y,z,self.W,self.X,self.Y,self.Z)
end
--============================================================================
function Quaternion:ToEntity(e)
    ENTITY.SetRotationQ(e,self.W, self.X, self.Y, self.Z)
end
--============================================================================
function Quaternion:RotateByAngleAxis(angle,ax,ay,az) -- np. PI,0,1,0 - rotate by 90 in Y axis
    self.W, self.X, self.Y, self.Z = RotateQuatByAxisAngle(self.W, self.X, self.Y, self.Z,angle,ax,ay,az)
end
--============================================================================
function Quaternion:Compare(q)
    if self.W ~= q.W then return false end
    if self.X ~= q.X then return false end
    if self.Y ~= q.Y then return false end
    if self.Z ~= q.Z then return false end
    return true
end
--============================================================================
function Quaternion:Normalize()
    local l = self.W*self.W + self.X*self.X + self.Y*self.Y + self.Z*self.Z
    l = 1/math.sqrt(l)
    self.W = self.W * l
    self.X = self.X * l
    self.Y = self.Y * l
    self.Z = self.Z * l
end
