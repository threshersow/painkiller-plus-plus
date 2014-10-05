function C3L3_SilosCover:OnInitTemplate()
    --self.Update = nil
    --self._Synchronize = self.Synchronize
    --self.Synchronize = nil
    self.closed = false
    self.close = false
end

function C3L3_SilosCover:OnCreateEntity()
    self:PO_Create( BodyTypes.FromMesh )
    ENTITY.PO_SetPinned( self._Entity, true )
    self.orygPos = Clone(self.Pos)
end

function C3L3_SilosCover:Tick(delta)
	if not self.closed and self.close then
		--self.orygPos
		self.Pos.X = self.Pos.X - delta * self.closeSpeed 
		if self.Pos.X < 49 then
			self.closed = true
			if self._sndLoop then
				ENTITY.Release(self._sndLoop)
				self._sndLoop = nil
			end
			return
		end
		ENTITY.SetPosition(self._Entity, self.Pos.X, self.Pos.Y, self.Pos.Z)
	end
end

function C3L3_SilosCover:Close()
	self._sndLoop = self:BindSound("items/elevators/elevator4-middle-loop",30,90,true)
    self.close = true
end
