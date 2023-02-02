CreateConVar("randomat_inchbyinch_time", 320, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How often player scale is decreased", 1, 1000)
CreateConVar("randomat_inchbyinch_step", 0.05, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How much each player shrinks by", 0, 1)
CreateConVar("randomat_inchbyinch_min", 0.25, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Minimum size a player can reach", 0, 1)

local EVENT = {}
EVENT.Title = "Inch By Inch"
EVENT.Description = "You get shorter and shorter as the round continues"
EVENT.id = "inchbyinch"

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
    time = 0
    sc = GetConVar("randomat_inchbyinch_step")
    hook.Add("Tick","Randomatinchbyinch", function(ply)
        time += 1
        if time >= GetConVar("randomat_inchbyinch_time") then
            time = 0
            for i, v in ipairs( self:GetAlivePlayers() ) do
                v:SetStepSize(v:GetStepSize()*sc)
                v:SetModelScale(v:GetModelScale()*sc, GetConVar("randomat_inchbyinch_time") - 1)
                v:SetViewOffset(v:GetViewOffset()*sc)
                v:SetViewOffsetDucked(v:GetViewOffsetDucked()*sc)
        
                local a, b = v:GetHull()
                v:SetHull(a*sc, b*sc)
        
                a, b = v:GetHullDuck()
                v:SetHullDuck(a*sc, b*sc)
        
                v:SetNWFloat("RmdtSpeedModifier", math.Clamp(v:GetStepSize()/9, 0.25, 1) * v:GetNWFloat("RmdtSpeedModifier", 1))
            end
        end
    end)
end


function EVENT:End()
    hook.Remove("Tick","Randomatinchbyinch")
    for _, ply in pairs(player.GetAll()) do
        ply:SetModelScale(1, 1)
        ply:SetViewOffset(Vector(0,0,64))
        ply:SetViewOffsetDucked(Vector(0, 0, 32))
        ply:ResetHull()
        ply:SetStepSize(18)
        ply:SetNWFloat("RmdtSpeedModifier", 1)
    end
end

Randomat:register(EVENT)