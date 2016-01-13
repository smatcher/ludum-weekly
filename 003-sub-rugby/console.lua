local Class = require "love-toys.third-party.hump.class"

local ConsoleClass = Class {}

function ConsoleClass:init()
	self.lines = {}
end

function ConsoleClass:print(text, color)
	if #self.lines >= Constants.Console.MaxLines then
		table.remove(self.lines, 1)
	end
	table.insert(self.lines, {text = text, color = color})
end

function ConsoleClass:draw()
	love.graphics.setColor(Constants.Colors.ConsoleBackground)
	love.graphics.rectangle("fill",
		Constants.Console.DrawX,
		Constants.Console.DrawY,
		Constants.Console.DrawWidth,
		Constants.Console.DrawHeight,
		Constants.Console.DrawRadius
	)
	for k,v in pairs(self.lines) do
		love.graphics.setColor(v.color)
		love.graphics.print(v.text,
			Constants.Console.DrawX + Constants.Console.TextOffsetX,
			Constants.Console.DrawY + Constants.Console.TextOffsetY + (k-1) * Constants.Console.LineHeight
		)
	end
	love.graphics.setColor(Constants.Colors.Default)
end

return ConsoleClass

