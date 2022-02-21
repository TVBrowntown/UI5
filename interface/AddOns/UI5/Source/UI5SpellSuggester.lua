UI5.SpellSuggester = {}

--[[

	Spell Suggester suggests what spells to use depending on the target.
	Consider it like a priority list. If you have a DoT you should keep
	on a target it that spell will go to the top of the Queue then
	disappear when it is currently on your target.

	Spell Suggester appears only when you have a hostile target.

	A maximum of 5 spells will be shown at a time. There is a 6th that
	is queued up, but not in view.

	Will not suggest something that is not currently available.

	1 = always at the top

]]--

local iconSize = {
	48,
	48
}

local spellListed = {}

			--spellId, priority, mechanic
local spell01 = {  111, 		  1,	   0} -- Yer Bleedin' Ailment (always 1)
local spell02 = {  111, 		  1,	   0} -- Rotten Arrer (always 1)
local spell03 = {  111, 		  1,	   0} -- What Blocka (if tank 1, if melee 1)
local spell04 = {  111, 		  1,	   0} -- Shrapnel Arrer (Bright Wiz, Archmage, Rune Priest, Shadow Warrior)
local spell05 = {  111, 		  1,	   0} -- Red Tipped Arrer (if they have damage absorb shields on, can parse combat chat for "absorbs")
local spell06 = {  111, 		  1,	   0} -- Choking Arrer - BW, AM, Rune Priest (silences them)
local spell07 = {  111, 		  1,	   0} -- Behind Ya! straight to top if you're behind them and they are on 50% or below
local spell08 = {  111, 		  1,	   0} -- Stop running - snare
local spell09 = {  111, 		  1,	   0} -- Not so Fast - knockdown
local spell10 = {  111, 		  1,	   0} -- Drop that - disarm! (WH, WL, SW, Slayer)

-- because SH has no special mechanic just set to 0 (all phases of mechanic)

function UI5.Spell01Logic()
	-- first, is the spell in queue already?
	-- no?
	-- does target have Yer Bleedin?
	-- if no, set priority number 1 UNLESS
	-- Rotten arrer already number 1? Set priority 2.

	-- table.insert(spellListed, QueuePrio, SpellId)
end

function UI5.ConditionCheck(conditionType, modifierType, )
--[[
	1 hasEffect (modifierType) -- 1 timeLeft, 2
	2 hasntEffect
	3 HP(modifierType) --1 below, 2 equal to, 3 greater than, 4 not
	4 spellAvailable
	5 mechanicValue
]]

end

function UI5.SuggestSpells()


function UI5.DrawSpell()

end

function UI5.UpdatePositions()

end

function UI5.SSOnUpdate()
	-- check available spells, run a throttle as well
	-- get CDs and change priority if possible
end

--[[

1	
table.concat (table [, sep [, i [, j]]--[[)

Concatenates the strings in the tables based on the parameters given. See example for detail.

2	
table.insert (table, [pos,] value)

Inserts a value into the table at specified position.

3	
table.maxn (table)

Returns the largest numeric index.

4	
table.remove (table [, pos])

Removes the value from the table.

5	
table.sort (table [, comp])

Sorts the table based on optional comparator argument.


]]