Mapview = {}

function Mapview:Load(mapname)
  self.globalscale = 3
  self.globaltranslatex = 0
  self.globaltranslatey = 0
  self.globaltranslaterot = 0
  self.imagescale = 1
  self.imagetranslatex = 0
  self.imagetranslatey = 0
  local locfile = "../Data/Mapview/"
  mapname = string.gsub(mapname, "(%a+).mpk", "%1") .. ".cfg"
  local file = io.open(locfile .. mapname, "r")
  if not file then
    return
  end
  local pattern = "([0-9%-%.]+),([0-9%-%.]+),([0-9%-%.]+),([0-9%-%.]+),([0-9%-%.]+),([0-9%-%.]+),([0-9%-%.]+)"
  local once = true
  for line in file:lines() do
    local readglobalscale = string.gsub(line, pattern, "%1")
    local readglobaltranslatex = string.gsub(line, pattern, "%2")
    local readglobaltranslatey = string.gsub(line, pattern, "%3")
    local readglobaltranslaterot = string.gsub(line, pattern, "%4")
    local readimagescale = string.gsub(line, pattern, "%5")
    local readimagetranslatex = string.gsub(line, pattern, "%6")
    local readimagetranslatey = string.gsub(line, pattern, "%7")
    self.globalscale = tonumber(readglobalscale)
    self.globaltranslatex = tonumber(readglobaltranslatex)
    self.globaltranslatey = tonumber(readglobaltranslatey)
    self.globaltranslaterot = tonumber(readglobaltranslaterot)
    self.imagescale = tonumber(readimagescale)
    self.imagetranslatex = tonumber(readimagetranslatex)
    self.imagetranslatey = tonumber(readimagetranslatey)
    if self.globalscale == nil then
      self.globalscale = 1
    end
    if self.globaltranslatex == nil then
      self.globaltranslatex = 0
    end
    if self.globaltranslatey == nil then
      self.globaltranslatey = 0
    end
    if self.globaltranslaterot == nil then
      self.globaltranslaterot = 0
    end
    if self.imagescale == nil then
      self.imagescale = 1
    end
    if self.imagetranslatex == nil then
      self.imagetranslatex = 0
    end
    if self.imagetranslatey == nil then
      self.imagetranslatey = 0
    end
    local txt = tostring(self.globalscale) .. "," .. tostring(self.globaltranslatex) .. "," .. tostring(self.globaltranslatey) .. "," .. tostring(self.globaltranslaterot) .. "," .. tostring(self.imagescale) .. "," .. tostring(self.imagetranslatex) .. "," .. tostring(self.imagetranslatey)
  end
  io.close(file)
end

function Mapview:Save(mapname)
  local locfile = "../Data/Mapview/"
  mapname = string.gsub(mapname, "(%a+).mpk", "%1") .. ".cfg"
  local file = io.open(locfile .. mapname, "w")
  if not file then
    return
  end
  local txt = tostring(self.globalscale) .. "," .. tostring(self.globaltranslatex) .. "," .. tostring(self.globaltranslatey) .. "," .. tostring(self.globaltranslaterot) .. "," .. tostring(self.imagescale) .. "," .. tostring(self.imagetranslatex) .. "," .. tostring(self.imagetranslatey)
  file:write(txt)
  io.close(file)
end
