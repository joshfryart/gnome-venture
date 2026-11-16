-- Gust Ribbon (pl-hcr-3), yard sprite 64x64. Opus second pass (c14/opus2), built on c14/haiku.
-- Seedkeeper, common, Lair of the Hurricane Crab. "A leaf ribbon that flutters around in a little circle."
-- Haiku drew a green ring with a blue face plate in the hole (it read as a hood). It is now one long ribbon
-- of leaf chasing itself round a loop: a thin curled tail, a body that twists over at the top to show its pale
-- underside, and a broad leaf head with the face, midrib running the whole way.
-- quirk: fluttering round in its circle: a dashed wind loop inside the ring and flutter ticks at the twist.
-- closer look: a little bite notch out of the ribbon's edge on the left.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-hcr-3-yard", 64)
local cos, sin, pi, sqrt, floor, max, min = math.cos, math.sin, math.pi, math.sqrt, math.floor, math.max, math.min

local LEAF = { "#1c4236", "#2a6640", "#3c8c4a", "#62ac50", "#9ccc68", "#d2e89a" }
local UNDR = { "#3e5a40", "#5c7e52", "#82a46a", "#accb8a", "#d2e4b0", "#eef4d6" }
local WIND = "#d6eaf0"

-- ribbon path: a loop round (32,27), tail at the left, head arriving at the lower right
local CX, CY, R = 31, 28, 15
local A0, A1 = 112, 418 -- degrees, clockwise on screen
local function path(t)
  local a = (A0 + (A1 - A0) * t) * pi / 180
  local r = R
  return CX + r * cos(a), CY + r * sin(a)
end
local function width(t)
  local w = 1 + 3.4 * t ^ .7
  for _, tc in ipairs({ .43, .6 }) do -- the two twists at the top: pinch
    local tw = math.abs(t - tc)
    if tw < .07 then w = w * (.3 + .7 * tw / .07) end
  end
  return w
end
local function under(t) return t > .43 and t < .6 end -- the pale underside shows between the two twists
local samples = {}
for i = 0, 400 do
  local t = i / 400
  local x, y = path(t)
  local x2, y2 = path(min(1, t + .003)) local x1, y1 = path(max(0, t - .003))
  local tx, ty = x2 - x1, y2 - y1 local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  samples[#samples+1] = { x = x, y = y, t = t, px = -ty, py = tx, w = width(t) }
end
local rib, rn, RT, RS = HP.mask(), {}, {}, {}
for y = 0, 63 do for x = 0, 63 do
  local best, bs
  for _, s in ipairs(samples) do local q = (x - s.x) ^ 2 + (y - s.y) ^ 2 if not best or q < best then best, bs = q, s end end
  if sqrt(best) <= bs.w then
    local sd = (x - bs.x) * bs.px + (y - bs.y) * bs.py
    local sn = max(-.9, min(.9, sd / (bs.w + .5)))
    rib:set(x, y) rn[K(x, y)] = { bs.px * sn * .85, bs.py * sn * .85, .55 } RT[K(x, y)] = bs.t RS[K(x, y)] = sd / max(bs.w, .5)
  end
end end
-- bite notch on the left edge
rib:cut(c:ellipse(13.5, 31, 1.3, 1.3))

c:groundShadow(36, 59, 12, 2)

-- split into top-side and underside parts so the twist reads
local top, und = HP.mask(), HP.mask()
rib:each(function(x, y) if under(RT[K(x, y)]) then und:set(x, y) else top:set(x, y) end end)
local tI, tT = O.shadeN(c, top, rn, LEAF, { amb = .3, wrap = .45, rim = true, bounce = "#3f6a8a", bmax = 2 })
local uI, uT = O.shadeN(c, und, rn, UNDR, { amb = .4, wrap = .5, sep = UNDR[1] })
-- midrib down the ribbon, side veins on the wide part
O.tex(c, tI, tT, LEAF, function(x, y, i)
  local s, t = RS[K(x, y)], RT[K(x, y)]
  if not s then return 0 end
  if math.abs(s) < .2 and t > .08 then return 1 end
  if t > .6 and math.abs(s) > .45 and math.abs(s) < .7 and (x + y) % 4 == 0 then return -1 end
end)
O.tex(c, uI, uT, UNDR, function(x, y, i) local s = RS[K(x, y)] if s and math.abs(s) < .22 then return -1 end end)

-- the head: a broad leaf blade, pointed at the end, the face on it
local head = c:poly{ { 46, 35 }, { 49, 38 }, { 50, 43 }, { 48, 48 }, { 43, 52 }, { 36, 54 }, { 29, 55 }, { 22, 56 }, { 26, 52 },
                     { 28, 46 }, { 30, 41 }, { 34, 37 }, { 40, 35 } } -- leaf blade: base up-right, long tip out to the lower left
head:add(c:ellipse(39, 44, 10, 8.5))
local hI, hT = O.shade(c, head, LEAF, { sphere = { 33, 38, 17 }, amb = .4, wrap = .45, rim = true, bounce = "#3f6a8a", bmax = 2, sep = LEAF[1] })
local function mr(x, y) return ((x - 36) * .6 + (y - 46) * .8) end         -- signed distance from the midrib
local function al(x, y) return ((x - 36) * -.8 + (y - 46) * .6) end        -- position along it (+ toward the tip)
local function face(x, y) return x >= 29 and x <= 47 and y >= 37 and y <= 49 end
O.tex(c, hI, hT, LEAF, function(x, y, i)
  if face(x, y) then return 0 end
  local d, a = mr(x, y), al(x, y)
  if math.abs(d) < .55 then return 1 end                                         -- pale midrib
  if math.abs(((a - math.abs(d) * .9) % 4) - 0) < .6 and math.abs(d) > 1.5 and i <= 5 then return -1 end -- veins
end)
O.mark(c, { { 32, 51 }, { 31, 52 }, { 30, 52 }, { 29, 53 }, { 28, 53 }, { 27, 54 }, { 26, 54 }, { 25, 55 } }, LEAF[5]) -- midrib to the tip
O.mark(c, { { 35, 52 }, { 36, 51 }, { 37, 50 }, { 41, 50 }, { 42, 49 }, { 43, 48 } }, LEAF[2])                     -- veins
c:eyeLocked(32, 39)
c:eyeLocked(41, 39)
c:cheek(30, 45) c:cheek(46, 45)
O.dots(c, { { 36, 46 }, { 37, 47 }, { 38, 47 }, { 39, 47 }, { 40, 46 } }, P.ink)

O.done(c, "pl-hcr-3-yard", function(c)
  -- dashed wind loop inside the ring
  for a = 0, 359, 8 do
    if (a // 8) % 3 ~= 2 and not (a > 30 and a < 150) then
      local x, y = floor(CX + 8 * cos(a * pi / 180) + .5), floor(CY - 1 + 7 * sin(a * pi / 180) + .5)
      if not c:get(x, y) then O.dot(c, x, y, WIND) end
    end
  end
  -- flutter ticks at the twist
  O.dots(c, { { 44, 8 }, { 45, 7 }, { 48, 10 }, { 49, 10 }, { 17, 8 }, { 16, 9 } }, WIND)
end)
