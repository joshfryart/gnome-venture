-- home-cottage 240x135 (x2). Round-door gnome cottage; quirk: snail climbing the chimney.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = dofile(d .. "/../lib/palette.lua")
local out = app.params.out or "./"
local c = HP.canvas{ w = 240, h = 135, scale = 2, name = "home-cottage" }
local function rim(m, hex) c:fillMask(m:grow(1):cut(m), hex) end
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end

-- sky
c:bands(0, 80, "sky", 4)
c:fillMask(c:ellipse(30, 22, 9, 9), P.gold.hi) c:fillMask(c:ellipse(30, 22, 6, 6), P.gold.base)
local function cloud(x, y)
  c:fillMask(c:ellipse(x, y, 5, 4), P.cream) c:fillMask(c:ellipse(x + 8, y - 2, 6, 5), P.cream)
  c:fillMask(c:ellipse(x + 17, y, 5, 4), P.cream) R(x - 5, y + 1, x + 22, y + 4, P.cream)
end
cloud(95, 18) cloud(190, 30) cloud(150, 10)

-- FAR: two low-contrast hill layers
c:fillMask(c:ellipse(40, 90, 70, 22), P.moss.shade)
c:fillMask(c:ellipse(200, 92, 80, 26), P.moss.shade)
c:fillMask(c:ellipse(120, 96, 90, 14), P.sea.shade)
c:fillMask(c:ellipse(70, 96, 60, 12), P.moss.deep) c:fillMask(c:ellipse(210, 98, 50, 12), P.moss.deep)

-- MID ground
R(0, 98, 239, 134, P.moss.base)
R(0, 114, 239, 124, P.moss.hi)
c:fillMask(c:poly{ {108, 134}, {112, 110}, {128, 110}, {138, 134} }, P.wood.hi) -- path
c:fillMask(c:poly{ {118, 134}, {120, 110}, {128, 110}, {132, 134} }, P.wood.hi)

-- cottage (hero, ink outline as an object)
local wall = c:rrect(66, 62, 168, 112, 3)
local roof = c:poly{ {58, 66}, {117, 28}, {176, 66} }
local chim = c:rect(140, 26, 150, 52)
local home = wall:copy():add(roof):add(chim):add(c:rect(139, 24, 151, 27))
rim(home, P.ink)
c:groundShadow(117, 113, 56, 2)
c:part(chim, "stone")
c:part(c:rect(139, 24, 151, 27), "stone", { band = 1 })
c:part(wall, { hi = P.cream, base = P.gold.hi, shade = P.gold.base, deep = P.gold.deep })
c:part(roof, "ember", { band = 3 })
-- roof tile rows
for y = 40, 64, 6 do
  for x = 70, 164 do if roof:has(x, y) and (x + y) % 4 ~= 0 then c:px(x, y, P.ember.shade) end end
end
c:fillMask(c:ellipse(117, 50, 5, 5), P.wood.deep) c:fillMask(c:ellipse(117, 50, 3, 3), P.sea.base) -- attic round window
c:px(116, 49, P.sea.hi) c:px(117, 49, P.sea.hi)
-- round door
local door = c:ellipse(117, 100, 11, 12):clip(c:rect(0, 0, 239, 112))
c:part(door, "wood", { band = 2 })
c:fillMask(c:ellipse(117, 100, 11, 12):clip(c:rect(0, 0, 239, 112)):grow(1):cut(c:ellipse(117, 100, 11, 12)), P.wood.deep)
c:button(124, 101)
for y = 92, 111, 5 do R(107, y, 127, y, P.wood.shade) end
R(116, 90, 118, 111, P.wood.deep)
c:fillMask(c:rect(105, 112, 129, 112), P.stone.base)
-- windows with flower boxes
local function window(x, y)
  local w = c:rect(x, y, x + 17, y + 14)
  rim(w, P.wood.deep)
  c:fillMask(w, P.sea.base) c:fillMask(c:rect(x, y, x + 17, y + 4), P.sea.hi)
  R(x + 8, y, x + 9, y + 14, P.wood.base) R(x, y + 7, x + 17, y + 8, P.wood.base)
  c:part(c:rect(x - 2, y + 15, x + 19, y + 19), "wood", { band = 1 })
  for i = 0, 6 do
    local fx = x + i * 3 - 1
    c:fillMask(c:ellipse(fx, y + 14, 1, 1), P.moss.base)
    c:px(fx, y + 12, ({ P.petal.base, P.ember.hi, P.gold.base, P.dusk.hi })[i % 4 + 1]) c:px(fx, y + 13, P.moss.shade)
  end
