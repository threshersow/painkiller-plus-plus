GameStates = {
  WarmUp = 1,
  Counting = 2,
  Playing = 3,
  Finished = 4,
  Paused = 5
}
MPCfg = {
  GameMode = "Free For All",
  GameState = GameStates.Finished,
  TeamDamage = true,
  AllowBrightskins = true,
  FragLimit = 0,
  TimeLimit = 0,
  CaptureLimit = 0,
  LMSLives = 5,
  ClientConsoleLockdown = false,
  ProPlus = false
}
MPGameRules = {
  ["Free For All"] = {
    StartState = GameStates.Counting,
    AutoRespawnAfterCountdown = true,
    Teams = false
  },
  ["Voosh"] = {
    StartState = GameStates.Counting,
    AutoRespawnAfterCountdown = true,
    Teams = false
  },
  ["The Light Bearer"] = {
    StartState = GameStates.Counting,
    AutoRespawnAfterCountdown = true,
    Teams = false
  },
  ["People Can Fly"] = {
    StartState = GameStates.WarmUp,
    AutoRespawnAfterCountdown = true,
    Teams = false
  },
  ["Team Deathmatch"] = {
    StartState = GameStates.WarmUp,
    AutoRespawnAfterCountdown = true,
    Teams = true
  },
  ["Capture The Flag"] = {
    StartState = GameStates.WarmUp,
    AutoRespawnAfterCountdown = true,
    Teams = true
  },
  ["Last Man Standing"] = {
    StartState = GameStates.WarmUp,
    AutoRespawnAfterCountdown = true,
    Teams = false
  },
  ["Duel"] = {
    StartState = GameStates.WarmUp,
    AutoRespawnAfterCountdown = true,
    Teams = false,
    PlayerLimit = 2
  },
  ["Clan Arena"] = {
    StartState = GameStates.WarmUp,
    AutoRespawnAfterCountdown = false,
    ResetStatusAfterCountdown = true,
    Teams = true
  },
  ["Instagib"] = {
    StartState = GameStates.WarmUp,
    AutoRespawnAfterCountdown = true,
    Teams = false
  },
  ["ICTF"] = {
    StartState = GameStates.WarmUp,
    AutoRespawnAfterCountdown = true,
    Teams = true
  }
}
MPCfgBackup = {}

function Game:IsServer()
  if self.GMode == GModes.MultiplayerServer or self.GMode == GModes.DedicatedServer then
    return true
  end
  return false
end

function Game:OnSwitchToState(mode)
  self.GMode = mode
  if mode == GModes.MultiplayerClient then
    self.WaitForServer = true
    WORLD.SetGameVisible(false)
  end
  if mode ~= GModes.SingleGame then
    Game:Print(">> BeforeChangeGameType, preload templates " .. mode)
    self:InitTemplates()
    self._onSwitch = true
    Game:Print(">> BeforeChangeGameType, preload templates end")
    MPCfg.GameMode = "Free For All"
  else
    MPCfg.GameMode = ""
  end
  MPCfg.ClientConsoleLockdown = false
  self.Active = false
end

function Game:BeforeChangeGameType(mode)
  if self.GMode == GModes.DedicatedServer then
    Editor.Enabled = false
  end
end

function Game:AfterChangeGameType()
  if self.GMode ~= GModes.SingleGame then
    GOD = false
    PHYSICS.SetGravity(Tweak.GlobalData.MPGravity)
    if Cfg.AllowBunnyhopping then
      PHYSICS.SetBunnyHopAcceleration(Tweak.MultiPlayerMove.BunnyHopAcceleration)
    else
      PHYSICS.SetBunnyHopAcceleration(0)
    end
    self._emptyServerTime = 0
  else
    PHYSICS.SetBunnyHopAcceleration(Tweak.PlayerMove.BunnyHopAcceleration)
    PHYSICS.SetGravity(Tweak.GlobalData.Gravity)
  end
end

function Game:AfterWorldSynchronization(mapName, levelName)
  Game:Print("AfterWorldSynchronization")
  Game._countTimer = 0
  Game._countTimerStart = nil
  Loc.Position = {}
  Loc:Load(mapName)
  Waypoint.Position = {}
  Waypoint:Load(mapName)
  Game.ClearStats()
  Cfg.ModName = "PK++ 1.2.1.64"
  if linker ~= "versionB.txt ../Data/PKPlusSounds ../Data/Locs PKPlusSounds.pak" then
    MsgBox("Something isn't right here. Exiting.")
    Exit(1)
  end
  MPCfg.TeamLock = false
  if Game:IsServer() then
    local teamsize = 8
    local maxplayers = Cfg.MaxPlayers
    if Cfg.GameMode == "Duel" and not Cfg.ForceSpec then
      maxplayers = 2
    end
    local gameState = "playing"
    if MPCfg.GameState == GameStates.WarmUp then
      gameState = "warmup"
    elseif MPCfg.GameState == GameStates.Counting then
      gameState = "counting"
    elseif MPCfg.GameState == GameStates.Finished then
      gameState = "finished"
    end
    local numPlayers = 0
    local numSpecs = 0
    for id, ps in Game.PlayerStats, nil do
      if ps.Spectator == 0 then
        numPlayers = numPlayers + 1
      else
        numSpecs = numSpecs + 1
      end
    end
    GAMESPY.SetServerInfo(PK_VERSION, Cfg.ServerName, Cfg.ServerPassword, levelName, Cfg.GameMode, maxplayers, Cfg.MaxSpectators, Cfg.FragLimit, Cfg.TimeLimit, Game._TimeLimitOut, gameState, numPlayers, numSpecs)
    if Cfg.AllowBunnyhopping then
      PHYSICS.SetBunnyHopAcceleration(Tweak.MultiPlayerMove.BunnyHopAcceleration)
    else
      PHYSICS.SetBunnyHopAcceleration(0)
    end
    if Cfg.ProPlus then
      Game:EnableProPlus()
    else
      Game:DisableProPlus()
    end
    MPCfg.GameState = MPGameRules[Cfg.GameMode].StartState
    if Cfg.NoWarmup then
      MPCfg.GameState = GameStates.Counting
    end
    Game.SetConfiguration(Cfg.AllowBrightskins, Cfg.GameMode, Cfg.FragLimit, Cfg.CaptureLimit, Cfg.LMSLives, Cfg.TeamDamage, Cfg.ClientConsoleLockdown)
    Game.SetTimeLimit(Cfg.TimeLimit, 0, Cfg.WarmUpTime)
    Game.VooshCurWeapon = math.random(1, 5)
    GAMESPY.SetGameMode(2)
  else
    NET.ClientPingReset()
  end
  if Game.GMode == GModes.MultiplayerServer or Game.GMode == GModes.MultiplayerClient then
    local pn = "Player_" .. NET.GetClientID()
    if Cfg.PlayerName then
      pn = Cfg.PlayerName
    end
    if not NET.IsSpectator(NET.GetClientID()) then
      self.NewPlayerRequest(NET.GetClientID(), pn, Cfg.PlayerModel, Cfg.Team, 0, 0)
    else
      self.NewPlayerRequest(NET.GetClientID(), pn, Cfg.PlayerModel, Cfg.Team, 0, 1)
    end
  end
  self.VooshTick = 0
  Game.WaitForServer = nil
  Game.Active = true
  WORLD.SetGameVisible(true)
  if Cfg and not IsDedicatedServer() then
    INP.SetUseDInput(Cfg.DirectInput)
  end
  INP.Reset()
  MOUSE.Lock()
end

function Game_SetupCustomGameSpyVariables()
  if Cfg.PitabotEnabled then
    LoadPiTaBOT()
  end
end

function Game_InterpretVariable(name, value)
  if Game:IsServer() then
    local pattern = "(%d+),(%w+),([%w%p%s]+)"
    local clientid = string.gsub(value, pattern, "%1")
    local password = string.gsub(value, pattern, "%2")
    local command = string.gsub(value, pattern, "%3")
    if password ~= nil and command ~= nil and Cfg.RconPass ~= nil and Cfg.RconPass ~= "" and name == "rcon" then
      if password == Cfg.RconPass then
        Console:OnCommand("\\" .. command)
        SendNetMethod(Game.ConsoleMessage, tonumber(clientid), true, true, "Rcon command successful.")
      else
        SendNetMethod(Game.ConsoleMessage, tonumber(clientid), true, true, "Rcon password is incorrect. Please set with: rconpass <pass>")
      end
    end
    if command ~= nil and name == "ref" then
      local i = string.find(command, " ", 1, true)
      i = i or string.len(command) + 1
      local cmd = string.sub(command, 1, i - 1)
      local allowed = Game:CheckVotingParams(cmd)
      if allowed and password == Cfg.RefPass or allowed and Game.PlayerStats[tonumber(clientid)].Referee then
        Console:OnCommand("\\" .. command)
        SendNetMethod(Game.ConsoleMessage, tonumber(clientid), true, true, "Ref command successful.")
      elseif password == Cfg.RefPass then
        SendNetMethod(Game.ConsoleMessage, tonumber(clientid), true, true, "Command not allowed")
      elseif password ~= "" then
        SendNetMethod(Game.ConsoleMessage, tonumber(clientid), true, true, "You are not a referee or referee password incorrect")
      else
        SendNetMethod(Game.ConsoleMessage, tonumber(clientid), true, true, "You are not a referee or referee password incorrect")
      end
    end
    if name == "CHATO" then
      for i, ps in Game.PlayerStats, nil do
        if ps.ClientID ~= ServerID then
          NET.SendVariable(ps.ClientID, "CHATOR", value)
          Game._ChatData[tonumber(value)] = {
            ClientID = tonumber(value),
            Check = true
          }
        end
      end
    end
    if name == "CHATC" then
      for i, ps in Game.PlayerStats, nil do
        if ps.ClientID ~= ServerID then
          NET.SendVariable(ps.ClientID, "CHATCR", value)
          Game._ChatData[tonumber(value)] = {
            ClientID = tonumber(value),
            Check = false
          }
        end
      end
    end
    if name == "CLIENTID" then
      Game.ServerCheckModUser = value
    end
  else
    if name == "MOTD" then
      MPCfg.MOTD = tostring(value)
      if not Hud then
        return
      end
      Hud._MOTDTime = INP.GetTime() + 10
    end
    if name == "FGMN" then
      Hud.fname = value
      fragmessagestart = Game.currentTime
      fragmessageend = Game.currentTime + 60
    end
    if name == "HITSND" and Game._procSpec and Game._procSpec ~= nil and Game._procSpec.player ~= nil and Game._procSpec.player >= 0 and tonumber(value) == Game._procSpec.player and Cfg.HitSound then
      if Cfg.Newhitsound == false then
        PlaySound2D("../Sounds/hitsound", nil, nil, true)
      else
        PlaySound2D("../Sounds/hitsoundnew", nil, nil, true)
      end
    end
    if name == "DTHSND" and Game._procSpec and Game._procSpec ~= nil and Game._procSpec.player ~= nil and Game._procSpec.player >= 0 and tonumber(value) == Game._procSpec.player and Cfg.KillSound then
      if Cfg.Newhitsound == false then
        PlaySound2D("../Sounds/killsound", nil, nil, true)
      else
        PlaySound2D("../Sounds/killsoundnew", nil, nil, true)
      end
    end
    if name == "RFX" then
      if value and value == "1" then
        if not MPCfg.RocketFix then
          CONSOLE_AddMessage("#1***Rocketfix has now been enabled on the server***")
        end
        MPCfg.RocketFix = true
        Tweak.MultiPlayerMove.AlternateRocketJump = false
        WORLD.ApplyTweaks()
      end
      if value and value == "0" then
        if MPCfg.RocketFix then
          CONSOLE_AddMessage("#1***Rocketfix has now been disabled on the server***")
        end
        MPCfg.RocketFix = false
        Tweak.MultiPlayerMove.AlternateRocketJump = true
        WORLD.ApplyTweaks()
      end
    end
    if name == "CHATOR" then
      if Game._SomeConsoleOpened == false then
        Game._SomeConsoleOpened = true
      end
      Game.ChatData[tonumber(value)] = {
        ClientID = tonumber(value),
        Check = true
      }
    end
    if name == "CHATCR" then
      Game._ConsoleClientID = tonumber(value)
      Game._SomeConsoleClosed = true
      Game.ChatData[tonumber(value)] = {
        ClientID = tonumber(value),
        Check = false
      }
    end
  end
end

