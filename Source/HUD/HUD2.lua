--=====================================================================================
function Hud:DrawFPS()
local w,h = R3D.ScreenSize()
--==SHOWFPS
     if Cfg.FPS or (Cfg.ShowFPS and Game.GMode ~= GModes.SingleGame) then --CONFUSED which one is right? I think Cfg.ShowFPS?
        local fps = string.format("%d",R3D.GetFPS())
        if Cfg.ShowFPSShadow then HUD.PrintXY(900*w/1024+Cfg.ShowFPSShadowLevel,10*h/768+Cfg.ShowFPSShadowLevel,fps,"Impact",0,0,0,26) end
        if Cfg.ShowFPSShadow then HUD.PrintXY((900+50)*w/1024+2,10*h/768+2,"fps","Impact",0,0,0,26) end 
        HUD.PrintXY(900*w/1024,10*h/768,fps,"Impact",255,255,255,26)
        HUD.PrintXY((900+50)*w/1024,10*h/768,"fps","Impact",255,255,255,26)
     end
     if(Player)then
	      if (Cfg.ShowPing and Game.GMode ~= GModes.SingleGame) then --CONFUSED which one is right? I think Cfg.ShowFPS?
	        local ping = string.format("ping: %d",tonumber(Game.PlayerStats[Player.ClientID].Ping))
	        --if Cfg.ShowPingShadow then HUD.PrintXY((Cfg.ShowPingX)*w+Cfg.ShowPingShadowLevel,Cfg.ShowPingY*h+Cfg.ShowPingShadowLevel,"ping","Impact",0,0,0,26) end
	        if Cfg.ShowPingShadow then HUD.PrintXY(Cfg.ShowPingX*w+2,Cfg.ShowPingY*h+2,tostring(ping),"Impact",0,0,0,26) end
	        --HUD.PrintXY((Cfg.ShowPingX)*w,Cfg.ShowPingY*h,"ping","Impact",255,255,255,26)
	        HUD.PrintXY(Cfg.ShowPingX*w,Cfg.ShowPingY*h,tostring(ping),"Impact",255,255,255,26)
	     end
     end
--==
end
--=====================================================================================
function Hud:DrawTimer()
	local w,h = R3D.ScreenSize()
--==TIMER
	if Game and Game.GMode ~= GModes.SingleGame and (self._showtimer or Cfg.ShowTimer) and Game._TimeLimitOut and MPCfg.GameState ~= GameStates.Finished then -- and (MPCfg.GameState ~= GameStates.Finished)
		local tm = (MPCfg.TimeLimit*60 - Game._TimeLimitOut) / 60
		if Cfg.ShowTimerCountUp == true then
			tm = (Game._TimeLimitOut) / 60
		end
		local m = math.floor(tm)
		local s = math.floor((tm - m) * 60)
		local red = false
		if(m <= 0.0) and Cfg.ShowTimerCountUp == false then
			red = true
		else if (m >= MPCfg.TimeLimit - 1) and Cfg.ShowTimerCountUp then
			red = true
		end
		end
		if(Cfg.ShowTimerFontSize == nil)then Cfg.ShowTimerFontSize = 45 end
		local timerfontsize = Cfg.ShowTimerFontSize
		local time = string.format(m..":"..string.format("%02d",s))
			if (Cfg.ShowTimer) and Game.GMode ~= GModes.SingleGame then
				if red then
					if Cfg.ShowTimerShadow then HUD.PrintXY(Cfg.ShowTimerX*w+Cfg.ShowTimerShadowLevel,Cfg.ShowTimerY*h+Cfg.ShowTimerShadowLevel,time,"Impact",0,0,0,timerfontsize) end
					HUD.PrintXY(Cfg.ShowTimerX*w,Cfg.ShowTimerY*h,time,"Impact",230,0,0,timerfontsize)
				else
					if Cfg.ShowTimerShadow then HUD.PrintXY(Cfg.ShowTimerX*w+2,Cfg.ShowTimerY*h+2,time,"Impact",0,0,0,timerfontsize) end
					HUD.PrintXY(Cfg.ShowTimerX*w,Cfg.ShowTimerY*h,time,"Impact",255,255,255,timerfontsize)
				end
			end
	  	end
