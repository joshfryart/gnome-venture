-- ico-fountain (final, Opus): round stone garden fountain. Wide dressed-stone basin (rim, jointed blocks, shaded
-- inner wall), slim turned column with a plinth and a collar, small top bowl, a jet that crowns and falls in two arcs.
-- Material: cylinder-lit stone with block joints (dark seam + lit edge), rim bevel; water is glassy: bright lit rim,
-- pale core, darker back edge under the stone, ripple rings and splash marks. AO where column meets water / bowl.
-- quirk: a gold wishing coin glints on the basin floor.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_4.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, max, min, abs, floor = math.sqrt, math.max, math.min, math.abs, math.floor
local c = A.new("ico-fountain")
local STONE = { "#3e3f5a", "#5b5c78", "#7c7d97", "#a1a1b6", "#c5c4d4", "#e7e4ec" }
local SEA   = { "#26457a", "#2f66a6", "#3b8fc6", "#5fbfd6", "#98e2e6", "#d2f7f0" }
local GOLD  = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local st, wt = { r = { name = "stone" } }, { r = { name = "water" } }
local SC = { 0.34, 0.5, 0.65, 0.79, 0.91 }

c:groundShadow(32, 57, 22, 2)

-- basin wall (front) + rim
local CX, RY = 32, 44
local wall = c:ellipse(CX, RY, 23, 6):add(c:rect(9, RY, 55, 52)):add(c:ellipse(CX, 52, 23, 4))
local wn = {}
wall:each(function(x, y) local s = max(-0.96, min(0.96, (x - CX) / 23.5)) wn[K(x, y)] = { s, 0.15, sqrt(1 - s*s) } end)
local widx = A.shade(c, wall, wn, STONE, { cuts = SC, amb = 0.05, wrap = 0.2, tok = st })
-- block joints (foreshortened toward the sides) and a lower course line
for _, s in ipairs{ -0.82, -0.45, 0.0, 0.45, 0.82 } do
  local x = floor(CX + s * 23 + 0.5)
  for y = 49, 55 do if wall:has(x, y) then A.step(c, widx, STONE, x, y, -2, st) A.step(c, widx, STONE, x + 1, y, 1, st) end end
end
-- rim top surface: ring, lit from above, with a bevel lip on the front edge
local outer, inner = c:ellipse(CX, RY, 23, 6), c:ellipse(CX, RY, 20, 4)
local rim = outer:copy():cut(inner)
local rn = X.pillow(rim, 1.5)
for k, n in pairs(rn) do rn[k] = { A.norm(n[1] * 0.6, n[2] * 0.6 - 0.45, n[3]) } end
local ridx = A.shade(c, rim, rn, STONE, { cuts = SC, amb = 0.15, wrap = 0.3, tok = st })
rim:each(function(x, y) if not rim:has(x, y + 1) and y > RY then A.step(c, ridx, STONE, x, y, -1, st) end end)
-- inner wall strip at the back, then water
inner:each(function(x, y) c:put(x, y, y < RY - 1 and STONE[2] or STONE[3], st) end)
local water = c:ellipse(CX, RY + 0.6, 19, 3)
water:clip(inner)
local wnf = {}
water:each(function(x, y) local dx, dy = (x - CX) / 20, (y - RY - 0.6) / 3.6 wnf[K(x, y)] = { dx * 0.35, dy * 0.6 - 0.2, 1 } end)
for k, n in pairs(wnf) do wnf[k] = { A.norm(n[1], n[2], n[3]) } end
local qidx = A.shade(c, water, wnf, SEA, { cuts = { 0.3, 0.55, 0.72, 0.86, 0.95 }, amb = 0.2, wrap = 0.3, tok = wt })
water:each(function(x, y) if not water:has(x, y - 1) then c:put(x, y, SEA[1], wt) qidx[K(x, y)] = 1 end end) -- under the rim
-- ripple rings round the column foot
for _, p in ipairs{ { 25, 47 }, { 26, 48 }, { 38, 48 }, { 39, 47 }, { 27, 44 }, { 37, 44 } } do c:put(p[1], p[2], SEA[5], wt) end
-- quirk: wishing coin on the basin floor (seen through water)
c:put(43, 46, GOLD[3], wt) c:put(44, 46, GOLD[4], wt) c:put(42, 47, GOLD[2], wt) c:put(43, 47, GOLD[3], wt) c:put(44, 47, GOLD[2], wt)
c:put(44, 45, A.CREAM, wt)

