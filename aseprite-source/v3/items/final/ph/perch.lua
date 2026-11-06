-- perch (final, Opus aC33_1). A slim European perch swimming right: humped olive back, six dark tapering bars over a
-- brassy-gold flank, cream belly, small scale rows, gill cover arc, gold-ringed eye; spiny first dorsal (grey-olive
-- membrane, dark spines, the black rear spot), soft second dorsal, forked orange-red tail, red pelvic and anal fins,
-- a translucent pectoral fin; per-pixel light, cool reflected belly edge, AO under fins.
-- quirk: a snapped bit of fishing line still hangs from its lip on a tiny hook, twisting as it curls away.
local NAME = "perch"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local OLIVE = { "#1c3328", "#2b4a32", "#45683a", "#688a40", "#94aa4c", "#c8cc78" }
local BRASS = { "#4e3a1e", "#7e5e22", "#b48a2a", "#dab238", "#f0d264", "#fff0a8" }
local BELLY = { "#5e5466", "#948a90", "#c8bca8", "#e6d8b8", "#f6eacc", "#fff4d6" }
local FIN = { "#5a1a2a", "#962a2c", "#cc472c", "#ec6c32", "#ff9a52", "#ffc88a" }
local MEM = { "#3a4448", "#56666a", "#7a8c86", "#9cae9e", "#c0ccb4", "#e2e8cc" }
local COOL = "#5f86a8"

local MY, X0, X1 = 33, 13, 54
local function prof(x)
  local u = (x - X0) / (X1 - X0)
  if u < 0 or u > 1 then return nil end
  local top = 2.2 + 8.6 * sin(pi * u ^ 0.78) ^ 0.85
  local bot = 2.2 + 6.4 * sin(pi * u ^ 0.9) ^ 0.9
  return MY - top, MY + bot
end
local body = HP.mask()
for x = X0, X1 do local t, b = prof(x)
  for y = floor(t + 0.5), floor(b + 0.5) do body:set(x, y) end end
-- normals: across-body cylinder blended with pillow at the ends
local np = X.pillow(body, 3)
local bn, BU = {}, {}
body:each(function(x, y) local k = K(x, y) local t, b = prof(x)
  local u = (y - (t + b) / 2) / ((b - t) / 2 + 0.6)
  BU[k] = (y - t) / (b - t + 0.01)
  local cx, cy, cz = 0, u * 0.92, sqrt(max(0.05, 1 - (u * 0.92) ^ 2))
  local p = np[k]
  bn[k] = { A.norm(cx * 0.6 + p[1] * 0.4, cy * 0.6 + p[2] * 0.4, cz * 0.6 + p[3] * 0.4) }
end)

-- tail (behind body): forked, rays
local ttok = { r = { name = "tail" } }
local tail = c:poly{ { 14, 31 }, { 9, 25 }, { 7, 23 }, { 8, 28 }, { 10, 33 }, { 8, 39 }, { 7, 43 }, { 9, 41 }, { 14, 36 } }
tail:cut(body)
local tn = X.pillow(tail, 2)
local tidx = A.shade(c, tail, tn, FIN, { amb = 0.2, wrap = 0.35 })
tail:each(function(x, y) if (x + abs(y - 33)) % 3 == 0 and x < 13 then c:put(x, y, FIN[max(1, (tidx[K(x, y)] or 3) - 1)], ttok) end end)

-- fins under/over the body (drawn first, body overlaps their roots)
local function fin(pts, ramp, nm, ray)
  local m = c:poly(pts) m:cut(body)
  local n = X.pillow(m, 1.5)
  local tok = { r = { name = nm } }
  local idx = A.shade(c, m, n, ramp, { amb = 0.18, wrap = 0.35, tok = tok })
  if ray then m:each(function(x, y) if ray(x, y) then c:put(x, y, ramp[max(1, (idx[K(x, y)] or 3) - 2)], tok) end end) end
  m:each(function(x, y) if body:has(x, y + 1) or body:has(x, y - 1) then c:put(x, y, ramp[1], tok) end end)
  return m, idx, tok
end
-- spiny first dorsal: membrane with spines, black rear spot, spines poke 1 px above the scalloped edge
local dm, didx, dtok = fin({ { 21, 26 }, { 22, 18 }, { 24, 15 }, { 27, 15 }, { 30, 16 }, { 33, 18 }, { 35, 21 }, { 36, 24 } }, MEM, "dorsal1",
  function(x, y) return x % 3 == 0 end)
for x = 22, 35, 3 do local yt = 99 dm:each(function(xx, yy) if xx == x and yy < yt then yt = yy end end)
  if yt < 99 then c:put(x, yt - 1, MEM[2], dtok) end end
for _, p in ipairs{ { 31, 20 }, { 32, 20 }, { 32, 21 }, { 33, 21 }, { 31, 21 }, { 32, 22 }, { 33, 22 } } do c:put(p[1], p[2], "#24202c", dtok) end
-- soft second dorsal
fin({ { 37, 24 }, { 38, 20 }, { 41, 19 }, { 44, 21 }, { 45, 24 } }, MEM, "dorsal2", function(x, y) return x % 2 == 0 end)
-- anal fin and pelvic fin: red-orange
fin({ { 22, 38 }, { 21, 43 }, { 24, 45 }, { 28, 41 } }, FIN, "anal", function(x, y) return (x + y) % 3 == 0 end)
fin({ { 39, 39 }, { 37, 45 }, { 40, 46 }, { 44, 41 } }, FIN, "pelvic", function(x, y) return (x + y) % 3 == 0 end)

