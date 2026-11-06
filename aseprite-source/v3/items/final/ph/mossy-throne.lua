-- mossy-throne (final pass, Opus). A slim carved stone throne, front view: tall back slab with a pointed arch and a
-- knob finial, a recessed panel with a carved sun ring, thin arm posts with ball finials, a seat slab (lit top plane,
-- darker front face), slim legs on foot blocks. Chisel bevels, speckle and a hairline crack in the stone; AO where
-- parts meet. Moss drapes over the arch and spills over the seat edge in drips. Ground shadow (it stands).
-- quirk: a tiny gold gnome crown has been left on the seat.
local NAME = "mossy-throne"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local STONE = { "#2e3048", "#474a66", "#666986", "#8b8da6", "#b4b5c6", "#dcdce6" }
local MOSS  = { "#1d4a3a", "#2a6b40", "#3f8f45", "#62b04c", "#93cf62", "#c8ec8a" }
local GOLD  = { "#6e3a1c", "#a8601e", "#d98322", "#f5b82e", "#ffe38a", "#fff4d6" }

c:groundShadow(32, 54, 18, 2)

local stok = { r = { name = "stone" } }
local function stone(m, R, bias, o)
  o = o or {}
  local n = X.pillow(m, R or 2)
  local v = X.light(n, { amb = o.amb or 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local i = 1
    for j, cu in ipairs(A.CUTS) do if v[k] >= cu then i = j + 1 end end
    i = i + (o.lift or 0)
    if bias and bias[k] then i = i + bias[k] end
    -- speckle: sparse darker grains on flat areas
    local h = X.hash(x, y, o.seed or 1)
    if h > 0.93 and i > 2 then i = i - 1 elseif h < 0.03 and i < 6 then i = i + 1 end
    c:put(x, y, STONE[max(1, min(6, i))], stok)
  end)
end

-- masks
local back = c:rect(21, 20, 42, 37)
-- pointed (two-centred) arch on top
for y = 6, 20 do for x = 19, 44 do
  if (x - 29.9)^2 + (y - 20)^2 <= 12.1^2 and (x - 33.1)^2 + (y - 20)^2 <= 12.1^2 then back:set(x, y) end end end
local knob = c:ellipse(31.5, 7, 1.5, 1.5):add(c:rect(31, 8, 32, 9))
local panel = c:rect(25, 19, 38, 33)
for y = 11, 19 do for x = 25, 38 do
  if (x - 30.4)^2 + (y - 19)^2 <= 8.2^2 and (x - 32.6)^2 + (y - 19)^2 <= 8.2^2 then panel:set(x, y) end end end
local armL, armR = c:rect(15, 31, 18, 49), c:rect(45, 31, 48, 49)
local railL, railR = c:rect(18, 32, 21, 34), c:rect(42, 32, 45, 34)
local ballL, ballR = c:ellipse(16.5, 28.5, 2.5, 2.5), c:ellipse(46.5, 28.5, 2.5, 2.5)
local seatTop = c:rect(17, 37, 46, 40)
local seatFace = c:rect(17, 41, 46, 45)
local legL, legR = c:rect(20, 46, 23, 50), c:rect(40, 46, 43, 50)
local footL, footR = c:rect(19, 51, 24, 53), c:rect(39, 51, 44, 53)

-- moss masks: cap on the arch, a cushion on the left ball, a mat spilling over the seat's left half with drips
local mossCap = HP.mask()
back:grow(1):add(knob:grow(1)):each(function(x, y)
  local lim = 14 + 2.2 * sin(x * 0.9) + (x < 30 and 3 or 0) + 1.5 * X.hash(x, 0, 2)
  if y <= lim and (back:has(x, y) or knob:has(x, y) or X.hash(x, y, 9) > 0.3) then mossCap:set(x, y) end
end)
local mossBall = HP.mask()
ballL:grow(1):each(function(x, y) if y <= 28 + (x < 17 and 1 or 0) then mossBall:set(x, y) end end)
local mossSeat = HP.mask()
for x = 17, 33 do
  local top = 37 - (X.hash(x, 1, 5) > 0.5 and 1 or 0)
  local bot = 41 + floor(1.6 * X.hash(x, 2, 5))
  if x == 20 or x == 26 then bot = 44 + (x == 20 and 2 or 0) end   -- drips
  if x == 31 then bot = 42 end
  if x > 30 then top = 38 end
  for y = top, bot do mossSeat:set(x, y) end
end
mossSeat:cut(c:rect(32, 37, 33, 37))
local allMoss = mossCap:copy():add(mossBall):add(mossSeat)

-- stone parts, back to front, AO where they meet and under the moss
local function sb(m, others)
  local b = {}
  for _, o in ipairs(others) do X.ao(b, m, o, 1, -1) end
  A.cast(b, m, allMoss, 1, 1, -1)
  return b
end
-- back slab with recessed panel
local bb = sb(back, { seatTop, railL, railR })
stone(back, 2, bb, { seed = 1 })
-- recess: panel one tone darker, lit inner edge bottom-right, shadowed inner edge top-left
panel:each(function(x, y) local k = K(x, y)
  local i = 3
  if not panel:has(x - 1, y) or not panel:has(x, y - 1) then i = 2 end
  if not panel:has(x + 1, y) or not panel:has(x, y + 1) then i = 5 end
  if X.hash(x, y, 7) > 0.94 then i = i - 1 end
  c:put(x, y, STONE[i], stok)
end)
-- carved sun ring in the panel
local ringO, ringI = c:ellipse(31.5, 24.5, 3.5, 3.5), c:ellipse(31.5, 24.5, 1.5, 1.5)
ringO:copy():cut(ringI):each(function(x, y)
  local d = (x - 31.5) + (y - 24.5)
  c:put(x, y, d < -1 and STONE[1] or (d > 1 and STONE[5] or STONE[2]), stok) end)
ringI:each(function(x, y) c:put(x, y, STONE[4], stok) end)
c:put(31, 24, STONE[5], stok)
-- hairline crack down the back slab's right side
for _, p in ipairs{ {39, 24}, {39, 25}, {40, 26}, {40, 27}, {39, 28}, {40, 29} } do c:put(p[1], p[2], STONE[1], stok) end
c:put(41, 26, STONE[5], stok)
stone(knob, 1.2, sb(knob, {}), { seed = 2 })

-- legs and feet
for _, m in ipairs{ legL, legR } do stone(m, 1.5, sb(m, { seatFace }), { seed = 3, amb = 0.08 }) end
for _, m in ipairs{ footL, footR } do stone(m, 1.2, sb(m, { legL, legR }), { seed = 4 }) end
-- seat: lit top plane, darker front face, deep crease between
stone(seatTop, 1.5, sb(seatTop, { back }), { seed = 5, lift = 1 })
stone(seatFace, 1.5, sb(seatFace, {}), { seed = 6, lift = -1 })
for x = 17, 46 do c:put(x, 41, STONE[2], stok) end
for x = 18, 45 do c:put(x, 37, STONE[6], stok) end
-- arm rails, posts, balls
for _, m in ipairs{ railL, railR } do stone(m, 1, sb(m, {}), { seed = 7 }) end
for _, m in ipairs{ armL, armR } do
  local b = sb(m, { seatTop, seatFace, railL, railR })
  stone(m, 1.5, b, { seed = 8 })
end
for _, m in ipairs{ ballL, ballR } do
  local n = X.sphere(m:bbox() and (m == ballL and 16.5 or 46.5), 28.5, 2.5, m)
  local v = X.light(n, { amb = 0.12, wrap = 0.2 })
  X.tone(c, m, v, STONE, { cuts = A.CUTS, tok = stok })
end
-- deep separation lines between stacked stone parts
local function sepLine(front, behind)
  front:grow(1):cut(front):each(function(x, y) if behind:has(x, y) and not front:has(x, y) then c:put(x, y, STONE[1], stok) end end)
end
sepLine(armL, seatTop) sepLine(armR, seatTop) sepLine(armL, seatFace) sepLine(armR, seatFace)
sepLine(ballL, armL) sepLine(ballR, armR)

-- moss
local mtok = { r = { name = "moss" } }
A.moss(c, mossCap, MOSS, { size = 3.0, seed = 21, tok = mtok, R = 2 })
A.moss(c, mossBall, MOSS, { size = 2.6, seed = 22, tok = mtok, R = 1.5 })
A.moss(c, mossSeat, MOSS, { size = 3.0, seed = 23, tok = mtok, R = 1.5 })
-- drip tips catch light
c:put(20, 46, MOSS[4], mtok) c:put(26, 44, MOSS[4], mtok)

-- quirk: tiny gold crown on the seat
local ctok = { r = { name = "crown" } }
A.map(c, 36, 33, {
  "a.b.a",
  "bcdcb",
  "cdedc",
  "bbbbb",
}, { a = GOLD[5], b = GOLD[3], c = GOLD[4], d = GOLD[4], e = "#e8493b" }, ctok)
for x = 36, 40 do c:put(x, 36, x < 38 and GOLD[3] or GOLD[2], ctok) end
c:put(41, 36, STONE[1], stok) c:put(41, 35, STONE[2], stok)
c:put(37, 34, GOLD[6], ctok)

A.save(c, NAME)
