-- ico-finish (final, Opus). A slim wooden pole planted upright with a gold ball finial, flying a chequered finish
-- flag that ripples out to the right in two soft waves; the pole stands on a 2-tone ground shadow.
-- Material: pole = per-pixel cylinder light, 6-tone wood with grain streaks and a paler cut-end under the finial;
-- finial = 6-tone polished gold sphere with specular + glint; flag = cloth normals from the ripple (vertical fold
-- bands) snapped to two 6-tone ramps (cream / night-violet checks), diagonal weave lines on the cream squares, a
-- sleeve hem wrapped round the pole with a gold stitch, AO where the sleeve meets the pole and in each fold trough.
-- quirk: the free corner is frayed and one loose thread trails off it, twisting in the wind.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, sin, cos, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new("ico-finish")
local WD = { "#4a2a2a", "#6e3f30", "#94603e", "#b97a4a", "#d89c62", "#efc08a" }
local GD = { "#7a3d1f", "#b0601f", "#d98322", "#f5b82e", "#ffd96a", "#fff0b0" }
local CR = { "#8a7086", "#b59c9e", "#d8c3b4", "#eee0c8", "#fbf0d6", "#fffaea" }
local NV = { "#120e22", "#1c1632", "#282044", "#372c5a", "#4a3d74", "#635490" }
local ptok, gtok, ftok = A.tok("pole"), A.tok("gold"), A.tok("flag")

local PX, PY0, PY1 = 15, 11, 55
c:groundShadow(PX + 2, PY1 + 1, 7, 1)

-- flag cloth geometry: u across (0 at pole .. 1 free edge), v down (0..1)
local FX0, FW, FY0, FH = PX + 2, 34, 12, 23
local function wave(u) return 2.6 * u * sin(u * 2 * pi * 1.05 - 0.4) end           -- vertical offset
local function dwave(u) return 2.6 * (sin(u * 2 * pi * 1.05 - 0.4) + u * 2 * pi * 1.05 * cos(u * 2 * pi * 1.05 - 0.4)) end
local function hgt(u) return FH * (1 - 0.12 * u) end                                -- droops a little toward the tip
local fm, fn, FU, FV = HP.mask(), {}, {}, {}
for x = FX0, FX0 + FW do
  local u = (x - FX0) / FW
  local top = FY0 + wave(u) + (FH - hgt(u)) * 0.25
  local bot = top + hgt(u)
  for y = floor(top + .5), floor(bot + .5) do
    -- frayed free corner: bottom-right bites
    local fray = (u > 0.93 and y > bot - 4 and ((x + y) % 2 == 0 or y > bot - 1.5))
    if not fray then
      fm:set(x, y)
      local k = K(x, y)
      local slope = dwave(u) / FW * 2.2       -- ripple tilts the cloth's normal left/right
      fn[k] = { A.norm(-slope * 1.3, -0.15, 1) }
      FU[k], FV[k] = u, (y - top) / hgt(u)
    end
  end
end
local v = A.val(fn, { amb = 0.1, wrap = 0.3, tilt = { 34, 22, 20, 0.06 } })
local bias = {}
fm:each(function(x, y) local k = K(x, y)
  if x <= FX0 + 1 then bias[k] = -1 end                   -- AO beside the sleeve
end)
local cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local COLS, ROWS = 5, 4
fm:each(function(x, y) local k = K(x, y)
  local ci, ri = floor(FU[k] * COLS * 0.999), floor(min(0.999, max(0, FV[k])) * ROWS)
  local R = ((ci + ri) % 2 == 0) and NV or CR
  local i = 1
  for j, t in ipairs(cuts) do if v[k] >= t then i = j + 1 end end
  i = max(1, min(6, i + (bias[k] or 0)))
  -- diagonal weave on the cream squares
  if R == CR and (x + y) % 5 == 0 and i > 2 then i = i - 1 end
  c:put(x, y, R[i], ftok)
end)
-- top hem: lit edge row; bottom edge: one darker row (cloth thickness)
for x = FX0, FX0 + FW do
  local u = (x - FX0) / FW
  local top = floor(FY0 + wave(u) + (FH - hgt(u)) * 0.25 + .5)
  local bot = floor(FY0 + wave(u) + (FH - hgt(u)) * 0.25 + hgt(u) + .5)
  if fm:has(x, top) then local k = K(x, top)
    local ci = floor(u * COLS * 0.999) local R = (ci % 2 == 0) and NV or CR
    c:put(x, top, R[min(6, (R == NV) and 5 or 6)], ftok) end
  if fm:has(x, bot) then local ci, ri = floor(u * COLS * 0.999), ROWS - 1
    local R = ((ci + ri) % 2 == 0) and NV or CR c:put(x, bot, R[2], ftok) end
