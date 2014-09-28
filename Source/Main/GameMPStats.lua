--============================================================================
function Game:UpdateSpecs()
    if Game:IsServer() then  
             
    	for i,o in Game.PlayerStats do
    		if(Game.PlayerStats[o.ClientID].Version) then --Game.PlayerStats[o.ClientID].Version~=nil and  and 
	    		if(o.Spectator == 1)then
				for id,ps in Game.PlayerStats do 
					if(ps and ps.Player~=nil and ps.Spectator == 0) then
						local ammo1 = 0
						local ammo2 = 0
						local currentweaponindex = tonumber(ps.Player._CurWeaponIndex)
						local armortype = tonumber(ps.Player.ArmorType)
				          if(currentweaponindex==1)then
				        		ammo1 = 0
				        		ammo2 = 0
				        	end
				        	if(currentweaponindex==2 and ps.Player.Ammo.Shotgun~=nil and ps.Player.Ammo.IceBullets~=nil ) then   	
				        		ammo1 = tonumber(ps.Player.Ammo.Shotgun)
				        		ammo2 = tonumber(ps.Player.Ammo.IceBullets)
				        	end
				        	if(currentweaponindex==3) and ps.Player.Ammo.Stakes~=nil and ps.Player.Ammo.Grenades~=nil then
				        		ammo1 = tonumber(ps.Player.Ammo.Stakes)
				        		ammo2 = tonumber(ps.Player.Ammo.Grenades)
				        	end
				        	if(currentweaponindex==4) and ps.Player.Ammo.Grenades~=nil and ps.Player.Ammo.MiniGun~=nil then
				        		ammo1 = tonumber(ps.Player.Ammo.Grenades)
				        		ammo2 = tonumber(ps.Player.Ammo.MiniGun)
				        	end
				        	if(currentweaponindex==5) and ps.Player.Ammo.Electro~=nil and ps.Player.Ammo.Shurikens~=nil then
				        		ammo1 = tonumber(ps.Player.Ammo.Electro)
				        		ammo2 = tonumber(ps.Player.Ammo.Shurikens)
				        	end

				        	if(ps.ClientID~=nil and ps.Player.Health~=nil and ps.Player.Armor~=nil and currentweaponindex~=nil and ammo1~=nil and ammo2~=nil)then
							local txt = "L33T,"..ps.ClientID..","..ps.Player.Health..","..ps.Player.Armor..","..currentweaponindex..","..ammo1..","..ammo2..","..armortype
							SendNetMethod(Game.ConsoleClientMessage, o.ClientID, true, true, ServerID,txt,0)
						end
					end
				end
	        	end
        	end
    	end
    end
    if Game:IsServer() then  
	for id,ps in Game.PlayerStats do 
		if(ps and ps.Player~=nil and ps.Spectator == 0) then
			local ammo1 = 0
			local ammo2 = 0
			local currentweapon = tonumber(ps.Player._CurWeaponIndex)
			local armortype = tonumber(ps.Player.ArmorType)
			if(currentweapon==1)then
				ammo1 = 0
				ammo2 = 0
			end
			if(currentweapon==2 and ps.Player.Ammo.Shotgun~=nil and ps.Player.Ammo.IceBullets~=nil) then
				ammo1 = tonumber(ps.Player.Ammo.Shotgun)
				ammo2 = tonumber(ps.Player.Ammo.IceBullets)
			end
			if(currentweapon==3) and ps.Player.Ammo.Stakes~=nil and ps.Player.Ammo.Grenades~=nil then
				ammo1 = tonumber(ps.Player.Ammo.Stakes)
				ammo2 = tonumber(ps.Player.Ammo.Grenades)
			end
			if(currentweapon==4) and ps.Player.Ammo.Grenades~=nil and ps.Player.Ammo.MiniGun~=nil then
				ammo1 = tonumber(ps.Player.Ammo.Grenades)
				ammo2 = tonumber(ps.Player.Ammo.MiniGun)
			end
			if(currentweapon==5) and ps.Player.Ammo.Electro~=nil and ps.Player.Ammo.Shurikens~=nil then
				ammo1 = tonumber(ps.Player.Ammo.Electro)
				ammo2 = tonumber(ps.Player.Ammo.Shurikens)
			end
			if(ps.ClientID~=nil and ps.Player.Health~=nil and ps.Player.Armor~=nil and currentweapon~=nil and ammo1~=nil and ammo2~=nil)then
				--local txt = "L33T,"..ps.ClientID..","..ps.Player.Health..","..ps.Player.Armor..","..Currentweapon..","..ammo1..","..ammo2..","..armortype
				Game.PlayerData[ps.ClientID] = {Health = ps.Player.Health, Armour = ps.Player.Armor, Weapon = currentweapon, Ammo1 = ammo1, Ammo2 = ammo2, ArmorType = armortype}
				--SendNetMethod(Game.ConsoleClientMessage, o.ClientID, true, true, ServerID,txt,0)
			end
		end
	    end
	end

