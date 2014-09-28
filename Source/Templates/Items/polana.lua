function polana:OnInitTemplate()
    self.Update = nil
    self._Synchronize = self.Synchronize
    self.Synchronize = nil
end

function polana:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMeshNotCentered)
	ENTITY.PO_SetPinned( self._Entity, true )
end


function polana:burn()
	local s = self.s_SubClass.SoundsDefinitions.burnin
	if s then
		self._snd = self:BindSound(s.samples[1], s.dist1, s.dist2, true)
	end
end

function polana:CustomOnDeath()
	ENTITY.Release(self._snd)
end
