local EVENT = {}
EVENT.Title = "I'm The Captian Now."
EVENT.Description = "When a detective kills an innocent, the innocent becomes the detective, and the old detective dies."
EVENT.id = "captain"

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
    for _, v in pairs({}) do
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



-- Used in removecorpse.
local function findcorpse(v)
	for _, ent in pairs( ents.FindByClass( "prop_ragdoll" )) do
		if ent.uqid == v:UniqueID() and IsValid(ent) then
			return ent or false
		end
	end
end



-- Remove corpse, used on the player the detective kills.
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




local function checkTeam(ply)
    role = ply:GetRole()
    innocents = {}
    traitors = {}
    if ROLE_INNOCENT then table.insert(innocents, ROLE_INNOCENT) end
    if ROLE_PHOENIX then table.insert(innocents, ROLE_PHOENIX) end
    if ROLE_SURVIVALIST then table.insert(innocents, ROLE_SURVIVALIST) end
    if ROLE_MERCENARY then table.insert(innocents, ROLE_MERCENARY) end
    if ROLE_PHANTOM then table.insert(innocents, ROLE_PHANTOM) end
    if ROLE_GLITCH then table.insert(innocents, ROLE_GLITCH) end
    if ROLE_DETECTIVE then table.insert(innocents, ROLE_DETECTIVE) end

    if ROLE_TRAITOR then table.insert(traitors, ROLE_TRAITOR) end
    if ROLE_ASSASSIN then table.insert(traitors, ROLE_ASSASSIN) end
    if ROLE_HYPNOTIST then table.insert(traitors, ROLE_HYPNOTIST) end
    if ROLE_SWAPPER then table.insert(traitors, ROLE_SWAPPER) end
    if ROLE_KILLER then table.insert(traitors, ROLE_KILLER) end
    if ROLE_VAMPIRE then table.insert(traitors, ROLE_VAMPIRE) end
    if ROLE_ZOMBIE then table.insert(traitors, ROLE_ZOMBIE) end
    if ROLE_INFECTED then table.insert(traitors, ROLE_INFECTED) end




    for i, v in ipairs(innocents) do
        if role == v then
            return ROLE_INNOCENT
        end
    end


    for i, v in ipairs(traitors) do
        if role == v then
            return ROLE_TRAITOR
        end
    end
    
    return ROLE_INNOCENT
end




function EVENT:Begin()
    hook.Add("DoPlayerDeath","RandomatCaptain", function(ply, attacker, dmg)

        -- Only procede if the player didn't suicide, and the attacker
        -- is another player.
        if (attacker.IsPlayer() and attacker ~= ply) then
            if attacker:GetRole() == ROLE_DETECTIVE and checkTeam(ply) == ROLE_INNOCENT then
                
                attacker:Kill() -- Kill the detective
                timer.Create("respawndelay", 0.1, 0, function()

                    local corpse = findcorpse(ply) -- run the normal respawn code now

                    -- Respawn the new detective elsewhere
                    ply:SpawnForRound( true )
                    ply:SetRole(ROLE_DETECTIVE)
                    ply:SetHealth(100)
                    timer.Simple(0.2, function()
                        attacker:SetDefaultCredits()
                        ply:SetDefaultCredits()
                    end)
                    
                    -- Remove his corpse
                    if corpse then
                        ply:SetPos(corpse:GetPos())
                        removecorpse(corpse)
                    end

                    SendFullStateUpdate()
                    if ply:Alive() then timer.Destroy("respawndelay") return end

                end)
            end
        end

    end)
end


function EVENT:End()
	hook.Remove("DoPlayerDeath", "RandomatCaptain")
end

Randomat:register(EVENT)