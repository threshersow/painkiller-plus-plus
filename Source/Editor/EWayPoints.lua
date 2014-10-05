--============================================================================
EWayPoints = 
{
    Z=0.4,
    OldPoint=-1,
    SelPoint=-1,
    LockPos=Vector:New(0,0,0),
    From=Vector:New(0,0,0),
    To=Vector:New(0,0,0),
    TmpObj = 
    {
        _Name = "point",
        Pos = Vector:New(0,0,0),
    }
}
--============================================================================
function EWayPoints:Init()
end
--============================================================================
function EWayPoints:SelectPoint(lp)
    if self.SelPoint>-1 then self.OldPoint = self.SelPoint end
    if lp > -1 then
        self.LockPos:Set(WPT.GetPos(lp))                
        self.SelPoint = lp
        self.TmpObj.Pos:Set(WPT.GetPos(lp))
        self.TmpObj._Name = "point "..lp
        Editor.SelObj = self.TmpObj
        self.SelPoint = lp
    else
        self.SelPoint = -1
        Editor.SelObj = nil
    end
    
    if self.SelPoint>-1 then 
        self.From:Set(self.To:Get())
        self.To:Set(WPT.GetPos(self.SelPoint))
    end

end
--============================================================================
function EWayPoints:Tick(delta)

    if INP.Key(Keys.LeftCtrl) == 2 then

        if MOUSE.LB() == 1 then
            WPT.FastPickCurrentSet(MX,MY,0.12)
        end

        if MOUSE.RB() == 1 then
            WPT.EnableDisableSet(MX,MY,0.12)
        end

    else
    
        if MOUSE.MB() == 1 and self.SelPoint >-1 then        
            self.SelPoint = WPT.Add()
            local x,y,z = Editor.SelObj.Pos:Get()
            WPT.SetPos(self.SelPoint,x+0.5,y,z)        
        end
    
        -- rect selection
        if (MOUSE.LB() == 3 or MOUSE.RB() == 3) then
            if  Editor.IsRect then                
                local selectMode = 1
                if MOUSE.RB() == 3 then selectMode=0 end
                local lp = WPT.Select(Editor.LMX,Editor.LMY,MX,MY,0,selectMode)
                if lp > -1 then self:SelectPoint(lp) end
            else
                WPT.RecalculateSelected()
            end
        end

        -- pick point 
        if not Editor.ObjEdited and (MOUSE.LB() == 1 or MOUSE.RB() == 1) then        
            local selectMode = 1
            if MOUSE.RB() == 1 then selectMode=0 end
            local lp = WPT.Select(MX,MY,MX,MY,0.12,selectMode)
            self:SelectPoint(lp)
        end

        -- displacing
        if Editor.ObjEdited and self.SelPoint > -1 then        
            local v = Vector:New(Editor.SelObj.Pos:Get())
            v:Sub(self.LockPos:Get())
            WPT.MoveSelected(v:Get())        
            self.LockPos:Set(Editor.SelObj.Pos:Get())
        end
    end
end
--============================================================================
function EWayPoints:Render()
    HUD.PrintXY(3,80,"Way Points Editor:"..self.Z)
    if Editor.SelObj then
		local x,y,z = Editor.SelObj.Pos:Get()
		local posit = " "..x..","..y..","..z
        HUD.PrintXY(3,100,posit)
    end  

    -- chwilowo tutaj poniewaz ma dzialac bez shifta
    if INP.Key(Keys.U) == 1 then
        WPT.UnselectAll()
    end

    --if INP.Key(Keys.F3) == 1 and self.SelPoint>-1 then
    --    local i, o = next(GObjects.elements, nil)
    --    while i do
    --        local x1,y1,z1 = self.To:Get()
    --        o.AI.Task = TPathWalk:New(o,x1,y1,z1)    
    --        o.AI.Task:Init()
    --        i, o = next(GObjects.elements, i)
    --    end        
    --end

end
--============================================================================
function EWayPoints:FindPath()
    if self.EditWayPoints == 0 then return end
    if self.OldPoint < 0 then return end
    local x,y,z = self.From:Get()
    local x1,y1,z1 = self.To:Get()
    WPT.FindPath(-1,x,y,z,x1,y1,z1)    
end
--============================================================================
