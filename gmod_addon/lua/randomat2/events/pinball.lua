AddCSLuaFile()

local EVENT = {}

CreateConVar("randomat_pinball_mul", 100, {FCVAR_NOTIFY, FCVAR_ARCHIVE} , "The velocity multiplyer")


EVENT.Title = "Pinball People"
EVENT.id = "pinball"

---- Define Randomat ULX Table Entries --------------------------------------------
	-- This follows the randomatULX table formula
	-- If you cant figure out how it should be layed out you probably shouldnt be here...
	local events = {}
	
	events["pinball"] = {}
    events["pinball"].name = "pinball"
    events["pinball"].sdr = {}

    slider = events["pinball"].sdr
	slider[1] = {}
	slider[1].cmd = "mul"
	slider[1].dsc = "The velocity multiplyer"
	slider[1].min = "0"
	slider[1].max = "10000"

	
---- Commands to add to Randomat ULX command table --------------------------------
	--These must be created for all convars that
	--the above sliders or checkboxs want to change
	
	events["pinball"].commands = { 						-- New section to allow for transfer of commands easily
    "ttt_randomat_pinball",
    "randomat_pinball_mul",
	}
	
	local eventJSON = util.TableToJSON(events) 				-- Converts Table to string for sending
	
---- Check for Data File and our event --------------------------------------------
	
	eventJSON = eventJSON .. "\n"							-- Add the line end or shit breaks
	
	local data = file.Read( "randomataddons.txt", "DATA" ) 	-- Check for file, if it doesnt exist create it.
	if not data then 										-- We do this here to check if we are the first addon
		file.Write( "randomataddons.txt", eventJSON )		-- This also allows for easy deleting/refreshing of file
		print("[RANDOMAT] [PINBALL] No randomataddons file found, creating one")
	end 
	
	data = file.Read( "randomataddons.txt", "DATA" ) 		-- File still doesnt exist, must be an issue...
	if not data then return end
		
	print("[RANDOMAT] [PINBALL] Found randomataddons.txt")
	
	local alreadyExists = false
	
	local tabdata = string.Split( data, "\n" )				-- Store Table in JSON format to file for reading by randomatULX
	for _, line in ipairs( tabdata ) do						-- However we need to check if our addon already exists in file
		if line .. "\n" == eventJSON then					
			print("[RANDOMAT] [PINBALL] Event found in randomataddons list")
			alreadyExists = true
		end
	end
	if (!alreadyExists) then								-- JSON Table not found in file, writing to file
		print("[RANDOMAT] [PINBALL] Did not find event in list, adding")			-- PLS NOTE, if the table is altered it will add the entry again
		file.Append( "randomataddons.txt", eventJSON)
	end

----------------------------------------------------------------------



function EVENT:Begin()
    for i, ply in pairs(player.GetAll()) do
        ply:SetCustomCollisionCheck(true)
    end
    hook.Add( "ShouldCollide", "RandomatPinball", function( ply, ply2 )
        if ply and ply2 then
            if ply:IsPlayer() and ply2:IsPlayer() then
                if ply:GetPos():DistToSqr(ply2:GetPos()) < 1300 then
                    velVector = Vector(ply:GetPos().x - ply2:GetPos().x, ply:GetPos().y - ply2:GetPos().y, ply:GetPos().z - ply2:GetPos().z)
                    ply:SetVelocity(velVector*GetConVar("randomat_pinball_mul"):GetInt())
                end
            end
        end
    end)
end


function EVENT:End()
    hook.Remove( "ShouldCollide", "RandomatPinball")
end

Randomat:register(EVENT)