-- column with plinth + collar
local col = c:rect(29, 29, 35, 45)
local plinth = c:rrect(27, 42, 37, 46, 1)
local collar = c:rect(28, 31, 36, 32)
local cidx = A.shade(c, col, A.vcyl(col, 32, 3.5), STONE, { cuts = SC, amb = 0.04, wrap = 0.18, tok = st })
local pidx = A.shade(c, plinth, A.vcyl(plinth, 32, 5.5), STONE, { cuts = SC, amb = 0.06, wrap = 0.2, tok = st })
for x = 27, 37 do A.step(c, pidx, STONE, x, 42, 1, st) A.step(c, pidx, STONE, x, 46, -1, st) end
A.sep(c, col, cidx, STONE, plinth, -2, st)
local kidx = A.shade(c, collar, A.vcyl(collar, 32, 4.5), STONE, { cuts = SC, amb = 0.06, wrap = 0.2, tok = st })
for x = 28, 36 do A.step(c, kidx, STONE, x, 32, -1, st) A.step(c, cidx, STONE, x, 33, -2, st) end
-- splash ring where the plinth meets water
for x = 26, 38 do if water:has(x, 47) and not plinth:has(x, 47) then A.step(c, qidx, SEA, x, 47, 2, wt) end end

-- top bowl: underside cup, rim, water
local cup = c:ellipse(32, 26, 11, 5) cup:cut(c:rect(0, 0, 63, 25))
local cupn = {}
cup:each(function(x, y) local s = max(-0.96, min(0.96, (x - 32) / 11.5)) cupn[K(x, y)] = { s, 0.4, sqrt(1 - s*s) } end)
local uidx = A.shade(c, cup, cupn, STONE, { cuts = SC, amb = 0.04, wrap = 0.18, tok = st })
A.sep(c, col, cidx, STONE, cup, -2, st)
local brim = c:ellipse(32, 25, 11, 3)
local bin = c:ellipse(32, 25, 9, 2)
local bn = {}
brim:each(function(x, y) bn[K(x, y)] = { A.norm((x - 32) / 14, -0.6, 0.75) } end)
local bidx = A.shade(c, brim, bn, STONE, { cuts = SC, amb = 0.2, wrap = 0.3, tok = st })
bin:each(function(x, y) c:put(x, y, y < 25 and SEA[2] or SEA[4], wt) end)
c:put(26, 25, SEA[5], wt) c:put(27, 25, SEA[5], wt)

-- jet + two falling arcs (glassy: lit rim, pale core)
local function stream(pts, wfn, lightCore)
  local m, n, T, S, idx = A.tube(c, pts, wfn, SEA, { tok = wt, cuts = { 0.25, 0.45, 0.62, 0.78, 0.9 }, amb = 0.2, wrap = 0.35 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.3 then c:put(x, y, SEA[lightCore], wt) end end)
  return m, idx
end
local jm = stream({ { 32, 25 }, { 32, 19 }, { 32, 14 }, { 32, 10 } }, function(t) return 1.25 end, 5)
local lm = stream({ { 31, 10 }, { 24, 5 }, { 17, 10 }, { 16, 32 } }, function(t) return 1.35 - t * 0.45 end, 5)
local rm = stream({ { 33, 10 }, { 40, 5 }, { 47, 10 }, { 48, 32 } }, function(t) return 1.35 - t * 0.45 end, 5)
-- crown of the jet
local crown = c:ellipse(32, 9, 3, 2)
crown:each(function(x, y) c:put(x, y, y <= 8 and SEA[6] or SEA[5], wt) end)
c:put(31, 8, A.CREAM, wt)
-- falling drops below each arc
for _, d in ipairs{ { 15, 35 }, { 48, 35 } } do
  c:put(d[1], d[2], SEA[5], wt) c:put(d[1] + 1, d[2], SEA[4], wt) c:put(d[1], d[2] + 1, SEA[4], wt) c:put(d[1] + 1, d[2] + 1, SEA[3], wt)
end
-- splash marks where arcs land
for _, p in ipairs{ { 13, 44 }, { 17, 44 }, { 47, 44 }, { 51, 44 }, { 14, 46 }, { 50, 46 } } do
  if water:has(p[1], p[2]) or rim:has(p[1], p[2]) then c:put(p[1], p[2], SEA[6], wt) end end
-- separation of streams from the stone they pass in front of
for _, m in ipairs{ lm, rm } do
  A.sep(c, rim, ridx, STONE, m, -2, st)
end
A.save(c, "ico-fountain")
