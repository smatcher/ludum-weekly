local Class = require "love-toys.third-party.hump.class"

local SubmarineClass = require "submarine"

local TorpedoClass = Class {}

function TorpedoClass:init(x, y, direction)
	self.x = x
	self.y = y
	self.direction = direction
	self.destroyed = false
end

function TorpedoClass:move(all_subs, subs_destroyed)
	local dx, dy = SubmarineClass.deltaCellsForDirection(self.direction)
	for i=1,Constants.Game.TorpedoSpeed,1 do
		self.x = self.x + dx
		self.y = self.y + dy
		for _,sub in pairs(all_subs) do
			if sub.x == self.x and sub.y == self.y then
				subs_destroyed[sub] = true
				self.destroyed = true
				return
			end
		end
	end

	if self.x < 0
	or self.y < 0
	or self.x >= Constants.Grid.Width
	or self.y >= Constants.Grid.Height then
		self.destroyed = true
	end
end

function TorpedoClass:draw(grid)
	-- don't draw torpedoes
	--local draw_x, draw_y = grid:cellCoord(self.x, self.y)
	--love.graphics.print("T", draw_x, draw_y)
end

return TorpedoClass

