-- ant-chitin (final pass, Opus single pass). One shed ant shield: a slim, slightly tilted, chamfered (hexagon-hint)
-- armour plate made of three overlapping tergites, each tucked under the lip of the one above.
-- Material: height-field light (6-tone iridescent violet chitin), a raised mid keel, rolled lit lips with a dark
-- ambient step where each plate slides under the next, fine punctures (pit + lit lower rim), glossy specular streaks
-- along the upper-left of every tergite + one cream glint, cool teal iridescent reflected light lower-right,
-- a thin translucent amber margin along the lit edge.
-- quirk: a tiny red ant peeks over the top edge, gripping the shield with both hands (somebody wants it back).
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, cos, sin = math.floor, math.sqrt, math.max, math.min, math.abs, math.cos, math.sin
local c = A.new("ant-chitin")
local CH    = { "#261b3c", "#3a2b5c", "#523e84", "#6d56aa", "#9278ce", "#c2acee" }
local AMBER = { "#8a4a3a", "#c27a4a", "#e6a85e" }
local TEAL, SPEC = "#4fb3b8", "#fff4d6"
local ANT   = { "#5e1e2a", "#9a2e30", "#d24a3a", "#f27a5a" }
local tok = { r = { name = "chitin" } }

local CX, CY, L, W = 31.5, 33, 21.5, 11.5
local ang = 0.22                      -- top leans right
local ca, sa = cos(ang), sin(ang)
local function loc(x, y)              -- -> u across, v along (-1 top .. 1 bottom)
  local dx, dy = x - CX, y - CY
  return dx * ca + dy * sa, (-dx * sa + dy * ca) / L
end
local function wid(v) return W * min(1, (1 - abs(v)) * 1.9) ^ 0.62 end
local SEG = { -1, -0.34, 0.24, 1 }
local function segOf(v) for i = 1, 3 do if v < SEG[i + 1] then return i, (v - SEG[i]) / (SEG[i + 1] - SEG[i]) end end return 3, 1 end
local function H(x, y)
  local u, v = loc(x, y)
  if abs(v) >= 1 then return 0 end
  local w = wid(v)
  if abs(u) >= w then return 0 end
  local cu = sqrt(1 - (u / w)^2)
  local h = cu ^ 0.8 * 7.5 + 0.5 * max(0, 1 - abs(u) / 1.3)                 -- dome + keel
  local s, q = segOf(v - 0.13 * cu * cu)
  local lip = s < 3 and (q < 0.8 and q / 0.8 * 2.2 or 2.2 - (q - 0.8) / 0.2 * 1.0) or 0  -- slope up to a rolled lip
  return h + lip * cu + 0.3
end
local m, n = A.hfield(H, 8, 8, 56, 58, 1.0)
local bias, SG, Q = {}, {}, {}
m:each(function(x, y) local k = K(x, y)
  local u, v = loc(x, y)
  local cu = sqrt(max(0, 1 - (u / wid(v))^2))
  local s, q = segOf(v - 0.13 * cu * cu)
  SG[k], Q[k] = s, q
  if s > 1 and q < 0.12 then bias[k] = -1 end                         -- ambient under the lip above
end)
local idx = A.shade(c, m, n, CH, { tok = tok, bias = bias, amb = 0.05, wrap = 0.35, cuts = { 0.2, 0.36, 0.52, 0.7, 0.87 } })
-- dark step row directly under each lip
m:each(function(x, y) local k = K(x, y)
  local kk = K(x, y - 1)
  if SG[kk] and SG[kk] < SG[k] then c:put(x, y, CH[1], tok) idx[k] = 1
    if m:has(x, y - 1) then A.step(c, idx, CH, x, y - 1, 1, tok) end end
end)
-- fine punctures: pit + lit lower rim
m:each(function(x, y) local k = K(x, y)
  local i = idx[k]
  if i >= 3 and i <= 5 and X.hash(x, y, 21) < 0.04 and Q[k] > 0.2 and Q[k] < 0.75 and m:has(x + 1, y + 1) then
    c:put(x, y, CH[max(1, i - 2)], tok) A.step(c, idx, CH, x + 1, y + 1, 1, tok) end end)
-- glossy streaks on the upper-left of each tergite + glint
local e = m:edge()
for s = 1, 3 do
  m:each(function(x, y) local k = K(x, y)
    if SG[k] == s then local u, v = loc(x, y)
      local w = wid(v)
      local r = u / w
      if r > -0.62 and r < -0.42 and Q[k] > 0.25 and Q[k] < (s == 3 and 0.55 or 0.78) then c:put(x, y, CH[6], tok) end
    end end)
end
-- iridescent teal bounce on the lower-right rim, amber translucent margin on the lit rim
local rim = X.rim(n)
e:each(function(x, y) local k = K(x, y)
  local u = loc(x, y)
  if u > 0 and rim[k] > 0.5 and SG[k] >= 2 then c:put(x, y, TEAL, tok)
  elseif u < -2 and Q[k] > 0.15 and (idx[k] or 0) >= 4 then c:put(x, y, AMBER[3], tok) end end)
do -- glint on the top tergite
  local gx, gy
  m:each(function(x, y) local k = K(x, y) if SG[k] == 1 and CH[6] == c:get(x, y) and (not gx or y < gy) then gx, gy = x, y end end)
  if gx then c:put(gx, gy + 1, SPEC, tok) c:put(gx, gy + 2, SPEC, tok) end
end

-- quirk: a little red ant peeks over the top right shoulder, two hands gripping the rim
local atok = { r = { name = "ant" } }
local ax, ay = 34, 5
A.map(c, {
  "a.......a",
  ".a.....a.",
  "..a...a..",
  "..HHHHH..",
  ".HhRRRRH.",
  ".RceRceR.",
  ".rRRRRrd.",
  "gg.rdr.gg",
}, ax, ay, { a = ANT[1], H = ANT[2], h = ANT[4], R = ANT[3], r = ANT[2], d = ANT[1], e = A.INK, c = A.CREAM, g = ANT[3] }, atok)

A.save(c, "ant-chitin")
