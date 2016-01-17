local Class = require "love-toys.third-party.hump.class"

local SubmarineClass = require "submarine"

local BombClass = Class {}


function BombClass:init()
	self.x = Constants.Bomb.StartX
	self.y = Constants.Bomb.StartY
	self.sub_grabbing = nil -- submarine owning the bomb
end

function BombClass:drawOverSubs()
	return self.sub_grabbing ~= nil and self.sub_grabbing.team == SubmarineClass.Teams.Player
end

function BombClass:draw(grid)
	local draw_x, draw_y = grid:cellCoord(self.x, self.y)
	local drawn = BombClass.Bomb
	if self:drawOverSubs() then
		drawn = BombClass.BombGrabbed
	end
	love.graphics.draw(drawn,
		draw_x,
		draw_y
	)
end

function BombClass:loadAssets()
	BombClass.Bomb = love.graphics.newImage("bomb.png")
	BombClass.BombGrabbed = love.graphics.newImage("bomb-grabbed.png")
end

return BombClass