function Game:AfterNewClientConnected(clientID)
  if Game.PlayerStats[clientID] then
    return
  end
  local str = Text2Tab(Game.ServerCheckModUser, ":")
  if (clientID ~= tonumber(str[1]) or clientID == tonumber(str[1])) and str[2] ~= "MOD13" then
    NET.DisconnectClient(clientID)
    return
  end
  if clientID == tonumber(str[1]) and str[2] == "MOD13" then
    Game.ServerCheckModUser = "999:nil"
  end
  SendNetMethod(Game.SetConfiguration, clientID, true, true, Cfg.AllowBrightskins, Cfg.GameMode, Cfg.FragLimit, Cfg.CaptureLimit, Cfg.LMSLives, Cfg.TeamDamage, Cfg.ClientConsoleLockdown)
  SendNetMethod(Game.SetGameState, clientID, true, true, MPCfg.GameState)
  Game:Print("AfterNewClientConnected: " .. clientID)
  for i, o in self.Players, nil do
    if o.ClientID ~= clientID then
      local ps = Game.PlayerStats[o.ClientID]
      if ps then
        local pu_state = 0
        if o.HasQuad then
          pu_state = AddBitFlag(pu_state, 2)
        end
        if o.HasWeaponModifier then
          pu_state = AddBitFlag(pu_state, 4)
        end
        if o.HasFlag then
          pu_state = AddBitFlag(pu_state, 8)
        end
        SendNetMethod(Game.OnNewPlayerInGame, clientID, true, true, o.ClientID, o._Entity, ps.Name, ps.Score, ps.Kills, ps.Deaths, pu_state, INP.GetTime() - ps._starttime, ps.Team, ps.State, ps.Spectator)
      end
    end
  end
  SendNetMethod(Game.SetTimeLimit, clientID, true, true, MPCfg.TimeLimit, Game._TimeLimitOut, Game._countTimer)
  local rest = Cfg.MOTD
  local rest = "PK++ 1.2.1.64 Server - "
  if Cfg.RocketFix then
    rest = rest .. "RocketFix on - "
  else
    rest = rest .. "RocketFix off - "
  end
  if MPCfg.ProPlus then
    rest = rest .. "ProPlus on;"
  else
    rest = rest .. "ProPlus off;"
  end
  rest = rest .. "ServerFPS - " .. tostring(Cfg.ServerFPS) .. ";"
  if Cfg.MOTD ~= nil then
    rest = rest .. Cfg.MOTD
  end
  rest = rest .. "; "
  NET.SendVariable(clientID, "MOTD", rest)
  Game:SendRocketFix()
end

function Game:AfterClientDisconnected(clientID)
  Game:Print("AfterClientDisconnected: " .. tostring(clientID))
  Game.OnPlayerLeaveGame(clientID)
  if Game._voteCmd ~= "" then
    Game.PlayerVoteRequest(clientID, 0)
  end
  if MPCfg.GameState == GameStates.Playing then
    CPlayer:Common_UpdateStats(true, -1, -1, 0, 0)
  end
end

function Game:SyncCounter(sec)
  Game._countTimer = sec
  local s = math.floor(sec) + 1
  if 2 <= s and s <= 4 then
    SOUND.Play2D(string.format("multiplayer/lucifer/Lucifer_time%02d", s - 1), 100, true, true)
  end
  if 4 <= s and s <= 11 then
    SOUND.Play2D("multiplayer/clock-tick", 100, true, true)
  end
end

Network:RegisterMethod("Game.SyncCounter", NCallOn.AllClients, NMode.Unreliable, "f")
Game.PingTick = 0
Game.VooshTick = 0
Game.VooshCurWeapon = 0
Game.LastGameSpyReport = 0
Game.LastLongCheck = 0
Game.LastLongerCheck = 0

function Game:OnMultiplayerServerTick(delta)
  if MPCfg.GameState == GameStates.WarmUp then
    Game._team1Score = 0
    Game._team2Score = 0
    MPSTATS.SetTeamsScore(0, 0)
  end
  if MPCfg.GameState == GameStates.Counting then
    Game._team1Score = 0
    Game._team2Score = 0
    MPSTATS.SetTeamsScore(0, 0)
  end
  Game:BotTick(delta)
  if Cfg.DuelQueue and Game.DuelQueueTime then
    Game.DuelQueueTime = Game.DuelQueueTime - delta
    if Game.DuelQueuePlayer1JoinTime then
      Game.DuelQueuePlayer1JoinTime = Game.DuelQueuePlayer1JoinTime - delta
      if 0 >= Game.DuelQueuePlayer1JoinTime then
        if Game.DuelQueuePlayer1 then
          Console:Cmd_FORCEJOIN(Game.DuelQueuePlayer1)
        end
        Game.DuelQueuePlayer1JoinTime = nil
        Game.DuelQueuePlayer1 = nil
      end
    end
    if Game.DuelQueuePlayer2JoinTime then
      Game.DuelQueuePlayer2JoinTime = Game.DuelQueuePlayer2JoinTime - delta
      if 0 >= Game.DuelQueuePlayer2JoinTime then
        if Game.DuelQueuePlayer2 then
          Console:Cmd_FORCEJOIN(Game.DuelQueuePlayer2)
        end
        Game.DuelQueuePlayer2JoinTime = nil
        Game.DuelQueuePlayer2 = nil
      end
    end
    if 0 >= Game.DuelQueueTime then
      Game.DuelQueueTime = nil
      Game.DuelQueuePlayer1 = nil
      Game.DuelQueuePlayer2 = nil
    end
  end
  if MPCfg.GameState == GameStates.Counting then
    Game:ClearStats()
    if not self._countTimerLast then
      self._countTimerLast = INP.GetTime()
    end
    local tm = INP.GetTime()
    self._countTimer = self._countTimer - (tm - self._countTimerLast)
    self._countTimerLast = tm
    local s = math.floor(self._countTimer) + 1
    if s and self._countTimerInt ~= s then
      Game.SyncCounter(self._countTimer)
      self._countTimerInt = s
    end
    if s < 2 and Cfg.AutoTeamLock then
      MPCfg.TeamLock = true
    end
  else
    self._countTimerLast = nil
  end
  if MPCfg.GameState ~= GameStates.Finished then
    if MPCfg.GameMode == "Voosh" then
      self.VooshTick = self.VooshTick + delta
      if not Game._bimSound and self.VooshTick >= 23 then
        Game.BimBam()
        Game._bimSound = true
      end
      if self.VooshTick >= 25 then
        Game._bimSound = nil
        self.VooshTick = 0
        local w = Game.VooshCurWeapon
        while w == Game.VooshCurWeapon do
          Game.VooshCurWeapon = math.random(1, 5)
        end
        for i, o in self.Players, nil do
          if not o._died then
            CPlayer.WeaponChangeConfirmation(o.ClientID, o._Entity, Game.VooshCurWeapon)
          end
        end
      end
    end
    if MPCfg.GameState == GameStates.Counting and 0 >= self._countTimer then
      for i, ps in Game.PlayerStats, nil do
        ps.Score = 0
        ps.Kills = 0
        ps.Deaths = 0
        MPSTATS.Update(ps.ClientID, ps.Name, ps.Score, ps.Kills, ps.Deaths, ps.Ping, ps.PacketLoss, ps.Team, ps.State, ps.Spectator)
        Game.NewPlayerTeamConfirmation(ps.ClientID, ps.Team)
      end
      Game.ConsoleMessageAll("Match Started.")
      Game.SetGameState(GameStates.Playing)
      if MPGameRules[MPCfg.GameMode].AutoRespawnAfterCountdown then
        local items = GObjects:GetAllObjectsByClass("CItem")
        for i, o in items, nil do
          if o.TimeToLive and 0 < o.TimeToLive then
            o.TimeToLive = 0
          end
        end
        for i, o in items, nil do
          o:TryToRespawn(true)
        end
        for i, o in GObjects.Elements, nil do
          if o._mpWarmUp then
            GObjects:ToKill(o)
          end
        end
        WORLD.DeleteDyingEntities()
        for i, o in Game.PlayerStats, nil do
          if o.Spectator == 0 then
            Game.ResetPlayer(o.ClientID)
          end
        end
        for i, o in Game.PlayerStats, nil do
          if o.Spectator == 0 then
            Game.PlayerRespawnRequest(o.ClientID)
          end
        end
      end
      if MPCfg.GameMode == "Clan Arena" and MPGameRules[MPCfg.GameMode].ResetStatusAfterCountdown then
        local weapon = 3
        if 0 < Cfg.StartupWeapon and Cfg.StartupWeapon <= 7 then
          weapon = Cfg.StartupWeapon
        end
        for i, o in Game.PlayerStats, nil do
          if o.Spectator == 0 then
            Game.PlayerRespawnConfirmation(o.ClientID, nil, nil, weapon)
          end
        end
      end
      Game._countTimerInt = nil
    end
  end
  self.PingTick = self.PingTick + delta
  local pc = table.getn(self.Players)
  if 0 < pc then
    if 2 <= self.PingTick then
      local j = 1
      local marg = {}
      for i, o in self.Players, nil do
        marg[j] = o.ClientID
        marg[j + 1] = NET.GetClientPing(o.ClientID)
        if Cfg.BotFakePing then
          if Game.PlayerStats[o.ClientID] ~= nil and Game.PlayerStats[o.ClientID].Bot ~= nil then
            marg[j + 1] = math.floor(math.random(10) + 30)
          end
        elseif Game.PlayerStats[o.ClientID] ~= nil and Game.PlayerStats[o.ClientID].Bot ~= nil then
          marg[j + 1] = 0
        end
        if marg[j + 1] > 255 then
          marg[j + 1] = 255
        end
        marg[j + 2] = NET.GetClientPacketLoss(o.ClientID)
        if marg[j + 2] > 255 then
          marg[j + 2] = 255
        end
        j = j + 3
      end
      self.PlayerPingInfo(table.getn(self.Players), unpack(marg))
      self.PingTick = 0
    end
    self._emptyServerTime = -1
  elseif self._emptyServerTime == -1 then
    self._emptyServerTime = INP.GetTime()
  elseif 0 < self._emptyServerTime and 30 < INP.GetTime() - self._emptyServerTime then
    Game_RestoreServerSettings()
    self._emptyServerTime = 0
  end
  if 5 <= INP.GetTime() - self.LastLongCheck then
    if MPCfg.GameState == GameStates.WarmUp then
      for jk, ps in Game.PlayerStats, nil do
        if ps.Bot and ps.State ~= 1 then
          Game.SetStateRequest(ps.ClientID, 1)
        end
      end
    end
    if 0 < Game._voteTimeLeft and Game._voteCmd ~= "" then
      local botvotes = 0
      local nobots = true
      for jk, ps in Game.PlayerStats, nil do
        if ps.Bot then
          botvotes = botvotes + 1
          Game.PlayerVoteRequest(ps.ClientID, 1)
          nobots = false
        end
      end
      if nobots then
        Game.PlayerVoteRequest(ServerID, botvotes)
        Game:CheckVotingStatus()
      end
    end
    if Cfg.ImpureClientWarning and IsDedicatedServer() then
      for jk, ps in Game.PlayerStats, nil do
        if not ps.Version and ps.Checked and not ps.Bot then
          Game.ConsoleMessageAll(ps.Name .. " is running old/non-pure PK++.")
        end
        if not ps.Version and not ps.Checked and not ps.Bot then
          ps.Checked = true
        end
      end
    end
    self:CheckBotCount()
    if MPCfg.GameState == GameStates.WarmUp or MPCfg.GameState == GameStates.Playing then
      for jk, ps in Game.PlayerStats, nil do
        for i, o in Game.Players, nil do
          if o.ClientID == ps.ClientID then
          end
        end
      end
    end
    self.LastLongCheck = INP.GetTime()
  end
  if INP.GetTime() - self.LastLongerCheck >= 20 then
    Game:Server2ClientCommand(0, "pollall")
    if Cfg.ProPlus then
      Game:EnableProPlus()
    else
      Game:DisableProPlus()
    end
    self.LastLongerCheck = INP.GetTime()
    Game:SendRocketFix()
  end
  if 1 <= INP.GetTime() - self.LastGameSpyReport then
    local maxplayers = Cfg.MaxPlayers
    if Cfg.GameMode == "Duel" and not Cfg.ForceSpec then
      maxplayers = 2
    end
    local gameState = "playing"
    if MPCfg.GameState == GameStates.WarmUp then
      gameState = "warmup"
    elseif MPCfg.GameState == GameStates.Counting then
      gameState = "counting"
    elseif MPCfg.GameState == GameStates.Finished then
      gameState = "finished"
    end
    local numPlayers = 0
    local numSpecs = 0
    for id, ps in Game.PlayerStats, nil do
      if ps.Spectator == 0 then
        numPlayers = numPlayers + 1
      else
        numSpecs = numSpecs + 1
      end
    end
    GAMESPY.SetServerInfo(PK_VERSION, Cfg.ServerName, Cfg.ServerPassword, Lev._Name, Cfg.GameMode, maxplayers, Cfg.MaxSpectators, Cfg.FragLimit, Cfg.TimeLimit, self._TimeLimitOut, gameState, numPlayers, numSpecs)
    Game:GameSpy_UpdatePlayers()
    self.LastGameSpyReport = INP.GetTime()
    for j, pks in Game.PlayerStats, nil do
      if Cfg.BotQuickRespawn and pks and pks.Bot and pks._Entity == nil and (MPCfg.GameState == GameStates.WarmUp or MPCfg.GameState == GameStates.Playing) then
        for j, pkds in Game.Players, nil do
          if pks and pkds and pks.ClientID == pkds.ClientID and pkds._timeToRespawn and 1 < pkds._timeToRespawn then
            pkds._timeToRespawn = 1
          end
        end
      end
    end
  end
  self:UpdateSpecs()
  if MPCfg.GameState == GameStates.Paused then
    Game:Timeout()
  end
end

function Game:BimBam()
  SOUND.Play2D("multiplayer/voosh_weapon_change", 100, true, true)
end

Network:RegisterMethod("Game.BimBam", NCallOn.AllClients, NMode.Unreliable, "")

