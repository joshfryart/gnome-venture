-- centipede-plate (final, Opus single pass). A slim chest plate made from a giant centipede's back: seven glossy
-- chitin tergites, front plates overlapping the ones behind, a raised keel down the middle, amber legs hooking out of
-- every segment, two tail prongs, and a stitched leather strap tab at the neck.
-- Material: per-pixel chitin light (6-tone teal-green with a gold-green sheen), bright lip on each plate's front edge,
-- AO + contact shadow under each overlap, specular streak on the keel, cool reflected light lower right; legs twisted
-- two-tone with dark joints.
-- quirk: the head plate still wears its two curly antennae.
local NAME = "centipede-plate"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r1_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local CH = { "#14243a", "#1b4450", "#22695e", "#36916a", "#6fbf74", "#c6eaa0" }
local LEG = { "#6a2f2a", "#b0582c", "#e5923a", "#ffcf6e" }
local LEATHER = { "#4a2a26", "#764030", "#a5603e", "#d08f5c", "#f0bf88" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local BOUNCE = "#5aa6b8"
local CX = 32

-- segments: top y, height, half width (front = top)
local segs = {
  { 15, 6, 7.5 },   -- head plate
  { 20, 6, 9.5 },
  { 25, 6, 10.8 },
  { 30, 6, 11.3 },
  { 35, 6, 10.8 },
  { 40, 6, 9.6 },
  { 45, 5, 7.6 },
  { 49, 5, 5.4 },
}
local function segMask(s)
  local y0, h, w = s[1], s[2], s[3]
  local m = HP.mask()
  for y = y0, y0 + h do
    local f = (y - y0) / h
    -- rounded rear edge: the plate bows backward in the middle
    for x = floor(CX - w - 1), floor(CX + w + 1) do
      local dx = (x + 0.5 - CX) / w
      if abs(dx) <= 1 then
        local back = y0 + h - 1 + floor(1.6 * (1 - dx * dx) + 0.5)
        local front = y0 + floor(1.2 * dx * dx + 0.5)
        local corner = abs(dx) > 0.86 and (y == y0 + h + 1 - 0) and 1 or 0
        if y >= front and y <= back then m:set(x, y) end
      end
    end
  end
  -- extend the rear lobe one row
  for x = floor(CX - w * 0.55), floor(CX + w * 0.55) do m:set(x, y0 + h + 1) end
  return m
end

-- legs first (behind plates): one pair per body segment, hooking down and out
local legM = HP.mask()
local legs = {}
for i = 2, 7 do
  local s = segs[i]
  local y = s[1] + 3
  local w = s[3]
  for _, side in ipairs{ -1, 1 } do
    local x0 = floor(CX + side * (w - 1) + 0.5)
    local kx = floor(CX + side * (w + 3.5) + 0.5)
    local ky = y - 1 + (i > 4 and 1 or 0)
    local fx = floor(CX + side * (w + 4.5) + 0.5)
    local fy = ky + 4
    local pts = { { x0, y }, { kx, ky }, { fx, fy } }
    legs[#legs + 1] = { pts = pts, side = side }
  end
end
local legTok = A.tok("leg")
for _, l in ipairs(legs) do
  local p = l.pts
  local m = c:line({ p[1], p[2] }, 2):add(c:line({ p[2], p[3] }, 1))
  legM:add(m)
end
-- paint legs: upper row lit, lower row shade; tips pale; knee dark joint
legM:each(function(x, y)
  local lit = not legM:has(x, y - 1)
  c:put(x, y, lit and LEG[3] or LEG[2], legTok)
end)
for _, l in ipairs(legs) do
  local k = l.pts[2]
  c:put(k[1], k[2], LEG[1], legTok)
  local t = l.pts[3]
  c:put(t[1], t[2], LEG[4], legTok)
end

-- tail prongs (terminal legs), behind the last plate
local tail = HP.mask()
tail:add(c:line({ { 30, 52 }, { 27, 56 } }, 2)):add(c:line({ { 34, 52 }, { 37, 56 } }, 2))
tail:each(function(x, y) c:put(x, y, (x < CX) and LEG[3] or LEG[2], legTok) end)
c:put(27, 56, LEG[4], legTok) c:put(37, 56, LEG[1], legTok)

-- plates, back to front so each front plate laps over the next
local masks = {}
for i = #segs, 1, -1 do masks[i] = segMask(segs[i]) end
local all = HP.mask()
for i = 1, #segs do all:add(masks[i]) end
local idx = {}
local nAll = X.pillow(all, 6)
for i = #segs, 1, -1 do
  local m = masks[i]:copy()
  for j = 1, i - 1 do m:cut(masks[j]) end
  local s = segs[i]
  -- normals: body curvature (pillow of whole plate) + each tergite domed front-to-back
  local n = {}
  m:each(function(x, y)
    local k = K(x, y)
    local a = nAll[k]
    local f = (y - s[1]) / (s[2] + 1)            -- 0 front .. 1 rear
    local tilt = (f - 0.35) * 1.1                 -- front faces up toward the light
    n[k] = { A.norm(a[1] * 1.3, a[2] + tilt, a[3]) }
  end)
  local bias = {}
  -- contact shadow: the plate in front casts onto this plate's front rows
  if i > 1 then X.ao(bias, m, masks[i - 1], 1, -2) end
  local tk = A.tok("plate" .. i)
  local id = A.shade(c, m, n, CH, { tok = tk, bias = bias, amb = 0.08, wrap = 0.28, cuts = { 0.16, 0.32, 0.5, 0.68, 0.84 } })
  for k, v in pairs(id) do idx[k] = v end
  -- bright lip on the rear edge (the rim that laps over the next plate)
  m:each(function(x, y)
    if not m:has(x, y + 1) and abs(x + 0.5 - CX) < s[3] - 1 and idx[K(x, y)] then
      A.step(c, idx, CH, x, y, (x < CX + 3) and 1 or -1, tk)
    end
  end)
end
-- keel: raised ridge on the centre line, lit left column + shade right column
all:each(function(x, y)
  if y > 15 and y < 52 then
    local k = K(x, y)
    if x == CX - 1 then A.step(c, idx, CH, x, y, 1, A.tok("keel")) end
    if x == CX then A.step(c, idx, CH, x, y, -1, A.tok("keel")) end
  end
end)
-- specular streak on the keel and a sheen glint on the upper left
for y = 22, 28 do if all:has(CX - 1, y) and (y ~= 25) then c:px(CX - 1, y, CH[6]) end end
c:px(25, 26, CH[6]) c:px(26, 26, CH[6]) c:px(24, 27, CH[5])
-- cool reflected light on the lower-right rim
all:edge():each(function(x, y) if x > CX + 4 and y > 30 and y < 47 and X.hash(x, y, 2) > 0.25 then c:px(x, y, BOUNCE) end end)
-- tiny pores in a row on each plate (chitin texture)
for i = 2, 7 do local s = segs[i]
  for _, dx in ipairs{ -5, 5 } do
    local x, y = CX + dx, s[1] + 3
    if idx[K(x, y)] then A.step(c, idx, CH, x, y, -2, A.tok("pore")) end
  end
end

-- leather strap tab at the neck with a gold buckle (in front of the head plate)
local strap = c:rect(30, 10, 34, 15)
local stok = A.tok("strap")
A.shade(c, strap, A.vcylN(strap, 30, 34), LEATHER, { tok = stok, cuts = { 0.25, 0.45, 0.65, 0.85 } })
for x = 30, 34 do c:px(x, 15, LEATHER[1]) c:px(x, 10, LEATHER[4]) end
c:px(32, 12, LEATHER[1]) c:px(31, 12, LEATHER[2])  -- punched strap hole
for _, x in ipairs{ 30, 31, 33, 34 } do c:px(x, 14, GOLD[3]) end   -- one stitched seam (2 on 1 off)

-- quirk: antennae curling up off the head plate
local ant = A.tok("antenna")
A.pline(c, { { 27, 15 }, { 25, 12 }, { 24, 9 }, { 25, 7 } }, LEG[2], ant)
c:px(26, 6, LEG[3]) c:px(27, 7, LEG[3])
A.pline(c, { { 37, 15 }, { 39, 12 }, { 40, 9 }, { 39, 7 } }, LEG[2], ant)
c:px(38, 6, LEG[3]) c:px(37, 7, LEG[2])

A.save(c, NAME)