end
--============================================================================
function Hud:AmmoList()
    local w,h = R3D.ScreenSize()

	local font ="Impact"
	local armor = Player.Armor
	local sgammo = Player.Ammo.Shotgun
	local iceammo = Player.Ammo.IceBullets
	local stakeammo = Player.Ammo.Stakes
	local grenadeammo = Player.Ammo.Grenades
	local cgammo = Player.Ammo.MiniGun
	local shurikenammo = Player.Ammo.Shurikens
	local lgammo = Player.Ammo.Electro
	
	if Player.EnabledWeapons[2]~=nil or not Cfg.AmmolistHideWeapons then Hud:QuadTrans(Hud._matShell,AmmoList_Icons_Pos1_X,AmmoList_Pos1_Y,1*1,false,255) end
	if Player.EnabledWeapons[2]~=nil or not Cfg.AmmolistHideWeapons then Hud:QuadTrans(Hud._matFreezer,AmmoList_Icons_Pos2_X,AmmoList_Pos2_Y,1*1,false,255) end
	if Player.EnabledWeapons[3]~=nil or not Cfg.AmmolistHideWeapons then Hud:QuadTrans(Hud._matStake,AmmoList_Icons_Pos3_X,AmmoList_Pos3_Y,1*1,false,255) end
	if Player.EnabledWeapons[3]~=nil or Player.EnabledWeapons[4]~=nil or not Cfg.AmmolistHideWeapons then Hud:QuadTrans(Hud._matRocket,AmmoList_Icons_Pos4_X,AmmoList_Pos4_Y,1*1,false,255) end
	if Player.EnabledWeapons[4]~=nil or not Cfg.AmmolistHideWeapons then Hud:QuadTrans(Hud._matMinigun,AmmoList_Icons_Pos5_X,AmmoList_Pos5_Y,1*1,false,255) end
	if Player.EnabledWeapons[5]~=nil or not Cfg.AmmolistHideWeapons then Hud:QuadTrans(Hud._matSzuriken,AmmoList_Icons_Pos6_X,AmmoList_Pos6_Y,1*1,false,255) end
	if Player.EnabledWeapons[5]~=nil or not Cfg.AmmolistHideWeapons then Hud:QuadTrans(Hud._matElectro,AmmoList_Icons_Pos7_X,AmmoList_Pos7_Y,1*1,false,255) end

	if not Cfg.AmmolistHideWeapons then Hud:Erasures() end
	
        Hud:CurrentWeaponBG()

	if Cfg.Simplehud == false then
	        if Player.EnabledWeapons[2]~=nil or not Cfg.AmmolistHideWeapons then Hud:DrawDigitsText(AmmoList_Text_Pos1_X+(10*w/1024),AmmoList_Pos1_Y+(4*h/768),string.format("%3d",Player.Ammo.Shotgun),0.8*1,Player.s_SubClass.AmmoWarning.Shotgun) end
	        if Player.EnabledWeapons[2]~=nil or not Cfg.AmmolistHideWeapons then Hud:DrawDigitsText(AmmoList_Text_Pos2_X+(10*w/1024),AmmoList_Pos2_Y+(4*h/768),string.format("%3d",Player.Ammo.IceBullets),0.8*1,Player.s_SubClass.AmmoWarning.IceBullets) end
	        if Player.EnabledWeapons[3]~=nil or not Cfg.AmmolistHideWeapons then Hud:DrawDigitsText(AmmoList_Text_Pos3_X+(10*w/1024),AmmoList_Pos3_Y+(4*h/768),string.format("%3d",Player.Ammo.Stakes),0.8*1,Player.s_SubClass.AmmoWarning.Stakes) end
	        if Player.EnabledWeapons[3]~=nil or Player.EnabledWeapons[4]~=nil or not Cfg.AmmolistHideWeapons then Hud:DrawDigitsText(AmmoList_Text_Pos4_X+(10*w/1024),AmmoList_Pos4_Y+(4*h/768),string.format("%3d",Player.Ammo.Grenades),0.8*1,Player.s_SubClass.AmmoWarning.Grenades) end
	        if Player.EnabledWeapons[4]~=nil or not Cfg.AmmolistHideWeapons then Hud:DrawDigitsText(AmmoList_Text_Pos5_X+(10*w/1024),AmmoList_Pos5_Y+(4*h/768),string.format("%3d",Player.Ammo.MiniGun),0.8*1,Player.s_SubClass.AmmoWarning.MiniGun) end
	        if Player.EnabledWeapons[5]~=nil or not Cfg.AmmolistHideWeapons then Hud:DrawDigitsText(AmmoList_Text_Pos6_X+(10*w/1024),AmmoList_Pos6_Y+(4*h/768),string.format("%3d",Player.Ammo.Shurikens),0.8*1,Player.s_SubClass.AmmoWarning.Shurikens) end
	        if Player.EnabledWeapons[5]~=nil or not Cfg.AmmolistHideWeapons then Hud:DrawDigitsText(AmmoList_Text_Pos7_X+(10*w/1024),AmmoList_Pos7_Y+(4*h/768),string.format("%3d",Player.Ammo.Electro),0.8*1,Player.s_SubClass.AmmoWarning.Electro) end
	else
		if Player.EnabledWeapons[2]~=nil or not Cfg.AmmolistHideWeapons then HUD.PrintXY(AmmoList_Text_Pos1_X+(10*w/1024),AmmoList_Pos1_Y+(4*h/768),string.format("%3d",Player.Ammo.Shotgun),font,255,255,255,30) end
		if Player.EnabledWeapons[2]~=nil or not Cfg.AmmolistHideWeapons then HUD.PrintXY(AmmoList_Text_Pos2_X+(10*w/1024),AmmoList_Pos2_Y+(4*h/768),string.format("%3d",Player.Ammo.IceBullets),font,255,255,255,30) end
		if Player.EnabledWeapons[3]~=nil or not Cfg.AmmolistHideWeapons then HUD.PrintXY(AmmoList_Text_Pos3_X+(10*w/1024),AmmoList_Pos3_Y+(4*h/768),string.format("%3d",Player.Ammo.Stakes),font,255,255,255,30) end
		if Player.EnabledWeapons[3]~=nil or Player.EnabledWeapons[4]~=nil or not Cfg.AmmolistHideWeapons then HUD.PrintXY(AmmoList_Text_Pos4_X+(10*w/1024),AmmoList_Pos4_Y+(4*h/768),string.format("%3d",Player.Ammo.Grenades),font,255,255,255,30) end
		if Player.EnabledWeapons[4]~=nil or not Cfg.AmmolistHideWeapons then HUD.PrintXY(AmmoList_Text_Pos5_X+(10*w/1024),AmmoList_Pos5_Y+(4*h/768),string.format("%3d",Player.Ammo.MiniGun),font,255,255,255,30) end
		if Player.EnabledWeapons[5]~=nil or not Cfg.AmmolistHideWeapons then HUD.PrintXY(AmmoList_Text_Pos6_X+(10*w/1024),AmmoList_Pos6_Y+(4*h/768),string.format("%3d",Player.Ammo.Shurikens),font,255,255,255,30) end
		if Player.EnabledWeapons[5]~=nil or not Cfg.AmmolistHideWeapons then HUD.PrintXY(AmmoList_Text_Pos7_X+(10*w/1024),AmmoList_Pos7_Y+(4*h/768),string.format("%3d",Player.Ammo.Electro),font,255,255,255,30) end
	end


