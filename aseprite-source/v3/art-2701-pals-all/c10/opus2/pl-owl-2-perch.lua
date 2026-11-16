-- Nightglow Fleck (pl-owl-2), perch sprite 36x36. Opus second pass (c10/opus2), hand-built at this size.
-- A round chip of moon in cool moonlight tones with a zigzag snap across its lower right (the slab of the break
-- shows below it), two craters, a glow streak on the rim, pill eyes on the lit middle.
-- quirk: two moon crumbs trailing in behind it from the upper right.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-owl-2-perch", 36)

local MOON = { "#565084", "#8a86b6", "#bcbcd6", "#e6e4c6", "#f8f0b4", "#fffae0" }
local SLAB = { "#3e3a66", "#5e5a88", "#8682a8", "#aeaac4" }
local GLOW = "#fff0a0"

local zig = { { 20, 3 }, { 23, 8 }, { 21, 11 }, { 27, 14 }, { 24, 19 }, { 29, 22 }, { 25, 25 }, { 27, 29 }, { 21, 28 }, { 19, 33 } }
local keep = c:poly{ { 0, 0 }, { 20, 0 }, zig[1], zig[2], zig[3], zig[4], zig[5], zig[6], zig[7], zig[8], zig[9], zig[10], { 19, 35 }, { 0, 35 } }
local disc = c:ellipse(16, 17, 13, 13)
local chip = disc:copy():clip(keep)
local slab = chip:copy():shift(1, 2):clip(disc):cut(chip)
O.shade(c, slab, SLAB, { R = 1, amb = .3, cuts = { .3, .55, .8 } })
local mI, mT = O.shade(c, chip, MOON, { sphere = { 12, 12, 19 }, amb = .5, wrap = .65, rim = true, bounce = "#7a6aa8", bmax = 2, sep = SLAB[1] })
for _, cr in ipairs({ { 8, 11, 1.5 }, { 14, 26, 1.5 } }) do
  c:ellipse(cr[1], cr[2], cr[3], cr[3]):each(function(x, y)
    local p = y * c.w + x
    if c.own[p] == mT then
      local i = mI[K(x, y)] or 3
      local dx, dy = x - cr[1], y - cr[2]
      c.pix[p] = MOON[math.max(1, math.min(6, i + ((dx + dy) < 0 and -1 or 1)))]:lower()
    end
  end)
end
O.mark(c, { { 4, 15 }, { 4, 16 }, { 5, 12 }, { 6, 10 } }, MOON[6])

c:eyeSmall(10, 15)
c:eyeSmall(17, 15)
O.dot(c, 8, 19, "#f5809f") O.dot(c, 21, 19, "#f5809f")
O.dots(c, { { 13, 19 }, { 14, 20 }, { 15, 20 }, { 16, 19 } }, P.ink)

O.shift(c, 1, 1)
O.done(c, "pl-owl-2-perch", function(c)
  for _, q in ipairs({ { 28, 4 }, { 32, 9 } }) do
    c:put(q[1], q[2], GLOW) c:put(q[1] + 1, q[2], MOON[5]) c:put(q[1], q[2] + 1, MOON[4]) c:put(q[1] + 1, q[2] + 1, MOON[3])
    for _, o in ipairs({ { -1, 0 }, { -1, 1 }, { 2, 0 }, { 2, 1 }, { 0, -1 }, { 1, -1 }, { 0, 2 }, { 1, 2 } }) do c:put(q[1] + o[1], q[2] + o[2], P.ink) end
  end
end)
