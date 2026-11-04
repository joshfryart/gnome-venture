-- jackfruit (final pass, Opus single pass). A tall oblong jackfruit, slightly tilted, its rind a hex grid of
-- knobbly cone bumps (each lit upper-left by the per-pixel normal field, dark valleys between, scalloped outline).
-- Thick woody stalk with grain and a pale end-grain cut on top, a dark collar ring where it meets the fruit,
-- one glossy elliptic leaf with midrib and veins, cool reflected light on the lower right of the rind.
-- quirk: a bead of milky latex weeping from the collar and running down the shoulder.
local NAME = "jackfruit"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new(NAME)
local RIND = { "#2a4022", "#42622a", "#62852e", "#89a636", "#b3c34a", "#dde283" }
local COOL = "#4c7c68"
local WOOD = { "#3d2420", "#5a3526", "#7a4c30", "#9a663c", "#bb8552", "#dcac78" }
local LEAF = { "#123326", "#1b4a30", "#28673a", "#3c8640", "#5fa64a", "#98cc66" }
local LATEX = { "#c9c0b4", "#ece4d2", "#fff4d6" }

-- fruit body: tilted oval + bump grid
local cx, cy, rx, ry, ang = 31, 37, 11.6, 17.4, 0.1
local ca, sa = cos(ang), sin(ang)
local bumps = {}
for j = -7, 7 do for i = -5, 5 do
  local u = i * 4.8 + ((j % 2 == 0) and 0 or 2.4)
  local v = j * 4.1
  bumps[#bumps + 1] = { cx + u * ca - v * sa, cy + u * sa + v * ca }
end end
local function nearest(x, y)
  local best, bx, by = 1e9, 0, 0
  for _, b in ipairs(bumps) do local q = (x - b[1])^2 + (y - b[2])^2 if q < best then best, bx, by = q, b[1], b[2] end end
  return sqrt(best), x - bx, y - by
end
local body, bn = HP.mask(), {}
for y = floor(cy - ry - 3), floor(cy + ry + 3) do for x = floor(cx - rx - 3), floor(cx + rx + 3) do
  local dx, dy = x - cx, y - cy
  local u = (dx * ca + dy * sa) / (rx + 0.45)
  local v = (-dx * sa + dy * ca) / (ry + 0.45)
  local q = u*u + v*v
  local d = nearest(x, y)
  if q <= 0.92 or (q <= 1.1 and d < 1.6) then
    body:set(x, y)
    local nx, ny = (u * ca - v * sa) / 1, (u * sa + v * ca) / 1
    local nz = sqrt(max(1 - min(q, 0.98), 0.03))
    bn[K(x, y)] = { nx, ny, nz }
  end
end end
local bias = {}
body:each(function(x, y) local k = K(x, y)
  local d, dx, dy = nearest(x, y)
  local nn = bn[k]
  if d < 2.6 then nn[1] = nn[1] + dx / 2.6 * 0.75 nn[2] = nn[2] + dy / 2.6 * 0.75 end
  bn[k] = { A.norm(nn[1], nn[2], nn[3]) }
  if d > 2.45 then bias[k] = -1 end
end)

-- stalk: thick, curving up and slightly left
local sp = { { 33, 21 }, { 33.5, 16 }, { 32, 12.5 }, { 30.5, 9 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 2.3 - t * 0.3 end)
-- collar ring: AO on the rind around the stalk foot
X.ao(bias, body, sm, 2, -1)
local fidx, ftok = A.shade(c, body, bn, RIND, { bias = bias, amb = 0.1, wrap = 0.22 })
local rim = X.rim(bn)
body:each(function(x, y) local k = K(x, y)
  if rim[k] > 0.72 and fidx[k] <= 2 and not bias[k] then c:put(x, y, COOL, ftok) end end)
-- small dark tip dot in the centre of each upper-left-lit bump crest on the shade side gives the spiky read
for _, b in ipairs(bumps) do
  local x, y = floor(b[1] + 0.5), floor(b[2] + 0.5)
  if body:has(x, y) and body:shrink(1):has(x, y) and not bias[K(x, y)] then
    local i = fidx[K(x, y)] if i and i >= 3 then c:put(x - 1, y - 1, RIND[min(6, i + 1)], ftok) end
  end
end
-- blossom scar at the bottom
local bx, by = floor(cx - 18 * sa + 0.5), floor(cy + 18 * ca + 0.5)
c:put(bx, by - 1, RIND[1], ftok) c:put(bx - 1, by - 1, RIND[2], ftok)

-- stalk paint: wood grain bands, cut end
sm:cut(body)
local stok = { r = { name = "stalk" } }
local sidx = A.shade(c, sm, sn, WOOD, { tok = stok, amb = 0.12, wrap = 0.3 })
sm:each(function(x, y) local k = K(x, y)
  local s = SS[k]
  if abs(s - 0.25) < 0.12 or abs(s + 0.45) < 0.1 then c:put(x, y, WOOD[max(1, sidx[k] - 1)], stok) end
end)
-- dark collar where the stalk enters the rind
for x = 30, 36 do if sm:has(x, 19) then c:put(x, 19, WOOD[1], stok) end if sm:has(x, 18) then c:put(x, 18, WOOD[2], stok) end end
-- end grain cut (pale oval with ring)
A.map(c, { ".ab.", "bcdb", ".bb." }, 28, 6, { a = WOOD[6], b = WOOD[4], c = WOOD[6], d = WOOD[5] }, stok)

-- leaf off the stalk, up-right
local lm, ln, LT, LS, len = A.blade(33, 14, 43, 6, 54, 11, function(t)
  if t > 0.985 then return -1 end
  return max(0.4, 4.6 * sin(pi * min(1, t * 0.92 + 0.06)) ^ 0.75)
end, { fold = 0.3 })
lm:cut(sm)
local lbias = {}
X.ao(lbias, lm, sm, 1, -1)
A.leaf(c, lm, ln, LT, LS, { ramp = LEAF, vein = "#a8d47a", cool = "#2f5f58", per = 4.2, sweep = 3, len = len, bias = lbias, t0 = 0.1 })
-- leaf spec glint (glossy)
local gx, gy = A.specAt(lm, ln, 60)
c:put(gx, gy, A.CREAM)

-- quirk: latex bead from the collar
A.map(c, { "ab", "bc", ".b", ".b", "ab", "bc" }, 36, 21, { a = LATEX[3], b = LATEX[2], c = LATEX[1] })
-- rind pop
c:put(23, 27, "#eef0a8") c:put(24, 27, "#eef0a8")
A.save(c, NAME)
