local Class = require "love-toys.third-party.hump.class"
local Vector = require "love-toys.third-party.hump.vector"

BackgroundEntity = Class {
	init = function(self)
	end;

	draw = function(self, camera)
		local g = BackgroundEntity.sky_texture
		love.graphics.draw(g, 400, 300, 0, 2, 2, g:getWidth()/2, g:getHeight()/2)

		local layer_x_offsets = {
			0;
			196;
			103;
			189;
			25,
			256;
		}

		-- TODO : add vertical parallaxe effect
		g = BackgroundEntity.mountain_texture
		for layer = 1, 6, 1 do
			local factor = layer / 6.0 -- linear progression from 0 (back layer) to 1 (front layer)
			local fade_intensity = factor * factor * factor * 255
			love.graphics.setColor(fade_intensity, fade_intensity, fade_intensity, fade_intensity)
			local x_start = - layer_x_offsets[layer] - ((factor * camera.x) % g:getWidth())
			local y = 420 + factor * 120
			for x = x_start, 800 + g:getWidth(), g:getWidth() do
				love.graphics.draw(g, x, y, 0, 1.2 * factor, 1.2 * factor, g:getWidth()/2, g:getHeight()/2)
			end
		end
		love.graphics.setColor(255, 255, 255)
	end;
}

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
	BackgroundEntity.sky_texture = love.graphics.newImage("sky.png")
	BackgroundEntity.mountain_texture = love.graphics.newImage("mountain.png")
	PlayerEntity.texture = love.graphics.newImage("goat.png")
	PlatformEntity.texture = love.graphics.newImage("rock.png")
end
