
local Entities = {
	GridClass = require "grid",
	TooltipsClass = require "tooltips",
	BombClass = require "bomb",
	SubmarineClass = require "submarine",
	ConsoleClass = require "console",
	OrdersMenuClass = require "orders_menu",
}

function Entities:loadAssets()
	for k,v in pairs(self) do
		if type(v) == 'table' and v.loadAssets ~= nil then
			v.loadAssets()
		end
	end
end

return Entities