end
--============================================================================
function Game:UpdateStats(clientid,statsid)
    	if Game:IsServer() then           
    		for i,o in Game.PlayerStats do
    			if(o.ClientID==clientid)then -- Game.PlayerStats[o.ClientID].Version~=nil and --Game.PlayerStats[o.ClientID].Version and 
	    			for ig,ps in Game.PlayerStats do
	    				if(Game.Stats[ps.ClientID]~=nil)then
			    			for id,attack_type in Game.Stats[ps.ClientID].PlayerWepStats do	
							if(ps.ClientID~=nil  and (ps.ClientID==statsid or statsid=="all"))then
								local txt = "ST4TZ,"..ps.ClientID..","..attack_type.attacktype..","..attack_type.hits..","..attack_type.shots..","..attack_type.damage
								SendNetMethod(Game.ConsoleClientMessage, o.ClientID, true, true, ServerID, txt,0)
							end
						end
					end
				end
			end
		end
	end
end
--============================================================================
function Game:ClearStats()
	Game.Stats = {}
end
--============================================================================
function Game:SetStats(clientid, attacktype, deltahit, deltashot, deltadamage)
	--MsgBox("Game:SetStats"..clientid.." "..attacktype.." "..deltahit.." "..deltashot.." "..deltadamage)
	if(clientid < 0)then return end
	if(attacktype==nil)then return end
	if(deltahit==nil)then deltahit = 0 end
	if(deltashot==nil)then deltashot = 0 end
	if(deltadamage==nil)then deltadamage = 0 end	
	if(Game.Stats[clientid]==nil)then Game.Stats[clientid]={PlayerWepStats = {}} end
	if(Game.Stats[clientid].PlayerWepStats[attacktype]==nil)then Game.Stats[clientid].PlayerWepStats[attacktype] = {} 
		Game.Stats[clientid].PlayerWepStats[attacktype].hits = 0
		Game.Stats[clientid].PlayerWepStats[attacktype].shots = 0
		Game.Stats[clientid].PlayerWepStats[attacktype].damage = 0
	end
	Game.Stats[clientid].PlayerWepStats[attacktype].attacktype = attacktype
	Game.Stats[clientid].PlayerWepStats[attacktype].hits = deltahit
	Game.Stats[clientid].PlayerWepStats[attacktype].shots = deltashot
	Game.Stats[clientid].PlayerWepStats[attacktype].damage = deltadamage
	if not Game:IsServer() then  	
		--MsgBox("Game:SetStats DONE".." "..clientid.." "..Game.Stats[clientid].PlayerWepStats[attacktype].hits.." "..Game.Stats[clientid].PlayerWepStats[attacktype].shots.." "..Game.Stats[clientid].PlayerWepStats[attacktype].damage)
	end
end
--============================================================================
function Game:AddToStats(clientid, attacktype, deltahit, deltashot, deltadamage)
	if(not clientid or clientid==nil or clientid < 0)then return end
	if(attacktype==nil)then return end
	if(deltahit==nil)then deltahit = 0 end
	if(deltashot==nil)then deltashot = 0 end
	if(deltadamage==nil)then deltadamage = 0 end
	if(Game.Stats[clientid]==nil)then Game.Stats[clientid]={PlayerWepStats = {}} end
	if(Game.Stats[clientid].PlayerWepStats[attacktype]==nil)then Game.Stats[clientid].PlayerWepStats[attacktype] = {} 
		Game.Stats[clientid].PlayerWepStats[attacktype].hits = 0
		Game.Stats[clientid].PlayerWepStats[attacktype].shots = 0
		Game.Stats[clientid].PlayerWepStats[attacktype].damage = 0
	end
	Game.Stats[clientid].PlayerWepStats[attacktype].attacktype = attacktype
	Game.Stats[clientid].PlayerWepStats[attacktype].hits = Game.Stats[clientid].PlayerWepStats[attacktype].hits + deltahit
	Game.Stats[clientid].PlayerWepStats[attacktype].shots = Game.Stats[clientid].PlayerWepStats[attacktype].shots + deltashot
	Game.Stats[clientid].PlayerWepStats[attacktype].damage = Game.Stats[clientid].PlayerWepStats[attacktype].damage + deltadamage	
	--MsgBox(Game.Stats[clientid].PlayerWepStats[attacktype].hits.." "..Game.Stats[clientid].PlayerWepStats[attacktype].shots.." "..Game.Stats[clientid].PlayerWepStats[attacktype].damage)
end
--============================================================================