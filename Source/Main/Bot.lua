
BotStates = {
	SearchingForWaypoint = 0,
	HeadingToWaypoint = 1,
	AttackingEnemy = 2,
	FollowingFriend = 3,
	ChangingWeapon = 4,
	Idle = 5,
	Talking = 6,
	Dancing = 7,
	AttackingAdvance = 8,
	AttackingRetreat = 9,
	AttackingStrafeLeft = 10,
	AttackingStrafeRight = 11,
	Typing = 12
}

function Game:BotTick(delta)
	for j,pks in Game.PlayerStats do
		if pks and pks.Bot and pks._Entity ~= nil then
			local botclientid = pks.ClientID  --
			if(Game.PlayerStats[botclientid]~=nil)then		               
				local botx,boty,botz = self:GetClientPosition(botclientid)
				NET.ClientPingReset(botclientid) 
				-- STATE TIMEOUT
				
				if(self.bot[botclientid].statetime < INP.GetTime())then
					-- STUCK OR BORED
					if(self.bot[botclientid].state == BotStates.Typing)then
						self.bot[botclientid].state = BotStates.Talking
					elseif(self.bot[botclientid].state == BotStates.AttackingEnemy)then
						self.bot[botclientid].state = BotStates.ChangingWeapon
						self.bot[botclientid].statetime = INP.GetTime() + 1
					else
						self:BotResetWaypoints(botclientid)
					end
				end
					

					
					-- WAYPOINT CODE
					
					if(self.bot[botclientid].state == BotStates.SearchingForWaypoint)then
						-- LOST, LOOKING FOR SOMEWHERE
						local currentwp = self:GetCurrentWaypoint(botclientid)
						local testx,testy,testz,tid,success = self:GetNextWaypoint(botclientid,currentwp)
						if(success)then
							self.bot[botclientid].statetime = INP.GetTime() + 3 -- WAS 2
							self.bot[botclientid].state = BotStates.HeadingToWaypoint
							self.bot[botclientid].mex,self.bot[botclientid].mey,self.bot[botclientid].mez,tid,blah = self:GetNextWaypoint(botclientid,currentwp)
							--MsgBox("new target found, I am at.."..currentwp.." next target is "..tid.." last next target is "..self.bot[botclientid].TargetID[1].." previous target was "..self.bot[botclientid].TargetID[2])
							for i=1,32 do
								self.bot[botclientid].TargetID[33-i] = self.bot[botclientid].TargetID[32-i]
							end
							self.bot[botclientid].TargetID[1] = tid
						else	
							if(Cfg.BotChat and math.floor(math.random(5000))==1 or Cfg.BotChat and Cfg.BotEliza and Game.PlayerStats[botclientid].LastThingHeard~=nil)then 
								self.bot[botclientid].state = BotStates.Typing
								self.bot[botclientid].statetime = INP.GetTime() + 2

							else
								self.bot[botclientid].angle = self.bot[botclientid].angle + 0.001 * self.bot[botclientid].rotation -- DOESNT MATTER
								self.bot[botclientid].state = BotStates.SearchingForWaypoint
								--self.bot[botclientid].statetime = INP.GetTime() + 3
							end
						end		
					elseif(self.bot[botclientid].state == BotStates.HeadingToWaypoint)then
						-- HEADING SOMEWHERE
						local angle = math.atan2(botx-self.bot[botclientid].mex,botz-self.bot[botclientid].mez)
						-- STOP MEGA SPIN
						--if((self.bot[botclientid].angle - angle)<0  )then angle = angle + math.pi*2.0 end
						--if((self.bot[botclientid].angle - angle)> math.pi*2.0)then angle = angle - math.pi*2.0 end
						
						self.bot[botclientid].angle = self.bot[botclientid].angle - (self.bot[botclientid].angle - angle) * 0.2 + (math.pi/200)*math.sin(INP.GetTime()) -- WAS 0.2
						self.bot[botclientid].rotation = 1
						if(math.random(2) > 1)then self.bot[botclientid].rotation = -1 end
						local ignore = false
						if (math.random(2) < 1) then ignore = true end
						if(Cfg.BotChat and math.floor(math.random(5000))==1 or Cfg.BotChat and Cfg.BotEliza and Game.PlayerStats[botclientid].LastThingHeard~=nil and not ignore)then 
								self.bot[botclientid].state = BotStates.Typing
								self.bot[botclientid].statetime = INP.GetTime() + 2	
						-- ITEM HANDLING	
						elseif(self:GetCurrentWaypoint(botclientid) == self.bot[botclientid].TargetID[1])then
						local isuc = false
							if(Cfg.BotFindItems and math.floor(math.random(10))>2)then
							        local ix = 0
							        local iy = 0
							        local iz = 0
								ix,iy,iz,isuc = Game:GetNearestItem(botclientid)
								if isuc	then
									--MsgBox("found item")
									--RawCallMethod(Game.ConsoleClientMessage,botclientid,"Heading for an item",0) 
									mex,mey,mez = Game:GetNearestItem(botclientid)
									self.bot[botclientid].state = BotStates.HeadingToWaypoint
									self.bot[botclientid].statetime = INP.GetTime() + 1.5 -- WAS 1
								end
							end
						-- ITEM HANDLING
							if(not isuc or not Cfg.BotFindItems)then
								-- REACHED TARGET
								--MsgBox("reach target .."..self:GetCurrentWaypoint(botclientid).." next target iss "..self.bot[botclientid].TargetID[1].." last target was "..self.bot[botclientid].TargetID[2].." last target was "..self.bot[botclientid].TargetID[3].." last target was "..self.bot[botclientid].TargetID[4].." last target was "..self.bot[botclientid].TargetID[5])
								Game.PlayerStats[botclientid].LastThingHeard = nil
								self.bot[botclientid].state = BotStates.SearchingForWaypoint
								self.bot[botclientid].statetime = INP.GetTime() + 0.5 -- WAS 0.1
							end
						end
						if ignore then Game.PlayerStats[botclientid].LastThingHeard = nil end
					end	
					
					
					
				-- ATTACK
				if(true and Cfg.BotAttack)then
					if(self.bot[botclientid].state ~= BotStates.ChangingWeapon)then
						if(self.bot[botclientid].state ~= BotStates.AttackingEnemy)then
							local testx,testy,testz,targetsuccess = self:GetAttackTarget(botclientid)
							if(targetsuccess)then
								self.bot[botclientid].state = BotStates.AttackingEnemy
								self.bot[botclientid].statetime = INP.GetTime() + 0.25 -- WAS 0.5
								self.bot[botclientid].mex,self.bot[botclientid].mey,self.bot[botclientid].mez = self:GetAttackTarget(botclientid)			
								local angle = math.atan2(botx-self.bot[botclientid].mex,botz-self.bot[botclientid].mez)
								self.bot[botclientid].angle = self.bot[botclientid].angle - (self.bot[botclientid].angle - angle) * 0.6
							end
						else
							local testx,testy,testz,targetsuccess = self:GetAttackTarget(botclientid)
							if(targetsuccess)then
								self.bot[botclientid].state = BotStates.AttackingEnemy
								self.bot[botclientid].mex,self.bot[botclientid].mey,self.bot[botclientid].mez = self:GetAttackTarget(botclientid)			
								local angle = math.atan2(botx-self.bot[botclientid].mex,botz-self.bot[botclientid].mez)
								self.bot[botclientid].angle = self.bot[botclientid].angle - (self.bot[botclientid].angle - angle) * 0.6
							end	
						end
					end
				end
					
				for i,o in Game.Players do
					if o.ClientID == botclientid then 
						--for i,o in Game.Players do
							--if o.ClientID == botclientid then 
								--o:TryToSelectNextWeaponWithAmmo(o._CurWeaponIndex,1)
							--end
						--end				
						local yaw = self.bot[botclientid].angle 
						local arm = Dist2D(botx,botz,self.bot[botclientid].mex,self.bot[botclientid].mez) 
						local pitch = math.atan2(arm,boty-self.bot[botclientid].mey)-math.pi/2
						--if(arm<0)then pitch = math.atan2(-arm,boty-self.bot[botclientid].mey)+math.pi end
						--local tsuc = false						
						ENTITY.SetOrientation(Game.PlayerStats[botclientid]._Entity, self.bot[botclientid].angle + math.pi)
						
						-- STUBNOSE
						if(Cfg.BotCheckStubNose and self.bot[botclientid].state ~= BotStates.SearchingForWaypoint)then
							local Nose = Vector:New(0,0,0)
							Nose:Set(self.bot[botclientid].mex-botx,self.bot[botclientid].mey-boty,self.bot[botclientid].mez-botz)
							Nose:Normalize()
							--Nose.X = Nose.X * 0.5
							--Nose.Y = Nose.Y * 0.5
							--Nose.Z = Nose.Z * 0.5
							ENTITY.RemoveFromIntersectionSolver(self.bot[botclientid]._Entity)
							local b,d,wx,wy,wz = WORLD.LineTraceFixedGeom(botx,boty,botz,botx+Nose.X,boty+Nose.Y,botz+Nose.Z)
							ENTITY.AddToIntersectionSolver(self.bot[botclientid]._Entity)	
							if b then 
							--RawCallMethod(Game.ConsoleClientMessage,botclientid,"Ow My Nose",0) 
							self.bot[botclientid].state = BotStates.SearchingForWaypoint end
						end
						
						
						if(self.bot[botclientid].state == BotStates.HeadingToWaypoint or self.bot[botclientid].state == BotStates.AttackingEnemy and arm > 80 or self.bot[botclientid].state == BotStates.AttackingEnemy and self.bot[botclientid].weapon == 1)then 
						--local closerangeattack = false	
							if(o:IsOnGround())then
								local vx,vy,vz,l  = ENTITY.GetVelocity(Game.PlayerStats[botclientid]._Entity) 
								if((vx*vx+vz*vz)>=118 or math.floor(math.random(20))==1)then
									-- BUNNY
									--o:SetupAction(botclientid,Actions.Jump,pitch,yaw)
									PLAYER.BotAction(Game.PlayerStats[botclientid]._Entity,Actions.Jump + Actions.Forward,yaw,pitch,delta)	
								else
									-- RUN
									if(arm < 8 and arm>=0 and self.bot[botclientid].state == BotStates.AttackingEnemy and self.bot[botclientid].weapon ~= 1)then
										--o:SetupAction(botclientid,Actions.Forward,pitch,yaw)
										PLAYER.BotAction(Game.PlayerStats[botclientid]._Entity,Actions.Fire,yaw,pitch,delta)
									elseif(self.bot[botclientid].state == BotStates.AttackingEnemy and self.bot[botclientid].weapon == 1)then	
										-- ADJUST FOR SKILL
										if(Cfg.BotSkill<10)then
											self.bot[botclientid].mex = self.bot[botclientid].mex + math.random(-(10-Cfg.BotSkill)*0.5,(10-Cfg.BotSkill)*0.5)
											self.bot[botclientid].mez = self.bot[botclientid].mez + math.random(-(10-Cfg.BotSkill)*0.5,(10-Cfg.BotSkill)*0.5)
										end
										--self.bot[botclientid].state = BotStates.ChangingWeapon
										--o:SetupAction(botclientid,Actions.Forward,pitch,yaw)
										o:SetupAction(botclientid,Actions.Fire + Actions.Forward,pitch,yaw)
										o.ForwardVector:Set(self.bot[botclientid].mex-botx,self.bot[botclientid].mey-boty,self.bot[botclientid].mez-botz)
										o.ForwardVector:Normalize()
										PLAYER.BotAction(Game.PlayerStats[botclientid]._Entity,Actions.Fire + Actions.Forward,yaw,pitch,delta)
									--elseif(arm < 3 and arm >=0 and self.bot[botclientid].state == BotStates.AttackingEnemy)then	
										--o:SetupAction(botclientid,Actions.Fire,pitch,yaw)
										--PLAYER.BotAction(Game.PlayerStats[botclientid]._Entity,Actions.Fire,yaw,pitch,delta)
									else	
										--o:SetupAction(botclientid,Actions.Forward,pitch,yaw)
										PLAYER.BotAction(Game.PlayerStats[botclientid]._Entity,Actions.Forward,yaw,pitch,delta)
									end
								end
							else
								-- FORWARD IN THE AIR
								--if(not math.floor(math.random(10))==1)then
								o:SetupAction(botclientid,Actions.Forward,pitch,yaw)
								PLAYER.BotAction(Game.PlayerStats[botclientid]._Entity,Actions.Forward,yaw,pitch,delta)	
								--else
									--PLAYER.BotAction(Game.PlayerStats[botclientid]._Entity,Actions.Jump + Actions.Forward,yaw,pitch,delta)	
								--end
							end
						elseif(self.bot[botclientid].state == BotStates.AttackingEnemy)then
							-- ATTACK
							-- ADJUST FOR SKILL
							if(Cfg.BotSkill<10)then
								--yaw = yaw + math.random(-(10-Cfg.BotSkill)*math.pi/8.0,(10-Cfg.BotSkill)*math.pi/8.0)
								--pitch = pitch + math.random(-(10-Cfg.BotSkill)*math.pi/8.0,(10-Cfg.BotSkill)*math.pi/8.0)
								self.bot[botclientid].mex = self.bot[botclientid].mex + math.random(-(10-Cfg.BotSkill)*0.5,(10-Cfg.BotSkill)*0.5)
								self.bot[botclientid].mez = self.bot[botclientid].mez + math.random(-(10-Cfg.BotSkill)*0.5,(10-Cfg.BotSkill)*0.5)
							end
							
							if(self.bot[botclientid].altfire)then
								if(self.bot[botclientid].straferight == false)then
									o:SetupAction(botclientid,Actions.AltFire + Actions.Left,pitch,yaw)
									o.ForwardVector:Set(self.bot[botclientid].mex-botx,self.bot[botclientid].mey-boty,self.bot[botclientid].mez-botz)
									o.ForwardVector:Normalize()
									PLAYER.BotAction(Game.PlayerStats[botclientid]._Entity,Actions.AltFire + Actions.Left,yaw,pitch,delta)	
								else
									o:SetupAction(botclientid,Actions.AltFire + Actions.Right,pitch,yaw)
									o.ForwardVector:Set(self.bot[botclientid].mex-botx,self.bot[botclientid].mey-boty,self.bot[botclientid].mez-botz)
									o.ForwardVector:Normalize()
									PLAYER.BotAction(Game.PlayerStats[botclientid]._Entity,Actions.AltFire + Actions.Right,yaw,pitch,delta)	
								end
							else
								if(self.bot[botclientid].straferight == false)then
									o:SetupAction(botclientid,Actions.Fire + Actions.Left,pitch,yaw)
									o.ForwardVector:Set(self.bot[botclientid].mex-botx,self.bot[botclientid].mey-boty,self.bot[botclientid].mez-botz)
									o.ForwardVector:Normalize()
									PLAYER.BotAction(Game.PlayerStats[botclientid]._Entity,Actions.Fire + Actions.Left,yaw,pitch,delta)	
								else
									o:SetupAction(botclientid,Actions.Fire + Actions.Right,pitch,yaw)
									o.ForwardVector:Set(self.bot[botclientid].mex-botx,self.bot[botclientid].mey-boty,self.bot[botclientid].mez-botz)
									o.ForwardVector:Normalize()
									PLAYER.BotAction(Game.PlayerStats[botclientid]._Entity,Actions.Fire + Actions.Right,yaw,pitch,delta)	
								end
							end
						elseif(self.bot[botclientid].state == BotStates.ChangingWeapon)then
				
								-- DEFAULTS, MEDIUM RANGE
								-- ADJUST FOR SKILL
								if(Cfg.BotSkill<10)then
									--yaw = yaw + math.random(-(10-Cfg.BotSkill)*math.pi/8.0,(10-Cfg.BotSkill)*math.pi/8.0)
									--pitch = pitch + math.random(-(10-Cfg.BotSkill)*math.pi/8.0,(10-Cfg.BotSkill)*math.pi/8.0)
									self.bot[botclientid].mex = self.bot[botclientid].mex + math.random(-(10-Cfg.BotSkill)*0.5,(10-Cfg.BotSkill)*0.5)
									self.bot[botclientid].mez = self.bot[botclientid].mez + math.random(-(10-Cfg.BotSkill)*0.5,(10-Cfg.BotSkill)*0.5)
								end
								if(o.EnabledWeapons[4]~=nil and o.Ammo[Weapon2Ammo[41]] > 0)then
									self.bot[botclientid].weapon = 4
									self.bot[botclientid].altfire = false
								elseif(o.EnabledWeapons[4]~=nil and o.Ammo[Weapon2Ammo[42]] > 0)then
									self.bot[botclientid].weapon = 4
									self.bot[botclientid].altfire = true
								elseif(o.EnabledWeapons[5]~=nil and o.Ammo[Weapon2Ammo[52]] > 0)then
									self.bot[botclientid].weapon = 5
									self.bot[botclientid].altfire = true
								elseif(o.EnabledWeapons[5]~=nil and o.Ammo[Weapon2Ammo[51]] > 0)then
									self.bot[botclientid].weapon = 5
									self.bot[botclientid].altfire = false
								elseif(o.EnabledWeapons[2]~=nil and o.Ammo[Weapon2Ammo[21]] > 0)then
									self.bot[botclientid].weapon = 2
									self.bot[botclientid].altfire = false
								elseif(o.EnabledWeapons[3]~=nil and o.Ammo[Weapon2Ammo[31]] > 0)then
									self.bot[botclientid].weapon = 3
									self.bot[botclientid].altfire = false
								else
									self.bot[botclientid].weapon = 1
									self.bot[botclientid].altfire = false
								end
							if(arm>20)then
								if(o.EnabledWeapons[4]~=nil and o.Ammo[Weapon2Ammo[42]] >0)then
									self.bot[botclientid].weapon = 4
									self.bot[botclientid].altfire = true
								elseif(o.EnabledWeapons[3]~=nil and o.Ammo[Weapon2Ammo[31]] > 0)then
									self.bot[botclientid].weapon = 3
									self.bot[botclientid].altfire = false
								elseif(o.EnabledWeapons[2]~=nil and o.Ammo[Weapon2Ammo[21]] > 0)then
									self.bot[botclientid].weapon = 2
									self.bot[botclientid].altfire = false
								else
									self.bot[botclientid].weapon = 1
									self.bot[botclientid].altfire = false
								end
							--SHORT RANGE
							elseif(arm<=6 and arm>1.5)then
								if(o.EnabledWeapons[4]~=nil and o.Ammo[Weapon2Ammo[41]] > 0)then
									self.bot[botclientid].weapon = 4
									self.bot[botclientid].altfire = false
								elseif(o.EnabledWeapons[4]~=nil and o.Ammo[Weapon2Ammo[42]] > 0)then
									self.bot[botclientid].weapon = 4
									self.bot[botclientid].altfire = true
								elseif(o.EnabledWeapons[5]~=nil and o.Ammo[Weapon2Ammo[51]] > 0)then
									self.bot[botclientid].weapon = 5
									self.bot[botclientid].altfire = true
								elseif(o.EnabledWeapons[3]~=nil and o.Ammo[Weapon2Ammo[31]] > 0)then
									self.bot[botclientid].weapon = 3
									self.bot[botclientid].altfire = false
								elseif(o.EnabledWeapons[2]~=nil and o.Ammo[Weapon2Ammo[21]] > 0)then
									self.bot[botclientid].weapon = 2
									self.bot[botclientid].altfire = false
								else
									self.bot[botclientid].weapon = 1
									self.bot[botclientid].altfire = false
								end
							--POINT BLANK
							elseif(arm<=1.5)then
								self.bot[botclientid].weapon = 1
								self.bot[botclientid].altfire = false
								--if(math.random(2)>1)then self.bot[botclientid].altfire = true end
							end

							
							PLAYER.BotAction(Game.PlayerStats[botclientid]._Entity,Actions.None,yaw,pitch,delta)
							
							-- RANDOM WEAPON USE
							--self.bot[botclientid].weapon = math.floor(( math.random(4) )) + 1
							o:TryToChangeWeapon( self.bot[botclientid].weapon  )
							if MPCfg.GameMode ~= "Voosh" then o._CurWeaponIndex = self.bot[botclientid].weapon end
							--self.bot[botclientid].altfire = false
							--if(math.random(2)>1)then self.bot[botclientid].altfire = true end
							-- RANDOM WEAPON USE
							
							-- CAREFUL
							self.bot[botclientid].state = BotStates.HeadingToWaypoint
							self.bot[botclientid].statetime = INP.GetTime() + 2
							
							self.bot[botclientid].straferight = true
							if(math.random(2)>1)then self.bot[botclientid].straferight = false end
							
						elseif(self.bot[botclientid].state == BotStates.Talking)then
							-- STAND
							local tauntcount = 0
							for i,taunt in Cfg.BotTaunts do
								tauntcount = tauntcount + 1
							end
							local txt = Cfg.BotTaunts[math.floor(math.random(1,tauntcount-1))]
							if(Cfg.BotEliza and not Game.PlayerStats[botclientid].LastThingHeard)then
								--PLAYER.BotAction(Game.PlayerStats[botclientid]._Entity,Actions.SelectBestWeapon1,yaw,pitch,delta)
								--return
							end
							if(Cfg.BotEliza and Game.PlayerStats[botclientid].LastThingHeard)then

								--MsgBox(Game.PlayerStats[botclientid].LastThingHeard)
								local reply = Eliza(Game.PlayerStats[botclientid].LastThingHeard)
								--MsgBox(reply)
								txt = string.lower(reply)
								Game.PlayerStats[botclientid].LastThingHeard = nil
							end
							if(math.random(6)>1 and false)then
									Game.PlayerStats[botclientid].LastThingHeard = nil
									PLAYER.BotAction(Game.PlayerStats[botclientid]._Entity,Actions.SelectBestWeapon1,yaw,pitch,delta)
								return
							end
							for i,y in Game.PlayerStats do
								if y.ClientID == ServerID then
									RawCallMethod(Game.ConsoleClientMessage,botclientid,txt,0) 
								else
									SendNetMethod(Game.ConsoleClientMessage, y.ClientID, true, true, botclientid ,txt,0)
								end
							end
							   
							--o:SetupAction(botclientid,Actions.SelectBestWeapon1,pitch,yaw)
							PLAYER.BotAction(Game.PlayerStats[botclientid]._Entity,Actions.SelectBestWeapon1,yaw,pitch,delta)
							self.bot[botclientid].state = BotStates.Idle
							self.bot[botclientid].statetime = INP.GetTime() + 3
						else
							o:SetupAction(botclientid,Actions.None,pitch,yaw)
							PLAYER.BotAction(Game.PlayerStats[botclientid]._Entity,Actions.SelectBestWeapon1,yaw,pitch,delta)
						end	
					
					end
			    	end 			    	
				--
				--if(Game.PlayerStats[botclientid].Bot)then Game.PlayerStats[botclientid].Ping = 32 + math.floor(math.random(10)) end  				
			end
		end
	end
