-- fiddleheads (final, Opus aB31_2). A bundle of three ostrich-fern croziers: slim grooved stems, tight coils
-- (outer two curl outward, middle one bows over), brown papery chaff at the neck, pale cut ends, tied with twisted twine
-- whose loose end hangs to the right. Per-pixel light, seams darkened where the coil touches itself.
-- quirk: a ladybird is climbing the right stem.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos = math.floor, math.abs, math.max, math.min, math.sin, math.cos
local NAME = "fiddleheads"
local c = A.new(NAME)
local FERN = { "#1d3b2c", "#2a5a34", "#3f7d38", "#61a03e", "#8cc44c", "#c3e47a" }
local CHAFF = { "#5a3424", "#8a5530", "#b88050", "#dcb07a" }
local TW = { "#5a3a22", "#86592e", "#b07f40", "#d2a55a", "#ecc983", "#fbe7b4" }
local COOL = "#3f7a78"
local CUTS = { 0.2, 0.38, 0.55, 0.71, 0.86 }

local SJ = 40 / 130
local function wfn(t)
  if t < SJ then return 1.25 + 0.35 * (t / SJ) end
  local u = (t - SJ) / (1 - SJ)
  return 1.85 - 0.75 * u
end
local defs = {
  { p = { {27, 57}, {27, 48}, {21, 40}, {21, 30} }, dir = 1, R = 5.3 },
  { p = { {35, 57}, {36, 48}, {44, 41}, {45, 32} }, dir = -1, R = 5.3 },
  { p = { {31, 57}, {31, 47}, {33, 34}, {36, 22} }, dir = 1, R = 5.6 },
}
-- twine band
local tw = HP.mask()
for y = 45, 49 do for x = 25, 38 do
  if not ((y == 45 or y == 49) and (x == 25 or x == 38)) then tw:set(x, y) end end end
local tail = { {38, 47}, {41, 50}, {39, 54}, {42, 58} }
local tm, tn, TT, TS = A.tube(tail, function(t) return 0.85 end)
tm:cut(tw)

local cro = {}
for i, d in ipairs(defs) do
  local sm = A.crozier(d.p, d.dir, d.R, 1.28, wfn)
  local m, n, T, S = A.ptube(sm)
  cro[i] = { m = m, n = n, T = T, S = S, d = d }
end
-- paint stems: later ones on top
for i, cr in ipairs(cro) do
  local bias = {}
  for j = i + 1, #cro do X.ao(bias, cr.m, cro[j].m, 1, -1) end
  X.ao(bias, cr.m, tw, 1, -1)
  A.cast(bias, cr.m, tw, 1, 1, -1)
  local tok = A.tok("crozier" .. i)
  local vis = cr.m:copy()
  for j = i + 1, #cro do vis:cut(cro[j].m) end
  local idx = X.tone(c, vis, X.light(cr.n, { amb = 0.1, wrap = 0.3 }), FERN, { cuts = CUTS, bias = bias, tok = tok })
  A.seams(c, vis, cr.T, idx, FERN, tok, 0.14)
  vis:each(function(x, y) local k = K(x, y) local t, s = cr.T[k], cr.S[k]
    -- grooved stem: dark U-channel just right of centre, lit ridge to its left
    if t < SJ - 0.02 and t > 0.05 and not bias[k] then
      if s > 0.02 and s < 0.4 then c:put(x, y, FERN[max(1, idx[k] - 2)], tok)
      elseif s < -0.25 and s > -0.62 then c:put(x, y, FERN[min(6, idx[k] + 1)], tok) end
    end
    -- cool bounce on the outer shade edge
    if s > 0.8 and t > 0.08 and not bias[k] and idx[k] <= 3 then c:put(x, y, COOL, tok) end
    -- fresh cut end
    if y >= 56 then c:put(x, y, (s < -0.3) and "#e6f2b8" or "#c8e094", tok) end
  end)
  -- papery chaff flakes at the neck where stem meets coil
  local ftok = A.tok("chaff" .. i)
  local x, y = A.bez(cr.d.p, 0.9)
  local dx = -cr.d.dir
  for _, f in ipairs{ {0, 0, 3}, {dx, 0, 4}, {dx, 1, 2}, {0, -2, 3}, {-dx, 3, 2} } do
    local px, py = floor(x + 0.5) + f[1] + (i == 3 and -1 or 0), floor(y + 0.5) + f[2]
    if vis:has(px, py) then c:put(px, py, CHAFF[f[3]], ftok) end
  end
  cr.vis, cr.idx = vis, idx
end
-- specular on the middle coil + a dew-free cream glint
do local cr = cro[3]
  local sx, sy = A.specAt(cr.vis, cr.n, 30)
  c:put(sx, sy, "#effad0", A.tok("crozier3")) c:put(sx + 1, sy, FERN[6], A.tok("crozier3"))
end

-- twine wrap: cylinder across the bundle, diagonal twist strands
local ttok = A.tok("twine")
tw:each(function(x, y)
  local nx = (x - 31.5) / 7.5
  local ny = (y - 47) / 3.2
  local n = { nx * 0.8, ny * 0.6, math.sqrt(max(0.05, 1 - nx*nx * 0.64 - ny*ny * 0.36)) }
  local L = X.L
  local v = max(0, n[1]*L[1] + n[2]*L[2] + n[3]*L[3])
  local i = A.q(v, { 0.15, 0.35, 0.55, 0.72, 0.88 })
  if (x + y * 2) % 4 == 0 then i = i - 2 elseif (x + y * 2) % 4 == 1 then i = i + 1 end
  c:put(x, y, TW[max(1, min(6, i))], ttok)
end)
local tidx = X.tone(c, tm, X.light(tn, { amb = 0.15, wrap = 0.3 }), TW, { cuts = { 0.2, 0.4, 0.58, 0.74, 0.9 }, tok = ttok })
tm:each(function(x, y) if (x + y) % 3 == 0 then c:put(x, y, TW[max(1, tidx[K(x, y)] - 2)], ttok) end end)
-- frayed end
c:put(43, 59, TW[4], ttok) c:put(41, 59, TW[3], ttok)

-- quirk: ladybird on the right stem (head up-left, climbing)
local lt = A.tok("ladybird")
local LB = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
for _, p in ipairs{ {42, 41, 3}, {43, 41, 3}, {44, 41, 2}, {41, 42, 3}, {42, 42, 4}, {43, 42, 3}, {44, 42, 2},
  {41, 43, 2}, {42, 43, 3}, {43, 43, 2}, {44, 43, 1} } do c:put(p[1], p[2], LB[p[3]], lt) end
c:put(42, 42, LB[4], lt)
c:put(43, 42, A.INK, lt) c:put(42, 41, "#ffb48a", lt)
c:put(41, 41, A.INK, lt) c:put(40, 41, A.INK, lt) c:put(40, 40, "#4a3442", lt)
c:put(44, 43, A.INK, lt)

A.save(c, NAME)
