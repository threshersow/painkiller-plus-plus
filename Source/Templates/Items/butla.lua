o.OnInitTemplate = CItem.StdOnInitTemplate

function butla:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
    ENTITY.EnableCollisions(self._Entity, true, 0.25, self.Destroy.MinSpeedOnCollision*0.5)
    ENTITY.PO_SetAngularDamping(self._Entity,4.0)
    self.OnCollision = CItem.StdOnCollision
end

function butla:OnDamage(damage, obj, attack_type, x, y, z , nx ,ny, nz )    

    local hole = true
    local p = Vector:New(0,-7,0)    
    local dir = Vector:New(0,1,0)
    
    if self.SingleBottomHole then    
        if self.Impulses then hole = false end
    else
        if x and nx then        
            p.X, p.Y, p.Z = ENTITY.ComputeLocalPoint(self._Entity,x,y,z)            
            dir:Set(-nx, -ny, -nz)               
        else
            hole = false
        end
    end    

    if hole then
        if not self._snd then
            self._snd = SOUND3D.Create("misc/gas-outflow-5sec")
            SOUND3D.SetHearingDistance(self._snd,18,30) 
            SOUND3D.SetPosition(self._snd,x,y,z) 
            SOUND3D.Play(self._snd)
        end
    
        if not self.Impulses then 
            self.Impulses = {} 
            ENTITY.PO_SetFriction(self._Entity,0)
        end    
        
        local q = Quaternion:New_FromEntity(self._Entity)
        
        dir.X,dir.Y,dir.Z = q:InverseTransformVector(dir.X,dir.Y,dir.Z)
        dir:Normalize()
        
        table.insert(self.Impulses,{p,dir})
        self._pfx = AddPFX("butlagas",0.2)--,Vector:New(x,y,z))
        ENTITY.RegisterChild(self._Entity,self._pfx)    
        local ax,ay,az = Quaternion:New_FromNormal(-dir.X,-dir.Y,-dir.Z):ToEuler()        
		--PARTICLE.SetParentOffset(self._pfx,p.X*self.Scale,p.Y*self.Scale,p.Z*self.Scale)
		PARTICLE.SetParentOffset(self._pfx,p.X*self.Scale,p.Y*self.Scale,p.Z*self.Scale,nil,0,0,0, ax,ay,az)-- -math.pi/2,math.pi/2,math.pi/2)
    end
        
    
    CItem.OnDamage(self,damage)   
end

function butla:Delete()
    SOUND3D.Delete(self._snd)
    CItem.Delete(self)
end


function butla:CustomOnDeath()
	if self._pfx then
		PARTICLE.Die(self._pfx)
		self._pfx = nil
	end
end

function butla:Tick(delta)
    if not self.Impulses then return end
       
    self.ExplosionTimer = self.ExplosionTimer -  delta
    if self.ExplosionTimer < 0 then
        CItem.OnDamage(self,9999999)
        return
    end
    
    local q = Quaternion:New_FromEntity(self._Entity)        
    local ex,ey,ez = ENTITY.GetPosition(self._Entity)        
    if self._snd then
        SOUND3D.SetPosition(self._snd,ex,ey,ez)
    end
    
    local n = table.getn(self.Impulses)
    for i,o in self.Impulses do
        
        local x,y,z = ENTITY.TransformLocalPointToWorld(self._Entity,o[1].X,o[1].Y,o[1].Z)        
        
        local dir = Vector:New(0,0,0)
        dir.X,dir.Y,dir.Z = q:TransformVector(o[2].X,o[2].Y,o[2].Z)
        dir:Normalize()
        
        --local q = Quaternion:New_FromNormalZ(-dir.X, -dir.Y, -dir.Z)
		--q:ToEntity(self._pfx)
		--ENTITY.SetPosition(self._pfx,x,y,z) 
        
        local a = (self.RepulsePower + n * self.RepulsePower/2) * delta / n
		ENTITY.PO_Impulse(self._Entity,x,y,z,dir.X*a,dir.Y*a,dir.Z*a)
        --Game:Print(i..": "..dx..", "..dy..", "..dz)
    end
end
