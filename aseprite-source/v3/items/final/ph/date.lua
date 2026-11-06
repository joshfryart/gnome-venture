-- date (final, Opus single pass). One slim medjool date lying on the diagonal (stem end upper-right): per-pixel
-- capsule light on a 6-tone mahogany ramp, glossy wrinkled skin (lengthwise grooves with lit lips and a few cross
-- creases), a long waxy specular streak on the lit shoulder, cool reflected light on the shade edge, a pale 4-lobed
-- calyx cap with AO where it sits, and a short twisted golden fruit strand.
-- quirk: one bite out of the far end shows amber flesh and the ridge of the pit.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new("date")
local DT = { "#2a0f17", "#461920", "#682824", "#8c3b2a", "#b25a34", "#d8874c" }
local SPEC, BOUNCE = "#ffe2b4", "#6e4766"
local FL = { "#7a3a1e", "#ab632d", "#d49248", "#efc070", "#fbe0a2" }
local PIT = { "#5e3a26", "#9c7650", "#d2b282" }
local CAL = { "#5a3a1a", "#8f6630", "#c49a52", "#ecd08a" }
local STR = { "#7a4614", "#bb7d24", "#e8b445", "#fbe08a" }

-- body: gently curved capsule
local p = { { 12, 52 }, { 21, 42 }, { 34, 30 }, { 46, 19 } }
local function hw(t) return 7.6 * sin(pi * t) ^ 0.6 + 0.3 end
local m, n, T, S, samp = G.tube(p, hw)
-- the tube helper stops at the end samples; round the ends a little more
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end

