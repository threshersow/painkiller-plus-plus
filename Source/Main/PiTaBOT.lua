--
-- PiTaBOT server mod v1.01
--
--    developed by PiTaGoRaS (pitagoras@gmx.net)
--
--    http://pitabot.sourceforge.net
--

PB_smod_version = 1.01

PB_EventType =
{
    [AttackTypes.Shotgun]    = 1,
    [AttackTypes.MiniGun]    = 2,
    [AttackTypes.Grenade]    = 3,
    [AttackTypes.Rocket]     = 4,
	[AttackTypes.Stake]		 = 5,
    [AttackTypes.Painkiller] = 6,
    [AttackTypes.PainkillerRotor] = 7,
	[AttackTypes.Shuriken]   = 8,
    [AttackTypes.Electro]    = 9,
    [AttackTypes.TeleFrag]   = 10,
    [AttackTypes.Rifle]      = 11,
    [AttackTypes.BoltStick]  = 12,
    [AttackTypes.HeaterBomb] = 13,
    [AttackTypes.HitGround]  = 20,
    [AttackTypes.OutOfLevel] = 21,
    [AttackTypes.Suicide]    = 22,
    [AttackTypes.Explosion]  = 23,
    [AttackTypes.Lava]       = 24,
    ["PlayerJoined"] = 30,
    ["PlayerLeft"]   = 31,
    ["SayAll"]       = 32,
    ["NickChange"]   = 33,
    ["TakeArmor"]    = 40,
    ["TakeMega"]     = 41
}


PB_EventsQueue = { "", "", "", "", "", "", "" }

PB_enabled = false



function LoadPiTaBOT()

	if ((Cfg.PiTaBOT == 1) and Game:IsServer()) then

  		CONSOLE.AddMessage("PiTaBOT server mod Loaded\n");

  		PB_enabled = true
    	NET.SetupGameSpyVariable("PiTaBOT", false, PB_smod_version)
       	NET.SetupGameSpyVariable("PB_EventsLog1", true, "")
       	NET.SetupGameSpyVariable("PB_EventsLog2", true, "")

        -- Temp. hack to avoid PiTaBOT v0.67 crashing
    	NET.SetupGameSpyVariable("PB_fix0.67", true, "")
  	else
    	NET.SetupGameSpyVariable("PiTaBOT", false, 0)
  	end

end


function PBLogEvent(player, Type, args)

    local event
    local timestamp = INP.GetTime()

	if (not PB_enabled) or (player == nil) or (not PB_EventType[Type]) then return end

    event = timestamp.."#"..tostring(ClearColorCodes(player)).."#"..tostring(PB_EventType[Type]).."#"

	if (args ~= nil) then
        if (type(args) == "table") then
            for key,value in args do
                if (value ~= nil) then
                    event = event..ClearColorCodes(value).."#"
                end
            end
    	else
            event = event..ClearColorCodes(args)
        end
    end

	InsertIntoEventsQueue(event)

end


function ClearColorCodes(name)

    cleanName = (string.gsub(name, "#[0-9a-fA-F]", ""))
    cleanName = (string.gsub(cleanName, "#", ""))

	return cleanName

end


function PBResetEventsLog()
-- Clear the events at the beginning of each map

    NET.SetGameSpyVariable("PB_EventsLog1", "none")
    NET.SetGameSpyVariable("PB_EventsLog2", "none")

    for key,value in PB_EventsQueue do
        PB_EventsQueue[key] = ""
    end

end


function InsertIntoEventsQueue(newEvent)
-- This is a FIFO type events queue

	local i = 1
	while (i+1 <= table.getn(PB_EventsQueue)) do
		PB_EventsQueue[i] = PB_EventsQueue[i+1]
		i = i + 1
	end

	PB_EventsQueue[i] = newEvent

	ReportInfoToGameSpy()

end


function ReportInfoToGameSpy()

-- We set a max of 126 bytes per gamespy variable (ASE protocol limitation)
-- if the text exceeds this length, the older events aren't sent

    local txt = ""
	local i = table.getn(PB_EventsQueue)

	while ((i > 0) and ((string.len(txt) + string.len(PB_EventsQueue[i])) <= 251)) do
        txt = PB_EventsQueue[i].."\n"..txt
        i = i - 1
    end

    local middle = string.len(txt) / 2

	NET.SetGameSpyVariable("PB_EventsLog1", string.sub(txt, 1, middle))
   	NET.SetGameSpyVariable("PB_EventsLog2", string.sub(txt, middle + 1))

    -- For debugging purposes
	--CONSOLE.AddMessage("PBEvents:\n"..string.gsub(txt, "#", "/").."end\n")

end
