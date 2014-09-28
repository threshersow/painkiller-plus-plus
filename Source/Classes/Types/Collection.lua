--====================================================================
-- Array
--====================================================================
Array = 
{
    Elements = {},
    _Class = "Array"
}
--====================================================================
function Array:New()
    return Clone(Array)
end
----------------------------------------------------------------------
function Array:Add(obj)
    table.insert(self.Elements,obj)
    return obj
end
----------------------------------------------------------------------
function Array:Insert(idx,obj)
    table.insert(self.Elements,idx,obj)
    return obj
end
----------------------------------------------------------------------
function Array:E(idx)
    return self.Elements[idx]
end
----------------------------------------------------------------------
function Array:Clear()
    self.Elements = {}
end
----------------------------------------------------------------------
function Array:Count()
    return table.getn(self.Elements) 
end
----------------------------------------------------------------------
function Array:FindByField(field,val)
    local c = 1
    for i,o in self.Elements do 
        if rawget(o,field) == val then return c end
        c = c + 1
    end
    return -1
end
----------------------------------------------------------------------
function MyCompareFunc(e1,e2)
    if rawget(e1,Array.SortField) > rawget(e2,Array.SortField) then return true end
    return false
end
----------------------------------------------------------------------
function Array:SortByField(field)
    Array.SortField = field
    table.sort(self.Elements,MyCompareFunc)
end
----------------------------------------------------------------------
function Array:ExecFunction(func,...)
    for i,o in self.Elements do 
        func(o,arg)
    end
end
--====================================================================
function Array:RemoveByIndex(idx)
    if idx>-1 then
        table.remove(self.Elements,idx)
    end
end
--====================================================================
function Array:IndexOf(obj)
    for i,v in self.Elements do 
        if v == obj then return i end
    end
    return -1
end
--====================================================================
function Array:FastRemove(obj)
    local idx = self:IndexOf(obj)
    if idx > -1 then
        table.remove(self.Elements,idx)
        --self.Elements[idx] = self.Elements[self.Count-1]
        --self.Elements[self.Count-1] = nil
        --table.setn(self.Elements,self.Count)
    end
end
----------------------------------------------------------------------
function Array:GetElementsWithFieldValue(field,value)
    local array = {}
    local cnt = 0
    local i, v = next(self.Elements, nil)
    if type(value) == "string" then
        local l = string.find(value,"*")        
        l = l - 1
        if l < 0 then l = string.len(value) end
        while i do
            if v[field] and string.sub(v[field],1,l) == string.sub(value,1,l) then
                cnt = cnt+1
                array[cnt] = v            
            end
            i, v = next(self.Elements, i)
        end        
    else
        while i do
            if v[field] and v[field]==value then
                cnt = cnt+1
                array[cnt] = v            
            end
            i, v = next(self.Elements, i)
        end
    end
    return array,cnt
end
--====================================================================
function AddObjToTable(tbl,obj)
    for i,v in tbl do 
        if v == obj then return obj end
    end
    table.insert(tbl,obj)
end
--============================================================================
function RemoveObjFromTable(tbl,obj)
    for i,v in tbl do 
        if v == obj then             
            table.remove(tbl,i) 
            return
        end
    end
end
--============================================================================
