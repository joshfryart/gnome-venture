local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA0.lua")
local HP, X, K, INK, CREAM = D.HP, D.X, D.K, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- crop-tuber: round turnip, purple crown over a cream belly with a wavy dividing line, tail root, three leaves.
-- quirk: a small bee has landed on the right leaf tip.
local c = D.new("crop-tuber")
local PUR = { "#35295f", "#5a3f8a", "#7a52a8", "#9a6cc4", "#b890dc", "#dcc4f4" }
local WHT = { "#7a5a7a", "#b898a8", "#dcc0c0", "#f0dcd0", "#fcf0e0", "#fffaf0" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
c:groundShadow(32, 59, 11, 2)
-- leaves first
D.leaf(c, 31, 28, 19, 10, 4.2, LEAF, { 5, 9 })
D.leaf(c, 33, 28, 45, 10, 4.2, LEAF, { 5, 9 })
D.leaf(c, 32, 27, 32, 6, 3.2, LEAF, { 5, 10 })
local m = c:ellipse(32, 38, 15, 12):add(c:poly{ {26, 46}, {31, 58}, {32, 58}, {34, 46} })
local n = X.pillow(m, 7)
local v = X.light(n, { amb = 0.08, wrap = 0.25 })
local top, bot = HP.mask(), HP.mask()
local function edge(x) return 37 + floor(sin(x * 0.55) * 2 + 0.5) end
m:each(function(x, y) if y < edge(x) then top:set(x, y) else bot:set(x, y) end end)
local cuts = { 0.26, 0.44, 0.6, 0.75, 0.88 }
X.tone(c, top, v, PUR, { cuts = cuts })
X.tone(c, bot, v, WHT, { cuts = cuts })
bot:each(function(x, y) if top:has(x, y - 1) then c:px(x, y, "#9a6cc4") end end)
-- hairy tail
c:px(31, 58, "#b898a8") c:px(33, 57, "#dcc0c0") c:px(29, 55, "#b898a8")
-- crown sprouts and spec
c:part(c:rect(30, 26, 34, 29), "moss", { noshade = true, nopop = true })
for _, p in ipairs{ {21, 33}, {22, 32}, {21, 34}, {22, 33} } do c:px(p[1], p[2], "#e8d0fc") end
c:px(21, 33, CREAM)
-- bee on right leaf
local bee = {
  "..cc..",
  ".gKgK.",
  "gKgKKK",
  ".GKGK.",
}
c:paint(bee, 44, 5, { c = "#fff4d6", g = "#f5b82e", G = "#d98322", K = INK })
D.fin()
