-- Wing Jot (pl-jdf-1), yard sprite 64x64. Opus second pass (c14/opus2), built on c14/haiku.
-- Thornblade, common, Lair of the Jade Dragon-fly. "A jade flake that falls off a wing and hums while it drifts."
-- Haiku drew a faceted blue gem (it read as a crystal). Now it is a real piece of dragonfly wing in jade glass:
-- a long rounded wing tip tilted as it drifts, a dark leading-edge vein along the top, cross-veins making the
-- little window cells, a bright glassy rim and pale core, and a jagged broken edge at the root where it
-- snapped off the wing.
-- quirk: it hums as it drifts: sound rings ripple off the tip and a dotted drift trail curls behind it.
-- closer look: the pterostigma, the small dark amber cell near the tip on the leading edge, like on a real wing.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
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
-- the face sits in one big clear central cell
local function fd(x, y) return ((x - 31.5) / 10.5) ^ 2 + ((y - 34) / 7.5) ^ 2 end
-- membrane: amber tint at the root, a pale clear band along the trailing edge, a glassy glint streak
O.tex(c, I, T, JADE, function(x, y, i)
  if fd(x, y) < 1.1 then return 0 end
  local u = (x - 9) * DX + (y - 43) * DY
  if not wing:has(x + 1, y + 2) and i <= 4 and u > 8 then return 1 end
  if math.abs((x - 9) * -DY + (y - 43) * DX + 1 - (u - 30) * .05) < .8 and u > 34 and u < 46 then return 2 end
end)
-- veins: costa along the leading edge, three long veins root -> tip, cross-veins between them
local function bez(p, t) return O.bez(p, t) end
local LV = { { { 11, 40 }, { 24, 31 }, { 40, 22 }, { 56, 15 } }, { { 11, 44 }, { 26, 37 }, { 42, 28 }, { 57, 19 } },
             { { 13, 47 }, { 28, 44 }, { 44, 36 }, { 55, 25 } } }
local vpx = {}
for li, p in ipairs(LV) do
  for k = 0, 80 do local x, y = bez(p, k / 80) vpx[#vpx+1] = { floor(x + .5), floor(y + .5) } end
  if li < 3 then
    for k = 1, 9 do
      local t = k / 10 + (li == 2 and .05 or 0)
      local x1, y1 = bez(p, t) local x2, y2 = bez(LV[li + 1], t + .02)
      for s = 0, 6 do local q = s / 6 vpx[#vpx+1] = { floor(x1 + (x2 - x1) * q + .5), floor(y1 + (y2 - y1) * q + .5) } end
    end
  end
end
for _, q in ipairs(vpx) do
  if wing:has(q[1], q[2]) and fd(q[1], q[2]) >= 1 then
    O.mark(c, { q }, fd(q[1], q[2]) < 1.35 and JADE[3] or JADE[2])
  end
end
-- face cell ring
wing:each(function(x, y) local d = fd(x, y) if d >= 1 and d < 1.22 then O.mark(c, { { x, y } }, JADE[3]) end end)
-- costa: the dark leading-edge vein
local cst = {}
wing:each(function(x, y) if wing:has(x, y - 1) and not wing:has(x, y - 2) and (x - 9) * DX + (y - 43) * DY > 3 then cst[#cst+1] = { x, y } end end)
for _, q in ipairs(cst) do O.mark(c, { q }, VEIN) end
-- pterostigma: a small amber cell just behind the leading edge near the tip
O.mark(c, { { 48, 18 }, { 49, 17 }, { 50, 17 }, { 51, 16 } }, STIG[2]) O.mark(c, { { 49, 18 }, { 50, 18 }, { 51, 17 } }, STIG[3])
O.dots(c, { { 21, 31 }, { 22, 30 } }, JADE[6]) -- glint on the glass

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
