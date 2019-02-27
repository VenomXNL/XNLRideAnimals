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
]]

--===========================================================================================================================
-- 'Event Functions' You can use to trigger events/actions on your server/gamemode
--===========================================================================================================================
function OnPlayerBoardAnimal()
	-- You could use these calls to for example save stats of players on how many times they
	-- have ridden animals or so. 
	-- NOTE: I WILL NOT make such scripts or help with them, since those heavily depend on what
	-- YOU need or want, and also on your type of data(base) storage. 
end

function OnPlayerLeaveAnimal()
	-- You could use these calls to for example save stats of players on how many times they
	-- have ridden animals or so. 
	-- NOTE: I WILL NOT make such scripts or help with them, since those heavily depend on what
	-- YOU need or want, and also on your type of data(base) storage. 

	-- The reason I have a OnPlayerBOARDAnimal AND a OnPlayerLeaveAnimal is because we also
	-- keep track of riding time(s), and we do checks for when a farmer for example has 'exit' his
	-- cow to put it in the barn(s)
end

function OnPlayerRequestToRideAnimal()
	-- Check for 'own conditions' on our server if the player is allowed at that time to
	-- even ride/board animals. You could also use that function for example to 'exclude' wanted
	-- players from riding/boarding animals.
	
	-- We for example use it to check if the player has obtained a special perk which makes him/her able
	-- to ride these animals.
	return true
end

--===========================================================================================================================
-- (Global) Script Declarations
--===========================================================================================================================
local HelperMessageID = 0
AnimalControlStatus =  0.05

local Animal = {
	Handle = nil,
	Invincible = false,
	Ragdoll = false,
	Marker = false,
	InControl = false,
	IsFleeing = false,
	Speed = {
		Walk = 2.0,
		Run = 3.0,
	},
}

--===========================================================================================================================
-- Enitiy Enumerator Section
--===========================================================================================================================
local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end
		enum.destructor = nil
		enum.handle = nil
	end
}

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end
	
		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)
	
		local next = true
		repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
		until not next
	
		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function GetNearbyPeds(X, Y, Z, Radius)
	local NearbyPeds = {}
	for Ped in EnumeratePeds() do
		if DoesEntityExist(Ped) then
			local PedPosition = GetEntityCoords(Ped, false)
			if Vdist(X, Y, Z, PedPosition.x, PedPosition.y, PedPosition.z) <= Radius then
				table.insert(NearbyPeds, Ped)
			end
		end
	end
	return NearbyPeds
end