function Game:OnMultiplayerClientTick(delta)
  if MPCfg.GameState == GameStates.WarmUp then
    Game:AutoRecordStop()
    Game._team1Score = 0
    Game._team2Score = 0
    MPSTATS.SetTeamsScore(0, 0)
  end
  if MPCfg.GameState == GameStates.Counting then
    Game:AutoRecordStart()
    Game:ClearStats()
    Game._team1Score = 0
    Game._team2Score = 0
    MPSTATS.SetTeamsScore(0, 0)
  end
  if not (INP.UIAction(UIActions.Scoreboard) and Game._procStats) or MPCfg.GameState ~= GameStates.Finished then
  end
  if not self._procStats then
    if MPCfg.GameState == GameStates.WarmUp then
      if INP.UIAction(UIActions.Scoreboard) then
        local t
        if MPGameRules[MPCfg.GameMode].StartState == GameStates.WarmUp then
          t = 2
        end
        Game._procStats = GObjects:Add(TempObjName(), Templates["EndOfMatch.CProcess"]:New(t))
        INP.RemoveUIAction(UIActions.Scoreboard)
      end
    elseif INP.UIAction(UIActions.Scoreboard) then
      MPSTATS.Show()
    else
      MPSTATS.Hide()
    end
  elseif INP.UIAction(UIActions.Scoreboard) and (MPCfg.GameState == GameStates.WarmUp or MPCfg.GameState == GameStates.Counting and MPGameRules[MPCfg.GameMode].StartState == GameStates.WarmUp) then
    GObjects:ToKill(Game._procStats)
    Game._procStats = nil
    Hud.Enabled = true
    MPSTATS.Hide()
    INP.RemoveUIAction(UIActions.Scoreboard)
  end
  if Game.LevelStarted == true then
    Game:ChatIcon()
    PressedKey()
  end
end

function Game:OnMultiplayerCommonTick(delta)
  if MPCfg.GameState ~= GameStates.Playing then
    return
  end
  if MPCfg.TimeLimit > 0 and 0 <= self._TimeLimitOut and MPCfg.GameState ~= GameStates.Finished then
    local tm = INP.GetTime()
    self._TimeLimitOut = self._TimeLimitOut + (tm - self._LastTime)
    self._LastTime = tm
    if self._TimeLimitOut >= MPCfg.TimeLimit * 60 then
      Game:CheckOvertime()
      if not (self._TimeLimitOut > MPCfg.TimeLimit * 60) then
        return
      end
      if Game:IsServer() then
        StringToDo = "Game.EndOfMatch()"
      end
      MPSTATS.SetTimeLeft("00:00")
      SOUND.Play2D("multiplayer/clock-bell-bigger", 100, true, true)
      self._TimeLimitOut = -1
    else
      local tm = (MPCfg.TimeLimit * 60 - self._TimeLimitOut) / 60
      local m = math.floor(tm)
      local s = math.floor((tm - m) * 60)
      MPSTATS.SetTimeLeft(m .. ":" .. string.format("%02d", s))
      if self._lasts and self._lasts ~= s then
        if m == 0 and s <= 10 then
          if math.mod(s, 2) == 0 then
            SOUND.Play2D("multiplayer/clock-tick", 100, true, true)
          else
            SOUND.Play2D("multiplayer/clock-tock", 100, true, true)
          end
          if s == 10 or s == 6 or s == 2 then
            SOUND.Play2D("multiplayer/clock-bell-bigger", 100, true, true)
          end
          if s == 8 or s == 4 or s == 0 then
            SOUND.Play2D("multiplayer/clock-bell", 100, true, true)
          end
        elseif s == 0 then
          SOUND.Play2D("multiplayer/clock-tick", 100, true, true)
          CONSOLE_AddMessage(Languages.Texts[393] .. ": " .. m .. " " .. Languages.Texts[729])
          if 1 <= m and m <= 10 then
            SOUND.Play2D(string.format("multiplayer/lucifer/Lucifer_time%02d", m), 100, true, true)
          elseif m == 15 then
            SOUND.Play2D("multiplayer/lucifer/Lucifer_time15", 100, true, true)
          elseif m == 20 then
            SOUND.Play2D("multiplayer/lucifer/Lucifer_time20", 100, true, true)
          elseif m == 25 then
            SOUND.Play2D("multiplayer/lucifer/Lucifer_time25", 100, true, true)
          elseif not Cfg.NoGong then
            SOUND.Play2D("multiplayer/clock-bell-bigger", 100, true, true)
          end
        end
      end
      self._lasts = s
    end
  end
end

function Game:NewPlayerRequest(clientID, name, model, team, state, spectator)
  local str = Text2Tab(Game.ServerCheckModUser, ":")
  if clientID == tonumber(str[1]) and str[2] == "MOD13" then
    Game.ServerCheckModUser = "999:nil"
  end
  if spectator == nil then
    spectator = 0
  end
  Game:Print("NewPlayerRequest")
  if MPCfg.GameMode == "Last Man Standing" and (MPCfg.GameState == GameStates.Playing or MPCfg.GameState == GameStates.Finished) then
    spectator = 1
  end
  if MPCfg.GameMode == "Clan Arena" and (MPCfg.GameState == GameStates.Playing or MPCfg.GameState == GameStates.Finished or MPCfg.GameState == GameStates.Counting) then
    spectator = 1
  end
  Game.OnNewPlayerInGame(clientID, nil, name, 0, 0, 0, AddBitFlag(0, 1), 0, team, state, spectator, Game._team1Score, Game._team2Score)
  if MPCfg.GameState == GameStates.Finished then
    SendNetMethod(Game.EndOfMatch, clientID, true, true)
  end
  Game.PlayerStats[clientID].Model = MPModels[model]
  local txt = "Please install PK++ www.pkeuro.com"
  SendNetMethod(Game.ConsoleClientMessage, clientID, true, true, ServerID, txt, 0)
  if MPCfg.ProPlus then
    Game:Server2ClientCommand(0, "enableproplusall")
  else
    Game:Server2ClientCommand(0, "disenableproplusall")
  end
  Game:SendRocketFix()
  local playercount = 0
  for i, ps in Game.PlayerStats, nil do
    if ps.Spectator == 0 then
      playercount = playercount + 1
    end
  end
  if (not (Cfg.GameMode == "Duel" and Cfg.ForceSpec) or playercount ~= 2 or spectator ~= 0) and Cfg.ForceSpec and Game.NewComers[clientID] == nil and spectator == 0 and MPCfg.GameState == GameStates.Playing and (Cfg.GameMode == "Duel" or Cfg.GameMode == "Team Deathmatch" and Game.bot[clientID] == nil) then
    Game.PlayerSpectatorRequest(clientID, 1)
    spectator = 1
    Game.NewComers[clientID] = 1
  end
  if Cfg.GameMode == "Duel" and Cfg.ForceSpec and 2 < playercount and spectator == 0 then
    Game.PlayerSpectatorRequest(clientID, 1)
    spectator = 1
    Game.NewComers[clientID] = 1
  end
  if Game.DuelQueueTime then
    if clientID ~= Game.DuelQueuePlayer1 and clientID ~= Game.DuelQueuePlayer2 then
      Game.PlayerSpectatorRequest(clientID, 1)
      spectator = 1
      Game.NewComers[clientID] = 1
    end
    if clientID == Game.DuelQueuePlayer1 then
      Game.PlayerSpectatorRequest(clientID, 0)
      Game.NewComers[clientID] = 1
    end
    if clientID == Game.DuelQueuePlayer2 then
      Game.PlayerSpectatorRequest(clientID, 0)
      Game.NewComers[clientID] = 1
    end
  end
  if (MPCfg.GameState == GameStates.WarmUp or MPCfg.GameState == GameStates.Playing) and spectator == 0 then
    for i, o in Game._ChatData, nil do
      if Game.PlayerStats[o.ClientID] ~= nil and Game._ChatData[o.ClientID].Check then
        NET.SendVariable(clientID, "CHATOR", o.ClientID)
      end
    end
    Game.PlayerRespawnRequest(clientID)
  end
end

Network:RegisterMethod("Game.NewPlayerRequest", NCallOn.Server, NMode.Reliable, "bsbbbb")

function Game:OnNewPlayerInGame(clientID, entity, name, score, kills, deaths, pu_state, playtime, team, state, spectator, t1score, t2score)
  Game:Print("OnNewPlayerInGame: " .. clientID)
  local player
  if spectator == 0 then
    if Game:IsServer() or clientID == NET.GetClientID() then
      player = Game:AddPlayer(nil, name, "player")
      player:ResetStatus()
      player.ClientID = clientID
      player._died = true
      player.Team = team
    end
    if clientID == NET.GetClientID() then
      GObjects:ToKill(Game._procSpec)
      Game._procSpec = nil
    end
  elseif clientID == NET.GetClientID() then
    Game._procSpec = GObjects:Add(TempObjName(), Templates["PSpectatorControler.CProcess"]:New())
    Game._procSpec:Init()
    if Game._procStats then
      GObjects:ToKill(Game._procStats)
      Game._procStats = nil
    end
  end
  NET.SetSpectator(clientID, spectator)
  Game.PlayerStats[clientID] = {
    ClientID = clientID,
    Name = name,
    Score = score,
    Kills = kills,
    Deaths = deaths,
    Ping = 0,
    PacketLoss = 0,
    Team = team,
    State = state,
    Spectator = spectator
  }
  local ps = Game.PlayerStats[clientID]
  MPSTATS.Update(ps.ClientID, ps.Name, ps.Score, ps.Kills, ps.Deaths, ps.Ping, ps.PacketLoss, ps.Team, ps.State, ps.Spectator)
  ps._Entity = entity
  ps.Player = player
  ps._respawned = false
  MPSTATS.SetPlayerGameTime(ps.ClientID, playtime)
  ps._starttime = INP.GetTime()
  if spectator == 0 then
    if Game.GMode ~= GModes.DedicatedServer then
      local p = GObjects:Add(TempObjName(), Templates["PPlayerAnimation.CProcess"]:New(nil, clientID))
      ps._animproc = p
      ps._animproc._Entity = entity
    end
    if clientID == NET.GetClientID() then
      Player = player
      Player._Entity = entity
      MOUSE.Lock(true)
      local t
      if MPGameRules[MPCfg.GameMode].StartState == GameStates.WarmUp then
        t = 2
      end
      Game._procStats = GObjects:Add(TempObjName(), Templates["EndOfMatch.CProcess"]:New(t))
    else
      ENTITY.PO_SetFriction(entity, 0.7)
      ENTITY.EnableDraw(entity, true)
      MDL.SetAnim(entity, "idle", true)
      MDL.SetMeshVisibility(entity, "rl", false)
      if IsBitFlag(pu_state, 1) then
        local txt = string.gsub(TXT.Multiplayer.PlayerJoined, "$PLAYER", Game.PlayerStats[clientID].Name)
        CONSOLE_AddMessage(txt)
        if Cfg.PitabotEnabled then
          PBLogEvent(Game.PlayerStats[clientID].Name, "PlayerJoined", nil)
        end
        SOUND.Play2D("multiplayer/newplayerjoinedserver")
      end
    end
    Game:BrightSkin(entity, true, team)
    Game._team1Score = t1score
    Game._team2Score = t2score
    MPSTATS.SetTeamsScore(t1score, t2score)
  end
  if IsBitFlag(pu_state, 2) then
    RawCallMethod(Templates["Quad.CItem"].TakeFX, entity, 0)
  end
  if IsBitFlag(pu_state, 4) then
    RawCallMethod(Templates["WeaponModifier.CItem"].TakeFX, entity, 0)
  end
  if IsBitFlag(pu_state, 8) then
    RawCallMethod(Templates["Flag.CItem"].TakeFX, entity, 0)
  end
  Game:GameSpy_UpdatePlayers()
  Game:CheckWarmUpStatus()
end

Network:RegisterMethod("Game.OnNewPlayerInGame", NCallOn.ServerAndAllClients, NMode.Reliable, "besiuubfbbbii")

function Game:ResetPlayer(clientID)
  local player = Game:FindPlayerByClientID(clientID)
  if player then
    player:FreeBlockedObjects()
    player:ResetStatusAfterDeath()
    if Game:IsServer() then
      ENTITY.Release(player._Entity)
    end
    player._Entity = nil
  end
  local ps = Game.PlayerStats[clientID]
  if ps then
    if ps._animproc then
      ps._animproc:Reset()
    end
    if ps._Entity then
      EntityToObject[ps._Entity] = nil
      ps._Entity = nil
    end
  end
end

Network:RegisterMethod("Game.ResetPlayer", NCallOn.ServerAndAllClients, NMode.Reliable, "b")

function Game:SetTimeLimit(timelimit, timeout, counter)
  MPCfg.TimeLimit = timelimit
  Game._TimeLimitOut = timeout
  if MPCfg.TimeLimit > 0 then
    MPSTATS.SetTimeLeft(MPCfg.TimeLimit)
  else
    MPSTATS.SetTimeLeft(0)
  end
  Game._countTimer = counter
  Game._LastTime = INP.GetTime()
end

Network:RegisterMethod("Game.SetTimeLimit", NCallOn.ServerAndAllClients, NMode.Reliable, "fff")

