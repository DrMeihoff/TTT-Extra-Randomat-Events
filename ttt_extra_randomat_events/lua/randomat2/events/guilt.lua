CreateConVar("randomat_guilt_time", 5, {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Time Guilty", 1, 30)

local EVENT = {}
EVENT.Title = "Unbelivable Guilt"
EVENT.Description = "If you kill a player on your team, your head will be forced down for a few seconds."
EVENT.id = "guilt"

function EVENT:GetConVars()

    local sliders = {}
    for _, v in pairs({"time"}) do
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


    hook.Add("PlayerDeath","RandomatGuilt", function(ply, attacker, dmg)

        if ply and attacker and ply ~= attacker and ply:IsPlayer() and attacker:IsPlayer() then            if checkTeam(ply) == checkTeam(attacker) then
                net.Start("Guilty")
                net.Send(attacker)
            end
        end

    end)
end




function EVENT:End()
    hook.Add("PlayerDeath","RandomatGuilt")
end

Randomat:register(EVENT)

util.AddNetworkString("Guilty")