UI5.extendedAudio = {}

sndParried 	= "parried1"
sndDodged	= "dodged1"
sndScPop	= "pop1"
sndBlocked	= "blocked1"
sndAbsorbed	= "absorbed1"
sndRenTick	= "renown1"
sndCritHit	= "crit1"
sndFriLogI	= "f_login1"
sndFriLogO	= "f_logout1"
sndKeepLor	= "keeplord1"
sndWhisper	= "whisper1"
sndFort		= "fort1"
sndCityOpn	= "city1"
sndMention	= "namecalled1"

settings = {

	RenownTick = { true },
	CriticalHit = { true },
	FriendLogin = { true },
	FriendWhisper = { true },
	NameMentioned = { true },
	ScenarioPop = { true },
	KeepUnderAttack = { true },
	KeepLordAttack = { true },
	FortOpen = { true },
	FortBeforeCity = { true },
	justParried = { true },
	justAbsorbed = { true },
	justDodged = { true },
	justParried = { true }
}

UI5.logFileName = "UI5extendedAudio"

    --PlayerName = wstring.sub(GameData.Player.name,1,-3)
    --Language = SystemData.Settings.Language.active

function UI5.extendedAudioSetup()
	-- sets up which queues will proc extended audio sounds.
	TextLogCreate(UI5.logFileName, 18000)
	TextLogSetEnabled(UI5.logFileName, true)
	TextLogSetIncrementalSaving(UI5.logFileName, true, StringToWString("logs/"..UI5.logFileName..".log"))
    RegisterEventHandler(SystemData.Events.SCENARIO_SHOW_JOIN_PROMPT, "UI5.RecordScPop")
    d("extendedAudio setup!")
end

function UI5.extendedAudioHowTo()

end

function UI5.extendedAudioOptions()

end

function UI5.extendedAudioCallAudio()

end

function UI5.extendedAudioParser()

end

function UI5.RecordSound(soundName)
	--must be a string
	soundName = soundName
    UI5.logSoundToPlay(soundName)
end

function UI5.RecordScPop()
	PlaySound(500)
	-- temporary in-client sound
    UI5.logSoundToPlay(sndScPop)
end

function UI5.logSoundToPlay(soundName)
	--checks that a second has passed
	--local timeCheck = timeCheck
	--if timeCheck >= timeCheck + 1 or timeCheck == nil then
    if LastComment ~= soundName then
    --old method; can add an exception for particular sounds, like parry, etc.
        TextLogAddEntry(UI5.logFileName, 0, towstring(soundName))
        TextLogSaveLog(UI5.logFileName,towstring(""))
        LastComment = soundName
    end
	--timeCheck = GetComputerTime()
end

function UI5.clearLogFile()
	TextLogDestroy("UI5")
	TextLogCreate(UI5.logFileName, 18000)
	TextLogSetEnabled(UI5.logFileName, true)
	TextLogSetIncrementalSaving(UI5.logFileName, true, StringToWString("logs/"..UI5.logFileName..".log"))	
end