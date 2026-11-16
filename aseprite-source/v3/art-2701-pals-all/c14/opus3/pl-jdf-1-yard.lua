-- Wing Jot (pl-jdf-1), yard sprite 64x64. Opus third pass (c14/opus3, richness), built on c14/opus2.
-- opus3 fixes the crackle-glass read: a thick dark costa with a lit glass edge under it, long veins
-- (two long veins) running parallel from root to tip and converging there, regular ladder cross-veins between them (tighter in
-- the costal field), a pale membrane margin, a faint rainbow sheen streak, a nodus notch and a dark-rimmed
-- amber pterostigma.
-- Thornblade, common, Lair of the Jade Dragon-fly. "A jade flake that falls off a wing and hums while it drifts."
-- Haiku drew a faceted blue gem (it read as a crystal). Now it is a real piece of dragonfly wing in jade glass:
-- a long rounded wing tip tilted as it drifts, a dark leading-edge vein along the top, cross-veins making the
-- little window cells, a bright glassy rim and pale core, and a jagged broken edge at the root where it
-- snapped off the wing.
-- quirk: it hums as it drifts: sound rings ripple off the tip and a dotted drift trail curls behind it.
-- closer look: the pterostigma, the small dark amber cell near the tip on the leading edge, like on a real wing.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_c14.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-jdf-1-yard", 64)
local cos, sin, rad, sqrt, abs, floor = math.cos, math.sin, math.rad, math.sqrt, math.abs, math.floor

local JADE = { "#123c3a", "#1c6052", "#2a8a6e", "#4cb489", "#8edcac", "#d0f4d8" }
local VEIN = "#1a4c44"
local STIG = { "#6a3a22", "#a8642a", "#d89a3c" }
local HUM  = "#a8e8c4"

-- wing outline: nearly straight leading edge on top, curved trailing edge below, round tip up-right,
-- jagged break at the root (lower left)
local wing = c:poly{ { 9, 37 }, { 20, 29 }, { 32, 22 }, { 44, 16 }, { 51, 13 }, { 56, 12 }, { 59, 14 }, { 59, 19 },
                     { 55, 26 }, { 48, 34 }, { 39, 42 }, { 29, 47 }, { 19, 49 }, { 11, 49 }, { 13, 46 }, { 8, 44 }, { 11, 41 }, { 7, 39 } }
local DX, DY = .89, -.455
local ANG = math.atan(DY, DX)

c:groundShadow(31, 57, 11, 2)
local I, T = O.shade(c, wing, JADE, { R = 6, amb = .42, wrap = .55, bounce = "#5a7ab0", bmax = 3 })
-- opus3 venation: everything is laid out in wing coordinates (u along the leading edge, f = 0 at the costa,
-- 1 at the trailing edge), so the long veins run parallel root -> tip and converge at the tip, and the
-- cross-veins are short regular ladder rungs between them. That reads as a wing, not as crackle glass.
local NX, NY = -DY, DX -- perpendicular, pointing down-right into the wing
local function UV(x, y) return (x - 9) * DX + (y - 37) * DY, (x - 9) * NX + (y - 37) * NY end
local vmin, vmax = {}, {}
wing:each(function(x, y) local u, v = UV(x, y) local b = floor(u + .5)
  vmin[b] = math.min(vmin[b] or 99, v) vmax[b] = math.max(vmax[b] or -99, v) end)
local function F(x, y) local u, v = UV(x, y) local b = floor(u + .5)
  local w = math.max(1, (vmax[b] or v) - (vmin[b] or v)) return u, (v - (vmin[b] or v)) / w, w, v - (vmin[b] or v) end
