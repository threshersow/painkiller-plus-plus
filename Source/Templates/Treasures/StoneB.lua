function StoneB:OnCreateEntity()
    self:DropOut()    
end
--============================================================================
function StoneB:OnTake(player)	
    self.Client_OnTake(player.ClientID,player._Entity,self._Entity,"StoneB")
end
--============================================================================