end
--=====================================================================================
function Hud:AmmoListPos1()
    local w,h = R3D.ScreenSize()

    local icons_pos_x = (5+0)*w/1024

    AmmoList_Icons_Pos1_X       = icons_pos_x
    AmmoList_Icons_Pos2_X       = icons_pos_x
    AmmoList_Icons_Pos3_X       = icons_pos_x
    AmmoList_Icons_Pos4_X       = icons_pos_x
    AmmoList_Icons_Pos5_X       = icons_pos_x
    AmmoList_Icons_Pos6_X       = icons_pos_x
    AmmoList_Icons_Pos7_X       = icons_pos_x

    local text_pos_x = (((45)*1)+0)*w/1024

    AmmoList_Text_Pos1_X        = text_pos_x
    AmmoList_Text_Pos2_X        = text_pos_x
    AmmoList_Text_Pos3_X        = text_pos_x
    AmmoList_Text_Pos4_X        = text_pos_x
    AmmoList_Text_Pos5_X        = text_pos_x
    AmmoList_Text_Pos6_X        = text_pos_x
    AmmoList_Text_Pos7_X        = text_pos_x


    AmmoList_Pos1_Y             = (200+((0)*1))*h/768
    AmmoList_Pos2_Y             = (200+((37)*1))*h/768
    AmmoList_Pos3_Y             = (200+((74)*1))*h/768
    AmmoList_Pos4_Y             = (200+((111)*1))*h/768
    AmmoList_Pos5_Y             = (200+((148)*1))*h/768
    AmmoList_Pos6_Y             = (200+((185)*1))*h/768
    AmmoList_Pos7_Y             = (200+((222)*1))*h/768

