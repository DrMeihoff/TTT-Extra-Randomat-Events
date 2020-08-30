AddCSLuaFile()

local EVENT = {}

EVENT.Title = "Petrify!"
EVENT.id = "defaultplayer"

---- Define Randomat ULX Table Entries --------------------------------------------
	-- This follows the randomatULX table formula
	-- If you cant figure out how it should be layed out you probably shouldnt be here...
	local events = {}
	
	events["defaultplayer"] = {}
	events["defaultplayer"].name = "defaultplayer"

	
---- Commands to add to Randomat ULX command table --------------------------------
	--These must be created for all convars that
	--the above sliders or checkboxs want to change
	
	events["defaultplayer"].commands = { 						-- New section to allow for transfer of commands easily
	"ttt_randomat_defaultplayer",
	}
	
	local eventJSON = util.TableToJSON(events) 				-- Converts Table to string for sending
	
---- Check for Data File and our event --------------------------------------------
	
	eventJSON = eventJSON .. "\n"							-- Add the line end or shit breaks
	
	local data = file.Read( "randomataddons.txt", "DATA" ) 	-- Check for file, if it doesnt exist create it.
	if not data then 										-- We do this here to check if we are the first addon
		file.Write( "randomataddons.txt", eventJSON )		-- This also allows for easy deleting/refreshing of file
		print("[RANDOMAT] [DEFAULTPLAYER] No randomataddons file found, creating one")
	end 
	
	data = file.Read( "randomataddons.txt", "DATA" ) 		-- File still doesnt exist, must be an issue...
	if not data then return end
		
	print("[RANDOMAT] [DEFAULTPLAYER] Found randomataddons.txt")
	
	local alreadyExists = false
	
	local tabdata = string.Split( data, "\n" )				-- Store Table in JSON format to file for reading by randomatULX
	for _, line in ipairs( tabdata ) do						-- However we need to check if our addon already exists in file
		if line .. "\n" == eventJSON then					
			print("[RANDOMAT] [DEFAULTPLAYER] Event found in randomataddons list")
			alreadyExists = true
		end
	end
	if (!alreadyExists) then								-- JSON Table not found in file, writing to file
		print("[RANDOMAT] [DEFAULTPLAYER] Did not find event in list, adding")			-- PLS NOTE, if the table is altered it will add the entry again
		file.Append( "randomataddons.txt", eventJSON)
	end

----------------------------------------------------------------------
for i = 1, 1, 4 do
	sound.Add( {
		name = "stonefootstep-"..i,
		channel = CHAN_BODY,
		volume = 1.0,
		level = 80,
		pitch = {95, 110},
		sound = "stonefootstep-"..i
	} )
end


local function petrify(ply)
	print("Pertify!")
	if ply then
		if ply:IsValid() and ply:Alive() then
			FindMetaTable("Entity").SetModel(ply, "models/player.mdl")
		end
	end
end





function EVENT:Begin()
	hook.Add("PlayerSpawn", "randomatDefaultPlayer", function(ply)
		timer.Simple(0.5, petrify(ply))
	end)
	
	hook.Add( "PlayerFootstep", "randomatDefaultPlayerFootstep", function( ply, pos, foot, sound, volume, rf )
		footstepNum = math.random(1, 3)
		print("Footstep! num: "..footstepNum)
		ply:EmitSound( "StoneFootstep-"..footstepNum..".wav" )
		return true
	end )

    for i, ply in pairs(player.GetAll()) do
        petrify(ply)
    end

end


function EVENT:End()
	hook.Remove("PlayerSpawn", "randomatDefaultPlayer")
	hook.Remove("PlayerFootstep", "randomatDefaultPlayerFootstep")
end

Randomat:register(EVENT)