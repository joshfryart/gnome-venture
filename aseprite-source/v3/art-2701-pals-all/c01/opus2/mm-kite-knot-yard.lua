-- Kite Knot (mm-kite-knot), yard sprite 64x64. Opus second pass (art-2701-pals-all/c01/opus2), from the Haiku idea.
-- Thornblade, uncommon, Mistmoor. "Ties its tail in a bow and flies off in a huff."
-- A diamond kite tilted up and away (it is leaving), four cloth panels (ember red / gold, quartered by
-- wooden spars), each panel billowing on its own with a weave and a hemmed edge. Cross brows, pouting mouth,
-- a puff of huff blown out of one side. The tail swings down in an S with little ribbon ties.
-- Fixes: the Haiku kite stood dead upright and flat; now it tilts and billows, the panels and spars
-- give it structure, the brows are bold ink and the tail moves.
-- quirk: halfway down, the tail string is tied in a big pink bow.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mm-kite-knot-yard", 64)

local EMB  = { "#4a1a2e", "#7e2238", "#b8343c", "#e0533e", "#f4864e", "#fbc07a" }
local GOLD = { "#5e3a1c", "#9a5d1e", "#d08a2a", "#f0b440", "#f8d670", "#fdf0b0" }
local WOOD = { "#3a2228", "#5e3a2e", "#86563a", "#ad7a4c" }
local PINK = { "#7a2a4a", "#c94f6d", "#ef7a8a", "#f7a8a8" }
local CLD  = { "#8696b4", "#b2c0d6", "#d9e3ee", "#eef3f8" }
local STR  = "#d8ccb8"

