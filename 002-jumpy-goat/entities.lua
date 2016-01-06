local Class = require "love-toys.third-party.hump.class"
local Vector = require "love-toys.third-party.hump.vector"

PlayerEntity = Class {
	init = function(self, position)
		self.position = position:clone()
		self.direction = PlayerEntity.LeftDirection
	end;

	draw = function(self)
		love.graphics.rectangle("fill", self.position.x - 25, self.position.y - 25, 50, 50)
	end;

	LeftDirection = 0;
	RightDirection = 1;
}

PlatformEntity = Class {
	init = function(self, position)
		self.position = position:clone()
	end;

	draw = function(self)
		love.graphics.rectangle("fill", self.position.x - 100, self.position.y - 10, 200, 20)
	end;
}

