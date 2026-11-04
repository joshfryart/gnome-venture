-- sea-grape-sorbet (final, single pass by artist aD14_5). A slim tulip glass on a thin stem and round foot, filled with
-- sorbet that shows through the glass; three frosty violet scoops (ruffled skirts, ice-crystal flecks, a curl line,
-- one specular each) are stacked above the lip. Garnish: a round, leathery sea-grape leaf with red veins tucked
-- behind on the right, and a sprig of three wine-purple sea grapes on a red stalk hanging over the left lip.
-- Glass: pale rim, bright left streak, deep-blue shade side, cool bounce; foot has a ground shadow.
-- quirk: the sorbet is melting, a violet drip runs down the glass with a bead falling off it.
local NAME = "sea-grape-sorbet"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_5.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, max, min, sqrt, sin, cos, pi = math.floor, math.abs, math.max, math.min, math.sqrt, math.sin, math.cos, math.pi
local c = G.new2(NAME)
local GLS = { "#25446e", "#3a76a6", "#6eb4d0", "#a6e2e2", "#d6f6f0", "#f6fffb" }
local SOR = { "#3a2468", "#5f3b92", "#8860bc", "#aa86d6", "#cbb0ec", "#efe2fb" }
local GRP = { "#2a1034", "#4b1c52", "#78307a", "#a5509a", "#d081bc", "#f4bde4" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local RED = { "#7a2438", "#b5394a", "#e86a5a" }
local STALK = { "#6a2236", "#a2332e", "#d0562e" }

c:groundShadow(32, 59, 12, 2)
-- leaf behind: round, notch at base, red veins fan from the base
local lcx, lcy, lr = 46, 17, 8.2
local lm = c:ellipse(lcx, lcy, lr, lr - 0.4)
lm:cut(HP.poly({ { lcx - 1, lcy + lr + 1 }, { lcx, lcy + lr - 3 }, { lcx + 1, lcy + lr + 1 } }))
local ln = X.sphere(lcx - 1, lcy - 1, lr + 1, lm)
local ltok = { r = { name = "leaf" } }
-- tilt the whole leaf with a fold normal
lm:each(function(x, y) local k = K(x, y) local nn = ln[k] nn[1] = nn[1] * 0.6 - 0.15 nn[3] = nn[3] * 1.2 end)
G.toneN(c, lm, ln, LEAF, { tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.2, wrap = 0.3 })
local bx0, by0 = lcx - 1, lcy + lr - 1
for _, a in ipairs{ -1.25, -0.8, -0.4, 0, 0.4, 0.8, 1.25 } do
  local ex, ey = bx0 + sin(a) * (lr + 0.5), by0 - cos(a) * (lr * 1.9)
  local mx = abs(a) < 0.1 and 3 or 2
  local pts = {}
  for s = 0, 1, 0.04 do
    local x, y = floor(bx0 + (ex - bx0) * s + 0.5), floor(by0 + (ey - by0) * s + 0.5)
    if lm:has(x, y) and s > 0.04 and s < (abs(a) < 0.1 and 0.9 or 0.78 - abs(a) * 0.15) then c:put(x, y, abs(a) < 0.1 and RED[3] or (a < 0 and RED[3] or RED[2]), ltok) end
  end
end
lm:edge():each(function(x, y) if x > lcx and y > lcy then c:put(x, y, "#2a6f64", ltok) end end)

-- foot, stem
local foot = c:ellipse(32, 56.5, 10, 2.2)
G.toneN(c, foot, X.pillow(foot, 2.2, 1.2), GLS, { tok = { r = { name = "glass" } }, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.15, wrap = 0.35 })
for x = 25, 29 do c:put(x, 56, GLS[5]) end
local stem = c:rect(30, 42, 33, 56)
local stn = {}
stem:each(function(x, y) local t = (x - 30.5) / 2.2 - 0.0 stn[K(x, y)] = { t * 0.85, 0, sqrt(1 - min(0.9, t * t)) } end)
X.tone(c, stem, X.light(stn, { amb = 0.18, wrap = 0.4 }), GLS, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = { r = { name = "glass" } } })
-- stem knop (a glass bead)
for _, p in ipairs{ { 29, 49 }, { 34, 49 }, { 29, 50 }, { 34, 50 } } do c:put(p[1], p[2], GLS[4]) end
c:put(30, 49, GLS[6]) c:put(30, 50, GLS[5]) c:put(33, 50, GLS[2]) c:put(33, 49, GLS[3])
c:put(31, 56, GLS[1]) c:put(32, 56, GLS[1])
-- bowl: tulip, top width 26 -> stem
local bowl = HP.mask()
for y = 29, 44 do
  local t = (y - 29) / 15
  local w = 13.2 * (1 - t ^ 1.7) + 2.2
  for x = floor(32 - w + 0.5), floor(31 + w + 0.5) do bowl:set(x, y) end
