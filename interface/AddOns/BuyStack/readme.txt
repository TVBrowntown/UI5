BuyStack - strassenflirt@gmail.com
----------------------------------

When you have a tradeskill for which you need to buy large stacks of trading items it is very uncomfortable.
Either you rightclick and get only one item, or you shift-leftclick, have to enter a number and then have to manually put the stack in your bag.

Here comes BuyStack!
When you CRTL-rightclick on any item at a trader you automatically buy a whole bunch of that item that is put directly in your bags.


These are the options:

/bs option [value]
size 'value' -- set the stacksize to 'value' (default 20, min. 1)
s[ettings] -- list the current settings.

The key is hardcoded to CRTL-rightclick at the moment, but if at a later time any other addon or the default ui might get in conflict with that, I will make it configurable.

Revision history
----------------
1.2 - 
Settings are now saved per character.

You can set AutoBuy amounts for each item. Clicking to buy a stack then only buys upto the set amount to AutoBuy.

/bs b 'value' -- set mouse and key(s) for buying to 'value' (combination of ('left' or 'right'), 'shift', 'alt' and 'ctrl'), example: 'left shift alt'.
/bs ab 'value' -- set mouse and key(s) for autobuying to 'value' (combination of ('left' or 'right'), 'shift', 'alt' and 'ctrl'), example: 'right ctrl alt'.

For those that do not understand the functionality :-) here is a description.

Lets say you want to set buying of stacks to the left mouse button together with pressing SHIFT and CTRL.
You enter "/bs b left shift ctrl".

Same goes for setting an AutoBuy amount for an item:
You want that on the right mouse button together with pressing ALT and CTRL.
You enter "/bs ab right alt ctrl".

If you want to delete an AutoBuy setting for an item, click with your AutoBuy settings and the same set stack size on that item again.

Example 1:
AutoBuy for item X is set to 20. If you want to change the stack size for that item to 40, set the default stack size to 40 first with "/bs size 40" and then click the AutoBuy keys -> the AutoBuy amount for X will be set to 40.

Example 2:
AutoBuy for item X is set to 20. If you want to delete the setting for that item, make sure that the default stack size is set to the same value 20. Click the AutoBuy keys -> the AutoBuy setting for X will be deleted. Clicking twice with your AutoBuy keys will therefore always delete the setting.

You can check if you have done it right by entering "/bs s".
I hope everyone understands this as I do not know how to explain it better. :-)

1.1 - changed kind of hooking to delete a bug

1.0 - initial release