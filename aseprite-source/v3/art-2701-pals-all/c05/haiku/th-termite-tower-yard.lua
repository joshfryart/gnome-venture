-- Termite Tower (th-termite-tower), yard 64x64. Haiku first pass. Common, rootwarden.
-- Builds a red tower one grain at a time and never says sorry.
-- quirk: grains keep dropping off the base.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(dir .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (dir .. "/")
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "th-termite-tower-yard" }
local function halfL(y) return 26 - (y - 12) * 8 / 46 end
local function halfR(y) return 38 + (y - 12) * 8 / 46 end
c:groundShadow(32, 60, 18, 3)
c:part(c:ellipse(32, 12, 7, 3), "ember")
c:part(c:poly({ { 26, 12 }, { 38, 12 }, { 46, 58 }, { 18, 58 } }), "ember")
for _, y in ipairs({ 22, 31, 40, 49 }) do
  for x = math.floor(halfL(y)) + 2, math.floor(halfR(y)) - 2 do c:px(x, y, P.ember.deep) end
end
c:px(14, 52, P.gold.base) c:px(13, 53, P.gold.hi) c:px(50, 56, P.gold.base) c:px(51, 57, P.gold.hi)
c:eyeLocked(25, 27) c:eyeLocked(35, 27)
c:cheek(22, 35) c:cheek(40, 35)
c:px(32, 34, P.ember.deep) c:px(33, 34, P.ember.deep)
c:px(29, 38, P.ink) c:px(30, 39, P.ink) c:px(31, 39, P.ink) c:px(32, 39, P.ink) c:px(33, 39, P.ink) c:px(34, 38, P.ink)
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "th-termite-tower-yard.aseprite", png = out .. "th-termite-tower-yard.png", scale = 1 }