end  


function Game:GetAttackTarget(botclientid)
	local nearestx = 0
	local nearesty = 0
	local nearestz = 0
	local min = 1000000
	local botx,boty,botz = ENTITY.PO_GetPawnHeadPos(self.PlayerStats[botclientid]._Entity) 
	local targetsuccess = false	
	for i, ps in Game.PlayerStats do
		if(ps and ps~=nil and ps._Entity~=nil)then
			if(ps.ClientID ~= botclientid)then
			if(ps.Spectator == 0)then
			if(Game.PlayerStats[botclientid].Team ~= ps.Team and MPGameRules[MPCfg.GameMode] and MPGameRules[MPCfg.GameMode].Teams or not (MPGameRules[MPCfg.GameMode] and MPGameRules[MPCfg.GameMode].Teams)) then
			local mex,mey,mez = ENTITY.PO_GetPawnHeadPos(ps._Entity) 
			local distance = Dist3D(botx,boty,botz,mex,mey,mez)  
			if(distance<min and distance<80)then
				local angle = math.atan2(botx-mex,botz-mez) 
				--if(math.abs(angle - self.bot[botclientid].angle) < math.pi/2)then
					ENTITY.RemoveFromIntersectionSolver(self.bot[botclientid]._Entity)
					local b,d,wx,wy,wz = WORLD.LineTraceFixedGeom(botx,boty,botz,mex,mey,mez)
					ENTITY.AddToIntersectionSolver(self.bot[botclientid]._Entity)	
					--if(b)then RawCallMethod(Game.ConsoleClientMessage,botclientid,"I DONT SEE YOU "..botx.." "..boty.." "..botz) end
					if(not b)then
						--RawCallMethod(Game.ConsoleClientMessage,botclientid,"I SEE YOU "..mex.." "..mey.." "..mez) 
						local weaponclass =0 -- 0 = hitscan, 1 = aimatfeet, 2 = gravityaffected
						local time = distance / 40.0 -- weapon speed
						local vx,vy,vz,l = ENTITY.GetVelocity(ps._Entity) 
							local wep = self.bot[botclientid].weapon
							local alt = self.bot[botclientid].altfire	
							local weaponspeed = 40.0
							
							-- MISSILES - ROCKETS, SHURIKENS, FREEZE, PAINKILLER2
							if(wep==4 and alt==false)then
								weaponspeed = 40.0
							elseif(wep==5 and alt==false)then
								weaponspeed = 70.0
							elseif(wep==1 and alt==true)then
								weaponspeed = 30.0
							elseif(wep==2 and alt==true)then
								weaponspeed = 50.0
								
							-- GRAVITY AFFECTED - STAKE, BOLT, GRENADES
							elseif(wep==3 and alt==false)then
								weaponspeed = 100.0 --70.0
							elseif(wep==7 and alt==false)then
								weaponspeed = 190.0
							elseif(wep==3 and alt==true)then
								weaponspeed = 28.0 -- also has 8 up
							end
							local k = (mex-botx)
							local l = (mey-boty)
							local m = (mez-botz)
							local A = vx*vx + vy*vy + vz*vz - weaponspeed*weaponspeed
							local B = 2.0*(k*vx + l*vy + m*vz)
							local C = k*k + l*l + m*m
							if(A~=0 and B*B > 4*A*C)then
								time = (-B + math.sqrt(B*B-4.0*A*C))/(2.0*A)
								if(time<0)then time = (-B - math.sqrt(B*B-4.0*A*C))/(2.0*A) end
							end
							
							ENTITY.RemoveFromIntersectionSolver(ps._Entity)
							local isFloor,d,wx,wy,wz = WORLD.LineTraceFixedGeom(mex,mey,mez,mex,mey-2.21,mez)    
							ENTITY.AddToIntersectionSolver(ps._Entity)
				
							if(isFloor)then
								-- MISSILES - ROCKETS, SHURIKENS, FREEZE, PAINKILLER2
								if(wep==4 and alt==false or wep==5 and alt==false or wep==1 and alt==true or wep==2 and alt==true)then
									nearestx = mex + vx*time
									nearestz = mez + vz*time
									if(wep==4 and alt==false)then
										nearesty = mey - 2.15 --+ vy*time
										if(nearesty>boty)then
											nearesty = mey
										end
									else
										nearesty = mey - 0.8
									end
									
								-- GRAVITY AFFECTED - STAKE, BOLT, GRENADES
								elseif(wep==3 and alt==true or wep==7 and alt==false or wep==3 and alt==false)then
									nearestx = mex + vx*time
									nearestz = mez + vz*time
									nearesty = mey - 1.1 + 0.5*Tweak.GlobalData.MPGravity*time*time
								else
								
								-- HITSCAN - CHAINGUN, MACHINEGUN, SHOTGUN, ELECTRO, PAINKILLER1
									nearestx = mex
									nearesty = mey
									nearestz = mez
								end
								--RawCallMethod(Game.ConsoleClientMessage,botclientid,"ON GROUND "..wep,0) 
							else
								-- MISSILES - SHURIKENS, ROCKETS, FREEZE, PAINKILLER2
								if(wep==4 and alt==false or wep==5 and alt==false or wep==1 and alt==true or wep==2 and alt==true)then
									nearestx = mex + vx*time
									nearestz = mez + vz*time
									if(wep==4 and alt==false)then
										nearesty = mey - 0.65 + vy*time - 0.5*Tweak.GlobalData.MPGravity*time*time
										if(nearesty < boty - 2.15 )then
											nearesty = boty - 2.15
										end
									else
										nearesty = mey - 0.8 + vy*time - 0.5*Tweak.GlobalData.MPGravity*time*time
										if(nearesty < boty - 0.8 )then
											nearesty = boty - 0.8
										end
									end
									
								-- GRAVITY AFFECTED - STAKE, BOLT, GRENADES
								elseif(wep==3 and alt==true or wep==7 and alt==false or wep==3 and alt==false)then
									nearestx = mex + vx*time
									nearestz = mez + vz*time
									nearesty = mey - 0.3 -- TARGET FALLING VELOCITY CANCELS
									if(nearesty < boty - 2.2 )then
										nearesty = mey - 0.3 + 0.5*Tweak.GlobalData.MPGravity*time*time
									end
								else
								
								-- HITSCAN - CHAINGUN, MACHINEGUN, SHOTGUN, ELECTRO, PAINKILLER1
									nearestx = mex
									nearesty = mey
									nearestz = mez
								end
								--RawCallMethod(Game.ConsoleClientMessage,botclientid,"IN AIR",0) 
							end
							
						
															
						targetsuccess  = true
						min = distance
					end
				end
				end
				end
			end
		end	
	end
	return nearestx,nearesty,nearestz,targetsuccess