end
--=====================================================================================
function Hud:AmmoListPos2()
    local w,h = R3D.ScreenSize()

    local icons_pos_x = w-(((75*1)-32+0)*w/1024)

    AmmoList_Icons_Pos1_X       = icons_pos_x
    AmmoList_Icons_Pos2_X       = icons_pos_x
    AmmoList_Icons_Pos3_X       = icons_pos_x
    AmmoList_Icons_Pos4_X       = icons_pos_x
    AmmoList_Icons_Pos5_X       = icons_pos_x
    AmmoList_Icons_Pos6_X       = icons_pos_x
    AmmoList_Icons_Pos7_X       = icons_pos_x


    local text_pos_x = w-(((165*1)-50+0)*w/1024)

    AmmoList_Text_Pos1_X        = text_pos_x
    AmmoList_Text_Pos2_X        = text_pos_x
    AmmoList_Text_Pos3_X        = text_pos_x
    AmmoList_Text_Pos4_X        = text_pos_x
    AmmoList_Text_Pos5_X        = text_pos_x
    AmmoList_Text_Pos6_X        = text_pos_x
    AmmoList_Text_Pos7_X        = text_pos_x


    AmmoList_Pos1_Y             = (200+((0)*1))*h/768
    AmmoList_Pos2_Y             = (200+((37)*1))*h/768
    AmmoList_Pos3_Y             = (200+((74)*1))*h/768
    AmmoList_Pos4_Y             = (200+((111)*1))*h/768
    AmmoList_Pos5_Y             = (200+((148)*1))*h/768
    AmmoList_Pos6_Y             = (200+((185)*1))*h/768
    AmmoList_Pos7_Y             = (200+((222)*1))*h/768

end
--=====================================================================================
function Hud:Erasures()
    if Player.EnabledWeapons[2] == Shotgun then
        Hud:QuadTrans(Hud._matout,AmmoList_Icons_Pos1_X,AmmoList_Pos1_Y,1*1,false,255)
        Hud:QuadTrans(Hud._matout,AmmoList_Icons_Pos2_X,AmmoList_Pos2_Y,1*1,false,255)
    end

    if Player.EnabledWeapons[3] == StakeGunGL then
        Hud:QuadTrans(Hud._matout,AmmoList_Icons_Pos3_X,AmmoList_Pos3_Y,1*1,false,255)
    end

    if Player.EnabledWeapons[3] == StakeGunGL or Player.EnabledWeapons[4] == MiniGunRL then
        Hud:QuadTrans(Hud._matout,AmmoList_Icons_Pos4_X,AmmoList_Pos4_Y,1*1,false,255)
    end

    if Player.EnabledWeapons[4] == MiniGunRL then
        Hud:QuadTrans(Hud._matout,AmmoList_Icons_Pos5_X,AmmoList_Pos5_Y,1*1,false,255)
    end

    if Player.EnabledWeapons[5] == DriverElectro then
        Hud:QuadTrans(Hud._matout,AmmoList_Icons_Pos6_X,AmmoList_Pos6_Y,1*1,false,255)
        Hud:QuadTrans(Hud._matout,AmmoList_Icons_Pos7_X,AmmoList_Pos7_Y,1*1,false,255)
    end

end

