-- ico-skull (final, Opus). Front-on skull with a domed cranium narrowing to the cheekbones, deep rounded eye
-- sockets, a heart-shaped nasal opening, a row of upper teeth and a separate hinged jaw with lower teeth.
-- Material: per-pixel dome light (6-tone ivory bone, cool-violet shade side, cool bounce on the right edge),
-- concave sockets lit on their lower-right inner wall with a dark overhang under the brow, a wavy coronal
-- suture, bevelled teeth with dark gaps, AO in the gap between jaw and teeth, one forehead glint.
-- quirk: a little pink worm has crawled out of the left eye socket and is peeking round the cheek.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA9_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("ico-skull")
local BONE  = { "#4e3a5a", "#7e6474", "#ad9488", "#d4c0a2", "#eee0bc", "#fff4d6" }
local HOLE  = { "#1c1428", "#2c2040", "#3e3058", "#5a4672" }
local BOUNCE = "#a4a2c4"
local btok = { r = { name = "bone" } }

-- skull mask: dome + cheek block + upper jaw
local skull = A.ellM(32, 24, 14.5, 14.5)
skull:add(A.ellM(32, 35, 12.2, 7.5))
skull:add(c:rrect(23, 38, 41, 45, 2))
local n = X.pillow(skull, 7)
-- blend in an analytic dome on the cranium so it reads round
local sn = X.sphere(32, 23, 15, skull)
skull:each(function(x, y) local k = K(x, y)
  if y < 31 then local a, b = n[k], sn[k] local t = (y < 26) and 0.7 or 0.4
    n[k] = { A.norm(a[1] * (1 - t) + b[1] * t, a[2] * (1 - t) + b[2] * t, a[3] * (1 - t) + b[3] * t) } end
end)
local bias = {}
-- AO under the brow over each socket, under the cheekbones beside the teeth
for _, sx in ipairs{ 25, 39 } do X.ao(bias, skull, A.ellM(sx, 30, 4.6, 4.6), 1, -1) end
skull:each(function(x, y) local k = K(x, y)
  if y >= 40 and (x <= 24 or x >= 40) then bias[k] = (bias[k] or 0) - 1 end
end)
local idx = A.shade(c, skull, n, BONE, { tok = btok, bias = bias, amb = 0.1, wrap = 0.3 })
-- lit lower rim of each socket (bone lip catching light)
for _, sx in ipairs{ 25, 39 } do
  for x = sx - 3, sx + 2 do A.step(c, idx, BONE, x, 36, 1, btok) end
end
-- cool bounce on the lower-right edge
skull:each(function(x, y) if not skull:has(x + 1, y) and not skull:has(x + 1, y + 1) and y > 27 and y < 41 then c:put(x, y, BOUNCE, btok) end end)
-- coronal suture: wavy zigzag over the crown
local sut = {}
for x = 22, 42 do
  local t = (x - 32) / 10
  local y = floor(14.5 + 3.2 * t * t + ((x % 3 == 0) and -1 or ((x % 3 == 1) and 0 or 1)) * 0.8 + .5)
  if skull:has(x, y) then A.step(c, idx, BONE, x, y, -2, btok) sut[#sut + 1] = { x, y } end
end
-- sagittal suture running back from the crown centre
for y = 9, 13 do A.step(c, idx, BONE, 32 + ((y % 2 == 0) and 0 or 1), y, -1, btok) end
-- forehead glint
c:put(24, 15, BONE[6], btok) c:put(25, 15, BONE[6], btok) c:put(24, 14, A.SPEC, btok)

-- eye sockets: concave, dark upper-left, the lower-right inner wall lit
local htok = { r = { name = "hole" } }
for _, sx in ipairs{ 25, 39 } do
  local sm = c:rrect(sx - 4, 26, sx + 4, 34, 3)
  sm:each(function(x, y)
    local dx, dy = x - sx, y - 30
    local v = dx * 0.55 + dy * 0.7
    local i = 1
    if v > 1.0 then i = 2 end
    if v > 3.2 then i = 3 end
    if v > 4.6 and (not sm:has(x + 1, y) or not sm:has(x, y + 1)) then i = 4 end
    if dy <= -3 then i = 1 end
    c:put(x, y, HOLE[i], htok)
  end)
end
-- nasal opening: inverted heart with a lit bone septum
A.map(c, {
  "...K...",
  "..KKK..",
  ".KKKKd.",
  ".KKbKd.",
  ".KK.dd.",
  "..K.d..",
}, 29, 35, { K = HOLE[1], d = HOLE[3], b = BONE[4] }, htok)
c:put(32, 39, BONE[4], btok) c:put(32, 40, BONE[3], btok) c:put(32, 41, BONE[2], btok)

-- upper teeth on the maxilla: five rounded teeth, AO under the maxilla, dark gaps
local ttok = { r = { name = "teeth" } }
local TEETH = { "#6e5464", "#a48c80", "#d8c8a8", "#f4e8c8", "#fff4d6" }
for x = 23, 41 do for y = 42, 45 do c:put(x, y, (y == 45) and HOLE[3] or BONE[2], htok) end end
for i, tx in ipairs{ 23, 27, 31, 35, 39 } do
  for x = tx, tx + 2 do for y = 42, 45 do
    local t = ({ 2, 4, 3, 3 })[y - 41]
    if x == tx + 2 and y > 42 then t = t - 1 end
    if not (y == 45 and x == tx + 2) then c:put(x, y, TEETH[t], ttok) end
  end end
  c:put(tx, 43, TEETH[5], ttok)
end
-- gap row between upper teeth and jaw
for x = 23, 41 do if x % 4 ~= 0 then c:put(x, 46, HOLE[1], htok) end end

-- mandible: separate piece, slightly narrower, rounded chin
local jtok = { r = { name = "jaw" } }
local jaw = A.fn(20, 46, 44, 56, function(x, y)
  if y < 47 or y > 54 then return false end
  local hw = 9.6 - max(0, y - 50) * 1.15
  return abs(x - 32) <= hw
end)
local jn = X.pillow(jaw, 3)
local jb = {}
jaw:each(function(x, y) if y == 47 then jb[K(x, y)] = -1 end end)
local jidx = A.shade(c, jaw, jn, BONE, { tok = jtok, bias = jb, amb = 0.1, wrap = 0.3 })
-- lower teeth (2 rows, in the jaw)
for x = 25, 39 do c:put(x, 47, HOLE[3], htok) c:put(x, 48, BONE[2], htok) end
for _, tx in ipairs{ 25, 29, 33, 37 } do
  for x = tx, tx + 2 do
    c:put(x, 47, (x == tx + 1) and TEETH[4] or TEETH[3], ttok)
    c:put(x, 48, (x == tx + 2) and TEETH[2] or TEETH[3], ttok)
  end
end
-- jaw hinge notches at the corners, chin dimple
for _, x in ipairs{ 23, 41 } do c:put(x, 48, BONE[2], jtok) c:put(x, 49, BONE[2], jtok) end
A.step(c, jidx, BONE, 32, 53, -1, jtok)
jaw:each(function(x, y) if not jaw:has(x + 1, y) and y > 48 then c:put(x, y, BOUNCE, jtok) end end)

-- quirk: a pink worm peeking out of the left socket
local wtok = { r = { name = "worm" } }
A.map(c, {
  "hh.......",
  "eph......",
  ".pp...pp.",
  "..pPpPP..",
  "...PPP...",
}, 16, 32, { e = "#2b1c26", h = "#ffc4d8", p = "#f5809f", P = "#c94f84" }, wtok)

A.save(c, "ico-skull")
