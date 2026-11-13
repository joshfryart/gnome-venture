-- banner-SA-pets: Canopy Critter Co., treehouse shop in a big rainforest trunk
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/bn.lua")
local L, R2, R = B.L, B.R2, B.R
local floor, hsh = math.floor, B.hsh
local c = B.new()
B.bands(c, 0, 90, { "#f8d8a0", "#f6c88c", "#f4b87c", "#e8a874", "#d89870" }, "sky")
B.sun(c, 60, 34, 12, "#fff0b8", "#f6c870", "#fbe4b4")
-- far green hills (layered)
local function hill(y0, amp, ph, ramp, step)
  for x = 0, 479 do
    local y = floor(y0 + amp * math.sin(x / step + ph) + amp * 0.5 * math.sin(x / (step * 0.37) + ph * 2))
    for yy = y, 99 do B.put(c, x, yy, (yy - y < 2) and ramp[1] or ramp[2], "hills") end
  end
end
hill(58, 5, 0, { "#8ab07a", "#6e9a68" }, 38) hill(68, 5, 2, { "#5c9a58", "#4a8650" }, 30) hill(78, 4, 4, { "#3a7e48", "#2e6a42" }, 26)
-- forest floor
B.bands(c, 94, 119, { "#2e6a42", "#265c3a", "#1f4e32", "#1a432c" }, "floor")
B.speck(c, L.rect(0, 94, 479, 119), { "#3a7e48", "#4a9a4c", "#143a2c" }, 0.08, 3)
-- canopy ceiling band + vines
for x = 0, 479 do
  local d = 6 + floor(3 * math.sin(x / 7) + 2 * math.sin(x / 3.1 + 1))
  for y = 0, d do B.put(c, x, y, (y >= d - 1) and "#143a2c" or ((hsh(x, y, 1) < 0.3) and "#1f5a3a" or "#235e3a"), "canopy") end
end
for _, x in ipairs({ 20, 44, 100, 132, 360, 392, 440, 466 }) do
  for y = 7, 20 + (x % 17) do B.put(c, x, y, (y % 5 == 0) and "#6ac060" or "#2f7a48", "vine") if y % 7 == 3 then B.put(c, x + 1, y, "#52ac50", "vine") end end
end
-- far stilt huts
local function hut(x, y)
  B.solid(c, L.rect(x - 1, y, x, y + 14), R2.TABBY, 1, 1, "stilt") B.solid(c, L.rect(x + 12, y, x + 13, y + 14), R2.TABBY, 1, 1, "stilt")
  B.solid(c, L.rect(x - 2, y - 8, x + 15, y), R.WOOD, 1, 1, "hut")
  B.solid(c, L.poly({ { x - 5, y - 7 }, { x + 18, y - 7 }, { x + 12, y - 15 }, { x + 1, y - 15 } }), R2.THATCH, 1, 1, "hut")
  B.rectc(c, x + 4, y - 5, x + 8, y - 1, "#ffd870", "glass")
end
hut(36, 66) hut(420, 62)
-- big trunk
local trunk = L.poly({ { 196, 119 }, { 206, 70 }, { 214, 36 }, { 300, 36 }, { 308, 70 }, { 322, 119 } })
B.solid(c, trunk, R2.TABBY, 3, 3, "trunk")
trunk:each(function(x, y) local h = hsh(floor(x / 3), y, 5) if (x + floor(y / 9)) % 11 == 0 and h < 0.7 then B.put(c, x, y, R2.TABBY.s, "bark") elseif h > 0.96 then B.put(c, x, y, R2.TABBY.L, "bark") end end)
B.part(c, L.poly({ { 190, 119 }, { 200, 108 }, { 206, 119 } }), R2.TABBY, 1, 1, "root")
-- treehouse platform (deck)
B.solid(c, L.rect(150, 94, 360, 100), R.WOOD, 1, 1, "deck") B.planks(c, L.rect(150, 95, 360, 99), R.WOOD, 14, 152)
-- house body
local body = L.rect(168, 56, 342, 94)
B.solid(c, body, R.WOOD, 2, 2, "wall") B.planks(c, body, R.WOOD, 6, 170)
-- thatched roof with cat ears
local roof = L.poly({ { 154, 58 }, { 356, 58 }, { 336, 36 }, { 174, 36 } })
B.solid(c, roof, R2.THATCH, 2, 3, "roof") B.thatch(c, roof, R2.THATCH)
local ears = L.poly({ { 184, 40 }, { 182, 18 }, { 212, 36 } }):add(L.poly({ { 326, 40 }, { 328, 18 }, { 298, 36 } }))
B.solid(c, ears, R2.THATCH, 1, 2, "roof") B.thatch(c, ears, R2.THATCH)
B.px(c, { { 185, 24, "#e8909e" }, { 185, 27, "#e8909e" }, { 186, 30, "#e8909e" }, { 325, 24, "#e8909e" }, { 325, 27, "#e8909e" }, { 324, 30, "#e8909e" } })
-- eye windows (round, glow, slit pupil)
for _, ex in ipairs({ 212, 296 }) do
  local w = L.ellipse(ex, 68, 13, 11)
  B.solid(c, w, R.GOLD, 1, 1, "window")
  B.fill(c, L.ellipse(ex, 68, 10, 8), "#ffd870", "glow")
  B.bands(c, 61, 75, { "#fff0a8", "#ffd870", "#f8b848" }, "glow", ex - 10, ex + 10)
  B.rectc(c, ex - 1, 61, ex, 75, "#2b1c26", "pupil") B.rectc(c, ex - 1, 62, ex - 1, 64, "#ffffff", "pupil")
  L.ellipse(ex, 68, 10, 8):each(function(x, y) if not L.ellipse(ex, 68, 10, 8):has(x, y) then end end)
