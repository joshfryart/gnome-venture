-- home-cottage PASS 1 (form). 240x135 grid, x2.
-- Gnome cottage with a toadstool roof, round green door, porthole windows with flower boxes, crooked
-- stone chimney + smoke, vegetable patch, picket fence. Planes: far = 2-tone hills (no ink);
-- mid = cottage (object: ink outline) + tree + veg patch; near = ink-edged fence, bushes, flowers.
-- quirk: a snail travelling up the chimney (with a shiny trail).
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local c = HP.canvas{ w = 240, h = 135, scale = 2, name = "home-cottage" }
local floor, sin = math.floor, math.sin
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end

-- SKY
c:stripes(0, 80, { P.sky.shade, P.sky.base, P.sky.hi }, { 3, 4, 3 })
c:fillMask(E(26, 20, 9, 9), P.gold.base) c:fillMask(E(25, 19, 6, 6), P.gold.hi)
c:cloud(52, 28, 26, P.cream, P.sky.hi)
c:cloud(176, 18, 32, P.cream, P.sky.hi)
c:cloud(212, 40, 18, P.cream, P.sky.hi)

-- FAR: two hill layers, 2 colours, no ink
c:terrain(function(x) return 66 + 6 * sin(x / 31 + .4) + 3 * sin(x / 13) end, P.sea.hi)
c:terrain(function(x) return 76 + 5 * sin(x / 23 + 2) + 2 * sin(x / 9) end, P.moss.hi)

-- MID ground
c:terrain(function(x) return 90 + 2 * sin(x / 40) end, P.moss.base)
-- round tree behind, left
c:part(c:rect(30, 74, 34, 100), "wood", { band = 1, nopop = true })
local crown = E(32, 62, 20, 17):add(E(18, 72, 11, 9)):add(E(47, 71, 11, 9))
c:part(crown, "moss", { band = 3 })
for _, a in ipairs{ {22, 58}, {38, 54}, {30, 70}, {44, 64}, {16, 70} } do R(a[1], a[2], a[1] + 1, a[2] + 1, P.ember.base) end

-- stepping-stone path
for i, s in ipairs{ {116, 116, 5, 2}, {111, 121, 6, 2}, {118, 126, 7, 3}, {110, 132, 8, 3} } do
  local m = E(s[1], s[2], s[3], s[4]) c:part(m, "stone", { band = 1, nopop = i % 2 == 0 })
end

