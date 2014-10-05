CMusicEnv = 
{
    _IsME = true,    

    Music = 
    {
        Ambient = {},
        AmbientOverwrite = false,
        Battle = {},
        BattleOverwrite = false,
    },

    s_SubClass = {    
        _boxColor = R3D.RGB(200,200,200),
    },
    s_Editor = {
        ["Music.Ambient.[new]"]  = { "BrowseEdit",  {"*.mp3", "data\\music\\",true} },
        ["Music.Battle.[new]"]   = { "BrowseEdit",  {"*.mp3", "data\\music\\",true} },
    },
    _Class = "CMusicEnv"
}
Inherit(CMusicEnv,CBox) 

function CMusicEnv:OnApply()
end
