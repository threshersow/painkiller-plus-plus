--============================================================================
-- Area class
--============================================================================
CArea =
{
    _picked = -1,
    Points = {},
    HasRegion = false,
    _Class = "CArea",
}
Inherit(CArea,CObject)
--============================================================================
function CArea:AddFirstPoint()
    local n = table.getn(self.Points)
    if n < 1 then
        local x,y,z = CAM.GetForwardVector()
        self:AddPoint(Lev.Pos.X+x,Lev.Pos.Y+y,Lev.Pos.Z+z)
        return true
    end
    return false
end
--============================================================================
function CArea:GetPoint(idx)
    local p = self.Points[idx]
    if p then return p.X,p.Y,p.Z,p.A end
    return 0,0,0,0
end
--============================================================================
function CArea:OnClone(old)
    self.Points = Clone(old.Points)
    self:MoveAllPoints(1,1,1)    
    if Lev then self:AddFirstPoint() end
end
--============================================================================
function CArea:Delete()
    ENTITY.Release(self._Entity)
end
--============================================================================
function CArea:Apply(old)
    if self.HasRegion then
        ENTITY.Release(self._Entity)
        self._Entity = ENTITY.Create(ETypes.Region)
        REGION.BuildFromPoint(self._Entity,self.Points)
        --WORLD.AddEntity(self._Entity,true)
    end
    
    -- bug w lua, musze przeliczyc punkty po wczytaniu
    local n = 0
    for i,v in self.Points do  n = n + 1 end
    table.setn(self.Points,n)
end
--============================================================================
function CArea:AddPoint(x,y,z)
    local n = table.getn(self.Points)
    self.Points[n+1] = VectorA:New(x,y,z,0)
    table.setn(self.Points,n+1)
end
--============================================================================
function CArea:AddPointAt(x,y,z,at)
    local n = table.getn(self.Points)
    table.setn(self.Points,n+1)
	for i=n,at+1,-1 do
		self.Points[i+1] = self.Points[i]
	end	
    self.Points[at+1] = VectorA:New(x,y,z,0)
end
--============================================================================
function CArea:RemovePoint(idx)
    local n = table.getn(self.Points)
	for i=idx,n-1 do
		self.Points[i] = self.Points[i+1]
	end
    self.Points[n] = nil
    table.setn(self.Points,n-1)
end
--============================================================================
function CArea:MoveAllPoints(ax,ay,az)
    local n = table.getn(self.Points)
    for i=1,n do
        self.Points[i]:Add(ax,ay,az)
    end
end
--============================================================================
function BezierPoint(points,mu)

    local kn,nn,nkn
    local blend
    
    local n = table.getn(points)-1
    
    if mu >= 1 then return points[n+1] end
    
    local b = Vector:New(0,0,0)
    local muk = 1
    local munk = math.pow(1-mu,n)

    for k=0,n  do
        nn = n
        kn = k
        nkn = n - k;
        
        blend = muk * munk
        muk = muk * mu
        munk = munk / (1-mu)
        
        while (nn >= 1) do
            blend = blend * nn
            nn = nn-1
            if (kn > 1) then
                blend = blend / kn
                kn = kn-1
            end
            if (nkn > 1) then
                blend = blend / nkn
                nkn = nkn-1
            end 
        end
       
       --Game:Print(k)
       --Game:Print(blend)
       
        b.X = b.X + points[k+1].X * blend
        b.Y = b.Y + points[k+1].Y * blend
        b.Z = b.Z + points[k+1].Z * blend
    end
    
    --Game:Print(mu)
    --Game:Print(b.X..","..b.Y..","..b.Z)

    return b
