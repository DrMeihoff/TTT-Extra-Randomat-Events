AddCSLuaFile()

local EVENT = {}

EVENT.Title = "'Realistic' Recoil"
EVENT.id = "gunforce"

CreateConVar("randomat_gunforce_max", 150000, {FCVAR_NOTIFY, FCVAR_ARCHIVE} , "Maximum Magnitude a gun can chnge somones velocity by.")



---- Define Randomat ULX Table Entries --------------------------------------------
	-- This follows the randomatULX table formula
	-- If you cant figure out how it should be layed out you probably shouldnt be here...
	local events = {}
	
	events["gunforce"] = {}
    events["gunforce"].name = "gunforce"
    events["gunforce"].sdr = {}

    slider = events["gunforce"].sdr
	slider[1] = {}
	slider[1].cmd = "max"
	slider[1].dsc = "Max Magnitude (def. 150000)"
	slider[1].min = "0"
	slider[1].max = "1000000"

	
---- Commands to add to Randomat ULX command table --------------------------------
	--These must be created for all convars that
	--the above sliders or checkboxs want to change
	
	events["gunforce"].commands = { 						-- New section to allow for transfer of commands easily
    "ttt_randomat_gunforce",
    "randomat_gunforce_max",
	}
	
	local eventJSON = util.TableToJSON(events) 				-- Converts Table to string for sending
	
---- Check for Data File and our event --------------------------------------------
	
	eventJSON = eventJSON .. "\n"							-- Add the line end or shit breaks
	
	local data = file.Read( "randomataddons.txt", "DATA" ) 	-- Check for file, if it doesnt exist create it.
	if not data then 										-- We do this here to check if we are the first addon
		file.Write( "randomataddons.txt", eventJSON )		-- This also allows for easy deleting/refreshing of file
		print("[RANDOMAT] [GUNFORCE] No randomataddons file found, creating one")
	end 
	
	data = file.Read( "randomataddons.txt", "DATA" ) 		-- File still doesnt exist, must be an issue...
	if not data then return end
		
	print("[RANDOMAT] [GUNFORCE] Found randomataddons.txt")
	
	local alreadyExists = false
	
	local tabdata = string.Split( data, "\n" )				-- Store Table in JSON format to file for reading by randomatULX
	for _, line in ipairs( tabdata ) do						-- However we need to check if our addon already exists in file
		if line .. "\n" == eventJSON then					
			print("[RANDOMAT] [GUNFORCE] Event found in randomataddons list")
			alreadyExists = true
		end
	end
	if (!alreadyExists) then								-- JSON Table not found in file, writing to file
		print("[RANDOMAT] [GUNFORCE] Did not find event in list, adding")			-- PLS NOTE, if the table is altered it will add the entry again
		file.Append( "randomataddons.txt", eventJSON)
	end

----------------------------------------------------------------------



function EVENT:Begin()
    hook.Add("EntityFireBullets","RandomatGunforce", function(ent, data)
        currentVelocity = ent:GetVelocity()
        vec = Vector(ent:EyePos().x - ent:GetEyeTrace().HitPos.x, ent:EyePos().y - ent:GetEyeTrace().HitPos.y, ent:EyePos().z - ent:GetEyeTrace().HitPos.z)
        vec:Normalize()
        newVelocity = (vec*math.exp(tonumber(math.pow(data.Damage/2, 1/2)))*4.8*data.Num)
        if newVelocity:Length() > GetConVar("randomat_gunforce_max"):GetInt() then
            newVelocity = (newVelocity / newVelocity:Length()) * GetConVar("randomat_gunforce_max"):GetInt()
        end
        if ent:IsOnGround() then
            --ent:SetPos(ent:GetPos() + vec)
            ent:SetPos(ent:GetPos() + Vector(0,0,1))
        end
        ent:SetVelocity(newVelocity)
    end)
end


function EVENT:End()
	hook.Remove("EntityFireBullets", "RandomatGunforce")
end

Randomat:register(EVENT)