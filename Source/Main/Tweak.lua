--============================================================================
-- Tweak
--============================================================================
Tweak = 
{
    Underwater =
    {
        Gravity = 0.1,
        RaiseLinear = 2.0,
        RaiseAngular = 1.5,
    },
    
    BulletTime = 
    {
        Slowdown    = 1/8,
        FadeInTime  = 0.5,
        FadeMaxTime = 20,
        FadeOutTime = 1,
    },
    
    Glass = 
    {
        ActivationDelay = 1,
        ActivationSpeed = 1,
        NonColliderPerc = 3,
        TimeToDelete = 3,
        TimeToDeleteRnd = 2,
        ExplosionRangeModifier = 0.6,
        MinimalGlassBreakMass = 20.0,
        MinimalGlassBreakSpeed = 7.5,
    },

    PlayerMove =
    {
        QWPhysics = false,
        AbsoluteVerticalVelocityBelowWhichDoubleJumpHappens = -1.0,
        SecondsWhenYouCanBunnyHopAfterLanding = 0.2,
        SecondsWhenYouCanBunnyHopBeforeLanding = 0.2,
        PlayerSpeed = 8.0,
        MaximalBunnyHopSpeed = 15.0,
        BunnyHopAcceleration = 0.3,
        JumpStrength = 1.0,
        StairsUpSpeed = 1.0,
        StairsDownSpeed = 1.0,
        MaximalItemPushMass = 2500.0,
        SlowdownDuringJump = 20.0,
        StrongAirControl = 0.2,
        WeakAirControl = 0.002,
        IceSlideModifier = 0.06,
        IceSlideAngleModifier = 0.5,
        PlayerSpeedIce = 9.0,
        SlopeAngleToSlide = 60.0,
        ShowSpeedmeter = false,
        ComboDelay = 0.00,
        ShockedTime = 0.5,
        ExplosionShockedTime = 0.1,

        UnderwaterSpeed = 5.0,
        SpeedOfDecelerationUnderwater = 0.2,
        NormalizeMovementVectorUnderwater = false,
    },

    MultiPlayerMove =
    {
        PlayerSpeed = 11.0,
        JumpStrength = 0.85,
        BunnyHopAcceleration = 0.062,
        SecondsWhenYouCanBunnyHopAfterLanding = 0.2,
        SecondsWhenYouCanBunnyHopBeforeLanding = 0.2,
        BunnyHopDifficulty = 5.0, -- 1/5 sek to max kara, czyli BHA = 0 (0.2 s)
        MaximalBunnyHopSpeed = 28,
        MinimalTimeBetweenBunnyHops = 0.3,
        AbsoluteVerticalVelocityBelowWhichDoubleJumpHappens = -1.0,
        AccelerationWhenWalking = 2,
        DecelerationWhenWalking = 0.99,
        StairsUpSpeed = 1.0,
        StairsDownSpeed = 1.0,
        MaximalItemPushMass = 2500.0,
        SlowdownDuringJump = 9999.0,
        StrongAirControl = 0.35,
        WeakAirControl = 0.022,
        SlopeAngleToSlide = 60.0,
        ShockedTime = 0.5,
        ExplosionShockedTime = 0.2,
        MinimalExplosionImpulse = 0.5,
        KnockbackMultiplier = 0.005,

        MaxStepHeightWhileInAir = 0.7,
        MaxStepHeight = 0.7,
        PhantomTolerance = 0.1,
        Overbounce = 1.01,
        MaxTimeToZeroCamera = 300, --ms
        MinCameraCatchup = 0.02,
        MaxCameraDiff = 0.5,
        MaxCorrectPosSearchDist = 0.1,

	-- ugly hack for MP Rocket Jump
        AlternateRocketJump = true,
	AlternateRocketJumpOnlyMyRockets = false,
	AlternateRocketJumpWorkAboveThisStrength = 0.0,
    },

    PromodePlayerMove =
    {
        PlayerSpeed = 9.0,
        JumpStrength = 1.16,
        StrafeSpeedModifier = 1.75,
        MinimalFallSpeedToDisableJump = -10.0,
        GroundFriction = 4.0,
        StopSpeedFactor = 0.5,
        GroundFrictionModifierNearFalls = 2.0,
        AirAcceleration = 10.0,
        GroundAcceleration = 20.0,
        AirMaxAccelerationSpeedModifier = 0.15,
        Gravity = 3*9.81,
        DoubleJump = true,
        SecondsYouHaveSameSpeedAfterLanding = 0.0,
        HorizontalSpeedAfterLandingMultiplier = 0.002,
    },

    ActiveMeshesDeactivator =
    {
        HighFrequencyMinimalLinearVelocity = 0.003,	
        HighFrequencyMinimalAngularVelocity = 0.001,
        LowFrequencyMinimalLinearVelocity = 1.0,
        LowFrequencyMinimalAngularVelocity = 1.0,
    },
    
    Multiplayer = 
    {
        PlayerAutorespawnTime = 5,
        RespawnPointBusyTime = 2,
    },

    GlobalData =
    {
        Gravity   = 2*9.81,
        MPGravity = 3*9.81,
        MinimalFallSpeedToDisableJump = -10.0,
	DisableGibs = false,
	GermanVersion = false,
    },
    MonsterCanAttackAnotherMonsterChance = 0.1,
    MonsterMonsterDamageModif = 0.5,    -- ?
    PlayerPlayerDamageModif = 0.5,      -- ?
    ShowBulletsPath = false,

    Gfx =
    {
        DemonFXScale = 4,
        DemonFXBias  = -2.50,
        DetailTextureDistance = 20,
	SkinShaderLODDistance = 20,
    },

    PathfinderColors =
    {
        SelectedR = 0,     SelectedG = 255,   SelectedB = 0,
        ChosenSetR = 255,  ChosenSetG = 0,  ChosenSetB = 0,
        DisabledR = 64,    DisabledG = 64,    DisabledB = 64,
        BorderR = 255,     BorderG = 255,     BorderB = 0,
        SetColor1R = 255,  SetColor1G = 255,  SetColor1B = 255,
        SetColor2R = 0,    SetColor2G = 0,    SetColor2B = 255,
        SetColor3R = 0,    SetColor3G = 255,  SetColor3B = 255,
        SetColor4R = 255,  SetColor4G = 0,    SetColor4B = 255,
        SetColor5R = 255,  SetColor5G = 255,  SetColor5B = 255,
        SetColor6R = 0,    SetColor6G = 0,    SetColor6B = 255,
    },

    HUD =
    {
        CompassUpDownStrength = 64,
        CompassUpDownSpeed = 640,
        ProgressSoundRepeat = 0.2,
        CreditsScrollSpeed = 8,
    },
}
--============================================================================
function Tweak:Apply()
    WORLD.ApplyTweaks()
end
--===============================================
function Tweak:Inherit(self,t,override)
    if not t then return nil end
    local i, v = next(t, nil)
    while i do
        if type(v)=="table" and string.sub(i,1,3) ~= "Obj"  and string.sub(i,1,4) ~= "_Obj" then
            if not self[i] then self[i] = {} end
            self:Inherit(self[i],v,override)
        else
            if override then
                self[i] = v
            else
                if self[i] == nil then
                    self[i] = v
                end
            end
        end
        i, v = next(t, i)
    end
end
--============================================================================
function Tweak:Load()   
--    DoFile("tweak.ini",false)
--    if MyTweak then
--        self:Inherit(Tweak,MyTweak,true)
--    end
    if not Cfg.AllowBunnyhopping then
        Tweak.MultiPlayerMove.BunnyHopAcceleration = 0
    end
    if Cfg.RocketFix then Tweak.MultiPlayerMove.AlternateRocketJump = false end
    self:Apply()       
end
--============================================================================
