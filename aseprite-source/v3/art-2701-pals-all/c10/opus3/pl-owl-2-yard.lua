-- Nightglow Fleck (pl-owl-2), yard sprite 64x64. Opus richness pass (c10/opus3), built on c10/opus2.
-- Richness pass: rock strata lines and a lit top lip on the broken slab, an extra deep crater with a bright ray
-- splash (the moon's youngest crater), glinting moondust flecks on the lit side, a second softer maria field,
-- a pale glow line along the snapped edge where the light catches it.
-- Wayfinder, common. "A fleck of moon the owl dropped on the way home."
-- A broken chip of moon: one smooth curved edge (a piece of the moon's rim, top-left) and jagged snapped edges on
-- the other sides, with pale broken faces catching the light. Cool moonlight ramp (lavender shade up to lemon
-- cream light, so it glows instead of reading as butter or stone), soft maria patches, rimmed craters.
-- Haiku pass fixed: it was a plain round grey-blue ball (read as a planet or a blueberry) with no break.
-- quirk: it is still falling home. A dotted trail of tiny moon crumbs arcs down behind it from the upper right.
-- closer look: three talon scratches by the snapped edge, where the owl's grip slipped.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-owl-2-yard", 64)

local MOON = { "#565084", "#8a86b6", "#bcbcd6", "#e6e4c6", "#f8f0b4", "#fffae0" }
local SLAB = { "#3e3a66", "#5e5a88", "#8682a8", "#aeaac4" }
local GLOW = "#fff0a0"

-- a round moon chip with a zigzag snap across its lower right
local zig = { { 36, 4 }, { 41, 12 }, { 37, 17 }, { 46, 23 }, { 42, 30 }, { 52, 34 }, { 45, 40 }, { 50, 47 }, { 38, 46 }, { 34, 54 } }
local keep = c:poly{ { 0, 0 }, { 36, 0 }, zig[1], zig[2], zig[3], zig[4], zig[5], zig[6], zig[7], zig[8], zig[9], zig[10], { 34, 63 }, { 0, 63 } }
local disc = c:ellipse(29, 30, 22, 22)
local chip = disc:copy():clip(keep)
-- the slab: the thickness of the snapped edge, seen below and right of the break
local slab = chip:copy():shift(2, 2):clip(disc):cut(chip)
local slI, slT = O.shade(c, slab, SLAB, { R = 1, amb = .3, cuts = { .3, .55, .8 } })
O.tex(c, slI, slT, SLAB, function(x, y, i) if (x + y * 2) % 5 == 0 then return -1 end if (x + y * 2) % 5 == 2 and i >= 2 then return 1 end end) -- strata
local mb = {}
local mI, mT = O.shade(c, chip, MOON, { sphere = { 23, 23, 33 }, bias = mb, amb = .5, wrap = .65, rim = true, bounce = "#7a6aa8", bmax = 2, sep = SLAB[1] })
-- maria: soft darker patches away from the face
O.tex(c, mI, mT, MOON, function(x, y, i)
  if x >= 16 and x <= 40 and y >= 24 and y <= 40 then return 0 end
  local v = math.sin(x * .31 + .7) + math.sin(y * .27 + 1.9) + math.sin((x - y) * .19)
  if v > 1.2 and i >= 3 then return (v > 1.9 and i >= 4) and -2 or -1 end
  local w = math.sin(x * .5 + 2.3) + math.sin(y * .45 + .4)
  if w > 1.55 and i >= 4 then return -1 end
  if H(x, y, 29) > .975 and i >= 4 then return 2 end -- moondust glints
end)
-- craters: dark lip upper-left, lit lip lower-right
for _, cr in ipairs({ { 14, 20, 2.5 }, { 23, 12, 1.5 }, { 33, 14, 2 }, { 12, 39, 1.5 }, { 24, 46, 2 }, { 40, 35, 1 }, { 30, 9, 1 }, { 16, 30, 2.5 } }) do
  c:ellipse(cr[1], cr[2], cr[3], cr[3]):each(function(x, y)
    local p = y * c.w + x
    if c.own[p] == mT then
      local i = mI[K(x, y)] or 3
      local dx, dy = x - cr[1], y - cr[2]
      local d = math.sqrt(dx * dx + dy * dy)
      local o = (d > cr[3] - 1) and ((dx + dy) < 0 and -2 or 1) or -1
      c.pix[p] = MOON[math.max(1, math.min(6, i + o))]:lower()
    end
  end)
end
-- ray splash round the young crater (upper left)
for _, r in ipairs({ { 11, 17 }, { 10, 16 }, { 17, 17 }, { 18, 16 }, { 11, 23 }, { 10, 24 }, { 17, 23 }, { 14, 16 }, { 14, 15 } }) do
  if c.own[r[2] * c.w + r[1]] == mT then O.mark(c, { r }, MOON[6]) end
end
-- glow line along the snapped edge (chip pixels touching the slab)
chip:each(function(x, y)
  if slab:has(x + 1, y + 1) and not slab:has(x, y + 1) and ((x + y) % 3 ~= 0) then O.mark(c, { { x, y } }, MOON[5]) end
end)
-- glow streak along the moon rim
O.mark(c, { { 8, 28 }, { 8, 29 }, { 8, 30 }, { 8, 26 }, { 9, 23 }, { 10, 20 }, { 12, 17 }, { 14, 14 } }, MOON[6])
-- closer look: three talon scratches by the snapped edge
for _, s in ipairs({ { 38, 40 }, { 40, 38 }, { 42, 36 } }) do
  O.mark(c, { { s[1], s[2] }, { s[1] - 1, s[2] + 1 }, { s[1] - 2, s[2] + 2 } }, MOON[2])
end

-- face
c:eyeLocked(20, 27)
c:eyeLocked(31, 27)
c:cheek(18, 34) c:cheek(36, 34)
O.dots(c, { { 25, 34 }, { 26, 35 }, { 27, 35 }, { 28, 35 }, { 29, 34 } }, P.ink)
O.dots(c, { { 26, 36 }, { 27, 36 }, { 28, 36 } }, "#c94f84")

O.shift(c, 1, 3)
O.done(c, "pl-owl-2-yard", function(c)
  -- quirk: crumb trail falling in behind it from the upper right
  for _, q in ipairs({ { 51, 5 }, { 56, 11 }, { 59, 18 } }) do
    c:put(q[1], q[2], GLOW) c:put(q[1] + 1, q[2], MOON[5]) c:put(q[1], q[2] + 1, MOON[4]) c:put(q[1] + 1, q[2] + 1, MOON[3])
    for _, o in ipairs({ { -1, 0 }, { -1, 1 }, { 2, 0 }, { 2, 1 }, { 0, -1 }, { 1, -1 }, { 0, 2 }, { 1, 2 } }) do c:put(q[1] + o[1], q[2] + o[2], P.ink) end
  end
  c:sparkle(5, 6)
end)
