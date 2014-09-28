Waypoint = 
{
	Position = {}
}
--============================================================================
function Waypoint:Load(mapname)
    -- Clear
      
    local locfile = "../Data/Waypoints/"  
    mapname = string.gsub (mapname,"(%a+).mpk", "%1")  .. ".bwp"
    --MsgBox(locfile..mapname)
    local file = io.open (locfile..mapname,"r")
    if not file then
		return
    end
    
    local pattern = "([%w%s]+),([0-9%-%.]+),([0-9%-%.]+),([0-9%-%.]+)"
    
    local index = 1
    for line in file:lines() do
    	local location = string.gsub(line, pattern, "%1")
    	local x = string.gsub(line, pattern, "%2")
    	local y = string.gsub(line, pattern, "%3")
    	local z = string.gsub(line, pattern, "%4")
    	location = Game:GetLocationByPosition(x,y,z)
    	self.Position[index] = {location = location, x = tonumber(x), y = tonumber(y), z = tonumber(z)}
    	--MsgBox("Read: "..self.Position[index].location.." "..self.Position[index].x.." "..self.Position[index].y.." "..self.Position[index].z.." <--")
    	index = index + 1
    end
	--MsgBox("Read: "..index)
    io.close(file)
end
--============================================================================
