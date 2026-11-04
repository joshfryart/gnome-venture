-- rock-garden (final draft D12, Sonnet). A shallow wooden tray of raked sand with ripples that circle three smooth
-- stones, one capped with moss. quirk: a tiny snail is climbing the tall stone.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dD12.lua")
local H, HP, X, K, B = D.H, D.HP, D.X, D.K, D.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("rock-garden")
D.shadow(c, 32, 58, 27, 2.5)
local tray = c:rrect(5, 32, 59, 56, 3)
D.lit(c, tray, D.R.wood, 4, {})
local SA = D.R.sand
local sand = c:rrect(8, 34, 56, 51, 2)
D.lit(c, sand, SA, 6, { wrap = 0.4, amb = 0.3 })
-- rake lines
for y = 37, 49, 3 do for x = 9, 55 do if sand:has(x, y) and (x + y) % 9 ~= 0 then c:px(x, y, SA[2]) c:px(x, y + 1, SA[5]) end end end
-- concentric ripples around stone spots
for _, s in ipairs{ {20,42},{41,40} } do for r = 1, 2 do
  local ring = c:ellipse(s[1], s[2], 6 + r * 3, 3 + r * 1.6)
  ring:cut(c:ellipse(s[1], s[2], 5 + r * 3, 2.2 + r * 1.6)):clip(sand)
  c:fillMask(ring, SA[2]) end end
-- stones
local function stone(pts, ramp)
  local m = c:poly(pts) D.lit(c, m, ramp, 4, { wrap = 0.2 }) return m
end
local s1 = stone({ {14,43},{14,31},{19,23},{27,25},{29,34},{27,44} }, D.R.stone)
local s2 = stone({ {35,44},{34,36},{39,31},{47,33},{49,40},{46,45} }, D.R.stone)
local s3 = stone({ {44,33},{45,27},{50,25},{54,29},{53,34} }, D.R.ink)
-- moss cap
local mc = c:poly{ {14,31},{19,23},{27,25},{28,30},{23,29},{19,31} }:clip(s1)
D.lit(c, mc, D.R.leaf, 2, {})
c:px(17, 29, "#9dd06c") c:px(21, 26, "#9dd06c")
-- snail on stone 1
local sh = B.ell(24, 36, 2.6, 2.6, 0)
B.lit(c, sh, { "#8f4a1f", "#b8682a", "#d98322", "#f5b82e", "#ffd060", "#ffe38a" }, 1.8)
c:px(24, 36, "#8f4a1f") c:px(25, 35, "#8f4a1f")
c:fillMask(c:rect(19, 38, 22, 39), "#c9b2f0") c:px(18, 37, "#c9b2f0") c:px(18, 36, "#8a6fd0") c:px(20, 37, "#8a6fd0")
c:px(17, 35, "#2b1c26")
D.fin()
