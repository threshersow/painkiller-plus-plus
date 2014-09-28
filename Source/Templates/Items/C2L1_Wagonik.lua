function C2L1_Wagonik:OnInitTemplate()
    self._Synchronize = self.Synchronize
    self.Synchronize = nil
end

function C2L1_Wagonik:OnCreateEntity()

    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
    self.HoldJoint = MDL.GetJointIndex( self._Entity, "joint1_getmass" )

    self.UpDir = Clone(self.PosUp)
    self.UpDir:Sub( self.PosDown.X, self.PosDown.Y, self.PosDown.Z )
    self.UpDir:Normalize()
    self.UpVel = Clone(self.UpDir)
    self.UpVel:MulByFloat(self.GoSpeed)

    self.CurSpeed = 0

    self.PosDown.X, self.PosDown.Y, self.PosDown.Z = MDL.GetJointPos( self._Entity, self.HoldJoint )
end


function C2L1_Wagonik:Update()
    if self.GoingState == self.WagonikStates.IsUp then

        if self.CurSpeed > 0.005 then

            self.IsStopped = nil

            local x,y,z = MDL.GetJointPos( self._Entity, self.HoldJoint )

            if self.CurSpeed > self.Acceleration then
                self.CurSpeed = self.CurSpeed - self.Acceleration
            else
                self.CurSpeed = 0
            end

            self.UpDir = Clone(self.PosUp)
            self.UpDir:Sub(self.PosDown.X,self.PosDown.Y,self.PosDown.Z)
            self.UpDir:Normalize()
            self.UpVel = Clone(self.UpDir)
            self.UpVel:MulByFloat(self.CurSpeed)

            MDL.ApplyVelocitiesToJoint( self._Entity, self.HoldJoint, self.UpVel.X, self.UpVel.Y, self.UpVel.Z, 0, 0, 0 )
        else
            if not self.IsStopped then
                self.IsStopped = true
                MDL.ApplyVelocitiesToJoint( self._Entity, self.HoldJoint, 0, 0, 0, 0, 0, 0 )
            end
        end

        if self.GoUp then
            self.GoUp = false
        end

        if self.Stop then
            self.Stop = false
            self.StayTimer = nil
            self.GoingState = self.WagonikStates.Stopped
        end

        if self.GoDown or ( self.StayTimer and self.StayTimer > 100 ) then
            self.StayTimer = nil
            self.GoDown = false
            self.GoingState = self.WagonikStates.GoingDown
            self.LastHoldJointPos.X, self.LastHoldJointPos.Y, self.LastHoldJointPos.Z = MDL.GetJointPos( self._Entity, self.HoldJoint )
        end

    else
        if self.GoingState == self.WagonikStates.IsDown then

            if self.CurSpeed > 0 then

                self.IsStopped = nil

                local x,y,z = MDL.GetJointPos( self._Entity, self.HoldJoint )

                if self.CurSpeed > self.Acceleration then
                    self.CurSpeed = self.CurSpeed - self.Acceleration
                else
                    self.CurSpeed = 0
                end

                self.UpDir = Clone(self.PosDown)
                self.UpDir:Sub(self.PosUp.X,self.PosUp.Y,self.PosUp.Z)
                self.UpDir:Normalize()
                self.UpVel = Clone(self.UpDir)
                self.UpVel:MulByFloat(self.CurSpeed)

                MDL.ApplyVelocitiesToJoint( self._Entity, self.HoldJoint, self.UpVel.X, self.UpVel.Y, self.UpVel.Z, 0, 0, 0 )
            else
                if not self.IsStopped then
                    self.IsStopped = true
                    MDL.ApplyVelocitiesToJoint( self._Entity, self.HoldJoint, 0, 0, 0, 0, 0, 0 )
                end
            end

            if self.GoDown then
                self.GoDown = false
            end

            if self.Stop then
                self.Stop = false
                self.StayTimer = nil
                self.GoingState = self.WagonikStates.Stopped
            end

            if self.GoUp or ( self.StayTimer and self.StayTimer > 100 ) then
                self.StayTimer = nil
                self.GoUp = false
                self:BindSound("misc/mountain_railway-start",8,40,false,self.HoldJoint)
                self._sndLoop = self:BindSound("misc/mountain_railway-loop",8,40,true,self.HoldJoint)
                self.GoingState = self.WagonikStates.GoingUp
                self.LastHoldJointPos.X, self.LastHoldJointPos.Y, self.LastHoldJointPos.Z = MDL.GetJointPos( self._Entity, self.HoldJoint )
            end

        else
            if self.GoingState == self.WagonikStates.GoingUp then

                local x,y,z = MDL.GetJointPos( self._Entity, self.HoldJoint )

                local distUp = Vector:New(self.PosUp.X,self.PosUp.Y,self.PosUp.Z)
                distUp:Sub( x,y,z )
                local lenUp = distUp:Len()

                local distDown = Vector:New(self.PosDown.X,self.PosDown.Y,self.PosDown.Z)
                distDown:Sub( x,y,z )
                local lenDown = distDown:Len()

                local maxSpeed = self.GoSpeed

                if 0.5*lenDown < maxSpeed then
                    maxSpeed = 0.5*lenDown
                end

                if 0.4*lenUp < maxSpeed then
                    maxSpeed = 0.4*lenUp
                end

                if maxSpeed < 0.1 then
                    maxSpeed = 0.1
                end

                local braking = false
                if self.CurSpeed > maxSpeed then
                    braking = true
                end

                self.CurSpeed = maxSpeed

                self.UpDir = Clone(self.PosUp)
                self.UpDir:Sub( x,y,z )
                self.UpDir:Normalize()
                self.UpVel = Clone(self.UpDir)
                self.UpVel:MulByFloat(self.CurSpeed)

                local posDiff = Vector:New(x,y,z)
                posDiff:Sub( self.LastHoldJointPos.X, self.LastHoldJointPos.Y, self.LastHoldJointPos.Z )

                if not braking then
                    MDL.ApplyPointImpulseToRagdoll( self._Entity, 0,0,0, posDiff.X,posDiff.Y,posDiff.Z )
                end
                MDL.ApplyVelocitiesToJoint( self._Entity, self.HoldJoint, self.UpVel.X, self.UpVel.Y, self.UpVel.Z, 0, 0, 0 )
                self.LastHoldJointPos.X, self.LastHoldJointPos.Y, self.LastHoldJointPos.Z = x, y, z

                if self.GoDown then
                    self.GoingState = self.WagonikStates.GoingDown
                    self.CurSpeed = -self.CurSpeed
                end

                if self.GoUp then
                    self.GoUp = false
                end

                if self.Stop then
                    self.Stop = false
                    self.StayTimer = nil
                    self.GoingState = self.WagonikStates.Stopped
                end

                if y > self.PosUp.Y - 1.0 and self._sndLoop then
                    if self._sndLoop then
						ENTITY.Release(self._sndLoop)
						self._sndLoop = nil
                    end
                    self:BindSound("misc/mountain_railway-stop",12,48,false,self.HoldJoint)
                end

                if y > self.PosUp.Y then
                    self.StayTimer = 1
                    self.GoingState = self.WagonikStates.IsUp
                end

            else
                if self.GoingState == self.WagonikStates.GoingDown then

                    local x,y,z = MDL.GetJointPos( self._Entity, self.HoldJoint )

                    local distUp = Vector:New(self.PosUp.X,self.PosUp.Y,self.PosUp.Z)
                    distUp:Sub( x,y,z )
                    local lenUp = distUp:Len()

                    local distDown = Vector:New(self.PosDown.X,self.PosDown.Y,self.PosDown.Z)
                    distDown:Sub( x,y,z )
                    local lenDown = distDown:Len()

                    local maxSpeed = self.GoSpeed

                    if 0.4*lenDown < maxSpeed then
                        maxSpeed = lenDown*0.4
                    end

                    if 0.5*lenUp < maxSpeed then
                        maxSpeed = 0.5*lenUp
                    end

                    if maxSpeed < 0.1 then
                        maxSpeed = 0.1
                    end

                    local braking = false
                    if self.CurSpeed > maxSpeed then
                        braking = true
                    end

                    self.CurSpeed = maxSpeed

                    self.UpDir = Clone(self.PosDown)
                    self.UpDir:Sub( x,y,z )
                    self.UpDir:Normalize()
                    self.UpVel = Clone(self.UpDir)
                    self.UpVel:MulByFloat(self.CurSpeed)

                    local posDiff = Vector:New(x,y,z)
                    posDiff:Sub( self.LastHoldJointPos.X, self.LastHoldJointPos.Y, self.LastHoldJointPos.Z )

                    if not braking then
                        MDL.ApplyPointImpulseToRagdoll( self._Entity, 0,0,0, posDiff.X,posDiff.Y,posDiff.Z )
                    end
                    MDL.ApplyVelocitiesToJoint( self._Entity, self.HoldJoint, self.UpVel.X, self.UpVel.Y, self.UpVel.Z, 0, 0, 0 )
                    self.LastHoldJointPos.X, self.LastHoldJointPos.Y, self.LastHoldJointPos.Z = x, y, z


                    if self.GoUp then
                        self.GoingState = self.WagonikStates.GoingUp
                        self.CurSpeed = -self.CurSpeed
                    end

                    if self.GoDown then
                        self.GoDown = false
                    end
                
                    if self.Stop then
                        self.Stop = false
                        self.StayTimer = nil
                        self.GoingState = self.WagonikStates.Stopped
                    end

                    if y < self.PosDown.Y then
                        self.StayTimer = 1
                        self.GoingState = self.WagonikStates.IsDown
                    end
                else  -- Stopped

                    local speed
                    self.UpDir.X,self.UpDir.Y,self.UpDir.Z,speed = MDL.GetVelocitiesFromJoint( self._Entity, self.HoldJoint )
                    if speed > 0.1 then
                        self.IsStopped = nil
                        self.UpDir.X = self.UpDir.X / speed
                        self.UpDir.Y = self.UpDir.Y / speed
                        self.UpDir.Z = self.UpDir.Z / speed

                        local x,y,z = MDL.GetJointPos( self._Entity, self.HoldJoint )

                        if speed > self.Acceleration then
                            self.CurSpeed = speed - self.Acceleration
                        else
                            self.CurSpeed = 0
                        end

                        self.UpVel = Clone(self.UpDir)
                        self.UpVel:MulByFloat(self.CurSpeed)

                        MDL.ApplyVelocitiesToJoint( self._Entity, self.HoldJoint, self.UpVel.X, self.UpVel.Y, self.UpVel.Z, 0, 0, 0 )
                    else
                        if not self.IsStopped then
                            self.IsStopped = true
                            MDL.ApplyVelocitiesToJoint( self._Entity, self.HoldJoint, 0, 0, 0, 0, 0, 0 )
                        end
                    end


                    if self.Stop then
                        self.Stop = false
                    end

                    if self.GoUp then
                        self.StayTimer = nil
                        self.GoUp = false
                        self.GoingState = self.WagonikStates.GoingUp
                        self.LastHoldJointPos.X, self.LastHoldJointPos.Y, self.LastHoldJointPos.Z = MDL.GetJointPos( self._Entity, self.HoldJoint )
                    end

                    if self.GoDown then
                        self.StayTimer = nil
                        self.GoDown = false
                        self.GoingState = self.WagonikStates.GoingDown
                        self.LastHoldJointPos.X, self.LastHoldJointPos.Y, self.LastHoldJointPos.Z = MDL.GetJointPos( self._Entity, self.HoldJoint )
                    end
                end
            end
        end
    end
end
			