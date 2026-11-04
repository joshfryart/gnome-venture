-- ginger (final pass, Opus single pass). A knobbly "hand" of fresh ginger lying on the diagonal: a slim main
-- rhizome with branching fingers, each lobe a separate ellipsoid; height-field union gives dark creases where they meet.
-- Material: 6-tone papery tan skin (violet shade), raised ring nodes (groove + lit lip), pink fresh bud tips,
-- one waxy specular, cool bounce lower-right; pale yellow fibrous flesh on the cut end; a thin green shoot.
-- quirk: the new shoot curls over at the top like a question mark.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, cos, sin = math.floor, math.max, math.min, math.abs, math.sqrt, math.cos, math.sin
local c = A.new("ginger")
local SKIN  = { "#4c2a34", "#7a4838", "#aa7048", "#d09a60", "#eac08a", "#fbe3b4" }
local PINK  = { "#8a3a52", "#c45a72", "#ee8fa0", "#ffc4cc" }
local FLESH = { "#b8862c", "#e0b84a", "#f6dc7c", "#fff0b4" }
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local SPEC, BOUNCE = "#fff4d6", "#9a6a86"

-- lobes: cx, cy, rx, ry, angle, rings(u positions), bud(1 = pink tip at +u end)
local L = {
  { 21, 42, 9.5, 5.2, -0.32, { -0.3, 0.25 }, 0 },
  { 34, 38, 7.5, 4.6, -0.36, { 0.1 }, 0 },
  { 27, 32, 5.2, 3.3, -1.15, { -0.1 }, 1 },
  { 44, 32.5, 7, 3.8, -0.62, { -0.2, 0.35 }, 0 },
  { 40, 44, 4.2, 3, 0.45, {}, 1 },
  { 51.5, 26.5, 3.6, 2.6, -0.8, {}, 1 },
}
local m, n, U, V, LI, H2 = HP.mask(), {}, {}, {}, {}, {}
for li, l in ipairs(L) do
  local cx, cy, rx, ry, a = l[1], l[2], l[3], l[4], l[5]
  local ca, sa = cos(a), sin(a)
  for y = floor(cy - 11), floor(cy + 11) do for x = floor(cx - 11), floor(cx + 11) do
    local dx, dy = x - cx, y - cy
    local u = (dx * ca + dy * sa) / (rx + 0.45)
    local v = (-dx * sa + dy * ca) / (ry + 0.45)
    local q = u * u + v * v
    if q <= 1 then
      local h = sqrt(1 - q) * ry
      local k = K(x, y)
      if not LI[k] or h > H2[k][1] then
        H2[k] = { h, H2[k] and H2[k][1] or 0 }
        local a2, b2 = u / (rx + .45), v / (ry + .45)
        n[k] = { A.norm(a2 * ca - b2 * sa, a2 * sa + b2 * ca, sqrt(max(1 - q, 0.03)) / ((rx + ry) / 2) * 1.1) }
        LI[k], U[k], V[k] = li, u, v
      elseif h > H2[k][2] then H2[k][2] = h end
      m:set(x, y)
    end
  end end
end
-- cut end: flat on the left of lobe 1
local cut = c:rect(0, 0, 12, 63)
m:cut(cut)
local bias = {}
m:each(function(x, y) local k = K(x, y)
  if H2[k] and H2[k][2] > 0 and H2[k][1] - H2[k][2] < 1.3 then bias[k] = -2 end end)
local tok = { r = { name = "skin" } }
local idx = A.shade(c, m, n, SKIN, { amb = 0.08, wrap = 0.25, bias = bias, tok = tok })
-- ring nodes (groove with a lit lip toward the light) + faint papery speckle
m:each(function(x, y) local k = K(x, y) local l = L[LI[k]]
  for _, r in ipairs(l[6]) do
    local d = U[k] - r
    if abs(d) < 0.055 and abs(V[k]) < 0.85 then A.step(c, idx, SKIN, x, y, -2, tok)
    elseif d < -0.055 and d > -0.16 and abs(V[k]) < 0.7 and idx[k] >= 3 then A.step(c, idx, SKIN, x, y, 1, tok) end
  end
  if X.hash(x, y, 7) > 0.93 and idx[k] >= 3 and idx[k] <= 5 then A.step(c, idx, SKIN, x, y, -1, tok) end
end)
-- pink fresh bud tips on the +u end of flagged lobes
local ptok = { r = { name = "bud" } }
m:each(function(x, y) local k = K(x, y) local l = L[LI[k]]
  if l[7] == 1 and U[k] > 0.62 then
    local i = idx[k] >= 5 and 4 or idx[k] >= 4 and 3 or idx[k] >= 2 and 2 or 1
    if U[k] < 0.72 then i = max(1, i - 1) end
    c:put(x, y, PINK[i], ptok)
  end end)
-- cool bounce on the lower-right edge of the main lobes
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.72 and (LI[k] == 1 or LI[k] == 2 or LI[k] == 5) then c:put(x, y, BOUNCE, tok) end end)
-- cut face: pale fibrous flesh disc with a darker skin ring and fibre dots
local ftok = { r = { name = "flesh" } }
local face = c:ellipse(13, 43.5, 2, 4.6)
local fe = face:edge()
face:each(function(x, y)
  local i = 3
  if fe:has(x, y) then i = (y < 43) and 2 or 1 end
  if not fe:has(x, y) and x <= 12 and y <= 42 then i = 4 end
  if not fe:has(x, y) and X.hash(x, y, 11) > 0.7 then i = 2 end
  c:put(x, y, FLESH[i], ftok)
end)
-- waxy specular on the main lobe
c:put(17, 38, SKIN[6], tok) c:put(18, 38, SPEC, tok) c:put(19, 38, SKIN[6], tok)

-- shoot: thin stalk up from the top finger, lance leaf, curled tip (quirk)
local ltok = { r = { name = "shoot" } }
local stalk = { { 29, 29 }, { 29, 28 }, { 30, 27 }, { 30, 26 }, { 30, 25 }, { 31, 24 }, { 31, 23 }, { 31, 22 }, { 31, 21 }, { 31, 20 }, { 31, 19 }, { 31, 18 }, { 31, 17 } }
for i, p in ipairs(stalk) do c:put(p[1], p[2], i < 4 and LEAF[3] or LEAF[4], ltok) if i < 8 then c:put(p[1] + 1, p[2], LEAF[2], ltok) end end
-- sheath bump where the shoot leaves the rhizome (AO ring)
c:put(28, 29, PINK[2], ptok) c:put(30, 29, PINK[1], ptok)
-- lance leaf angled up-left from the stalk
A.leaf(c, 31, 24, 25, 17, 19, 12, 2.4, LEAF, { tok = ltok, vs = 3 })
-- curled tip: question-mark curl
local curl = { { 31, 16 }, { 31, 15 }, { 32, 14 }, { 33, 14 }, { 34, 15 }, { 34, 16 }, { 33, 17 } }
for i, p in ipairs(curl) do c:put(p[1], p[2], i < 4 and LEAF[5] or LEAF[3], ltok) end
A.save(c, "ginger")
