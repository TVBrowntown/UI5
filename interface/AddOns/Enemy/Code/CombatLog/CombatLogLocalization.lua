
function Enemy.CombatLogInitLocalization ()

	Enemy.localization.combatLogParse_strCrit =
	{
		enUS = L"critically "
	}
	Enemy.localization.combatLogParse_strBlock =
	{
		enUS = L"blocked"
	}
	Enemy.localization.combatLogParse_strParry =
	{
		enUS = L"parried"
	}
	Enemy.localization.combatLogParse_strDodge =
	{
		enUS = L"dodged"
	}
	Enemy.localization.combatLogParse_strDisrupted =
	{
		enUS = L"disrupted"
	}
	Enemy.localization.combatLogParse_strYou =
	{
		enUS = L"you"
	}
	Enemy.localization.combatLogParse_regexMitigation =
	{
		enUS = L"(%d+) mitigated"
	}
	Enemy.localization.combatLogParse_regexAbsorb =
	{
		enUS = L"(%d+) absorbed"
	}
	Enemy.localization.combatLogParse_regexOverheal =
	{
		enUS = L"(%d+) overhealed"
	}
	Enemy.localization.combatLogParse_regexIncommingDamage =
	{
		enUS = L"^(.-)'s (.-) ([critically% ]*)hits you for (%d+) damage%.(.*)"
	}
	Enemy.localization.combatLogParse_regexIncommingDamageFromSelf =
	{
		enUS = L"^Yours? (.-) ([critically%s]*)hits (.-) for (%d+) damage%.(.*)"
	}
	Enemy.localization.combatLogParse_regexIncommingDamageIgnored =
	{
		enUS = L"^You (.-) (.-)'s (.-)%."
	}
	Enemy.localization.combatLogParse_regexOutgoingDamage =
	{
		enUS = L"^Yours? (.-) ([critically%s]*)hits (.-) for (%d+) damage%.(.*)"
	}
	Enemy.localization.combatLogParse_regexOutgoingDamageIgnored =
	{
		enUS = L"^(.-) (%w+) yours? (.-)%."
	}
	Enemy.localization.combatLogParse_regexOutgoingPetDamage =
	{
		enUS = L"^(.-)'s (.-) ([critically%s]*)hits (.-) for (%d+) damage%.(.*)"
	}
	Enemy.localization.combatLogParse_regexOutgoingPetDamageIgnored =
	{
		enUS = L"^(.-) (%w+) (.-)'s (.-)%."
	}
	Enemy.localization.combatLogParse_regexOutgoingHeal =
	{
		enUS = L"^Yours? (.-) ([critically%s]*)heals (.-) for (%d+) points%.(.*)"
	}
	Enemy.localization.combatLogParse_regexIncommingHealYours =
	{
		enUS = L"^Yours? (.-) ([critically%s]*)heals (.-) for (%d+) points%.(.*)"
	}
	Enemy.localization.combatLogParse_regexIncommingHeal =
	{
		enUS = L"^(.-)'s (.-) ([critically%s]*)heals you for (%d+) points%.(.*)"
	}
end


-- Will be called after all localization and parse functions has been assigned
function Enemy.CombatLogFixLocalization (g)
end