--=====================================================================================
function Hud:CurrentWeaponIcon()
    local w,h = R3D.ScreenSize()

    if Player._CurWeaponIndex == 1 then
        Hud:QuadTrans(Hud._matPainkiller,(496)*w/1024,(710)*h/768,1,false,255)
    elseif Player._CurWeaponIndex == 2 then
        Hud:QuadTrans(Hud._matShell,(496)*w/1024,(710)*h/768,1,false,255)
    elseif Player._CurWeaponIndex == 3 then
        Hud:QuadTrans(Hud._matStake,(496)*w/1024,(710)*h/768,1,false,255)
    elseif Player._CurWeaponIndex == 4 then
        Hud:QuadTrans(Hud._matRocket,(496)*w/1024,(710)*h/768,1,false,255)
    elseif Player._CurWeaponIndex == 5 then
        Hud:QuadTrans(Hud._matElectro,(496)*w/1024,(710)*h/768,1,false,255)
    end
end
--=====================================================================================
function Hud:CurrentWeaponBG()
    local w,h = R3D.ScreenSize()
	local wep1 = { w = 0.07, d = 0.049}
	local wep2 = { w = 0.07, d = 0.049}
	local wep3 = { w = 0.045, d = 0.049}
	local wep4 = { w = 0.045, d = 0.049}

	if Player._CurWeaponIndex == 1 then
    elseif Player._CurWeaponIndex == 2 then
        HUD.DrawQuadRGBA(Hud._matBluePix,AmmoList_Text_Pos1_X,AmmoList_Pos1_Y,w*wep1.w,h*wep1.d)
        HUD.DrawQuadRGBA(Hud._matBluePix,AmmoList_Text_Pos2_X,AmmoList_Pos2_Y,w*wep2.w,h*wep2.d)
    elseif Player._CurWeaponIndex == 3 then
        HUD.DrawQuadRGBA(Hud._matBluePix,AmmoList_Text_Pos3_X,AmmoList_Pos3_Y,w*wep1.w,h*wep1.d)
        --HUD.DrawQuadRGBA(Hud._matBluePix,AmmoList_Text_Pos4_X,AmmoList_Pos4_Y,w*wep2.w,h*wep2.d)
    elseif Player._CurWeaponIndex == 4 then
        HUD.DrawQuadRGBA(Hud._matBluePix,AmmoList_Text_Pos4_X,AmmoList_Pos4_Y,w*wep1.w,h*wep1.d)
        HUD.DrawQuadRGBA(Hud._matBluePix,AmmoList_Text_Pos5_X,AmmoList_Pos5_Y,w*wep2.w,h*wep2.d)
    elseif Player._CurWeaponIndex == 5 then
        HUD.DrawQuadRGBA(Hud._matBluePix,AmmoList_Text_Pos6_X,AmmoList_Pos6_Y,w*wep1.w,h*wep1.d)
        HUD.DrawQuadRGBA(Hud._matBluePix,AmmoList_Text_Pos7_X,AmmoList_Pos7_Y,w*wep2.w,h*wep2.d)
	end
	end
--=====================================================================================
function Hud:FragMessage(fname)
    local w,h = R3D.ScreenSize()
    local font ="Impact"
    HUD.PrintXY(-1,400*h/768+2,"You killed: "..HUD.StripColorInfo(fname).."!",font,0,0,0,22)
    HUD.PrintXY(-1,400*h/768,"You killed: "..fname.."!",font,255,255,255,22)
end
--=====================================================================================
function Hud_OnConsoleTab(cmd)
	Hud:OnConsoleTab(cmd)
end
--============================================================================
function Hud:Simplehud()
	local w,h = R3D.ScreenSize()
	local font ="Impact"
	local armor = math.floor(Player.Armor)
	local sgammo = Player.Ammo.Shotgun
	local iceammo = Player.Ammo.IceBullets
	local stakeammo = Player.Ammo.Stakes
	local grenadeammo = Player.Ammo.Grenades
	local cgammo = Player.Ammo.MiniGun
	local shurikenammo = Player.Ammo.Shurikens
	local lgammo = Player.Ammo.Electro

        local he = math.floor(Player.Health)
        if he < 1 and he > 0 then
            he = 1
        end
