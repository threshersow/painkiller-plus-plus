Waypoint = {
  Position = {}
}

function Waypoint:Load(mapname)
  local locfile = "../Data/Waypoints/"
  mapname = string.gsub(mapname, "(%a+).mpk", "%1") .. ".bwp"
  local file = io.open(locfile .. mapname, "r")
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
    location = Game:GetLocationByPosition(x, y, z)
    self.Position[index] = {
      location = location,
      x = tonumber(x),
      y = tonumber(y),
      z = tonumber(z)
    }
    index = index + 1
  end
  io.close(file)
end
