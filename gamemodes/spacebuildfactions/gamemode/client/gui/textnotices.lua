------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------
noticesEnabled = true

local PANEL = {}
local plyvar  = {}

surface.CreateFont("ScoreboardText", {
	font = "Tahoma",
	size = 16,
	weight = 1000,
	antialias = true
})

function PANEL:Init()
	self:SetMouseInputEnabled( false )
end

function PANEL:PerformLayout()
	self:SetPos( 0, 0 )
	self:SetSize( ScrW(), ScrH() )
end

function PANEL:ApplySchemeSettings()
end

local text
local function DrawTextTest( umsg )
	text = umsg:ReadString()
end
usermessage.Hook("DrawText", DrawTextTest)

--local last = 0
function PANEL:Paint(x, y)
	if not noticesEnabled then return end
	if text then
		--draw.SimpleText( text, "SM_WeaponTitle", ScrW() / 2 - 13, ScrH() / 2.5, Color(100,255,100, 255),1,1)
	end
	
	if respawntimer and ( respawntimer > CurTime() ) and not HideRespawnTimer then
		draw.SimpleText( "Respawning in " .. math.Round( respawntimer - CurTime() ) .. " Seconds.", "ScoreboardText", ScrW() / 2 - 20, ScrH() / 2 - 5, Color(255,100,100, 240),1,1)
		draw.SimpleText( "Press f4 to choose a spawnpoint.", "ScoreboardText", ScrW() / 2 - 22, ScrH() / 2 + 10, Color(255,100,100, 240),1,1)
	end
	--[[
	if last < CurTime() then
		PrintTable(plyvar)
		last = CurTime() + 5
	end
	--]]

	local client = LocalPlayer()
	if not plyvar[client] then return end
	
	for a,b in pairs(plyvar[client]) do
		for k,v in pairs(plyvar[client][a]) do
			if (a - 1) ~= 0 then
				if plyvar[client][a - 1] == nil then
					plyvar[client][a - 1] = {}
				end
				if plyvar[client][a - 1][k] == nil then
					plyvar[client][a - 1][k] = v
					plyvar[client][a] = nil
				end
			end
		end
	end
	
	for a,b in pairs(plyvar[client]) do
		if plyvar[client][a].added and plyvar[client][a].added ~= 0 and plyvar[client][a].showtime and plyvar[client][a].text then
			if plyvar[client][a].showtime < CurTime() then
				plyvar[client][a].added = nil
				plyvar[client][a].showtime = nil
				plyvar[client][a].text = nil
				return
			else
				
				local fade = ((math.abs(CurTime() - plyvar[client][a].showtime)) / 6) * 255
				if fade > 255 then
					fade = 255
				end
				
				local text = nil
				local pos = nil
				if plyvar[client][a].text == "rock0" then
					text = "Chalcocite"
					pos = orepos
				elseif plyvar[client][a].text == "rock1" then
					text = "Gold"
					pos = goldpos
				else
					text = plyvar[client][a].text
					pos = 0
				end
				if plyvar[client][a].text == "money" then plyvar[client][a].text = "$" end
				if plyvar[client][a].added < 0 then
					if plyvar[client][a].text == "$" then
						draw.SimpleText( "- $" ..(plyvar[client][a].added * -1), "ScoreboardText", moneypos, 40, Color(255,100,100, fade),1,1)
					else
						draw.SimpleText( "-" ..(plyvar[client][a].added * -1).. " " ..text, "ScoreboardText", pos, 40, Color(255,100,100, fade),1,1)
					end
				else
					if plyvar[client][a].text == "$" then
						draw.SimpleText( "+ $" ..plyvar[client][a].added, "ScoreboardText", moneypos, 40, Color(100,255,100, fade),1,1)
					else
						draw.SimpleText( "+" ..plyvar[client][a].added.. " " ..text, "ScoreboardText", pos, 40, Color(100,255,100, fade),1,1)
					end
				end
			end
		else
			plyvar[client][a].added = nil
			plyvar[client][a].showtime = nil
			plyvar[client][a].text = nil
			return
		end
	end
end

local function DrawNoticeUmsg( umsg )
	if not notices then
		notices = vgui.Create( "FAC Notices" )
	end
	
	local client = LocalPlayer()
	
	if not plyvar[client] then
		plyvar[client] = {}
	end
	if not plyvar[client][1] then
		plyvar[client][1] = {}
	end
	
	local ustring = umsg:ReadString()
	local unum = umsg:ReadShort()
	local done = false

	if not plyvar[client][1].text then
		plyvar[client][1].added = unum
		plyvar[client][1].showtime = CurTime() + 8
		plyvar[client][1].text = ustring
	else
		for a,b in pairs(plyvar[client]) do
			for k,v in pairs(plyvar[client][a]) do
				if plyvar[client][a].text == ustring and not done then
					plyvar[client][a].added = plyvar[client][a].added + unum
					plyvar[client][a].showtime = CurTime() + 8
					done = true
				end
			end
		end
		if not done then
			local amt = table.getn(plyvar[client]) + 1
			plyvar[client][amt] = {}
			plyvar[client][amt].added = unum
			plyvar[client][amt].showtime = CurTime() + 8
			plyvar[client][amt].text = ustring
		end
	end

end
usermessage.Hook("DrawNotice", DrawNoticeUmsg)

local function DrawRespawnTimer( umsg )
	respawntimer   = CurTime() + umsg:ReadShort()
end
usermessage.Hook( "DrawRespawnTimer", DrawRespawnTimer ) 

vgui.Register("FAC Notices", PANEL, "Panel")
notices = vgui.Create( "FAC Notices" )

notices:SetVisible( true )
