-- ico-chili (final pass, Opus). A slim, glossy red chili hanging in a long hook: rounded shoulder under a frilled
-- green calyx, tapering to a fine curled tip. Bold enough for 16 px.
-- Material: per-pixel cylinder light (6-tone red, cool-violet shade), one lengthwise lobe crease, waxy specular
-- streak on the lit shoulder + one cream glint, cool reflected light lower-right, AO ring under the calyx.
-- Calyx: 6-tone moss pillow with drooping sepals; stem: 3 px bent woody-green stalk with a pale cut end.
-- quirk: the tip is so hot it has lit a tiny flame.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA2_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt = math.floor, math.max, math.min, math.sqrt
local c = A.new("ico-chili")
local RED  = { "#5a1a32", "#8c2238", "#c02f35", "#e5483a", "#fb7650", "#ffb184" }
local LEAF = { "#183f36", "#22593f", "#2f7747", "#47964d", "#6db556", "#a3d270" }
local STEM = { "#24503c", "#3f7a48", "#68a456", "#c7df8e" }
local SPEC, BOUNCE = "#fff1cf", "#9e4766"
local rt, lt = A.tok("chili"), A.tok("leaf")

-- body
local p = { { 19, 21 }, { 40, 15 }, { 52, 36 }, { 37, 52 } }
local function hw(t)
  if t < 0.06 then return 5.2 + (t / 0.06) * 1.2 end
  return 6.4 * ((1 - t) / 0.94) ^ 0.85 + 0.6
end
local m, n, T, S, samp = A.tube(p, hw)
local bias = {}
m:each(function(x, y) local k = K(x, y) if T[k] < 0.05 then bias[k] = -1 end end)
local idx = A.shade(c, m, n, RED, { amb = 0.02, wrap = 0.08, cuts = { 0.2, 0.4, 0.58, 0.75, 0.91 }, bias = bias, tok = rt })
-- lobe crease: a dark groove a little past the centre line, lit lip above it
m:each(function(x, y) local k = K(x, y)
  local t, s = T[k], S[k]
  if t > 0.1 and t < 0.72 then
    local target = 0.28 - t * 0.12
    if math.abs(s - target) < 0.12 then A.step(c, idx, RED, x, y, -1, rt) end
  end
end)
-- cool reflected light on the lower-right edge
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.62 and S[k] > 0.75 and T[k] > 0.16 and T[k] < 0.82 then c:put(x, y, BOUNCE, rt) end end)
-- waxy specular streak along the lit shoulder, then one glint
local function at(t, s)
  local q = samp[floor(t * 160) + 1]
  return floor(q.x + q.px * q.w * s + .5), floor(q.y + q.py * q.w * s + .5)
end
for i = 0, 14 do local t = 0.1 + i * 0.022 local x, y = at(t, -0.52) c:put(x, y, RED[6], rt) end
for i = 0, 5 do local t = 0.5 + i * 0.03 local x, y = at(t, -0.5) c:put(x, y, RED[5], rt) end
do local x, y = at(0.15, -0.55) c:put(x, y, SPEC, rt) c:put(x + 1, y, SPEC, rt) end

-- calyx: frilled cap over the shoulder, sepals drooping down onto the body
local sepals = {
  { { 20, 15.5 }, { 28, 17 }, { 22.5, 19.8 } },
  { { 22, 19 }, { 29.5, 21.5 }, { 22, 24 } },
  { { 21.5, 23.2 }, { 27.5, 26.8 }, { 19.5, 27 } },
}
local cal = HP.mask()
local sm = {}
for i, q in ipairs(sepals) do
  local sp = c:poly(q)
  sm[i] = sp
  local sn = X.pillow(sp, 1.6)
  local sb = {}
  -- lit midrib from the cap out to the tip
  for j = 0, 8 do local f = j / 8
    local x = floor(q[1][1] + (q[3][1] - q[1][1]) * 0.5 + (q[2][1] - (q[1][1] + q[3][1]) / 2) * f * 0.85 + .5)
    local y = floor(q[1][2] + (q[3][2] - q[1][2]) * 0.5 + (q[2][2] - (q[1][2] + q[3][2]) / 2) * f * 0.85 + .5)
    sb[K(x, y)] = 1 end
  A.shade(c, sp, sn, LEAF, { amb = 0.1, wrap = 0.3, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, bias = sb, tok = lt })
  -- dark separation where this sepal overlaps the previous one
  if i > 1 then sp:each(function(x, y) if sm[i - 1]:has(x, y - 1) and not sp:has(x, y - 1) then c:put(x, y, LEAF[1], lt) end end) end
  cal:add(sp)
end
-- round cap (the stem end of the pod) seen end-on
local cap = A.ell(19.5, 21, 3.4, 5.6)
local cn = X.pillow(cap, 2.6)
local cidx = A.shade(c, cap, cn, LEAF, { amb = 0.08, wrap = 0.3, cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, tok = lt })
cap:each(function(x, y) if not cap:has(x + 1, y) and not cal:has(x + 1, y) then end end)
cal:add(cap)
-- recessed cap face where the stem sits
for _, q in ipairs{ { 18, 19 }, { 18, 20 }, { 19, 20 }, { 18, 21 }, { 19, 21 } } do c:put(q[1], q[2], LEAF[2], lt) end
-- AO on the body just below the calyx rim
cal:grow(1):cut(cal):each(function(x, y) if m:has(x, y) then A.step(c, idx, RED, x, y, -2, rt) end end)
c:put(17, 17, LEAF[6], lt) c:put(17, 18, LEAF[5], lt)

-- stem: 3 px bent stalk rising up-left, pale cut end
local stem = A.stroke({ { 18, 20 }, { 14, 16 }, { 13, 11 }, { 16, 7.5 } }, 1.5)
stem:cut(cal)
stem:each(function(x, y)
  local lit = stem:has(x + 1, y) and not stem:has(x - 1, y) or (not stem:has(x, y - 1))
  local dark = not stem:has(x + 1, y) or not stem:has(x, y + 1)
  c:put(x, y, lit and STEM[3] or (dark and STEM[1] or STEM[2]), lt)
end)
c:put(17, 6, STEM[4], lt) c:put(17, 7, STEM[4], lt)
-- AO where stem enters calyx
c:put(16, 17, LEAF[1], lt)

-- quirk: a tiny flame on the curled tip
local tx, ty = at(1, 0)
A.map(c, {
  "..y.",
  ".yo.",
  ".yoO",
  "yoOr",
  ".Or.",
}, tx - 3, ty - 6, { y = "#ffe38a", o = "#f5b82e", O = "#f08a2a", r = "#d9502f" }, A.tok("flame"))
A.save(c, "ico-chili")