end
-- quirk: loose thread trailing from the frayed corner, 2-tone twist
do local x, y = FX0 + FW, floor(FY0 + wave(1) + FH * 0.03 + hgt(1) - 1)
  local th = { { 1, 0 }, { 2, 1 }, { 3, 1 }, { 4, 2 }, { 5, 2 }, { 6, 3 }, { 7, 3 }, { 8, 3 } }
  for i, p in ipairs(th) do c:put(x + p[1], y + p[2], (i % 2 == 0) and CR[3] or CR[5], ftok) end
end

-- sleeve hem wrapped round the pole (cloth cylinder, cream) with a gold stitch line
local sm = HP.mask()
for y = FY0 - 1, FY0 + FH + 1 do for x = PX - 2, PX + 2 do sm:set(x, y) end end
local sn = {}
sm:each(function(x, y) local s = (x - PX) / 2.9 sn[K(x, y)] = { s, 0, sqrt(max(0.05, 1 - s * s)) } end)
local sb = {}
sm:each(function(x, y) if y == FY0 - 1 or y == FY0 + FH + 1 then sb[K(x, y)] = -1 end end)
A.shade(c, sm, sn, CR, { tok = A.tok("sleeve"), amb = 0.12, wrap = 0.3, cuts = cuts, bias = sb })
for y = FY0 + 1, FY0 + FH - 1 do if (y - FY0) % 3 ~= 0 then c:put(PX + 1, y, GD[3], A.tok("sleeve")) end end

-- pole (painted above and below the sleeve)
local pm = HP.mask()
for y = PY0, PY1 do for x = PX - 1, PX + 1 do if not sm:has(x, y) then pm:set(x, y) end end end
local pn = {}
pm:each(function(x, y) local s = (x - PX) / 1.9 pn[K(x, y)] = { s, 0, sqrt(1 - s * s) } end)
local pb = {}
pm:each(function(x, y) if y == FY0 + FH + 2 or y == PY0 + 1 then pb[K(x, y)] = -1 end   -- AO under the sleeve / finial
  if y >= PY1 - 1 then pb[K(x, y)] = -1 end end)
local pidx = A.shade(c, pm, pn, WD, { tok = ptok, amb = 0.1, wrap = 0.35, cuts = { 0.15, 0.3, 0.48, 0.66, 0.84 }, bias = pb })
-- grain streaks
for _, g in ipairs{ { PX, 39, 4 }, { PX + 1, 45, 3 }, { PX, 50, 3 }, { PX - 1, 42, 2 } } do
  for y = g[2], g[2] + g[3] - 1 do local k = K(g[1], y) if pidx[k] then A.step(c, pidx, WD, g[1], y, -1, ptok) end end
end
c:put(PX, 48, WD[2], ptok) -- knot
-- finial: gold ball on a little collar
local gm, gn = A.oval(PX + 0.0, PY0 - 3, 3.2, 3.2, 0)
local gidx = A.shade(c, gm, gn, GD, { tok = gtok, amb = 0.12, wrap = 0.35, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 } })
for x = PX - 2, PX + 2 do c:put(x, PY0, (x == PX - 2) and GD[5] or (x == PX + 2 and GD[2] or GD[3]), gtok) end
c:put(PX - 1, PY0 - 5, GD[6], gtok) c:put(PX - 2, PY0 - 4, A.CREAM, gtok) c:put(PX - 1, PY0 - 4, GD[6], gtok)
-- bottom: the pole sinks into a tiny tuft of grass
A.map(c, { "g.G.g", "gGGGg" }, PX - 2, PY1 - 1, { g = "#3f9150", G = "#7cc35a" }, A.tok("grass"))
A.save(c, "ico-finish")
