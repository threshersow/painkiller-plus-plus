o.OnInitTemplate = CItem.StdOnInitTemplate

function C4L1_Fireworks_sack:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
	
end

function C4L1_Fireworks_sack:OnRelease()
end

function C4L1_Fireworks_sack:OnDestroy()
    local count = self.Destroy.CustomThrowItemCount
    local x,y,z = ENTITY.GetPosition(self._Entity)
    for i=1,count do
        local name = self.Destroy.CustomThrowItem
        if type(name) == "table" then
            name = name[math.random(1,table.getn(name))]
        end
        local obj = GObjects:Add(TempObjName(),CloneTemplate(name))
        obj.Pos.X = x + FRand(-0.2,0.2)
        obj.Pos.Y = y
        obj.Pos.Z = z + FRand(-0.2,0.2)
        --obj.ObjOwnerRot = Clone(self.Rot)
        obj.Rot = Clone(self.Rot)
        obj:Apply()
        obj:Synchronize()
        obj:BindSound("misc/fireworks-onfly"..math.random(1,4),16,50,false)
    end
end
