-- Sun Glint (ow-sun-glint), yard sprite 64x64. Opus second pass (art-2701-pals-all/c02/opus2), built on the Haiku pass.
-- Rootwarden, uncommon, Olivewhistle. "Winks off the sea at breakfast and keeps going all afternoon."
-- A round morning sun sitting on a strip of sea: a warm gold disc lit from the upper left, a crown of three big
-- cream-tipped rays on top (tri knob) and eight shorter amber rays round the rest, and a gold reflection
-- path running down the water. Uncommon touch: lit ray tips, glints on the sea.
-- Fix vs Haiku: only 7 colours and thin spikes; now 6-tone ramps on disc, rays and sea, rays are fat
-- wedges in their own amber ramp (separate from the disc), and the sun has somewhere to wink from.
-- quirk: it is mid-wink: one locked eye, the other a closed arc with a cream sparkle popping off it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ow-sun-glint-yard", 64)

local SUN = { "#9a4a1c", "#c86a22", "#e8902c", "#f6b440", "#fcd662", "#fff0a6" }
local RAY = { "#7a2a1a", "#a8401c", "#d05e22", "#ec8430", "#f6ac48", "#fcd890" }
local SEA = { "#1d3f6a", "#245e8e", "#2f84ac", "#48a8c0", "#7ccbd2", "#b9e8e4" }
local CX, CY, R = 32, 32, 14

-- rays: wedges behind the disc
local function ray(a, len, half, tipTone)
  local r0 = R - 2
  local ca, sa = math.cos(math.rad(a)), math.sin(math.rad(a))
  local p1 = { CX + math.cos(math.rad(a - half)) * r0, CY + math.sin(math.rad(a - half)) * r0 }
  local p2 = { CX + math.cos(math.rad(a + half)) * r0, CY + math.sin(math.rad(a + half)) * r0 }
  local tip = { CX + ca * len, CY + sa * len }
  local m = c:poly{ p1, tip, p2 }
  local rb = {}
  m:each(function(x, y)
    local d = math.sqrt((x - CX) ^ 2 + (y - CY) ^ 2)
    if d > len - 2.5 then rb[K(x, y)] = tipTone end
  end)
  O.shade(c, m, RAY, { R = 1.5, bias = rb, amb = .3, wrap = .4, sep = RAY[1] })
end
-- tri knob: the three big crown rays
ray(-90, 25, 17, 2)
ray(-130, 23, 16, 2)
ray(-50, 23, 16, 2)
for _, a in ipairs({ -12, 22, 158, 192 }) do ray(a, 20, 15, 1) end

-- disc
local disc = c:ellipse(CX, CY, R, R)
local dI, dT = O.shade(c, disc, SUN, { sphere = { CX - 5, CY - 6, R + 5 }, amb = .25, wrap = .35, rim = true, sep = "#a8401c" })
-- sun-spot mottling (faint, keeps the lighting)
O.dots(c, { { 24, 24 }, { 25, 24 }, { 24, 25 } }, SUN[6])

-- face
c:eyeLocked(24, 29)
-- winking eye: closed arc
O.dots(c, { { 35, 32 }, { 36, 31 }, { 37, 31 }, { 38, 31 }, { 39, 32 } }, P.ink)
O.dots(c, { { 36, 30 }, { 38, 30 } }, SUN[3]) -- lid crease
O.dots(c, { { 22, 36 }, { 23, 36 } }, "#f5809f") O.dots(c, { { 40, 35 }, { 41, 35 } }, "#f5809f")
-- big grin
O.dots(c, { { 28, 37 }, { 29, 38 }, { 30, 39 }, { 31, 39 }, { 32, 39 }, { 33, 39 }, { 34, 38 }, { 35, 37 } }, P.ink)
O.dots(c, { { 29, 37 }, { 30, 37 }, { 31, 37 }, { 32, 37 }, { 33, 37 }, { 34, 37 }, { 30, 38 }, { 31, 38 }, { 32, 38 }, { 33, 38 } }, "#7a2c34")
O.dots(c, { { 31, 38 }, { 32, 38 } }, "#d4553f")

-- sea strip in front: the sun's lower edge dips into the water
local sea = HP.mask()
for x = 7, 56 do
  local top = math.floor(46.5 + 1.2 * math.sin(x * .45) + .5)
  local bot = 56 - ((x < 11 or x > 52) and 1 or 0)
  for y = top, bot do sea:set(x, y) end
end
local sb = {}
sea:each(function(x, y) sb[K(x, y)] = -1 end)
local sI, sT = O.shade(c, sea, SEA, { R = 2, bias = sb, amb = .3, wrap = .4, rim = true })
O.tex(c, sI, sT, SEA, function(x, y, i) if (y == 51 and x % 7 < 3) or (y == 53 and (x + 4) % 8 < 3) then return -1 end end)
-- gold reflection path: broken horizontal dashes narrowing downwards
O.retone(c, sI, sT, { SUN[4], SUN[5], SUN[5], SUN[6], SUN[6], SUN[6] }, function(x, y, i)
  local w = 8 - (y - 49) * .8
  return math.abs(x - CX) <= w and (y + (x // 3)) % 2 == 0 and y >= 49
end)

-- foam line on the crest
for x = 7, 56 do
  local top = math.floor(46.5 + 1.2 * math.sin(x * .45) + .5)
  if c:get(x, top) and math.sin(x * .45) > -.2 then O.mark(c, { { x, top } }, SEA[6]) end
end

-- glints on the sea (un-outlined, after finish)
O.done(c, "ow-sun-glint-yard", function(c)
  -- quirk: the sparkle popping off the wink
  for _, d in ipairs({ { 0, 0 }, { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 }, { 2, 0 }, { -2, 0 }, { 0, 2 }, { 0, -2 } }) do
    c:put(43 + d[1], 27 + d[2], d[1] == 0 and d[2] == 0 and "#fff6c8" or "#fde49a", { r = { name = "spark" } })
  end
  for _, p in ipairs({ { 14, 51 }, { 49, 52 } }) do c:sparkle(p[1], p[2]) end
end)