end
--============================================================================
function Game:GetClientPosition(botclientid)
	local x = 0
	local y = 0
	local z = 0
        if Game.PlayerStats[botclientid]~=nil and Game.PlayerStats[botclientid]._Entity~=nil then   		               
		x,y,z = ENTITY.PO_GetPawnHeadPos(Game.PlayerStats[botclientid]._Entity) 
	end
	return x,y,z
end
--============================================================================
function Game:GetCurrentWaypoint(botclientid)
	local x,y,z = self:GetClientPosition(botclientid)
	for i,locitem in Waypoint.Position do 
		if(Dist2D(x,z,locitem.x,locitem.z)<=2)then     -- Dist3D(x,y,z,locitem.x,locitem.y,locitem.z)<1 or WAS 0.6
			return i
		end
	end
	-- NON WAYPOINT DETECTION
	if(Dist2D(x,z,Game.bot[botclientid].mex,Game.bot[botclientid].mez)<1)then
		return (300+math.floor(math.random(1000)))
	end
	return -1
end
--============================================================================
function Game:GetNextWaypoint(botplayerid, currentwp)
	local areaname = "Unknown"
	local min = 1000000
	local botx,boty,botz = ENTITY.PO_GetPawnHeadPos(Game.PlayerStats[botplayerid]._Entity) 
	local nearestx = 0
	local nearesty = 0
	local nearestz = 0
	local success = false
	local wpokay = true
	for i,locitem in Waypoint.Position do  
		--MsgBox(i.." "..currentwp)
		if(i ~= currentwp)then  
			wpokay = true 
			for j=1,32 do
				--MsgBox(j)
				if(wpokay == true)then
					if(i==self.bot[botplayerid].TargetID[j])then
						--MsgBox("error : "..i.."which is "..self.bot[botplayerid].TargetID[j].." number "..j)
						wpokay = false
					end
				end
			end
			if(wpokay)then
				local wayangle = math.atan2(botx-locitem.x,botz-locitem.z)  
				--if(math.abs(wayangle-self.bot[botplayerid].angle) < math.pi/2.0)then
					local distance = Dist3D(botx,boty,botz,locitem.x,locitem.y,locitem.z)
					if(distance < min and math.abs(boty-locitem.y)<4.0)then
						local b,d,wx,wy,wz = WORLD.LineTraceFixedGeom(locitem.x,locitem.y,locitem.z,botx,boty,botz)
						if(not b)then
							areaname = locitem.location
							nearestx = locitem.x
							nearesty = locitem.y
							nearestz = locitem.z
							success = true
							targetid = i
							min = distance
						end
					end
				--end
			end
		end
	end 
	return nearestx,nearesty,nearestz,targetid,success