local cx, cy, ang = 35, 24, math.rad(14)
local ca, sa = math.cos(ang), math.sin(ang)
local function rot(lx, ly) return cx + lx * ca - ly * sa, cy + lx * sa + ly * ca end
local function unrot(x, y) local dx, dy = x + .5 - cx, y + .5 - cy return dx * ca + dy * sa, -dx * sa + dy * ca end
local L = { { 0, -19 }, { 15, -5 }, { 0, 18 }, { -15, -5 } }
local pts = {}
for _, p in ipairs(L) do local x, y = rot(p[1], p[2]) pts[#pts+1] = { x, y } end
local kite = c:poly(pts)

-- tail first (behind the kite): an S curve from the bottom tip
local bx, by = rot(0, 18)
local tail = { { bx, by }, { bx - 7, by + 6 }, { bx + 4, by + 11 }, { bx - 5, by + 17 } }
local tm = O.tube(tail, function() return .6 end)
tm:each(function(x, y) c:put(x, y, STR, { r = { name = "string" } }) end)
-- little ribbon ties along the tail
for _, t in ipairs({ .25, .8 }) do
  local x, y = O.bez(tail, t)
  x, y = math.floor(x), math.floor(y)
  O.dots(c, { { x - 1, y }, { x + 1, y } }, t < .5 and GOLD[4] or EMB[4]) O.dots(c, { { x - 2, y + 1 }, { x + 2, y - 1 } }, t < .5 and GOLD[3] or EMB[3])
end

-- the kite cloth: four panels, each billowing
local n = {}
kite:each(function(x, y)
  local lx, ly = unrot(x, y)
  -- panel centre in local coords
  local px = lx < 0 and -6 or 6
  local py = ly < -5 and -10 or 5
  local dx, dy = (lx - px) / 9, (ly - py) / 12
  local z = math.sqrt(math.max(.15, 1 - dx * dx - dy * dy))
  local nx, ny = dx * ca - dy * sa, dx * sa + dy * ca
  n[K(x, y)] = { nx * .55, ny * .55, z + .3 }
end)
local v = X.light(n, { amb = .15, wrap = .35 })
local ktok = { r = { name = "kite" } }
local CUT = { .2, .38, .55, .71, .86 }
kite:each(function(x, y)
  local lx, ly = unrot(x, y)
  local red = (lx < 0) == (ly < -5)
  local R = red and EMB or GOLD
  local vv = v[K(x, y)] or .5
  local i = 1
  for k = 1, 5 do if vv > CUT[k] then i = k + 1 end end
  if math.floor(lx + 40) % 3 == 0 and math.floor(ly + 40) % 2 == 0 and i > 2 then i = i - 1 end -- weave
  c:put(x, y, R[i], ktok)
end)
-- hem just inside the edge
kite:edge():each(function(x, y)
  local lx, ly = unrot(x, y)
  local red = (lx < 0) == (ly < -5)
  c:put(x, y, red and EMB[2] or GOLD[2], ktok)
end)
-- spars
local sx0, sy0 = rot(0, -18) local sx1, sy1 = rot(0, 17)
local hx0, hy0 = rot(-14, -5) local hx1, hy1 = rot(14, -5)
-- the spars sit behind the cloth: a dark crease line through each panel, wood showing only at the tips
local function crease(x0, y0, x1, y1)
  local nn = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
  for t = 0, nn do
    local x, y = math.floor(x0 + (x1 - x0) * t / nn + .5), math.floor(y0 + (y1 - y0) * t / nn + .5)
    if c.own[y * 64 + x] == ktok then
      local lx, ly = unrot(x, y)
      local red = (lx < 0) == (ly < -5)
      local d = math.min(math.abs(lx), math.abs(ly + 5))
      c:put(x, y, (t < 2 or t > nn - 2) and WOOD[3] or (red and EMB[2] or GOLD[2]), ktok)
    end
  end
end
crease(sx0, sy0, sx1, sy1) crease(hx0, hy0, hx1, hy1)
local jx, jy = rot(0, -5)
O.dots(c, { { math.floor(jx), math.floor(jy) }, { math.floor(jx) + 1, math.floor(jy) } }, WOOD[4])

-- face (below the cross spar)
local fx, fy = rot(0, 3)
fx, fy = math.floor(fx), math.floor(fy)
c:eyeLocked(fx - 8, fy - 3)
c:eyeLocked(fx + 2, fy - 3)
O.dots(c, { { fx - 9, fy - 6 }, { fx - 8, fy - 6 }, { fx - 7, fy - 5 }, { fx - 6, fy - 5 }, { fx - 5, fy - 4 }, { fx - 4, fy - 4 } }, P.ink)
O.dots(c, { { fx + 7, fy - 6 }, { fx + 6, fy - 6 }, { fx + 5, fy - 5 }, { fx + 4, fy - 5 }, { fx + 3, fy - 4 }, { fx + 2, fy - 4 } }, P.ink)
O.dots(c, { { fx - 4, fy + 6 }, { fx - 3, fy + 5 }, { fx - 2, fy + 5 }, { fx - 1, fy + 5 }, { fx, fy + 5 }, { fx + 1, fy + 6 } }, P.ink) -- pout
c:cheek(fx - 10, fy + 3) c:cheek(fx + 6, fy + 3)

-- quirk: the tail tied in a big bow
local qx, qy = O.bez(tail, .4)
qx, qy = math.floor(qx), math.floor(qy)
local bow = c:poly{ { qx, qy }, { qx - 5, qy - 3 }, { qx - 5, qy + 3 } }
bow:add(c:poly{ { qx, qy }, { qx + 5, qy - 3 }, { qx + 5, qy + 3 } })
O.shade(c, bow, PINK, { R = 1, amb = .3, cuts = { .3, .55, .8 }, sep = PINK[1] })
O.dots(c, { { qx - 1, qy + 2 }, { qx - 2, qy + 3 }, { qx + 1, qy + 2 }, { qx + 2, qy + 4 } }, PINK[2]) -- streamers
O.flat(c, c:rect(qx - 1, qy - 1, qx + 1, qy + 1), PINK[2], "knot") O.dot(c, qx - 1, qy - 1, PINK[4])

-- huff puff blown out to the left
local hp = O.unionCircles{ { 13, 22, 2.5, 2 }, { 16, 20, 2, 1.8 } }
O.shade(c, hp, CLD, { R = 1, amb = .4, cuts = { .35, .6, .85 }, rim = true })
O.flat(c, c:rect(11, 26, 12, 27), CLD[3], "puff2")

O.shift(c, 2, 0)
O.done(c, "mm-kite-knot-yard")