end
window(80, 82) window(140, 82)
-- vegetable patch (right)
c:fillMask(c:rect(180, 104, 226, 118), P.wood.shade)
for i = 0, 4 do
  local x = 184 + i * 9
  R(x, 106, x + 6, 106, P.wood.deep) R(x, 112, x + 6, 112, P.wood.deep)
  if i % 2 == 0 then c:fillMask(c:ellipse(x + 3, 108, 3, 2), P.moss.base) c:px(x + 3, 109, P.ember.base) c:px(x + 2, 109, P.ember.base) -- radish tops
  else c:fillMask(c:poly{ {x + 1, 110}, {x + 3, 105}, {x + 6, 110} }, P.moss.hi) c:px(x + 3, 111, P.gold.base) end
  c:fillMask(c:ellipse(x + 3, 115, 3, 2), P.moss.shade)
end
-- bush beside house + tree far
c:fillMask(c:ellipse(52, 100, 10, 12), P.moss.shade) c:fillMask(c:ellipse(50, 97, 7, 8), P.moss.base) c:px(48, 94, P.moss.hi) c:px(49, 94, P.moss.hi)

-- quirk: snail on the chimney
c:fillMask(c:ellipse(145.5, 38, 3, 3), P.petal.shade) c:fillMask(c:ellipse(145.5, 38, 1, 1), P.petal.hi)
c:fillMask(c:rect(142, 43, 148, 44), P.cream) c:px(142, 42, P.cream) c:px(142, 41, P.ink) c:px(144, 40, P.ink)
-- smoke
c:fillMask(c:ellipse(147, 18, 3, 2), P.stone.hi) c:fillMask(c:ellipse(151, 12, 4, 3), P.stone.hi) c:fillMask(c:ellipse(158, 7, 4, 3), P.stone.base)

-- NEAR: picket fence with ink edges, tufts, corner bushes
local function picket(x)
  local m = c:poly{ {x, 118}, {x + 2, 114}, {x + 4, 118}, {x + 4, 128}, {x, 128} }
  rim(m, P.ink) c:part(m, "cream" == nil and "wood" or { hi = P.cream, base = P.stone.hi, shade = P.stone.base, deep = P.stone.shade }, { band = 1, nopop = true })
end
for x = 0, 100, 7 do picket(x) end
for x = 140, 238, 7 do picket(x) end
R(0, 121, 100, 122, P.ink) R(140, 121, 239, 122, P.ink) R(0, 124, 100, 124, P.stone.shade) R(140, 124, 239, 124, P.stone.shade)
R(0, 129, 239, 134, P.moss.shade) R(0, 133, 239, 134, P.moss.deep)
c:fillMask(c:ellipse(10, 134, 18, 7), P.moss.deep) c:fillMask(c:ellipse(232, 134, 20, 7), P.moss.deep)
c:fillMask(c:ellipse(8, 129, 8, 6), P.moss.shade) c:fillMask(c:ellipse(234, 129, 8, 6), P.moss.shade)
c:px(5, 126, P.moss.base) c:px(6, 126, P.moss.base) c:px(231, 126, P.moss.base) c:px(232, 126, P.moss.base)
for _, f in ipairs{ {60, 131, P.petal.base}, {80, 132, P.gold.hi}, {160, 131, P.ember.hi}, {190, 132, P.petal.base}, {22, 125, P.gold.base}, {222, 126, P.petal.hi} } do
  c:px(f[1], f[2], f[3]) c:px(f[1] - 1, f[2], f[3]) c:px(f[1] + 1, f[2], f[3]) c:px(f[1], f[2] - 1, f[3]) c:px(f[1], f[2] + 1, P.moss.deep) c:px(f[1], f[2], P.cream)
end

c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "home-cottage.aseprite", png = out .. "home-cottage.png", scale = 2 }
