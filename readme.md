--entityEnumerator Written by IllidanS4
--[[
The MIT License (MIT)
Copyright (c) 2017 IllidanS4
Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:
The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
]]

--[[
===========================================================================================================================
 VenomXNL's "Upgraded" Ride Animals Script (XNLRideAnimals)
 Based on the (Lua) script 'Ride a deer for FiveM' (fivem-ride-a-deer)
 Original script: https://github.com/FrazzIe/fivem-ride-a-deer
 Original Script was based on: https://www.gta5-mods.com/scripts/ride-a-deer
 entityEnumerator Written by IllidanS4
===========================================================================================================================

Improvements/Upgrades made:
 - You CAN NOT spawn the animals with keybinds anymore (we did not needed
   nor wanted this on our 'realism RP server'), so you will HAVE to approach the
   'real wild life' animals yourself
 - You can now ride the Deer, (Wild Boar) and Cows!(YES COWS HAHAHA)
 - Added checks for if your animal has tripped/been hit by a car/killed etc,
   this will make the player fall off (ragdoll shortly)
 - If the PLAYER dies on top of the animal he/she will also fall off with ragdoll
 - Checks for if the animal is already dead when trying to 'board it'
   - Same goes for when it's getting up or falling at that moment.
 - Checks if the animal you're trying to 'board' is not already occupied by another
   player 
 - Set the player to unarmed when he/she boards the animal to prevent the peds of feds
   to 'freak out' when you (accidentally) press your aim key/button.
 - Different posses on the animal to match better with the game
 - The character does make some 'idle movements' so it doesn't look like a 'concrete block' on top of the animal
 - You will need to gain control of the animal when you 'board it' by tapping the indicated key else you'll fall off. 
	  The animal will FLEE AGAIN when you try to re-board it after you get off or fallen off (it still is a WILD animal!)
  - The player position is now actually 'front facing' which also makes it possible to ride the animals in First Person
  
Important to know:
  This script does NOT use MissionEntity's or Persitant Entity's, nor does it make them from
  the animal's you are riding. This means that it will/should not create 'left over objects'.
  BUT it MIGHT also cause the animal to de-sync sometimes (althoug it did NOT happen when we tested
  it, not even when teleporting (NEWLY SPAWNED) players from across the map to a animal riding player)
   
Expected question(s): 
 - Q: If it's for your "realism server", then why the hell include this 'mini game'?
   A: Well simple: Like a few of our players (which requested this also btw) stated:
      in real life you "could technically also ride/board those animals", although it's
	  HIGHLY unrecommended..... And secondly: While it's a realism server, it doesn't mean
	  it can't include some funny 'weird sh*t which would also be possible in real life' haha
	  
 - Q: The cows are somewhat 'addicted to go left often' while I want or try to make it go right, why?
   A: First of: Have you ever boarded a cow in real life and tried to make it go where you would want it to go? :P haha
      secondly: I have no freaking clue, but we wanted to leave it this way to make it 'harder to ride them' haha

 - Q: Can you/will you add other animals to like a pig, dog etc? 
   A: Hell no, first of it would not fit (sizes don't match up well enough), and secondly the other animals
      available are not nearly as "ridable" as these three would be in real life (although I still DO NOT
	  recommend to even try this in real life! haha) 

 - Q: Can you make it so that the animal will stay tame when you gained control and you re-board it (Like in RDR for example)?
   A: Yes I can, and I HAD in this mod but it 'messedup' the WILD animal realism to much, to I've DELETED
      the code, and NOPE: I'm sorry but I will not rewrite it due to lack of time, it is however fairly simple
	  and would just involve remembering the last refrence and comparing it to 'the current boarding' (and some
	  entity exists checks). Again: sorry no time to 'rewrite' this code.
	  
 Known "bugs/issues":
  - Some poses on top of the animal are 'not perfect' and might cause some slight clipping
  - Running with the animal is 'not that great'
  - Might cause way to much laughter than was intended :P
===========================================================================================================================