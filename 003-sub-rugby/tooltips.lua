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

	love.graphics.setColor(Constants.Colors.Default)
end

function TooltipsClass:mousemoved(x, y, dx, dt)
	self.hovered = (x >= Constants.Tooltips.DrawX  
		and x <= Constants.Tooltips.DrawX + TooltipsClass.QuestionMark:getWidth()
		and y >= Constants.Tooltips.DrawY
		and y <= Constants.Tooltips.DrawY + TooltipsClass.QuestionMark:getHeight()
	)
	if self.hovered then
		self.new = false
	end
end

function TooltipsClass.loadAssets()
	TooltipsClass.QuestionMark = love.graphics.newImage("tooltip.png")
end

return TooltipsClass

