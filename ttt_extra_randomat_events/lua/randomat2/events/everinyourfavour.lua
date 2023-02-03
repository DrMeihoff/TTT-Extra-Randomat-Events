local EVENT = {}
EVENT.Title = "Ever In Your Favour"
EVENT.Description = "A sound will play every time somebody dies."
EVENT.id = "everinyourfavour"

---- Define Randomat ULX Table Entries --------------------------------------------
	-- This follows the randomatULX table formula
	-- If you cant figure out how it should be layed out you probably shouldnt be here...
	local events = {}
	
	events["everinyourfavour"] = {}
    events["everinyourfavour"].name = "everinyourfavour"

---- Commands to add to Randomat ULX command table --------------------------------
	--These must be created for all convars that
	--the above sliders or checkboxs want to change
	
	events["everinyourfavour"].commands = { 						-- New section to allow for transfer of commands easily
    "ttt_randomat_everinyourfavour",
	}
	
	local eventJSON = util.TableToJSON(events) 				-- Converts Table to string for sending
	
---- Check for Data File and our event --------------------------------------------
	
    eventJSON = eventJSON .. "\n"							-- Add the line end or shit breaks
	
    local data = file.Read( "randomataddons.txt", "DATA" ) 	-- Check for file, if it doesnt exist create it.
    if not data then 										-- We do this here to check if we are the first addon
        file.Write( "randomataddons.txt", eventJSON )		-- This also allows for easy deleting/refreshing of file
        print("[RANDOMAT] [FAVOUR] No randomataddons file found, creating one")
    end 

    data = file.Read( "randomataddons.txt", "DATA" ) 		-- File still doesnt exist, must be an issue...
    if not data then return end

    print("[RANDOMAT] [FAVOUR] Found randomataddons.txt")
    local alreadyExists = false

    local tabdata = string.Split( data, "\n" )				-- Store Table in JSON format to file for reading by randomatULX
    for _, line in ipairs( tabdata ) do						-- However we need to check if our addon already exists in file
        if line .. "\n" == eventJSON then					
            print("[RANDOMAT] [FAVOUR] Event found in randomataddons list")
            alreadyExists = true
        end
    end
    if (!alreadyExists) then								-- JSON Table not found in file, writing to file
        print("[RANDOMAT] [FAVOUR] Did not find event in list, adding")			-- PLS NOTE, if the table is altered it will add the entry again
        file.Append( "randomataddons.txt", eventJSON)
    end

----------------------------------------------------------------------

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
                dcm = 1                     -- The number of decimal points to support in this slider-based ConVar
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
    hook.Add("DoPlayerDeath","RandomatEverInYourFavour", function(ply)
        for i, v in ipairs( player.GetAll() ) do
            net.Start("EverInYourFavour")
            net.Send(v)
        end
          
        surface.PlaySound("ambient/alarms/klaxon1.wav")
    end)
end


function EVENT:End()
    hook.Remove("DoPlayerDeath","RandomatEverInYourFavour")
end

Randomat:register(EVENT)