end
local gtok = { r = { name = "glass" } }
local bn = {}
bowl:each(function(x, y)
  local t = max(-0.97, min(0.97, (x - 31.5) / 13.2 * (1 + (y - 29) / 40)))
  bn[K(x, y)] = { t, 0.25 * ((y - 29) / 15), sqrt(1 - t * t) }
end)
-- inside: sorbet seen through the glass
local liquid = bowl:shrink(2)
liquid:cut(HP.rect(0, 0, 63, 30))
local bv = X.light(bn, { amb = 0.2, wrap = 0.4 })
X.tone(c, bowl, bv, GLS, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = gtok })
local lv = {}
liquid:each(function(x, y) local k = K(x, y) lv[k] = bv[k] end)
X.tone(c, liquid, lv, SOR, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, bias = (function() local b = {} liquid:each(function(x, y) b[K(x, y)] = -1 end) return b end)(), tok = { r = { name = "sorbet" } } })
liquid:each(function(x, y) if G.hash(x, y, 8) > 0.9 then c:put(x, y, SOR[4], { r = { name = "sorbet" } }) end end)
-- glass rim (bright ellipse lip), left highlight streak, right deep edge
for x = 18, 45 do c:put(x, 29, GLS[6], gtok) end
for x = 19, 44 do c:put(x, 30, GLS[4], gtok) end
for y = 32, 41 do c:put(20 + floor((y - 32) / 2.6), y, GLS[6], gtok) c:put(21 + floor((y - 32) / 2.6), y, GLS[5], gtok) end
bowl:edge():each(function(x, y) if x > 38 and y > 31 then c:put(x, y, GLS[1], gtok) end end)
for y = 34, 43 do local xx = 42 - floor((y - 34) / 2.2) c:put(xx, y, GLS[3], gtok) end

-- scoops
local function scoop(cx, cy, r, name, ab)
  local m = c:ellipse(cx, cy, r, r - 0.5)
  local tok = { r = { name = name } }
  local n = X.sphere(cx - 0.6, cy - 0.8, r + 0.5, m)
  local bias = {}
  if ab then X.ao(bias, m, ab, 1, -1) G.cast(bias, m, ab, 1, 1, -1) end
  G.toneN(c, m, n, SOR, { bias = bias, tok = tok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
  -- ice crystal flecks and a few dark pits
  m:each(function(x, y) local k = K(x, y)
    if not bias[k] then
      local h = G.hash(x, y, cx)
      if h > 0.9 then c:put(x, y, SOR[6], tok) elseif h > 0.84 and x < cx then c:put(x, y, SOR[5], tok) elseif h < 0.05 then c:put(x, y, SOR[2], tok) end
    end
  end)
  -- curl line (scoop swirl)
  for a = 0.4, 2.2, 0.12 do
    local x, y = floor(cx + cos(a + 1.1) * r * 0.5 + 0.5), floor(cy + sin(a + 1.1) * r * 0.45 + r * 0.1 + 0.5)
    if m:has(x, y) then c:put(x, y, SOR[2], tok) end
  end
  -- ruffled skirt on the underside
  for x = cx - r + 1, cx + r - 1 do
    local yy = floor(cy + sqrt(max(0, (r - 0.2)^2 - (x - cx)^2) * ((r - 0.5) / r) ^ 2) + 0.5)
    if m:has(x, yy) then c:put(x, yy, (x % 3 == 0) and SOR[1] or SOR[2], tok) end
  end
  return m, tok
end
local s1 = scoop(25, 23, 7.6, "scoopL")
local s2 = scoop(39, 22, 8.2, "scoopR")
local s3, t3 = scoop(32, 14, 6.2, "scoopT", nil)
-- speculars (one per scoop, two on glossy top)
local sp = "#fbf4ff"
c:put(21, 19, sp) c:put(22, 19, sp) c:put(22, 20, SOR[6])
c:put(35, 18, sp) c:put(36, 18, sp)
c:put(29, 10, sp) c:put(30, 10, sp)
-- contact shadow of the lower scoops on the glass lip, and bowl top
for x = 19, 44 do if (x % 2 == 0) then c:put(x, 30, GLS[2], gtok) end end

-- sea grape sprig (hangs over the left lip): stalk, three grapes
local stp = { { 29, 12 }, { 22, 14 }, { 15, 21 }, { 15, 30 } }
local sm, sn = G.tube(stp, function(t) return 0.95 end)
sm:cut(s1)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), { STALK[1], STALK[2], STALK[3], "#e88a50" }, { cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "stalk" } } })
local function grape(cx, cy, r, name)
  local m = c:ellipse(cx, cy, r, r)
  local tok = { r = { name = name } }
  local n = X.sphere(cx - 0.4, cy - 0.4, r, m)
  G.toneN(c, m, n, GRP, { tok = tok, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 }, amb = 0.1, wrap = 0.25 })
  c:put(cx - 1, cy - 1, GRP[6], tok)
  m:edge():each(function(x, y) if x > cx and y > cy then c:put(x, y, "#5a3a8c", tok) end end)
  return m
end
grape(11, 33, 2.8, "g1") grape(17, 33, 2.8, "g2") grape(14, 38, 2.8, "g3")

-- quirk drip: runs down the right of the bowl from the lip, bead falling
local dtok = { r = { name = "drip" } }
for y = 31, 38 do c:put(44, y, SOR[3], dtok) c:put(43, y, SOR[4], dtok) end
c:put(44, 39, SOR[2], dtok) c:put(43, 39, SOR[3], dtok)
c:put(43, 40, SOR[4], dtok) c:put(43, 31, SOR[5], dtok)
G.save2(c, NAME)
