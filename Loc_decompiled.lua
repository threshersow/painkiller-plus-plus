Loc = {
  Position = {}
}

function Loc:Load(mapname)
  local locfile = "../Data/Locs/"
  mapname = string.gsub(mapname, "(%a+).mpk", "%1") .. ".loc"
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
