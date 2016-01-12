local Camera = require "love-toys.third-party.hump.camera" 
local GameState = require "love-toys.third-party.hump.gamestate" 
local Timer = require "love-toys.third-party.hump.timer"
local Vector = require "love-toys.third-party.hump.vector"

local Entities = require "entities"

local game = {
}

function game:init()
end

function game:draw()
end

function game:update(dt)
end

function game:keypressed(key, code, isrepeat)
--	if key == 'left' then
--		self.player.direction = PlayerEntity.LeftDirection
--	end
--
--	if key == 'right' then
--		self.player.direction = PlayerEntity.RightDirection
--	end
end

function game:keyreleased(key, code)
	if key == 'escape' then
		GameState.switch(states.Menu)
	end
end

return game

