-- banner-CA PASS 1 (form). 240x60 grid, x2. Central Asia steppe at sunrise.
-- Planes: far = Tian Shan peaks (dusk.hi + cream snow, no ink); mid = felt yurt (hero, wood.deep edge),
-- horses on the foothills; near = ink-edged feather grass + wild tulips framing both corners.
-- quirk: a goat standing on the yurt roof.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local c = HP.canvas{ w = 240, h = 60, scale = 2, name = "banner-CA" }
local floor, sin = math.floor, math.sin
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end

-- SKY: 4 flat bands, sunrise warms toward the horizon
c:stripes(0, 41, { P.sky.shade, P.sky.base, P.petal.hi, P.gold.hi }, { 2, 3, 3, 3 })
c:fillMask(c:ellipse(78, 33, 8, 8), P.gold.base)             -- sun disc, half behind the peaks
c:fillMask(c:ellipse(77, 32, 5, 5), P.gold.hi)
c:cloud(10, 13, 24, P.cream, P.sky.hi)
c:cloud(104, 19, 16, P.cream, P.petal.hi)
c:cloud(196, 11, 28, P.cream, P.sky.hi)

-- FAR: snow peaks (2 colours)
local peaks = { {-6, 22, 1.0}, {22, 14, 1.1}, {50, 24, 0.9}, {118, 9, 1.0}, {146, 19, 1.2}, {180, 25, 0.8}, {212, 12, 1.05}, {246, 20, 1.0} }
local function ridge(x)
  local y = 40
  for _, p in ipairs(peaks) do
    local v = p[2] + math.abs(x - p[1]) * p[3]
    if v < y then y = v end
  end
  return y