end
--=======================================================================
function Console:Cmd_KICKBOT()
    if Game.GMode == GModes.SingleGame then return end
    if Game:IsServer() then
    	local botcount = 0
    	local bluecount = 0
    	local redcount = 0
    	for i,ps in Game.PlayerStats do
	    	if ps.Bot then
	    		botcount = botcount + 1	
	    	end
    	end
    	if(botcount>0)then
	    	local base = 150
	    	local BotID = base + botcount
	    	--Console:Cmd_BANKICKID(BotID-1)
	    	--MsgBox(BotID-1)
	    	--Game.AfterClientDisconnected(BotID-1)
	    	
	    	Game.OnPlayerLeaveGame(BotID-1)
	    	--ENTITY.PO_Remove(Game.PlayerStats[BotID-1]._Entity)
	    	Game.PlayerStats[BotID-1]=nil
	        --Game.bot[BotID-1] = nil -- preserve name
        end
    end
end
--=======================================================================
function Console:Cmd_KICKALLBOTS()
	local botcount = 0
    	for i,ps in Game.PlayerStats do
	    	if ps.Bot then
	    		botcount = botcount + 1	
	    	end
    	end
    	for i=0,botcount+1 do
    		Console:Cmd_KICKBOT()
    	end
end
--=======================================================================
function Console:Cmd_BOTMINPLAYERS(number)
    if Game.GMode == GModes.SingleGame then return end
    if Game:IsServer() then
    	if(number==nil)then
    		CONSOLE_AddMessage("Syntax: botminplayers <number>")
    		CONSOLE_AddMessage("Help: Sets the minimum number of players to appear on the server, before which bots are added. If set equal to Cfg.MaxPlayers, the bots will always leave one space for new players. If set greater than Cfg.MaxPlayers, bots will leave a space only if there are spectators present.")
		CONSOLE_AddMessage("State: Cfg.BotMinPlayers is currently ".. tonumber(Cfg.BotMinPlayers))
	else
		Cfg.BotMinPlayers = tonumber(number)
		CONSOLE_AddMessage("Cfg.BotMinPlayers is now ".. tonumber(number))
	end
    end
