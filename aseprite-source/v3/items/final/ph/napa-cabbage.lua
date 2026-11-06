-- napa-cabbage (final, Opus single pass). A tall slim napa head standing on its cut root plate: five long spoon
-- leaves wrapping a pale heart, each with a broad white rib that runs up into a crinkled, frilly green top.
-- Material: per-pixel light from a blend of the head's ellipsoid and each leaf's own curl (6-tone green, 6-tone rib
-- white), crinkle bias on the green, pale veins from the rib, a groove beside each rib, AO where leaves overlap,
-- glossy rib highlight, cream root plate with growth rings, 2-tone ground shadow.
-- quirk: a caterpillar has chewed a hole in the front-left leaf and is peeking out of it.
local NAME = "napa-cabbage"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local GR  = { "#244a36", "#3a7040", "#5c9a48", "#86bc58", "#b4d870", "#e0f09c" }
local GRI = { "#3e6234", "#5e8a3e", "#88b04c", "#b0cc62", "#d6e68a", "#f2f4bc" }
local WH  = { "#6a7656", "#949f72", "#bcc492", "#dcdfb2", "#efefd0", "#fbf8e6" }
local CXH, CYH, RXH, RYH = 32, 31, 13, 24

c:groundShadow(32, 57, 12, 1.5)

-- leaves: {base, ctrl, tip, wmax, ramp(green), inner?}
local defs = {
  { { 32, 55 }, { 32, 30 }, { 32, 8 }, 6.0, GRI },          -- heart (back)
  { { 30, 55 }, { 23, 32 }, { 25, 10 }, 5.4, GRI },          -- inner left
  { { 34, 55 }, { 41, 32 }, { 39, 10 }, 5.4, GRI },          -- inner right
  { { 31, 56 }, { 19, 38 }, { 23, 16 }, 6.2, GR },           -- outer left
  { { 33, 56 }, { 45, 38 }, { 41, 16 }, 6.2, GR },           -- outer right
}
local L = {}
for i, d in ipairs(defs) do
  local wm = d[4]
  local m, n, T, S, len = A.blade(d[1][1], d[1][2], d[2][1], d[2][2], d[3][1], d[3][2], function(t)
    if t > 0.995 then return -1 end
    local w = 2.0 + (wm - 2.0) * min(1, t / 0.72) ^ 0.8
    if t > 0.86 then w = w * sqrt(max(0, 1 - ((t - 0.86) / 0.14) ^ 2)) + 0.3 end
    return w
  end, { fold = 0 })
  -- frill: notch the green edge every other 2x2 cell
  local cut = {}
  m:edge():each(function(x, y) local k = K(x, y)
    if T[k] > 0.5 and (floor(x / 2) + floor(y / 2)) % 2 == 0 and X.hash(x, y, i) > 0.25 then cut[#cut + 1] = k end end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  L[i] = { m = m, T = T, S = S, len = len, ramp = d[5], d = d }
end
-- head normals: ellipsoid + leaf curl
for _, l in ipairs(L) do
  local n = {}
  l.m:each(function(x, y) local k = K(x, y)
    local dx, dy = (x - CXH) / (RXH + 1), (y - CYH) / (RYH + 1)
    n[k] = { A.norm(dx * 0.8 + l.S[k] * 0.5, dy * 0.45 - 0.05, 1) }
  end)
  l.n = n
end

local tok = { r = { name = "napa" } }
for i, l in ipairs(L) do
  local bias = {}
  for j = i + 1, #L do X.ao(bias, l.m, L[j].m, 1, -1) A.cast(bias, l.m, L[j].m, 1, 1, -1) end
  local v = X.light(l.n, { amb = 0.1, wrap = 0.3 })
  l.m:each(function(x, y) local k = K(x, y)
    local t, s = l.T[k], l.S[k]
    local i6 = 1
    for j, ct in ipairs(A.CUTS) do if v[k] >= ct then i6 = j + 1 end end
    i6 = i6 + (bias[k] or 0)
    local ribw = 0.62 - 0.4 * min(1, t / 0.85)
    local col
    if t < 0.24 or (abs(s) < ribw and t < 0.86) then
      -- white rib: bulges, glossy line on the lit side, groove at its edge
      local j = i6 + 1
      if abs(s) > ribw - 0.14 and t >= 0.24 then j = j - 2 end
      if s < -ribw * 0.3 and s > -ribw * 0.7 and t > 0.3 and t < 0.75 and j >= 5 then j = 6 end
      if t < 0.06 then j = j - 1 end
      col = WH[max(1, min(6, j))]
    else
      local j = i6
      local hh = X.hash(floor(x / 2), floor(y / 2), 11 + i)
      if hh > 0.78 then j = j - 1 elseif hh < 0.16 then j = j + 1 end
      -- veins sweeping up from the rib
      local ph = (t * l.len - abs(s) * 5.0) / 3.4
      local f = ph - floor(ph)
      if f < 0.2 and abs(s) < 0.85 then j = (s < 0) and j + 1 or j - 1 end
      col = l.ramp[max(1, min(6, j))]
    end
    c:put(x, y, col, tok)
  end)
end

-- root plate
local plate = HP.ellipse(32, 56, 5.5, 1.6)
plate:each(function(x, y)
  local r = sqrt(((x - 32) / 5.5) ^ 2 + ((y - 56) / 1.6) ^ 2)
  c:put(x, y, (r < 0.35) and "#d8c68e" or ((r < 0.75) and "#f2e6b8" or "#c8b47c"), tok)
end)
c:put(30, 55, WH[2], tok) c:put(34, 55, WH[2], tok)

-- one bright glint on the front-right rib
c:put(39, 27, A.CREAM, tok)

-- quirk: chewed hole with a peeking caterpillar on the outer left leaf
local hx, hy = 22, 30
for _, q in ipairs{ { 0, 0 }, { 1, 0 }, { 2, 0 }, { 0, 1 }, { 1, 1 }, { 2, 1 }, { 1, -1 } } do c:put(hx + q[1], hy + q[2], "#1c3428", tok) end
c:put(hx - 1, hy, GR[2], tok) c:put(hx + 3, hy + 1, GR[5], tok) c:put(hx + 1, hy + 2, GR[5], tok)
-- caterpillar head (bright lime) with an eye, body segment behind
c:put(hx + 1, hy, "#c8ec5a", tok) c:put(hx + 2, hy, "#a8d040", tok)
c:put(hx + 1, hy + 1, "#86b030", tok) c:put(hx + 2, hy + 1, "#2b1c26", tok)
c:put(hx + 1, hy - 1, "#e8f890", tok)

A.save(c, NAME)