function Game:OnPlayerLeaveGame(clientID)
  Game:Print("OnPlayerLeaveGame: " .. clientID)
  if Game:IsServer() and Game._ChatData[clientID] then
    Game._ChatData[clientID] = nil
  end
  if not Game:IsServer() and Game.ChatData[clientID] then
    Game.ChatData[clientID] = nil
  end
  for i, o in Game.Players, nil do
    if o.ClientID == clientID then
      if Game:IsServer() then
        ENTITY.Release(o._Entity)
      end
      GObjects:ToKill(o)
      table.remove(Game.Players, i)
      if o == Player then
        Player = nil
      end
      if o == Game._spectatorRecordingPlayer then
        Game._spectatorRecordingPlayer = nil
      end
      break
    end
  end
  local ps = Game.PlayerStats[clientID]
  if not ps then
    return
  end
  local txt = string.gsub(TXT.Multiplayer.PlayerLeft, "$PLAYER", ps.Name)
  CONSOLE_AddMessage(txt)
  if Cfg.PitabotEnabled then
    PBLogEvent(ps.Name, "PlayerLeft", nil)
  end
  local pcs = GObjects:GetElementsWithFieldValue("_Class", "CProcess*")
  for i, p in pcs, nil do
    if p.ClientID == clientID then
      GObjects:ToKill(p)
    end
  end
  if ps._Entity then
    EntityToObject[ps._Entity] = nil
  end
  MPSTATS.RemovePlayer(clientID)
  Game.PlayerStats[clientID] = nil
  SOUND.Play2D("hero/hero_gib3")
  Game:GameSpy_UpdatePlayers()
  Game:CheckWarmUpStatus()
end

Network:RegisterMethod("Game.OnPlayerLeaveGame", NCallOn.ServerAndAllClients, NMode.Reliable, "b")

function Game:PlayerKill(clientID)
  local player = Game:FindPlayerByClientID(clientID)
  if player then
    player:OnDamage(999999, nil, AttackTypes.ConsoleKill)
  end
end

Network:RegisterMethod("Game.PlayerKill", NCallOn.Server, NMode.Reliable, "b")

function Game:PlayerSpectatorRequest(clientID, spectator)
  local errormessage = "Server can't change client mode [spectator<->player]"
  if MPCfg.GameState == GameStates.Finished then
    return
  end
  local ps = Game.PlayerStats[clientID]
  if ps and ps.Spectator == spectator then
    return
  end
  local can = NET.CanConnectNewClient(spectator)
  if MPCfg.GameMode == "Last Man Standing" and (MPCfg.GameState == GameStates.Playing or MPCfg.GameState == GameStates.Finished) then
    can = true
  end
  if MPCfg.GameMode == "Clan Arena" and (MPCfg.GameState == GameStates.Playing or MPCfg.GameState == GameStates.Finished) and spectator == 1 then
    can = true
  elseif MPCfg.GameMode == "Clan Arena" and (MPCfg.GameState == GameStates.Playing or MPCfg.GameState == GameStates.Finished) and spectator == 0 then
    can = false
  end
  if MPCfg.TeamLock and spectator == 0 and (MPCfg.GameState == GameStates.Playing or MPCfg.GameState == GameStates.Finished) then
    can = false
    errormessage = "A game is in progress. Cannot join game."
  end
  local playercount = 0
  for i, ps in Game.PlayerStats, nil do
    if ps.Spectator == 0 then
      playercount = playercount + 1
    end
  end
  if Cfg.GameMode == "Duel" and 2 <= playercount and spectator == 0 then
    can = false
    errormessage = "Duel player slots are full."
  end
  if can then
    Game:AfterClientDisconnected(clientID)
    Game.PlayerSpectatorConfirmation(clientID, spectator)
  else
    SendNetMethod(Game.ConsoleMessage, clientID, true, true, errormessage)
  end
  if not (can and ps) or ps.Bot then
  end
end

Network:RegisterMethod("Game.PlayerSpectatorRequest", NCallOn.Server, NMode.Reliable, "bb")

function Game:PlayerSpectatorConfirmation(spectator)
  Game.NewPlayerRequest(NET.GetClientID(), Cfg.PlayerName, Cfg.PlayerModel, Cfg.Team, 0, spectator)
end

Network:RegisterMethod("Game.PlayerSpectatorConfirmation", NCallOn.SingleClient, NMode.Reliable, "b")

function Game:PlayerRespawnRequest(clientID)
  if MPCfg.GameState ~= GameStates.Playing and MPCfg.GameState ~= GameStates.WarmUp and MPCfg.GameState ~= GameStates.Counting then
    return
  end
  local player = Game:FindPlayerByClientID(clientID)
  if player and not player._Entity then
    Game:Print("PlayerRespawnRequest: " .. clientID)
    player._timeToRespawn = -1
    local exist, x, y, z, a, pt = player:FindFreeRespawnPoint(player._lastRespawnPoint)
    if not exist then
      return
    end
    player._lastRespawnPoint = pt
    local model = Game.PlayerStats[clientID].Model
    if Cfg.ForceModel then
      if MPGameRules[MPCfg.GameMode].Teams and Cfg.ForceModel_Teams then
        if Game.PlayerStats[clientID].Team == 0 then
          model = MPModels[2]
        else
          model = MPModels[1]
        end
      else
        model = MPModels[Cfg.PlayerModel]
      end
    end
    player._Entity = CreatePlayer(model, true)
    ENTITY.SetSynchroString(player._Entity, "CPlayer")
    ENTITY.EnableDeathZoneTest(player._Entity, true)
    ENTITY.PO_SetMovedByExplosions(player._Entity, true)
    ENTITY.EnableNetworkSynchronization(player._Entity, true, false, 0, clientID, 3)
    player:Respawn(x, y, z, a)
    local weapon = 3
    if 0 < Cfg.StartupWeapon and Cfg.StartupWeapon <= 7 then
      weapon = Cfg.StartupWeapon
    end
    if MPCfg.GameMode == "Voosh" then
      weapon = Game.VooshCurWeapon
    end
    if MPCfg.GameMode == "People Can Fly" then
      weapon = 4
    end
    Game.PlayerRespawnConfirmation(clientID, player._Entity, ENTITY.GetOrientation(player._Entity), weapon)
    if not MPCfg.ProPlus then
      player:CheckTeleFrag()
    end
    SendNetMethod(Game.SetTimeLimit, clientID, true, true, MPCfg.TimeLimit, Game._TimeLimitOut)
  end
end

Network:RegisterMethod("Game.PlayerRespawnRequest", NCallOn.Server, NMode.Reliable, "b")

function Game:NewPlayerNameRequest(clientID, name)
  Game.NewPlayerNameConfirmation(clientID, name)
end

Network:RegisterMethod("Game.NewPlayerNameRequest", NCallOn.Server, NMode.Reliable, "bs")

function Game:NewPlayerNameConfirmation(clientID, name)
  local ps = Game.PlayerStats[clientID]
  if ps then
    CONSOLE_AddMessage(ps.Name .. " is now " .. name .. ".")
    if Cfg.PitabotEnabled and ps.Name ~= name then
      PBLogEvent(ps.Name, "NickChange", name)
    end
    ps.Name = name
    MPSTATS.Update(ps.ClientID, ps.Name, ps.Score, ps.Kills, ps.Deaths, ps.Ping, ps.PacketLoss, ps.Team, ps.State, ps.Spectator)
  end
end

Network:RegisterMethod("Game.NewPlayerNameConfirmation", NCallOn.ServerAndAllClients, NMode.Reliable, "bs")

function Game:NewPlayerTeamRequest(clientID, team)
  if MPGameRules[MPCfg.GameMode].Teams then
    Game.NewPlayerTeamConfirmation(clientID, team)
    local ps = Game.PlayerStats[clientID]
    if ps and ps.Spectator == 0 then
      Game.ResetPlayer(clientID)
      Game.PlayerRespawnRequest(clientID)
    end
  end
end

Network:RegisterMethod("Game.NewPlayerTeamRequest", NCallOn.Server, NMode.Reliable, "bb")

function Game:NewPlayerTeamConfirmation(clientID, team)
  local ps = Game.PlayerStats[clientID]
  if ps then
    local tname = "Angels"
    if team == 1 then
      tname = "Demons"
    end
    CONSOLE_AddMessage(ps.Name .. " is now in team: " .. tname .. ".")
    ps.Team = team
    if ps.Player then
      ps.Player.Team = team
    end
    ps.Score = 0
    ps.Kills = 0
    ps.Deaths = 0
    MPSTATS.Update(ps.ClientID, ps.Name, ps.Score, ps.Kills, ps.Deaths, ps.Ping, ps.PacketLoss, ps.Team, ps.State, ps.Spectator)
  end
  if Player and Player.ClientID == clientID then
    Cfg.Team = team
  end
  for i, o in Game.PlayerStats, nil do
    Game:BrightSkin(o._Entity, MPCfg.AllowBrightskins, o.Team)
  end
  Game:CheckWarmUpStatus()
end

Network:RegisterMethod("Game.NewPlayerTeamConfirmation", NCallOn.ServerAndAllClients, NMode.Reliable, "bb")

function Game:SetStateRequest(clientID, state)
  local ps = Game.PlayerStats[clientID]
  if ps and ps.Spectator == 1 then
    return
  end
  Game.SetStateConfirmation(clientID, state)
end

Network:RegisterMethod("Game.SetStateRequest", NCallOn.Server, NMode.Reliable, "bb")

function Game:SetStateConfirmation(clientID, state)
  local ps = Game.PlayerStats[clientID]
  if ps then
    ps.State = state
    if ps.State == 1 and (MPCfg.GameState == GameStates.WarmUp or MPCfg.GameState == GameStates.Counting) then
      CONSOLE_AddMessage(ps.Name .. " is ready.")
    end
    if ps.State == 0 and (MPCfg.GameState == GameStates.WarmUp or MPCfg.GameState == GameStates.Counting) then
      CONSOLE_AddMessage(ps.Name .. " is unready.")
    end
    if ps.State == 2 and MPCfg.GameState == GameStates.Playing then
      CONSOLE_AddMessage(ps.Name .. " wants to break match.")
    end
    MPSTATS.Update(ps.ClientID, ps.Name, ps.Score, ps.Kills, ps.Deaths, ps.Ping, ps.PacketLoss, ps.Team, ps.State, ps.Spectator)
  end
  Game:CheckWarmUpStatus()
end

Network:RegisterMethod("Game.SetStateConfirmation", NCallOn.ServerAndAllClients, NMode.Reliable, "bb")

function Game:CheckWarmUpStatus()
  if MPCfg.GameState == GameStates.Finished then
    return
  end
  local n = 0
  for i, o in Game.PlayerStats, nil do
    if o.Spectator == 0 then
      n = n + 1
    end
  end
  local reds = 0
  local blues = 0
  local punready = 0
  local pbreak = 0
  for i, o in Game.PlayerStats, nil do
    if o.Spectator == 0 then
      if o.State ~= 1 then
        if o.State == 0 then
          punready = punready + 1
        end
        if o.State == 2 then
          pbreak = pbreak + 1
        end
      end
      if o.Team == 1 then
        reds = reds + 1
      end
      if o.Team == 0 then
        blues = blues + 1
      end
    end
  end
  if MPCfg.GameState == GameStates.WarmUp and pbreak == 0 and punready == 0 then
    if 1 < n then
      if not MPGameRules[Cfg.GameMode].Teams or blues ~= 0 and reds ~= 0 then
        MPCfg.GameState = GameStates.Counting
        Game._countTimer = 4.99
        CONSOLE_AddMessage("Match begins in 5 seconds.")
      else
        CONSOLE_AddMessage("Waiting for other team.")
      end
    else
      CONSOLE_AddMessage("Waiting for other players.")
    end
  end
  if Game:IsServer() then
    if MPCfg.GameState == GameStates.Playing and (pbreak >= n / 2 or MPGameRules[Cfg.GameMode].Teams and Cfg.StopMatchOnTeamQuit and (blues == 0 or reds == 0)) then
      StringToDo = "Game.EndOfMatch()"
    end
  elseif Game:IsServer() and Cfg.GameMode == "Clan Arena" and MPCfg.GameState == GameStates.Playing and (blues == 0 or reds == 0) then
    if reds == 0 then
      Game._team1Score = Game._team1Score + 1
    end
    if blues == 0 then
      Game._team2Score = Game._team2Score + 1
    end
    StringToDo = "Game:NextRound()"
  end
end

function Game:StartVotingRequest(clientID, cmd, params)
  local allowed = false
  allowed = Game:CheckVotingParams(cmd)
  if allowed then
    Game.StartVotingConfirmation(clientID, cmd, params)
  else
    Game.ConsoleMessageAll("Voting on " .. cmd .. " is disabled on this server")
  end
end

Network:RegisterMethod("Game.StartVotingRequest", NCallOn.Server, NMode.Reliable, "bss")