--===========================================================================================================================
-- Animal Related Fuctions
--===========================================================================================================================
function Animal.Attach()
	local Ped = PlayerPedId()

	FreezeEntityPosition(Animal.Handle, true)
	FreezeEntityPosition(Ped, true)

	local AnimalPosition = GetEntityCoords(Animal.Handle, false)
	SetEntityCoords(Ped, AnimalPosition.x, AnimalPosition.y, AnimalPosition.z)

	AnimalName = "Deer"
	AnimalType = 1
	XAminalOffSet = 0.0 -- Default DEER offset
	AnimalOffSet  = 0.2  -- Default DEER offset
	--if GetEntityModel(Animal.Handle) == GetHashKey('a_c_cow') then AnimalOffSet = 0.2 end
	
	if GetEntityModel(Animal.Handle) == GetHashKey('a_c_cow') then 
		AnimalName = "Cow"
		AnimalType = 2
		AnimalOffSet  = 0.1
		XAminalOffSet = 0.1
	end
		
	if GetEntityModel(Animal.Handle) == GetHashKey('a_c_boar') then 
		AnimalName = "Boar"
		AnimalOffSet = 0.3
		AnimalType = 3
		XAminalOffSet = -0.0
	end

	if (HelperMessageID > 2 or HelperMessageID < 2) and not Animal.InControl then
		DisplayHelpText('Keep tapping ~INPUT_VEH_ACCELERATE~ to get control of the ' .. AnimalName)
		HelperMessageID = 2
		AnimalControlStatus = 0.05
	end

	SetCurrentPedWeapon(Ped, "weapon_unarmed", true)	-- Sets the player to unarmed (no weapons), 
														-- it could "freak out" Peds or Feds, and 'space the weapon' through the animal
	AttachEntityToEntity(Ped, Animal.Handle, GetPedBoneIndex(Animal.Handle, 24816), XAminalOffSet, 0.0, AnimalOffSet, 0.0, 0.0, -90.0, false, false, false, true, 2, true)

	if AnimalType == 1  then
		RequestAnimDict("amb@prop_human_seat_chair@male@generic@base")
		while not HasAnimDictLoaded("amb@prop_human_seat_chair@male@generic@base") do
			Citizen.Wait(250)
		end
		TaskPlayAnim(Ped, "amb@prop_human_seat_chair@male@generic@base", "base", 8.0, 1, -1, 1, 1.0, 0, 0, 0)
	elseif AnimalType == 2 or AnimalType == 3 then
		RequestAnimDict("amb@prop_human_seat_chair@male@elbows_on_knees@idle_a")
		while not HasAnimDictLoaded("amb@prop_human_seat_chair@male@elbows_on_knees@idle_a") do
			Citizen.Wait(250)
		end

		TaskPlayAnim(Ped, "amb@prop_human_seat_chair@male@elbows_on_knees@idle_a", "idle_a", 8.0, 1, -1, 1, 1.0, 0, 0, 0)
	end
	--TaskPlayAnim(Ped, "rcmjosh2", "josh_sitting_loop", 8.0, 1, -1, 2, 1.0, 0, 0, 0)

	
	FreezeEntityPosition(Animal.Handle, false)
	FreezeEntityPosition(Ped, false)
	OnPlayerBoardAnimal() -- Used to do some 'extra stuff' on our server when a player has boarded an animal
						  -- you can also use it to for example save stats like: Ridden Animals: [number of times]
end

