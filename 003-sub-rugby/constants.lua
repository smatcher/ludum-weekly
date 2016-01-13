Constants = {
	Game = {
		SubCountPerTeam = 4,
		RespawnCooldown = 3,
	},

	Bomb = {
		StartX = 12,
		StartY = 8,
	},

	Grid = {
		-- Number of cells
		Width = 25,
		Height = 17,
		TeamAreaDepth = 3,

		-- Pixel dimensions
		DrawWidth = 600,
		DrawHeight = 408,
		DrawX = 100,
		DrawY = 25,
		HorMarkerOffsetX = 6, -- Horizontal marker offset
		HorMarkerOffsetY = 14,
		VerMarkerOffsetX = 14, -- Vertical marker offset
		VerMarkerOffsetY = 6,
	},

	Tooltips = {
		DrawX = (800 - 32 - 4),
		DrawY = 4,
		DrawInfoX = 500,
		DrawInfoY = 0,
		DrawInfoWidth = 300,
		DrawInfoHeight = 600,
		TextOffsetX = 5,
		TextOffsetY = 5,
	},

	Console = {
		DrawWidth = 650,
		DrawHeight = 125,
		DrawX = 75,
		DrawY = 450,
		DrawRadius = 2,
		TextOffsetX = 5,
		TextOffsetY = 5,
		LineHeight = 20,
		MaxLines = 6
	},

	Colors = {
		Background = {105, 140, 160, 255},
		ConsoleBackground = {27, 33, 37, 255},
		TooltipBackground = {27, 33, 37, 192},
		TeamRedArea = {160, 105, 140, 255},
		TeamGreenArea = {140, 160, 107, 255},
		GridMarkings = {255, 255, 255, 255},
		TooltipDim = {192, 192, 192, 64},
		TooltipNew = {255, 190, 85, 255},
		TooltipHovered = {192, 192, 192, 128},
		TextAlert = {230, 130, 55, 255},
		TextInfo = {110, 160, 105, 255},
		TextNormal = {192, 192, 192, 255},
		Default = {255, 255, 255, 255},
	},
	
}

