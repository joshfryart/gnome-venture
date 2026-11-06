-- rice-and-peas (final, artist aD12_4). A slim glazed teal bowl (cream dotted band, glaze streak, cool bounce, foot ring)
-- heaped with a dome of pink-tinged coconut rice: individual grains with a lit top and shadow dot, glossy red kidney
-- beans (specular + notch), green thyme flecks, a wooden spoon sunk in the heap with the handle sticking up and out.
-- Parts meet with AO (inner rim, spoon, beans). quirk: one runaway kidney bean has rolled out of the bowl onto the table,
-- with a single rice grain stuck to it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_4.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("rice-and-peas")

local TEAL = { "#14303c", "#1f4e5e", "#2c6f84", "#3f93a4", "#6ab8c0", "#a8e0dc" }
local RICE = { "#7a4e54", "#a8756e", "#d09c8c", "#ecc0a8", "#fcdcc4", "#fff2de" }
local CRM  = { "#8a6a58", "#b58d70", "#dcb590", "#f2d4a8", "#fbe7c4", "#fff4d6" }
local BN   = { "#3a1018", "#6e2038", "#a02a3c", "#c8403c", "#e86a50", "#ffa07a" }
local WOOD = { "#3a2220", "#51302b", "#7a4630", "#a46a40", "#cc9460", "#e8b982" }
local rnd = A.rng(11)

c:groundShadow(31, 56, 22, 2.5)

-- foot ring
local foot = A.rows(53, 55, function(y) return 32 - (y == 53 and 10 or 11), 32 + (y == 53 and 10 or 11) end)
local fb = {} foot:each(function(x, y) fb[K(x, y)] = (y == 55) and -2 or -1 end)
A.pill(c, foot, TEAL, 1.6, { bias = fb })

-- bowl body (hemisphere section)
local body = A.rows(40, 52, function(y) local hw = 20 * sqrt(1 - ((y - 40) / 20) ^ 2) return 32 - hw, 32 + hw end)
local rimO, rimI = c:ellipse(32, 40, 20, 5), c:ellipse(32, 40, 18, 3.4)
local ring = rimO:copy():cut(rimI)
local frontRing = ring:copy():clip(c:rect(0, 40, 63, 63))
local bb = {} X.ao(bb, body, frontRing, 1, -1)
local bidx, bn = A.sph(c, body, 30, 35, 21, TEAL, { bias = bb, amb = 0.1, wrap = 0.28 })
-- cream band with dots, curving down at the middle
for x = 12, 52 do
  local yc = 43 + 3.5 * sqrt(max(0, 1 - ((x - 32) / 20) ^ 2))
  for _, y in ipairs{ floor(yc), floor(yc) + 1 } do
    if body:has(x, y) then c:px(x, y, CRM[min(6, max(1, (bidx[K(x, y)] or 3) + 0))]) end
  end
  if x % 4 == 0 and body:has(x, floor(yc) + 1) then c:px(x, floor(yc) + 1, TEAL[max(1, (bidx[K(x, floor(yc) + 1)] or 3) - 1)]) end
  if body:has(x, floor(yc) + 2) then c:px(x, floor(yc) + 2, TEAL[max(1, (bidx[K(x, floor(yc) + 2)] or 3) - 2)]) end
end
-- cool bounce light on the lower-right edge, glaze streak on the left
local rim = X.rim(bn)
body:edge():each(function(x, y) if rim[K(x, y)] > 0.62 and x > 36 and y > 44 then c:px(x, y, "#5aa6b8") end end)
for _, p in ipairs{ {17,48},{17,49},{18,50},{19,51} } do if body:has(p[1], p[2]) then c:px(p[1], p[2], TEAL[6]) end end
c:px(18, 47, "#e6fbf6")

-- rim ring (lighter lip), back half now, front half re-put after the rice
local rb = {} ring:each(function(x, y) rb[K(x, y)] = 1 end)
local ridx = A.pill(c, ring, TEAL, 1.5, { bias = rb, amb = 0.15, wrap = 0.3 })
for _, p in ipairs{ {15,38},{16,37},{16,38},{14,40} } do if ring:has(p[1], p[2]) then c:px(p[1], p[2], "#e6fbf6") end end
-- inside of the bowl
rimI:each(function(x, y) c:px(x, y, y < 40 and TEAL[2] or TEAL[1]) end)

-- spoon (bowl head sunk in the rice + handle)
local head = A.ell(35.5, 31, 4.8, 3.2, -0.75)
local hm, hn, HT, HS = X.cyl(38, 29, 54, 9, function(t) return 1.1 + 0.55 * max(0, (t - 0.8) / 0.2) end)