function Animal.Ride()
	local Ped = PlayerPedId()
	local PedPosition = GetEntityCoords(Ped, false)
	if IsPedSittingInAnyVehicle(Ped) or IsPedGettingIntoAVehicle(Ped) then
		return
	end

	local AttachedEntity = GetEntityAttachedTo(Ped)

	if (IsEntityAttached(Ped)) and (GetEntityModel(AttachedEntity) == GetHashKey("a_c_deer") or GetEntityModel(AttachedEntity) == GetHashKey("a_c_cow") 
	    or GetEntityModel(AttachedEntity) == GetHashKey("a_c_boar")) then
		local SideCoordinates = GetCoordsInfrontOfEntityWithDistance(AttachedEntity, 1.0, 90.0)
		local SideHeading = GetEntityHeading(AttachedEntity)

		SideCoordinates.z = GetGroundZ(SideCoordinates.x, SideCoordinates.y, SideCoordinates.z)

		Animal.Handle = nil
		Animal.InControl = false
		DetachEntity(Ped, true, false)
		ClearPedSecondaryTask(Ped)
		ClearPedTasksImmediately(Ped)

		AminD2 = "amb@prop_human_seat_chair@male@elbows_on_knees@react_aggressive"
		RequestAnimDict(AminD2)
		while not HasAnimDictLoaded(AminD2) do
			Citizen.Wait(0)
		end
		TaskPlayAnim(Ped, AminD2, "exit_left", 8.0, 1, -1, 0, 1.0, 0, 0, 0)
		Wait(100)
		SetEntityCoords(Ped, SideCoordinates.x, SideCoordinates.y, SideCoordinates.z)
		SetEntityHeading(Ped, SideHeading)
		ClearPedSecondaryTask(Ped)
		ClearPedTasksImmediately(Ped)
		RemoveAnimDict(AminD2)
		OnPlayerLeaveAnimal() -- Used on our server to do 'stuff' when the player got of the animal
		if HelperMessageID > 0 then
			HelperMessageID = 0
			ClearAllHelpMessages()				
		end

	else
		for _, Ped in pairs(GetNearbyPeds(PedPosition.x, PedPosition.y, PedPosition.z, 2.0)) do
			if not IsPedFalling(Ped) and not IsPedFatallyInjured(Ped) and not IsPedDeadOrDying(Ped) 
			   and not IsPedDeadOrDying(Ped) and not IsPedGettingUp(Ped) and not IsPedRagdoll(Ped) then
				if GetEntityModel(Ped) == GetHashKey("a_c_deer") or GetEntityModel(Ped) == GetHashKey("a_c_cow")
					or GetEntityModel(Ped) == GetHashKey("a_c_boar") then

					-- Here we do a simple scan to see if there are other Peds in the radius of the animal
					-- (although for 'all safety' I've made this scan a bit bigger)
					-- If it turns out if there is a player nearby it will then compare if that Entity (The other player)
					-- if attached to the 'just detected entity (the animal)'. If this is the case we will NOT allow the
					-- player to "also" board the animal
					for _, Ped2 in pairs(GetNearbyPeds(PedPosition.x, PedPosition.y, PedPosition.z, 4.0)) do
						if IsEntityAttachedToEntity(Ped2, Ped) then
							return
						end
					end

					-- Check for 'own conditions' on our server if the player is allowed at that time to
					-- even ride/board animals. You could also use that function for example to 'exclude' wanted
					-- players from riding/boarding animals
					if OnPlayerRequestToRideAnimal() then
						Animal.Handle = Ped
						Animal.Attach()
					end
					break
				end
			end
		end
	end
end

function DropPlayerFromAnimal()
	local Ped = PlayerPedId()
	Animal.Handle = nil
	DetachEntity(Ped, true, false)
	ClearPedTasksImmediately(Ped)
	ClearPedSecondaryTask(Ped)
	Animal.InControl = false
	AminD2 = "amb@prop_human_seat_chair@male@elbows_on_knees@react_aggressive"
	RequestAnimDict(AminD2)
	while not HasAnimDictLoaded(AminD2) do
		Citizen.Wait(0)
	end
	TaskPlayAnim(Ped, AminD2, "exit_left", 8.0, 1, -1, 0, 1.0, 0, 0, 0)
	Wait(100)
	ClearPedSecondaryTask(Ped)
	ClearPedTasksImmediately(Ped)
	Wait(100)
	SetPedToRagdoll(Ped, 1500, 1500, 0, 0, 0, 0)
	AnimalControlStatus = 0
	OnPlayerLeaveAnimal() -- Used on our server to do 'stuff' when the player got of the animal
end

--===========================================================================================================================
-- Main 'Helper' functions
--===========================================================================================================================
function GetCoordsInfrontOfEntityWithDistance(Entity, Distance, Heading)
	local Coordinates = GetEntityCoords(Entity, false)
	local Head = (GetEntityHeading(Entity) + (Heading or 0.0)) * math.pi / 180.0
	return {x = Coordinates.x + Distance * math.sin(-1.0 * Head), y = Coordinates.y + Distance * math.cos(-1.0 * Head), z = Coordinates.z}
end

function GetGroundZ(X, Y, Z)
	if tonumber(X) and tonumber(Y) and tonumber(Z) then
		local _, GroundZ = GetGroundZFor_3dCoord(X + 0.0, Y + 0.0, Z + 0.0, Citizen.ReturnResultAnyway())
		return GroundZ
	else
		return 0.0
	end
end

function DisplayHelpText(str)
	SetTextComponentFormat("STRING")
	AddTextComponentString(str)
	DisplayHelpTextFromStringLabel(0, 0, 1, -1)
	EndTextCommandDisplayHelp(0, 0, true, 8000)
end

--===========================================================================================================================
-- Controling Threads
--===========================================================================================================================
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(50)
		if AnimalControlStatus > 0 then
			AnimalControlStatus = AnimalControlStatus - 0.001
		end
	end

end)

