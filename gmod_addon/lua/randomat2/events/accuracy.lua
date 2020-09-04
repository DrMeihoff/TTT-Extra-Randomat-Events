AddCSLuaFile()

local EVENT = {}

EVENT.Title = "Look at me, I'm the accuracy now."
EVENT.id = "accuracy"

---- Define Randomat ULX Table Entries --------------------------------------------
	-- This follows the randomatULX table formula
	-- If you cant figure out how it should be layed out you probably shouldnt be here...
	local events = {}
	
	events["accuracy"] = {}
	events["accuracy"].name = "accuracy"

	
---- Commands to add to Randomat ULX command table --------------------------------
	--These must be created for all convars that
	--the above sliders or checkboxs want to change
	
	events["accuracy"].commands = { 						-- New section to allow for transfer of commands easily
	"ttt_randomat_accuracy",
	}
	
	local eventJSON = util.TableToJSON(events) 				-- Converts Table to string for sending
	
---- Check for Data File and our event --------------------------------------------
	
	eventJSON = eventJSON .. "\n"							-- Add the line end or shit breaks
	
	local data = file.Read( "randomataddons.txt", "DATA" ) 	-- Check for file, if it doesnt exist create it.
	if not data then 										-- We do this here to check if we are the first addon
		file.Write( "randomataddons.txt", eventJSON )		-- This also allows for easy deleting/refreshing of file
		print("[RANDOMAT] [ACCURACY] No randomataddons file found, creating one")
	end 
	
	data = file.Read( "randomataddons.txt", "DATA" ) 		-- File still doesnt exist, must be an issue...
	if not data then return end
		
	print("[RANDOMAT] [ACCURACY] Found randomataddons.txt")
	
	local alreadyExists = false
	
	local tabdata = string.Split( data, "\n" )				-- Store Table in JSON format to file for reading by randomatULX
	for _, line in ipairs( tabdata ) do						-- However we need to check if our addon already exists in file
		if line .. "\n" == eventJSON then					
			print("[RANDOMAT] [ACCURACY] Event found in randomataddons list")
			alreadyExists = true
		end
	end
	if (!alreadyExists) then								-- JSON Table not found in file, writing to file
		print("[RANDOMAT] [ACCURACY] Did not find event in list, adding")			-- PLS NOTE, if the table is altered it will add the entry again
		file.Append( "randomataddons.txt", eventJSON)
	end

----------------------------------------------------------------------


function EVENT:Begin()
    for i, ply in pairs(player.GetAll()) do
        ply.shotBullet = false
        ply.hitShotBullet = false
	end
	
	for i, ply in pairs(player.GetAll()) do
		ply:SetMaxHealth(ply:GetMaxHealth() + 100)
    end
	
    hook.Add("EntityFireBullets","RandomatAccuracyFire", function(ent, data)
        ent.shotBullet = true
        timer.Simple(0.1, function()
            if ent.hitShotBullet then
                print("Hit!")
				ent.hitShotBullet = false
				print((ent:GetMaxHealth() + 5))
				if !((ent:Health() + 5) > ent:GetMaxHealth()) then
					ent:SetHealth(ent:Health()+5)
				else
					ent:SetHealth(ent:GetMaxHealth())
				end
            else
				ent:TakeDamage(5)
            end
        end)
    end)

    hook.Add("EntityTakeDamage","RandomatAccuracyHit", function(ent, damage)
		if ent:IsPlayer() then
        	damage:GetAttacker().hitShotBullet = true
			damage:GetAttacker().shotBullet = false
		end
    end)
end


function EVENT:End()
    hook.Remove("EntityFireBullets", "RandomatAccuracyFire")
	hook.Remove("OnTakeDamage", "RandomatAccuracyHit")
	
	for i, ply in pairs(player.GetAll()) do
		ply:SetMaxHealth(100)
    end
end

Randomat:register(EVENT)