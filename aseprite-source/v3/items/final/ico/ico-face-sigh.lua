-- ico-face-sigh (final, Opus). A round sun-yellow face, set left of centre, eyes shut in heavy drooping lids under
-- worried brows, a small puckered "o" mouth blowing out a long puff of breath that drifts off to the lower right.
-- Material: per-pixel sphere light snapped to a 6-tone yellow ramp (cool rose-violet shade), soft lit bevel at the
-- rim, one specular streak + cream glint on the upper-left, cool reflected light along the lower-right rim, AO under
-- the brows and in the lid creases; breath puff = 5-tone pale sky with a swirl line, contact shadow on the cheek.
-- quirk: one limp hair strand curls up off the crown and flops forward over the brow.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-face-sigh")
local YE = { "#7a3a3a", "#b8603a", "#e08d2e", "#f5b82e", "#ffd94e", "#fff09a" }
local INK, CREAM = A.INK, A.CREAM
local ftok = A.tok("face")
local CX, CY, R = 27, 33, 18.5

-- quirk: one limp hair strand (2 px, twisted lit/dark) curling up off the crown and flopping forward
local HR = { "#2b1c26", "#4a2a2a", "#6e3f30", "#94603e" }
local htok = A.tok("hair")
local sp = { { 28, 16 }, { 28, 7 }, { 20, 5 }, { 18, 12 } }
local sm, sn = A.tube(sp, function(t) return 1.05 - t * 0.25 end)
A.shade(c, sm, sn, HR, { tok = htok, cuts = { 0.3, 0.55, 0.78 } })
for i = 0, 10 do local x, y = A.bez(sp, i / 10) if i % 3 == 1 then c:put(floor(x + .5), floor(y + .5), HR[4], htok) end end
-- face sphere
local m = A.ell(CX, CY, R, R)
local n = {}
m:each(function(x, y)
  local nx, ny = (x - CX) / (R + 0.5), (y - CY) / (R + 0.5)
  local q = 1 - nx * nx - ny * ny
  n[K(x, y)] = { A.norm(nx, ny, sqrt(max(q, 0.02)) * 1.15) }
end)
local bias = {}
-- AO where the strand roots
for x = 25, 29 do for y = 14, 16 do if m:has(x, y) then bias[K(x, y)] = -1 end end end
local idx = A.shade(c, m, n, YE, { tok = ftok, amb = 0.1, wrap = 0.35, cuts = { 0.14, 0.32, 0.5, 0.68, 0.86 },
  bias = bias, tilt = { CX, CY, R, 0.06 } })
-- cool reflected light lower-right
local rim = X.rim(n)
m:edge():each(function(x, y) if rim[K(x, y)] > 0.72 then c:put(x, y, "#c0707a", ftok) end end)
-- specular streak + glint upper-left
for _, p in ipairs{ { 16, 23 }, { 17, 22 }, { 18, 21 }, { 15, 25 }, { 15, 24 }, { 19, 20 } } do c:put(p[1], p[2], YE[6], ftok) end
c:put(17, 23, CREAM, ftok) c:put(18, 22, CREAM, ftok) c:put(16, 24, CREAM, ftok)

