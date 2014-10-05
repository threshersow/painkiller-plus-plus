--============================================================================
function CoinG:OnCreateEntity()
    self:DropOut()    
end
--============================================================================
function CoinG:OnTake(player)	
    self.Client_OnTake(player.ClientID,player._Entity,self._Entity,"CoinG")
end
--============================================================================
