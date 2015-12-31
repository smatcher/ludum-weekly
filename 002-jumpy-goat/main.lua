local GameState = require "love-toys.third-party.hump.gamestate" 

states = {}
states.Menu = require "menu"
states.Game = require "game"

function love.load()
	GameState.registerEvents()
	GameState.switch(states.Menu)
end