-- bite: two tooth arcs out of the lower-left end
local bite = G.rell(10.8, 53.2, 1, 0, 8.6, 8.6)
m:cut(bite)
-- drop stray crumbs left by the cut
for _ = 1, 2 do local rm = {}
  m:each(function(x, y) local nb = 0
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if m:has(x + d[1], y + d[2]) then nb = nb + 1 end end
    if nb < 2 then rm[#rm + 1] = K(x, y) end end)
  for _, k in ipairs(rm) do m.s[k] = nil end end
-- tooth marks: two 1 px nicks into the bitten rim
for _, q in ipairs{ {17, 49}, {14, 46} } do m.s[K(q[1], q[2])] = nil end
local near1 = bite:grow(1)
local near2 = bite:grow(4)

local bias = {}
m:each(function(x, y) local k = K(x, y) if T[k] > 0.94 then bias[k] = -1 end end)
local tok = { r = { name = "date" } }
local v = X.light(n, { amb = 0.06, wrap = 0.25 })
local idx = X.tone(c, m, v, DT, { cuts = { 0.3, 0.46, 0.62, 0.78, 0.93 }, bias = bias, tok = tok })

-- wrinkles: {t0, t1, s0, s1}
local strokes = {
  { 0.18, 0.5, -0.55, -0.42 }, { 0.42, 0.78, -0.3, -0.52 }, { 0.12, 0.38, 0.05, 0.12 }, { 0.34, 0.66, 0.18, 0.02 },
  { 0.6, 0.86, 0.08, 0.3 }, { 0.22, 0.48, 0.5, 0.42 }, { 0.55, 0.8, 0.55, 0.62 }, { 0.7, 0.9, -0.1, -0.32 },
}
local creases = { { 0.3, -0.7, -0.1 }, { 0.55, -0.1, 0.5 }, { 0.72, -0.55, 0.0 } }
m:each(function(x, y) local k = K(x, y)
  if near2:has(x, y) then return end
  local t, s = T[k], S[k]
  local i = idx[k]
  for _, st in ipairs(strokes) do
    if t >= st[1] and t <= st[2] then
      local sc = st[3] + (st[4] - st[3]) * (t - st[1]) / (st[2] - st[1]) + 0.05 * sin(t * 40)
      local d = (s - sc) * (hw(t) + 0.5)
      if abs(d) < 0.5 then c:put(x, y, DT[max(1, i - 2)], tok)
      elseif d <= -0.5 and d > -1.5 and i >= 3 then c:put(x, y, DT[min(6, i + 1)], tok) end
    end
  end
  for _, cr in ipairs(creases) do
    if s > cr[2] and s < cr[3] then
      local d = (t - cr[1]) * LEN + s * 1.2
      if abs(d) < 0.5 then c:put(x, y, DT[max(1, i - 1)], tok) end
    end
  end
end)
-- cool reflected light on the lower-right edge
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if S[k] > 0.8 and T[k] > 0.15 and T[k] < 0.85 and not near1:has(x, y) then c:put(x, y, BOUNCE, tok) end end)
-- specular streak along the lit shoulder + glint
for i = 0, 14 do
  local s = samp[floor((0.4 + i * 0.016) * 160) + 1]
  local x, y = floor(s.x + s.px * s.w * -0.55 + .5), floor(s.y + s.py * s.w * -0.55 + .5)
  if m:has(x, y) then c:put(x, y, i % 5 == 4 and DT[5] or DT[6], tok) end
end
do local s = samp[floor(0.5 * 160) + 1]
  local x, y = floor(s.x + s.px * s.w * -0.55 + .5), floor(s.y + s.py * s.w * -0.55 + .5)
  c:put(x, y, SPEC, tok) c:put(x + 1, y - 1, SPEC, tok) end
-- small secondary glints on wrinkle lips (glossy skin)
for _, q in ipairs{ { 0.28, -0.3 }, { 0.68, 0.0 } } do
  local s = samp[floor(q[1] * 160) + 1]
  c:put(floor(s.x + s.px * s.w * q[2] + .5), floor(s.y + s.py * s.w * q[2] + .5), DT[6], tok)
end

-- bite face: amber flesh, brightest at the bitten rim, pit ridge in the middle
local near2b = bite:grow(3)
m:each(function(x, y) local k = K(x, y)
  if near2:has(x, y) then
    local s = S[k]
    local lit = s < 0.1
    local ring = near1:has(x, y) and 1 or (near2b:has(x, y) and 2 or 3)
    if abs(s) < 0.16 and ring <= 2 then c:put(x, y, ring == 1 and PIT[3] or PIT[2], tok)
    elseif ring == 1 then c:put(x, y, lit and FL[5] or FL[4], tok)
    elseif ring == 2 then c:put(x, y, lit and FL[4] or FL[3], tok)
    else c:put(x, y, lit and FL[3] or FL[1], tok) end
  end
end)
-- fibres in the flesh


-- calyx cap at the stem end: 4 lobes, pale, AO on the fruit around it
local cx, cy = 45, 20
local cm = G.rell(cx, cy, 0.7, -0.7, 2.3, 3.6)
local cn = X.pillow(cm, 1.6)
m:each(function(x, y) if cm:grow(1):has(x, y) and not cm:has(x, y) then c:put(x, y, DT[1], tok) end end)
local ctok = { r = { name = "calyx" } }
G.toneN(c, cm, cn, CAL, { tok = ctok, cuts = { 0.3, 0.55, 0.78 }, amb = 0.15, wrap = 0.3 })
-- lobe notches
for _, q in ipairs{ { 43, 19 }, { 46, 22 }, { 44, 22 } } do if cm:has(q[1], q[2]) then c:put(q[1], q[2], CAL[1], ctok) end end
c:put(44, 18, CAL[4], ctok)

-- fruit strand: twisted, golden, out of the calyx to the upper right
local sp = { { 47, 18 }, { 50, 15 }, { 50, 11 }, { 54, 8 } }
local stm, stn, STT, STS = G.tube(sp, function(t) return 1.05 - 0.25 * t end)
stm:cut(cm)
local stok = { r = { name = "strand" } }
stm:each(function(x, y) local k = K(x, y)
  local s, t = STS[k], STT[k]
  local i = s < -0.3 and 4 or (s < 0.3 and 3 or 2)
  -- twist: diagonal dark stripe every 3 px
  if floor(t * 14 + s * 1.2) % 3 == 0 then i = max(1, i - 1) end
  c:put(x, y, STR[i], stok)
end)
-- broken end of the strand (paler cut fibres)
c:put(55, 7, STR[4], stok)

G.fin(c)
