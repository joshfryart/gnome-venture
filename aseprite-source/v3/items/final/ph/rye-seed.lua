-- rye-seed (final D step, Sonnet high). Four slim grey-tan rye grains (pointed ends, a dark ventral crease, a pale
-- germ patch at the base, a tuft of hairs at the tip) lie on a long torn scrap of rye leaf (a narrow grass ribbon:
-- pale midrib, parallel veins, ragged torn ends, cool reflected edge, AO + contact shadow under each grain). The right
-- grain has germinated: three white seminal roots with root hairs trail off the scrap, a pale cream coleoptile
-- stands up and splits into two glaucous blue-green grass blades with midribs, and a tiny pair of clasping auricles.
-- quirk: one grain's husk has split open down the crease and the pale floury kernel peeks out.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_4.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2("rye-seed")

local LEAF = { "#1b3b2e", "#285a3a", "#3a7844", "#54984f", "#78b85c", "#a6d47c" }
local VEIN, COOL = "#c4e49a", "#3a6c72"
local GRAIN = { "#46341f", "#74593a", "#a4864f", "#cdae6e", "#e8cf92", "#fdefc2" }
local KERN = { "#b7ac86", "#e4dab4", "#f6efd2", "#fffaea" }
local BLUE = { "#1e4646", "#2d665e", "#438578", "#60a48e", "#88c3a8", "#b6e0c4" }
local COLE = { "#9a9672", "#c4bf94", "#e4e0b6", "#f8f4d4" }
local ROOT = { "#a89878", "#d4c8a8", "#f0e8cc", "#fffaf0" }
local tok = function(n) return { r = { name = n } } end

-- grains: cx, cy, rx, ry, angle
local seeds = {
  { 15.5, 53, 4.9, 2.3, -0.12 },
  { 26.5, 54, 4.8, 2.3, 0.2 },
  { 36.5, 49, 4.9, 2.4, -0.3 },
  { 47, 46.5, 5.0, 2.4, 0.42 },       -- germinating
}
local all = HP.mask()
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.85) all:add(s.m) end

-- ---------- leaf scrap ----------
local lm, ln, LT, LS, len = G.blade(5, 57, 30, 55, 59, 41, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 6.6 * sin(pi * min(1, 0.05 + t * 0.9)) ^ 0.42)
end, { fold = 0.3 })
-- ragged torn ends
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local jag = G.h(floor(abs(s) * 6), 1, 5)
  if t < 0.03 + jag * 0.05 + abs(s) * 0.03 then cut[#cut + 1] = k end
  if t > 0.93 - jag * 0.05 - (s > 0 and 0.03 or 0) then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
X.ao(bias, lm, all, 1, -1) G.cast(bias, lm, all, 1, 2, -1) G.cast(bias, lm, all, 2, 3, -1)
local ltok = tok("leaf")
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.63, 0.8 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 and t > 0.05 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok)           -- midrib
  elseif abs(abs(s) - 0.42) < 0.07 or abs(abs(s) - 0.74) < 0.06 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end -- parallel veins
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] and LS[k] > 0.6 and LT[k] > 0.12 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)
-- torn edge shows a paler fibre row on the cut ends
lm:each(function(x, y) local k = K(x, y)
  if (LT[k] < 0.12 and not lm:has(x - 1, y)) or (LT[k] > 0.84 and not lm:has(x + 1, y + 0)) then c:put(x, y, LEAF[6], ltok) end end)

-- ---------- roots (before the grain so the base sits over them) ----------
local function root(p, w)
  local m, n, T, S = G.tube(p, function(t) return w * (1 - t * 0.5) end)
  X.tone(c, m, X.light(n, { amb = 0.2, wrap = 0.3 }), ROOT, { cuts = { 0.3, 0.55, 0.8 }, tok = tok("root") })
  return m, T
end
root({ { 42, 48 }, { 38, 51 }, { 36, 55 }, { 39, 58 } }, 0.7)
root({ { 42, 48 }, { 42, 52 }, { 45, 56 }, { 49, 56 } }, 0.7)
root({ { 41, 47 }, { 35, 48 }, { 31, 51 }, { 30, 55 } }, 0.65)
-- root hairs
for _, p in ipairs{ { 36, 53 }, { 35, 55 }, { 44, 54 }, { 46, 56 }, { 33, 50 }, { 31, 52 } } do c:px(p[1], p[2], ROOT[3]) end

