------------------------------------
--	Simple Prop Protection
--	By Spacetech
------------------------------------

AddCSLuaFile("sh_spropprotection.lua")
AddCSLuaFile("spropprotection/cl_init.lua")
AddCSLuaFile("spropprotection/sh_cppi.lua")

SPropProtection = {}
SPropProtection.Version = 1.5

CPPI = {}
CPPI_NOTIMPLEMENTED = 26
CPPI_DEFER = 16

include("spropprotection/sh_cppi.lua")

if(SERVER) then
	include("spropprotection/sv_init.lua")
else
	include("spropprotection/cl_init.lua")
end

Msg("==========================================================\n")
Msg("Simple Prop Protection Version "..SPropProtection.Version.." by Spacetech has loaded\n")
Msg("==========================================================\n")
