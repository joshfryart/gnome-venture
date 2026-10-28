-- wonder-goat-path-vineyards.lua : "Terraced vines on a steep hillside, and a harvest in full swing. The goats are supervising."
-- Thing to do: help with the harvest. Warm golden-hour afternoon, South Europe (terracotta, cypress, olive).
local K = dofile("/home/user/gnome-venture/aseprite-source/final/scripts/wonders/w5lib.lua")
local L, GV, TINY = K.L, K.GV, K.TINY
local W, H = L.W, L.H
local c = L.new()
local function R(h, o) return GV.ramp(h, o) end

L.sky(c, "warm", 56)
-- far sea and hazy hills
c:fill(c:rect(0, 40, 110, 47), "#8fcbd8"); c:fill(c:rect(0, 40, 110, 40), "#c8ecdc"); c:fill(c:rect(0, 44, 110, 44), "#5a86b8")
c:fill(L.below(c, function(x) return 46 + 7 * math.sin(x / 31 + 1) + x * 0.03 end):clip(c:rect(0, 0, W - 1, 60)), "#c3b2ea")
c:fill(L.below(c, function(x) return 52 + 4 * math.sin(x / 17 + 3) - x * 0.05 end):clip(c:rect(0, 0, W - 1, 62)), "#a894dc")
L.cloud(c, 150, 18, 16, "#fdf2d8", "#f5cc92"); L.cloud(c, 40, 28, 12, "#fdf2d8", "#f5cc92"); L.cloud(c, 210, 34, 10, "#fdf2d8", "#f5cc92")
-- hill mass behind the top terrace, olive green
c:fill(L.below(c, function(x) return 50 - x * 0.03 + 3 * math.sin(x / 13) end), "#a4b86a")

local function vines(f, gd, x0, x1, step)
  for x = x0, x1, step do
    local y = math.floor(f(x) + gd - 6)
    c:part(c:ellipse(x, y - 1, 4.5, 3.5), R("#4a8a3e"), { flat = true, gloss = false, outline = false })
    c:fill(c:rect(x - 3, y - 3, x - 1, y - 3), "#7ab55c"); c:fill(c:rect(x + 1, y - 2, x + 2, y - 2), "#7ab55c")
    c:part(c:ellipse(x - 1, y + 2, 1.5, 2), R("#7a4a9a"), TINY); c:part(c:ellipse(x + 3, y + 1, 1.5, 2), R("#7a4a9a"), TINY)
    c:px(x - 2, y, "#a77ac4")
  end
end
local function tier(y0, slope, ph) return function(x) return y0 - x * slope + 1.5 * math.sin(x / 19 + ph) end end

-- T1 : farmhouse, cypress, olive, goats
local f1 = tier(60, 0.02, 0); K.terrace(c, f1, 14, "#7ab55c", "#c9c5bc", "#8b8f96")
vines(f1, 14, 100, 235, 11)
-- farmhouse
c:part(c:rect(26, 40, 54, 62), R("#f1ece0", { dot = "#fff3c8", rim = "#f5b860" }), { cres = 4, deep = 5, gloss = false })
c:part(c:poly({ { 22, 41 }, { 40, 29 }, { 58, 41 } }), R("#d9885a"), { cres = 4, deep = 6, gloss = false })
c:seam({ { 26, 45 }, { 54, 45 } }, { on = 2, off = 1 })
c:part(c:rrect(37, 51, 43, 62, 2), R("#7a4a1f"), { gloss = false, outline = false, contour = "#2a1a10" })
c:fill(c:rect(30, 48, 33, 52), "#3f8fb0"); c:fill(c:rect(48, 48, 51, 52), "#3f8fb0")
c:fill(c:rect(29, 53, 34, 53), "#d9885a"); c:fill(c:rect(47, 53, 52, 53), "#d9885a")
-- cypresses and olive
for _, t in ipairs({ { 66, 62, 5, 17 }, { 74, 63, 4, 13 } }) do
  c:part(c:ellipse(t[1], t[2] - t[4], t[3], t[4]), R("#2f5a2a"), { gloss = false, outline = false, cres = 3, deep = 5 })
end
c:part(c:rect(95, 54, 97, 62), R("#8a4f2a"), TINY)
c:part(c:ellipse(96, 48, 10, 7), R("#8a9a6a"), { gloss = false, outline = false, cres = 4, deep = 6 })
for _, p in ipairs({ { 90, 46 }, { 99, 50 }, { 95, 44 } }) do c:px(p[1], p[2], "#c8d77a") end
-- goats supervising
K.goat(c, 148, 68, { dir = -1, brow = true }); K.goat(c, 178, 68, { dir = -1, brow = true, coat = "#d8c496" }); K.goat(c, 210, 68, { dir = -1, brow = true })

