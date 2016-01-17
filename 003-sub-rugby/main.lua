local GameState = require "love-toys.third-party.hump.gamestate" 
local Timer = require "love-toys.third-party.hump.timer" 
local Entities = require "entities"

states = {}
states.Menu = require "menu"
states.Game = require "game"
states.Connecting = require "connecting"
states.Disconnected = require "disconnected"

require "constants"

global_blinker = 1.0

function love.load()
	math.randomseed(os.time())

	Entities:loadAssets()

	GameState.registerEvents()
	GameState.switch(states.Menu)

	local easeIn, easeOut
	easeIn = function()
		Timer.tween(0.5, _G, {global_blinker = 1.0}, 'in-out-quad', easeOut)
	end
	easeOut = function()
		Timer.tween(0.5, _G, {global_blinker = 0.0}, 'in-out-quad', easeIn)
	end
	easeOut()
end

