CreateConVar("randomat_inchbyinch_time", 320, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How often player scale is decreased", 1, 1000)
CreateConVar("randomat_inchbyinch_step", 0.05, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "How much each player shrinks by", 0, 1)
CreateConVar("randomat_inchbyinch_min", 0.25, {FCVAR_NOTIFY, FCVAR_ARCHIVE}, "Minimum size a player can reach", 0, 1)

local EVENT = {}
EVENT.Title = "Inch By Inch"
EVENT.Description = "You get shorter and shorter as the round continues"
EVENT.id = "inchbyinch"

---- Define Randomat ULX Table Entries --------------------------------------------
	-- This follows the randomatULX table formula
	-- If you cant figure out how it should be layed out you probably shouldnt be here...
	local events = {}
	
	events["inchbyinch"] = {}
    events["inchbyinch"].name = "inchbyinch"

---- Commands to add to Randomat ULX command table --------------------------------
	--These must be created for all convars that
	--the above sliders or checkboxs want to change
	
	events["inchbyinch"].commands = { 						-- New section to allow for transfer of commands easily
    "ttt_randomat_inchbyinch",
	}
	
	local eventJSON = util.TableToJSON(events) 				-- Converts Table to string for sending
	
---- Check for Data File and our event --------------------------------------------
	
    eventJSON = eventJSON .. "\n"							-- Add the line end or shit breaks
	
    local data = file.Read( "randomataddons.txt", "DATA" ) 	-- Check for file, if it doesnt exist create it.
    if not data then 										-- We do this here to check if we are the first addon
        file.Write( "randomataddons.txt", eventJSON )		-- This also allows for easy deleting/refreshing of file
        print("[RANDOMAT] [INCHBYINCH] No randomataddons file found, creating one")
    end 

    data = file.Read( "randomataddons.txt", "DATA" ) 		-- File still doesnt exist, must be an issue...
    if not data then return end

    print("[RANDOMAT] [INCHBYINCH] Found randomataddons.txt")
    local alreadyExists = false

    local tabdata = string.Split( data, "\n" )				-- Store Table in JSON format to file for reading by randomatULX
    for _, line in ipairs( tabdata ) do						-- However we need to check if our addon already exists in file
        if line .. "\n" == eventJSON then					
            print("[RANDOMAT] [INCHBYINCH] Event found in randomataddons list")
            alreadyExists = true
        end
    end
    if (!alreadyExists) then								-- JSON Table not found in file, writing to file
        print("[RANDOMAT] [INCHBYINCH] Did not find event in list, adding")			-- PLS NOTE, if the table is altered it will add the entry again
        file.Append( "randomataddons.txt", eventJSON)
    end

----------------------------------------------------------------------

function EVENT:GetConVars()

    local sliders = {}
    for _, v in pairs({"time", "step", "min"}) do
        local name = "randomat_" .. self.id .. "_" .. v
        if ConVarExists(name) then
            local convar = GetConVar(name)
            table.insert(sliders, {
                cmd = v,                    -- The command extension (e.g. everything after "randomat_example_")
                dsc = convar:GetHelpText(), -- The description of the ConVar
                min = convar:GetMin(),      -- The minimum value for this slider-based ConVar
                max = convar:GetMax(),      -- The maximum value for this slider-based ConVar
                dcm = 2                     -- The number of decimal points to support in this slider-based ConVar
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
    sc = GetConVar("randomat_inchbyinch_step"):GetFloat()
    hook.Add("Tick","Randomatinchbyinch", function(ply)
        time = time + 1
        if time >= GetConVar("randomat_inchbyinch_time"):GetFloat() then
            time = 0
            for i, v in ipairs( self:GetAlivePlayers() ) do
                v:SetStepSize(v:GetStepSize()*sc)
                v:SetModelScale(v:GetModelScale()*sc, 1)
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