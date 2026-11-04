-- reindeer-lichen (final, Sonnet high, D12-1). A pale sage-grey cushion of reindeer lichen (Cladonia rangiferina) on a
-- crumbling clod of dark peat: a dome built from ~30 fluffy tip-puffs, each a lit sphere with thin darker twig lines
-- radiating inside and a cream tip, creases between neighbours, shaded toward the peat. Five forked antler-like
-- branches (2 px wide, two levels of forking) rise from the crown with pale knob tips.
-- quirk: two tiny red-capped "British soldier" cups stand guard on the cushion's shoulders.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_1.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("reindeer-lichen")
local LI = { "#2e4640", "#4e6c62", "#76968a", "#a2bfae", "#c8dcc4", "#eef6e2" }
local PEAT = { "#1e1420", "#34222c", "#4e3438", "#6e4a44", "#8e6654", "#b08468" }
local RED = { "#6a1e2a", "#b22e30", "#e04a36", "#ff7a54" }
local rnd = A.rng(41)
c:groundShadow(32, 58, 19, 2.5)

-- peat clod
local clod = HP.mask()
clod:add(c:ellipse(32, 55, 15, 3.8)):add(c:ellipse(23, 53, 6, 3)):add(c:ellipse(42, 53, 6, 3))
local cn = X.pillow(clod, 3.4, 0.9)
local cidx = A.shade(c, clod, cn, PEAT, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, amb = 0.1, wrap = 0.3 })
clod:each(function(x, y) local h = X.hash(x, y, 9) local k = K(x, y)
  if h > 0.88 then c:px(x, y, PEAT[min(6, (cidx[k] or 3) + 1)]) elseif h < 0.09 then c:px(x, y, PEAT[max(1, (cidx[k] or 3) - 1)]) end end)
-- a bright speck of moss on the peat
c:px(19, 55, "#5a8a4a") c:px(20, 55, "#7aaa5a") c:px(20, 54, "#5a8a4a") c:px(44, 55, "#5a8a4a") c:px(45, 55, "#7aaa5a")

-- antlers first (the cushion hides their feet)
local function branch(x, y, ang, len, depth)
  local x2, y2 = x + cos(ang) * len, y + sin(ang) * len
  local m = HP.mask()
  A.lineMask(m, floor(x + .5), floor(y + .5), floor(x2 + .5), floor(y2 + .5), 2)
  local lit = LI[depth >= 2 and 4 or 5]
  local sh = LI[depth >= 2 and 2 or 3]
  m:each(function(px, py)
    if not m:has(px - 1, py) then c:px(px, py, lit) elseif not m:has(px, py + 1) then c:px(px, py, sh) else c:px(px, py, LI[3]) end
  end)
  if depth == 0 then
    c:px(floor(x2 + .5), floor(y2 + .5), LI[6]) c:px(floor(x2 + .5), floor(y2 + .5) - 1, LI[6])
    return
  end
  for i = 1, 2 do
    local da = (i == 1 and -1 or 1) * (0.5 + rnd() * 0.18)
    branch(x2, y2, ang + da, len * 0.72, depth - 1)
  end
end
branch(23, 42, -pi / 2 - 0.62, 7.2, 2)
branch(28, 40, -pi / 2 - 0.22, 8.8, 2)
branch(33, 40, -pi / 2 + 0.05, 9.6, 2)
branch(38, 40, -pi / 2 + 0.3, 8.6, 2)
branch(43, 42, -pi / 2 + 0.66, 7.2, 2)

