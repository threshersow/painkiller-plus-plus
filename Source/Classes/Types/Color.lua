--============================================================================
-- Color
--============================================================================
Color = 
{
    R = 255,
    G = 255,
    B = 255,
    A = 0,
    _Class = "Color"
}
--============================================================================
function Color:New(r,g,b,a)
    local c = Clone(Color)
    c:Set(r,g,b,a)
    return c
end
--============================================================================
function Color:Set(r,g,b,a)
    self.R = r
    self.G = g
    self.B = b
    if a then self.A = a else self.A = 0 end
end
--============================================================================
function Color:Compose()
    return R3D.RGBA(self.R,self.G,self.B,self.A)
end
--============================================================================
function Color:ToString()
    return string.format("%d %d %d %d",self.R,self.G,self.B,self.A)
end
--============================================================================
function Color:SaveString(x,y,z)
    return "Color:New("..self.R..","..self.G..","..self.B..","..self.A..")"
end
--============================================================================
--[[
function Color:FromString(str)
end
--]]
--============================================================================
function Color:Compare(color)
    if self.R ~= color.R then return false end
    if self.G ~= color.G then return false end
    if self.B ~= color.B then return false end
    if self.A ~= color.A then return false end
    return true
end
--============================================================================
