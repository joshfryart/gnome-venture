-- ico-pumpkin (Opus single pass). An upright heirloom pumpkin, a touch taller than a squat jack-o-lantern, built
-- from five overlapping ribs painted back to front. Material: per-pixel light (rib ellipsoid + overall sphere)
-- snapped to a 6-tone orange ramp, dark grooves and AO where ribs tuck behind each other, a sunken crown dimple
-- round the stem, waxy specular on the front rib, cool violet bounce on the lower-right. Stem: ridged, twisted
-- 5 px stalk with a pale cut end; one veined lobed leaf and a curly tendril.
-- quirk: a small snail is climbing the right-hand rib.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA8_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = A.new("ico-pumpkin")
local OR = { "#5e1f33", "#9a3127", "#cf521f", "#ee7a22", "#fda640", "#ffd47a" }
local ST = { "#2e3326", "#4a5530", "#6c7a3a", "#909c4a", "#b8bf68", "#e2dc9c" }
local LF = { "#1d4a3e", "#2a6a46", "#3f8e4c", "#62ad52", "#94cc66", "#c8e48a" }
local SPEC, BOUNCE = "#fff1cf", "#a04a66"
c:groundShadow(32, 55, 19, 2)

local cx, cy = 32, 38
-- {x, rx, ry, dy}: back ribs first
local ribs = {
  { cx - 14.5, 6.5, 12.5, 1.0 }, { cx + 14.5, 6.5, 12.5, 1.0 },
  { cx - 8.5, 7.5, 14.5, 0.3 }, { cx + 8.5, 7.5, 14.5, 0.3 },
  { cx, 8.0, 15.5, 0 },
}
local gs = {}   -- overall sphere normal (squashed) for the global light
local function gnorm(x, y)
  local u, v = (x - cx) / 21.5, (y - cy) / 17.5
  return u, v, sqrt(max(0.04, 1 - u*u - v*v))
end
local own, masks = {}, {}
for i, r in ipairs(ribs) do
  local m = A.oval(r[1], cy + r[4], r[2], r[3], 0)
  masks[i] = m
  m:each(function(x, y) own[K(x, y)] = i end)
end
local all = HP.mask() for _, m in ipairs(masks) do all:add(m) end
local tok = { r = { name = "pumpkin" } }
local idx = {}
for i, r in ipairs(ribs) do
  local m = HP.mask()
  masks[i]:each(function(x, y) if own[K(x, y)] == i then m:set(x, y) end end)
  local n, bias = {}, {}
  m:each(function(x, y)
    local u = (x - r[1]) / (r[2] + 0.5)
    local v = (y - cy - r[4]) / (r[3] + 0.5)
    local rz = sqrt(max(0.05, 1 - u*u - v*v))
    local gx, gy, gz = gnorm(x, y)
    n[K(x, y)] = { A.norm(u * 0.7 + gx * 0.7, v * 0.35 + gy * 0.8, rz * 0.6 + gz) }
  end)
  -- AO + groove where a rib in front covers this one
  for j = i + 1, #ribs do
    local front = masks[j]
    m:each(function(x, y)
      local k = K(x, y)
      if front:has(x + 1, y) or front:has(x - 1, y) then bias[k] = (bias[k] or 0) - 3
      elseif front:has(x + 2, y) or front:has(x - 2, y) then bias[k] = (bias[k] or 0) - 1 end
    end)
  end
  -- crown dimple + base tuck
  m:each(function(x, y)
    local k = K(x, y)
    local d = sqrt(((x - cx) / 1.6)^2 + (y - (cy - 15.5))^2)
    if d < 2.5 then bias[k] = (bias[k] or 0) - 2 elseif d < 4.5 then bias[k] = (bias[k] or 0) - 1 end
    local e = sqrt(((x - cx) / 2.2)^2 + (y - (cy + 15.5))^2)
    if e < 3 then bias[k] = (bias[k] or 0) - 1 end
  end)
  local id = A.shade(m, n, OR, { amb = 0.1, wrap = 0.45, cuts = { 0.22, 0.38, 0.54, 0.7, 0.85 }, bias = bias, tok = tok })
  for k, v in pairs(id) do idx[k] = v end
  if i == #ribs then
    -- waxy streak down the front rib's lit flank
    for _, p in ipairs{ { cx - 4, 28 }, { cx - 5, 30 }, { cx - 5, 31 }, { cx - 5, 33 } } do c:put(p[1], p[2], OR[6], tok) end
    c:put(cx - 4, 27, SPEC, tok)
  end
