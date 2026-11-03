-- ico-ruin (final, Opus single pass). A broken sandstone arch on a stepped plinth: left pier and half the arch stand,
-- the right pier is snapped off mid-height and a fallen voussoir lies in the doorway. Open doorway = air in the silhouette.
-- Material: every block is its own bevelled slab (pillow normals, 6-tone warm sandstone) with dark mortar joints,
-- grain speckle, a crack, paler fresh-break faces, moss on the extrados and plinth, ivy up the left pier,
-- ambient shading under the impost and a contact shadow under the fallen block.
-- quirk: a single red poppy has taken root on the broken pier.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA9_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, atan, pi, sqrt, max, min = math.floor, math.abs, math.atan, math.pi, math.sqrt, math.max, math.min
local c = A.new("ico-ruin")
local SAND = { "#46263a", "#7a3f48", "#b06a54", "#d8975f", "#efbf78", "#fde6a8" }
local MORTAR = "#5e3844"
local MOSS = { "#1f4a3e", "#2d6a44", "#3f8c4c", "#62ad52", "#93cc66", "#c4e584" }
local stok = { r = { name = "stone" } }

-- block painter: mask, bias function, extra
local function block(m, o)
  o = o or {}
  local bias = {}
  m:each(function(x, y) local k = K(x, y)
    local b = 0
    if X.hash(x, y, 7) < 0.1 then b = b - 1 end        -- grain pits
    if o.bias then b = b + (o.bias(x, y) or 0) end
    if b ~= 0 then bias[k] = b end
  end)
  local idx = A.slab(c, m, SAND, o.R or 1.7, { bias = bias, tok = stok, amb = 0.1, wrap = 0.3 })
  return idx
end

c:groundShadow(32, 53, 25, 2)

-- plinth (3 blocks, mortar joints)
local plinth = c:rect(8, 46, 56, 52)
c:fillMask(plinth, MORTAR)
for _, b in ipairs{ { 8, 22 }, { 24, 39 }, { 41, 56 } } do
  block(c:rect(b[1], 46, b[2], 52), { bias = function(x, y) if y >= 51 then return -1 end end })
end

-- arch ring: elliptical, centre (32,20); voussoirs by angle; broken right of the crown
local CX, CY = 32, 20.5
local ring = A.mk(8, 3, 56, 21, function(x, y)
  local ox = ((x - CX) / 20.5) ^ 2 + ((y - CY) / 15.5) ^ 2
  local ix = ((x - CX) / 11.5) ^ 2 + ((y - CY) / 10) ^ 2
  if not (ox <= 1 and ix > 1 and y <= 21) then return false end
  -- jagged break
  local brk = 37 + ({ 0, 1, -1, 2, 0, -2, 1, 3, 0, -1, 2, 1 })[(y % 12) + 1]
  return x <= brk
end)
c:fillMask(ring, MORTAR)
local NV = 9
for i = 0, NV - 1 do
  local v = A.mk(8, 3, 56, 21, function(x, y)
    if not ring:has(x, y) then return false end
    local th = atan(-(y + 0.5 - CY) / 16, (x + 0.5 - CX) / 21.5)
    if th < 0 then th = th + 2 * pi end
    local a0, a1 = pi - (i + 1) * pi / NV, pi - i * pi / NV
    return th >= a0 + 0.035 and th < a1 - 0.035
  end)
  if v:count() > 0 then block(v, { R = 1.5 }) end
end
for i = 1, NV - 1 do
  local th = pi - i * pi / NV
  for r = 0, 1, 0.04 do
    local rx, ry = 11.5 + r * 9, 10 + r * 5.5
    local x, y = floor(CX + math.cos(th) * rx), floor(CY - math.sin(th) * ry)
    if ring:has(x, y) then c:put(x, y, MORTAR, stok) end
  end
end
-- fresh break face on the arch end: paler
ring:each(function(x, y) if not ring:has(x + 1, y) and x > 33 then c:put(x, y, SAND[5], stok) if not ring:has(x + 1, y + 1) then c:put(x, y, SAND[4], stok) end end end)

-- left pier (stacked blocks) + impost
local pierL = c:rect(13, 22, 21, 45)
c:fillMask(pierL, MORTAR)
for _, b in ipairs{ { 22, 27 }, { 28, 33 }, { 34, 39 }, { 40, 45 } } do
  block(c:rect(13, b[1], 21, b[2] - 1), { bias = function(x, y) if y <= 23 then return -1 end end })
