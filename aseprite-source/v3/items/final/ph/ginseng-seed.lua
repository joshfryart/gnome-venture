local NAME = "ginseng-seed"
-- ginseng-seed: pale flat round-oval ginseng seeds on a scrap of real ginseng leaf (palmate, 5 toothed oval leaflets on a stalk); one seed split, sprout with mini 3-leaflet palmate leaf. quirk: one red berry.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local LEAF  = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }
local SLEAF = { "#1a4238", "#255f43", "#33804b", "#4f9f52", "#78bd5c", "#a8d877" }
local COOL = "#3c6f74"
-- toothed oval leaflet: from base a to tip b (control c), half-width w, side veins at vt (px along)
local function leaflet(ax, ay, cx, cy, bx, by, w, ramp, vts, nm, bias)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.9 + 0.1)
    return max(0.45, w * sin(pi * u ^ 1.2) ^ 0.7)
  end, { fold = 0.5 })
  local tm = HP.mask()
  m:edge():each(function(x, y) if (x + 2 * y) % 3 == 0 and T[K(x, y)] > 0.18 and T[K(x, y)] < 0.97 then tm:set(x, y) end end)
  m:cut(tm)
  local tok = { r = { name = nm } }
  G.toneN(c, m, n, ramp, { tok = tok, cuts = CUTS, amb = 0.12, wrap = 0.22, bias = bias })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.14 and t > 0.04 and t < 0.92 then c:put(x, y, s <= 0 and ramp[6] or ramp[2], tok) return end
    for _, vt in ipairs(vts) do
      local d = t * L - (vt + abs(s) * 3.2)
      if d > -0.5 and d < 0.5 and abs(s) > 0.3 and abs(s) < 0.75 then c:put(x, y, s < 0 and ramp[6] or ramp[2], tok) return end
    end
  end)
  m:edge():each(function(x, y) local k = K(x, y) if S[k] > 0.6 and T[k] > 0.15 and T[k] < 0.85 then c:put(x, y, COOL, tok) end end)
  return m
end
local SEED = { "#7c6244", "#a68a62", "#cdb68a", "#e4d2a8", "#f3e6c6", "#fff6de" }
local STEM = { "#5a2a30", "#86403a", "#a85c48", "#7a8a48", "#9cae5a" }
local BERRY = { "#5a0f1e", "#8e1a2a", "#c62d32", "#ee5a44", "#ff9a78" }
-- leaf scrap: stalk + 5 leaflets
local stm, stn, ST = G.tube({ {33,60}, {32,55}, {32,51}, {32,46} }, function(t) return 1.1 - 0.3 * t end)
G.toneN(c, stm, stn, LEAF, { tok = { r = { name = "stalk" } }, cuts = CUTS })
local seeds = { {23, 41, 0.3}, {41, 42, -0.25}, {27, 51, -0.1}, {38, 52, 0.2} }
local bias = {}
local sm = {}
for i, s in ipairs(seeds) do sm[i], s.n = G.oval(s[1], s[2], 3.4, 2.7, s[3], 0.8) end
local function lf(...) return leaflet(...) end
local ml = {
  lf(32,47, 32,40, 32,27, 3.9, LEAF, {5, 9}, "lc"),
  lf(31,47, 22,45, 13,36, 3.7, LEAF, {4, 8}, "lul"),
  lf(33,47, 42,45, 51,36, 3.7, LEAF, {4, 8}, "lur"),
  lf(31,48, 22,50, 13,50, 3.0, LEAF, {3, 6}, "lll"),
  lf(33,48, 42,50, 51,50, 3.0, LEAF, {3, 6}, "llr"),
}
-- contact shadows of seeds on the leaf
for i, s in ipairs(seeds) do
  sm[i]:shift(1, 2):each(function(x, y) if not sm[i]:has(x, y) then for _, m in ipairs(ml) do if m:has(x, y) then c:put(x, y, LEAF[1], { r = { name = "sh" } }) end end end end)
end
-- sprout from the split seed (centre-top): stem up to a mini palmate leaf
local pm, pn, PT = G.tube({ {32,39}, {31,31}, {33,22}, {32,16} }, function(t) return 0.95 - 0.2 * t end)
local ptok = { r = { name = "stem" } }
local pv = X.light(pn, { amb = 0.15, wrap = 0.3 })
pm:each(function(x, y) local k = K(x, y) local lit = pv[k] > 0.55
  if PT[k] < 0.5 then c:put(x, y, lit and STEM[3] or STEM[2], ptok) else c:put(x, y, lit and STEM[5] or STEM[4], ptok) end end)
lf(32,17, 32,11, 32,5, 2.5, SLEAF, {3}, "pc")
lf(32,17, 27,15, 21,10, 2.4, SLEAF, {3}, "pl")
lf(32,17, 37,15, 43,10, 2.4, SLEAF, {3}, "pr")
-- seeds
local function seedPaint(m, n, i, cx, cy, ang)
  local tok = { r = { name = "seed" .. i } }
  local idx = X.tone(c, m, X.light(n, { amb = 0.08, wrap = 0.22 }), SEED, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 }, tok = tok })
  -- seam ridge across the long axis
  for t = -2, 2 do local x, y = floor(cx + cos(ang) * t + 0.5), floor(cy + sin(ang) * t + 0.5)
    if m:has(x, y) then c:put(x, y, SEED[2], tok) end end
  local bx, by = G.specAt(m, n, 30) if bx then c:put(bx, by, SEED[6], tok) end
end
for i, s in ipairs(seeds) do seedPaint(sm[i], s.n, i, s[1], s[2], s[3]) end
-- split seed at stem base
local sp, spn = G.oval(32, 41, 3.6, 2.8, 0, 0.8)
seedPaint(sp, spn, 9, 32, 41, 0)
c:put(31, 40, SEED[1], { r = { name = "seed9" } }) c:put(31, 41, SEED[1], { r = { name = "seed9" } }) c:put(32, 40, STEM[2], { r = { name = "seed9" } })
-- quirk: one red berry on a pedicel at lower right
local bm, bn = G.oval(47, 56, 2.6, 2.6, 0, 1)
local bt = { r = { name = "berry" } }
X.tone(c, bm, X.light(bn, { amb = 0.08, wrap = 0.2 }), { BERRY[1], BERRY[2], BERRY[3], BERRY[4], BERRY[5], BERRY[5] }, { cuts = CUTS, tok = bt })
c:put(46, 54, "#ffd8c0", bt)
for _, p in ipairs{ {45,52},{44,51},{43,51} } do c:put(p[1], p[2], STEM[4], { r = { name = "ped" } }) end
G.save(c, NAME)
