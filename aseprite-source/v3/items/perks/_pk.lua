-- _pk.lua: shared helpers for the perk-popover art (growth-stage pots and the stake sign). Reuses the v3 helper chain
-- (_helpers/_aA10_1.lua -> batch2/_b2g1.lua -> lib/hp.lua + hpx.lua). Every stage keeps the pot at the same place so the
-- five pictures line up when the counter swaps them. Light upper-left, 6-tone ramps, 1px ink outline, one quirk each.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../final/_helpers/_aA10_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local P = { A = A, HP = HP, X = X, K = K }
P.OUT = app.params.out or (DIR .. "/out/")
P.EM   = { "#4a1f2e", "#7d2c3a", "#b52e3f", "#e8493b", "#ff7a50", "#ffab78" }   -- terracotta
P.SO   = { "#3a2226", "#5a3329", "#7d4a33", "#a0663f", "#c48955", "#e2b07a" }   -- soil
P.LF   = { "#1d4a3c", "#2a6b45", "#3d8a4a", "#5aab4f", "#86c95c", "#bfe57e" }   -- leaves
P.SM   = { "#2a5f40", "#4c8f4a", "#78b85a", "#a6d873" }                         -- stems
P.GD   = { "#5a2a1a", "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a", "#fff4d6" }   -- gold seed, flower eye, snail shell
P.PT   = { "#7d2c5e", "#b3416f", "#e0638f", "#f5809f", "#ffc4d8", "#ffe9ef" }   -- petals and bud
P.WD   = { "#51302b", "#6e3f2f", "#864c33", "#b97a4a", "#d9a26a", "#e8b982" }   -- plank wood
P.ST   = { "#444663", "#74758c", "#aaa9b8", "#d6d5df" }                          -- nail heads
P.SK   = { "#7a4036", "#c98462", "#f0b98d", "#ffe0bd" }                          -- snail body
P.tok  = { leaf = { r = { name = "leaf" } }, stem = { r = { name = "stem" } }, pot = { r = { name = "pot" } }, soil = { r = { name = "soil" } }, misc = { r = { name = "misc" } } }

function P.new(name, w, h) return HP.canvas{ w = w or 64, h = h or 64, scale = 1, name = name } end

-- terracotta pot (tapered body, wide rim, rim shadow) with soil on top. Rim top y=40.
function P.pot(c)
  c:groundShadow(32, 61, 17, 2)
  local body = c:poly({ { 20, 47 }, { 44, 47 }, { 41, 60 }, { 23, 60 } })
  local bn = A.slab(body, 5)
  A.shade(c, body, bn, P.EM, { amb = 0.08, wrap = 0.3, tok = P.tok.pot })
  -- dark band under the rim (AO) and a worn chip on the lower right (material cue)
  for x = 20, 44 do if body:has(x, 48) then c:put(x, 48, P.EM[1], P.tok.pot) end end
  for x = 23, 41 do if body:has(x, 59) then c:put(x, 59, P.EM[1], P.tok.pot) end end
  c:put(38, 54, P.EM[1], P.tok.pot) c:put(39, 55, P.EM[1], P.tok.pot) c:put(39, 54, P.EM[5], P.tok.pot)
  local rim = c:rrect(15, 40, 49, 47, 2)
  local rn = A.slab(rim, 3)
  A.shade(c, rim, rn, P.EM, { amb = 0.1, wrap = 0.3, tok = P.tok.pot })
  c:put(19, 41, P.EM[6], P.tok.pot) c:put(20, 41, P.EM[6], P.tok.pot) c:put(21, 41, P.EM[5], P.tok.pot)   -- the one rim shine
  -- soil: pillow-lit crumbs inside the rim
  local soil = c:ellipse(32, 41, 15, 3.2):clip(c:rect(0, 0, 63, 42))
  local sn = A.slab(soil, 3)
  local sidx = A.shade(c, soil, sn, P.SO, { amb = 0.06, wrap = 0.2, tok = P.tok.soil })
  soil:each(function(x, y) local h = X.hash(x, y, 11)
    if h < 0.14 then c:put(x, y, P.SO[min(6, (sidx[K(x, y)] or 3) + 2)], P.tok.soil) elseif h > 0.9 then c:put(x, y, P.SO[1], P.tok.soil) end end)
  return soil
end

-- the quirk: a small snail on the ground at the left of the pot
function P.snail(c, x, y)
  local body = c:rrect(x + 1, y + 6, x + 11, y + 8, 1)
  body:add(c:rrect(x + 9, y + 4, x + 11, y + 8, 1))
  A.shade(c, body, A.slab(body, 2), P.SK, { cuts = A.CUTS5, tok = P.tok.misc })
  c:put(x + 11, y + 3, P.SK[2], P.tok.misc) c:put(x + 9, y + 3, P.SK[2], P.tok.misc)        -- eye stalks
  c:put(x + 11, y + 2, P.GD[1], P.tok.misc) c:put(x + 9, y + 2, P.GD[1], P.tok.misc)
  local shell = c:ellipse(x + 4.5, y + 4, 3.8, 3.8)
  A.shade(c, shell, X.sphere(x + 4.5, y + 4, 3.8, shell), P.GD, { cuts = { 0.22, 0.4, 0.58, 0.76, 0.9 }, tok = P.tok.misc })
  c:put(x + 4, y + 4, P.GD[1], P.tok.misc) c:put(x + 5, y + 4, P.GD[2], P.tok.misc) c:put(x + 5, y + 5, P.GD[2], P.tok.misc) c:put(x + 3, y + 3, P.GD[6], P.tok.misc)
end

function P.stem(c, ax, ay, bx, by, w)
  local m, n, T = X.cyl(ax, ay, bx, by, function() return w end)
  local b = {}
  m:each(function(x, y) if T[K(x, y)] > 0.9 then b[K(x, y)] = -1 end end)
  A.shade(c, m, n, P.SM, { amb = 0.1, bias = b, tok = P.tok.stem })
  return m
end

-- V-folded leaf with midrib and paired veins (same recipe as ico-sprout)
function P.leaf(c, ax, ay, cx, cy, bx, by, W, stem)
  local m, n, T, S, len = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.6, W * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.75)
  end, { fold = 0.6 })
  local b = {}
  if stem then X.ao(b, m, stem, 1, -1) end
  local idx = A.shade(c, m, n, P.LF, { amb = 0.12, wrap = 0.3, bias = b, tok = P.tok.leaf })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.14 and t > 0.08 and t < 0.9 then c:put(x, y, s <= 0 and P.LF[3] or P.LF[2], P.tok.leaf) end
    for _, vt in ipairs{ 0.35, 0.6 } do
      local d = (t - vt) * len - abs(s) * 3.0
      if d > -0.5 and d < 0.5 and abs(s) > 0.22 and abs(s) < 0.78 then c:put(x, y, P.LF[max(1, (idx[k] or 3) - 1)], P.tok.leaf) end
    end
  end)
  return m
end

function P.finish(c, name)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = P.OUT .. name .. ".aseprite", png = P.OUT .. name .. ".png", scale = 1 }
end
return P
