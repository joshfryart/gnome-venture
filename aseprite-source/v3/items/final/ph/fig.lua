-- fig (final, Opus aB31_2). A slim teardrop fig: revolved-body light (narrow green-washed neck swelling to a deep
-- purple base), faint meridian ribs, waxy lavender bloom speckle on the lit side, one specular, cool reflected light
-- on the lower right, dark ostiole eye at the base. Short woody stem with a pale cut end; a three-lobed fig leaf
-- behind (midrib + lobe veins, AO and contact shadow where the fig neck crosses it).
-- quirk: a bead of amber nectar hangs from the eye.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, cos, pi, sqrt = math.floor, math.abs, math.max, math.min, math.sin, math.cos, math.pi, math.sqrt
local NAME = "fig"
local c = A.new(NAME)
local PUR = { "#2a1838", "#45204f", "#62296a", "#813a86", "#a25aa4", "#c88cc6" }
local NECK = { "#26301f", "#3b4a2b", "#566635", "#768444", "#9aa456", "#c6c87a" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local WOOD = { "#3e2a22", "#5e3f2c", "#83593a", "#a87a50", "#d0a676" }
local BLOOM, COOL, VEIN = "#b8a4d8", "#5d6aaa", "#c2e48c"

-- body of revolution: axis x = CX, y from Y0 (neck top) to Y1 (base)
local CX, Y0, Y1, W = 28, 17, 52, 12
local function wy(y)
  local t = (y - Y0) / (Y1 - Y0)
  if t < 0 or t > 1 then return -1 end
  if t < 0.68 then local u = t / 0.68 return 2.0 + (W - 2.0) * sin(pi / 2 * u) ^ 1.7 end
  local u = (t - 0.68) / 0.32
  return W * sqrt(max(0, 1 - u ^ 2.2))
end
local fm, fn, FS = HP.mask(), {}, {}
for y = Y0, Y1 do
  local w = wy(y + 0.5)
  local dw = (wy(min(Y1, y + 1.5)) - wy(max(Y0, y - 0.5))) / 2
  for x = floor(CX - w - 1), floor(CX + w + 1) do
    local s = (x + 0.5 - CX) / (w + 0.3)
    if abs(s) <= 1 and w > 0 then
      fm:set(x, y)
      local k = K(x, y)
      local nx, ny, nz = s, -dw * 0.9, sqrt(max(0.02, 1 - s * s))
      if y >= Y1 - 1 then ny = ny + 0.6 end
      local l = sqrt(nx*nx + ny*ny + nz*nz)
      fn[k] = { nx / l, ny / l, nz / l } FS[k] = s
    end
  end
end

-- leaf behind (upper right): three lobes from a base near the neck
local lm = HP.mask()
local BX, BY = 33, 21
local lobes = { { 51, 17, 4.6 }, { 44, 6, 3.9 }, { 52, 29, 3.6 } }
for _, l in ipairs(lobes) do
  local dx, dy = l[1] - BX, l[2] - BY
  local L = sqrt(dx*dx + dy*dy) local ux, uy = dx / L, dy / L
  lm:add(A.rell(BX + dx * 0.56, BY + dy * 0.56, ux, uy, L * 0.5, l[3]))
end
lm:add(A.rell(BX + 5, BY - 1, 1, 0, 5, 4.5))
local ln = X.pillow(lm, 2.2)
local lbias = {}
X.ao(lbias, lm, fm, 1, -1) A.cast(lbias, lm, fm, 2, 1, -1)
local ltok = A.tok("leaf")
local lidx = X.tone(c, lm, X.light(ln, { amb = 0.15, wrap = 0.3 }), LEAF, { cuts = { 0.15, 0.32, 0.5, 0.68, 0.84 }, bias = lbias, tok = ltok })
for _, l in ipairs(lobes) do
  local pts = { { BX + 1, BY }, { BX + (l[1] - BX) * 0.85, BY + (l[2] - BY) * 0.85 } }
  HP.line(pts, 1):each(function(x, y) if lm:has(x, y) and not lm:edge():has(x, y) and not fm:has(x, y) then
    c:put(x, y, lbias[K(x, y)] and LEAF[3] or VEIN, ltok) end end)
  -- side veins: one pair per lobe
  local mx, my = BX + (l[1] - BX) * 0.5, BY + (l[2] - BY) * 0.5
  local dx, dy = l[1] - BX, l[2] - BY local L = sqrt(dx*dx + dy*dy) dx, dy = dx / L, dy / L
  for _, sd in ipairs{ 1, -1 } do
    local ex, ey = mx + dx * 3 + (-dy) * sd * 2.6, my + dy * 3 + dx * sd * 2.6
    HP.line({ { mx, my }, { ex, ey } }, 1):each(function(x, y) if lm:has(x, y) and not lm:edge():has(x, y) and not fm:has(x, y) then
      c:put(x, y, LEAF[min(6, (lidx[K(x, y)] or 3) + 1)], ltok) end end)
  end
end
lm:edge():each(function(x, y) local k = K(x, y) if (lidx[k] or 6) <= 3 and x + y > BX + BY + 14 then c:put(x, y, "#2f6a63", ltok) end end)

-- stem (over the leaf base)
local stok = A.tok("stem")
local sm, sn = A.tube({ {28, 18}, {28, 15}, {29, 12}, {31, 10} }, function(t) return 1.3 - 0.2 * t end)
local sidx = X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), WOOD, { cuts = { 0.25, 0.45, 0.65, 0.82 }, tok = stok })
c:put(31, 9, WOOD[5], stok) c:put(32, 10, WOOD[4], stok) c:put(31, 10, "#e8c898", stok) c:put(32, 9, WOOD[4], stok)