end
-- lit hi flecks on each side rib's upper-left curve
for _, p in ipairs{ { cx - 12, 30 }, { cx - 12, 31 }, { cx - 18, 33 } } do c:put(p[1], p[2], OR[6], tok) end
-- faint vertical skin striations (one tone up) on the front ribs
all:each(function(x, y) local k = K(x, y) local i = idx[k]
  if i and i >= 3 and i <= 4 and X.hash(x, floor(y / 3), 3) < 0.06 then c:put(x, y, OR[i + 1], tok) end end)
A.bounce(all, (function() local nn = {} all:each(function(x, y) nn[K(x, y)] = { gnorm(x, y) } end) return nn end)(),
  BOUNCE, 0.78, function(x, y) return y > cy end)

-- leaf (behind the stem, lying on the left shoulder): three rounded lobes, midrib + veins
local leaf = A.oval(21.5, 22.5, 6.5, 3.6, -0.35):add(A.oval(17.5, 20.5, 3.2, 2.6, -0.9)):add(A.oval(23, 19.5, 3.3, 2.6, -0.1))
-- contact shadow of the leaf on the ribs
leaf:shift(1, 2):each(function(x, y) local k = K(x, y)
  if idx[k] and not leaf:has(x, y) then c:put(x, y, OR[max(1, idx[k] - 2)], tok) end end)
local ln = X.pillow(leaf, 2.5)
local ltok = { r = { name = "leaf" } }
local lid = A.shade(leaf, ln, LF, { amb = 0.1, wrap = 0.3, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = ltok })
A.ln({ { 28, 23 }, { 21, 22 }, { 16, 19 } }, LF[2], leaf, ltok)
A.ln({ { 22, 22 }, { 22, 18 } }, LF[2], leaf, ltok)
A.ln({ { 24, 22 }, { 21, 25 } }, LF[2], leaf, ltok)
A.ln({ { 27, 22 }, { 21, 21 } }, LF[5], leaf, ltok)

-- stem: ridged, slightly twisted stalk leaning right, pale cut end
local sp = { { cx, cy - 14 }, { cx + 0.5, cy - 19 }, { cx + 2, cy - 23 }, { cx + 4.5, cy - 25.5 } }
local sm, sn, T, S = A.tube(sp, function(t) return 2.9 - t * 0.7 end, 120)
local stok = { r = { name = "stem" } }
local bias = {}
sm:each(function(x, y) local k = K(x, y)
  if T[k] < 0.18 then bias[k] = -1 end
  local tw = S[k] + T[k] * 0.9          -- ridges twist along the stalk
  local f = (tw * 2.2) % 1
  if f < 0.22 and abs(S[k]) < 0.85 then bias[k] = (bias[k] or 0) - 1 end
end)
A.shade(sm, sn, ST, { amb = 0.06, wrap = 0.25, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = bias, tok = stok })
-- cut end: pale end grain disc with a darker core
local ex, ey = A.bez(sp, 1)
local cap = A.oval(ex, ey - 0.3, 2.2, 1.4, -0.6)
cap:each(function(x, y) c:put(x, y, ST[6], stok) end)
c:put(floor(ex + .5), floor(ey), ST[5], stok)
-- tendril: 2 px curl off the stem's right side
local tpts = { { 35, 19 }, { 38, 18 }, { 41, 17 }, { 43, 15 }, { 43, 13 }, { 41, 12 }, { 40, 14 } }
A.ln(tpts, LF[4], nil, ltok)
A.ln({ { 35, 20 }, { 38, 19 }, { 41, 18 }, { 44, 16 }, { 44, 14 } }, LF[2], nil, ltok)
c:put(42, 12, LF[5], ltok)

-- quirk: a snail on the right-hand rib, climbing up (shell spiral, soft body, eye stalks)
local SN = { s = "#35295f", S = "#5a459e", h = "#8a6fd0", H = "#c9b2f0", b = "#c8c0d4", B = "#ece6f2", d = "#8a84a0", k = "#2b1c26" }
A.bmp({
  "..k.k....",
  "..B.B....",
  ".BBb.sss.",
  "Bbbbshhss",
  ".bbsHsShs",
  ".bbshSshs",
  ".bdsSssss",
  ".bd.ssss.",
  ".bbd.....",
  "..bd.....",
}, 14, 37, SN)
A.done()
