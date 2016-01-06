local Class = require "love-toys.third-party.hump.class"
local Vector = require "love-toys.third-party.hump.vector"

PlayerEntity = Class {
	init = function(self, position)
		self.position = position:clone()
		self.direction = PlayerEntity.LeftDirection
	end;

	draw = function(self)
		local g = PlayerEntity.texture
		local x_scale = 1
		if self.direction == PlayerEntity.RightDirection then
			x_scale = -1
		end
		love.graphics.draw(g, self.position.x, self.position.y, 0, x_scale, 1, g:getWidth()/2, g:getHeight()/2)
	end;

	LeftDirection = 0;
	RightDirection = 1;
}

PlatformEntity = Class {
	init = function(self, position)
		self.position = position:clone()
	end;

	draw = function(self)
		local g = PlatformEntity.texture
		love.graphics.draw(g, self.position.x, self.position.y, 0, 1, 1, g:getWidth()/2, g:getHeight()/2)
	end;
}

function loadEntityAssets()
	PlayerEntity.texture = love.graphics.newImage("goat.png")
	PlatformEntity.texture = love.graphics.newImage("rock.png")
end
