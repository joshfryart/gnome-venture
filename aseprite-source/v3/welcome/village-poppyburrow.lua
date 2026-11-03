-- village-poppyburrow FIRST DRAFT. 160x100 scene, full canvas, no outline.
-- Planes: sky + far hills (low contrast), mid grassy mounds with round-doored burrows and a windsock,
-- near plane of red poppies and ink-edged grass tufts.
-- quirk: a snail-shell doorbell? no: a mouse's laundry line of tiny socks between two burrows.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (d .. "/")
local NAME = "village-poppyburrow"
local c = HP.canvas{ w = 160, h = 100, scale = 1, name = NAME }
local sin, floor, abs = math.sin, math.floor, math.abs
local seed = 11
local function rnd() seed = (seed * 1103515245 + 12345) % 2147483648 return seed / 2147483648 end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end

c:stripes(0, 44, { P.sky.shade, P.sky.base, P.sky.hi }, { 3, 4, 4 })
c:cloud(14, 20, 26, P.cream, P.sky.hi) c:cloud(112, 14, 22, P.cream, P.sky.hi)
c:fillMask(E(140, 30, 5, 5), P.gold.hi)
-- far hills
c:terrain(function(x) return 38 + 6 * sin(x / 25 + 1) + 2 * sin(x / 8) end, "#a9dccb")
c:terrain(function(x) return 46 + 4 * sin(x / 19 + 3) end, P.moss.hi)
-- meadow
c:terrain(function(x) return 52 + 2 * sin(x / 17) end, P.moss.base)
for i = 1, 70 do local x, y = floor(rnd() * 160), 54 + floor(rnd() * 20) c:px(x, y, P.moss.shade) c:px(x + 1, y - 1, P.moss.shade) end
-- little far poppy specks (depth plane 1)
for i = 1, 40 do local x, y = floor(rnd() * 160), 50 + floor(rnd() * 8) c:px(x, y, P.ember.base) end
-- winding path
local path = HP.mask()
for y = 56, 99 do
  local cx = 80 + 14 * sin(y / 11) - (y - 56) * .1
  local hw = 3 + (y - 56) * .22
  for x = floor(cx - hw), floor(cx + hw) do path:set(x, y) end
end
c:fillMask(path, P.gold.hi)
path:each(function(x, y) if (x * 7 + y * 13) % 9 == 0 then c:px(x, y, "#e7b873") end end)

-- mounds with burrow doors
local function mound(cx, base, rx, ry, door, sock)
  local m = E(cx, base, rx, ry):clip(c:rect(0, 0, 159, base))
  c:rim(m, P.moss.deep)
  c:part(m, "moss", { band = 3, pop = { x = cx - rx + 6, y = base - ry + 4 } })
  for i = 1, 8 do local x, y = cx - rx + 4 + floor(rnd() * (rx * 2 - 8)), base - 2 - floor(rnd() * (ry - 4)) c:px(x, y, P.moss.hi) c:px(x + 1, y, P.moss.hi) end
  -- door
  local dr = door * 1.0
  local frame = E(cx, base - dr + 1, dr + 1, dr + 1):clip(c:rect(0, 0, 159, base))
  c:rim(frame, P.wood.deep)
  c:part(frame, "wood", { band = 1, nopop = true, inner = false })
  local dd = E(cx, base - dr + 1, dr - 1, dr - 1):clip(c:rect(0, 0, 159, base))
  c:part(dd, "ember", { band = 1, nopop = true, inner = false })
  R(cx, base - 2 * dr + 2, cx, base, P.ember.shade)
  c:px(cx + dr - 3, base - dr + 1, P.gold.hi) c:px(cx + dr - 3, base - dr + 2, P.gold.base)
  R(cx - dr - 1, base, cx + dr + 1, base, P.wood.deep)
  -- step stone
  c:fillMask(E(cx, base + 2, dr + 2, 1), P.stone.base)
  c:px(cx - 1, base + 2, P.stone.hi)
  -- round window beside the door
  local wx = cx - rx + floor(rx * .5)
  c:rim(E(wx, base - 7, 2, 2), P.wood.deep) c:fillMask(E(wx, base - 7, 2, 2), P.gold.hi) c:px(wx, base - 8, P.cream)
  -- chimney pipe
  if sock then
    R(cx + 12, base - ry - 3, cx + 15, base - ry + 3, P.stone.base) R(cx + 12, base - ry - 3, cx + 15, base - ry - 3, P.stone.deep)
    c:fillMask(E(cx + 14, base - ry - 6, 2, 2), P.stone.hi)
  end
end
mound(28, 70, 26, 18, 6, false)
mound(125, 66, 28, 18, 6, true)
-- big central mound (hero) with windsock
mound(80, 62, 22, 12, 4, false)
-- windsock on a pole at the hero mound
R(79, 36, 80, 52, P.wood.deep) c:px(79, 36, P.wood.base)
local sx, sy = 81, 36
for i = 0, 11 do
  local w = 5 - floor(i / 3)
  for j = 0, w do c:px(sx + i, sy + j, ((i // 3) % 2 == 0) and P.ember.base or P.cream) end
  c:px(sx + i, sy + w + 1, P.ember.shade)
end
c:px(sx, sy - 1, P.ink)
-- washing line with socks between the side mounds (quirk)
for _, p in ipairs{ {52, 54}, {56, 55}, {60, 56}, {64, 56}, {96, 56}, {100, 56}, {104, 55}, {108, 54} } do c:px(p[1], p[2], P.stone.deep) end
for _, s in ipairs{ {{58,57},"petal"}, {{102,57},"sea"} } do R(s[1][1], s[1][2], s[1][1] + 1, s[1][2] + 3, P[s[2]].base) c:px(s[1][1], s[1][2] + 3, P[s[2]].hi) end

-- near plane: poppies everywhere
local function poppy(x, y, s)
  local h = 5 + s * 3
  R(x, y + 1, x, y + h, P.moss.shade)
  if s >= 1 then c:px(x - 1, y + h - 2, P.moss.base) c:px(x - 2, y + h - 3, P.moss.base) end
  local pet = E(x, y, 2 + s, 1 + s)
  c:rim(pet, P.ember.deep)
  c:fillMask(pet, P.ember.base)
  c:fillMask(E(x, y + 1, 1 + s, s):clip(c:rect(x - 5, y + 1, x + 5, y + 4)), P.ember.shade)
  c:px(x - 1, y - s, P.ember.hi) c:px(x - 2 - s + 1, y - s + 1, P.ember.hi)
  c:px(x, y, P.ink) if s >= 2 then c:px(x + 1, y, P.ink) c:px(x - 1, y, P.ink) end
end
for i = 1, 22 do
  local x = floor(rnd() * 160)
  local y = 70 + floor(rnd() * 14)
  if not path:has(x, y + 5) then poppy(x, y, 1) end
end
for _, p in ipairs{ {8, 82, 2}, {20, 90, 2}, {40, 86, 2}, {60, 92, 1}, {110, 90, 2}, {128, 84, 2}, {146, 90, 2}, {154, 80, 2}, {96, 80, 1}, {3, 94, 1}, {34, 78, 1}, {138, 76, 1} } do poppy(p[1], p[2], p[3]) end
-- foreground grass blades along the bottom
for x = 0, 159, 3 do
  local h = 3 + floor(rnd() * 4)
  for k = 0, h do c:px(x, 99 - k, k < 2 and P.moss.deep or P.moss.shade) end
  c:px(x + 1, 99 - h + 1, P.moss.base)
end
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
