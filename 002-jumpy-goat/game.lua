local GameState = require "love-toys.third-party.hump.gamestate" 
local Vector = require "love-toys.third-party.hump.vector"

require "entities"

local game = {

	player = PlayerEntity(Vector(50, 50))

}

function game:draw()
	game.player:draw()
end

function game:update(dt)
end

function game:keyreleased(key, code)
	if key == 'escape' then
		GameState.switch(states.Menu)
	end
end

return game

