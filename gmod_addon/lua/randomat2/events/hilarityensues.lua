AddCSLuaFile()

CreateConVar("randomat_hilarityensues_respawn", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE} , "Whether to respawn traitor (def. 1)")


local EVENT = {}

EVENT.Title = "Hilarity Ensues"
EVENT.id = "hilarityensues"

---- Define Randomat ULX Table Entries --------------------------------------------
	-- This follows the randomatULX table formula
	-- If you cant figure out how it should be layed out you probably shouldnt be here...
	local events = {}
	
	events["hilarityensues"] = {}
    events["hilarityensues"].name = "hilarityensues"
    
    events["hilarityensues"].chk = {}
	check = events["hilarityensues"].chk
	check[1] = {}
	check[1].cmd = "respawn"
	check[1].dsc = "Whether to respawn traitor (def. 1)"

	
---- Commands to add to Randomat ULX command table --------------------------------
	--These must be created for all convars that
	--the above sliders or checkboxs want to change
	
	events["hilarityensues"].commands = { 						-- New section to allow for transfer of commands easily
    "ttt_randomat_hilarityensues",
    "randomat_hilarityensues_respawn"
	}
	
	local eventJSON = util.TableToJSON(events) 				-- Converts Table to string for sending
	
---- Check for Data File and our event --------------------------------------------
	
	eventJSON = eventJSON .. "\n"							-- Add the line end or shit breaks
	
	local data = file.Read( "randomataddons.txt", "DATA" ) 	-- Check for file, if it doesnt exist create it.
	if not data then 										-- We do this here to check if we are the first addon
		file.Write( "randomataddons.txt", eventJSON )		-- This also allows for easy deleting/refreshing of file
		print("[RANDOMAT] [HILARITYENSUES] No randomataddons file found, creating one")
	end 
	
	data = file.Read( "randomataddons.txt", "DATA" ) 		-- File still doesnt exist, must be an issue...
	if not data then return end
		
	print("[RANDOMAT] [HILARITYENSUES] Found randomataddons.txt")
	
	local alreadyExists = false
	
	local tabdata = string.Split( data, "\n" )				-- Store Table in JSON format to file for reading by randomatULX
	for _, line in ipairs( tabdata ) do						-- However we need to check if our addon already exists in file
		if line .. "\n" == eventJSON then					
			print("[RANDOMAT] [HILARITYENSUES] Event found in randomataddons list")
			alreadyExists = true
		end
	end
	if (!alreadyExists) then								-- JSON Table not found in file, writing to file
		print("[RANDOMAT] [HILARITYENSUES] Did not find event in list, adding")			-- PLS NOTE, if the table is altered it will add the entry again
		file.Append( "randomataddons.txt", eventJSON)
	end

----------------------------------------------------------------------



function EVENT:Begin()
    hook.Add("DoPlayerDeath","RandomatHilarityEnsues", function(ply, attacker, dmg)
        if (attacker.IsPlayer() and attacker ~= ply) then
            if ply:GetRole() == ROLE_JESTER and attacker:GetRole() == ROLE_TRAITOR then
                local explosion = ents.Create( "env_explosion" )
                explosion:SetPos( ply:GetPos() )
	            explosion:Spawn() -- Spawn the explosion
	            explosion:SetKeyValue( "iMagnitude", "50" )
                explosion:Fire( "Explode", 0, 0 )
                
                if GetConVar("randomat_hilarityensues_respawn"):GetBool() then
                    ply:ConCommand("ttt_spectator_mode 0")
                    timer.Create("respawndelay", 0.1, 0, function()
                        local corpse = findcorpse(attacker) -- run the normal respawn code now
                        attacker:SpawnForRound( true )
                        attacker:SetCredits( ( (attacker:GetRole() == ROLE_INNOCENT) and 0 ) or GetConVarNumber("ttt_credits_starting") )
                        attacker:SetHealth(100)
                        if corpse then
                            attacker:SetPos(corpse:GetPos())
                            removecorpse(corpse)
                        end
                        SendFullStateUpdate()
                        if attacker:Alive() then timer.Destroy("respawndelay") return end
                    end)
                end
            end
        end
    end)
end


function EVENT:End()
	hook.Remove("DoPlayerDeath", "RandomatHilarityEnsues")
end

Randomat:register(EVENT)