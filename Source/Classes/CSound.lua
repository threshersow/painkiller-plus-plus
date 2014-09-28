--============================================================================
-- Sound class
--============================================================================
CSound =
{
    Sound = "",
    Pos = Vector:New(0,0,0),
    Volume = 100,
    Interval = 0,
    IsObstructed = false,
    RandomShift = 0, -- losowe przesuniecie od intervalu t = Interval + Rand(-RandomShift,RandomShift)
    EnvironmentIntensity = 0.25, 
    Falloff = 
    {
        Start = 5,
        End = 20,
    },
    _ManualLoop = false, -- loopowanie miedzy losowymi dzwiekami
    _SndPtr = 0, -- jesli interval == 0 operujemy na tym handlerze
    _IvCnt = 0, -- licznik intervalu
    _Class = "CSound",
    _Launched = false,
    _ActivateDist = 10,
}
Inherit(CSound,CObject)
--============================================================================
function CSound:Delete()
    SOUND3D.Stop(self._SndPtr)
    SOUND3D.Delete(self._SndPtr)
    self._SndPtr = nil
end
--============================================================================
function CSound:LoadData()
    self:Delete()
    if Cfg.AmbientSounds and self.Sound ~= "" then
        local t,n = Text2Tab(self.Sound,';')
        local snd = t[math.random(1,n)]
        self._SndPtr = SOUND3D.Create(snd)
        SOUND3D.SetIntensity(self._SndPtr,self.EnvironmentIntensity)
    end    
end
--============================================================================
function CSound:OnClone(old)
    if old == CSound then 
        self.Pos = OppositeToCamera() 
    else 
        self.Pos.X = old.Pos.X - 0.5
        self.Pos.Z = old.Pos.Z - 0.5
    end
    self._SndPtr = nil
end
--============================================================================
function CSound:Apply(old)        
    self.Sound = string.lower(self.Sound)

    self._LaunchCnt = FRand(0,1)
    self._ActivateDist = self.Falloff.Start + (self.Falloff.End - self.Falloff.Start) / 2    
    
    if self.Interval == 0 then
        if string.find(self.Sound,';') then 
            self._ManualLoop = true
        end
    end
    
    if self.Interval == 0 or old then 
        self:Play()
    end

end
--============================================================================
function CSound:Play(onlyLooped)
 
    --Game:Print(self._Name)

    self:LoadData()

    if not Cfg.AmbientSounds then return end
    
    local loops = 1
    if self.Interval == 0 and not self._ManualLoop then
        loops = 0
    end
    
    SOUND3D.SetLoopCount(self._SndPtr,loops)
    SOUND3D.SetPosition(self._SndPtr,self.Pos.X,self.Pos.Y,self.Pos.Z)    
    SOUND3D.SetHearingDistance(self._SndPtr,self.Falloff.Start,self.Falloff.End)
    SOUND3D.SetVolume(self._SndPtr,self.Volume)
    SOUND3D.SetObstructed(self._SndPtr,self.IsObstructed)
    
    if self.Interval == 0 then
       SOUND3D.Play(self._SndPtr)
    else
        if not onlyLooped then
            SOUND3D.PlayAndForget(self._SndPtr)
        end        
        if self.RandomShift > self.Interval - 1 then
			Game:Print(self._Name.."self.RandomShift > self.Interval - 1")
			self.RandomShift = self.Interval - 1
        end
        self._IvCnt = self.Interval + FRand(-self.RandomShift, self.RandomShift)
        if self._IvCnt <= 0 then self._IvCnt = 1 end -- protection
    end
    
    --Game:Print(self._IvCnt)
end
--============================================================================
function CSound:Tick(delta)
    if not Cfg.AmbientSounds then return end
    
    if self.Interval ~= 0 then        
        local px,py,pz = CAM.GetPos() -- bo przy edycji jest tylko kamera
        if not self._Launched then
            -- ma zawsze odpalic gdy player bedzie pierwszy raz w jego poblizu (sprawdzam co 1 sec)
            self._LaunchCnt = self._LaunchCnt - delta
            if self._LaunchCnt < 0 then
                if self.Pos:Dist(px,py,pz) < self._ActivateDist then
                    self:Play()
                    self._Launched = true
                end
                self._LaunchCnt = 1
            end
        else
            self._IvCnt = self._IvCnt - delta
            if self._IvCnt < 0 then                
                if self.Pos:Dist(px,py,pz) < self.Falloff.End * 1.2 then
                    self:Play()
                    --Game:Print("a "..self._Name.." "..self._IvCnt)
                else
                    self._IvCnt = self.Interval + FRand(-self.RandomShift, self.RandomShift)
                    if self._IvCnt <= 0 then self._IvCnt = 1 end -- protection
                end
            end
        end
    else
        if self._ManualLoop and not SOUND3D.IsPlaying(self._SndPtr) then    
            self:Play()
        end
    end
end
--============================================================================
function CSound:Synchronization()
    SOUND3D.SetPosition(self._SndPtr,self.Pos.X,self.Pos.Y,self.Pos.Z)
end
--============================================================================
function PlaySound3D(sound,x,y,z,range1,range2,noRandomize)
--    if Game.IsServer and LogicSounds[sound] then
--        table.insert(ActiveSounds,{sound,LogicSounds[sound],obj,x,y,z,range1,range2})        
--    end
    if type(sound) == "table" then
        sound = sound[math.random(1,table.getn(sound))]
    end
    return SOUND.Play3D(sound,x,y,z,range1,range2,noRandomize)
end
--============================================================================
function PlaySound2D(sound,volume,sameSpeedInBulletTime,noRandomize)
    if type(sound) == "table" then
        sound = sound[math.random(1,table.getn(sound))]
    end
--    if Game.IsServer and LogicSounds[sound] then
--        table.insert(ActiveSounds,{sound,LogicSounds[sound],obj,x,y,z,range1,range2})
--    end
    return SOUND.Play2D(sound,volume,sameSpeedInBulletTime,noRandomize)
end
--============================================================================
function PlayLogicSound(sound,x,y,z,range1,range2,obj)
	table.insert(ActiveSounds,{sound,LogicSounds[sound],obj,x,y,z,range1,range2, Game.currentTime})
end
--============================================================================
function CSound:EnableAmbients(enable)
    Game:Print("EnableAmbients")
    for i,o in GObjects.Elements do 
        if o._Class == "CSound" then
            o:Play(true)
        end
    end
end
--============================================================================
