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

-- wing frame: u along the wing (root -> tip), v across (leading edge negative)
local CX, CY, ANG = 31, 31, rad(-14)
local A, B = 25, 15
local function uv(x, y)
  local dx, dy = x - CX, y - CY
  return dx * cos(ANG) + dy * sin(ANG), -dx * sin(ANG) + dy * cos(ANG)
end
local function half(u, v) -- straight leading edge (v<0), full curved trailing edge
  local taper = .6 + .4 * math.min(1, (u + A) / (1.1 * A))
  return (v < 0 and B * .58 or B) * taper
end
local wing, n, UU, VV = HP.mask(), {}, {}, {}
for y = 0, 63 do for x = 0, 63 do
  local u, v = uv(x + .5, y + .5)
  local hb = half(u, v)
  -- jagged break at the root
  local root = -A + 3 + 2.5 * ((floor(v / 2.5) % 2 == 0) and 1 or 0)
  if (u / A) ^ 2 + (v / hb) ^ 2 <= 1 and u > root then
    wing:set(x, y)
    local nu, nv = u / A, v / hb
    local nz = sqrt(math.max(.15, 1 - (nu * nu + nv * nv) * .6))
    -- normal back to screen space (gently domed)
    local sx = (nu * cos(ANG) - nv * sin(ANG)) * .7
    local sy = (nu * sin(ANG) + nv * cos(ANG)) * .7
    n[K(x, y)] = { sx, sy, nz }
    UU[K(x, y)], VV[K(x, y)] = u, v / hb
  end
end end

c:groundShadow(31, 57, 11, 2)
local I, T = O.shadeN(c, wing, n, JADE, { amb = .4, wrap = .55, rim = true, bounce = "#5a7ab0", bmax = 3 })
-- the face sits in one big central cell ringed by a vein
local function fd(x, y) return ((x - 31.5) / 10.5) ^ 2 + ((y - 32) / 7.5) ^ 2 end
-- glass shimmer: alternate cells one tone lighter, trailing edge thinner and darker
O.tex(c, I, T, JADE, function(x, y, i)
  local u, v = UU[K(x, y)], VV[K(x, y)]
  if fd(x, y) < 1 then return 0 end
  if v > .82 and i >= 3 then return -1 end
  if floor((u + 30 - v * 3) / 6) % 2 == 0 and v > -.4 then return 1 end
end)
-- leaded vein network: dark 1px lines
local veins = {}
wing:each(function(x, y)
  local u, v = UU[K(x, y)], VV[K(x, y)]
  local hb = half(u, v)
  local d = fd(x, y)
  local on = false
  if v < -.7 then on = true end                                                    -- costa (leading edge)
  if d >= 1 and d < 1.25 then on = true end                                        -- ring round the face cell
  if d >= 1.25 then
    if math.abs(v - .2) * hb < .55 or math.abs(v - .62) * hb < .55 or math.abs(v + .3) * hb < .5 then on = true end -- long veins
    if ((u + 30 - v * 3) % 6) < .9 then on = true end                              -- cross-veins
  end
  if on then veins[#veins+1] = { x, y } end
end)
for _, q in ipairs(veins) do O.mark(c, { q }, VEIN) end
-- pterostigma near the tip, on the leading edge
for _, p in ipairs({ { 47, 18 }, { 48, 18 }, { 49, 17 }, { 47, 19 }, { 48, 19 }, { 49, 18 } }) do
  if wing:has(p[1], p[2]) then O.mark(c, { p }, (p[2] == 18 and p[1] == 47) and STIG[3] or STIG[2]) end
end
O.dots(c, { { 24, 26 }, { 25, 25 }, { 26, 25 } }, JADE[6]) -- glint on the glass

c:eyeLocked(25, 28)
c:eyeLocked(34, 27)
c:cheek(24, 34) c:cheek(39, 33)
O.dots(c, { { 30, 34 }, { 31, 34 }, { 32, 34 }, { 29, 35 }, { 33, 35 }, { 30, 36 }, { 31, 36 }, { 32, 36 } }, P.ink) -- round humming mouth
O.dot(c, 31, 35, "#1e5048")

O.done(c, "pl-jdf-1-yard", function(c)
  -- hum rings off the tip
  for _, r in ipairs({ 5, 8 }) do
    for a = -50, 50, 8 do
      local t = ANG + rad(a)
      local x, y = floor(53.5 + r * cos(t) + .5), floor(20 + r * sin(t) + .5)
      if not c:get(x, y) and x < 63 then O.dot(c, x, y, HUM) end
    end
  end
  -- dotted drift trail behind the root
  for _, p in ipairs({ { 5, 44 }, { 7, 47 }, { 10, 49 }, { 14, 50 }, { 18, 49 } }) do O.dot(c, p[1], p[2], HUM) end
end)