--==ARMOR
     	if Player and Player.FrozenArmor then 
	armor = 0
	end

        if Player.ArmorType == 0 then
	Hud:QuadTrans(Hud._matArmorNormal,(007)*w/1024,(722)*h/768,1,false,255)		
            if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),722*h/768,armor,font,0,0,0,50) end
            HUD.PrintXY((052*w/1024),720*h/768,armor,font,255,0,0,50)
	end

        if Player.ArmorType == 1 then
	Hud:QuadTrans(Hud._matArmorGreen,(007)*w/1024,(722)*h/768,1,false,255)
	if armor > 50 then
            if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),722*h/768,armor,font,0,0,0,50) end
            HUD.PrintXY((052*w/1024),720*h/768,armor,font,100,70,20,50)
		else
	
            if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),722*h/768,armor,font,0,0,0,50) end
            HUD.PrintXY((052*w/1024),720*h/768,armor,font,255,0,0,50)
	end
	end

        if Player.ArmorType == 2 then
	Hud:QuadTrans(Hud._matArmorYellow,(007)*w/1024,(722)*h/768,1,false,255)
	if armor > 50 then
            if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),722*h/768,armor,font,0,0,0,50) end
            HUD.PrintXY((052*w/1024),720*h/768,armor,font,190,210,250,50)
		else

            if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),722*h/768,armor,font,0,0,0,50) end
            HUD.PrintXY((052*w/1024),720*h/768,armor,font,255,0,0,50)
	end
	end
 
       if Player.ArmorType == 3 then
	Hud:QuadTrans(Hud._matArmorRed,(007)*w/1024,(722)*h/768,1,false,255)
	if armor > 50 then	
            if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),722*h/768,armor,font,0,0,0,50) end
            HUD.PrintXY((052*w/1024),720*h/768,armor,font,230,200,0,50)
		else
	
            if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),722*h/768,armor,font,0,0,0,50) end
            HUD.PrintXY((052*w/1024),720*h/768,armor,font,255,0,0,50)
	end
        end

--==HEALTH	
	Hud:QuadTrans(Hud._matHealth,(007)*w/1024,(670)*h/768,1,false,255)
	if he < 25 then
	if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),672*h/768,he,font,0,0,0,50) end
	HUD.PrintXY((052*w/1024),670*h/768,he,font,255,0,0,50)
	elseif he > 100 then 
	if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),672*h/768,he,font,0,0,0,50) end
	HUD.PrintXY((052*w/1024),670*h/768,he,font,25,200,60,50)
	else
	if Cfg.SimplehudShadow then HUD.PrintXY((054*w/1024),672*h/768,he,font,0,0,0,50) end
	HUD.PrintXY((052*w/1024),670*h/768,he,font,255,255,255,50)
	end

