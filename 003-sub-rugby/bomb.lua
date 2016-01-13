local Class = require "love-toys.third-party.hump.class"

local BombClass = Class {}

function BombClass:init()
	self.x = Constants.Bomb.StartX
	self.y = Constants.Bomb.StartY
	self.grabbed = false
end

function BombClass:draw(grid)
	love.graphics.setColor(192, 192, 32, 255)
	local draw_x, draw_y = grid:cellCoord(self.x, self.y)
	love.graphics.rectangle("fill",
		draw_x + 6,
		draw_y + 6,
		12, -- Hardcoded while not definitive draw function
		12,
		6
	)
	love.graphics.setColor(Constants.Colors.Default)
end

return BombClass

