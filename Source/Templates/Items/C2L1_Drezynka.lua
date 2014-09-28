function C2L1_Drezynka:OnInitTemplate()
    self._Synchronize = self.Synchronize
    self.Synchronize = nil
end

function C2L1_Drezynka:OnCreateEntity()
    ENTITY.SetPosition( self._Entity, self.Pos.X, self.Pos.Y, self.Pos.Z )
    self:PO_Create(BodyTypes.FromRagdoll)
    ENTITY.PO_MaintainPosition( self._Entity, true, self.Pos.X, self.Pos.Y, self.Pos.Z, 15.0 )
    ENTITY.PO_EnableSpeedDamping( self._Entity, true, 3.0, 0.0, 0.5 )
    ENTITY.PO_SetFreedomOfRotation( self._Entity, EFreedomsOfRotation.Disabled )
    ENTITY.RemoveRagdoll( self._Entity )
    MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, 0 )

end

function C2L1_Drezynka:Update()

    if self.GoingState == DrezynkaStates.Stopped then

        if self.Go then
            self.Go = false
            self.GoingState = DrezynkaStates.Going

            ENTITY.PO_MaintainPosition( self._Entity, false )
            ENTITY.SetPosition( self._Entity, self.PosStart.X, self.PosStart.Y, self.PosStart.Z )
            ENTITY.PO_MaintainLinearMovement( self._Entity, true, self.SpeedVector.X, self.SpeedVector.Y, self.SpeedVector.Z, true )
            ENTITY.PO_MaintainVelocity( self._Entity, true, 0, 0, 0 )
            ENTITY.PO_EnableSpeedDamping( self._Entity, false )
            self.CurSpeed = 0.0

			self._sndLoop = self:BindSound("misc/drezyna-loop",8,40,true)
        end

    else
        if self.GoingState == DrezynkaStates.Going then

            local x,y,z = ENTITY.GetPosition( self._Entity )
            local distVec = Clone( self.PosStart )
            distVec:Sub( x, y, z )
            local len = distVec:Len()

            if len > self.DistGoFree then

				if self._sndLoop then
					ENTITY.Release(self._sndLoop)
					self._sndLoop = nil
				end
				self:BindSound("misc/drezyna-stop",8,40,false)

                Game:Print( 'GoFree - Pos: '..x..','..y..','..z..' , len: '..len )

                PLAYER.DetachFromUnderBody( Player._Entity )
                self.GoingState = DrezynkaStates.GoingFree
                self.TimerBeforePin = 100
                ENTITY.PO_MaintainLinearMovement( self._Entity, false )
                ENTITY.PO_MaintainVelocity( self._Entity, false )
                ENTITY.PO_SetFreedomOfRotation( self._Entity, EFreedomsOfRotation.FullFree )
                MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, 0 )
                ENTITY.PO_SetLinearDamping( self._Entity, 0.95 )
                ENTITY.PO_SetAngularDamping( self._Entity, 0.99 )
                ENTITY.PO_SetHardDeactivator()
            end

            if self.CurSpeed < self.MaxSpeed then
                self.CurSpeed = self.CurSpeed + self.Acceleration
            end
--            ENTITY.SetVelocity( self._Entity, self.SpeedVector.X*self.CurSpeed, self.SpeedVector.Y*self.CurSpeed, self.SpeedVector.Z*self.CurSpeed )

            local vx,vy,vz,speed = ENTITY.GetVelocity( self._Entity )

            MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, 0.5*self.CurSpeed )
            
            if self.CurSpeed < self.MaxSpeed then
                self.CurSpeed = self.CurSpeed + self.Acceleration
                ENTITY.PO_MaintainVelocity( self._Entity, true,
                    self.SpeedVector.X*self.CurSpeed, self.SpeedVector.Y*self.CurSpeed, self.SpeedVector.Z*self.CurSpeed, 0.5 )
            end

        else
            if self.GoingState == DrezynkaStates.GoingFree then
                self.TimerBeforePin = self.TimerBeforePin-1
                if self.TimerBeforePin == 0 then
                    self.GoingState = DrezynkaStates.Pinned
                    ENTITY.PO_SetPinned( self._Entity, true )
                end
            end
        end
    end
end
