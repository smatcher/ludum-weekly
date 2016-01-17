local Class = require "love-toys.third-party.hump.class"

local TooltipsClass = Class {}

local tooltip_text = [[
==[ Rules for SubRugby ]==
You play rugby with a team of submarines.
Take the bomb to the enemy lines (red area).

= Game principle:
The game is turn based, the turns are simultaneous.
A turn is divided in 3 phases:
- Deployment
- Orders
- Resolution

The game relies on stealth, you do not see the other player units.
However some actions will trigger a sonar bleep on the other player's screen.

= Deployment:
On your first turn (and afterward if you loose units)
you start your turn by deploying new submarines.
You do so by clicking on a cell in your area (green).
Dead units take 3 turns to respawn.

= Orders:
Select your units by clicking on them.
Your units have 2 actions for the turn (some actions take both).
A unit may only do one action per category per turn.
Orange actions will cause a sonar bleep.
When all your units are given their orders the "Send orders" button will appear.

= Resolution:
When both players validated their orders the turn resolution begins.
Both actions are solved one after the other
(first action for all units then second for all units)
Actions for a given sequence are solved in this order:
- units move
- torpedoes are fired
- torpedoes move
- destroyed units are removed

Units are destroyed on the following conditions:
- hit by a torpedo
- occupies the same cell as an other unit (collision)
- leaves the playing field
]]

function TooltipsClass:init()
	self.hovered = false
	self.new = true
end

function TooltipsClass:draw()
	
	if self.new == true then
		love.graphics.setColor(Constants.Colors.TooltipNew)
	elseif self.hovered == false then
		love.graphics.setColor(Constants.Colors.TooltipDim)
	else
		love.graphics.setColor(Constants.Colors.TooltipHovered)
	end

	love.graphics.draw(
		TooltipsClass.QuestionMark,
		Constants.Tooltips.DrawX,
		Constants.Tooltips.DrawY
	)

	if self.hovered then
		love.graphics.setColor(Constants.Colors.TooltipBackground)
		love.graphics.rectangle("fill",
			Constants.Tooltips.DrawInfoX,
			Constants.Tooltips.DrawInfoY,
			Constants.Tooltips.DrawInfoWidth,
			Constants.Tooltips.DrawInfoHeight
		)
		love.graphics.setColor(Constants.Colors.TextNormal)
		love.graphics.print(tooltip_text,
			Constants.Tooltips.DrawInfoX + Constants.Tooltips.TextOffsetX,
			Constants.Tooltips.DrawInfoY + Constants.Tooltips.TextOffsetY
		)
	end

	love.graphics.setColor(Constants.Colors.Default)
end

function TooltipsClass:mousemoved(x, y, dx, dt)
	-- Default hit area is the tooltip icon
	local hit_min_x = Constants.Tooltips.DrawX
	local hit_max_x = Constants.Tooltips.DrawX + TooltipsClass.QuestionMark:getWidth()
	local hit_min_y = Constants.Tooltips.DrawY
	local hit_max_y = Constants.Tooltips.DrawY + TooltipsClass.QuestionMark:getHeight()

	-- Extended hit area is the whole info area
	if self.hovered then
		hit_min_x = Constants.Tooltips.DrawInfoX
		hit_max_x = Constants.Tooltips.DrawInfoX + Constants.Tooltips.DrawInfoWidth
		hit_min_y = Constants.Tooltips.DrawInfoY
		hit_max_y = Constants.Tooltips.DrawInfoY + Constants.Tooltips.DrawInfoHeight
	end

	-- Test hit area
	self.hovered = (x >= hit_min_x
		and x <= hit_max_x
		and y >= hit_min_y
		and y <= hit_max_y
	)

	-- Mark the tooltip as seen
	if self.hovered then
		self.new = false
	end
end

function TooltipsClass.loadAssets()
	TooltipsClass.QuestionMark = love.graphics.newImage("tooltip.png")
end

return TooltipsClass

