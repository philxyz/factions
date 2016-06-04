------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

local matBlurEdges		= Material( "bluredges" )
local tex_MotionBlur	= render.GetMoBlurTex0()

ColorModify = {}
ColorModify[ "$pp_colour_addr" ] 		= 0
ColorModify[ "$pp_colour_addg" ] 		= 0
ColorModify[ "$pp_colour_addb" ] 		= 0
ColorModify[ "$pp_colour_brightness" ] 	= 0
ColorModify[ "$pp_colour_contrast" ] 	= 1
ColorModify[ "$pp_colour_colour" ] 		= 1
ColorModify[ "$pp_colour_mulr" ] 		= 0
ColorModify[ "$pp_colour_mulg" ] 		= 0
ColorModify[ "$pp_colour_mulb" ] 		= 0

local amt, motionblur, r, g, b, togoto, lasting = nil

local function PlayerScreenColor( umsg )
	local lr = umsg:ReadShort()
	local lg = umsg:ReadShort()
	local lb = umsg:ReadShort()
	lasting = umsg:ReadBool()
	
	color = Color ( 0, 0, 0 )
	togoto = Color( lr / 255, lg / 255, lb / 255 )
end
usermessage.Hook( "ModifyColor", PlayerScreenColor )

local function ModifyViewPaint()
	if color and color.r and color.g and color.b then
		if not lasting then
			togoto.r = math.Approach( togoto.r, 0.00, FrameTime() )
			togoto.g = math.Approach( togoto.g, 0.00, FrameTime() )
			togoto.b = math.Approach( togoto.b, 0.00, FrameTime() )
			color = togoto
		else
			color.r = math.Approach( color.r, togoto.r, FrameTime() )
			color.g = math.Approach( color.g, togoto.g, FrameTime() )
			color.b = math.Approach( color.b, togoto.b, FrameTime() )
		end
		
		if color.r == 0 and color.g == 0 and color.b == 0 then return end
		
		ColorModify[ "$pp_colour_addr" ] = color.r
		ColorModify[ "$pp_colour_addg" ] = color.g
		ColorModify[ "$pp_colour_addb" ] = color.b
		DrawColorModify( ColorModify )
	end
end
hook.Add( "RenderScreenspaceEffects", "[FAC] DoPlayerScreenColorModifications", ModifyViewPaint )

--[[                         Server Side
function CmbtFx.ModifyColor( ply, color, amt, lasting )
	if color and not CmbtFxConfig.ScreenBloodEffects then
		color, amt = nil
	end
	if not color and not amt then return end
	
	umsg.Start( "ModifyColor", ply )
		umsg.String( tostring(color) )
		umsg.Short( tonumber(amt) * 100 )
		umsg.Bool( lasting )
	umsg.End()
end
--]]
