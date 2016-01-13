local Class = require "love-toys.third-party.hump.class"

local SubmarineClass = Class {
	Teams = {
		Player = 0,
		Remote = 1,
	},

	Directions = {
		North = 0,
		NorthEast = 1,
		East = 2,
		SouthEast = 3,
		South = 4,
		SouthWest = 5,
		West = 6,
		NorthWest = 7,
	},

	Actions = {
		-- Move actions
		Move_1  = 00,
		Move_2  = 01,
		Move_3  = 02,
		Move_4  = 03,
		Move_5  = 04,
		Move_6  = 05,
		-- Turn actions
		Turn_N  = 10,
		Turn_NE = 11,
		Turn_E  = 12,
		Turn_SE = 13,
		Turn_S  = 14,
		Turn_SW = 15,
		Turn_W  = 16,
		Turn_NW = 17,
		-- Interact actions
		Fire    = 20,
		Special = 21, -- Reserved for later use
		Grab    = 22,
		-- Other
		Wait    = 30,
	},
}

function SubmarineClass:init()
	self.sonar_bleep = false
	self.team = SubmarineClass.Teams.Player
	self.x = -1
	self.y = -1
	self.in_game = false
	self.respawn_cooldown = 0
	self.direction = SubmarineClass.Directions.North
	self.action_1 = nil
	self.action_2 = nil
end

function SubmarineClass:draw(grid)
	if self.in_game == false then
		return
	end

	if self.team == SubmarineClass.Teams.Player then
		love.graphics.setColor(0, 255, 0, 255)
	else
		love.graphics.setColor(255, 0, 0, 255) -- TODO : skip displaying Remote Subs
	end

	local draw_x, draw_y = grid:cellCoord(self.x, self.y)
	love.graphics.rectangle("fill",
		draw_x,
		draw_y,
		24, -- Hardcoded while not definitive draw function
		24
	)
	love.graphics.setColor(0,0,0,255)
	local markers = {"N", "NE", "E", "SE", "S", "SW", "W", "NW"}
	local marker = markers[self.direction+1]
	love.graphics.print(marker, draw_x + 2, draw_y + 2)

	if self.sonar_bleep then
		love.graphics.print("b", draw_x + 14, draw_y + 10)
	end
	love.graphics.setColor(Constants.Colors.Default)
end

return SubmarineClass

