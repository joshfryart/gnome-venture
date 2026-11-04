-- rice-and-beans (final, agent aD12_3). A footed wooden bowl (curved grain rings, paler end-grain lip, lit per pixel)
-- heaped half with fluffy white rice (individual lit grains) and half with glossy red kidney beans (specular, hilum,
-- separation lines), a wooden spoon standing in the heap casting a shadow. quirk: one bean is stuck to the spoon handle.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_3.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, cos, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.max, math.min, math.sqrt
local c = A.new("rice-and-beans")
local WOOD = { "#3a2220", "#51302b", "#7a4630", "#a46a40", "#cc9460", "#e8b982" }
local RICE = { "#7a6a92", "#a89cba", "#d4c8d0", "#ece2dc", "#fff4e6", "#fffcf4" }
local BN   = { "#3a1018", "#6e2038", "#a02a3c", "#c8403c", "#e86a50", "#ffa07a" }
c:groundShadow(30, 57, 20, 2)

-- bowl body
local body = HP.mask()
for y = 37, 55 do
  local hw = 21 * (1 - 0.45 * ((y - 38) / 16) ^ 1.7)
  if y < 38 then hw = 21 end
  for x = floor(30 - hw + 0.5), floor(30 + hw - 0.5) do body:set(x, y) end
end
body:add(c:ellipse(30, 37, 21, 6)):cut(c:rect(0, 56, 63, 63))
local bi = A.vcyl(c, body, WOOD, 11, 49, { amb = 0.14, wrap = 0.3 })
-- curved grain rings on the outside
for _, y0 in ipairs{ 44, 47, 50, 53 } do
  for x = 9, 51 do
    local u = (x - 30) / 21
    if abs(u) < 1 then
      local y = floor(y0 + 2.4 * sqrt(1 - u * u) + 0.5 - (y0 - 44) * 0.18 * abs(u) * 3)
      if body:has(x, y) and (x + y0) % 7 ~= 0 then c:px(x, y, WOOD[max(1, (bi[K(x, y)] or 3) - 1)]) end
    end
  end
