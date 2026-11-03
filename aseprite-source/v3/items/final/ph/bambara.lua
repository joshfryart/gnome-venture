-- bambara (final, aR3_2 single pass). Bambara groundnut: a round, deeply wrinkled straw-coloured pod (net of sunken
-- grooves with lit ridges, soil-dusted underside) on its slim pale peg, plus two loose glossy maroon seeds below it,
-- each with the white bambara "eye" (hilum with a dark rim), waxy bloom, one hard specular and a cool reflected edge.
-- quirk: the peg ends in a little curled pigtail with a crumb of soil still stuck to it (it grew underground).
local NAME = "bambara"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_2.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local POD = { "#4a3226", "#74523a", "#9e7a4c", "#c4a062", "#e0c47e", "#f4e2a8" }
local RED = { "#2e1020", "#4e1828", "#742432", "#9c3438", "#c4544a", "#e8866a" }
local PEG = { "#5e4a36", "#8c7650", "#b8a374", "#dccb98", "#f2e6be" }
local SOIL = { "#3a2622", "#5c3c2e", "#7e5638" }
local COOL = "#7a3a5a"
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds (drawn into masks first so the pod can be shaded by them)
local s1 = { 37, 43, 6.0, 5.0, -0.3 }
local s2 = { 47, 35, 4.8, 4.1, 0.45 }
s1.m, s1.n = G.oval(s1[1], s1[2], s1[3], s1[4], s1[5], 0.85)
s2.m, s2.n = G.oval(s2[1], s2[2], s2[3], s2[4], s2[5], 0.85)

-- pod: wrinkled ellipsoid
local pc = { 26, 30, 10.4, 8.4, -0.5 }
local pm, pn = G.oval(pc[1], pc[2], pc[3], pc[4], pc[5], 0.9)
-- slight lumpy silhouette: nibble the rim where the grooves come out
local pts = {}
for i = 1, 13 do
  local a = i * 2.4 + 0.3
  local r = sqrt((i - 0.5) / 13)
  local ca, sa = cos(pc[5]), sin(pc[5])
  local u, v = cos(a) * r * pc[3], sin(a) * r * pc[4]
  pts[i] = { pc[1] + u * ca - v * sa + (X.hash(i, 1, 3) - 0.5) * 2.2, pc[2] + u * sa + v * ca + (X.hash(i, 2, 3) - 0.5) * 2.2 }
end
local function vor(x, y)
  local d1, d2 = 1e9, 1e9
  for _, p in ipairs(pts) do local d = sqrt((x - p[1])^2 + (y - p[2])^2)
    if d < d1 then d1, d2 = d, d1 elseif d < d2 then d2 = d end end
  return d2 - d1
end
local pv = X.light(pn, { amb = 0.1, wrap = 0.3 })
local pbias = {}
X.ao(pbias, pm, s1.m, 2, -1) G.cast(pbias, pm, s1.m, -1, -1, 0)
local ptok = { r = { name = "pod" } }
pm:each(function(x, y) local k = K(x, y)
  local i = 1 for q, cu in ipairs(CUTS) do if pv[k] >= cu then i = q + 1 end end
  local g = vor(x, y)
  local gl = vor(x - 1, y - 1)
  if g < 0.9 then i = i - 2                          -- sunken groove
  elseif gl < 0.9 then i = i + 1 end                 -- ridge lit on its upper-left lip
  i = i + (pbias[k] or 0)
  i = max(1, min(6, i))
  c:put(x, y, POD[i], ptok)
end)
-- soil dusting on the pod's underside
pm:each(function(x, y) local k = K(x, y)
  local dx, dy = x - pc[1], y - pc[2]
  if dx * 0.3 + dy > 4.5 and X.hash(x, y, 21) > 0.72 and vor(x, y) >= 0.9 then c:put(x, y, SOIL[3], ptok) end end)

-- peg (gynophore) out of the pod's upper-right end, curling into a pigtail
local pp = { { 33.5, 24 }, { 36, 18 }, { 35, 13 }, { 31.5, 11 } }
local gm, gn = G.tube(pp, function(t) return 1.15 - 0.3 * t end)
gm:cut(pm)
local gtok = { r = { name = "peg" } }
X.tone(c, gm, X.light(gn, { amb = 0.15, wrap = 0.3 }), PEG, { cuts = { 0.25, 0.45, 0.65, 0.85 }, tok = gtok })
-- pigtail curl: 1px loop at the end
for _, q in ipairs{ { 30, 11, 3 }, { 29, 12, 3 }, { 29, 13, 2 }, { 30, 14, 2 }, { 31, 14, 2 } } do c:put(q[1], q[2], PEG[q[3]], gtok) end
-- quirk: soil crumb stuck in the curl
local stok = { r = { name = "soil" } }
for _, q in ipairs{ { 28, 14, 2 }, { 29, 15, 1 }, { 28, 15, 2 }, { 27, 15, 3 }, { 28, 16, 1 } } do c:put(q[1], q[2], SOIL[q[3]], stok) end
-- ambient seat where peg enters the pod
for _, q in ipairs{ { 33, 24 }, { 34, 24 }, { 33, 25 } } do if pm:has(q[1], q[2]) then c:put(q[1], q[2], POD[1], ptok) end end

-- seeds: glossy maroon with the white eye
local function seed(s, others, eye, tokname)
  local vis = s.m:copy()
  for _, o in ipairs(others) do vis:cut(o.m) end
  local b = {}
  for _, o in ipairs(others) do X.ao(b, vis, o.m, 1, -1) end
  local tok = { r = { name = tokname } }
  local idx = G.toneN(c, vis, s.n, RED, { bias = b, tok = tok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.06, wrap = 0.2 })
  -- waxy bloom: a soft band of the 5th tone just inside the lit rim
  local e = vis:edge()
  vis:each(function(x, y) local k = K(x, y) local dx, dy = x - s[1], y - s[2]
    if e:has(x, y) and dx + dy > 3.5 and dx > 0 and dy > 0 and not b[k] then c:put(x, y, COOL, tok) end end)
  -- specular
  local bx, by = G.specAt(vis, s.n, 50)
  if bx then c:put(bx, by, "#fff4d6", tok) c:put(bx + 1, by, RED[6], tok) c:put(bx, by + 1, RED[6], tok) end
  if eye then
    local ex, ey, ca, sa = eye[1], eye[2], cos(s[5]), sin(s[5])
    local em = G.rell(ex, ey, ca, sa, eye[3], eye[4])
    local rim = em:grow(1):cut(em)
    rim:each(function(x, y) if vis:has(x, y) then c:put(x, y, RED[1], tok) end end)
    em:each(function(x, y) if vis:has(x, y) then
      local up = (x - ex) + (y - ey) < 0
      c:put(x, y, up and "#f4ead2" or "#cdbfa8", tok) end end)
    -- dark seam along the eye
    local sx, sy = floor(ex + .5), floor(ey + .5)
    c:put(sx, sy, "#7a5a52", tok) c:put(sx + (ca > 0 and 1 or -1), sy, "#7a5a52", tok)
  end
end
seed(s2, { s1 }, { 47.5, 36, 1.9, 0.9 }, "seed2")
seed(s1, {}, { 38, 44, 2.2, 1.0 }, "seed1")
-- contact shadow of the front seed on the pod
s1.m:shift(-1, 0):each(function(x, y) if pm:has(x, y) and not s1.m:has(x, y) then c:put(x, y, POD[1], ptok) end end)

G.save2(c, NAME)
