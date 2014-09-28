function C5L2_Winda:OnInitTemplate()
    self._Synchronize = self.Synchronize
    self.Synchronize = nil
end

function C5L2_Winda:OnCreateEntity()

    if self.StartingAtTop == true then
        self.GoingState = self.WindaStates.IsUp
        self.PosUp = Vector:New( ENTITY.GetPosition( self._Entity ) )
        self.PosDown = Vector:New( self.PosUp.X, self.PosUp.Y, self.PosUp.Z )
        self.PosDown:Add( 0, -self.HeightDifference, 0 )

        local x, y, z = ENTITY.GetPosition( self._Entity ) 
        self:PO_Create(BodyTypes.FromMeshNonConvex, nil, ECollisionGroups.Fixed )
        ENTITY.PO_MaintainPosition( self._Entity, true, self.PosUp.X, self.PosUp.Y, self.PosUp.Z, 2.0 )
    else
        self.GoingState = self.WindaStates.IsDown
        self.PosDown = Vector:New( ENTITY.GetPosition( self._Entity ) )
        self.PosUp = Vector:New( self.PosDown.X, self.PosDown.Y, self.PosDown.Z )
        self.PosUp:Add( 0, self.HeightDifference, 0 )

        local x, y, z = ENTITY.GetPosition( self._Entity ) 
        self:PO_Create(BodyTypes.FromMeshNonConvex, nil, ECollisionGroups.Fixed)

        ENTITY.PO_MaintainPosition( self._Entity, true, self.PosDown.X, self.PosDown.Y, self.PosDown.Z, 2.0 )
    end

    ENTITY.PO_EnableSpeedDamping( self._Entity, true, 3.0, 0.0, 0.5 )
    ENTITY.PO_SetFreedomOfRotation( self._Entity, EFreedomsOfRotation.Disabled )
    ENTITY.PO_MaintainLinearMovement( self._Entity, true, 0, 1, 0 )
    ENTITY.EnableNetworkSynchronization(self._Entity)

    self._soundLoop = SOUND3D.Create("items/elevators/elevator"..self.SoundType.."-middle-loop")
    SOUND3D.SetHearingDistance(self._soundLoop,8,40)
    SOUND3D.SetLoopCount(self._soundLoop,0)
end

function C5L2_Winda:OnRelease()
	if self._soundLoop then
		SOUND3D.Delete(self._soundLoop)
		self._soundLoop = nil
	end
end

function C5L2_Winda:Update()
    if self.GoingState == self.WindaStates.IsUp then
        if self.Stop then
            self.Stop = false
        end
        if self.GoUp then
            self.GoUp = false
        end
        if self.GoDown then
            self.GoDown = false
            ENTITY.PO_MaintainPosition( self._Entity, false )
--            ENTITY.PO_MaintainLinearMovement( self._Entity, true, 0, 1, 0 )
            ENTITY.PO_MaintainVelocity( self._Entity, true, 0, -self.GoSpeed, 0 )
            ENTITY.PO_EnableSpeedDamping( self._Entity, false )
            self.GoingState = self.WindaStates.GoingDown
        end
    else
        if self.GoingState == self.WindaStates.IsDown then
            if self.Stop then
                self.Stop = false
            end
            if self.GoDown then
                self.GoDown = false
            end
            if self.GoUp then
                self.GoUp = false
                ENTITY.PO_MaintainPosition( self._Entity, false )
--                ENTITY.PO_MaintainLinearMovement( self._Entity, true, 0, 1, 0 )
                ENTITY.PO_MaintainVelocity( self._Entity, true, 0, self.GoSpeed, 0 )
                ENTITY.PO_EnableSpeedDamping( self._Entity, false )
                self.GoingState = self.WindaStates.GoingUp
            end
        else
            if self.GoingState == self.WindaStates.GoingUp then

                if self.GoUp then
                    self.GoUp = false
                end

                if self.GoDown then
                    ENTITY.PO_MaintainVelocity( self._Entity, true, 0, -self.GoSpeed, 0 )
                end

                if self.Stop then
                    self.Stop = false
					self:StopSound()
                    self.GoingState = self.WindaStates.Stopped
                    ENTITY.PO_MaintainVelocity( self._Entity, false )
--                    ENTITY.PO_MaintainLinearMovement( self._Entity, false )
                    local pos = Vector:New( ENTITY.GetPosition( self._Entity ) )
                    ENTITY.PO_MaintainPosition( self._Entity, true, pos.X, pos.Y, pos.Z, 2.0 )
                    ENTITY.PO_EnableSpeedDamping( self._Entity, true, 3.0, 0.0, 0.5 )
                else
                    local x, y, z = ENTITY.GetPosition( self._Entity )
                    if y > self.PosUp.Y then
                        self.GoingState = self.WindaStates.IsUp
                        self:StopSound()
                        ENTITY.PO_MaintainVelocity( self._Entity, false )