-- ---------- sprout ----------
local cm, cn, CT, CS = G.tube({ { 44, 45 }, { 44, 39 }, { 45, 33 }, { 45, 27 } }, function(t) return 1.5 - 0.2 * t end)
cm:cut(seeds[4].m)
local cidx = X.tone(c, cm, X.light(cn, { amb = 0.18, wrap = 0.3 }), COLE, { cuts = { 0.3, 0.55, 0.8 }, tok = tok("cole") })
cm:each(function(x, y) local k = K(x, y) if abs(CS[k]) < 0.12 and CT[k] > 0.1 and CT[k] < 0.9 then c:put(x, y, COLE[2], tok("cole")) end end)
-- ring where the blades leave the sheath
cm:each(function(x, y) if CT[K(x, y)] > 0.9 then c:put(x, y, COLE[1], tok("cole")) end end)
local function blade(ax, ay, cx, cy, bx, by, w, name)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    return max(0.4, w * sin(pi * min(1, 0.22 + t * 0.78)) ^ 0.5)
  end, { fold = 0.5 })
  m:cut(cm)
  local tk = tok(name)
  G.toneN(c, m, n, BLUE, { tok = tk, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.17 and T[k] > 0.05 and T[k] < 0.92 then c:put(x, y, S[k] <= 0 and BLUE[6] or BLUE[3], tk) end end)
  return m
end
blade(45, 28, 44, 17, 52, 8, 1.8, "b1")
blade(44, 28, 41, 20, 34, 13, 1.5, "b2")
-- clasping auricles at the collar
c:px(43, 27, COLE[4]) c:px(42, 26, COLE[3]) c:px(47, 27, COLE[3]) c:px(48, 26, COLE[2])

-- ---------- grains (last) ----------
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tk = tok("grain" .. i)
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), flip * (-dx * sa + dy * ca) / (s[4] + .45)
    local idx
    if v < -0.5 then idx = 5 elseif v < -0.12 then idx = 4 elseif v < 0.12 then idx = 3 elseif v < 0.5 then idx = 3 else idx = 2 end
    if v > 0.1 and v < 0.55 then idx = 3 end
    if v > 0.7 then idx = 1 end
    if abs(v) < 0.2 and abs(u) < 0.72 then idx = 2 end                                -- ventral crease
    if abs(u) > 0.84 then idx = idx - 1 end
    -- germ patch (pale oval) at the base (u < 0)
    if u < -0.5 and u > -0.9 and abs(v) < 0.55 then idx = (v < 0) and 5 or 4 end
    if i == 3 and abs(v) < 0.3 and abs(u) < 0.62 then                                 -- split husk: kernel peeks out
      idx = nil
      c:put(x, y, abs(v) < 0.12 and KERN[4] or KERN[3], tk)
    end
    if idx then
      if sb[k] then idx = idx - 1 end
      c:put(x, y, GRAIN[max(1, min(6, idx))], tk)
    end
  end)
  -- split husk lips: dark edges either side of the kernel
  if i == 3 then
    vis:each(function(x, y)
      local dx, dy = x - s[1], y - s[2]
      local u, v = (dx * ca + dy * sa) / (s[3] + .45), flip * (-dx * sa + dy * ca) / (s[4] + .45)
      if abs(u) < 0.66 and abs(abs(v) - 0.3) < 0.1 then c:put(x, y, v < 0 and GRAIN[3] or GRAIN[1], tk) end
    end)
  end
  -- tuft of hairs at the tip (+u end) : two pale pixels
  local tx, ty = s[1] + ca * (s[3] + 1.0), s[2] + sa * (s[3] + 1.0)
  local xi, yi = floor(tx + 0.5), floor(ty + 0.5)
  if i ~= 4 or true then c:put(xi, yi, GRAIN[5], tk) c:put(xi + (ca > 0 and 1 or -1), yi + (sa > 0.1 and 1 or (sa < -0.1 and -1 or 0)), GRAIN[4], tk) end
end

G.save2(c, "rye-seed")
