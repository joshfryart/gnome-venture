-- ico-potato (Opus single pass). A slim, lumpy russet tuber lying on the diagonal (knobbly end upper-right),
-- 41x24 so it reads as a long potato, not a ball. Material: per-pixel pillow light snapped to a 6-tone russet ramp,
-- netted skin (sparse lenticel freckles), sunken eyes (dark pit, shaded brow, lit lower lip), a waxy specular on the
-- shoulder, cool violet reflected light lower-right, AO in the waist where the knob joins the body, soil smudges.
-- quirk: one eye has sprouted: a stubby lilac shoot with two tiny green leaves curls up from the knob.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt = math.floor, math.max, math.min, math.sqrt
local c = A.new("ico-potato")
local SK = { "#4a2630", "#7a4436", "#a8683e", "#c98f52", "#e2b46c", "#f4d898" }
local SPEC, BOUNCE = "#fff1cf", "#8e5a78"
local SOIL = { "#5a3a2e", "#7a5238" }
local SPR = { "#6e3f62", "#a8749a", "#dcb0c8", "#f4dce6" }
local LF = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }

-- body: long oval + a smaller knob on the upper-right end, waist pinched slightly
local ang = -0.36
local m1, n1 = A.oval(30, 35, 17.5, 12.0, ang)
local m2, n2 = A.oval(43.5, 29.0, 8.5, 9.0, ang)
local m3, n3 = A.oval(17, 40, 7.5, 8.5, ang)   -- rounder heel so the low end is not a point
local body = m1:copy():add(m2):add(m3)
-- ellipsoid normals (main body wins), blended with a soft pillow so the lobes join without a crease
local np = X.pillow(body, 6, 1.0)
local n = {}
body:each(function(x, y) local k = K(x, y)
  local a = n1[k] or n2[k] or n3[k]
  if n1[k] and n2[k] then a = { (n1[k][1] + n2[k][1]) / 2, (n1[k][2] + n2[k][2]) / 2, (n1[k][3] + n2[k][3]) / 2 } end
  local b = np[k]
  n[k] = { A.norm(a[1] * 0.75 + b[1] * 0.25, a[2] * 0.75 + b[2] * 0.25, a[3] * 0.75 + b[3] * 0.25) }
end)
local bias = {}
-- AO waist: pixels near the seam where knob meets body, on the lower (shade) side
local wx, wy = 39, 33.5
body:each(function(x, y)
  local d = sqrt((x - wx)^2 + (y - wy)^2)
  if d < 3.2 and (x - wx) * 0.4 + (y - wy) > -0.5 then bias[K(x, y)] = -1 end
end)
local tok = { r = { name = "potato" } }
local idx = A.shade(body, n, SK, { amb = 0.03, wrap = 0.2, cuts = { 0.24, 0.42, 0.58, 0.72, 0.87 }, bias = bias, tok = tok })

-- netted skin: sparse freckles one step darker, a few one step lighter on the lit half
body:shrink(1):each(function(x, y)
  local k = K(x, y) local i = idx[k]
  local h = X.hash(x, y, 7)
  if h < 0.07 and i > 2 then c:put(x, y, SK[i - 1], tok)
  elseif h > 0.95 and i >= 3 and i < 6 then c:put(x, y, SK[i + 1], tok) end
end)
-- soil smudges on the lower body (2-3 px patches)
for _, p in ipairs{ { 22, 47 }, { 23, 47 }, { 23, 46 }, { 31, 44 }, { 32, 44 }, { 14, 45 } } do
  if body:has(p[1], p[2]) then c:put(p[1], p[2], (idx[K(p[1], p[2])] or 3) >= 3 and SOIL[2] or SOIL[1], tok) end
end
-- eyes: dark pit, darker brow above-left, lit lip lower-right
local function eye(x, y, long)
  local i = idx[K(x, y)] or 3
  c:put(x, y, SK[1], tok)
  if long then c:put(x + 1, y, SK[1], tok) end
  c:put(x - 1, y - 1, SK[max(1, i - 2)], tok) c:put(x, y - 1, SK[max(1, i - 2)], tok) c:put(x - 1, y, SK[max(1, i - 1)], tok)
  local e = long and 2 or 1
  c:put(x + e - 1, y + 1, SK[min(6, i + 1)], tok) c:put(x + e, y + 1, SK[min(6, i + 1)], tok)
end
eye(18, 36, true) eye(27, 29, false) eye(33, 40, true) eye(24, 43, false) eye(41, 35, false) eye(36, 30, false)

-- specular: waxy shoulder glint + 2x1 hi beside it
c:put(20, 30, SPEC, tok) c:put(21, 30, SPEC, tok) c:put(22, 29, SK[6], tok) c:put(19, 31, SK[6], tok) c:put(23, 29, SK[6], tok)
-- cool reflected light along the lower-right rim
A.bounce(body, n, BOUNCE, 0.7, function(x, y) return y > 30 end)

-- quirk: sprouting eye on the knob, shoot curling up and right, two leaflets
local ex, ey = 46, 22
c:put(ex - 1, ey + 1, SK[1], tok) c:put(ex, ey + 1, SK[2], tok)
local sp = { { ex, ey + 1 }, { ex + 0.5, ey - 2 }, { ex + 2, ey - 4 }, { ex + 4, ey - 4.5 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return 1.55 - t * 0.35 end, 80)
local stok = { r = { name = "sprout" } }
A.shade(sm, sn, SPR, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- leaflets at the tip: two rounded, veined 4-5 px leaves so they survive 16 px
A.bmp({
  "..lLL.",
  ".lLLLd",
  "lLdLd.",
  "Ldd...",
}, ex + 4, ey - 9, { l = LF[4], L = LF[3], d = LF[2] }, stok)
A.bmp({
  "LLl.",
  "LLLl",
  ".dLL",
  "..dd",
}, ex - 1, ey - 9, { l = LF[4], L = LF[3], d = LF[2] }, stok)
c:put(ex + 3, ey - 5, LF[1], stok)
-- AO where the shoot leaves the skin
for _, p in ipairs{ { ex - 2, ey + 2 }, { ex + 1, ey + 2 }, { ex + 2, ey + 1 } } do
  if body:has(p[1], p[2]) then c:put(p[1], p[2], SK[max(1, (idx[K(p[1], p[2])] or 3) - 1)], tok) end end
A.done()
