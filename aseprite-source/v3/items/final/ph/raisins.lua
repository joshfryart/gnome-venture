-- raisins (Opus single pass, final). A glazed ochre stoneware bowl with a teal dotted band, heaped with plump,
-- wrinkled raisins (6-tone plum-brown ramps, ridge wrinkles, dusty bloom, AO between neighbours, front lip over the
-- heap) and a slim wooden scoop standing in the heap, handle up to the right with a hanging-hole.
-- quirk: a tiny red ant is hauling a stolen raisin away across the table, beside two spilled ones.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD11_3.lua")
local G, X, HP, K = A.G, A.X, A.HP, A.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = G.new2("raisins")
local CX, RY, RX, YB = 27, 34, 17, 51
local GLAZE = { "#6b3a35", "#9a5a3c", "#c98a4c", "#e3aa58", "#f3ca78", "#fde9a8" }
local TEAL  = { "#1d3f55", "#2a6a82", "#3a98a8", "#62c4c0", "#9be0d0", "#d4f6e6" }
local WOOD  = { "#51302b", "#7a4630", "#a1653c", "#c38850", "#e0aa6c", "#f4cf96" }

c:groundShadow(CX + 1, 56, 19, 2)
-- bowl body: lower half of an ellipsoid, narrowing to a foot
local body = HP.mask()
for y = RY, YB do
  local t = (y - RY) / 19
  local w = RX * sqrt(max(0, 1 - t * t))
  for x = floor(CX - w + .5), floor(CX + w - .5) do body:set(x, y) end
end
local n = {}
body:each(function(x, y)
  local nx, ny = (x + .5 - CX) / (RX + .6), (y - RY) / 20.5
  n[K(x, y)] = { nx, ny, sqrt(max(0.03, 1 - nx * nx - ny * ny)) }
end)
local v = X.light(n, { amb = .1, wrap = .3 })
local rr = X.rim(n)
local bias = {}
body:each(function(x, y) local k = K(x, y) if rr[k] > .78 then bias[k] = 1 end end)
local idx = X.tone(c, body, v, GLAZE, { cuts = { .24, .42, .58, .74, .88 }, bias = bias, tok = { r = { name = "bowl" } } })
-- teal painted band with cream dots
body:each(function(x, y)
  local k = K(x, y)
  if y >= RY + 4 and y <= RY + 7 then
    c:put(x, y, TEAL[idx[k]], { r = { name = "band" } })
    if y == RY + 5 and (x - CX) % 4 == 0 and idx[k] >= 3 then c:put(x, y, TEAL[6]) end
    if y == RY + 6 and (x - CX) % 4 == 2 and idx[k] >= 3 then c:put(x, y, TEAL[5]) end
  end
end)
-- glaze drip below the band
for _, p in ipairs{ { -6, 8 }, { 7, 8 }, { 7, 9 } } do local x, y = CX + p[1], RY + 8 + (p[2] - 8) if body:has(x, y) then c:px(x, y, TEAL[max(1, idx[K(x, y)] - 1)]) end end
-- foot ring
local foot = c:rect(CX - 6, YB, CX + 6, YB + 2)
foot:each(function(x, y) c:px(x, y, (y == YB) and GLAZE[1] or (x < CX - 2 and WOOD[3] or (x > CX + 2 and WOOD[1] or WOOD[2]))) end)
-- rim ring
local outer, inner = c:ellipse(CX, RY, RX, 4.7), c:ellipse(CX, RY, RX - 2.4, 3.1)
local ring = outer:copy():cut(inner)
local function paintRing(front)
  ring:each(function(x, y)
    if front and y < RY then return end
    local t = .52 + (y < RY and .22 or 0) - (x - CX) / 46 + (y > RY + 2 and -.12 or 0)
    local i = 1 for j, th in ipairs{ .24, .42, .58, .74, .88 } do if t >= th then i = j + 1 end end
    c:put(x, y, GLAZE[i], { r = { name = "rim" } })
  end)
end
paintRing(false)
inner:each(function(x, y) c:put(x, y, y < RY - 1 and GLAZE[2] or GLAZE[1], { r = { name = "cavity" } }) end)
-- front lip mask (for AO on heap)
local lip = ring:copy() local lipF = HP.mask()
ring:each(function(x, y) if y >= RY then lipF:set(x, y) end end)

