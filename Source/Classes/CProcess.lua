--============================================================================
-- Process
--============================================================================
CProcess =
{
  Obj = nil,
  ChildProc = nil, -- to bedzie kolekcja (mozliwosc wspolbieznych lub kolejkowanych procesow)
  _Class = "CProcess",
}
Inherit(CProcess,CObject)
--============================================================================
function CProcess:New(...)
    return Clone(getfenv()[self._Class])
end
--============================================================================
--function CProcess:Init()
--end
--============================================================================
--function CProcess:Delete()
--end
--============================================================================
--function CProcess:Synchronize()
--end
--============================================================================
--function CProcess:Is(class)
--    if self._Class == class then return true else return false end
--end
--============================================================================
--function CProcess:Reset()
--end
--============================================================================
function CProcess:ChildProcIs(class)
    if self.ChildProc and self.ChildProc._Class == class then return true else return false end
end
--============================================================================
--function CProcess:Update()
--    if self.ChildProc then self.ChildProc:Update() end
--end
--============================================================================
--function CProcess:Tick(delta)
--    if self.ChildProc then self.ChildProc:Tick(delta) end
--end
--============================================================================
function CProcess:GetMsg(msg,arg)
    if self.ChildProc then self.ChildProc:GetMsg(msg,arg) end
end
--============================================================================
function CProcess:AttachProcess(proc)
    self._PrevChildProc = self.ChildProc
    self.ChildProc = AttachProcess(proc,self.Obj)
end
--============================================================================
function CProcess:SetPrevProcess()
    self.ChildProc = self._PrevChildProc
    self:OnRestore()
end
--============================================================================
function CProcess:OnRestore()
    if self.ChildProc and self.ChildProc.OnRestore then self.ChildProc:OnRestore() end    
end
--============================================================================
function CProcess:Render(delta)
    if self.ChildProc then self.ChildProc:Render(delta) end
end
--============================================================================
function AttachProcess(proc,obj)
    if not proc then return nil end
    local p = proc
    p.Obj = obj
    p:Init()
    obj:Synchronize()
    return p
end
--============================================================================