end
--=======================================================================
function Console:Cmd_BOTSKILL(number)
    if Game.GMode == GModes.SingleGame then return end
    if Game:IsServer() then
    	if(number==nil)then
    		CONSOLE_AddMessage("Cfg.BotSkill is "..Cfg.BotSkill)
	else
		Cfg.BotSkill = tonumber(number)
		CONSOLE_AddMessage("Cfg.BotSkill is now ".. tonumber(Cfg.BotSkill))
	end
    end
end
--=======================================================================
function Console:Cmd_ADDBOT()
    if Game.GMode == GModes.SingleGame then return end
    if Game:IsServer() and not (MPCfg.GameState == GameStates.Playing and MPCfg.ForceSpec == true) then
    	local botcount = 0
    	local bluecount = 0
    	local redcount = 0
    	for i,ps in Game.PlayerStats do
	    	if ps.Team == 0 and ps.Spectator == 0 then
	    		bluecount = bluecount + 1
	    	end
	    	if ps.Team == 1 and ps.Spectator == 0 then
	    		redcount = redcount + 1
	    	end
	    	if ps.Bot then
	    		botcount = botcount + 1	
	    	end
    	end
    	local team = math.floor(math.random(0,1))
    	if(redcount < bluecount) then team = 1 end
    	if(redcount > bluecount) then team = 0 end
    	
    	-- TOO MANY PLAYERS
    	if(redcount + bluecount >= Cfg.MaxPlayers)then CONSOLE_AddMessage("Too many players. Increase Cfg.MaxPlayers") return end
    	if Cfg.GameMode == "Duel" and redcount + bluecount >= 2 then CONSOLE_AddMessage("Too many players.")return end
    	
    	
    	local base = 150
    	local BotID = base + botcount -- math.random(500,600)   	
        --			clientID,name,model,team,state,spectator
        name = "Bot-"..BotID
        local namecount = 1
        for nnn in Cfg.BotNames do
        	if(nnn~=nil)then namecount = namecount + 1 end
        end
        
        local name = Cfg.BotNames[math.floor(math.random(namecount-1))]
        
        if(name==nil)then name = "Bot-"..BotID end
        if(Game.bot[BotID] and Game.bot[BotID].Name~=nil)then 
        	name = Game.bot[BotID].Name
	end
	
        Game.bot[BotID]={angle=0,speed=0,rotation=1,state=0,mex=0,mey=0,mez=0,statetime=INP.GetTime(),TargetID={}, altfire=false, weapon = 3, straferight=false}
        Game.bot[BotID].Name = name  
             
        Game.NewPlayerRequest(BotID,name,math.floor(math.random(1,4)),team,0,0)
        --Game.AfterNewClientConnected(14)
        --Game.PlayerRespawnRequest(BotID)

        for j=1,32 do
		Game.bot[BotID].TargetID[j]= -2
	end
	if(Game.PlayerStats[BotID]~=nil)then
		Game.PlayerStats[BotID].Bot = true
	        Game.SetStateRequest(BotID,1)
        end
    end
