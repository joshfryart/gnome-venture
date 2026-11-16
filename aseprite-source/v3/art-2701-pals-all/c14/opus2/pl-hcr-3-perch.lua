-- Gust Ribbon (pl-hcr-3), perch sprite 36x36. Opus second pass (c14/opus2), hand-built at this size.
-- A leaf ribbon chasing itself round a loop: thin tail, a pale twisted underside at the top, a broad pointed
-- leaf head with 2x3 pill eyes.
-- quirk: a dashed wind loop inside the ring.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-hcr-3-perch", 36)
local cos, sin, pi, sqrt, floor, max, min = math.cos, math.sin, math.pi, math.sqrt, math.floor, math.max, math.min

local LEAF = { "#1c4236", "#2a6640", "#3c8c4a", "#62ac50", "#9ccc68", "#d2e89a" }
local UNDR = { "#3e5a40", "#5c7e52", "#82a46a", "#accb8a", "#d2e4b0", "#eef4d6" }
local WIND = "#d6eaf0"

local CX, CY, R = 17, 15, 8.5
local A0, A1 = 112, 418
local function path(t) local a = (A0 + (A1 - A0) * t) * pi / 180 return CX + R * cos(a), CY + R * sin(a) end
local function width(t)
  local w = .7 + 1.9 * t ^ .7
  for _, tc in ipairs({ .43, .6 }) do local tw = math.abs(t - tc) if tw < .07 then w = w * (.45 + .55 * tw / .07) end end
  return w
end
local samples = {}
for i = 0, 300 do
  local t = i / 300
  local x, y = path(t)
  local x2, y2 = path(min(1, t + .003)) local x1, y1 = path(max(0, t - .003))
  local tx, ty = x2 - x1, y2 - y1 local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  samples[#samples+1] = { x = x, y = y, t = t, px = -ty, py = tx, w = width(t) }
end
local top, und, rn = HP.mask(), HP.mask(), {}
for y = 0, 35 do for x = 0, 35 do
  local best, bs
  for _, s in ipairs(samples) do local q = (x - s.x) ^ 2 + (y - s.y) ^ 2 if not best or q < best then best, bs = q, s end end
  if sqrt(best) <= bs.w then
    local sn = max(-.9, min(.9, ((x - bs.x) * bs.px + (y - bs.y) * bs.py) / (bs.w + .5)))
    rn[K(x, y)] = { bs.px * sn * .85, bs.py * sn * .85, .55 }
    if bs.t > .43 and bs.t < .6 then und:set(x, y) else top:set(x, y) end
  end
end end

c:groundShadow(19, 32, 7, 1.5)
O.shadeN(c, top, rn, LEAF, { amb = .3, wrap = .45, rim = true })
O.shadeN(c, und, rn, UNDR, { amb = .4, wrap = .5, sep = UNDR[1] })

local head = c:poly{ { 25, 18 }, { 27, 20 }, { 27, 24 }, { 25, 27 }, { 21, 29 }, { 16, 30 }, { 11, 31 }, { 14, 28 },
                     { 15, 24 }, { 16, 21 }, { 19, 19 }, { 22, 18 } }
head:add(c:ellipse(21, 24, 6, 5))
O.shade(c, head, LEAF, { sphere = { 17, 20, 10 }, amb = .42, wrap = .45, rim = true, bounce = "#3f6a8a", bmax = 2, sep = LEAF[1] })
O.mark(c, { { 15, 29 }, { 14, 30 }, { 13, 30 } }, LEAF[5])
c:eyeSmall(17, 21)
c:eyeSmall(23, 21)
O.dot(c, 16, 25, P.petal.base) O.dot(c, 26, 25, P.petal.base)
O.dots(c, { { 19, 26 }, { 20, 27 }, { 21, 27 }, { 22, 26 } }, P.ink)

O.done(c, "pl-hcr-3-perch", function(c)
  for a = 0, 359, 12 do
    if (a // 12) % 3 ~= 2 and not (a > 20 and a < 160) then
      local x, y = floor(CX + 4.5 * cos(a * pi / 180) + .5), floor(CY + 4 * sin(a * pi / 180) + .5)
      if not c:get(x, y) then O.dot(c, x, y, WIND) end
    end
  end
end)
