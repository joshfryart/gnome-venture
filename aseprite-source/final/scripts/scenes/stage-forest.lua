-- scenes/stage-forest : 480x270, drawn 240x135 written 2x. Family: moss deeper + wood + dusk haze, day light. Same ground band as grassland.
local H = dofile(os.getenv("GV_ROOT") .. "aseprite-source/final/scripts/scenes/head.lua")
local GV = H.GV
local c = GV.canvas{ w = 240, h = 135, mode = "scene", out = 2, ol = 1, olx = 1 }
local W = 240
-- sky through canopy gaps: 5 bands, greener than grassland
c:bands(c:rect(0, 0, W - 1, 79), { "#a9d6ea", "#bfe0e4", "#cfe6d8", "#dfeccb", "#eaf0bf" })
c:fill(c:rect(0, 80, W - 1, 99), "#eaf0bf")
-- far tree line (pale blue-green) : trunks and round crowns, no outline, light haze
local function farTree(x, top, col)
  c:fill(c:rect(x - 1, top + 10, x, 96), col); c:fill(c:ellipse(x, top + 6, 8, 8), col)
end
for i = 0, 12 do farTree(8 + i * 19, 44 + (i * 7) % 9, "#9cc4a8") end
for i = 0, 10 do farTree(16 + i * 23, 56 + (i * 5) % 8, "#80b08f") end
-- sunbeams: two soft stepped slants, flat colour
for _, b in ipairs({ 78, 150 }) do
  for y = 0, 90 do c:fill(c:rect(b + math.floor(y / 4), y, b + math.floor(y / 4) + 7, y), (y % 2 == 0) and "#e6efc0" or "#dfeccb") end
end
-- ground: same bands as grassland so lands read as one world, darker moss
c:fill(c:rect(0, 90, W - 1, 108), "#6a9a3a")
c:fill(c:rect(0, 90, W - 1, 91), "#86b04c")
c:fill(c:rect(0, 109, W - 1, 118), "#4a8a3e")
c:fill(c:rect(0, 119, W - 1, 127), "#3f7a38")
c:fill(c:rect(0, 128, W - 1, 134), "#2f5a2a")
for x = 70, 170 do c:fill(c:rect(x, 100 + math.floor(2 * math.sin(x / 9) + 0.5), x, 101 + math.floor(2 * math.sin(x / 9) + 0.5)), "#9a6b3f") end
-- raised trees at the very edges would clutter the party slots, so: two big trunks just outside the thirds, one mid stump and mushrooms
local function tree(x, y0, w, ch, rx)
  c:part(c:rect(x, y0, x + w, 93), "wood", { gloss = false, cres = 2 })
  c:part(c:ellipse(x + w / 2, y0 - ch, rx, ch + 4), "moss", { cres = 5, deep = 2 })
end
tree(74, 52, 5, 18, 17)
tree(160, 48, 5, 20, 19)
c:part(c:rect(116, 82, 124, 92), "wood", { gloss = false, cres = 3 })                  -- stump
c:part(c:ellipse(120, 82, 5, 2), GV.ramp("#d9a660"), { gloss = false, flat = true })
c:part(c:ellipse(134, 90, 4, 3), "red", { gloss = false, cres = 2 })                   -- toadstool cap
c:fill(c:rect(133, 91, 134, 93), "#f2e4c0")
-- ferns and fallen leaves, sparse
for _, f in ipairs({ { 14, 112 }, { 40, 122 }, { 204, 116 }, { 226, 124 }, { 100, 120 }, { 150, 124 } }) do
  c:fill(c:rect(f[1], f[2], f[1] + 3, f[2]), "#7ab55c"); c:fill(c:rect(f[1] + 1, f[2] - 1, f[1] + 2, f[2] - 1), "#7ab55c")
end
c:paint({ "u.u", ".u." }, 190, 24, { u = "#4a2c1a" })
H.done(c, "stage-forest", "scenes/stage-forest.png", 32, true)