end
c:fillMask(c:rect(10, 18, 24, 21), MORTAR)
block(c:rect(10, 18, 24, 20), { R = 1.3 })
-- crack down the second block
for _, p in ipairs{ { 17, 28 }, { 17, 29 }, { 18, 30 }, { 18, 31 }, { 17, 32 } } do c:put(p[1], p[2], SAND[1], stok) end
c:put(19, 29, SAND[5], stok) c:put(19, 31, SAND[5], stok)

-- right pier: snapped off with a jagged top
local JAG = { [42] = 32, [43] = 31, [44] = 30, [45] = 31, [46] = 29, [47] = 30, [48] = 32, [49] = 31, [50] = 33, [51] = 34 }
local pierR = A.mk(42, 28, 51, 45, function(x, y) return y >= JAG[x] end)
c:fillMask(pierR, MORTAR)
local top = A.mk(42, 28, 51, 34, function(x, y) return pierR:has(x, y) and y <= 34 end)
block(top, { R = 1.3 })
block(c:rect(42, 35, 51, 39), {})
block(c:rect(42, 41, 51, 45), {})
-- broken top surface: pale rough face
pierR:each(function(x, y) if not pierR:has(x, y - 1) then c:put(x, y, SAND[6], stok) if X.hash(x, y, 3) < 0.4 then c:put(x, y + 1, SAND[5], stok) end end end)

-- fallen voussoir in the doorway, tipped on its side; contact shadow under it on the plinth
local fall = c:poly{ { 26, 45.9 }, { 27.5, 39.5 }, { 37.5, 41 }, { 37, 45.9 } }
c:fillMask(fall, MORTAR)
block(fall, { R = 1.1 })
for y = 40, 45 do for x = 35, 37 do if fall:has(x, y) and not fall:has(x + 1, y) then c:put(x, y, SAND[3], stok) c:put(x - 1, y, SAND[4], stok) end end end
for x = 25, 41 do if c:get(x, 46) then c:put(x, 46, SAND[2], stok) end end
for x = 27, 39 do if c:get(x, 47) then c:put(x, 47, SAND[3], stok) end end
-- chip lying beside it
block(c:rect(40, 44, 41, 45), { R = 1 })

-- moss: on the extrados near the crown and along the plinth top-left
local mtok = { r = { name = "moss" } }
local function mossOn(mask, x0, x1, depth)
  local mm = HP.mask()
  for x = x0, x1 do
    for y = 0, 63 do if c:get(x, y) and mask:has(x, y) then
      local d = depth + ((X.hash(x, 1, 5) < 0.35) and 1 or 0)
      for j = 0, d - 1 do if mask:has(x, y + j) then mm:set(x, y + j) end end
      break
    end end
  end
  A.slab(c, mm, MOSS, 1.2, { tok = mtok, amb = 0.15, wrap = 0.35 })
  return mm
end
mossOn(ring, 19, 28, 2)
mossOn(ring, 31, 33, 1)
mossOn(plinth, 8, 14, 2)
mossOn(plinth, 48, 54, 1)

-- ivy climbing the left pier: dark vine + 3px leaves
local VINE = { { 12, 46 }, { 13, 43 }, { 15, 40 }, { 14, 37 }, { 15, 34 }, { 17, 31 }, { 16, 28 }, { 17, 25 }, { 19, 23 } }
local vm = c:line(VINE, 1)
vm:each(function(x, y) c:put(x, y, MOSS[2], mtok) end)
for _, l in ipairs{ { 12, 41, 1 }, { 16, 38, 0 }, { 13, 33, 1 }, { 18, 29, 0 }, { 15, 26, 1 }, { 19, 22, 0 } } do
  local x, y = l[1], l[2]
  c:put(x, y, MOSS[5], mtok) c:put(x + 1, y, MOSS[4], mtok)
  c:put(x, y + 1, MOSS[4], mtok) c:put(x + 1, y + 1, MOSS[3], mtok)
  if l[3] == 1 then c:put(x - 1, y, MOSS[4], mtok) else c:put(x + 2, y, MOSS[3], mtok) end
end

-- quirk: a red poppy on the broken right pier
local ptok = { r = { name = "poppy" } }
for _, p in ipairs{ { 46, 28 }, { 46, 27 }, { 47, 26 }, { 47, 25 } } do c:put(p[1], p[2], MOSS[3], ptok) end
c:put(45, 27, MOSS[5], ptok)
A.map(c, {
  ".rRr.",
  "rRhRr",
  "RRkRd",
  ".rdd.",
}, 45, 21, { r = "#e8493b", R = "#ff6a4a", h = "#ffb08a", k = "#2b1c26", d = "#a8243a" }, ptok)

A.save(c, "ico-ruin")