-- raisins
local heap = HP.mask()
local PL = { A.ramp("#5c2d4a"), A.ramp("#683644"), A.ramp("#4e2c52"), A.ramp("#6a3a38") }
local function raisin(cx, cy, rx, ry, ang, sd, o)
  o = o or {}
  local m, nn = G.oval(cx, cy, rx, ry, ang, 1)
  -- irregular edge
  local ed = m:edge()
  local drop = {}
  m:each(function(x, y) if ed:has(x, y) and X.hash(x, y, sd) > .86 then drop[#drop + 1] = { x, y } end end)
  for _, p in ipairs(drop) do m.s[K(p[1], p[2])] = nil end
  local rp = PL[1 + floor(X.hash(sd, 4, 2) * 4)]
  local b = {}
  if not o.noao then X.ao(b, m, heap, 1, -2) X.ao(b, m, lipF, 1, -1) end
  local tok = { r = { name = "raisin" .. sd } }
  local ix = G.toneN(c, m, nn, rp, { bias = b, tok = tok, cuts = { .2, .36, .52, .68, .86 }, amb = .1, wrap = .3 })
  local ph = X.hash(sd, 9, 1) * 7
  m:each(function(x, y)
    local k = K(x, y)
    local i = ix[k] or 3
    local f = (x * 2.3 + y * 3.1 + ph) % 6
    if f < 1 and not (b[k] and b[k] < 0) then c:put(x, y, rp[max(1, i - 1)], tok)
    elseif f >= 1 and f < 1.9 and i >= 3 and i < 6 and (x - cx) + (y - cy) < 1 then c:put(x, y, rp[min(6, i + 1)], tok) end
    -- dusty bloom on the lit shoulder
    if (x - cx) + (y - cy) < -1 and X.hash(x, y, sd + 7) > .95 and i >= 3 then c:put(x, y, "#a98aa8", tok) end
  end)
  m:edge():each(function(x, y) if heap:has(x, y) then c:put(x, y, ((x - cx) + (y - cy) < -1) and rp[2] or rp[1], tok) end end)
  heap:add(m)
  return m
end
local rows = {
  { 19.5, { 26.5, 33 } },
  { 23.5, { 20.5, 27, 33.5, 39 } },
  { 28, { 15.5, 22, 28.5, 35, 41.5 } },
  { 32.5, { 13.5, 19.5, 25.5, 31.5, 37.5, 43.5 } },
}
local sd = 1
for _, r in ipairs(rows) do
  for _, x in ipairs(r[2]) do
    local j = (X.hash(sd, 2, 5) - .5) * 1.4
    raisin(x + (X.hash(sd, 7, 3) - .5) * 1.2, r[1] + (X.hash(sd, 8, 3) - .5) * 1.2, 4.1 + X.hash(sd, 3, 3) * .7, 3.2 + X.hash(sd, 5, 3) * .5, j, sd)
    sd = sd + 1
  end
end
-- front lip over the heap (+ AO line on the heap above it)
paintRing(true)
-- scoop handle (behind-front: stands in the heap)
local hm, hn, T, S = X.cyl(34, 29, 51, 10, function(t) return 1.6 - .25 * t end)
X.tone(c, hm, X.light(hn, { amb = .12, wrap = .3 }), WOOD, { cuts = { .24, .42, .58, .74, .88 }, tok = { r = { name = "scoop" } } })
hm:each(function(x, y) local k = K(x, y) if T[k] > .1 and X.hash(floor(T[k] * 20), floor(S[k] * 2 + 3), 6) > .72 then c:px(x, y, WOOD[2]) end end)
-- handle end paddle with hole
local pd = G.oval(52, 9.5, 3.1, 2.3, -.7, .7)
G.toneN(c, pd, select(2, G.oval(52, 9.5, 3.1, 2.3, -.7, .7)), WOOD, { amb = .12, wrap = .3 })
c:px(52, 9, WOOD[1]) c:px(51, 8, WOOD[2])
-- scoop edge shadow on heap
for _, p in ipairs{ { 33, 30 }, { 34, 31 }, { 35, 31 } } do if heap:has(p[1], p[2]) then c:px(p[1], p[2], "#2e1830") end end

-- spilled raisins + ant
heap = HP.mask()
raisin(47.5, 55.5, 3, 2.4, -.3, 62, { noao = true })
-- ant: red body, carrying a raisin overhead
local AR = { "#4a1424", "#7e2030", "#b3342f", "#d9503a", "#f58a5c" }
local ax, ay = 56, 56
for i, p in ipairs{ { 0, 0, 3 }, { 1, 0, 4 }, { -1, 0, 3 }, { -2, 0, 2 } } do c:px(ax + p[1], ay + p[2], AR[p[3]]) end
c:px(ax + 2, ay - 1, AR[4])                                  -- head
c:px(ax + 3, ay - 2, AR[2]) c:px(ax + 3, ay - 3, AR[2])        -- antenna
c:px(ax - 1, ay + 1, AR[1]) c:px(ax + 1, ay + 1, AR[1]) c:px(ax - 3, ay + 1, AR[1]) c:px(ax + 2, ay + 1, AR[1])
c:px(ax, ay - 1, AR[3])
local cr = G.oval(ax - .5, ay - 4, 3, 2.3, 0, 1)
local cm, cn = G.oval(ax - .5, ay - 4, 3, 2.3, 0, 1)
G.toneN(c, cm, cn, PL[2], { amb = .1, wrap = .3 })
c:px(ax - 1, ay - 5, "#a98aa8")
c:px(29, 30, "#e8d0e6")
G.save2(c, "raisins")