function Game:CheckVotingParams(cmd)
  local allowed = false
  if (cmd == "kick" or cmd == "kickid") and Cfg.UserKick then
    allowed = true
  elseif (cmd == "bankick" or cmd == "bankickid") and Cfg.UserBankick then
    allowed = true
  elseif cmd == "maxplayers" and Cfg.UserMaxPlayers then
    allowed = true
  elseif cmd == "maxspectators" and Cfg.UserMaxSpectators then
    allowed = true
  elseif cmd == "powerupdrop" and Cfg.UserPowerupDrop then
    allowed = true
  elseif cmd == "powerups" and Cfg.UserPowerups then
    allowed = true
  elseif cmd == "weaponsstay" and Cfg.UserWeaponsStay then
    allowed = true
  elseif cmd == "teamdamage" and Cfg.UserTeamDamage then
    allowed = true
  elseif cmd == "allowbunnyhopping" and Cfg.UserAllowBunnyhopping then
    allowed = true
  elseif cmd == "allowbrightskins" and Cfg.UserAllowBrightskins then
    allowed = true
  elseif cmd == "allowforwardrj" and Cfg.UserAllowForwardRJ then
    allowed = true
  elseif cmd == "reloadmap" and Cfg.UserReloadMap then
    allowed = true
  elseif cmd == "gamemode" and Cfg.UserGameMode then
    allowed = true
  elseif cmd == "mode" and Cfg.UserGameMode then
    allowed = true
  elseif cmd == "map" and Cfg.UserMapChange then
    allowed = true
  elseif cmd == "timelimit" and Cfg.UserTimeLimit then
    allowed = true
  elseif cmd == "fraglimit" and Cfg.UserFragLimit then
    allowed = true
  elseif cmd == "capturelimit" and Cfg.UserCaptureLimit then
    allowed = true
  elseif cmd == "lmslives" and Cfg.UserLMSLives then
    allowed = true
  elseif cmd == "weaponrespawntime" and Cfg.UserWeaponRespawnTime then
    allowed = true
  elseif cmd == "startupweapon" and Cfg.StartupWeapon then
    allowed = true
  elseif cmd == "proplus" then
    allowed = true
  elseif cmd == "forcespec" then
    allowed = true
  elseif cmd == "allready" then
    allowed = true
  elseif cmd == "botskill" then
    allowed = true
  elseif cmd == "teamlock" then
    allowed = true
  elseif cmd == "kickbot" then
    allowed = true
  elseif cmd == "kickallbots" then
    allowed = true
  elseif cmd == "addbot" then
    allowed = true
  elseif cmd == "referee" then
    allowed = true
  elseif cmd == "restartmap" then
    allowed = true
  elseif cmd == "saferespawn" then
    allowed = true
  elseif cmd == "warmupdamage" then
    allowed = true
  elseif cmd == "fallingdamage" then
    allowed = true
  elseif cmd == "rocketfix" then
    allowed = true
  end
  return allowed
end

function Game:StartVotingConfirmation(clientID, cmd, params)
  local ps = Game.PlayerStats[clientID]
  if ps and ps.Name then
    SOUND.Play2D("menu/menu/back-accept_alt", 100, true)
    CONSOLE_AddMessage(ps.Name .. " calls for voting - '" .. cmd .. " " .. params .. "'", R3D.RGB(200, 200, 200))
    ps._vote = 1
  end
  Game._voteTimeLeft = 60
  Game._voteCmd = cmd
  Game._voteParams = params
  Game:CheckVotingStatus()
end

Network:RegisterMethod("Game.StartVotingConfirmation", NCallOn.ServerAndAllClients, NMode.Reliable, "bss")

function Game:PlayerVoteRequest(clientID, vote)
  Game.PlayerVoteConfirmation(clientID, vote)
end

Network:RegisterMethod("Game.PlayerVoteRequest", NCallOn.Server, NMode.Reliable, "bb")

function Game:PlayerVoteConfirmation(clientID, vote)
  local ps = Game.PlayerStats[clientID]
  if ps then
    ps._vote = vote
  end
  Game:CheckVotingStatus()
end

Network:RegisterMethod("Game.PlayerVoteConfirmation", NCallOn.ServerAndAllClients, NMode.Reliable, "bb")

function Game:CheckVotingStatus()
  if Game._voteTimeLeft <= 0 and Game._voteCmd ~= "" then
    SOUND.Play2D("menu/menu/option-mark_map", 100, true)
    CONSOLE_AddMessage("Voting Timeout")
    for i, o in Game.PlayerStats, nil do
      if o._vote then
        o._vote = nil
      end
    end
    Game._voteTimeLeft = 0
    Game._voteCmd = ""
    Game._voteParams = ""
    return
  end
  local numPlayers = 0
  local yesVotes = 0
  local noVotes = 0
  for i, o in Game.PlayerStats, nil do
    if o._vote and o.Spectator == 0 then
      if o._vote == 1 then
        yesVotes = yesVotes + 1
      elseif o._vote == 0 then
        noVotes = noVotes + 1
      end
    end
    if o.Spectator == 0 then
      numPlayers = numPlayers + 1
    end
  end
  if numPlayers < 1 then
    SOUND.Play2D("menu/menu/option-mark_map", 100, true)
    CONSOLE_AddMessage("Voting aborted. Not enough players.")
    for i, o in Game.PlayerStats, nil do
      if o._vote then
        o._vote = nil
      end
    end
    Game._voteTimeLeft = 0
    Game._voteCmd = ""
    Game._voteParams = ""
  elseif yesVotes > numPlayers / 2 then
    SOUND.Play2D("menu/menu/back-accept_alt", 100, true)
    CONSOLE_AddMessage("Voting finished. More than half players voted 'YES' - " .. yesVotes .. "/" .. numPlayers)
    if Game:IsServer() and Game._voteCmd ~= "" then
      Console:OnCommand("\\" .. Game._voteCmd .. " " .. Game._voteParams)
    end
    for i, o in Game.PlayerStats, nil do
      if o._vote then
        o._vote = nil
      end
    end
    Game._voteTimeLeft = 0
    Game._voteCmd = ""
    Game._voteParams = ""
  elseif noVotes >= numPlayers / 2 then
    SOUND.Play2D("menu/menu/option-mark_map", 100, true)
    CONSOLE_AddMessage("Voting finished. Less than half players voted 'YES' - " .. noVotes .. "/" .. numPlayers)
    for i, o in Game.PlayerStats, nil do
      if o._vote then
        o._vote = nil
      end
    end
    Game._voteTimeLeft = 0
    Game._voteCmd = ""
    Game._voteParams = ""
  else
    SOUND.Play2D("menu/menu/click_alt", 100, true)
    CONSOLE_AddMessage("Current votes: YES - " .. yesVotes .. ", NO - " .. noVotes)
  end
end

function Game:SetGameState(state)
  if MPCfg.GameState == state then
    return
  end
  MPCfg.GameState = state
  if MPCfg.GameState == GameStates.WarmUp then
    Game._team1Score = 0
    Game._team2Score = 0
    MPSTATS.SetTeamsScore(0, 0)
  end
  if MPCfg.GameState == GameStates.Playing then
    Game._TimeLimitOut = 0
    Game._LastTime = INP.GetTime()
  end
end

Network:RegisterMethod("Game.SetGameState", NCallOn.ServerAndAllClients, NMode.Reliable, "b")

function Game:PlayerRespawnConfirmation(clientID, newe, a, weapon)
  if MPCfg.GameMode == "Clan Arena" and newe == nil then
    local player = Game:FindPlayerByClientID(clientID)
    if player then
      player:ResetStatus(weapon)
    end
  end
  if newe == nil then
    return
  end
  Game:Print("PlayerRespawnConfirmation")
  local player = Game:FindPlayerByClientID(clientID)
  local ps = Game.PlayerStats[clientID]
  if ps then
    ps._Entity = newe
    if ps._animproc then
      ps._animproc:Reset()
      ps._animproc._Entity = newe
    end
    ps._respawned = true
  end
  local myplayer = false
  if player then
    EntityToObject[newe] = player
    player._Entity = newe
    player:ResetStatus(weapon)
    ENTITY.PO_Enable(player._Entity, true)
    if Player == player then
      myplayer = true
      if Game._procStats then
        GObjects:ToKill(Game._procStats)
        Game._procStats = nil
        Hud.Enabled = true
        MPSTATS.Hide()
      end
      Game.CameraFromPlayer = true
      CAM.SetAng(-a / (math.pi / 180) - 180, 0, 0)
      for f = 1, 7 do
        if Hud.LAmmosPlaySound[f][1] == true then
          Hud.LAmmosPlaySound[f][1] = false
        end
        if Hud.LAmmosPlaySound[f][2] == true then
          Hud.LAmmosPlaySound[f][2] = false
        end
      end
    end
    if MPCfg.GameMode == "People Can Fly" then
      vx = math.sin(a)
      vz = math.cos(a)
      local x, y, z = ENTITY.GetPosition(newe)
      ENTITY.PO_Hit(newe, x, y, z, vx * 625, 625, vz * 625)
    end
  end
  local x, y, z = ENTITY.GetPosition(newe)
  if myplayer then
    if Game.GMode == GModes.MultiplayerClient then
      collectgarbage(0)
    end
    ENTITY.EnableDraw(newe, false)
    if ps and ps.Deaths == 0 then
      if math.random(0, 1) == 1 then
        SOUND.Play2D("multiplayer/lucifer/Lucifer_fight")
      else
        SOUND.Play2D("multiplayer/lucifer/lucifer-comemychildren")
      end
    else
      SOUND.Play2D("specials/respawns/respawn_m" .. math.random(1, 6))
    end
  else
    ENTITY.PO_SetFriction(newe, 0.7)
    ENTITY.EnableDraw(newe, true)
    MDL.SetAnim(newe, "idle", true)
    local x, y, z = ENTITY.GetPosition(newe)
    local fx, fy, fz = CAM.GetForwardVector()
    if not Cfg.NoSpawnEffects then
      AddObject("FX_Spawn.CActor", 0.6, Vector:New(x - fx / 3, y, z - fz / 3), Quaternion:New_FromNormalY(fx, 0, fz), true)
    end
    SOUND.Play3D("specials/respawns/respawn_m" .. math.random(1, 6), x, y, z, 25, 40)
  end
  if ps then
    Game:BrightSkin(newe, true, ps.Team)
  end
  if not Game:IsServer() then
    ENTITY.RemoveRagdoll(newe)
  end
end

Network:RegisterMethod("Game.PlayerRespawnConfirmation", NCallOn.ServerAndAllClients, NMode.Reliable, "befb")