-- HERO: cottage (ink outline)
local wall = c:rrect(72, 70, 158, 112, 2)
local cap = E(115, 74, 60, 36):clip(c:rect(0, 0, 239, 76)):add(E(115, 75, 60, 4))
local chim = c:poly{ {139, 24}, {150, 22}, {152, 56}, {141, 58} }
local chimTop = c:poly{ {137, 19}, {152, 17}, {153, 23}, {138, 25} }
local base = c:rect(70, 106, 160, 112)
local home = wall:copy():add(cap):add(chim):add(chimTop):add(base)
c:fillMask(E(115, 113, 50, 3), P.moss.shade)
c:rim(home, P.ink)
c:part(wall, { hi = P.cream, base = P.cream, shade = P.gold.hi, deep = P.gold.base }, { band = 3, nopop = true })
-- half-timber beams
for _, x in ipairs{ 76, 100, 130, 154 } do R(x, 80, x + 1, 106, P.wood.base) end
R(72, 80, 158, 81, P.wood.shade)
c:part(base, "stone", { band = 2, nopop = true })
for x = 72, 158, 6 do R(x, 106 + (x // 6) % 2 * 3, x, 108 + (x // 6) % 2 * 3, P.stone.shade) end
c:part(cap, "ember", { band = 4 })
c:part(chim:copy():cut(cap), "stone", { band = 2 })
c:part(chimTop, "stone", { band = 1, nopop = true })
for _, s in ipairs{ {84, 58, 5, 3}, {102, 46, 6, 4}, {126, 50, 4, 3}, {158, 64, 4, 2}, {72, 70, 3, 2}, {118, 64, 3, 2}, {96, 66, 2, 1} } do
  c:fillMask(E(s[1], s[2], s[3], s[4]):clip(cap), P.cream)
end
-- round door
local door = E(115, 100, 10, 12):clip(c:rect(0, 0, 239, 111))
c:rim(door, P.wood.deep)
c:part(door, "moss", { band = 2 })
R(115, 89, 115, 110, P.moss.deep)
c:px(120, 100, P.gold.base) c:px(121, 100, P.gold.base)
-- porthole windows + flower boxes
local function window(cx, cy)
  local f = E(cx, cy, 8, 8) c:fillMask(f, P.wood.base)
  local g = E(cx, cy, 6, 6) c:fillMask(g, P.sea.base)
  c:fillMask(E(cx, cy, 6, 6):clip(c:rect(cx - 7, cy - 7, cx + 7, cy - 2)), P.sea.hi)
  R(cx, cy - 6, cx, cy + 6, P.wood.base) R(cx - 6, cy, cx + 6, cy, P.wood.base)
  c:fillMask(E(cx, cy, 8, 8):edge(), P.wood.shade)
  local box = c:rect(cx - 10, cy + 8, cx + 10, cy + 11)
  c:part(box, "wood", { band = 1, nopop = true })
  for i = 0, 6 do
    local fx = cx - 9 + i * 3
    c:px(fx, cy + 7, P.moss.base) c:px(fx + 1, cy + 7, P.moss.shade)
    c:px(fx, cy + 6, ({ P.petal.base, P.gold.base, P.dusk.hi, P.ember.hi })[i % 4 + 1])
  end
end
window(88, 92) window(142, 92)
-- attic round window in the cap
c:fillMask(E(115, 56, 4, 4), P.wood.deep) c:fillMask(E(115, 56, 3, 3), P.gold.hi) R(115, 53, 115, 59, P.wood.deep)

-- smoke
c:fillMask(E(150, 12, 3, 2), P.stone.hi) c:fillMask(E(156, 7, 4, 3), P.stone.hi) c:fillMask(E(165, 3, 5, 3), P.cream)

-- QUIRK: snail up the chimney + trail
for y = 36, 42 do c:px(146, y, P.sky.hi) end
c:paint({
  ".e.e..",
  ".k.k..",
  "..ppp.",
  ".pPPpp",
  ".pPhPp",
  ".pPPpp",
  "cccccc",
}, 142, 28, { e = "#2b1c26", k = "#fff4d6", p = "petal.shade", P = "petal.base", h = "petal.hi", c = "#fff4d6" })

-- vegetable patch (mid, right)
local soil = c:rrect(172, 98, 232, 116, 3)
c:part(soil, "wood", { band = 2, nopop = true })
for row = 0, 2 do
  for i = 0, 5 do
    local x, y = 177 + i * 10 + (row % 2) * 4, 102 + row * 6
    if row == 0 then c:fillMask(E(x, y, 3, 2), P.moss.base) c:px(x, y - 2, P.moss.hi)
    elseif row == 1 then R(x, y - 3, x, y, P.moss.shade) R(x - 1, y - 2, x + 1, y - 2, P.moss.base) c:px(x, y + 1, P.ember.hi)
    else c:fillMask(E(x, y, 3, 2), P.gold.base) c:px(x, y - 3, P.moss.shade) end
  end
end

-- NEAR: fence (ink-edged), bushes, flowers
local fence = HP.mask()
for x = -2, 238, 8 do
  if x < 100 or x > 128 then fence:add(c:poly{ {x, 116}, {x + 2.5, 114}, {x + 5, 116}, {x + 5, 128}, {x, 128} }) end
end
fence:add(c:rect(0, 119, 101, 120)):add(c:rect(0, 124, 101, 125)):add(c:rect(128, 119, 239, 120)):add(c:rect(128, 124, 239, 125))
c:rim(fence, P.ink)
c:part(fence, "wood", { band = 1, nopop = true })
R(0, 129, 239, 134, P.moss.shade)
local bushL = E(8, 124, 16, 12):add(E(26, 130, 12, 8))
c:rim(bushL, P.ink) c:part(bushL, "moss", { band = 3 })
local bushR = E(230, 122, 16, 14):add(E(210, 131, 12, 6))
c:rim(bushR, P.ink) c:part(bushR, "moss", { band = 3 })
for _, f in ipairs{ {6, 116, "petal"}, {16, 122, "gold"}, {24, 126, "petal"}, {222, 114, "ember"}, {232, 120, "gold"}, {212, 127, "ember"} } do
  local m = c:rect(f[1] - 1, f[2], f[1] + 1, f[2]):add(c:rect(f[1], f[2] - 1, f[1], f[2] + 1))
  c:fillMask(m, P[f[3]].base) c:px(f[1], f[2], P.cream)
end

c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "home-cottage.p1.aseprite", png = out .. "home-cottage.p1.png", scale = 2 }