-- features (ink), drawn with a darker-face AO halo above them
local function inkp(x, y) c:put(x, y, INK, ftok) end
local function ao(x, y) local k = K(x, y) if idx[k] and c.own[y * c.w + x] == ftok then A.step(c, idx, YE, x, y, -1, ftok) end end
-- worried brows: inner ends raised, sloping down outward, 2 px thick
local brows = {
  { { 15, 26 }, { 16, 25 }, { 17, 25 }, { 18, 24 }, { 19, 24 }, { 20, 23 } },
  { { 32, 23 }, { 33, 24 }, { 34, 24 }, { 35, 25 }, { 36, 25 }, { 37, 26 } },
}
for _, b in ipairs(brows) do for _, p in ipairs(b) do ao(p[1], p[2] - 1) end end
for _, b in ipairs(brows) do for _, p in ipairs(b) do inkp(p[1], p[2]) inkp(p[1], p[2] + 1) end end
-- heavy shut lids: a lid dome (shade tone) resting on a thick downward lash line
local function lid(x0)
  local dome = { "..sss..", ".sssss.", "sssssss" }
  local lash = { "K.....K", "KKKKKKK", ".KKKKK." }
  for yy, row in ipairs(dome) do for xx = 1, #row do
    if row:sub(xx, xx) == "s" then local x, y = x0 + xx - 1, 27 + yy local k = K(x, y)
      c:put(x, y, YE[max(2, min(4, (idx[k] or 4) - 1))], ftok) end end end
  for yy, row in ipairs(lash) do for xx = 1, #row do
    if row:sub(xx, xx) == "K" then inkp(x0 + xx - 1, 29 + yy) end end end
  -- tired lash flick at the outer corner
end
lid(14) lid(31)

-- puckered "o" mouth, slightly right (blowing toward the puff)
local mouth = {
  ".KKK.",
  "KrrrK",
  "KrdrK",
  "KrrrK",
  ".KKK.",
}
for _, p in ipairs{ { 33, 39 }, { 34, 39 }, { 35, 39 } } do ao(p[1], p[2]) end
A.map(c, mouth, 32, 40, { K = INK, r = "#6e2038", d = "#3d1426" }, ftok)
-- pursed-lip highlight
c:put(33, 45, YE[5], ftok) c:put(34, 45, YE[5], ftok)

-- breath puff drifting lower-right: three lobes, smallest last, plus a stray wisp
local PF = { "#6f86b8", "#94acd6", "#bcd4ef", "#dcecfb", "#f3f9ff" }
local ptok = A.tok("puff")
local pm = HP.mask()
local lobes = { { 39.6, 42.5, 2.0 }, { 42, 43, 3.1 }, { 45, 41.5, 4.4 }, { 51, 44.5, 3.8 }, { 47, 47, 3.2 } }
for _, l in ipairs(lobes) do pm:add(A.ell(l[1], l[2], l[3], l[3])) end
local pn = {}
pm:each(function(x, y)
  local best, bl = 1e9, nil
  for _, l in ipairs(lobes) do local d = sqrt((x - l[1]) ^ 2 + (y - l[2]) ^ 2) - l[3] if d < best then best, bl = d, l end end
  local nx, ny = (x - bl[1]) / (bl[3] + 0.6), (y - bl[2]) / (bl[3] + 0.6)
  pn[K(x, y)] = { A.norm(nx, ny, sqrt(max(1 - nx * nx - ny * ny, 0.05))) }
end)
-- contact shadow of the puff on the cheek
local cb = {}
pm:shift(-1, -1):each(function(x, y) if m:has(x, y) and not pm:has(x, y) then ao(x, y) end end)
local pidx = A.shade(c, pm, pn, PF, { tok = ptok, amb = 0.25, wrap = 0.5, cuts = { 0.2, 0.4, 0.6, 0.8 } })
-- seams between lobes (darker crease) + swirl line
for _, p in ipairs{ { 42, 44 }, { 42, 45 }, { 48, 46 }, { 49, 47 }, { 48, 43 }, { 49, 42 } } do
  if pm:has(p[1], p[2]) then c:put(p[1], p[2], PF[2], ptok) end end
for _, p in ipairs{ { 44, 41 }, { 45, 40 }, { 46, 40 }, { 47, 41 }, { 47, 42 }, { 46, 43 }, { 45, 42 } } do c:put(p[1], p[2], PF[2], ptok) end
c:put(44, 39, PF[5], ptok) c:put(43, 40, PF[5], ptok)
-- stray wisp
for _, p in ipairs{ { 56, 41 }, { 57, 41 }, { 58, 40 } } do c:put(p[1], p[2], PF[3], ptok) end
c:put(56, 42, PF[2], ptok) c:put(57, 42, PF[2], ptok)
A.save(c, "ico-face-sigh")