end
--=======================================================================
function Game:CheckBotCount()
	if Game:IsServer() then
	    	local botcount = 0
	    	local bluecount = 0
	    	local redcount = 0
	    	local speccount = 0
	    	local playercount = 0
	    	
	    	for i,ps in Game.PlayerStats do
		    	if ps.Team == 0 and ps.Spectator == 0 then
		    		bluecount = bluecount + 1
		    	end
		    	if ps.Team == 1 and ps.Spectator == 0 then
		    		redcount = redcount + 1
		    	end
		    	if ps.Bot and ps.Spectator == 0 then
		    		botcount = botcount + 1	
		    	end
		    	if ps.Spectator == 1 then
		    		speccount = speccount + 1
		    	end
	    	end
	    	local playercount = bluecount + redcount

		-- AUTO ADDBOT/KICKBOT LOGIC
		
		local maxplayers = Cfg.MaxPlayers
		if Cfg.GameMode == "Duel" then maxplayers = 2 end
		
		if( Cfg.BotMinPlayers < maxplayers and playercount < maxplayers-1 and playercount < Cfg.BotMinPlayers ) then Console:Cmd_ADDBOT() return end 
		if( Cfg.BotMinPlayers < maxplayers and (playercount > maxplayers-1 or playercount > Cfg.BotMinPlayers) ) and botcount > 0 then Console:Cmd_KICKBOT() return end 
		
		if( Cfg.BotMinPlayers == maxplayers and playercount < maxplayers-1 and playercount < Cfg.BotMinPlayers) then Console:Cmd_ADDBOT() return end 
		if( Cfg.BotMinPlayers == maxplayers and playercount > maxplayers or playercount > Cfg.BotMinPlayers) and botcount > 0 then Console:Cmd_KICKBOT() return end 		

		if( Cfg.BotMinPlayers == maxplayers+1 and playercount < maxplayers-1 and playercount < Cfg.BotMinPlayers) then Console:Cmd_ADDBOT() return end
		if( Cfg.BotMinPlayers == maxplayers+1 and playercount < maxplayers and playercount < Cfg.BotMinPlayers and speccount==0 ) then Console:Cmd_ADDBOT() return end 
		if( Cfg.BotMinPlayers == maxplayers+1 and playercount > maxplayers-1 and speccount > 0) and botcount > 0 then Console:Cmd_KICKBOT() return end 		

		if( Cfg.BotMinPlayers > maxplayers+1 and playercount < maxplayers and playercount < Cfg.BotMinPlayers) then Console:Cmd_ADDBOT() return end 
		if( Cfg.BotMinPlayers > maxplayers+1 and playercount > maxplayers ) and botcount > 0 then Console:Cmd_KICKBOT() return end 							
	end