function Game:BrightSkin(entity, enable, team)
  local teams = false
  if MPGameRules[MPCfg.GameMode] and MPGameRules[MPCfg.GameMode].Teams then
    teams = true
  end
  ENTITY.KillAllChildrenByName(entity, "teammateIcon")
  if entity and 0 < entity and not PMENU.Active() and teams and team == Cfg.Team and (not Player or entity ~= Player._Entity) and (Cfg.TeammateIcon == 1 or Cfg.TeammateIcon == 2) then
    local ei = ENTITY.Create(ETypes.Billboard, "Script", "teammateIcon")
    local ticon = "hud/teammate"
    local color = Color:New(255, 255, 255)
    if Cfg.TeammateIcon == 2 then
      ticon = "SHud/teammate_pro"
      color = Color:New(255, 255, 255)
      if Cfg.TeammateIcon_RGB[4] == 0 then
        if not (not teams or Cfg.Team ~= team or Cfg.FixedColors) or Cfg.FixedColors and teams and team == 0 or not teams and Player and entity == Player._Entity then
          color = Color:New(0, 0, 255)
          if Cfg.BrightskinTeam == "White" then
            color = Color:New(255, 255, 255)
          end
          if Cfg.BrightskinTeam == "Red" then
            color = Color:New(255, 0, 0)
          end
          if Cfg.BrightskinTeam == "Blue" then
            color = Color:New(0, 102, 255)
          end
          if Cfg.BrightskinTeam == "Green" then
            color = Color:New(0, 255, 0)
          end
          if Cfg.BrightskinTeam == "Black" then
            color = Color:New(0, 0, 0)
          end
          if Cfg.BrightskinTeam == "Cyan" then
            color = Color:New(0, 255, 255)
          end
          if Cfg.BrightskinTeam == "Magenta" then
            color = Color:New(255, 0, 255)
          end
          if Cfg.BrightskinTeam == "Yellow" then
            color = Color:New(255, 255, 0)
          end
          if Cfg.BrightskinTeam == "Pink" then
            color = Color:New(255, 0, 153)
          end
          if Cfg.BrightskinTeam == "Orange" then
            color = Color:New(255, 153, 0)
          end
          if Cfg.BrightskinTeam == "Purple" then
            color = Color:New(204, 0, 255)
          end
          if Cfg.BrightskinTeam == "Grey" then
            color = Color:New(153, 153, 153)
          end
          if Cfg.BrightskinTeam == "Brown" then
            color = Color:New(153, 102, 0)
          end
        else
          color = Color:New(255, 0, 0)
          if Cfg.BrightskinEnemy == "White" then
            color = Color:New(255, 255, 255)
          end
          if Cfg.BrightskinEnemy == "Red" then
            color = Color:New(255, 0, 0)
          end
          if Cfg.BrightskinEnemy == "Blue" then
            color = Color:New(0, 102, 255)
          end
          if Cfg.BrightskinEnemy == "Green" then
            color = Color:New(0, 255, 0)
          end
          if Cfg.BrightskinEnemy == "Black" then
            color = Color:New(0, 0, 0)
          end
          if Cfg.BrightskinEnemy == "Cyan" then
            color = Color:New(0, 255, 255)
          end
          if Cfg.BrightskinEnemy == "Magenta" then
            color = Color:New(255, 0, 255)
          end
          if Cfg.BrightskinEnemy == "Yellow" then
            color = Color:New(255, 255, 0)
          end
          if Cfg.BrightskinEnemy == "Pink" then
            color = Color:New(255, 0, 153)
          end
          if Cfg.BrightskinEnemy == "Orange" then
            color = Color:New(255, 153, 0)
          end
          if Cfg.BrightskinEnemy == "Purple" then
            color = Color:New(204, 0, 255)
          end
          if Cfg.BrightskinEnemy == "Grey" then
            color = Color:New(153, 153, 153)
          end
          if Cfg.BrightskinEnemy == "Brown" then
            color = Color:New(153, 102, 0)
          end
        end
      else
        color = Color:New(Cfg.TeammateIcon_RGB[1], Cfg.TeammateIcon_RGB[2], Cfg.TeammateIcon_RGB[3], 255)
      end
    end
    BILLBOARD.SetupCorona(ei, 0.9, 0, 0, 0, 0, 0.5, 0, 0, 0, ticon, color:Compose(), 1, true)
    ENTITY.SetPosition(ei, 0, 2.7, 0)
    WORLD.AddEntity(ei)
    ENTITY.RegisterChild(entity, ei)
  end
  if Cfg.BrightSkins and enable and MPCfg.AllowBrightskins then
    local color
    if not (not teams or Cfg.Team ~= team or Cfg.FixedColors) or Cfg.FixedColors and teams and team == 0 or not teams and Player and entity == Player._Entity then
      color = Color:New(0, 0, 255)
      if Cfg.BrightskinTeam == "White" then
        color = Color:New(255, 255, 255)
      end
      if Cfg.BrightskinTeam == "Red" then
        color = Color:New(255, 0, 0)
      end
      if Cfg.BrightskinTeam == "Blue" then
        color = Color:New(0, 102, 255)
      end
      if Cfg.BrightskinTeam == "Green" then
        color = Color:New(0, 255, 0)
      end
      if Cfg.BrightskinTeam == "Black" then
        color = Color:New(0, 0, 0)
      end
      if Cfg.BrightskinTeam == "Cyan" then
        color = Color:New(0, 255, 255)
      end
      if Cfg.BrightskinTeam == "Magenta" then
        color = Color:New(255, 0, 255)
      end
      if Cfg.BrightskinTeam == "Yellow" then
        color = Color:New(255, 255, 0)
      end
      if Cfg.BrightskinTeam == "Pink" then
        color = Color:New(255, 0, 153)
      end
      if Cfg.BrightskinTeam == "Orange" then
        color = Color:New(255, 153, 0)
      end
      if Cfg.BrightskinTeam == "Purple" then
        color = Color:New(204, 0, 255)
      end
      if Cfg.BrightskinTeam == "Grey" then
        color = Color:New(153, 153, 153)
      end
      if Cfg.BrightskinTeam == "Brown" then
        color = Color:New(153, 102, 0)
      end
      self._ColorTeamB = {
        color.R,
        color.G,
        color.B
      }
    else
      color = Color:New(255, 0, 0)
      if Cfg.BrightskinEnemy == "White" then
        color = Color:New(255, 255, 255)
      end
      if Cfg.BrightskinEnemy == "Red" then
        color = Color:New(255, 0, 0)
      end
      if Cfg.BrightskinEnemy == "Blue" then
        color = Color:New(0, 102, 255)
      end
      if Cfg.BrightskinEnemy == "Green" then
        color = Color:New(0, 255, 0)
      end
      if Cfg.BrightskinEnemy == "Black" then
        color = Color:New(0, 0, 0)
      end
      if Cfg.BrightskinEnemy == "Cyan" then
        color = Color:New(0, 255, 255)
      end
      if Cfg.BrightskinEnemy == "Magenta" then
        color = Color:New(255, 0, 255)
      end
      if Cfg.BrightskinEnemy == "Yellow" then
        color = Color:New(255, 255, 0)
      end
      if Cfg.BrightskinEnemy == "Pink" then
        color = Color:New(255, 0, 153)
      end
      if Cfg.BrightskinEnemy == "Orange" then
        color = Color:New(255, 153, 0)
      end
      if Cfg.BrightskinEnemy == "Purple" then
        color = Color:New(204, 0, 255)
      end
      if Cfg.BrightskinEnemy == "Grey" then
        color = Color:New(153, 153, 153)
      end
      if Cfg.BrightskinEnemy == "Brown" then
        color = Color:New(153, 102, 0)
      end
      self._ColorTeamR = {
        color.R,
        color.G,
        color.B
      }
    end
    MDL.SetMeshLighting(entity, "*", false, color.R, color.G, color.B)
    if not PMENU.Active() then
      if not Cfg.BrightSkinsFull then
        MATERIAL.Replace("models/mp-model-fallenangel/mpplayer1texture1", "models/mp-model-fallenangel/mpplayer1texture1_brightskin")
        MATERIAL.Replace("models/mp-model-fallenangel/mpplayer1texture2", "models/mp-model-fallenangel/mpplayer1texture2_brightskin")
        MATERIAL.Replace("models/mp-model-fallenangel/mpplayer1texture3", "models/mp-model-fallenangel/mpplayer1texture3_brightskin")
        MATERIAL.Replace("models/mp-model-demon/mp_player_2_tex_1", "models/mp-model-demon/mp_player_2_tex_1_brightskin")
        MATERIAL.Replace("models/mp-model-demon/mp_player_2_tex_2", "models/mp-model-demon/mp_player_2_tex_2_brightskin")
        MATERIAL.Replace("models/mp-model-beast/mpplayer5_texture_1", "models/mp-model-beast/mpplayer5_texture_1_brightskin")
        MATERIAL.Replace("models/mp-model-beast/mpplayer5_texture_2", "models/mp-model-beast/mpplayer5_texture_2_brightskin")
        MATERIAL.Replace("models/mp-model-beast/mpplayer5_texture_3", "models/mp-model-beast/mpplayer5_texture_3_brightskin")
        MATERIAL.Replace("models/mp-model-painkiller/PAINPLAYER_texture1", "models/mp-model-painkiller/PAINPLAYER_texture1_brightskin")
        MATERIAL.Replace("models/mp-model-painkiller/PAINPLAYER_texture2", "models/mp-model-painkiller/PAINPLAYER_texture2_brightskin")
        MATERIAL.Replace("models/mp-model-painkiller/PAINPLAYER_texture3", "models/mp-model-painkiller/PAINPLAYER_texture3_brightskin")
        MATERIAL.Replace("models/mp-model-knight/templar_tex_1", "models/mp-model-knight/templar_tex_1_brightskin")
        MATERIAL.Replace("models/mp-model-knight/templar_tex_2", "models/mp-model-knight/templar_tex_2_brightskin")
        MATERIAL.Replace("models/mp-model-knight/templar_tex_3", "models/mp-model-knight/templar_tex_3_brightskin")
        MATERIAL.Replace("models/mp-model-player6/mpplayer6_texture1", "models/mp-model-player6/mpplayer6_texture_brightskin")
        MATERIAL.Replace("models/mp-model-player7/labcomando_texture1", "models/mp-model-player7/mpplayer7_texture_brightskin")
      else
        MATERIAL.Replace("models/mp-model-fallenangel/mpplayer1texture1", "FullBrightSkins/mp-model-fallenangel/mpplayer1texture1_brightskin")
        MATERIAL.Replace("models/mp-model-fallenangel/mpplayer1texture2", "FullBrightSkins/mp-model-fallenangel/mpplayer1texture2_brightskin")
        MATERIAL.Replace("models/mp-model-fallenangel/mpplayer1texture3", "FullBrightSkins/mp-model-fallenangel/mpplayer1texture3_brightskin")
        MATERIAL.Replace("models/mp-model-demon/mp_player_2_tex_1", "FullBrightSkins/mp-model-demon/mp_player_2_tex_1_brightskin")
        MATERIAL.Replace("models/mp-model-demon/mp_player_2_tex_2", "FullBrightSkins/mp-model-demon/mp_player_2_tex_2_brightskin")
        MATERIAL.Replace("models/mp-model-beast/mpplayer5_texture_1", "FullBrightSkins/mp-model-beast/mpplayer5_texture_1_brightskin")
        MATERIAL.Replace("models/mp-model-beast/mpplayer5_texture_2", "FullBrightSkins/mp-model-beast/mpplayer5_texture_2_brightskin")
        MATERIAL.Replace("models/mp-model-beast/mpplayer5_texture_3", "FullBrightSkins/mp-model-beast/mpplayer5_texture_3_brightskin")
        MATERIAL.Replace("models/mp-model-painkiller/PAINPLAYER_texture1", "FullBrightSkins/mp-model-painkiller/PAINPLAYER_texture1_brightskin")
        MATERIAL.Replace("models/mp-model-painkiller/PAINPLAYER_texture2", "FullBrightSkins/mp-model-painkiller/PAINPLAYER_texture2_brightskin")
        MATERIAL.Replace("models/mp-model-painkiller/PAINPLAYER_texture3", "FullBrightSkins/mp-model-painkiller/PAINPLAYER_texture3_brightskin")
        MATERIAL.Replace("models/mp-model-knight/templar_tex_1", "FullBrightSkins/mp-model-knight/templar_tex_1_brightskin")
        MATERIAL.Replace("models/mp-model-knight/templar_tex_2", "FullBrightSkins/mp-model-knight/templar_tex_2_brightskin")
        MATERIAL.Replace("models/mp-model-knight/templar_tex_3", "FullBrightSkins/mp-model-knight/templar_tex_3_brightskin")
        MATERIAL.Replace("models/mp-model-player6/mpplayer6_texture1", "FullBrightSkins/mp-model-player6/mpplayer6_texture_brightskin")
        MATERIAL.Replace("models/mp-model-player7/labcomando_texture1", "FullBrightSkins/mp-model-player7/mpplayer7_texture_brightskin")
      end
    end
  else
    MDL.SetMeshLighting(entity, "*", true)
    if teams then
      if Cfg.Team ~= team then
        MDL.SetTexture(entity, "mpplayer5_texture_1_add", "mpplayer5_texture_1_red")
        MDL.SetTexture(entity, "mpplayer5_texture_2_add", "mpplayer5_texture_2_red")
        MDL.SetTexture(entity, "mp_player_2_tex_1_add", "mp_player_2_tex_1_red")
        MDL.SetTexture(entity, "mp_player_2_tex_2_add", "mp_player_2_tex_2_red")
        MDL.SetTexture(entity, "mpplayer1texture2_add", "mpplayer1texture2_red")
        MDL.SetTexture(entity, "mpplayer1texture3_add", "mpplayer1texture3_red")
        MDL.SetTexture(entity, "templar_tex_2_add", "templar_tex_2_red")
        MDL.SetTexture(entity, "templar_tex_3_add", "templar_tex_3_red")
        MDL.SetTexture(entity, "painplayer_texture1_add", "painplayer_texture1_red")
        MDL.SetTexture(entity, "painplayer_texture2_add", "painplayer_texture2_red")
        MDL.SetTexture(entity, "painplayer_texture3_add", "painplayer_texture3_red")
        MDL.SetTexture(entity, "mpplayer6_texture1_add", "mpplayer6_texture1_red")
        MDL.SetTexture(entity, "labcomando_texture1_add", "labcomando_texture1_red")
      else
        MDL.SetTexture(entity, "mpplayer5_texture_1_add", "mpplayer5_texture_1_white")
        MDL.SetTexture(entity, "mpplayer5_texture_2_add", "mpplayer5_texture_2_white")
        MDL.SetTexture(entity, "mp_player_2_tex_1_add", "mp_player_2_tex_1_white")
        MDL.SetTexture(entity, "mp_player_2_tex_2_add", "mp_player_2_tex_2_white")
        MDL.SetTexture(entity, "mpplayer1texture2_add", "mpplayer1texture2_white")
        MDL.SetTexture(entity, "mpplayer1texture3_add", "mpplayer1texture3_white")
        MDL.SetTexture(entity, "templar_tex_2_add", "templar_tex_2_white")
        MDL.SetTexture(entity, "templar_tex_3_add", "templar_tex_3_white")
        MDL.SetTexture(entity, "painplayer_texture1_add", "painplayer_texture1_white")
        MDL.SetTexture(entity, "painplayer_texture2_add", "painplayer_texture2_white")
        MDL.SetTexture(entity, "painplayer_texture3_add", "painplayer_texture3_white")
        MDL.SetTexture(entity, "mpplayer6_texture1_add", "mpplayer6_texture1_white")
        MDL.SetTexture(entity, "labcomando_texture1_add", "labcomando_texture1_white")
      end
    end
    MATERIAL.Replace("models/mp-model-fallenangel/mpplayer1texture1", "models/mp-model-fallenangel/mpplayer1texture1")
    MATERIAL.Replace("models/mp-model-fallenangel/mpplayer1texture2", "models/mp-model-fallenangel/mpplayer1texture2")
    MATERIAL.Replace("models/mp-model-fallenangel/mpplayer1texture3", "models/mp-model-fallenangel/mpplayer1texture3")
    MATERIAL.Replace("models/mp-model-demon/mp_player_2_tex_1", "models/mp-model-demon/mp_player_2_tex_1")
    MATERIAL.Replace("models/mp-model-demon/mp_player_2_tex_2", "models/mp-model-demon/mp_player_2_tex_2")
    MATERIAL.Replace("models/mp-model-beast/mpplayer5_texture_1", "models/mp-model-beast/mpplayer5_texture_1")
    MATERIAL.Replace("models/mp-model-beast/mpplayer5_texture_2", "models/mp-model-beast/mpplayer5_texture_2")
    MATERIAL.Replace("models/mp-model-painkiller/PAINPLAYER_texture1", "models/mp-model-painkiller/PAINPLAYER_texture1")
    MATERIAL.Replace("models/mp-model-painkiller/PAINPLAYER_texture2", "models/mp-model-painkiller/PAINPLAYER_texture2")
    MATERIAL.Replace("models/mp-model-painkiller/PAINPLAYER_texture3", "models/mp-model-painkiller/PAINPLAYER_texture3")
    MATERIAL.Replace("models/mp-model-knight/templar_tex_1", "models/mp-model-knight/templar_tex_1")
    MATERIAL.Replace("models/mp-model-knight/templar_tex_2", "models/mp-model-knight/templar_tex_2")
    MATERIAL.Replace("models/mp-model-knight/templar_tex_3", "models/mp-model-knight/templar_tex_3")
    MATERIAL.Replace("models/mp-model-player6/mpplayer6_texture1", "models/mp-model-player6/mpplayer6_texture1")
    MATERIAL.Replace("models/mp-model-player7/labcomando_texture1", "models/mp-model-player7/labcomando_texture1")
  end
