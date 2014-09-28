------------------------------------------------------------------------
-- Joseph Weizenbaum's classic Eliza ported to SciTE
-- Kein-Hong Man <khman@users.sf.net> 20050117
-- This program is hereby placed into PUBLIC DOMAIN
------------------------------------------------------------------------
-- HOW TO USE
--   This program is for recreational purposes only. :-)
--   Create or load a file named "eliza" and type away...
--   Eliza will not interfere with other open files.
--   If you have existing event handlers, edit the handlers below...
------------------------------------------------------------------------
-- Original ELIZA paper:
--   ELIZA--A Computer Program For the Study of Natural Language
--   Communication Between Man and Machine,
--   Joseph Weizenbaum, 1966, Communications of the ACM Volume 9,
--   Number 1 (January 1966): 36-35.
--   URL: http://i5.nyu.edu/~mm64/x52.9265/january1966.html
------------------------------------------------------------------------
-- A copy of the original BASIC source of this Lua version of ELIZA can
-- be found at Josep Subirana's ELIZA download page.
------------------------------------------------------------------------
-- NOTES
-- * Modifications made to fit the program into SciTE...
-- * For historical accuracy, functionality is more-or-less identical,
--   as is the use of an all upper-case alphabet for output.
-- * There is really no point extending this program. Many other more
--   advanced Eliza-type programs exist. Good candidates for porting are
--   EMACS' doctor.el and Perl's Chatbot-Eliza. If I am really bored one
--   of these days, maybe I'll do it...
-- * One difference is keyword are matched by iterating through a hash
--   array, so matching order will be different from initialization order.
-- * In order to avoid keeping any internal state, this Eliza does not
--   remember your name.
-- * Input is now case-insensitive.
-- * The original used backticks for apostrophes, this was fixed.
-- * A couple of spelling mistakes in strings and comments fixed.
------------------------------------------------------------------------

--<snip>

------------------------------------------------------------------------
-- Eliza
-- * Input is case insensitive. No punctuation except apostrophes,
--   as in: don't you're i'm i've you've.
------------------------------------------------------------------------