-- rice dome
local mound = c:ellipse(32, 35, 16, 13):clip(c:rect(0, 0, 63, 39))
mound:add(c:ellipse(32, 40.5, 16.5, 2.6):clip(rimI))
local mb = {}
X.ao(mb, mound, frontRing, 2, -1)
G.cast(mb, mound, head, 1, 1, -2) G.cast(mb, mound, head, 2, 2, -1)
G.cast(mb, mound, hm, 1, 1, -1)
local midx = A.sph(c, mound, 31, 35, 15, RICE, { bias = mb, amb = 0.1, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
-- grains: lit top, shadow dot under
local inner = mound:shrink(1)
local pts = {}
inner:each(function(x, y) pts[#pts + 1] = { x, y } end)
table.sort(pts, function(a, b) if a[2] ~= b[2] then return a[2] < b[2] end return a[1] < b[1] end)
for i = 1, 70 do
  local p = pts[floor(rnd() * #pts) + 1]
  local x, y = p[1], p[2]
  local t = midx[K(x, y)] or 3
  local hi, lo = RICE[min(6, t + 1)], RICE[max(1, t - 1)]
  local o = floor(rnd() * 3)
  if o == 0 then c:px(x, y, hi) c:px(x + 1, y, hi) c:px(x, y + 1, lo) c:px(x + 1, y + 1, lo)
  elseif o == 1 then c:px(x, y, hi) c:px(x + 1, y + 1, hi) c:px(x, y + 1, lo)
  else c:px(x, y, hi) c:px(x, y + 1, hi) c:px(x + 1, y + 1, lo) end
end
-- thyme flecks
for i = 1, 11 do
  local p = pts[floor(rnd() * #pts) + 1]
  c:px(p[1], p[2], "#2e7646") c:px(p[1] + 1, p[2], "#6ab455") c:px(p[1], p[2] - 1, "#45954c")
end

-- kidney beans
local function bean(cx, cy, ang, scale)
  scale = scale or 1
  local m = A.ell(cx, cy, 2.7 * scale, 1.8 * scale, ang)
  m:shift(1, 1):each(function(x, y) if mound:has(x, y) and not m:has(x, y) then c:px(x, y, RICE[1]) end end)
  local n = X.pillow(m, 1.8)
  G.toneN(c, m, n, BN, { amb = 0.1, wrap = 0.3 })
  local ca, sa = cos(ang), sin(ang)
  -- notch (hilum) on the inner long side
  local hx, hy = floor(cx - 1.4 * sa + 0.5), floor(cy + 1.4 * ca + 0.5)
  if m:has(hx, hy) then c:px(hx, hy, "#f2b8a0") end
  c:px(floor(cx - 1.2 * ca + 0.5) - 0, floor(cy - 1.2 * sa - 0.6 + 0.5), BN[6])
end
for _, b in ipairs{ {21,34,0.3}, {27,28,-0.5}, {24,39,0.1}, {30,37,0.6}, {41,38,-0.2}, {44,33,0.5}, {17,38,0.0}, {32,24,-0.4}, {45,38,0.8} } do
  if mound:has(b[1], b[2]) then bean(b[1], b[2], b[3]) end
end

-- spoon over the rice
local WOODtok = { r = { name = "wood" } }
local hb = {} head:each(function(x, y) hb[K(x, y)] = 0 end)
local headIdx = A.pill(c, head, WOOD, 2.2, { bias = hb, tok = WOODtok })
A.ell(35, 30.4, 3.1, 1.8, -0.75):each(function(x, y) c:px(x, y, WOOD[max(1, (headIdx[K(x, y)] or 3) - 2)]) end)
A.ell(34.4, 30.8, 2.2, 1.0, -0.75):each(function(x, y) if (x + y) % 2 == 0 then c:px(x, y, RICE[3]) end end)
local hidx = G.toneN(c, hm, hn, WOOD, { amb = 0.12, wrap = 0.3 })
hm:each(function(x, y) local k = K(x, y)
  if abs(HS[k] - 0.15) < 0.14 and HT[k] > 0.08 then c:px(x, y, WOOD[max(1, (hidx[k] or 3) - 1)]) end
  if HT[k] < 0.06 then c:px(x, y, WOOD[1]) end end)
c:px(floor(38 + 16 * 0.93 + 0.5), floor(29 - 20 * 0.93 + 0.5), WOOD[1])
-- contact shadow of the handle on the dome
hm:shift(1, 1):each(function(x, y) if mound:has(x, y) and not hm:has(x, y) and not head:has(x, y) then c:px(x, y, RICE[1]) end end)

-- front rim over the rice
frontRing:each(function(x, y) c:px(x, y, TEAL[ridx[K(x, y)] or 4]) end)
for _, p in ipairs{ {26,45},{27,45},{36,44} } do end

-- quirk: runaway bean with a stuck grain
local rb2 = A.ell(49.5, 56, 2.9, 1.9, 0.25)
local rn = X.pillow(rb2, 1.9)
G.toneN(c, rb2, rn, BN, { amb = 0.1, wrap = 0.3 })
c:px(48, 55, BN[6]) c:px(47, 55, BN[5]) c:px(50, 56, "#f2b8a0")
c:px(51, 55, RICE[6]) c:px(52, 55, RICE[5]) c:px(51, 54, RICE[4])

A.save(c, "rice-and-peas")
