CAcousticEnv = 
{
    Room = 
    {
      Type       = 0,
      Intensity  = 1,
      SwitchTime = 2, 
    },
    
    Player = 
    {
        Spurs  = true,
        Ground = 0,
    },
    
    _IsAE = true,
    

    s_SubClass = {    
        _boxColor = R3D.RGB(200,150,170),
        SoundsDefinitions = 
        {
            path = "MOVEMENT",
            disablePitch = true, 
                
            -- 0 STONE --------------------------------------------------       
            Stone_L = {
                samples = {"walk-stone-left1", "walk-stone-left2"},
            },
            Stone_R = {
                samples = {"walk-stone-right1", "walk-stone-right2"},
            },
        
            -- 1 DIRT --------------------------------------------------
            Dirt_L = {
                samples = {"walk-dirt-left1", "walk-dirt-left2"},
            },
            Dirt_R = {
                samples = {"walk-dirt-right1", "walk-dirt-right2"},
            },
            
            -- 2 METAL --------------------------------------------------              
            Metal_L = {
                samples = {"walk-metal-left1", "walk-metal-left2"},
            },
            Metal_R = {
                samples = {"walk-metal-right1", "walk-metal-right2"},
            },
            
            -- 3 METAL BIG ----------------------------------------------              
            MetalBig_L = {
                samples = {"walk-metalbig-left1", "walk-metalbig-left2"},
            },
            MetalBig_R = {
                samples = {"walk-metalbig-right1", "walk-metalbig-right2"},
            },
        
            -- 4 WOOD ----------------------------------------------              
            Wood_L = {
                samples = {"walk-wood-left1", "walk-wood-left2"},
            },
            Wood_R = {
                samples = {"walk-wood-right1", "walk-wood-right2"},
            },
            
            -- 5 WOOD FLOOR --------------------------------------------              
            WoodFloor_L = {
                samples = {"walk-woodfloor-left1", "walk-woodfloor-left2"},
            },
            WoodFloor_R = {
                samples = {"walk-woodfloor-right1", "walk-woodfloor-right2"},
            },
        
            -- 6 WOOD BRIDGE --------------------------------------------              
            WoodBridge_L = {
                samples = {"walk-bridgewood-left1", "walk-bridgewood-left2"},
            },
            WoodBridge_R = {
                samples = {"walk-bridgewood-right1", "walk-bridgewood-right2"},
            },
        
            -- 7 SAND --------------------------------------------------              
            Sand_L = {
                samples = {"walk-sand-left1", "walk-sand-left2"},
            },
            Sand_R = {
                samples = {"walk-sand-right1", "walk-sand-right2"},
            },
        
            -- 8 SNOW --------------------------------------------------              
            Snow_L = {
                samples = {"walk-snow-left1", "walk-snow-left2"},
            },
            Snow_R = {
                samples = {"walk-snow-right1", "walk-snow-right2"},
            },
        
            -- 9 WET --------------------------------------------------              
            Wet_L = {
                samples = {"walk-wet-left1", "walk-wet-left2"},
            },
            Wet_R = {
                samples = {"walk-wet-right1", "walk-wet-right2"},
            },
        
            -- 10 WATER --------------------------------------------------              
            Water_L = {
                samples = {"walk-wet-left1", "walk-wet-left2"},
            },
            Water_R = {
                samples = {"walk-wet-right1", "walk-wet-right2"},
            },
        
            -- 11 CLIMB METAL --------------------------------------------------              
            ClimbMetal_L = {
                samples = {"climb-metal-ladder-left1", "climb-metal-ladder-left2"},
            },
            ClimbMetal_R = {
                samples = {"climb-metal-ladder-right1", "climb-metal-ladder-right2"},
            },
        
            -- 12 CLIMB WOOD  --------------------------------------------------              
            ClimbWood_L = {
                samples = {"climb-metal-ladder-left1", "climb-metal-ladder-left2"},
            },
            ClimbWood_R = {
                samples = {"climb-metal-ladder-right1", "climb-metal-ladder-right2"},
            },

            -- 13 METAL SKID  --------------------------------------------------              
            MetalSkid_L = {
                samples = {"walk-metalskid-left1", "walk-metalskid-left2"},
            },
            MetalSkid_R = {
                samples = {"walk-metalskid-right1", "walk-metalskid-right2"},
            },

            -- 14 WET SMALL  --------------------------------------------------              
            WetSmall_L = {
                samples = {"walk-wetsmall-left1", "walk-wetsmall-left2"},
            },
            WetSmall_R = {
                samples = {"walk-wetsmall-right1", "walk-wetsmall-right2"},
            },
            -- 15 PADDLE  --------------------------------------------------              
            Paddle_L = {
                samples = {"walk-paddle-left1", "walk-paddle-left2"},
            },
            Paddle_R = {
                samples = {"walk-paddle-right1", "walk-paddle-right2"},
            },
        }
    },
    _Class = "CAcousticEnv"
}
Inherit(CAcousticEnv,CBox) 

function CAcousticEnv:OnApply()
    for i,p in Acoustics.GroundTypes do
        local i = string.find(p,"|",1,true)
        if i and self.Player.Ground == tonumber(string.sub(p,i+1)) then
            self.Player._GroundName = string.sub(p,1,i-1)
            return
        end
    end
end