end
--============================================================================
function CalcNaturalCubicSpline(points)

    local gamma = {}    
    local n = table.getn(points) - 1 
    
    gamma[0] = 1.0/2.0
    for i=1, n-1 do gamma[i] = 1/(4-gamma[i-1]) end
    gamma[n] = 1/(2-gamma[n-1])

    -- X
    local deltaX = {}; local DX = {}
    deltaX[0] = 3*(points[2].X-points[1].X)*gamma[0]
    for i=1, n-1 do deltaX[i] = (3*(points[i+2].X-points[i].X)-deltaX[i-1])*gamma[i] end
    deltaX[n] = (3*(points[n+1].X-points[n].X)-deltaX[n-1])*gamma[n]    
    DX[n] = deltaX[n]
    for i=n-1, 0, -1 do DX[i] = deltaX[i] - gamma[i]*DX[i+1] end
    -- Y
    local deltaY = {}; local DY = {}
    deltaY[0] = 3*(points[2].Y-points[1].Y)*gamma[0]
    for i=1, n-1 do deltaY[i] = (3*(points[i+2].Y-points[i].Y)-deltaY[i-1])*gamma[i] end
    deltaY[n] = (3*(points[n+1].Y-points[n].Y)-deltaY[n-1])*gamma[n]    
    DY[n] = deltaY[n]
    for i=n-1, 0, -1 do DY[i] = deltaY[i] - gamma[i]*DY[i+1] end
    -- Z
    local deltaZ = {}; local DZ = {}
    deltaZ[0] = 3*(points[2].Z-points[1].Z)*gamma[0]
    for i=1, n-1 do deltaZ[i] = (3*(points[i+2].Z-points[i].Z)-deltaZ[i-1])*gamma[i] end
    deltaZ[n] = (3*(points[n+1].Z-points[n].Z)-deltaZ[n-1])*gamma[n]    
    DZ[n] = deltaZ[n]
    for i=n-1, 0, -1 do DZ[i] = deltaZ[i] - gamma[i]*DZ[i+1] end

    -- now compute the coefficients of the cubics
    local C = {}
    for i=1, n do
      C[i] = {}
      C[i].X = {A = points[i].X, B = DX[i-1], C = 3*(points[i+1].X - points[i].X) - 2*DX[i-1] - DX[i], D = 2*(points[i].X - points[i+1].X) + DX[i-1] + DX[i]}
      C[i].Y = {A = points[i].Y, B = DY[i-1], C = 3*(points[i+1].Y - points[i].Y) - 2*DY[i-1] - DY[i], D = 2*(points[i].Y - points[i+1].Y) + DY[i-1] + DY[i]}
      C[i].Z = {A = points[i].Z, B = DZ[i-1], C = 3*(points[i+1].Z - points[i].Z) - 2*DZ[i-1] - DZ[i], D = 2*(points[i].Z - points[i+1].Z) + DZ[i-1] + DZ[i]}
    end
    
    return C
end
--============================================================================
function NCubicPoint(ctab,mu)
    local n = table.getn(ctab)
    local i = math.floor(n*mu) + 1

    if i > n then i = n end
    
    local u = 1-(i - (n*mu))
    local c = ctab[i]
    
    local p = Vector:New(0,0,0)
    if c then
        p.X = (((c.X.D*u) + c.X.C)*u + c.X.B)*u + c.X.A
        p.Y = (((c.Y.D*u) + c.Y.C)*u + c.Y.B)*u + c.Y.A
        p.Z = (((c.Z.D*u) + c.Z.C)*u + c.Z.B)*u + c.Z.A
    end
    
    return p
end
--============================================================================
function NCubicDerivative(ctab,mu)
    local n = table.getn(ctab)
    local i = math.floor(n*mu) + 1

    local u = 1-(i - (n*mu))
    local c = ctab[i]

    local p = Vector:New(0,0,0)
    if c then
        p.X = ((c.X.D*3*u) + c.X.C*2)*u + c.X.B
        p.Y = ((c.Y.D*3*u) + c.Y.C*2)*u + c.Y.B
        p.Z = ((c.Z.D*3*u) + c.Z.C*2)*u + c.Z.B
    end
    
    return p
end
--============================================================================
function CArea:IsInside(x,y,z,ztolerance)
    
    local ch = false
    local cnt = table.getn(self.Points)
	
	for iv=1,cnt do 

        local p1 = self.Points[iv]
        local p2 = self.Points[iv+1]
        if iv == cnt then p2 = self.Points[1] end

        -- to przeniesc do C++
		if ((((p1.Z <= z) and (z < p2.Z)) or
		   ((p2.Z <= z) and (z < p1.Z))) and
           (x < (p2.X - p1.X) * (z - p1.Z) / (p2.Z - p1.Z) + p1.X))
              then ch = not ch end
    
	end
	
	return ch
end
--============================================================================
