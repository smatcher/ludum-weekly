local Class = require "love-toys.third-party.hump.class"

local BombClass = Class {}

function BombClass:init()
	self.x = Constants.Bomb.StartX
	self.y = Constants.Bomb.StartY
	self.grabbed = false
end

function BombClass:draw(grid)
	local draw_x, draw_y = grid:cellCoord(self.x, self.y)
	love.graphics.draw(BombClass.Bomb,
		draw_x,
		draw_y
	)
end

function BombClass:loadAssets()
	BombClass.Bomb = love.graphics.newImage("bomb.png")
end

return BombClass