end

function Game:ReloadBrightskins()
  for i, o in Game.PlayerStats, nil do
    Game:BrightSkin(o._Entity, MPCfg.AllowBrightskins, o.Team)
    if MPCfg.AllowBrightskins then
      CONSOLE_AddMessage("Brightskins enabled")
    else
      CONSOLE_AddMessage("Brightskins disabled")
    end
  end
end

Network:RegisterMethod("Game.ReloadBrightskins", NCallOn.ServerAndAllClients, NMode.Reliable, "")

function Game:EnableBunnyhopping(enable)
  PHYSICS.SetGravity(Tweak.GlobalData.MPGravity)
  if enable then
    PHYSICS.SetBunnyHopAcceleration(Tweak.MultiPlayerMove.BunnyHopAcceleration)
    CONSOLE_AddMessage("Bunnyhopping enabled")
  else
    PHYSICS.SetBunnyHopAcceleration(0)
    CONSOLE_AddMessage("Bunnyhopping disabled")
  end
end

Network:RegisterMethod("Game.EnableBunnyhopping", NCallOn.ServerAndAllClients, NMode.Reliable, "B")

function Game:PlayerPingInfo(cnt, ...)
  local i = 1
  while arg[i] do
    local ps = Game.PlayerStats[arg[i]]
    if ps then
      ps.Ping = arg[i + 1]
      ps.PacketLoss = arg[i + 2]
      MPSTATS.Update(ps.ClientID, ps.Name, ps.Score, ps.Kills, ps.Deaths, ps.Ping, ps.PacketLoss, ps.Team, ps.State, ps.Spectator)
    end
    i = i + 3
  end
end

Network:RegisterMethod("Game.PlayerPingInfo", NCallOn.ServerAndAllClients, NMode.Unreliable, "xbbb")

function Game:SayToAll(clientID, txt, color)
  local ps = Game.PlayerStats[clientID]
  if not ps and (clientID ~= ServerID or not IsDedicatedServer()) then
    return
  end
  if Game:Client2ServerRead(clientID, txt) then
    return
  end
  local onebotheardsomething
  for i, pp in Game.PlayerStats, nil do
    if pp.Bot and onebotheardsomething == nil then
      pp.LastThingHeard = txt
      onebotheardsomething = true
    end
  end
  Game.ConsoleClientMessage(clientID, txt, color)
  if Cfg.PitabotEnabled then
    if txt == "CMD:UPDATESTATSALL" then
      return
    end
    if clientID == ServerID and not ps then
      ps = {
        Name = "Server Admin"
      }
    end
    PBLogEvent(ps.Name, "SayAll", txt)
  end
end

Network:RegisterMethod("Game.SayToAll", NCallOn.Server, NMode.Reliable, "bsi")

function Game:SayToTeam(clientID, txt, color)
  local ps = Game.PlayerStats[clientID]
  if not ps or ps.Spectator == 1 then
    return
  end
  for i, o in Game.PlayerStats, nil do
    if o.Team == ps.Team then
      if o.ClientID == ServerID then
        RawCallMethod(Game.ConsoleClientMessage, clientID, txt, color)
      else
        SendNetMethod(Game.ConsoleClientMessage, o.ClientID, true, true, clientID, txt, color)
      end
    end
  end
end

Network:RegisterMethod("Game.SayToTeam", NCallOn.Server, NMode.Reliable, "bsi")

function Game:ConsoleClientMessage(clientID, txt, color)
  local ps = Game.PlayerStats[clientID]
  if clientID == ServerID and not ps then
    ps = {
      Name = "Dedicated Admin"
    }
  end
  if Game:Server2ClientRead(txt) then
    return
  end
  if not ps then
    return
  end
  if Cfg.HUD_TeamChatOnly and ps.Team ~= Cfg.Team then
    return
  end
  if color == nil or color == 0 then
    CONSOLE_AddMessage(ps.Name .. ": " .. txt, R3D.RGB(255, 0, 0))
  else
    CONSOLE_AddMessage(ps.Name .. ": " .. txt, color)
  end
  if not Cfg.NoChatBeep then
    SOUND.Play2D("menu/magicboard/wrong_place", 100, true, true)
  end
end

Network:RegisterMethod("Game.ConsoleClientMessage", NCallOn.ServerAndAllClients, NMode.Reliable, "bsi")

function Game:ConsoleMessage(txt)
  CONSOLE_AddMessage(txt, R3D.RGB(255, 0, 0))
  SOUND.Play2D("menu/magicboard/wrong_place", 100, true, true)
end

Network:RegisterMethod("Game.ConsoleMessage", NCallOn.ServerAndAllClients, NMode.Reliable, "s")

function Game:LoadNextMap()
  Logfile:Close()
  if Game:IsServer() and Game._procStats then
    GObjects:ToKill(Game._procStats)
    Game._procStats = nil
  end
  Game.DuelQueueDone = nil
  if Game:IsMapRestartDue() then
    Game:DuelQueue()
  end
  local maps = PainMenu.mapsOnServer
  if maps and table.getn(maps) > 0 then
    for i = 1, table.getn(maps) do
      if string.upper(maps[i]) == string.upper(Lev._Name) then
        if maps[i + 1] then
          if string.upper(maps[i + 1]) ~= string.upper(Lev._Name) or not Cfg.RestartMaps then
            NET.LoadMapOnServer(maps[i + 1])
            CONSOLE_AddMessage("Reloading map " .. tostring(maps[i + 1]))
          else
            Game:MapRestart()
            CONSOLE_AddMessage("Restarting map " .. tostring(maps[i + 1]))
          end
        elseif string.upper(maps[1]) ~= string.upper(Lev._Name) or not Cfg.RestartMaps then
          NET.LoadMapOnServer(maps[1])
          CONSOLE_AddMessage("Reloading map " .. tostring(maps[1]))
        else
          Game:MapRestart()
          CONSOLE_AddMessage("Restarting map " .. tostring(maps[1]))
        end
        return
      end
    end
    if string.upper(maps[1]) ~= string.upper(Lev._Name) or not Cfg.RestartMaps then
      NET.LoadMapOnServer(maps[1])
      CONSOLE_AddMessage("Reloading map " .. tostring(maps[1]))
    else
      Game:MapRestart()
      CONSOLE_AddMessage("Restarting map " .. tostring(maps[1]))
    end
    return
  end
  if not Cfg.RestartMaps then
    Game:MapRestart()
    CONSOLE_AddMessage("Restarting map " .. tostring(Lev._Name))
  else
    NET.LoadMapOnServer(Lev._Name)
    CONSOLE_AddMessage("Reloading map " .. tostring(Lev._Name))
  end
end

function Game:EndOfMatch()
  Game.NewComers = {}
  if Cfg.AutoStatsDump then
    Game:AutoStatsDump()
  end
  CONSOLE_AddMessage("Match Finished.")
  MPCfg.GameState = GameStates.Finished
  GObjects:ToKill(Game._procSpec)
  Game._procSpec = nil
  Log("EndOfMatch - 1\n")
  if Game._procStats then
    GObjects:ToKill(Game._procStats)
  end
  Log("EndOfMatch - 1.5\n")
  MPSTATS.SetTimeLeft("00:00")
  Log("EndOfMatch - 2\n")
  for i, o in Game.Players, nil do
    if not o._died then
      o._died = true
      o:ResetStatusAfterDeath()
      Log("SetTimeToDie 1\n")
      if Game:IsServer() then
        ENTITY.SetTimeToDie(o._Entity, 5)
      end
      Log("SetTimeToDie 2\n")
      o._Entity = nil
    end
  end
  Log("EndOfMatch - 3\n")
  for i, o in Game.PlayerStats, nil do
    if MPCfg.GameMode == "Last Man Standing" or MPCfg.GameMode == "Clan Arena" then
      NET.SetSpectator(i, 0)
    end
    Log("4")
    ENTITY.SetVelocity(o._Entity, 0, 0, 0)
    ENTITY.PO_Enable(o._Entity, false)
    MDL.SetAnim(o._Entity, "idle", true)
    ENTITY.EnableDraw(o._Entity, true)
    if o._animproc then
      o._animproc:Reset()
    end
    ENTITY.KillAllChildren(o._Entity)
    if o._Entity then
      Log(" E \n")
      EntityToObject[o._Entity] = nil
    end
    o._Entity = nil
  end
  Log("EndOfMatch - 4\n")
  Game._procStats = GObjects:Add(TempObjName(), Templates["EndOfMatch.CProcess"]:New(1))
  Log("EndOfMatch - 5\n")
end

Network:RegisterMethod("Game.EndOfMatch", NCallOn.ServerAndAllClients, NMode.Reliable, "")

function Game:SetConfiguration(brightskins, gamemode, fraglimit, capturelimit, lmslives, teamdamage, lockconsole)
  MPCfg.AllowBrightskins = brightskins
  MPCfg.TeamDamage = teamdamage
  MPCfg.FragLimit = fraglimit
  MPCfg.GameMode = gamemode
  MPCfg.CaptureLimit = capturelimit
  MPCfg.LMSLives = lmslives
  MPCfg.ClientConsoleLockdown = lockconsole
  MPSTATS.SetFragLimit(MPCfg.FragLimit)
  MPSTATS.SetCaptureLimit(MPCfg.CaptureLimit)
  MPSTATS.SetLMSLives(MPCfg.LMSLives)
  CONSOLE_AddMessage(gamemode)
  if Cfg.PitabotEnabled then
    PBResetEventsLog()
  end
end

Network:RegisterMethod("Game.SetConfiguration", NCallOn.ServerAndAllClients, NMode.Reliable, "BsfffBB")

function Game:ConsoleMessageAll(msg)
  CONSOLE_AddMessage(msg)
end

Network:RegisterMethod("Game.ConsoleMessageAll", NCallOn.ServerAndAllClients, NMode.Reliable, "s")

function Game:ServerInfoRequest(clientID)
  local ded = false
  if Game.GMode == GModes.DedicatedServer then
    ded = true
  end
  local fps = "Not limited"
  if Cfg.LimitServerFPS then
    fps = "" .. Cfg.ServerFPS
  end
  Game.ServerInfoConfirmation(clientID, Cfg.ServerName, ded, Lev._Name, MPCfg.GameMode, fps)
end

Network:RegisterMethod("Game.ServerInfoRequest", NCallOn.Server, NMode.Reliable, "b")

function Game:ServerInfoConfirmation(name, isDedicated, map, mode, fps)
  CONSOLE_AddMessage("Server: " .. name)
  local type = "Listen"
  if isDedicated then
    type = "Dedicated"
  end
  CONSOLE_AddMessage("Type: " .. type)
  CONSOLE_AddMessage("Map: " .. map)
  CONSOLE_AddMessage("Mode: " .. mode)
  CONSOLE_AddMessage("FPS: " .. fps)
end

Network:RegisterMethod("Game.ServerInfoConfirmation", NCallOn.SingleClient, NMode.Reliable, "sBsss")

function Game:FindPlayerStatsByEntity(entity)
  for i, o in Game.PlayerStats, nil do
    if o._Entity == entity then
      return o
    end
  end
  return nil
end

function Game:FindPlayerByClientID(clientID)
  for i, o in Game.Players, nil do
    if o.ClientID == clientID then
      return o
    end
  end
  return nil
end

function Game:GameSpy_UpdatePlayers()
  if not Game:IsServer() then
    return
  end
  local i = 0
  GAMESPY.RemoveAllPlayers()
  for id, ps in Game.PlayerStats, nil do
    if ps.Spectator == 0 then
      GAMESPY.SetPlayerInfo(i, ps.Name, ps.Score, ps.Ping, ps.Deaths, ps.Team)
      i = i + 1
    end
  end
end

function GetPlayerEntityByClient(clientID)
  local ps = Game.PlayerStats[clientID]
  if ps and ps._Entity then
    return ps._Entity
  end
  return 0
end

function Game_BackupServerSettings()
  MPCfgBackup.MaxPlayers = Cfg.MaxPlayers
  MPCfgBackup.MaxSpectators = Cfg.MaxSpectators
  MPCfgBackup.FragLimit = Cfg.FragLimit
  MPCfgBackup.TimeLimit = Cfg.TimeLimit
  MPCfgBackup.CaptureLimit = Cfg.CaptureLimit
  MPCfgBackup.LMSLives = Cfg.LMSLives
  MPCfgBackup.GameMode = Cfg.GameMode
  MPCfgBackup.Powerups = Cfg.Powerups
  MPCfgBackup.PowerupDrop = Cfg.PowerupDrop
  MPCfgBackup.WeaponsStay = Cfg.WeaponsStay
  MPCfgBackup.WeaponRespawnTime = Cfg.WeaponRespawnTime
  MPCfgBackup.TeamDamage = Cfg.TeamDamage
  MPCfgBackup.AllowBrightskins = Cfg.AllowBrightskins
  MPCfgBackup.AllowBunnyhopping = Cfg.AllowBunnyhopping
  MPCfgBackup.AllowForwardRJ = Cfg.AllowForwardRJ
  MPCfgBackup.StartupWeapon = Cfg.StartupWeapon
  MPCfgBackup.Map = Cfg.ServerMaps[1]
end