-- body: zone ramps on one light index
local btok = { r = { name = "body" } }
local bv = X.light(bn, { amb = 0.08, wrap = 0.28 })
local bias = {}
X.ao(bias, body, dm, 1, -1)
local bidx = {}
body:each(function(x, y) local k = K(x, y)
  local val = bv[k] local i = 1
  for j, t in ipairs(A.CUTS) do if val >= t then i = j + 1 end end
  i = max(1, min(6, i + (bias[k] or 0)))
  bidx[k] = i
  local u = BU[k]
  local ramp = u < 0.3 and OLIVE or (u < 0.72 and BRASS or BELLY)
  c:put(x, y, ramp[i], btok)
end)
local function bramp(k) local u = BU[k] return u < 0.3 and OLIVE or (u < 0.72 and BRASS or BELLY) end
-- scale rows: tiny offset arcs (one tone down), skipped on the head
body:each(function(x, y) local k = K(x, y)
  if x < 44 and x > X0 + 2 and BU[k] > 0.08 and BU[k] < 0.8 and ((y % 2 == 0 and x % 4 == 0) or (y % 2 == 1 and x % 4 == 2)) then
    c:put(x, y, bramp(k)[max(1, bidx[k] - 1)], btok) end end)
-- six dark bars, tapering toward the belly, slanting back
local bars = { 18, 23, 28, 33, 38, 42 }
body:each(function(x, y) local k = K(x, y) local u = BU[k]
  for bi, bx in ipairs(bars) do
    local cx = bx + (u - 0.3) * 2.5
    local w = 1.25 * (1 - u * 0.9) + (bi == 3 and 0.2 or 0)
    if u < 0.62 and abs(x - cx) < w then c:put(x, y, OLIVE[max(1, bidx[k] - 2)], btok) end
  end
end)
-- lateral line, cool reflected edge on the belly
body:each(function(x, y) local k = K(x, y) local t, b = prof(x)
  if x > 15 and x < 45 and y == floor(t + (b - t) * 0.36 + 0.5) and x % 2 == 0 then c:put(x, y, BRASS[6], btok) end
  if y == floor(b + 0.5) and x > 18 and x < 50 then c:put(x, y, COOL, btok) end
end)
-- head: gill cover arc, darker cheek, mouth
for y = 25, 40 do local t, b = prof(45)
  local x = floor(44.5 + 2.2 * sin((y - 25) / 15 * pi) + 0.5)
  if body:has(x, y) then c:put(x, y, bramp(K(x, y))[max(1, bidx[K(x, y)] - 2)], btok)
    if body:has(x + 1, y) then c:put(x + 1, y, bramp(K(x + 1, y))[min(6, bidx[K(x + 1, y)] + 1)], btok) end end
end
c:put(53, 33, "#3a1e26", btok) c:put(52, 33, "#3a1e26", btok) c:put(51, 34, BELLY[3], btok)
-- eye: gold ring, ink pupil, cream glint
local ex, ey = 48, 29
for _, p in ipairs{ { 0, -1 }, { 1, -1 }, { -1, 0 }, { 2, 0 }, { -1, 1 }, { 2, 1 }, { 0, 2 }, { 1, 2 } } do c:put(ex + p[1], ey + p[2], BRASS[5], btok) end
c:put(ex, ey, "#2b1c26", btok) c:put(ex + 1, ey, "#2b1c26", btok) c:put(ex, ey + 1, "#2b1c26", btok) c:put(ex + 1, ey + 1, "#2b1c26", btok)
c:put(ex, ey, A.CREAM, btok) c:put(ex - 1, ey - 1, BRASS[3], btok) c:put(ex + 2, ey + 2, BRASS[3], btok)
-- pectoral fin: small fan behind the gill cover, on the flank
local pm = c:poly{ { 42, 33 }, { 37, 35 }, { 36, 38 }, { 39, 37 }, { 42, 35 } }
local ptok = { r = { name = "pectoral" } }
local pidx = A.shade(c, pm, X.pillow(pm, 1.2), FIN, { amb = 0.3, wrap = 0.4, tok = ptok })
pm:each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, FIN[max(1, pidx[K(x, y)] - 1)], ptok) end end)
for x = 37, 43 do if pm:has(x, 32) == false and body:has(x, 36) and not pm:has(x, 36) and x > 38 then end end
-- one wet specular on the back
c:put(30, 25, OLIVE[6], btok) c:put(31, 25, OLIVE[6], btok) c:put(29, 26, OLIVE[5], btok)

-- quirk: tiny hook in the lip + snapped twisted line curling away
local htok = { r = { name = "hook" } }
for _, p in ipairs{ { 54, 35, "#e2e0e6" }, { 55, 36, "#aaa9b8" }, { 55, 37, "#74758c" }, { 54, 38, "#aaa9b8" }, { 53, 37, "#e2e0e6" } } do c:put(p[1], p[2], p[3], htok) end
local line = { { 56, 37 }, { 56, 38 }, { 57, 39 }, { 57, 40 }, { 56, 41 }, { 56, 42 }, { 57, 43 } }
for i, p in ipairs(line) do c:put(p[1], p[2], i % 2 == 0 and "#e8ddc0" or "#a89e8c", htok) end
A.save(c, NAME)
