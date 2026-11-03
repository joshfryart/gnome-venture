-- ico-candy (final, Opus). A wrapped bonbon tilted a little uphill: glossy pink hard candy with cream swirl stripes,
-- twisted necks, and crinkly mint cellophane fans either side. Material: body = per-pixel ellipsoid light (6-tone
-- pink, violet shade) with spiral stripes in their own 4-tone cream, a bright specular streak + glint and a cool
-- reflected light lower-right; necks = twist ridges (alternating diagonal tones) with AO where they pinch the body;
-- fans = pleated cellophane (radiating folds, a bright rim on each fold crest) and a crinkled zigzag edge.
-- quirk: a tiny ant has found it and is marching across the candy.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA2_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = A.new("ico-candy")
local PINK  = { "#5c1f4a", "#94306a", "#c94f84", "#ec6f98", "#ff9cbc", "#ffd0de" }
local CRM   = { "#a87a86", "#dcbcbc", "#f6e4d0", "#fff4e2" }
local MINT  = { "#1f4a5c", "#2f7684", "#45a7a8", "#6fd0c4", "#a8eedc", "#e0fff4" }
local SPEC, BOUNCE = "#fff6ec", "#9a7ad0"

local CX, CY, ANG = 32, 32, -0.32
local ux, uy = cos(ANG), sin(ANG)
local function loc(x, y) local dx, dy = x - CX, y - CY return dx * ux + dy * uy, -dx * uy + dy * ux end
local RX, RY = 11.8, 9.4
local NK0, NK1, F1 = 10.8, 14.0, 25.4

-- fans + necks first (body paints over the inner ends)
local fan, neck = HP.mask(), HP.mask()
local FT, FS = {}, {}
for y = 0, 63 do for x = 0, 63 do
  local t, s = loc(x, y)
  local at = abs(t)
  if at >= NK0 and at < NK1 + 0.6 and abs(s) <= 2.9 - (at - NK0) * 0.2 then neck:set(x, y) end
  if at >= NK1 then
    local half = 2.0 + (at - NK1) * 1.0
    local zig = ((floor((s + 20) / 2.0)) % 2 == 0) and 0 or 0.9
    if abs(s) <= half and at <= F1 - zig - abs(s) * 0.12 then fan:set(x, y) FT[K(x, y)] = t FS[K(x, y)] = s end
  end
end end
local ftok = A.tok("fan")
local fv = {}
fan:each(function(x, y) local k = K(x, y) local t, s = FT[k], FS[k]
  local at = abs(t)
  local phi = s / (at - NK1 + 3)
  local pleat = cos(phi * 9.5)
  local v = 0.62 + 0.26 * pleat - 0.32 * (s / (2.0 + (at - NK1) * 1.0)) - (t > 0 and 0.12 or 0)
  if at < NK1 + 2 then v = v - 0.25 end
  fv[k] = v
end)
local fidx = X.tone(c, fan, fv, MINT, { cuts = { 0.12, 0.3, 0.48, 0.66, 0.84 }, tok = ftok })
-- fold crest rim: brightest tone on the outer crinkle where a crest meets the edge
fan:edge():each(function(x, y) local k = K(x, y) if abs(FT[k]) > NK1 + 4 and fidx[k] >= 4 then A.set(c, fidx, MINT, x, y, 6, ftok) end end)
-- necks: twist ridges
local ntok = A.tok("neck")
neck:each(function(x, y) local t, s = loc(x, y)
  local r = floor(t * 1.0 + s * 0.9) % 3
  local i = (r == 0) and 2 or ((r == 1) and 4 or 5)
  if s > 0.8 then i = i - 1 end
  if abs(t) < NK0 + 1.2 then i = 1 end
  c:put(x, y, MINT[max(1, i)], ntok)
end)

-- body
local body = HP.mask()
local bn, BT, BS = {}, {}, {}
for y = 0, 63 do for x = 0, 63 do
  local t, s = loc(x, y)
  local a, b = t / (RX + 0.4), s / (RY + 0.4)
  local q = a * a + b * b
  if q <= 1 then
    body:set(x, y)
    local k = K(x, y)
    local nt, ns, nz = a / RX * 1.6, b / RY * 1.6, sqrt(max(0.03, 1 - q)) / ((RX + RY) / 2) * 1.6
    local wx, wy = nt * ux - ns * uy, nt * uy + ns * ux
    bn[k] = { A.norm(wx, wy, nz) }
    BT[k], BS[k] = a, b
  end
end end
local btok = A.tok("candy")
local bias = {}
-- AO where the body pinches into the necks
body:each(function(x, y) local k = K(x, y) if abs(BT[k]) > 0.88 and abs(BS[k]) < 0.45 then bias[k] = -1 end end)
local v = X.light(bn, { amb = 0.06, wrap = 0.28 })
local idx = X.tone(c, body, v, PINK, { cuts = { 0.16, 0.32, 0.5, 0.68, 0.85 }, bias = bias, tok = btok })
-- swirl stripes: bands across the body that bow with the curvature (spiral read)
local stok = A.tok("stripe")
body:each(function(x, y) local k = K(x, y) local a, b = BT[k], BS[k]
  local ph = a * 2.6 + b * 1.05 + b * b * 0.55
  local f = ph - floor(ph)
  if f < 0.34 then
    local i = idx[k]
    local j = (i >= 5) and 4 or ((i >= 4) and 3 or ((i >= 2) and 2 or 1))
    if bias[k] then j = max(1, j - 1) end
    c:put(x, y, CRM[j], stok)
  end
end)
-- cool bounce light lower-right
local rim = X.rim(bn)
body:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.78 and BS[k] > 0.45 and abs(BT[k]) < 0.75 then c:put(x, y, BOUNCE, btok) end end)
-- glossy specular streak along the upper-left shoulder + glint
for i = 0, 6 do
  local t, s = -5.6 + i * 1.1, -5.6 - (i - 3) ^ 2 * 0.08
  local x, y = floor(CX + t * ux - s * uy + 0.5), floor(CY + t * uy + s * ux + 0.5)
  c:put(x, y, (i == 2 or i == 3) and SPEC or PINK[6], btok)
end
do local t, s = 1.8, -6.6
  local x, y = floor(CX + t * ux - s * uy + 0.5), floor(CY + t * uy + s * ux + 0.5)
  c:put(x, y, PINK[6], btok) end

-- quirk: a tiny ant has found the candy and is marching across it (dark on the pink so it reads)
A.map(c, {
  "k..........",
  ".hh..k..GG.",
  "hghTTTTGgGG",
  ".hh.TT.GGGG",
  "..k.k.k.GG.",
}, 24, 29, { k = A.INK, h = "#3a1a26", T = "#4a2232", G = "#3a1a26", g = "#c88aa0" }, A.tok("ant"))
A.save(c, "ico-candy")
