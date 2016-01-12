local GameState = require "love-toys.third-party.hump.gamestate" 

states = {}
states.Menu = require "menu"
states.Game = require "game"
states.Connecting = require "connecting"
states.Disconnected = require "disconnected"

require "constants"

function love.load()
	math.randomseed(os.time())

	loadEntityAssets()

	GameState.registerEvents()
	GameState.switch(states.Menu)
end

