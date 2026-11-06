-- green-bean (aC10_0, Opus single pass). One slim S-curved snap-bean pod, bottom-left calyx to a wiry top-right
-- tail. Per-pixel cylinder light plus bulge normals over five seeds (bumps catch light on the upper side, pinch
-- into AO between), a suture groove along the shade side, waxy bloom specks, one specular streak, cool reflected
-- light on the lower edge. Olive calyx with sepals lying on the pod (AO under them), a short stem with a pale cut end.
-- quirk: a single dewdrop sits on the pod's shoulder.
local NAME = "green-bean"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, exp = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.exp
local c = G.new2(NAME)

local GRN  = { "#1b3d36", "#285b3c", "#387a3f", "#509b42", "#79bb4f", "#b0dc78" }
local BLOOM, COOL, SPEC = "#cfe8a8", "#4f8f8a", "#f4fbd8"
local CAL  = { "#2c3622", "#45532a", "#647534", "#8a9d45", "#b6c56a" }
local STEM = { "#3a4a2a", "#5e7238", "#8aa04c", "#d8d49a" }

local P = { { 15, 49 }, { 21, 29 }, { 41, 37 }, { 51, 13 } }
local SEEDS = { 0.2, 0.355, 0.51, 0.665, 0.81 }
local function bump(t)
  local b = 0
  for _, s in ipairs(SEEDS) do b = b + exp(-((t - s) / 0.05) ^ 2) end
  return b
end
local function W(t)
  local env = sin(pi * min(1, t * 0.96 + 0.035)) ^ 0.45
  return 0.55 + env * (2.05 + 0.75 * bump(t))
end
local pm, pn, PT, PS, sm = G.tube(P, W, 220)
-- approximate arc length for the along-axis slope of the bumps
local len = 0
for i = 2, #sm do len = len + sqrt((sm[i].x - sm[i - 1].x) ^ 2 + (sm[i].y - sm[i - 1].y) ^ 2) end
pm:each(function(x, y) local k = K(x, y)
  local t = PT[k]
  local s = sm[floor(t * (#sm - 1) + 0.5) + 1]
  local g = (W(min(1, t + 0.01)) - W(max(0, t - 0.01))) / (0.02 * len)
  local nn = pn[k]
  local nx, ny, nz = nn[1] - g * s.tx * 1.4, nn[2] - g * s.ty * 1.4, nn[3]
  local l = sqrt(nx * nx + ny * ny + nz * nz)
  pn[k] = { nx / l, ny / l, nz / l }
end)

-- calyx + stem masks first (needed for AO on the pod)
local s0 = sm[1]
local cx, cy = s0.x - s0.tx * 0.6, s0.y - s0.ty * 0.6
local calyx = G.rell(cx, cy, s0.tx, s0.ty, 2.2, 3.3)
local sepals = HP.mask()
for _, q in ipairs{ { -1, 4.6 }, { 1, 4.2 }, { -0.2, 5.4 } } do
  local side, L = q[1], q[2]
  for i = 0, 6 do
    local f = i / 6
    local px = cx + s0.tx * (L * f) + (-s0.ty) * side * (2.4 - f * 1.6)
    local py = cy + s0.ty * (L * f) + (s0.tx) * side * (2.4 - f * 1.6)
    sepals:set(floor(px + 0.5), floor(py + 0.5))
  end
end
local stemP = { { cx, cy }, { cx - s0.tx * 2, cy - s0.ty * 2 + 0.5 }, { cx - s0.tx * 4 - 1, cy - s0.ty * 4 + 1 }, { cx - s0.tx * 5.5 - 2, cy - s0.ty * 5.5 + 1.2 } }
local stm, stn = G.tube(stemP, function(t) return 1.05 end, 60)
stm:cut(calyx)

local bias = {}
X.ao(bias, pm, calyx, 1, -1)
X.ao(bias, pm, sepals, 1, -1)
-- pinches between seeds on the shade half, suture groove along the shade side
pm:each(function(x, y) local k = K(x, y)
  local t, s = PT[k], PS[k]
  if bump(t) < 0.12 and t > 0.25 and t < 0.78 and s > 0.25 then bias[k] = (bias[k] or 0) - 1 end
  if s > 0.42 and s < 0.6 and t > 0.08 and t < 0.93 then bias[k] = (bias[k] or 0) - 1 end
end)
local ptok = { r = { name = "pod" } }
local v = X.light(pn, { amb = 0.1, wrap = 0.28 })
local pidx = X.tone(c, pm, v, GRN, { cuts = { 0.22, 0.38, 0.54, 0.7, 0.85 }, bias = bias, tok = ptok })
-- waxy bloom specks on the lit side
pm:copy():shrink(1):each(function(x, y) local k = K(x, y)
  if pidx[k] >= 4 and PS[k] < -0.1 and X.hash(x, y, 7) > 0.86 then c:put(x, y, BLOOM, ptok) end end)
-- cool reflected light along the lower edge
local rim = X.rim(pn)
pm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.62 and PT[k] > 0.12 and PT[k] < 0.9 and not bias[k] then c:put(x, y, COOL, ptok) end end)
-- specular streak on the brightest seed bump
local bx, by = G.specAt(pm, pn, 50)
c:put(bx, by, SPEC, ptok) c:put(bx + 1, by, SPEC, ptok)

-- wiry tail beyond the tip
local e = sm[#sm]
local tail = { { e.x + 1, e.y - 2, 3 }, { e.x + 2, e.y - 3, 4 }, { e.x + 3, e.y - 4, 4 }, { e.x + 4, e.y - 4, 3 }, { e.x + 5, e.y - 3, 2 } }
for _, q in ipairs(tail) do c:put(floor(q[1] + 0.5), floor(q[2] + 0.5), GRN[q[3]], ptok) end

-- stem (behind calyx), pale cut end
local ttok = { r = { name = "stem" } }
X.tone(c, stm, X.light(stn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.85 }, tok = ttok })
do local q = stemP[4] c:put(floor(q[1] + 0.5), floor(q[2] + 0.5), STEM[4], ttok) end
-- calyx dome and sepals
local ctok = { r = { name = "calyx" } }
G.toneN(c, calyx, X.pillow(calyx, 1.6), CAL, { tok = ctok, cuts = { 0.22, 0.42, 0.62, 0.82 }, amb = 0.12 })
sepals:cut(calyx)
sepals:each(function(x, y) c:put(x, y, (x + y) % 3 == 0 and CAL[4] or CAL[3], ctok) end)

-- quirk: dewdrop on the upper shoulder of the pod
local dx, dy = G.bez(P, 0.43)
dx, dy = floor(dx - 2), floor(dy - 3.5)
local drop = { ".ab.", "acbb", "abbd", ".dd." }
local map = { a = "#6fb7b0", b = "#b8ece0", c = "#fff4d6", d = "#2f6a73" }
for j, row in ipairs(drop) do for i = 1, 4 do local ch = row:sub(i, i)
  if map[ch] then c:put(dx + i - 1, dy + j - 1, map[ch], ptok) end end end

G.save2(c, NAME)