end
-- nose + whiskers
B.solid(c, L.poly({ { 250, 76 }, { 262, 76 }, { 256, 82 } }), R.PINK, 1, 1, "nose")
for _, w in ipairs({ { 232, 82, 244, 84 }, { 232, 86, 244, 85 }, { 280, 84, 268, 82 }, { 280, 85, 268, 86 } }) do B.px(c, (function() local t = {} L.line({ { w[1], w[2] }, { w[3], w[4] } }):each(function(x, y) t[#t + 1] = { x, y, "#fff0a0" } end) return t end)()) end
-- door arch (open, warm)
local dr = L.rect(240, 84, 270, 94):add(L.ellipse(255, 86, 15, 6))
B.solid(c, dr, R.WOOD, 1, 1, "door") B.fill(c, L.rect(243, 86, 267, 94), "#ffc858", "glow") B.rectc(c, 243, 92, 267, 94, "#f8b848", "glow")
B.solid(c, L.ellipse(255, 90, 4, 3), R2.GINGER, 1, 1, "cat") 
-- fish sign bracket right + toucan
B.rectc(c, 356, 60, 356, 84, R.WOOD.D, "bracket") B.rectc(c, 356, 60, 382, 60, R.WOOD.D, "bracket") B.rectc(c, 357, 61, 381, 61, R.WOOD.m, "bracket")
B.rectc(c, 376, 62, 376, 68, "#5a3a28", "rope")
local fish = L.ellipse(376, 76, 10, 5):add(L.poly({ { 385, 76 }, { 392, 70 }, { 392, 82 } }))
B.solid(c, fish, R2.BLUEC, 1, 1, "sign") B.px(c, { { 370, 74, B.INK }, { 371, 74, B.INK }, { 374, 78, R2.BLUEC.s }, { 378, 77, R2.BLUEC.s } })
-- toucan on bracket
B.solid(c, L.ellipse(366, 54, 4, 5), R.NAVY, 1, 1, "bird") B.solid(c, L.poly({ { 369, 51 }, { 380, 52 }, { 369, 57 } }), R.ORANGE, 1, 1, "beak")
B.px(c, { { 366, 52, "#ffffff" }, { 367, 52, "#ffffff" }, { 364, 53, "#fff4d8" }, { 368, 51, B.INK }, { 365, 49, R.GOLD.L } })
-- orange cat on rail
B.rectc(c, 168, 90, 236, 90, R.WOOD.D, "rail") B.rectc(c, 168, 91, 236, 91, R.WOOD.m, "rail")
B.catSit(c, 186, 90, R2.GINGER, { stripe = R2.GINGER.b })
-- vine ladder
for y = 100, 118, 4 do B.rectc(c, 274, y, 282, y, R.WOOD.m, "rung") end
B.rectc(c, 274, 100, 274, 118, "#4a9a4c", "vine") B.rectc(c, 282, 100, 282, 118, "#4a9a4c", "vine")
-- feather bunting
B.bunting(c, 120, 14, 360, 20, 18, { R.RED, R.GOLD, R2.TEALC, R.PINK, R2.BLUEC }, 10)
B.bunting(c, 360, 20, 478, 10, 8, { R.GOLD, R2.TEALC, R.RED }, 10)
-- big foreground leaves
local function bigleaf(x, y, dx, dy, w, ramp) local m = L.tube({ { x, y }, { x + dx * .5, y + dy * .4 - 8 }, { x + dx, y + dy } }, function(t) return max and 0 or w * math.sin(t * math.pi) ^ 0.7 + 0.8 end) B.solid(c, m, ramp, 1, 2, "fore") B.line = nil end
local function leaf(x, y, dx, dy, w, ramp)
  local m = L.tube({ { x, y }, { x + dx * .5, y + dy * .4 - 8 }, { x + dx, y + dy } }, function(t) return w * math.sin(t * math.pi) ^ 0.7 + 0.8 end)
  B.solid(c, m, ramp, 1, 2, "fore")
  L.line({ { x, y }, { floor(x + dx * .5), floor(y + dy * .4 - 8) }, { x + dx, y + dy } }):clip(m):each(function(xx, yy) B.put(c, xx, yy, ramp.s, "vein") end)
end
leaf(-4, 118, 54, -22, 9, R2.LEAF) leaf(0, 118, 36, -34, 8, R2.LEAFD) leaf(484, 118, -56, -24, 9, R2.LEAF) leaf(480, 118, -34, -36, 8, R2.LEAFD)
-- mushrooms + jug (forest floor quirk)
for _, p in ipairs({ { 120, 112 }, { 134, 114 } }) do B.solid(c, L.ellipse(p[1], p[2] - 2, 4, 3), R.RED, 1, 1, "mush") B.rectc(c, p[1] - 1, p[2], p[1], p[2] + 3, "#f4ead0", "mush") B.px(c, { { p[1] - 2, p[2] - 3, "#fff4d8" }, { p[1] + 1, p[2] - 2, "#fff4d8" } }) end
B.finish(c, "banner-SA-pets")