--                        ENTITY.PO_MaintainLinearMovement( self._Entity, false )
                        ENTITY.PO_MaintainPosition( self._Entity, true, self.PosUp.X, self.PosUp.Y, self.PosUp.Z, 2.0 )
                        ENTITY.PO_EnableSpeedDamping( self._Entity, true, 3.0, 0.0, 0.5 )
                    else
           				self:StartLoop(x,y,z)
					end
                end
            else
                if self.GoingState == self.WindaStates.GoingDown then

                    if self.GoDown then
                        self.GoDown = false
                    end

                    if self.GoUp then
                        ENTITY.PO_MaintainVelocity( self._Entity, true, 0, self.GoSpeed, 0 )
                    end
                
                    if self.Stop then
                        self.Stop = false
                        self.GoingState = self.WindaStates.Stopped
	       				self:StopSound()

                        ENTITY.PO_MaintainVelocity( self._Entity, false )
--                        ENTITY.PO_MaintainLinearMovement( self._Entity, false )
                        local pos = Vector:New( ENTITY.GetPosition( self._Entity ) )
                        ENTITY.PO_MaintainPosition( self._Entity, true, pos.X, pos.Y, pos.Z, 2.0 )
                        ENTITY.PO_EnableSpeedDamping( self._Entity, true, 3.0, 0.0, 0.5 )
                    else
                        local x, y, z = ENTITY.GetPosition( self._Entity )
                        if y < self.PosDown.Y then
							self:StopSound()
                            self.GoingState = self.WindaStates.IsDown
                            ENTITY.PO_MaintainVelocity( self._Entity, false )
--                            ENTITY.PO_MaintainLinearMovement( self._Entity, false )
                            ENTITY.PO_MaintainPosition( self._Entity, true, self.PosDown.X, self.PosDown.Y, self.PosDown.Z, 2.0 )
                            ENTITY.PO_EnableSpeedDamping( self._Entity, true, 3.0, 0.0, 0.5 )
                        else
							self:StartLoop(x,y,z)
						end
                    end
                else -- Stopped

                    if self.Stop then
                        self.Stop = false
                    end

                    if self.GoUp then
                        self.GoUp = false
                        ENTITY.PO_MaintainPosition( self._Entity, false )
--                        ENTITY.PO_MaintainLinearMovement( self._Entity, true, 0, 1, 0 )
                        ENTITY.PO_MaintainVelocity( self._Entity, true, 0, self.GoSpeed, 0 )
                        ENTITY.PO_EnableSpeedDamping( self._Entity, false )
                        self.GoingState = self.WindaStates.GoingUp
                    else
                        if self.GoDown then
                            self.GoDown = false
                            ENTITY.PO_MaintainPosition( self._Entity, false )
--                            ENTITY.PO_MaintainLinearMovement( self._Entity, true, 0, 1, 0 )
                            ENTITY.PO_MaintainVelocity( self._Entity, true, 0, -self.GoSpeed, 0 )
                            ENTITY.PO_EnableSpeedDamping( self._Entity, false )
                            self.GoingState = self.WindaStates.GoingDown
                        end
                    end
                end
            end
        end
    end
end

function o:StopSound()
	local x,y,z = ENTITY.GetPosition( self._Entity )
	if SOUND3D.IsPlaying(self._soundLoop) then
		SOUND3D.Stop(self._soundLoop)
	end
	PlaySound3D("items/elevators/elevator"..self.SoundType.."-stop",x,y,z,8,40)
end

function o:StartLoop(x,y,z)
	if not SOUND3D.IsPlaying(self._soundLoop) then
		self:BindSound("items/elevators/elevator"..self.SoundType.."-start",8,40,false)
		SOUND3D.Play(self._soundLoop)
	end
	SOUND3D.SetPosition(self._soundLoop,x,y,z)
end

function C5L2_Winda:EditTick( delta )
    ENTITY.PO_MaintainLinearMovement( self._Entity, false )
    self.PosDown = Vector:New( ENTITY.GetPosition( self._Entity ) )
    self.PosUp = Vector:New( self.PosDown.X, self.PosDown.Y, self.PosDown.Z )
    self.PosUp:Add( 0, self.HeightDifference, 0 )
    local x, y, z = ENTITY.GetPosition( self._Entity ) 
    ENTITY.PO_MaintainPosition( self._Entity, true, self.PosDown.X, self.PosDown.Y, self.PosDown.Z, 2.0 )
    ENTITY.PO_MaintainLinearMovement( self._Entity, true, 0, 1, 0 )
end