function Game_RestoreServerSettings()
  Console:Cmd_FRAGLIMIT(MPCfgBackup.FragLimit)
  Console:Cmd_TIMELIMIT(MPCfgBackup.TimeLimit)
  Console:Cmd_CAPTURELIMIT(MPCfgBackup.CaptureLimit)
  Console:Cmd_MAXPLAYERS(MPCfgBackup.MaxPlayers)
  Console:Cmd_MAXSPECTATORS(MPCfgBackup.MaxSpectators)
  Console:Cmd_POWERUPS(MPCfgBackup.Powerups)
  Console:Cmd_POWERUPDROP(MPCfgBackup.PowerupDrop)
  Console:Cmd_WEAPONSSTAY(MPCfgBackup.WeaponsStay)
  Console:Cmd_WEAPONRESPAWNTIME(MPCfgBackup.WeaponRespawnTime)
  Console:Cmd_TEAMDAMAGE(MPCfgBackup.TeamDamage)
  Console:Cmd_ALLOWBRIGHTSKINS(MPCfgBackup.AllowBrightskins)
  Console:Cmd_ALLOWBUNNYHOPPING(MPCfgBackup.AllowBunnyhopping)
  Console:Cmd_ALLOWFORWARDRJ(MPCfgBackup.AllowForwardRJ)
  Console:Cmd_STARTUPWEAPON(MPCfgBackup.StartupWeapon)
  if MPCfg.GameMode ~= MPCfgBackup.GameMode then
    Console:Cmd_GAMEMODE(MPCfgBackup.GameMode)
  end
  if Lev._Name ~= MPCfgBackup.Map then
    Console:Cmd_MAP(MPCfgBackup.Map)
  end
end

function Game:BotResetWaypoints(botclientid)
  self.bot[botclientid].rotation = 1
  if 1 < math.random(2) then
    self.bot[botclientid].rotation = -1
  end
  self.bot[botclientid].state = BotStates.SearchingForWaypoint
  local changedone = false
  for i = 1, 32 do
    if not changedone and self.bot[botclientid].TargetID[33 - i] ~= -2 then
      self.bot[botclientid].TargetID[33 - i] = -2
      changedone = true
    end
  end
  if not changedone then
    repeat
      do break end -- pseudo-goto
      local botx, boty, botz = ENTITY.PO_GetPawnHeadPos(self.bot[botclientid]._Entity)
      for i = 1, 32 do
        self.bot[botclientid].mex = math.random(-10, 10)
        self.bot[botclientid].mey = boty
        self.bot[botclientid].mez = math.random(-10, 10)
        ENTITY.RemoveFromIntersectionSolver(self.bot[botclientid]._Entity)
        local b, d, wx, wy, wz = WORLD.LineTraceFixedGeom(botx, boty, botz, mex, mey, mez)
        ENTITY.AddToIntersectionSolver(self.bot[botclientid]._Entity)
        if not b then
          self.bot[botclientid].angle = math.random(2 * math.pi)
          self.bot[botclientid].state = BotStates.HeadingToWaypoint
          self.bot[botclientid].statetime = INP.GetTime() + 2
          return
        end
      end
    until true
  end
  self.bot[botclientid].statetime = INP.GetTime()
end

function Game:ChatIcon()
  local clientid = NET.GetClientID()
  local ps = Game.PlayerStats[clientid]
  local NetClientID = Game._ConsoleClientID
  if ps and not NET.IsSpectator(NET.GetClientID()) then
    if CONSOLE.IsActive() then
      if Game._MeConsoleOpened then
        NET.SendVariable(ServerID, "CHATO", clientid)
        Game._MeConsoleClosed = true
        Game._MeConsoleOpened = false
      end
    elseif not CONSOLE.IsActive() and Game._MeConsoleClosed then
      NET.SendVariable(ServerID, "CHATC", clientid)
      Game._MeConsoleClosed = false
      Game._MeConsoleOpened = true
    end
  end
  if Game._ChatIcon and Game._SomeConsoleOpened then
    if Game._SomeConsoleClosed == true and Game.PlayerStats[NetClientID] ~= nil then
      local entity = Game.PlayerStats[NetClientID]._Entity
      local team = Game.PlayerStats[NetClientID].Team
      if team == Cfg.Team then
        ReloadTeammate(entity, team)
      end
      Game._SomeConsoleClosed = false
    end
    local openedconsoles = 0
    for i, o in Game.ChatData, nil do
      if Game.PlayerStats[o.ClientID] ~= nil then
        local entity = Game.PlayerStats[o.ClientID]._Entity
        ENTITY.KillAllChildrenByName(entity, "ChatIcon")
        if entity and 0 < entity and not PMENU.Active() and (not Player or entity ~= Player._Entity) and Game.ChatData[o.ClientID].Check and Cfg.ChatIcon then
          local ei = ENTITY.Create(ETypes.Billboard, "Script", "ChatIcon")
          local t = Game.currentTime / 60
          local m = math.floor(t)
          local s = math.floor((t - m) * 4)
          local chatstyle = "ChatIcon/chat_3"
          if Cfg.ChatIcon_Anim then
            chatstyle = "ChatIcon/chat_" .. s
          end
          BILLBOARD.SetupCorona(ei, 1, 0, 0, 0, 0, 0.5, 0, 0, 0, chatstyle, Color:New(255, 255, 255, 255):Compose(), 4, true)
          ENTITY.SetPosition(ei, 0, 2.7, 0)
          WORLD.AddEntity(ei)
          ENTITY.RegisterChild(entity, ei)
          if Game.PlayerStats[o.ClientID].Team == Cfg.Team then
            ENTITY.KillAllChildrenByName(entity, "teammateIcon")
          end
        end
        if Game.ChatData[o.ClientID].Check then
          openedconsoles = openedconsoles + 1
        end
      elseif Game.PlayerStats[o.ClientID] == nil then
        Game.ChatData[o.ClientID] = nil
        Game._SomeConsoleClosed = false
      end
    end
    if openedconsoles == 0 then
      Game._SomeConsoleOpened = false
    end
  end
  Game._ChatIcon = Cfg.ChatIcon
end

function ReloadTeammate(entity, team)
  ENTITY.KillAllChildrenByName(entity, "teammateIcon")
  local teams = false
  if MPGameRules[MPCfg.GameMode] and MPGameRules[MPCfg.GameMode].Teams then
    teams = true
  end
  if entity and 0 < entity and not PMENU.Active() and teams and team == Cfg.Team and (not Player or entity ~= Player._Entity) and (Cfg.TeammateIcon == 1 or Cfg.TeammateIcon == 2) then
    local ei = ENTITY.Create(ETypes.Billboard, "Script", "teammateIcon")
    local ticon = "hud/teammate"
    local color = Color:New(255, 255, 255)
    if Cfg.TeammateIcon == 2 then
      ticon = "SHud/teammate_pro"
      color = Color:New(255, 255, 255)
      if Cfg.TeammateIcon_RGB[4] == 0 then
        if not (not teams or Cfg.Team ~= team or Cfg.FixedColors) or Cfg.FixedColors and teams and team == 0 or not teams and Player and entity == Player._Entity then
          color = Color:New(0, 0, 255)
          if Cfg.BrightskinTeam == "White" then
            color = Color:New(255, 255, 255)
          end
          if Cfg.BrightskinTeam == "Red" then
            color = Color:New(255, 0, 0)
          end
          if Cfg.BrightskinTeam == "Blue" then
            color = Color:New(0, 0, 255)
          end
          if Cfg.BrightskinTeam == "Green" then
            color = Color:New(0, 255, 0)
          end
          if Cfg.BrightskinTeam == "Black" then
            color = Color:New(0, 0, 0)
          end
          if Cfg.BrightskinTeam == "Cyan" then
            color = Color:New(0, 255, 255)
          end
          if Cfg.BrightskinTeam == "Magenta" then
            color = Color:New(255, 0, 255)
          end
          if Cfg.BrightskinTeam == "Yellow" then
            color = Color:New(255, 255, 0)
          end
          if Cfg.BrightskinTeam == "Pink" then
            color = Color:New(255, 0, 153)
          end
          if Cfg.BrightskinTeam == "Orange" then
            color = Color:New(255, 153, 0)
          end
          if Cfg.BrightskinTeam == "Purple" then
            color = Color:New(204, 0, 255)
          end
          if Cfg.BrightskinTeam == "Grey" then
            color = Color:New(153, 153, 153)
          end
          if Cfg.BrightskinTeam == "Brown" then
            color = Color:New(153, 102, 0)
          end
        else
          color = Color:New(255, 0, 0)
          if Cfg.BrightskinEnemy == "White" then
            color = Color:New(255, 255, 255)
          end
          if Cfg.BrightskinEnemy == "Red" then
            color = Color:New(255, 0, 0)
          end
          if Cfg.BrightskinEnemy == "Blue" then
            color = Color:New(0, 0, 255)
          end
          if Cfg.BrightskinEnemy == "Green" then
            color = Color:New(0, 255, 0)
          end
          if Cfg.BrightskinEnemy == "Black" then
            color = Color:New(0, 0, 0)
          end
          if Cfg.BrightskinEnemy == "Cyan" then
            color = Color:New(0, 255, 255)
          end
          if Cfg.BrightskinEnemy == "Magenta" then
            color = Color:New(255, 0, 255)
          end
          if Cfg.BrightskinEnemy == "Yellow" then
            color = Color:New(255, 255, 0)
          end
          if Cfg.BrightskinEnemy == "Pink" then
            color = Color:New(255, 0, 153)
          end
          if Cfg.BrightskinEnemy == "Orange" then
            color = Color:New(255, 153, 0)
          end
          if Cfg.BrightskinEnemy == "Purple" then
            color = Color:New(204, 0, 255)
          end
          if Cfg.BrightskinEnemy == "Grey" then
            color = Color:New(153, 153, 153)
          end
          if Cfg.BrightskinEnemy == "Brown" then
            color = Color:New(153, 102, 0)
          end
        end
      else
        color = Color:New(Cfg.TeammateIcon_RGB[1], Cfg.TeammateIcon_RGB[2], Cfg.TeammateIcon_RGB[3], 255)
      end
    end
    BILLBOARD.SetupCorona(ei, 0.9, 0, 0, 0, 0, 0.5, 0, 0, 0, ticon, color:Compose(), 1, true)
    ENTITY.SetPosition(ei, 0, 2.7, 0)
    WORLD.AddEntity(ei)
    ENTITY.RegisterChild(entity, ei)
  end
end

function PressedKey()
  if INP.Key(FKeys[Cfg.KeyPrimaryQuit]) == 1 or INP.Key(FKeys[Cfg.KeyAlternativeQuit]) == 1 then
    Console:Cmd_QUIT()
  end
  if INP.Key(FKeys[Cfg.KeyPrimaryVoteYes]) == 1 or INP.Key(FKeys[Cfg.KeyAlternativeVoteYes]) == 1 then
    Console:Cmd_VOTE("yes")
  end
  if INP.Key(FKeys[Cfg.KeyPrimaryVoteNo]) == 1 or INP.Key(FKeys[Cfg.KeyAlternativeVoteNo]) == 1 then
    Console:Cmd_VOTE("no")
  end
  if INP.Key(FKeys[Cfg.KeyPrimaryReadyUnready]) == 1 or INP.Key(FKeys[Cfg.KeyAlternativeReadyUnready]) == 1 then
    local ps = Game.PlayerStats[NET.GetClientID()]
    if ps.State == 0 then
      Console:Cmd_READY()
    elseif ps.State == 1 then
      Console:Cmd_NOTREADY()
    end
  end
  if INP.Key(FKeys[Cfg.KeyPrimaryTeam]) == 1 or INP.Key(FKeys[Cfg.KeyAlternativeTeam]) == 1 then
    if Cfg.Team == 0 then
      Console:Cmd_TEAM(2)
    elseif Cfg.Team == 1 then
      Console:Cmd_TEAM(1)
    end
    if MPCfg.GameMode == "Capture The Flag" or MPCfg.GameMode == "ICTF" then
      for i = 1, 2 do
        local entity = Game.FlagEntityData[i].Entity
        local param = Game.FlagEntityData[i].Param
        Templates["Flag.CItem"]:Client_OnCreateSimpleItems(entity, param)
      end
    end
  end
  if INP.Key(FKeys[Cfg.KeyPrimaryBreak]) == 1 or INP.Key(FKeys[Cfg.KeyAlternativeBreak]) == 1 then
    Console:Cmd_BREAK()
  end
  if INP.Key(FKeys[Cfg.KeyPrimaryKill]) == 1 or INP.Key(FKeys[Cfg.KeyAlternativeKill]) == 1 then
    Console:Cmd_KILL()
  end
  if INP.Key(FKeys[Cfg.KeyPrimarySpectator]) == 1 or INP.Key(FKeys[Cfg.KeyAlternativeSpectator]) == 1 then
    Console:Cmd_SPECTATOR(1)
  end
  if INP.Key(FKeys[Cfg.KeyPrimaryDisconnect]) == 1 or INP.Key(FKeys[Cfg.KeyAlternativeDisconnect]) == 1 then
    Console:Cmd_DISCONNECT()
  end
  if INP.Key(FKeys[Cfg.KeyPrimaryNetStats]) == 1 or INP.Key(FKeys[Cfg.KeyAlternativeNetStats]) == 1 then
    if not Game.SetStatsShow then
      NET.SetStatsShow(true)
      Game.SetStatsShow = true
    else
      NET.SetStatsShow(false)
      Game.SetStatsShow = false
    end
  end
end
