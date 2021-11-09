local event             = require "necro.event.Event"
local components        = require "necro.game.data.Components"
local customEntities    = require "necro.game.data.CustomEntities"
local object            = require "necro.game.object.Object"
dbg("mod loaded")
local dev
dev = true

components.register {
	baseBlockchain = {},
}
customEntities.extend {
	name        = "baseBlockchain",
	template    = customEntities.template.item("weapon_dagger"),
	data = {
		flyaway = "BLOCKCHAIN",
		hint    = "DMG + WITH MONEY, MORE MONEY WITH COMBO",
		slot    = "weapon"
	},
	components = {
		sprite = {
			texture = "mods/blockchain/gfx/base.png"
		}
	}
}

if dev then
	event.levelLoad.add("spawn", {order="entities"}, function (ev)
		object.spawn("blockchain_baseBlockchain",-1,-1)
	end)
	dbg("dev mode")
end