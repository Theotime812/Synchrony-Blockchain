local customWeapons     = require "necro.game.data.item.weapon.CustomWeapons"
local commonWeapon      = require "necro.game.data.item.weapon.CommonWeapon"
local event             = require "necro.event.Event"
local currentLevel      = require "necro.game.level.CurrentLevel"
local object            = require "necro.game.object.Object"

local dev = false

local function minGoldAmount()
	--[[
		Defined by geometric sequence
		with initial value is u(1) = 500
		and common ratio is 2.
		Index is the depth number of the current level.
	]]
	local init = 500
	local commonRatio = 2
	return init * commonRatio^(currentLevel.getDepth() - 1)
end

customWeapons.registerShape({
	name                    = "Blockchain",
	friendlyName            = "Blockchain",
	hint                    = "Dmg + with enough money, keep on killing for more gold",
	components = {
		weaponPattern = {
			pattern = commonWeapon.pattern {
				tiles = {
					{ offset = { 1, 0 } }
				}
			}
		}
	},
	texture                 = "mods/blockchain/gfx/texture.png",
	excludeMaterials = {
		"Electric",
		"Jeweled",
		"Frost",
		"Phasing",
	}
})

event.holderDealDamage.add("goldAmountMultiplier", {order = "baseMultiplier", filter = "blockchain_weaponTypeBlockchain"}, function(ev)
	if (ev.holder.goldCounter and ev.holder.goldCounter.amount >= minGoldAmount()) then
		ev.damage = ev.damage * 2;
	end
end)

if dev then
	event.levelLoad.add("spawn", {order="entities"}, function (ev)
		object.spawn("blockchain_WeaponGoldBlockchain",0,0)
		object.spawn("RingGold",0,0)
		object.spawn("FeetBalletShoes",0,0)
	end)
end