function Eliza(text)
  local response = ""
  local user = string.upper(text)
  local userOrig = user

  -- randomly selected replies if no keywords
  local randReplies = {
    "EXPLAIN?",
    "ERM",
    "WHAT DO YOU MEAN?",
    "ER?",
    "OK...",
    "YEAH",
    "HMMM OKAY",
    "YE",
    "...",
    "EH?",
    "OK",
    "HMMM",
    "BLAH",
    "WHATEVER",
    "JUST PLAY?",
  }

  -- keywords, replies
  local replies = {
    [" HOW ARE YOU"] = "I AM FINE THANKS :)",
    [" READY"] = "I AM READY.. GOGOGO",
    [" STOP"] = "ERM ... NO",
    [" HOW *"] = "OK",
    [" CAN YOU"] = "PERHAPS YOU WOULD LIKE TO BE ABLE TO",
    [" DO YOU"] = "YES",
    [" CAN I"] = "PERHAPS YOU DON'T WANT TO BE ABLE TO",
    [" YOU ARE"] = "WHAT MAKES YOU THINK I AM",
    [" YOURE *"] = "WHAT DO YOU THINK OF ME BEING *",
    [" I DONT"] = "WHY DON'T YOU",
    [" I FEEL"] = "TELL ME MORE ABOUT FEELING",
    [" WHY DON'T YOU"] = "WHY WOULD YOU WANT ME TO",
    [" WHY CAN'T I"] = "WHAT MAKES YOU THINK YOU SHOULD BE ABLE TO",
    [" I CAN'T"] = "HOW DO YOU KNOW YOU CAN'T",
    [" PING"] = "IT FEELS LAGGY.",
    [" LAG"] = "YOUR CONNECTION?",
    [" WARP"] = "HEH",
    [" I AM *"] = "HOW LONG HAVE YOU BEEN *",
    [" IM"] = "WHY ARE YOU TELLING ME YOURE",
    [" I WANT"] = "WHY DO YOU WANT",
    [" WHAT"] = "WHAT DO YOU THINK?",
    [" WHO"] = "DOES IT MATTER?",
    [" WHERE"] = "WHY DID YOU THINK OF THAT?",
    [" WHEN"] = "GUESS?",
    [" WHY"] = "WHAT IS IT THAT YOU REALLY WANT TO KNOW?",
    [" PERHAPS"] = "YOU'RE NOT VERY FIRM ON THAT!",
    [" SHOT"] = "ALL SKILL.",
    [" SORRY"] = "WHY SAY SORRY?",
    [" AIM"] = "ALL AIM :O)",
    [" I LIKE"] = "IS IT GOOD THAT YOU LIKE",
    [" MAYBE"] = "TRY AND DECIDE?",
    [" NO"] = ":<",
    [" YOUR *"] = "WHAT ABOUT MY *",
    [" ALWAYS"] = "CAN YOU THINK OF WHEN?",
    [" THINK"] = "DO YOU DOUBT",
    [" YES"] = ":>",
    [" CHEATING"] = "CHEATS ARE LAME",
    [" CHEAT"] = "JUST AIM",
    [" YOU ARE A BOT"] = "NO, IM NOT A BOT",
    [" ARE YOU A BOT?"] = "NOPE, JUST GOOD :)",
    [" BOT"] = "BOT?",
    [" FROM?"] = "I AM FROM ENGLAND",
    [" SKILL"] = "ME = SKILL",
    [" CAMP"] = "WHO DO YOU THINK IS CAMPING?",
    [" LAMER"] = "WHAT DOES LAMER MEAN?",
    [" STAKE"] = "SKILLZ",
    [" ARMOUR"] = "ARMOUR IS FOR NOOBS",
    [" SHOOT"] = "SKILLZ DUDE",
    [" WTF"] = "HAHA",
    [" CUNT"] = "BE NICE :)",
    [" FUCK"] = "OI BE NICE IM ONLY 12",
    [" FU"] = "FU 2 :)",
    [" AIMBOT"] = "HAHA YEAH SURE",
    [" AM I"] = "YOU ARE",
    [" HI"] = "HI",
    [" LO"] = "HI",
    [" HELLO"] = "HEY",
    [" HIYA"] = "HI",
    [" GG"] = "GG",
    [" GL"] = "HF",
    [" HF"] = "GL",
    [" LAME"] = "HEH",
    [" SUCK"] = "DONT WHINE",
  }

  -- conjugate
  local conjugate = {
    [" I "] = "YOU",
    [" ARE "] = "AM",
    [" WERE "] = "WAS",
    [" YOU "] = "ME",
    [" YOUR "] = "MY",
    [" IVE "] = "YOUVE",
    [" IM "] = "YOURE",
    [" ME "] = "YOU",
    [" AM I "] = "YOU ARE",
    [" AM "] = "ARE",
  }
  	
  local responsearray = {}
  local responseindex = 0
  
  -- random replies, no keyword
  local function replyRandomly()
    response = randReplies[math.random(table.getn(randReplies))]
  end

  -- find keyword, phrase
  local function processInput()

  
    for keyword, reply in pairs(replies) do
      local d, e = string.find(user, keyword, 1, 1)
      if d then
        -- process keywords
        response = response..reply..""
        if string.byte(string.sub(reply, -1)) < 65 then -- "A"
          response = response;return
        end
        local h = string.len(user) - (d + string.len(keyword))
        if h > 0 then
          user = string.sub(user, -h)
        end
        for cFrom, cTo in pairs(conjugate) do
          local f, g = string.find(user, cFrom, 1, 1)
          if f then
            local j = string.sub(user, 1, f - 1).." "..cTo
            local z = string.len(user) - (f - 1) - string.len(cTo)
            response = response..j
            if z > 2 then
              local l = string.sub(user, -(z - 2))
              if not string.find(userOrig, l) then return end
            end
            if z > 2 then response = response..string.sub(user, -(z - 2)) end
            if z < 2 then response = response  end
            return
          end--if f
        end--for
        response = response 
        return
      end--if d
    end--for
    replyRandomly()
    return
  end

  -- main()
  -- accept user input
  if string.sub(user, 1, 3) == "BYE" then
    response = "TTFN"
    return response
  end
  if string.sub(user, 1, 7) == "BECAUSE" then
    user = string.sub(user, 8)
  end
  user = " "..user.." "
  -- process input, print reply
  processInput()
  response = response
  return response
end

-- end of script

