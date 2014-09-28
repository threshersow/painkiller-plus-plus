--============================================================================
EFloors = 
{
    SelFloor=-1
}
--============================================================================
function EFloors:Init()
end
--============================================================================
function EFloors:Tick(delta)
    
    -- rect selection - not avaible in floors
    --if (MOUSE.LB() == 3 or MOUSE.RB() == 3) then
    --    if  Editor.IsRect then                
    --        local selectMode = 1
    --        if MOUSE.RB() == 3 then selectMode=0 end
    --        FLOOR.Select(Editor.LMX,Editor.LMY,MX,MY,selectMode)
    --    end
    --end

    if not Editor.ObjEdited and (MOUSE.LB() == 1 or MOUSE.RB() == 1) then        
        local selectMode = 1
        if MOUSE.RB() == 1 then selectMode=0 end
        WPT.SelectFloors(MX,MY,MX,MY,selectMode)
        --self:SelectPoint(lp)
    end

end
--============================================================================
function EFloors:Render()
    --HUD.PrintXY(3,80,"Way Points Editor:"..self.Z)
    --if Editor.SelObj then
    --    HUD.PrintXY(3,100,Editor.SelObj.Pos:Get())        
    --end  
end
--============================================================================
