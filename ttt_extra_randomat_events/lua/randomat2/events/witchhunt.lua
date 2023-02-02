local EVENT = {}
EVENT.Title = "Witch Hunt"
EVENT.Description = "Innocents sink in water. Traitors float."
EVENT.id = "witchhunt"

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

function EVENT:Begin()
    hook.Add("HandlePlayerSwimming","Randomatwitchhunt", function(ply, velocity)
        if ply:WaterLevel() > 1 then
            if ply.GetRole() == ROLE_INNOCENT then
                local up = Vector(0, 1, 0)
                ply.setVelocity(up)
            elseif ply.GetRole() == ROLE_TRAITOR then
                local down = Vector(0, -1, 0)
                ply.setVelocity(down)
            end
    end)
end


function EVENT:End()
    hook.Remove("HandlePlayerSwimming","Randomatwitchhunt")
end

Randomat:register(EVENT)