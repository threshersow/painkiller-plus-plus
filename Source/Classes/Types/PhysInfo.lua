PhysInfo = 
{
    Type  = -1,
    Scale = -1,

    Collision = 
    {
        Enabled          = false,
        MinVelocity      = -1,
        Interval         = -1,
        IntervalForFixed = -1,
    }

    Mass           = -1,  -- masa
    Restitution    = -1,  -- sprezystosc
    Friction       = -1,  -- tarcie
    LinearDamping  = -1,  -- tlumienie liniowe
    AngularDamping = -1,  -- tlumienie katowe

    --HasRagdoll     = false,
    Traceable         = true,
    MovedByExplosions = true,

    _Entity = nil
}

function PhysInfo:Create(entity)
end

function PhysInfo:SetVelocity(v,av)
end

function PhysInfo:Impulse(i,ai)
end

function PhysInfo:EnableRagdoll(enable)
end

