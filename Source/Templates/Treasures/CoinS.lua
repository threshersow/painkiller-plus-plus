--============================================================================
function CoinS:OnTake(player)	
    self.Client_OnTake(player.ClientID,player._Entity,self._Entity,"CoinS")
end
--============================================================================
