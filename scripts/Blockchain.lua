local customWeapons     = require "necro.game.data.item.weapon.CustomWeapons"
local event             = require "necro.event.Event"
local currentLevel      = require "necro.game.level.CurrentLevel"
local object            = require "necro.game.object.Object"
local action            = require "necro.game.system.Action"
local attack            = require "necro.game.character.Attack"
local components        = require "necro.game.data.Components"

local dev = true

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

local function killComboMultipliedGold(killCombo,previousGoldCounter)
	--[[
		Calculates the amount of gold dropped by the enemy,
		based on the kill combo. Multiplier increases by 0.5, rounded down,
		at each kill. This new multiplier is applied last.
	]]
	return (killCombo*0.5+1)*previousGoldCounter
end

components.register {
	killCombo = {
		components.field.int("combo"),
		components.field.int("lastCombo")
	}
}

customWeapons.registerShape({
	name                    = "Blockchain",
	friendlyName            = "Blockchain",
	hint                    = "Dmg + with enough money, keep on killing for more gold",
	components = {
		weaponPattern = {
			pattern =  {
				passWalls = true, swipe = "dagger",
				dashDirection = action.Direction.RIGHT, -- Same direction as attack
				tiles = { {
					-- Enemy exactly one tile in front of holder
					offset = {1,0},
					swipe = "dagger",
					dashDirection = false, -- Useless, but more understandable
				}, {
					-- Enemy one tile away, diagonally (on the left)
					offset = {1,1},
					clearance = {{1,0}},
					direction = action.Direction.DOWN -- enemy is hit at their right
				}, {
					-- Enemy one tile away, diagonally (on the right).
					-- Same pattern as the previous one, except offset(y) is negative
					offset = {1,-1},
					clearance = {{1,0}},
					direction = action.Direction.UP -- enemy is hit at their left
				}, {
					-- Enemy is one tile further on the left than 2nd pattern
					offset = {1, 2},
					clearance = {{1,1}, {1,0}}, -- Can't attack if there is something between enemy and player
					direction = action.Direction.DOWN
				}, {
					-- Same, but enemy is on the right
					offset = {1, -2},
					clearance = {{1,-1}, {1,0}},
					direction = action.Direction.UP
				} }
			}
		},
		blockchain_killCombo = { combo = 0, lastCombo = 0 }
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

event.holderKill.add("killComboMultiplier", {order="currencyMinimum", sequence=1, filter="blockchain_weaponTypeBlockchain"}, function(ev)
	if ev.currency ~= nil then
		-- Multiplies the gold drop by the new value, based on the kill combo
		dbg("old amount "..ev.currency.amount)
		ev.currency.amount = killComboMultipliedGold(ev.entity.blockchain_killCombo.combo,ev.currency.amount)
		dbg("new amount "..ev.currency.amount)
		-- Increments the kill combo
		ev.entity.blockchain_killCombo.combo = ev.entity.blockchain_killCombo.combo + 1
	end
end)

event.holderMoveResult.add("resetKillCounter", {order="itemCombo", filter="blockchain_killCombo"},function(ev)
	-- If same combo for 2 beats -> not a kill combo anymore, no enemy died last beat
	if ev.entity.blockchain_killCombo.combo == ev.entity.blockchain_killCombo.lastCombo then
		ev.entity.blockchain_killCombo.combo = 0
	end
	ev.entity.blockchain_killCombo.lastCombo = ev.entity.blockchain_killCombo.combo
end)

if dev then
	event.levelLoad.add("spawn", {order="entities"}, function(ev)
		object.spawn("blockchain_WeaponGoldBlockchain",0,0)
		object.spawn("RingGold",0,0)
		object.spawn("FeetBalletShoes",0,0)
	end)

	event.levelLoad.add("itemPoolInfo",{order="training",sequence=1}, function(ev)
		dbg(ev)
	end)
end

