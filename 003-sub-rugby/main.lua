local GameState = require "love-toys.third-party.hump.gamestate" 
local Entities = require "entities"

states = {}
states.Menu = require "menu"
states.Game = require "game"
states.Connecting = require "connecting"
states.Disconnected = require "disconnected"

require "constants"

function love.load()
	math.randomseed(os.time())

	Entities:loadAssets()

	GameState.registerEvents()
	GameState.switch(states.Menu)
end

