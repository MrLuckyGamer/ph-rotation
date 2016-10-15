-- This is a serverside lua script that makes the Original Prop Hunt have the better rotation system from Enhanced Prop Hunt (Excluding the client-side prop model).
-- Created by D4UNKN0WNM4N2010 (http://steamcommunity.com/id/daunknownman2010/). Please give credits if you use this script.

-- Close this script if not prop_hunt
if engine.ActiveGamemode() != "prop_hunt" then print("This script only works with Prop Hunt.") return end

-- Add ClientSide Lua File.
AddCSLuaFile()

-- ConVars?
if !ConVarExists( "ph_enhanced_rotation_support" ) then local ph_enhanced_rotation_support = CreateConVar("ph_enhanced_rotation_support", "0", {FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY}) end

-- Functions down here:
if (SERVER) then

-- Player spawns!
function PROPHUNTROTHOOK_PlayerSpawn(pl)
	-- Let's check up some things.
	if GetConVar("ph_enhanced_rotation_support"):GetBool() && pl:Team() == TEAM_PROPS then
		-- Psst! Lock rotation man!
		pl.lockRotation = false
		pl.usesNewRotation = false
		
		-- Late call..
		timer.Simple(0.1, function() if pl:IsValid() then PROPHUNTROT_PostPlayerSpawn(pl) end end)
	end
end
hook.Add("PlayerSpawn", "PROPHUNTROTHOOK_PlayerSpawn", PROPHUNTROTHOOK_PlayerSpawn)

-- Think function!
function PROPHUNTROTHOOK_Think()
	-- Check up on things here too.
	if GetConVar("ph_enhanced_rotation_support"):GetBool() then
		-- Only for TEAM_PROPS.
		for _, pl in pairs(team.GetPlayers(TEAM_PROPS)) do
			-- New rotation.
			if pl:IsValid() && pl:Alive() && pl.usesNewRotation && pl.ph_prop && pl.ph_prop:IsValid() then
				-- Set Position
				if pl.ph_prop:GetModel() == "models/player/kleiner.mdl" then
					pl.ph_prop:SetPos(pl:GetPos())
				else
					pl.ph_prop:SetPos(pl:GetPos() - Vector(0, 0, pl.ph_prop:OBBMins().z))
				end
				
				-- Set Angles
				if !pl.lockRotation then
					pl.ph_prop:SetAngles(pl:GetAngles())
				end
			end
			
			-- Constantly check the player for a pressed key.
			if pl:IsValid() && pl:Alive() && pl.usesNewRotation && pl:KeyPressed(IN_RELOAD) then
				pl.lockRotation = !pl.lockRotation
				pl:ChatPrint("Locked Rotation: "..string.upper(tostring(pl.lockRotation)))
			end
		end
	end
end
hook.Add("Think", "PROPHUNTROTHOOK_Think", PROPHUNTROTHOOK_Think)

-- Call this later!
function PROPHUNTROT_PostPlayerSpawn(pl)
	-- Some stuff.
	if pl:Alive() && pl.ph_prop && pl.ph_prop:IsValid() then
		-- Get the parent away from the child.
		if pl.ph_prop:GetParent() && pl.ph_prop:GetParent():IsValid() then
			pl.ph_prop:SetParent(nil)
		end
		
		-- We use the new rotation.
		pl.usesNewRotation = true
		
		-- Warn the player we can lock rotation.
		pl:ChatPrint("Press the reload button to lock your rotation.")
	end
end

-- This is required. Really required.
function PROPHUNTROT_RotationSupportChanged( name, old, new )
	-- Print a message about this disaster.
	PrintMessage(HUD_PRINTTALK, "Warning: ph_enhanced_rotation_support was changed. Bugs may occur!")
	
	-- Only for TEAM_PROPS.
	for _, pl in pairs(team.GetPlayers(TEAM_PROPS)) do
		-- Let's do something here
		if pl:IsValid() && pl:Alive() && pl.ph_prop && pl.ph_prop:IsValid() then
			-- If the player uses the new rotation..
			if pl.usesNewRotation then
				-- Reset these..
				pl.lockRotation = false
				pl.usesNewRotation = false
				
				-- Reset this!
				pl.ph_prop:SetParent(pl)
			else
				-- Get the parent away from the child.
				if pl.ph_prop:GetParent() && pl.ph_prop:GetParent():IsValid() then
					pl.ph_prop:SetParent(nil)
				end
				
				-- We use the new rotation.
				pl.usesNewRotation = true
				
				-- Warn the player we can lock rotation.
				pl:ChatPrint("Press the reload button to lock your rotation.")
			end
		end
	end
end
cvars.AddChangeCallback( "ph_enhanced_rotation_support", PROPHUNTROT_RotationSupportChanged )

end
