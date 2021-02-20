AddCSLuaFile()

local EVENT = {}

EVENT.Title = "Contagious Morality"
EVENT.id = "contagiousmorality"

---- Define Randomat ULX Table Entries --------------------------------------------
	-- This follows the randomatULX table formula
	-- If you cant figure out how it should be layed out you probably shouldnt be here...
	local events = {}
	
	events["contagiousmorality"] = {}
	events["contagiousmorality"].name = "contagiousmorality"

	
---- Commands to add to Randomat ULX command table --------------------------------
	--These must be created for all convars that
	--the above sliders or checkboxs want to change
	
	events["contagiousmorality"].commands = { 						-- New section to allow for transfer of commands easily
	"ttt_randomat_contagiousmorality",
	}
	
	local eventJSON = util.TableToJSON(events) 				-- Converts Table to string for sending
	
---- Check for Data File and our event --------------------------------------------
	
	eventJSON = eventJSON .. "\n"							-- Add the line end or shit breaks
	
	local data = file.Read( "randomataddons.txt", "DATA" ) 	-- Check for file, if it doesnt exist create it.
	if not data then 										-- We do this here to check if we are the first addon
		file.Write( "randomataddons.txt", eventJSON )		-- This also allows for easy deleting/refreshing of file
		print("[RANDOMAT] [CONTAGIOUSMORALITY] No randomataddons file found, creating one")
	end 
	
	data = file.Read( "randomataddons.txt", "DATA" ) 		-- File still doesnt exist, must be an issue...
	if not data then return end
		
	print("[RANDOMAT] [CONTAGIOUSMORALITY] Found randomataddons.txt")
	
	local alreadyExists = false
	
	local tabdata = string.Split( data, "\n" )				-- Store Table in JSON format to file for reading by randomatULX
	for _, line in ipairs( tabdata ) do						-- However we need to check if our addon already exists in file
		if line .. "\n" == eventJSON then					
			print("[RANDOMAT] [CONTAGIOUSMORALITY] Event found in randomataddons list")
			alreadyExists = true
		end
	end
	if (!alreadyExists) then								-- JSON Table not found in file, writing to file
		print("[RANDOMAT] [CONTAGIOUSMORALITY] Did not find event in list, adding")			-- PLS NOTE, if the table is altered it will add the entry again
		file.Append( "randomataddons.txt", eventJSON)
	end

----------------------------------------------------------------------

function findcorpse(v)
	for _, ent in pairs( ents.FindByClass( "prop_ragdoll" )) do
		if ent.uqid == v:UniqueID() and IsValid(ent) then
			return ent or false
		end
	end
end

function removecorpse(corpse)
	CORPSE.SetFound(corpse, false)
	if string.find(corpse:GetModel(), "zm_", 6, true) then
        player.GetByUniqueID( corpse.uqid ):SetNWBool( "body_found", false )
        corpse:Remove()
        SendFullStateUpdate()
		
	elseif corpse.player_ragdoll then
        player.GetByUniqueID( corpse.uqid ):SetNWBool( "body_found", false )
		corpse:Remove()
        SendFullStateUpdate()
	end
end

function EVENT:Begin()

	KarmaTable = {}
	for i, v in ipairs( self:GetAlivePlayers() ) do
		KarmaTable[v] = v:GetLiveKarma()
	end

	-- Replace all Jesters with Traitors
	for i, v in ipairs( player.GetAll() ) do
		if v:GetRole() == ROLE_JESTER then
			v:SetRole(ROLE_TRAITOR)
		end
	end
	SendFullStateUpdate()

	KarmaEnabledConvar = (GetConVar("ttt_karma"))
	KarmaEnabled = KarmaEnabledConvar:GetBool()

    hook.Add("DoPlayerDeath","RandomatContagiousMorality", function(ply, attacker, dmg)
		
        if (attacker.IsPlayer() and attacker ~= ply) then
            ply:ConCommand("ttt_spectator_mode 0")

            timer.Create("respawndelay", 0.1, 0, function()

                local corpse = findcorpse(ply) -- run the normal respawn code now
                ply:SpawnForRound( true )
                ply:SetCredits( ( (ply:GetRole() == ROLE_INNOCENT) and 0 ) or GetConVarNumber("ttt_credits_starting") )
                ply:SetRole(attacker:GetRole())
                ply:SetHealth(100)

                if corpse then
                    ply:SetPos(corpse:GetPos())
                    removecorpse(corpse)
                end

                SendFullStateUpdate()
                if ply:Alive() then timer.Destroy("respawndelay") return end

            end)
        end
    end)
end


function EVENT:End()
	
	for i, v in ipairs( self:GetAlivePlayers() ) do
		v:SetLiveKarma(KarmaTable[v])
		v:SetBaseKarma(KarmaTable[v])
		KARMA.ApplyKarma(v)
	end

	hook.Remove("DoPlayerDeath", "RandomatContagiousMorality")
end

Randomat:register(EVENT)