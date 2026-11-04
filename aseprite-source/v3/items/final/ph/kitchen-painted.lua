-- kitchen-painted (final, Opus single pass). A tall, narrow, front-on kitchen house with a curly Dutch gable: a round
-- crown with a ball finial and concave scroll shoulders, all edged by a lit cream coping. Pink lime-plaster facade
-- with a round teal oculus, a hand-painted frieze of tulips on a vine, a cream string course, a yellow panelled door
-- with a teal frame, a three-pane shop window under a striped scalloped awning, a window box of red blooms and a
-- teal-painted plinth. A brick chimney with a white painted band rises behind the right shoulder.
-- Material: per-pixel plane + bevel light on the plaster, moulding bevels, glass with bright rim and pale core,
-- cloth stripes with folds and a contact shadow under the awning, brick courses.
-- quirk: the painter left a pot of pink paint (one drip running down it) with a brush resting in it by the wall.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("kitchen-painted")

local PINK  = { "#7a2c5a", "#ac4878", "#d46890", "#ee88a6", "#fcaac0", "#ffd2de" }
local CRM   = { "#6e5060", "#a08484", "#c8b09e", "#e4d2b8", "#f6e8cc", "#fff6e2" }
local TEAL  = { "#1e3c64", "#2a6290", "#3a8ab0", "#5cb4c4", "#8cd8d4", "#c4f2e4" }
local GOLD  = { "#7a461e", "#b06e26", "#d89a2c", "#f2be3c", "#ffda6c", "#fff0ae" }
local BRICK = { "#4e1e2a", "#7a2c30", "#a43e36", "#c65a40", "#e07c56", "#f4a07a" }
local GLASS = { "#2a3a6a", "#3a6698", "#5c9cc0", "#8cc8dc", "#bce6ec", "#e8faf6" }
local TIN   = { "#2e2c40", "#4a4a60", "#6a6c82", "#9092a6", "#b8bacb", "#e0e2ea" }
local WOOD  = { "#3a2220", "#5c3424", "#7e4a2c", "#a0663a", "#c08650", "#dcaa70" }
local RED   = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local LEAF  = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }

local x0, x1, yb = 18, 43, 53
c:groundShadow(34, 55, 19, 1)

---------------------------------------------------------------- chimney (behind the right shoulder)
do
  local tok = { r = { name = "chim" } }
  local m = c:rect(39, 14, 42, 27)
  m:each(function(x, y)
    local row = floor((y - 14) / 2)
    local i = 4
    if (y - 14) % 2 == 1 then i = 2 elseif (x - 39 + (row % 2) * 2) % 4 == 0 then i = 2 end
    if x == 39 and i > 2 then i = 5 end
    if x == 42 then i = i - 1 end
    if y == 18 or y == 19 then i = (x == 39) and 6 or (x == 42 and 4 or 5) c:put(x, y, CRM[i], tok)
    else c:put(x, y, BRICK[max(1, i)], tok) end
  end)
  for x = 38, 43 do c:put(x, 13, x < 40 and BRICK[5] or BRICK[3], tok) c:put(x, 12, x < 40 and BRICK[6] or BRICK[4], tok) end
end

---------------------------------------------------------------- facade mask (Dutch gable)
local body = c:rect(x0, 29, x1, yb)
local crown = c:rect(23, 22, 38, 29):add(c:ellipse(30.5, 22, 7.5, 7.5):clip(c:rect(0, 0, 63, 22)))
local sh = c:rect(x0, 24, 22, 29):cut(c:ellipse(16.5, 22.5, 4.5, 4.5))
local shR = c:rect(39, 24, x1, 29):cut(c:ellipse(44.5, 22.5, 4.5, 4.5))
local facade = body:copy():add(crown):add(sh):add(shR)
local coping = facade:copy():cut(facade:shift(0, 1)):clip(c:rect(0, 0, 63, 30))
coping:add(c:rect(x0, 29, x1, 29))
local string2 = c:rect(x0, 30, x1, 30)

---------------------------------------------------------------- openings
local oc = c:ellipse(30.5, 21.5, 2.5, 2.5)
local ocR = oc:grow(1):cut(oc)
local door = HP.mask()
for y = 40, yb - 3 do for x = 20, 25 do if y >= 42 or (x + .5 - 23) ^ 2 + (y + .5 - 42) ^ 2 <= 9.5 then door:set(x, y) end end end
local doorF = door:grow(1):cut(door)
local winG = c:rect(29, 41, 40, 46)
local winF = c:rect(28, 40, 41, 47):cut(winG)
local awn = HP.mask()
for x = 29, 40 do awn:set(x, 35) end
for y = 36, 38 do for x = 28, 41 do awn:set(x, y) end end
for x = 28, 41 do if x % 2 == 0 then awn:set(x, 39) end end
local box = c:rect(28, 48, 41, 49)
local plinth = c:rect(x0, yb - 2, x1, yb)

