-- mesquite-pods (final, Opus single pass). A short thorny mesquite twig (bark grain, paired pale spines) with a
-- bipinnate leaf frond, and three long slim honey-mesquite pods hanging from it in loose curves: straw-gold, beaded
-- over the seeds with dark constrictions between, red-rose streaks along the shaded flank, a seam line, waxy specular.
-- quirk: a tiny bean weevil peeks out of its round exit hole in the middle pod.
local NAME = "mesquite-pods"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_1.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sqrt, max, min, cos, sin, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.cos, math.sin, math.pi
local c = A.new(NAME)
local POD = { "#5e3726", "#8c5630", "#b98236", "#dcaa48", "#f1cd6c", "#fdeaa4" }
local STREAK = { "#9a3d36", "#c25a44" }
local BARK = { "#3c2626", "#5a3a2e", "#7e5438", "#a3754a", "#c79b68" }
local LEAF = { "#21503f", "#2f6c46", "#45894c", "#66a656", "#93c56a", "#c0de8c" }
local SPINE = "#efe1bf"
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }

-- twig
local btok = { r = { name = "bark" } }
local tw = { { 12, 15 }, { 20, 12 }, { 30, 12 }, { 42, 9 } }
local tm, tn, TT, TS = G.tube(tw, function(t) return 1.6 - 0.6 * t end)
local tidx = A.shade(c, tm, tn, BARK, { amb = 0.1, wrap = 0.3, cuts = { 0.22, 0.42, 0.62, 0.82 }, tok = btok })
tm:each(function(x, y) local k = K(x, y) if abs(TS[k]) < 0.3 and X.hash(x, y, 2) < 0.35 then c:put(x, y, BARK[max(1, tidx[k] - 1)], btok) end end)
-- paler cut end (end grain) at the left
c:put(11, 15, BARK[5], btok) c:put(11, 14, BARK[4], btok) c:put(11, 16, BARK[3], btok)
-- paired spines at nodes
for _, s in ipairs{ { 17, 12, -1, -1 }, { 18, 15, 0, 1 }, { 35, 9, 0, -1 }, { 36, 12, 1, 1 } } do
  c:put(s[1] + s[3], s[2] + s[4], SPINE, btok) c:put(s[1] + 2 * s[3], s[2] + 2 * s[4], BARK[4], btok)
end

-- bipinnate leaf frond from the twig tip: rachis forks into two pinnae with tiny paired leaflets
local ltok = { r = { name = "leaf" } }
local function pinna(x0, y0, x1, y1)
  local L = sqrt((x1 - x0) ^ 2 + (y1 - y0) ^ 2)
  local ux, uy = (x1 - x0) / L, (y1 - y0) / L
  local px, py = -uy, ux
  for i = 0, floor(L) do
    local x, y = floor(x0 + ux * i + .5), floor(y0 + uy * i + .5)
    c:put(x, y, LEAF[2], ltok)
    if i >= 2 and i % 2 == 0 and i < L then
      for sgn = -1, 1, 2 do
        for j = 1, 2 do
          local lx, ly = floor(x + px * sgn * j + ux * j * 0.6 + .5), floor(y + py * sgn * j + uy * j * 0.6 + .5)
          local lit = (px * sgn + py * sgn) < 0
          c:put(lx, ly, lit and (j == 2 and LEAF[6] or LEAF[5]) or (j == 2 and LEAF[3] or LEAF[4]), ltok)
        end
      end
    end
  end
end
pinna(42, 9, 55, 6)
pinna(44, 9, 56, 13)

-- pods
local pods = {
  { { 22, 14 }, { 14, 25 }, { 8, 39 }, { 14, 52 }, 6 },
  { { 26, 14 }, { 32, 27 }, { 24, 41 }, { 32, 54 }, 7 },
  { { 30, 13 }, { 44, 20 }, { 52, 34 }, { 48, 49 }, 6 },
}
local hole
for pi_, p in ipairs(pods) do
  local pts, ns = { p[1], p[2], p[3], p[4] }, p[5]
  local function bead(t) return cos(2 * pi * (ns * t - 0.5 * ns * 0.12)) end
  local m, n, T, S = G.tube(pts, function(t)
    if t < 0.06 then return 0.9 end                          -- stalk
    local taper = min(1, (t - 0.06) / 0.12) * min(1, (1 - t) / 0.18)
    local u = (t - 0.12) / 0.88
    local b = 0.45 * max(0, cos(2 * pi * ns * u))
    return (1.55 + b) * taper ^ 0.6 + 0.35
  end, 220)
  m:cut(tm)
  -- normals: add bulge so each seed reads round
  local bias = {}
  local tok = { r = { name = "pod" .. pi_ } }
  m:each(function(x, y) local k = K(x, y) local t = T[k]
    local u = (t - 0.12) / 0.88
    local ph = cos(2 * pi * ns * u)
    if t > 0.14 and t < 0.94 and ph < -0.72 then bias[k] = -1 end   -- constriction AO
  end)
  local idx = A.shade(c, m, n, POD, { amb = 0.08, wrap = 0.28, cuts = CUTS, bias = bias, tok = tok })
  m:each(function(x, y) local k = K(x, y) local t, s = T[k], S[k]
    local u = (t - 0.12) / 0.88
    if t > 0.16 and t < 0.92 then
      -- seam along the lit edge
      if s < -0.62 and s > -0.86 and X.hash(x, y, pi_) < 0.6 then c:put(x, y, POD[min(6, idx[k] + 1)], tok) end
      -- red streaks on the shaded flank
      if s > 0.25 and s < 0.7 and (sin(u * 9 + pi_) > 0.35) then c:put(x, y, STREAK[idx[k] >= 3 and 2 or 1], tok) end
    end
    if t < 0.07 then c:put(x, y, BARK[3 + (s < 0 and 1 or 0)], tok) end
  end)
  -- waxy specular on the brightest pixel of 2 beads
  for _, tb in ipairs{ 0.32, 0.62 } do
    local best, bx, by
    m:each(function(x, y) local k = K(x, y)
      if abs(T[k] - tb) < 0.05 and idx[k] == 6 and (not best or S[k] < best) then best, bx, by = S[k], x, y end end)
    if bx then c:put(bx, by, "#fff6d2", tok) end
  end
  if pi_ == 2 then
    -- weevil exit hole on bead near t~0.5 shaded-middle
    local best, hx, hy
    m:each(function(x, y) local k = K(x, y)
      if abs(T[k] - 0.55) < 0.02 and abs(S[k]) < 0.25 and (not best or abs(S[k]) < best) then best, hx, hy = abs(S[k]), x, y end end)
    hole = { hx, hy, tok, idx }
  end
end
-- quirk: round hole, rim lit lower-right, weevil head (ink + eye glint + snout) peeking out
do
  local hx, hy, tok = hole[1], hole[2], hole[3]
  c:put(hx, hy, "#2b1c26", tok) c:put(hx + 1, hy, "#2b1c26", tok) c:put(hx, hy + 1, "#3a2430", tok) c:put(hx + 1, hy + 1, "#2b1c26", tok)
  c:put(hx + 2, hy + 1, POD[6], tok) c:put(hx + 1, hy + 2, POD[5], tok) c:put(hx - 1, hy, POD[2], tok)
  c:put(hx, hy, "#fff4d6", tok)                         -- eye glint
  c:put(hx - 1, hy - 1, "#5a3a42", tok)                  -- tiny snout poking out
end

A.save(c, NAME)
