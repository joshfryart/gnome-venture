-- banner-CA 240x60 (x2). Central Asia steppe sunrise, yurt, goat on roof (quirk).
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local P = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/palette.lua")
local out = app.params.out or "./"
local c = HP.canvas{ w = 240, h = 60, scale = 2, name = "banner-CA" }
local function rim(m, hex) c:fillMask(m:grow(1):cut(m), hex) end

-- sky: 4 bands + sunrise glow row, sun disc, puffs
c:bands(0, 37, "sky", 4)
c:fillMask(c:rect(0, 33, 239, 37), P.gold.hi)
c:fillMask(c:ellipse(150, 38, 11, 11):clip(c:rect(0, 0, 239, 38)), P.gold.base)
c:fillMask(c:ellipse(150, 38, 7, 7):clip(c:rect(0, 0, 239, 38)), P.gold.hi)
local function cloud(x, y)
  c:fillMask(c:ellipse(x, y, 4, 3), P.cream) c:fillMask(c:ellipse(x + 6, y - 1, 5, 4), P.cream)
  c:fillMask(c:ellipse(x + 13, y, 4, 3), P.cream)
  c:fillMask(c:rect(x - 4, y + 1, x + 17, y + 3), P.cream)
end
cloud(20, 10) cloud(95, 17) cloud(200, 8)

-- FAR plane: snow peaks (2 low-contrast colours, no ink)
local function peak(x0, x1, top, cx)
  local m = c:poly{ {x0, 40}, {cx, top}, {x1, 40} }
  c:fillMask(m, P.sky.deep)
  c:fillMask(c:poly{ {cx, top}, {cx + 1, top}, {x1, 40}, {cx + 4, 40} }, P.dusk.shade)
  c:fillMask(c:poly{ {cx, top}, {cx - 7, top + 8}, {cx - 3, top + 6}, {cx, top + 9}, {cx + 4, top + 6}, {cx + 7, top + 8} }:clip(m), P.stone.hi)
end
peak(-10, 60, 20, 24) peak(40, 120, 14, 82) peak(100, 175, 24, 140) peak(165, 250, 17, 208)
c:fillMask(c:rect(0, 39, 239, 41), P.moss.deep)
-- far hills + tiny horses
c:fillMask(c:ellipse(40, 44, 60, 5), P.moss.shade) c:fillMask(c:ellipse(190, 45, 70, 5), P.moss.shade)
local function horse(x, y, hex)
  c:fillMask(c:rect(x, y, x + 3, y + 1), hex) c:fillMask(c:rect(x + 3, y - 1, x + 4, y), hex)
  c:px(x, y + 2, hex) c:px(x + 3, y + 2, hex)
end
horse(30, 42, P.wood.deep) horse(36, 43, P.wood.shade) horse(205, 43, P.wood.deep) horse(212, 42, P.ink)

-- ground (steppe) in bands
c:fillMask(c:rect(0, 44, 239, 59), P.moss.base)
c:fillMask(c:rect(0, 51, 239, 55), P.moss.hi)
c:fillMask(c:rect(0, 56, 239, 59), P.moss.base)
c:fillMask(c:ellipse(120, 46, 200, 4):clip(c:rect(0, 44, 239, 47)), P.moss.base)
-- winding dirt path
c:fillMask(c:line({ {70, 59}, {90, 55}, {110, 52}, {128, 49} }, 3), P.gold.shade)

-- MID plane: yurt (hero)
local felt = { hi = P.cream, base = P.stone.hi, shade = P.stone.base, deep = P.stone.shade }
local wall = c:rrect(130, 33, 176, 52, 2)
local roof = c:poly{ {128, 33}, {153, 19}, {178, 33} }
local door = c:rrect(148, 41, 158, 52, 3)
rim(wall:copy():add(roof), P.wood.deep)
c:groundShadow(153, 53, 26, 2)
c:part(wall, felt)
c:part(roof, "ember")
c:fillMask(c:rect(130, 34, 176, 35), P.wood.base) -- belt band
c:fillMask(c:rect(130, 34, 176, 34), P.gold.base)
c:part(door, "wood", { band = 1 })
c:px(156, 47, P.gold.base)
c:fillMask(c:rect(152, 17, 154, 19), P.wood.deep) -- roof crown
-- chimney smoke
c:fillMask(c:ellipse(158, 13, 3, 2), P.stone.hi) c:fillMask(c:ellipse(162, 9, 3, 2), P.stone.hi)
-- quirk: goat on the roof
local gx, gy = 160, 25
c:fillMask(c:rect(gx, gy, gx + 6, gy + 3), P.cream)
c:fillMask(c:rect(gx + 6, gy - 3, gx + 8, gy), P.cream)           -- neck
c:fillMask(c:rect(gx + 8, gy - 3, gx + 10, gy - 2), P.cream)      -- head
c:px(gx + 7, gy - 4, P.wood.deep) c:px(gx + 9, gy - 4, P.wood.deep) -- horns
c:px(gx + 9, gy - 1, P.stone.base)                                 -- beard
c:px(gx + 1, gy + 4, P.stone.shade) c:px(gx + 5, gy + 4, P.stone.shade)
c:px(gx + 9, gy - 3, P.ink)
-- second yurt, small, to the right (mid)
local w2 = c:rrect(196, 40, 214, 52, 1)
local r2 = c:poly{ {194, 40}, {205, 33}, {216, 40} }
rim(w2:copy():add(r2), P.wood.deep)
c:part(w2, felt) c:part(r2, "ember")
c:fillMask(c:rect(203, 45, 207, 52), P.wood.base)

-- NEAR plane: grass tufts + flowers framing corners, full contrast
local function tuft(x, y, h, hex)
  c:fillMask(c:poly{ {x, y}, {x + 1, y - h}, {x + 2, y} }, hex)
  c:fillMask(c:poly{ {x + 3, y}, {x + 5, y - h - 2}, {x + 6, y} }, hex)
  c:fillMask(c:poly{ {x + 7, y}, {x + 8, y - h}, {x + 9, y} }, hex)
end
tuft(4, 57, 6, P.moss.deep) tuft(14, 56, 4, P.moss.shade) tuft(222, 57, 7, P.moss.deep) tuft(230, 56, 4, P.moss.shade)
tuft(58, 57, 3, P.moss.shade) tuft(184, 57, 3, P.moss.shade)
for _, f in ipairs{ {10, 50, P.petal.base}, {20, 54, P.gold.hi}, {226, 51, P.petal.base}, {235, 54, P.ember.base}, {44, 56, P.gold.hi}, {104, 57, P.petal.base} } do
  c:px(f[1], f[2], f[3]) c:px(f[1] - 1, f[2], f[3]) c:px(f[1] + 1, f[2], f[3]) c:px(f[1], f[2] - 1, f[3]) c:px(f[1], f[2] + 1, P.moss.deep)
  c:px(f[1], f[2], P.cream)
end
c:fillMask(c:ellipse(6, 59, 9, 4), P.moss.deep) c:fillMask(c:ellipse(234, 59, 11, 4), P.moss.deep)
c:hem(59)

c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "banner-CA.aseprite", png = out .. "banner-CA.png", scale = 2 }
