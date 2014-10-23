Painkiller++ (Revised)
===================
Be sure to visit [PKZone.org](http://pkzone.org)
	And [#Painkiller](http://webchat.quakenet.org/?channels=painkiller&uio=MTE9MzY5cf) on Quakenet IRC

Watch development LIVE on the [Developer Stream](http://www.twitch.tv/threshersgaming)

Thanks for the support!

----------


Updates
-------------
**October 22nd 2014**

 - FIXED Race Timer on HUD, now displays seconds properly
	 - This fix took place in RaceTimeString function in Utils.lua
	 - Timer now has it's own function 
 - Experimenting with Race Start/Finish line particle FX
	 - Need model for starting/finish line
 - ADDED Race Start/Finish line to RACE_JumpMap_01 ( DM_JumpMap_01, by shadow )
	 - A great map for Race mode, check it out!! :)
 - ADDED Players best race time to scoreboard
 - ADDED Spectator Item Timers
	 - Item timers for Armor(s) and Mega Health on the map for SPECTATORS ONLY
	 - Thinking I should maybe add Megapack (ammo) as well, thoughts? It's an important item for a few maps.
	 - I want to add more customization for this, right now it's fixed to the upper left beneath chat
	 - Great tool for casters to keep track of item times o/
 - CHANGED Race to be a "non-team" mode, this change is reflected on the scoreboard 
	 - I'm not sure if this created other bugs, please let me know
 - FIXED the "map does not match servers" to say what it should say, that the player doesn't have the map, gives them the option to visit PKZone.org map repository
 

**October 14th 2014**

 - Added Race Timer on HUD
	 - Cfg.RaceTimeX, Cfg.RaceTimeY, and Cfg.RaceTimeSize added to Config to move the timer around
 - Added RaceCheck.CItem Entity
	 - Allows More than one person to race at a time! \ o /
	 - Using Flag model for starting line and Checkpoint model for finish line
	 - Added default sounds for when a player starts/ends a race, possibly need new sounds
	 - Need to clean up Flag.CItem so that it doesn't contain old race code
	 - Need to clean up RaceCheck:Tick(), it's a mess right now
	 - Need Language translations for "Player starts race" and "Player finishes race in"
 - Updated MAP: RACE_Psycho
	 - Replaced Flag.CItem with new RaceCheck.CItem
	 - Moved a slab that was causing some issues with being caught in Gold Armor room
	 - Please remove all previous iterations from your /Data/ folder!
 

**October 10th 2014**

 - Added autoexec.ini
	 - autoexec.ini WILL NOT be overwritten
	 - create autoexec.ini in your Painkiller/Bin/ directory, it will exec automatically on game start
 - /exec (insert_config_name).ini in console no longer overwrites config :)
 - Slabs are now loaded in multiplayer, they are a bit buggy for some things, but basic functionality is there.
 - Enforcing maxfps of 125 (PK++ 1.3 did it, so will we...?)
 - **Race Mode**!
	 - Still has bugs but functions in it's basic form
	 - Not fully functional
	 - Players are "ghosts" to other players
		 - Explosions still affect other players, not sure if we can change this (boo closed source projects)
	 - Rockets, Stakes, Grenades, and other Projectile ammo will go 'through' other players
	 - Only one person can "race" at a time
	 - /kill respawns flag
	 - updated RACE_Psycho
 - /callvote map race_* now longer throws an error
 - DM_Amphi_11 included thanks to Stebe! o/
 

----------


Building Source
-------------------

TO DO