-- T2 : pickers
local f2 = tier(79, 0.03, 1.5); K.terrace(c, f2, 14, "#6a9a3a", "#c9c5bc", "#8b8f96")
vines(f2, 14, 14, 230, 11)
K.gnome(c, 70, 88, { tunic = "#d9885a", hat = "#d6322b", look = -1 })
K.gnome(c, 128, 88, { tunic = "#3f8fb0", hat = "#e8a317", lean = -2, look = 1 })
c:part(c:ellipse(139, 84, 4.5, 3.5), R("#b07a45"), { gloss = false, outline = false, cres = 2, deep = 3 })
c:part(c:ellipse(60, 85, 4.5, 3.5), R("#b07a45"), { gloss = false, outline = false, cres = 2, deep = 3 })
for _, p in ipairs({ { 58, 83 }, { 62, 83 }, { 137, 82 }, { 141, 82 } }) do c:part(c:ellipse(p[1], p[2], 1.5, 1.5), R("#7a4a9a"), TINY) end

-- T3 : pickers, a nibbling goat, the barrel
local f3 = tier(98, 0.03, 3); K.terrace(c, f3, 14, "#7ab55c", "#c9c5bc", "#8b8f96")
vines(f3, 14, 90, 235, 11)
K.goat(c, 30, 108, { dir = 1 })
K.gnome(c, 150, 108, { tunic = "#7a4a9a", hat = "#f2e4c0", look = -1 })
K.gnome(c, 192, 108, { tunic = "#e8a317", hat = "#4e8a3e", lean = -3, look = 1 })
-- ladder against the vine
c:fill(c:rect(172, 92, 173, 108), "#b07a45"); c:fill(c:rect(177, 92, 178, 108), "#b07a45")
for y = 95, 107, 4 do c:fill(c:rect(172, y, 178, y), "#d9a660") end

-- T4 : foreground, cart of grapes, treading tub
local f4 = tier(118, 0.02, 4); K.terrace(c, f4, 12, "#a4b86a", "#c9a96e", "#9a6b3f")
-- cart
c:part(c:rrect(28, 116, 76, 128, 2), R("#b07a45"), { gloss = false, cres = 4, deep = 5 })
c:seam({ { 30, 122 }, { 74, 122 } }, { on = 2, off = 1 })
for _, p in ipairs({ { 33, 114 }, { 40, 112 }, { 48, 114 }, { 56, 112 }, { 63, 114 }, { 70, 113 }, { 37, 109 }, { 52, 109 }, { 66, 109 } }) do
  c:part(c:ellipse(p[1], p[2], 3, 3), R("#7a4a9a"), { flat = true, gloss = false, outline = false })
  c:px(p[1] - 1, p[2] - 1, "#a77ac4")
end
c:part(c:ellipse(40, 129, 6, 6), R("#8a4f2a"), { gloss = false, cres = 3, deep = 5 }); c:fill(c:ellipse(40, 129, 2, 2), "#d9a660")
c:part(c:ellipse(66, 129, 6, 6), R("#8a4f2a"), { gloss = false, cres = 3, deep = 5 }); c:fill(c:ellipse(66, 129, 2, 2), "#d9a660")
-- treading tub
c:part(c:rrect(128, 116, 166, 130, 3), R("#b07a45"), { gloss = false, cres = 4, deep = 5 })
c:fill(c:rect(130, 116, 164, 119), "#7a4a9a"); c:fill(c:rect(130, 116, 164, 116), "#a77ac4")
c:seam({ { 130, 124 }, { 164, 124 } }, { on = 2, off = 1 })
K.gnome(c, 147, 118, { tunic = "#d6322b", hat = "#4e8a3e", lean = 3 })
c:fill(c:rect(144, 116, 150, 117), "#7a4a9a")
for _, p in ipairs({ { 136, 114 }, { 160, 113 }, { 156, 109 } }) do c:px(p[1], p[2], "#a77ac4"); c:px(p[1] + 1, p[2] + 1, "#7a4a9a") end
-- baskets of grapes on the right
for _, bx in ipairs({ 190, 206, 222 }) do
  c:part(c:ellipse(bx, 123, 7, 5), R("#d9a660"), { gloss = false, cres = 3, deep = 4 })
  c:part(c:ellipse(bx, 119, 6, 3.5), R("#7a4a9a"), { flat = true, gloss = false, outline = false })
  c:px(bx - 2, 118, "#a77ac4")
end
-- bees/butterflies
for _, p in ipairs({ { 108, 70 }, { 126, 100 }, { 100, 118 } }) do c:px(p[1], p[2], "#fff1c8"); c:px(p[1] + 1, p[2] - 1, "#f6b8cf") end
L.finish(c, "wonder-goat-path-vineyards")