end
-- foot ring
local foot = c:rrect(19, 54, 41, 57, 1)
A.vcyl(c, foot, WOOD, 19, 41, { amb = 0.1, wrap = 0.3 })
for x = 20, 40 do c:px(x, 54, WOOD[1]) end
-- opening / interior wall
local open = c:ellipse(30, 37, 19, 4.4)
c:fillMask(open, WOOD[1])
for x = 12, 22 do for y = 34, 37 do if open:has(x, y) then c:px(x, y, WOOD[2]) end end end
-- heap: dome over the opening
local heap = c:ellipse(30, 34, 18.5, 12.5):clip(c:rect(0, 0, 63, 37)):add(c:ellipse(30, 37.5, 18.5, 3.8))
local hn = X.pillow(heap, 9)
local hv = X.light(hn, { amb = 0.1, wrap = 0.3 })
local xb = function(y) return 31 + 2.2 * sin(y * 0.9) end
local rice, bean = HP.mask(), HP.mask()
heap:each(function(x, y) if x < xb(y) then rice:set(x, y) else bean:set(x, y) end end)
local ri = X.tone(c, rice, hv, RICE, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
X.tone(c, bean, hv, BN, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
-- rice grains: lit 3x2 capsules on an offset lattice
local rc = rice:copy():shrink(1)
for row = 0, 11 do
  for col = 0, 6 do
    local x = 12 + col * 3.7 + (row % 2) * 1.9 + (row * 7 % 3) * 0.4
    local y = 22 + row * 1.9
    local xi, yi = floor(x), floor(y)
    if rc:has(xi, yi) and rc:has(xi + 2, yi + 1) then
      local k = K(xi, yi)
      local i = ri[k] or 4
      local diag = (row + col) % 3 == 0
      c:px(xi, yi, RICE[min(6, i + 2)]) c:px(xi + 1, yi, RICE[min(6, i + 2)])
      c:px(xi + 2, yi + (diag and 1 or 0), RICE[i])
      c:px(xi, yi + 1, RICE[max(1, i - 2)]) c:px(xi + 1, yi + 1, RICE[max(1, i - 2)])
      if not diag then c:px(xi + 2, yi + 1, RICE[max(1, i - 3)]) end
    end
  end
end
-- beans (back to front)
local beans = { { 36, 27, 0.3 }, { 42, 28, -0.4 }, { 46, 33, 0.7 }, { 40, 32, 0.9 }, { 34, 32, -0.2 }, { 44, 36, -0.1 }, { 38, 36, 0.4 }, { 33, 36.5, 0.2 } }
local bt = { r = { name = "bean" } }
for _, b in ipairs(beans) do
  local m, n = G.oval(b[1], b[2], 3.5, 2.4, b[3], 0.9)
  m:clip(heap:copy():shrink(1))
  m:grow(1):cut(m):each(function(x, y) if bean:has(x, y) then c:px(x, y, BN[1]) end end)
  G.toneN(c, m, n, BN, { tok = bt, amb = 0.1, wrap = 0.25 })
  local ca, sa = cos(b[3]), sin(b[3])
  -- hilum on the lower-inner edge, specular upper-left
  c:px(floor(b[1] + 0.5 + sa * 1.4), floor(b[2] + 0.5 - ca * 1.4) + 1, "#f2c4a8")
  c:px(floor(b[1] - 1.4 * ca - 0.5), floor(b[2] - 1.4 * sa - 1), "#ffd0b0") c:px(floor(b[1] - 0.4 * ca - 0.5), floor(b[2] - 0.4 * sa - 1), "#ffb89a")
end
-- front lip of the bowl (paler end grain)
local lip = c:ellipse(30, 37, 21, 6):cut(c:ellipse(30, 37, 19, 4.4)):clip(c:rect(0, 37, 63, 63))
lip:add(c:rect(9, 37, 10, 38)):add(c:rect(50, 37, 51, 38))
A.vcyl(c, lip, { "#7a4630", "#a46a40", "#cc9460", "#e8b982", "#f6d4a0", "#fff0c8" }, 10, 50, { amb = 0.2, wrap = 0.4 })
for x = 12, 48, 5 do if lip:has(x, 42) then c:px(x, 42, WOOD[3]) end end
for x = 10, 50 do local y = 43 if body:has(x, y) and lip:has(x, y) then c:px(x, y, WOOD[2]) end end
-- spoon handle standing in the heap
local sp = { { 33, 31 }, { 37, 24 }, { 41, 18 }, { 44, 13 } }
local sm, sn, ST, SS = G.tube(sp, function(t) return 1.5 + 0.5 * t end)
-- cast shadow onto heap
sm:copy():shift(2, 1):each(function(x, y) if heap:has(x, y) and not sm:has(x, y) then c:px(x, y, rice:has(x, y) and RICE[2] or BN[1]) end end)
X.tone(c, sm, X.light(sn, { amb = 0.1, wrap = 0.3 }), WOOD, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, tok = { r = { name = "spoon" } } })
sm:each(function(x, y) local k = K(x, y) if abs(SS[k]) < 0.1 and ST[k] > 0.1 and (x + y) % 3 ~= 0 then c:px(x, y, WOOD[5]) end end)
sm:each(function(x, y) local k = K(x, y) if ST[k] < 0.08 then c:px(x, y, WOOD[1]) end end)
c:px(44, 12, WOOD[6]) c:px(43, 13, WOOD[6])
-- quirk: a bean stuck to the handle
local qm, qn = G.oval(40.5, 22, 3.2, 2.2, -1.0, 0.9)
qm:grow(1):cut(qm):each(function(x, y) c:px(x, y, BN[1]) end)
G.toneN(c, qm, qn, BN, { tok = bt, amb = 0.1, wrap = 0.25 })
c:px(39, 20, "#ffd0b0") c:px(40, 21, "#ffb89a") c:px(42, 23, "#f2c4a8")
A.save(c, "rice-and-beans")