end
--============================================================================
function Game:GetNearestItem(botclientid)
	local nearestx = 0
	local nearesty = 0
	local nearestz = 0
	local min = 1000000
	local botx,boty,botz = ENTITY.PO_GetPawnHeadPos(self.PlayerStats[botclientid]._Entity) 
	local targetsuccess = false	
        local items = GObjects:GetAllObjectsByClass("CItem")
        for i,o in items do 
        	if(o.Model~=nil and o.Model~="")then         
			local mex = o.Pos.X
			local mey = o.Pos.Y
			local mez = o.Pos.Z		
			local distance = Dist3D(botx,boty,botz,mex,mey,mez)  
			if(distance<min and distance<10 and math.abs(mey-boty)<4)then
				ENTITY.RemoveFromIntersectionSolver(self.bot[botclientid]._Entity)
				local b,d,wx,wy,wz = WORLD.LineTraceFixedGeom(botx,boty,botz,mex,mey,mez)
				ENTITY.AddToIntersectionSolver(self.bot[botclientid]._Entity)	
				if(not b)then
					nearestx = mex
					nearesty = mey		
					nearestz = mez									
					targetsuccess  = true
					min = distance
				end
	                end 
                end
	end
	return nearestx,nearesty,nearestz,targetsuccess
end
--============================================================================