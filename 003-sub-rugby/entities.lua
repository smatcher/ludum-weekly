local Class = require "love-toys.third-party.hump.class"
local Vector = require "love-toys.third-party.hump.vector"

local Entities = {
	GridClass = require "grid",
	TooltipsClass = require "tooltips",
	BombClass = require "bomb",
	SubmarineClass = require "submarine",
	ConsoleClass = require "console",
}

function Entities:loadAssets()
	for k,v in pairs(self) do
		if type(v) == 'table' and v.loadAssets ~= nil then
			v.loadAssets()
		end
	end
end

return Entities

