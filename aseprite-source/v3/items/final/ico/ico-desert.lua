-- ico-desert (final, Opus). A desert vignette: a slim saguaro cactus with two raised arms on a pale sand dune,
-- a darker back dune, a big low sun behind.
-- Material: cactus = per-pixel tube light per segment (6 tones), vertical rib grooves with lit lips and pale
-- areole dots along the ribs, AO where the arms join; sand = 6 tones with wind-ripple lines and grain specks;
-- sun = 6-tone disc, bright upper-left rim.
-- quirk: a tiny lizard is sunbathing on the dune, tail curled.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local c = A.new("ico-desert")
local CA  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local SA  = { "#8a5236", "#b87a48", "#d9a05e", "#edc27a", "#f8dc9e", "#fff0c8" }
local BD  = { "#6e3430", "#9a4e36", "#c46e40", "#de9050", "#f0b066" }
local SUN = { "#d0601c", "#ea8a26", "#f7ae30", "#ffcf48", "#ffe680", "#fff6c4" }
local AREO = "#e9f0c0"
local tS, tB, tF, tC, tX = A.tok("sun"), A.tok("backdune"), A.tok("dune"), A.tok("cactus"), A.tok("bits")

-- sun: big disc low behind, upper-right
local sun = A.ell(43, 25, 11, 11)
local sn = X.sphere(43, 25, 11, sun)
local snv = {}
sun:each(function(x, y) local r = A.polar(x, y, 43, 25) snv[K(x, y)] = 0 end)
local sidx = A.shade(c, sun, sn, SUN, { tok = tS, amb = 0.35, wrap = 0.6, cuts = { 0.38, 0.54, 0.68, 0.8, 0.92 } })
-- bright rim upper-left, warm darker band lower-right
sun:edge():each(function(x, y) if x + y < 64 then c:put(x, y, SUN[6], tS) end end)

-- back dune: low ridge from the left rising to the right, covers the sun's base
local back = c:terrain(function(x) return 38 - 6 * sin((x - 14) / 40 * pi) + 0.02 * (x - 30) ^ 2 * 0 end, nil, 46, 9, 56)
back:each(function() end)
local bn = A.hnorm(back, function(x, y) return back:has(x, y) and (46 - y) * 0.15 + 3 * sin((x - 14) / 40 * pi) or 0 end, 1.2)
local bidx = A.shade(c, back, bn, BD, { tok = tB, amb = 0.15, wrap = 0.3, tilt = { 32, 40, 20, 0.15 }, cuts = { 0.2, 0.4, 0.6, 0.8 } })
-- lit crest line
for x = 9, 56 do for y = 0, 63 do if back:has(x, y) then if x < 40 then c:put(x, y, BD[5], tB) end break end end end
-- AO on the sun where the dune overlaps (sun sits behind)
sun:each(function(x, y) if back:has(x, y + 1) and not back:has(x, y) then A.step(c, sidx, SUN, x, y, -1, tS) end end)

-- front dune: pale sand mound, crest upper-left, long slope to the right
local front = c:terrain(function(x) local u = (x - 22) / 22 return 45 + 6 * u * u - (u < 0 and 0 or 1.5 * u) end, nil, 52, 7, 57)
front:add(c:rect(8, 50, 56, 52))
local fn = A.hnorm(front, function(x, y) local u = (x - 22) / 22 return max(0, 9 - 6 * u * u) * (front:has(x, y) and 1 or 0) - (y - 45) * 0.3 end, 0.6)
local fb = {}
X.ao(fb, front, back, 1, -1)
local fidx = A.shade(c, front, fn, SA, { bias = fb, tok = tF, amb = 0.12, wrap = 0.3, tilt = { 30, 48, 24, 0.15 }, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 } })
-- wind ripples: curved dark lines with lit lip above
front:each(function(x, y)
  local w = y - 0.12 * (x - 30) - 1.2 * sin(x * 0.35)
  for _, r0 in ipairs{ 45.5, 48.5 } do
    if abs(w - r0) < 0.5 and front:has(x, y - 2) and x > 12 and x < 54 then
      A.step(c, fidx, SA, x, y, -1, tF)
      if front:has(x, y - 1) then A.step(c, fidx, SA, x, y - 1, 1, tF) end
    end
  end
end)
-- grain specks
front:each(function(x, y) if X.hash(x, y, 21) > 0.93 and not front:edge():has(x, y) then A.step(c, fidx, SA, x, y, (X.hash(x, y, 4) > 0.5) and 1 or -1, tF) end end)

-- cactus: trunk + two arms (elbow tubes), ribs, areoles
local CX = 24
local cacM = HP.mask()
local function seg(pts, w, ribs)
  local m, n, T, S = A.tube(pts, function(t) return w end)
  m:cut(cacM)
  local b = {}
  X.ao(b, m, cacM, 1, -1)
  local idx = A.shade(c, m, n, CA, { bias = b, tok = tC, amb = 0.1, wrap = 0.25, cuts = { 0.16, 0.32, 0.48, 0.64, 0.82 } })
  -- rib grooves (dark) with a lit lip on their left, areole dots along the ribs
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    for _, r in ipairs(ribs) do
      if abs(s - r) < 0.13 then
        A.step(c, idx, CA, x, y, -1, tC)
      elseif s < r and s > r - 0.32 and idx[k] and idx[k] >= 3 then A.step(c, idx, CA, x, y, 1, tC) end
    end
  end)
  cacM:add(m)
  return m, idx, T, S
end
-- trunk with rounded top
local tm, tidx = seg({ { CX, 49 }, { CX, 36 }, { CX, 22 }, { CX, 12.5 } }, 3.4, { -0.45, 0.25 })
-- arms: horizontal stub then up; left arm higher
local lm = seg({ { CX - 2, 33 }, { CX - 8, 34 }, { CX - 10, 31 }, { CX - 10, 21.5 } }, 2.3, { 0.05 })
local rm = seg({ { CX + 2, 38 }, { CX + 8, 39 }, { CX + 10, 36 }, { CX + 10, 27.5 } }, 2.3, { 0.05 })
-- re-tone trunk AO where arms meet (trunk already painted): dark rows under each arm joint
for _, p in ipairs{ { CX - 3, 36 }, { CX - 3, 37 }, { CX + 3, 41 }, { CX + 3, 42 } } do A.step(c, tidx, CA, p[1], p[2], -1, tC) end
-- areoles: pale dots up the ribs
cacM:each(function(x, y) if (y % 3 == 0) and (c:get(x, y) == CA[1] or c:get(x, y) == CA[2]) and X.hash(x, y, 2) > 0.45 and y < 46 then c:put(x, y, AREO, tC) end end)
-- top glint
c:put(CX - 2, 14, CA[6], tC) c:put(CX - 1, 14, CA[6], tC)
-- contact shadow on the sand at the cactus base
for x = CX - 4, CX + 7 do if front:has(x, 49) and not cacM:has(x, 49) then c:put(x, 49, SA[2], tF) end
  if front:has(x, 50) and x > CX + 1 then c:put(x, 50, SA[2], tF) end end

-- quirk: a tiny lizard sunbathing on the dune, tail curled (head left)
A.map(c, {
  "..k.k.....",
  "gGGGGGGg..",
  "kgGGGgGgg.",
  "..k.k...g.",
  "......gg..",
}, 40, 45, { G = "#7cc35a", g = "#3f9150", k = "#24544a" }, tX)
c:put(41, 46, A.INK, tX)

A.save(c, "ico-desert")