--==AMMO

  --==============================================================
  -- Blowfish's switch weapon fix
  --==============================================================

  local ammo1y = 720
	local ammo1ys = 722
	local ammo2y = 670
	local ammo2ys = 672 
  --if (INP.IsFireSwitched() or (Player._CurWeaponIndex and not Game.SwitchFire[Player._CurWeaponIndex])) then
	if not (INP.IsFireSwitched() or (Player._CurWeaponIndex and not Game.SwitchFire[Player._CurWeaponIndex] and Cfg.SwitchFire[Player._CurWeaponIndex]) or (Player._CurWeaponIndex and not Cfg.SwitchFire[Player._CurWeaponIndex] and Game.SwitchFire[Player._CurWeaponIndex])) then
		ammo1y = 670
		ammo1ys = 672
		ammo2y = 720
		ammo2ys = 722
  end

	if Player._CurWeaponIndex == 1 then   
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo1ys*h/768,"XXX",font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo1y*h/768,"XXX",font,255,255,255,50)
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo2ys*h/768,"XXX",font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo2y*h/768,"XXX",font,255,255,255,50)
		end	

    	if Player._CurWeaponIndex == 2 then
	Hud:QuadTrans(Hud._matShell,(870)*w/1024,(ammo1y)*h/768,1,false,255)
	Hud:QuadTrans(Hud._matFreezer,(870)*w/1024,(ammo2y)*h/768,1,false,255)
	
	if sgammo < 5 then 
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo1ys*h/768,sgammo,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo1y*h/768,sgammo,font,255,0,0,50)
	 	 if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo2ys*h/768,iceammo,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo2y*h/768,iceammo,font,255,255,255,50)
	else
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo1ys*h/768,sgammo,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo1y*h/768,sgammo,font,255,255,255,50)
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo2ys*h/768,iceammo,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo2y*h/768,iceammo,font,255,255,255,50)
		end
		end

	if Player._CurWeaponIndex == 3 then
	Hud:QuadTrans(Hud._matStake,(870)*w/1024,(ammo1y)*h/768,1,false,255)
	if stakeammo <= 5 then 
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo1ys*h/768,stakeammo,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo1y*h/768,stakeammo,font,255,0,0,50)
	else
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo1ys*h/768,stakeammo,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo1y*h/768,stakeammo,font,255,255,255,50)
		end
		end
	if Player._CurWeaponIndex == 3 then
	Hud:QuadTrans(Hud._matRocket,(870)*w/1024,(ammo2y)*h/768,1,false,255)
	if grenadeammo <= 5 then
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo2ys*h/768,grenadeammo,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo2y*h/768,grenadeammo,font,255,0,0,50)
	else
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo2ys*h/768,grenadeammo,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo2y*h/768,grenadeammo,font,255,255,255,50)
		end
		end


	if Player._CurWeaponIndex == 4 then
	Hud:QuadTrans(Hud._matRocket,(870)*w/1024,(ammo1y)*h/768,1,false,255)
	if grenadeammo <= 5 then
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo1ys*h/768,grenadeammo,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo1y*h/768,grenadeammo,font,255,0,0,50)
	else
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo1ys*h/768,grenadeammo,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo1y*h/768,grenadeammo,font,255,255,255,50)
		end
		end
	if Player._CurWeaponIndex == 4 then
	Hud:QuadTrans(Hud._matMinigun,(870)*w/1024,(ammo2y)*h/768,1,false,255)
	if cgammo <= 20 then
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo2ys*h/768,cgammo,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo2y*h/768,cgammo,font,255,0,0,50)
	else
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo2ys*h/768,cgammo,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo2y*h/768,cgammo,font,255,255,255,50)
		end
		end

	if Player._CurWeaponIndex == 5 then
	Hud:QuadTrans(Hud._matElectro,(870)*w/1024,(ammo1y)*h/768,1,false,255)
	if lgammo <= 15 then 
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo1ys*h/768,lgammo,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo1y*h/768,lgammo,font,255,0,0,50)
	else
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo1ys*h/768,lgammo,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo1y*h/768,lgammo,font,255,255,255,50)
		end
		end

	if Player._CurWeaponIndex == 5 then
	Hud:QuadTrans(Hud._matSzuriken,(870)*w/1024,(ammo2y)*h/768,1,false,255)
	if shurikenammo <= 7 then 
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo2ys*h/768,shurikenammo,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo2y*h/768,shurikenammo,font,255,0,0,50)
	else
	   if Cfg.SimplehudShadow then HUD.PrintXY((922*w/1024),ammo2ys*h/768,shurikenammo,font,0,0,0,50) end
	   HUD.PrintXY((920*w/1024),ammo2y*h/768,shurikenammo,font,255,255,255,50)
		end
		end


end
--==============================================================================
function Hud:DrawPlayerVsPlayer()
	if MPCfg.GameState == GameStates.WarmUp or MPCfg.GameState == GameStates.Counting then
		local w,h = R3D.ScreenSize()	
		--HUD.PrintXY(11*w/1024+1.1,71*h/768+1.1,"Warm Up","Impact",160,160,160,28)
		if MPCfg.GameMode == "Duel" then	
			local p1name
		    	local p2name
		    	for i,o in Game.PlayerStats do
		       		if o.Spectator == 0 then
		       			if not p1name then
		       				p1name = o.Name
		       			else
			       			p2name = o.Name
		       			end
		    		end
		    	end	
		    	if not p1name then p1name = "" end
		    	if not p2name then p2name = "" end
		    	if(p1name~="" and p2name~="")then
		    			HUD.PrintXY(-1,200*h/768+2,""..p1name.."  -versus-  "..p2name.."","Impact",0,0,0,32)
		        	HUD.PrintXY(-1,200*h/768,""..p1name.."  -versus-  "..p2name.."","Impact",255,255,255,32)
			end
	    	end
	end
end
--==============================================================================