---------------------------------------------------------------- plaster
local plaster = facade:copy():cut(coping):cut(string2):cut(oc):cut(ocR):cut(door):cut(doorF):cut(winG):cut(winF):cut(box):cut(plinth)
local pidx
do
  local pb = {}
  X.ao(pb, plaster, coping, 1, -1)
  local function cast(m, dx, dy, amt) m:shift(dx, dy):each(function(x, y) if plaster:has(x, y) and not m:has(x, y) then
    local k = K(x, y) pb[k] = (pb[k] or 0) + (amt or -1) end end) end
  cast(awn, 0, 1, -1) cast(awn, 1, 2, -1) cast(string2, 0, 1) cast(winF, 1, 1) cast(doorF, 1, 1) cast(box, 1, 1)
  local n0 = X.pillow(facade, 2)
  local n = {}
  plaster:each(function(x, y) local v = n0[K(x, y)] n[K(x, y)] = { A.norm(v[1] - 0.12, v[2], v[3]) } end)
  local tok = { r = { name = "plaster" } }
  pidx = A.toneN(c, plaster, n, PINK, { bias = pb, tok = tok })
  plaster:each(function(x, y) local h = X.hash(x, y, 17)
    if h > 0.94 then A.addT(c, pidx, PINK, x, y, -1, tok) elseif h < 0.04 then A.addT(c, pidx, PINK, x, y, 1, tok) end end)
  -- hand-painted frieze: a teal vine with tulips (paint takes the wall's light: lit/shade pairs)
  local function paint(x, y, ramp, lit, sh)
    if plaster:has(x, y) then c:put(x, y, (pidx[K(x, y)] or 4) >= 4 and ramp[lit] or ramp[sh], tok) end
  end
  for x = x0 + 2, x1 - 2 do paint(x, 34 + ((x % 4 < 2) and 0 or -1), TEAL, 4, 3) end
  local k = 0
  for x = x0 + 3, x1 - 3, 5 do
    k = k + 1
    local rr = (k % 2 == 0) and GOLD or RED
    paint(x, 32, LEAF, 3, 2)
    paint(x - 1, 31, rr, 3, 2) paint(x + 1, 31, rr, 3, 2) paint(x, 31, rr, 4, 3)
    paint(x - 1, 30 + 1, rr, 3, 2)
    paint(x - 1, 30, rr, 4, 3) paint(x + 1, 30, rr, 3, 2)
    paint(x + 1, 33, LEAF, 3, 2)
  end
  -- painted scallop garland under the crown
  for x = 24, 37 do local y = 27 + ((x % 3 == 1) and 1 or 0) paint(x, y, CRM, 6, 4) end
end

---------------------------------------------------------------- mouldings
do
  local tok = { r = { name = "mould" } }
  coping:each(function(x, y)
    local i = 5
    if x > 34 then i = 4 end
    if x < 26 and y < 26 then i = 6 end
    if y == 29 then i = (x < 30) and 5 or 4 end
    c:put(x, y, CRM[i], tok)
  end)
  string2:each(function(x, y) c:put(x, y, CRM[x < 30 and 3 or 2], tok) end)
  -- ball finial on the crown
  c:put(30, 13, CRM[6], tok) c:put(31, 13, CRM[4], tok) c:put(30, 12, CRM[5], tok) c:put(31, 12, CRM[5], tok)
  c:put(30, 11, CRM[3], tok)
  -- oculus
  ocR:each(function(x, y) c:put(x, y, (x < 31 and y < 22) and TEAL[5] or TEAL[2], tok) end)
  oc:each(function(x, y)
    local edge = not oc:has(x - 1, y) or not oc:has(x, y - 1)
    c:put(x, y, edge and GLASS[5] or ((x > 31 or y > 22) and GLASS[2] or GLASS[3]), tok) end)
  c:put(29, 20, GLASS[6], tok)
  c:put(30, 21, GLASS[4], tok)
  for y = 19, 24 do if oc:has(30, y) then c:put(31, y, TEAL[2], tok) end end
  -- plinth (teal paint) with lit top bevel
  plinth:each(function(x, y)
    local i = (y == yb - 2) and 5 or 3
    if x > x1 - 2 then i = i - 1 end
    if x == x0 then i = i + 1 end
    c:put(x, y, TEAL[min(6, i)], tok)
  end)
end

---------------------------------------------------------------- door
do
  local tok = { r = { name = "door" } }
  doorF:each(function(x, y) if y <= yb - 3 then c:put(x, y, (x <= 20 or y < 42) and TEAL[4] or TEAL[2], tok) end end)
  local n = X.pillow(door, 1)
  local db = {}
  door:each(function(x, y)
    local k = K(x, y)
    local inPanel = (x >= 21 and x <= 24) and ((y >= 43 and y <= 45) or (y >= 47 and y <= 49))
    if inPanel then
      if y == 43 or y == 47 then db[k] = -1 elseif x == 21 then db[k] = -1 elseif x == 24 or y == 45 or y == 49 then db[k] = 1 end
    end
    if not door:has(x, y - 1) then db[k] = (db[k] or 0) - 1 end
  end)
  local nn = {} for k, v in pairs(n) do nn[k] = { A.norm(v[1] - 0.1, v[2], v[3]) } end
  A.toneN(c, door, nn, GOLD, { bias = db, tok = tok })
  c:put(24, 46, WOOD[2], tok) c:put(23, 46, GOLD[6], tok)
  -- step
  for x = 19, 26 do c:put(x, yb - 2, x < 21 and CRM[6] or CRM[4], tok) end
  for x = 19, 26 do c:put(x, yb - 1, CRM[2], tok) c:put(x, yb, CRM[3], tok) end
end

---------------------------------------------------------------- window, awning, box
do
  local tok = { r = { name = "win" } }
  winF:each(function(x, y) c:put(x, y, (x == 28 or y == 40) and CRM[6] or CRM[3], tok) end)
  winG:each(function(x, y)
    local lx, ly = x - 29, y - 41
    local pane = lx % 4
    local i = 3
    if pane == 0 or ly == 5 then i = 2 end
    if ly == 0 or ly == 1 then i = 2 end                      -- awning shadow on the glass
    if (lx + ly) % 7 == 3 and ly >= 2 then i = 5 end         -- glint streaks
    if pane == 1 and ly == 2 then i = 6 end
    if lx == 4 or lx == 8 then c:put(x, y, CRM[lx == 4 and 4 or 3], tok) else c:put(x, y, GLASS[i], tok) end
  end)
  -- jars on a shelf seen through the glass
  for _, j in ipairs{ { 30, GOLD }, { 34, RED }, { 38, LEAF } } do
    c:put(j[1], 45, j[2][3], tok) c:put(j[1] + 1, 45, j[2][2], tok) c:put(j[1], 44, j[2][#j[2]], tok) c:put(j[1] + 1, 44, j[2][3], tok)
  end
  for x = 29, 40 do if x ~= 32 and x ~= 36 then c:put(x, 46, WOOD[3], tok) end end
  -- awning: stripes, folds, scallops
  local at = { r = { name = "awning" } }
  awn:each(function(x, y)
    local st = floor((x - 28) / 2) % 2 == 0
    local R = st and TEAL or CRM
    local i = 4
    if y == 35 then i = 5 elseif y == 38 then i = 3 elseif y == 39 then i = 2 end
    if x == 28 then i = i + 1 end
    if x >= 40 then i = i - 1 end
    if (x - 28) % 4 == 3 and y >= 37 then i = i - 1 end      -- fold
    c:put(x, y, R[max(1, min(6, i))], at)
  end)
  c:put(29, 35, CRM[6], at)
  -- iron rod ends
  c:put(27, 37, TIN[3], at) c:put(42, 37, TIN[2], at)
  -- window box with red geraniums
  local bt = { r = { name = "box" } }
  box:each(function(x, y) c:put(x, y, y == 48 and (x < 30 and WOOD[5] or WOOD[4]) or (x > 39 and WOOD[2] or WOOD[3]), bt) end)
  for x = 28, 41 do if x % 2 == 0 then c:put(x, 47, LEAF[x % 4 == 0 and 3 or 2], bt) end end
  for _, fx in ipairs{ 29, 33, 37, 40 } do c:put(fx, 47, RED[3], bt) c:put(fx + 1, 47, RED[2], bt) c:put(fx, 46, RED[4], bt) end
end

---------------------------------------------------------------- quirk: paint pot + brush
do
  local tok = { r = { name = "pot" } }
  local m = c:rect(46, 48, 51, yb)
  local _, n = X.cyl(48.5, 47, 48.5, 54, function() return 3 end, m)
  local pb = {}
  m:each(function(x, y) if y == 49 then pb[K(x, y)] = -1 end if y == 50 then pb[K(x, y)] = 1 end end)
  A.toneN(c, m, n, TIN, { bias = pb, tok = tok })
  -- paint surface and rim
  for x = 46, 51 do c:put(x, 47, x < 48 and TIN[5] or TIN[3], tok) end
  for x = 47, 50 do c:put(x, 48, x == 47 and PINK[5] or PINK[4], tok) end
  c:put(47, 49, PINK[4], tok) c:put(47, 50, PINK[3], tok) c:put(47, 51, PINK[3], tok) c:put(47, 52, PINK[2], tok)
  -- label band
  for x = 46, 51 do c:put(x, 51, x < 48 and CRM[5] or CRM[3], tok) end
  c:put(47, 51, PINK[3], tok)
  -- brush: wooden handle up-right, tin ferrule, pink bristles dipped in the pot
  local bt = { r = { name = "brush" } }
  for i = 0, 5 do c:put(51 + i, 44 - i, i % 2 == 0 and WOOD[5] or WOOD[4], bt) c:put(51 + i, 45 - i, WOOD[2], bt) end
  c:put(56, 38, WOOD[3], bt)
  c:put(50, 45, TIN[5], bt) c:put(50, 46, TIN[3], bt) c:put(49, 46, TIN[4], bt)
  c:put(49, 47, PINK[2], bt)
end

A.save(c, "kitchen-painted")