-- fig body
local ftok = A.tok("fig")
local v = X.light(fn, { amb = 0.08, wrap = 0.35 })
local cuts = { 0.16, 0.33, 0.5, 0.66, 0.82 }
local fidx = {}
fm:each(function(x, y) local k = K(x, y)
  local i = A.q(v[k], cuts)
  local neckLine = Y0 + 9 + 1.6 * sin(x * 1.3)
  local R = (y < neckLine) and NECK or PUR
  if y < neckLine and y > neckLine - 2.2 and (x % 3 == 0) then R = PUR end
  fidx[k] = i
  c:put(x, y, R[i], ftok)
end)
-- meridian ribs: faint lines following s = const
for _, s0 in ipairs{ -0.62, -0.22, 0.2, 0.58 } do
  for y = Y0 + 7, Y1 - 3 do local w = wy(y + 0.5)
    local x = floor(CX + s0 * (w + 0.3) - 0.5 + 0.5)
    local k = K(x, y)
    if fm:has(x, y) and fidx[k] and y > Y0 + 9 then
      local i = fidx[k] + (s0 < 0 and -1 or -1)
      c:put(x, y, PUR[max(1, min(6, i))], ftok)
    end
  end
end
-- waxy bloom: sparse pale speckle on the lit upper body
fm:each(function(x, y) local k = K(x, y)
  if y > Y0 + 11 and fidx[k] >= 4 and fidx[k] <= 5 and X.hash(x, y, 7) > 0.84 then c:put(x, y, BLOOM, ftok) end end)
-- cool reflected light on the lower right rim
fm:edge():each(function(x, y) local k = K(x, y)
  if FS[k] > 0.55 and y > Y0 + 14 and y < Y1 - 1 then c:put(x, y, COOL, ftok) end end)
-- specular: 2x1 bright + soft partner
do local x, y = 22, 33
  c:put(x, y, "#f2d6f0", ftok) c:put(x + 1, y, PUR[6], ftok) c:put(x, y + 1, PUR[6], ftok)
  c:put(x + 2, y - 2, "#fff4d6", ftok)
end
-- ostiole eye at the base
for _, p in ipairs{ {27, 51, "#1e0f24"}, {28, 51, "#1e0f24"}, {26, 51, PUR[2]}, {29, 51, PUR[2]}, {27, 50, PUR[2]}, {28, 50, "#c25a7a"} } do
  c:put(p[1], p[2], p[3], ftok) end
-- ambient band where neck meets stem
for x = 26, 30 do if fm:has(x, Y0) then c:put(x, Y0, NECK[1], ftok) end end

-- quirk: nectar bead under the eye
local ntok = A.tok("nectar")
for _, p in ipairs{ {27, 53, "#d98322"}, {28, 53, "#b8641c"}, {27, 54, "#f5b82e"}, {28, 54, "#d98322"}, {27, 55, "#ffe38a"}, {28, 55, "#b8641c"}, {27, 56, "#d98322"}, {28, 56, "#8f4a1f"} } do
  c:put(p[1], p[2], p[3], ntok) end

A.save(c, NAME)
