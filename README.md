Painkiller++ (Revised)
===================
Be sure to visit [PKZone.org](http://pkzone.org)
	And [#Painkiller](http://webchat.quakenet.org/?channels=painkiller&uio=MTE9MzY5cf) on Quakenet IRC

Watch development LIVE on the [Developer Stream](http://www.twitch.tv/threshersgaming)

Thanks for the support!

----------


Updates
-------------

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