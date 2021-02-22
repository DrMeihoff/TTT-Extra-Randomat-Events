CreateConVar("randomat_hilarity_respawn", 1, {FCVAR_NOTIFY, FCVAR_ARCHIVE} , "Whether to respawn traitor (def. 1)")

local EVENT = {}
EVENT.Title = "Hilarity Ensues"
EVENT.Description = "When a traitor kills a jester, the jester will expload."
EVENT.id = "hilarity"

function EVENT:GetConVars()

    local sliders = {}
    for _, v in pairs({}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,                    -- The command extension (e.g. everything after "randomat_example_")
                dsc = convar:GetHelpText(), -- The description of the ConVar
                min = convar:GetMin(),      -- The minimum value for this slider-based ConVar
                max = convar:GetMax(),      -- The maximum value for this slider-based ConVar
                dcm = 0                     -- The number of decimal points to support in this slider-based ConVar
            })
        end
    end




    local checks = {}
    for _, v in pairs({"respawn"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(checks, {
                cmd = v,                    -- The command extension (e.g. everything after "randomat_example_")
                dsc = convar:GetHelpText()  -- The description of the ConVar
            })
        end
    end


    local textboxes = {}
    for _, v in pairs({}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(textboxes, {
                cmd = v,                    -- The command extension (e.g. everything after "randomat_example_")
                dsc = convar:GetHelpText()  -- The description of the ConVar
            })
        end
    end

    return sliders, checks, textboxes
end


-- Used in removecorpse
local function findcorpse(v)
	for _, ent in pairs( ents.FindByClass( "prop_ragdoll" )) do
		if ent.uqid == v:UniqueID() and IsValid(ent) then
			return ent or false
		end
	end
end



-- Used to remove the corpse of someone killed aby another player.
local function removecorpse(corpse)
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
	-- If ttt2, then we should change how the jester works to avoid
	-- ending round
	if TTT2 then
		curConVar = GetConVar("ttt2_jes_winstate"):GetInt()
		if GetConVar("ttt2_jes_winstate"):GetInt() ~= 5 then
			GetConVar("ttt2_jes_winstate"):SetInt(5)
		end
	end

    if not ROLE_PHOENIX then
        role = ROLE_SWAPPER
        -- Replace all Jesters with Swappers
	    for i, v in ipairs( player.GetAll() ) do
		    if v:GetRole() == ROLE_JESTER then
			    v:SetRole(ROLE_SWAPPER)
		    end
	    end
    else
        role = ROLE_JESTER
    end

    hook.Add("TTTKarmaGivePenalty", "HilarityKarma", function(ply, penalty, victim)
        
        if ply:GetRole() == ROLE_TRAITOR and victim:GetRole() == role then
            return true
        end
        
        end)

	-- If there are no jesters, spawn one using a traitor as long as
	-- there are more than 1 traitors
	addJester = true
	traitors = 0

	for i, v in ipairs( player.GetAll() ) do
		if v:GetRole() == role then
			addJester = false
		end
		
		if v:GetRole() == ROLE_TRAITOR then
			traitors = traitors + 1
		end
	end

	if addJester and traitors > 1 then
		for i, v in ipairs( player.GetAll() ) do
			if v:GetRole() == ROLE_TRAITOR and addJester then
				v:SetRole(ROLE_JESTER)
				print("Created Jester")
				addJester = false
			end
		end
	end

	SendFullStateUpdate()

    hook.Add("DoPlayerDeath","RandomatHilarityEnsues", function(ply, attacker, dmg)
        
        -- If player did not suicide and was killed by a player
        if (attacker.IsPlayer() and attacker ~= ply) then

            -- Check player roles
			if ply:GetRole() == role and attacker:GetRole() == ROLE_TRAITOR then
                -- Create explosion
                local explosion = ents.Create( "env_explosion" )
                explosion:SetPos( ply:GetPos() )
	            explosion:Spawn() -- Spawn the explosion
	            explosion:SetKeyValue( "iMagnitude", "200" )
                explosion:Fire( "Explode", 0, 0 )
                print("awdadw")
				if GetConVar("randomat_hilarity_respawn"):GetBool() then
                    print("yes")
                    attacker:ConCommand("ttt_spectator_mode 0")
                    timer.Create("respawndelay", 0.1, 0, function()
                        print("spawn")
                        local corpse = findcorpse(attacker) -- run the normal respawn code now
                        attacker:SpawnForRound( true )
                        attacker:SetHealth(100)
                        attacker:SetRole(ROLE_TRAITOR)
                        timer.Simple(0.2, function()
                            attacker:SetDefaultCredits()
                            ply:SetDefaultCredits()
                        end)
                        
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
	if TTT2 then
		GetConVar("ttt2_jes_winstate"):SetInt(tonumber(curConVar))
	end
	hook.Remove("DoPlayerDeath", "RandomatHilarityEnsues")
end

Randomat:register(EVENT)