Citizen.CreateThread(function()
	--RequestAnimDict("rcmjosh2")
	--while not HasAnimDictLoaded("rcmjosh2") do

	while true do
		Citizen.Wait(0)

		-- This is (BY DEFAULT HOWEVER!) the [E] key
		if IsControlJustPressed(1, 51) and GetLastInputMethod(0) then
			Animal.Ride()
		end

		local Ped = PlayerPedId()
		local AttachedEntity = GetEntityAttachedTo(Ped)

		if (not IsPedSittingInAnyVehicle(Ped) or not IsPedGettingIntoAVehicle(Ped)) and IsEntityAttached(Ped) and AttachedEntity == Animal.Handle then
			if DoesEntityExist(Animal.Handle) then
				AnimalChecksOkay = true 		-- We set the 'animal state' default to true
				
				-- Here we check if the animal is 'okay' (not dead, tripped, run over etc etc),
				-- if the animal is 'not okay' we'll make the player fall off/ragdoll.
				-- same goes for when the player is 'not okay' anymore 
				if IsPedFalling(AttachedEntity) or IsPedFatallyInjured(AttachedEntity) or IsPedDeadOrDying(AttachedEntity) 
				   or IsPedDeadOrDying(AttachedEntity) or IsPedDeadOrDying(Ped) or IsPedGettingUp(AttachedEntity) or IsPedRagdoll(AttachedEntity) then
					Animal.IsFleeing = false
					Animal.InControl = false
					AnimalChecksOkay = false
					DropPlayerFromAnimal()
				end
			
				-- If the animal checks out all okay, we'll resume riding it
				if AnimalChecksOkay then
					local LeftAxisXNormal, LeftAxisYNormal = GetControlNormal(2, 218), GetControlNormal(2, 219)
					local Speed, Range = Animal.Speed.Walk, 4.0
	
					-- Make the animal 'run', however this is 'kinda buggy' and not totally satisfactory,
					-- so you could disable the following four lines of code to 'disable animal running'
					if IsControlPressed(0, 21) then
						Speed = Animal.Speed.Run
						Range = 8.0
					end
	
					if Animal.InControl then
						Animal.IsFleeing = false
						local GoToOffset = GetOffsetFromEntityInWorldCoords(Animal.Handle, LeftAxisXNormal * Range, LeftAxisYNormal * -1.0 * Range, 0.0)
		
						TaskLookAtCoord(Animal.Handle, GoToOffset.x, GoToOffset.y, GoToOffset.z, 0, 0, 2)
						TaskGoStraightToCoord(Animal.Handle, GoToOffset.x, GoToOffset.y, GoToOffset.z, Speed, 20000, 40000.0, 0.5)
		
						if Animal.Marker then
							DrawMarker(6, GoToOffset.x, GoToOffset.y, GoToOffset.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 255, 255, 255, 0, 0, 2, 0, 0, 0, 0)
						end
					else
						-- Tapping (Default) the [W] key to gain control of the animal
						if IsControlJustPressed(1, 71) and GetLastInputMethod(0) then
							if AnimalControlStatus < 0.1 then
								AnimalControlStatus = AnimalControlStatus + 0.005
								if AnimalControlStatus > 0.1 then 
									AnimalControlStatus = 0.1 
									if HelperMessageID > 4 or HelperMessageID < 4 then
										DisplayHelpText("You've gained control of the animal.")
										HelperMessageID = 4
										AnimalControlStatus = 0
										Animal.InControl = true
									end
								end
							end
						end
					
						if AnimalControlStatus <= 0.001 and not Animal.InControl then
							if HelperMessageID > 3 or HelperMessageID < 3 then
								DisplayHelpText("You've the lost your grip and fell off.")
								HelperMessageID = 3
							end
							DropPlayerFromAnimal()
						end
						
						if not Animal.IsFleeing then
							Animal.IsFleeing = true
							TaskSmartFleePed(Animal.Handle, Ped, 9000.0, -1, false, false)
						end
					end
				end
			end
		end
	end
end)