local Class = require "love-toys.third-party.hump.class"

local TooltipsClass = Class {}

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
		love.graphics.print("Work in progress : Tooltips aren't functional yet",
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