end
local mtn = c:terrain(ridge, P.dusk.hi, 44)
-- snow caps: triangle under each summit with a zigzag lower edge, clipped to the range
for i, p in ipairs(peaks) do
  local w = floor(9 / p[3])
  local pts = { {p[1] + .5, p[2] - 1} , {p[1] + w + 1, p[2] + w * p[3] + 1} }
  local n = 4
  for k = 1, n - 1 do
    local x = p[1] + w - k * 2 * w / n
    pts[#pts + 1] = { x, p[2] + w * p[3] * ((k % 2 == 1) and 0.55 or 1.0) + (i % 2) }
  end
  pts[#pts + 1] = { p[1] - w, p[2] + w * p[3] + 1 }
  c:fillMask(c:poly(pts):clip(mtn), P.cream)
end

-- MID-FAR: foothills (moss.hi), rolling, with grazing horses
c:terrain(function(x) return 39 + 2.5 * sin(x / 17) + 1.5 * sin(x / 7 + 1) end, P.moss.hi, 59)
c:terrain(function(x) return 45 + 1.5 * sin(x / 23 + 2) end, P.moss.base, 59)
local HORSE = {
  "......#.",
  ".....###",
  "#######.",
  ".#####..",
  ".#.#..#.",
  ".#.#..#.",
}
local function horse(x, y, hex, flip)
  for j, row in ipairs(HORSE) do for i = 1, #row do
    if row:sub(i, i) == "#" then c:px(flip and (x + 8 - i) or (x + i - 1), y + j - 1, hex) end
  end end
end
horse(26, 37, P.wood.shade) horse(37, 38, P.wood.deep, true) horse(48, 39, P.cream)
horse(214, 40, P.wood.base, true)

-- MID: winding dirt path from the yurt door down to the viewer
local path = c:line({ {172, 52}, {160, 54}, {140, 56}, {118, 58}, {104, 59} }, 3)
path:add(c:line({ {150, 56}, {128, 59} }, 3))
c:fillMask(path, P.gold.base)

-- HERO: yurt
local wall = c:rrect(150, 38, 194, 52, 2)
local roof = c:ellipse(172, 39, 25, 12):clip(c:rect(0, 0, 239, 38))
local crown = c:rect(168, 25, 176, 27)
local yurt = wall:copy():add(roof):add(crown)
c:fillMask(c:ellipse(172, 53, 26, 2), P.moss.shade)          -- ground shade
c:rim(yurt, P.wood.deep)
c:part(wall, { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }, { band = 3, nopop = true })
c:part(roof, "ember", { band = 2 })
for _, a in ipairs{ -20, -10, 0, 10, 20 } do                  -- felt ropes on the roof
  c:fillMask(c:line({ {172 + a * .25, 28}, {172 + a, 37} }, 1):clip(roof), P.ember.shade)
end
c:part(crown, "wood", { band = 1, nopop = true })
R(150, 40, 194, 42, P.ember.base)                              -- ornament band
for x = 150, 194 do if (x % 4 == 0) then c:px(x, 41, P.gold.base) elseif x % 4 ~= 2 then c:px(x, (x % 4 == 1) and 40 or 42, P.gold.base) end end
c:part(c:rrect(167, 44, 177, 52, 1), "gold", { band = 1 })   -- painted door
R(172, 44, 172, 52, P.gold.deep) c:px(170, 48, P.ember.base) c:px(174, 48, P.ember.base)
-- stove pipe + smoke
R(180, 26, 181, 31, P.stone.shade)
c:fillMask(c:ellipse(183, 22, 2, 1), P.stone.hi) c:fillMask(c:ellipse(186, 18, 3, 2), P.stone.hi) c:fillMask(c:ellipse(191, 14, 2, 1), P.stone.hi)

-- QUIRK: goat on the roof, near the crown, looking at the sunrise
c:paint({
  "....hh......",
  "...h..h.....",
  "..wwh.......",
  ".wewww......",
  "wwwwwwwwwww.",
  ".bwwwwwwwwwt",
  "..sssssssss.",
  "..l.l...l.l.",
  "..l.l...l.l.",
}, 156, 19, { h = "wood.deep", w = "#fff4d6", e = "#2b1c26", b = "stone.base", s = "stone.hi", t = "stone.hi", l = "wood.deep" })

-- NEAR: ink-edged feather grass + wild tulips framing both corners
local function tuft(x, y, blades)
  local m = HP.mask()
  for _, b in ipairs(blades) do
    m:add(c:poly{ {x + b[1], y + 1}, {x + b[1] + b[3], y - b[2]}, {x + b[1] + 3, y + 1} })
  end
  return m
end
local function tulip(x, y, ramp)
  local st = c:rect(x, y, x, y + 6)
  local hd = c:rect(x - 1, y - 3, x + 1, y):add(c:rect(x - 2, y - 2, x + 2, y))
  hd:cut(c:rect(x, y - 3, x, y - 3))
  c:rim(st:copy():add(hd), P.ink)
  c:fillMask(st, P.moss.shade) c:fillMask(hd, P[ramp].base)
  c:px(x - 2, y - 2, P[ramp].hi) c:fillMask(c:rect(x + 1, y - 1, x + 2, y), P[ramp].shade)
end
R(0, 54, 239, 59, P.moss.shade)
c:fillMask(path:clip(c:rect(0, 54, 239, 59)), P.gold.base)
local L = tuft(0, 58, { {-2, 12, 1}, {2, 8, 3}, {5, 14, 2}, {9, 9, 4}, {13, 6, 3}, {17, 4, 2} })
c:rim(L, P.ink) c:fillMask(L, P.moss.base)
local L2 = tuft(6, 58, { {0, 6, 2}, {6, 5, -1} })
c:rim(L2, P.ink) c:fillMask(L2, P.gold.base)
tulip(24, 49, "ember") tulip(30, 52, "petal")
local Rm = tuft(214, 58, { {0, 5, -2}, {4, 9, -1}, {8, 13, -2}, {12, 10, -3}, {16, 15, -1}, {20, 9, 0}, {24, 12, 1} })
c:rim(Rm, P.ink) c:fillMask(Rm, P.moss.base)
tulip(210, 50, "ember")
local st = c:ellipse(232, 56, 5, 2) c:rim(st, P.ink) c:part(st, "stone", { band = 1 })
R(0, 59, 239, 59, P.moss.deep)
c:hem(59)

c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "banner-CA.p1.aseprite", png = out .. "banner-CA.p1.png", scale = 2 }
