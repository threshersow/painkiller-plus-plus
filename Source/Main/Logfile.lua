--============================================================================
-- PK++ Logfile
--============================================================================
Logfile = 
{
	LogfileDefault = "gamelog.log",
	fileopen = 0,
	file = 0
}	
--============================================================================
function Logfile:Write(txt)
	if(self.fileopen == 0)then
		self:Open()
	end
	if(self.fileopen==1)then
		self.file:write( txt..'\n' )
		self.file:flush()
	end	
end
--============================================================================
function Logfile:Open()
	if(not Cfg)then return end
	if(Cfg.Logfile=="" or Cfg.Logfile==nil) then
		return
	end
	if(self.fileopen == 0)then
		if(Cfg.LogfileDaily)then
			self.file = io.open (os.date("%m-%d-%y-", os.time())..Cfg.Logfile..".log","a")
			self.fileopen = 1
		else
			self.file = io.open (Cfg.Logfile..".log","w")
			self.fileopen = 1
			
		end
	else
		self:Close()
		self:Open()
	end
	if(self.fileopen == 1)then
		self.file:write( "PK++ Logging Started..."..'\n' )
		self.file:write( os.date( "%d/%m/%y %X", os.time() )..'\n' )
	end
end
--============================================================================
function Logfile:Close()
	if(self.fileopen==1)then
		io.close(self.file)
		self.fileopen = 0
	end
end
--============================================================================
