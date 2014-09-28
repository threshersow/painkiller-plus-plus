Demo = 
{
	LogfileDefault = "gamelog.log",
	fileopen = 0,
	file = 0,
	timestamp = 0,
	linenumber = 0,
}
--============================================================================
function Demo:ReadDemoEvents(filename)
	if Demo.timestamp==0 or tonumber(timestamp) > INP.GetTime() then return false end	
	repeat 
		local line = io.lines(filename)
		if line ~= nil then Demo:ReadEvent(line) end
	until line == "EOE" or line == nil
	Demo.timestamp = io.lines(filename)
	Demo.timestamp = tonumber(Demo.timestamp)
	return true
end
--============================================================================
function Demo:WriteGame()
	Demo:Write(Lev.Map)
	local playercount = 0
	for i, ps in Game.PlayerStats do playercount = playercount + 1 end
	Demo:Write(playercount)
	for i, ps in Game.PlayerStats do 
		Demo:Write(ps.ClientID)
		Demo:Write(ps.Name)
		Demo:Write(ps.Model)
		Demo:Write(ps.Team)
		Demo:Write(ps.State)
		Demo:Write(ps.Spectator)
	end
end
--============================================================================
function Demo:ReadGame(filename)
	Game._DemoPlaying = true
	local map = Demo:GetLine()
	
	local playerName = Cfg["PlayerName"]
	local passwd = ""
	local speed = 1
	local port = Cfg["ServerPort"]
	local public = Cfg["PublicServer"]
	if( PMENU.StartServer( playerName, passwd, map, speed, port, "", public ) ) then
		PMENU.Activate( false )
		MOUSE.Show( false )
        	NET.LoadMapOnServer(map)
	end
	local numberofplayers = Demo:GetLine()
	for i=0,tonumber(numberofplayers) do
		local clientid = Demo:GetLine()
		local name = Demo:GetLine()
		local model = Demo:GetLine()
		local team = Demo:GetLine()
		local state = Demo:GetLine()
		local spectator = Demo:GetLine()
		Game.NewPlayerRequest(tonumber(clientid),name,tonumber(model),tonumber(team),tonumber(state),tonumber(spectator))
	end
end
--============================================================================
function Demo:GetLine()
	self.file = io.open ("test.dem","r")
	self.fileopen = 1
	local counter = 0
	local txt = nil
	for line in Demo.file:lines() do
		if counter == Demo.linenumber then txt = line end
		counter = counter + 1
	end
	Demo.linenumber = Demo.linenumber + 1
	io.close(self.file)
	self.fileopen = 0
	return txt
end
--============================================================================
function Demo:WriteEvent(event)

	-- "S" -- Sound
	-- "P" -- Player Movement
	-- "F" -- Fire
	-- "A" -- AltFire
	-- "J" -- Jump
	-- "C" -- Console
	-- "N" -- New Player
	-- "Q" -- Player Leave
	-- "X" -- Player Spec / No Spec
	-- "M" -- MPSTATS Update
	-- "G" -- Read Game
	
	--if(event=="P-ALL")then
		for i, ps in Game.PlayerStats do        
			if ps and ps._Entity and ps._Entity ~=0 and ps.Spectator == 0 and ps._animproc then   		
				local ap = ps._animproc    
				local clientid = ps.ClientID            
				local x,y,z = ENTITY.PO_GetPawnHeadPos(ps._Entity) 
				local yaw = ENTITY.GetOrientation(ps._Entity)
				local pitch = ap._LastPitch
				local anim = ap.Animation
				local txt = "P" .. ":"
				--clientid,x,y,z,yaw,pitch,anim
				txt = txt .. tostring(clientid)..",".. tostring(x)..",".. tostring(y)..",".. tostring(z)..",".. tostring(yaw)..",".. tostring(pitch)..",".. tostring(anim)
				Demo:Write(txt)
			end
		end
	--end
end
--============================================================================
function Demo:ReadEvent(line)

	-- "S" -- Sound
	-- "P" -- Player Movement
	-- "F" -- Fire
	-- "A" -- AltFire
	-- "J" -- Jump
	-- "C" -- Console
	-- "N" -- New Player
	-- "Q" -- Player Leave
	-- "X" -- Player Spec / No Spec
	-- "M" -- MPSTATS Update
	-- "G" -- Read Game
	
	local eventpattern = "(%w+):([%a%p%d%s]+)"
	local event = string.gsub(line, eventpattern , "%1") 
	line = string.gsub(line, eventpattern , "%2") 
	
	if(event=="P")then
		--clientid,x,y,z,yaw,pitch,anim
		local pattern= "([0-9%-%.]+),([0-9%-%.]+),([0-9%-%.]+),([0-9%-%.]+),([0-9%-%.]+),([0-9%-%.]+),(%w+)"
		local clientid = string.gsub(line, eventpattern , "%1") 
		local x = string.gsub(line, eventpattern , "%2") 
		local y = string.gsub(line, eventpattern , "%3") 
		local z = string.gsub(line, eventpattern , "%4") 
		local yaw = string.gsub(line, eventpattern , "%5") 
		local pitch = string.gsub(line, eventpattern , "%6") 
		local anim = string.gsub(line, eventpattern , "%7") 
		ENTITY.SetPosition(Game.PlayerStats[clientid]._Entity,x,y,z)
		ENTITY.SetOrientation(Game.PlayerStats[clientid]._Entity, yaw)
		Game.PlayerStats[clientid]._animproc._LastPitch = pitch
		Game.PlayerStats[clientid]._animproc.Animation = anim
		--local pp = Game.Players[clientid]
		--pp:Syncronize()
	end
	if(event=="F")then
		
	end	
end
--============================================================================
function Demo:Write(txt)
	if(self.fileopen == 0)then
		self:Open()
	end
	if(self.fileopen==1)then
		self.file:write( tostring(txt)..'\n' )
		self.file:flush()
	end	
end
--============================================================================
function Demo:Open()
	if(self.fileopen == 0)then
		self.file = io.open ("test.dem","a")
		self.fileopen = 1
	else
		self:Close()
		self:Open()
	end
	if(self.fileopen == 1)then
		-- WRITE GAME INFO
		Demo:WriteGame()
	end
end
--============================================================================
function Demo:Close()
	if(self.fileopen==1)then
		io.close(self.file)
		self.fileopen = 0
	end
end
--============================================================================