local function fd(x, y) return ((x - 31.5) / 10.5) ^ 2 + ((y - 34) / 7.5) ^ 2 end -- the face's clear cell
local LONG = { .25, .5, .75 }
local long, rung, costa, costaLit, edge, sheen = {}, {}, {}, {}, {}, {}
-- membrane: clean two-tone glass (lit costal half, cel shade toward the trailing edge, lower right)
local memL, memD = {}, {}
wing:each(function(x, y) local u, f = F(x, y) if f < .5 + (u - 30) * .006 then memL[#memL+1] = { x, y } else memD[#memD+1] = { x, y } end end)
O.mark(c, memL, JADE[6]) O.mark(c, memD, JADE[5])
wing:each(function(x, y)
  local u, f, w, dv = F(x, y)
  if dv < 1.3 and u > 2 then costa[#costa+1] = { x, y } return end
  if dv < 2.3 and u > 2 then costaLit[#costaLit+1] = { x, y } return end
  if fd(x, y) < 1.15 then return end
  if f > .93 and u > 6 then edge[#edge+1] = { x, y } return end
  for li, lf in ipairs(LONG) do
    if math.abs(f - lf) * w < .55 then long[#long+1] = { x, y } return end
  end
  -- ladder rungs: closer in the costal field, wider and staggered further back
  local band = f < LONG[1] and 1 or f < LONG[2] and 2 or f < LONG[3] and 3 or 4
  local sp = ({ 3, 4, 4, 5 })[band]
  local off = ({ 0, 2, 0, 2.5 })[band]
  if ((u + off) % sp) < .9 and u > 3 then rung[#rung+1] = { x, y } end
  -- iridescent sheen: a soft diagonal streak across the outer half
  local sd = (x - 44) + (y - 24) * 1.4
  if sd > -1 and sd < 1.6 and y >= 22 and y <= 27 and f > .3 then sheen[#sheen+1] = { x, y } end
end)
O.mark(c, rung, JADE[3])
O.mark(c, long, JADE[2])
O.mark(c, costa, VEIN)
O.mark(c, costaLit, JADE[6])
O.mark(c, edge, JADE[4])
for i, q in ipairs(sheen) do O.mark(c, { q }, i % 2 == 0 and "#f0dcec" or "#f6eecc") end -- a hint of rainbow on the glass
-- the face's clear cell: brighter glass, ringed by a vein
wing:each(function(x, y) local d = fd(x, y)
  if d < 1 then O.mark(c, { { x, y } }, (x - 31.5) + (y - 34) * 1.3 < 2 and JADE[6] or JADE[5]) elseif d < 1.15 then O.mark(c, { { x, y } }, JADE[2]) end end)
-- nodus: the little kink in the costa halfway along (a lit notch)
O.mark(c, { { 31, 24 }, { 32, 24 } }, JADE[5])
-- pterostigma: a dark-rimmed amber cell between the costa and the first vein near the tip
O.mark(c, { { 47, 19 }, { 48, 18 }, { 49, 18 }, { 50, 17 }, { 51, 17 }, { 52, 16 } }, STIG[1])
O.mark(c, { { 48, 19 }, { 49, 19 }, { 50, 18 }, { 51, 18 } }, STIG[3]) O.mark(c, { { 52, 17 } }, STIG[2])
O.dots(c, { { 20, 33 }, { 21, 32 } }, JADE[6]) -- glint on the glass

c:eyeLocked(25, 30)
c:eyeLocked(34, 29)
c:cheek(23, 36) c:cheek(40, 35)
O.dots(c, { { 30, 36 }, { 31, 36 }, { 32, 36 }, { 29, 37 }, { 33, 37 }, { 30, 38 }, { 31, 38 }, { 32, 38 } }, P.ink) -- round humming mouth
O.dot(c, 31, 37, "#1e5048")

O.done(c, "pl-jdf-1-yard", function(c)
  -- hum rings off the tip
  for _, r in ipairs({ 4, 6.5 }) do
    for a = -130, -30, 9 do
      local t = rad(a)
      local x, y = floor(55 + r * cos(t) + .5), floor(13 + r * sin(t) + .5)
      if not c:get(x, y) and x < 63 then O.dot(c, x, y, HUM) end
    end
  end
  -- dotted drift trail behind the root
  for _, p in ipairs({ { 5, 44 }, { 7, 47 }, { 10, 49 }, { 14, 50 }, { 18, 49 } }) do O.dot(c, p[1], p[2], HUM) end
end)