-- dome of puffs
local DX, DY, RX, RY = 32, 50, 17, 14
local puffs = {}
local row = 0
for gy = 37, 51, 3.1 do
  row = row + 1
  for gx = 16 + (row % 2) * 1.8, 49, 3.4 do
    local x, y = gx + (rnd() - 0.5) * 1.6, gy + (rnd() - 0.5) * 1.4
    local q = ((x - DX) / RX) ^ 2 + ((y - DY) / RY) ^ 2
    if q <= 1.0 and y < 52 then puffs[#puffs + 1] = { x, y, 2.5 + rnd() * 0.9 + (1 - q) * 0.5 } end
  end
end
table.sort(puffs, function(a, b) if floor(a[2]) ~= floor(b[2]) then return a[2] < b[2] end return a[1] < b[1] end)
local dome, PID = HP.mask(), {}
for i, p in ipairs(puffs) do
  local m = c:ellipse(p[1], p[2], p[3], p[3] * 0.92)
  p.m = m
  m:each(function(x, y) dome:set(x, y) PID[K(x, y)] = i end)
end
-- normals: broad dome form blended with each puff's own sphere
local dn = X.pillow(dome, 8, 1.0)
local N = {}
dome:each(function(x, y) local k = K(x, y)
  local p = puffs[PID[k]]
  local nx, ny = (x + 0.5 - p[1]) / (p[3] + 0.6), (y + 0.5 - p[2]) / (p[3] + 0.6)
  local q = 1 - nx * nx - ny * ny
  local sx, sy, sz = nx, ny, sqrt(max(q, 0.05))
  local d = dn[k]
  N[k] = { A.norm(d[1] * 0.9 + sx * 0.8, d[2] * 0.9 + sy * 0.8, d[3] * 0.9 + sz * 0.8) }
end)
local bias = {}
dome:each(function(x, y) local k = K(x, y)
  -- toward the peat: darker; lower-right: darker
  local dyb = (y - 46) / 6
  if dyb > 0 then bias[k] = -floor(dyb * 2.2 + 0.2) end
end)
local didx = A.shade(c, dome, N, LI, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 }, bias = bias, amb = 0.1, wrap = 0.3 })
dome:each(function(x, y) local k = K(x, y)
  local i = didx[k] or 3
  local id = PID[k]
  -- crease between puffs
  local l, u = PID[K(x - 1, y)], PID[K(x, y - 1)]
  if (l and l ~= id and l < id) or (u and u ~= id and u < id) then c:px(x, y, LI[max(1, i - 1)]) end
end)
-- twig lines inside each puff (darker), cream tip
for i, p in ipairs(puffs) do
  local n = 3
  local a0 = rnd() * 6.28
  for j = 1, n do
    local a = a0 + j * 2.09 + (rnd() - 0.5) * 0.5
    local x1, y1 = p[1] + cos(a) * (p[3] - 0.4), p[2] + sin(a) * (p[3] - 0.4)
    local ln = HP.mask() A.lineMask(ln, floor(p[1] + .5), floor(p[2] + .5), floor(x1 + .5), floor(y1 + .5))
    ln:each(function(x, y) local k = K(x, y)
      if PID[k] == i and (didx[k] or 3) > 2 then c:px(x, y, LI[max(1, (didx[k] or 3) - 1)]) end end)
  end
  local k = K(floor(p[1] - p[3] * 0.35 + .5), floor(p[2] - p[3] * 0.4 + .5))
  if PID[k] == i and (didx[k] or 3) >= 4 then c:px(floor(p[1] - p[3] * 0.35 + .5), floor(p[2] - p[3] * 0.4 + .5), LI[6]) end
end
-- contact darkness at the base of the dome
dome:each(function(x, y) if not dome:has(x, y + 1) and y > 46 then c:px(x, y, LI[1]) end end)

-- quirk: soldier cups on the shoulders
local function soldier(sx, hgt)
  local ty
  for y = 20, 62 do if dome:has(sx, y) then ty = y break end end
  if not ty then return end
  for h = 0, hgt do c:px(sx, ty - h + 1, h % 2 == 0 and LI[4] or LI[3]) c:px(sx + 1, ty - h + 1, LI[2]) end
  local cy = ty - hgt - 1
  c:px(sx - 1, cy, RED[2]) c:px(sx, cy, RED[3]) c:px(sx + 1, cy, RED[2])
  c:px(sx, cy - 1, RED[4]) c:px(sx + 1, cy - 1, RED[3]) c:px(sx - 1, cy - 1, RED[2])
  c:px(sx - 1, cy + 1, RED[1]) c:px(sx, cy + 1, RED[2]) c:px(sx + 1, cy + 1, RED[1])
end
soldier(21, 3)
soldier(44, 4)
A.save(c, "reindeer-lichen")
