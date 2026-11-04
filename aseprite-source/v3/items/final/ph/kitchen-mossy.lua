-- kitchen-mossy (final, Opus single pass). A low, front-on fieldstone kitchen hut under a deep rounded roof of moss
-- cushions: the moss sits on an old straw thatch whose cut ends show as a lit fringe at the eave, with a few moss
-- strands dripping down the wall. Crooked stone chimney with a slab cap leans out of the moss. Arched plank door in a
-- ring of pale voussoir stones, round glowing window with a cross bar on a stone sill, grass tufts at the footing.
-- Material: per-stone pillow light with dark mortar, lumpy per-blob moss normals (6 tones, cool deep greens), straw
-- strokes, wood planks, AO under the thatch and moss, contact shadow from the chimney.
-- quirk: a tiny red toadstool has sprouted on the chimney cap.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("kitchen-mossy")

local MOSS  = { "#1c3e36", "#285c3e", "#3a7c46", "#56a050", "#80c25e", "#b6e07c" }
local STRAW = { "#4e3220", "#7a5228", "#a67634", "#cc9e48", "#ecc86a", "#fae6a2" }
local MST   = { "#2e2c38", "#46444e", "#625f66", "#827e80", "#a6a29c", "#ccc8bc" }
local WOOD  = { "#3a2220", "#5c3424", "#7e4a2c", "#a0663a", "#c08650", "#dcaa70" }
local GLOW  = { "#8a3a1e", "#c25a24", "#e88a2e", "#f8b440", "#ffd870", "#fff2b8" }
local RED   = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }

local x0, x1, yt, yb = 16, 47, 38, 53

c:groundShadow(32, 55, 19, 1)

---------------------------------------------------------------- chimney (behind the moss)
local chim = HP.mask()
for y = 13, 31 do
  local s = y < 19 and 1 or 0
  for x = 40 + s, 44 + s do chim:set(x, y) end
end
do
  local tok = { r = { name = "chim" } }
  local cb = {}
  chim:each(function(x, y)
    local s = y < 19 and 1 or 0
    local lx = x - 40 - s
    local row = floor((y - 13) / 2)
    local f = (lx + (row % 2) * 2) % 4
    local k = K(x, y)
    local b = 0
    if (y - 13) % 2 == 1 then b = -2 elseif f == 3 then b = -2 elseif f == 0 then b = 1 end
    if lx == 4 then b = b - 1 end
    if lx == 0 then b = b + 1 end
    cb[k] = b
  end)
  local n = {}
  chim:each(function(x, y) n[K(x, y)] = { A.norm(-0.2, -0.1, 1) } end)
  A.toneN(c, chim, n, MST, { bias = cb, tok = tok })
  -- step at the crook: shadow under the overhang
  c:put(40, 19, MST[1], tok) c:put(45, 18, MST[2], tok)
  -- cap slab
  for x = 39, 47 do c:put(x, 12, x < 42 and MST[6] or MST[5], tok) c:put(x, 11, x < 41 and MST[5] or MST[4], tok) end
  for x = 39, 47 do c:put(x, 12, x < 43 and MST[4] or MST[3], tok) end
  c:put(39, 11, MST[6], tok)
end
-- quirk: toadstool on the cap
do
  local tok = { r = { name = "toad" } }
  c:put(41, 10, "#e8dcc0", tok) c:put(41, 9, "#fff0d0", tok)
  for x = 39, 43 do c:put(x, 8, x < 41 and RED[3] or (x == 43 and RED[1] or RED[2]), tok) end
  for x = 40, 42 do c:put(x, 7, x == 40 and RED[4] or RED[3], tok) end
  c:put(40, 8, "#fff4d6", tok) c:put(42, 7, "#fff4d6", tok)
end

---------------------------------------------------------------- walls: fieldstone
local wall = c:rect(x0, yt, x1, yb)
do
  local tok = { r = { name = "wall" } }
  wall:each(function(x, y) c:put(x, y, MST[2], tok) end)     -- mortar
  local y = yt
  local ri = 0
  while y <= yb do
    local h = (ri % 2 == 0) and 4 or 3
    local x = x0 - (ri % 2) * 2
    local si = 0
    while x <= x1 do
      local w = 4 + floor(X.hash(ri, si, 5) * 4)
      local sm = c:rrect(x, y, x + w - 2, min(yb, y + h - 2), 1):clip(wall)
      if sm:count() > 0 then
        local n = X.pillow(sm, 1.5)
        local bias = {}
        local tint = X.hash(si, ri, 9) > 0.7 and -1 or 0
        sm:each(function(px, py) local k = K(px, py) bias[k] = tint
          if py < yt + 3 then bias[k] = bias[k] - (py < yt + 2 and 2 or 1) end end)   -- AO under the thatch
        local nn = {}
        for k, v in pairs(n) do nn[k] = { A.norm(v[1] - 0.15, v[2], v[3]) } end
        A.toneN(c, sm, nn, MST, { bias = bias, tok = tok, cuts = { 0.2, 0.34, 0.5, 0.66, 0.82 } })
      end
      x = x + w
      si = si + 1
    end
    y = y + h
    ri = ri + 1
  end
  -- mortar AO rows top
  for x = x0, x1 do c:put(x, yt, MST[1], tok) end
end

---------------------------------------------------------------- door with voussoir arch
local door = HP.mask()
for y = 42, yb do for x = 21, 28 do
  if y >= 46 or (x + .5 - 25) ^ 2 + (y + .5 - 46) ^ 2 <= 16.5 then door:set(x, y) end
end end
do
  local arch = door:grow(1):cut(door)
  arch:add(door:grow(2):cut(door):clip(c:rect(0, 0, 63, 46)))
  arch:cut(c:rect(0, yb + 1, 63, 63))
  local tok = { r = { name = "arch" } }
  arch:each(function(x, y)
    local ang = math.atan(y + .5 - 46, x + .5 - 25)
    local seg = floor((ang + math.pi) / (math.pi / 6))
    local i = 5
    if y >= 46 then seg = floor((y - 46) / 2) i = (x > 25) and 4 or 5 end
    if seg % 2 == 1 then i = i - 1 end
    if x > 26 then i = i - 1 end
    -- outer ring edge shadow
    if not door:grow(1):has(x, y) then i = i - 1 end
    c:put(x, y, MST[max(2, i)], tok)
  end)
  local tok2 = { r = { name = "door" } }
  local db = {}
  door:each(function(x, y)
    local k = K(x, y)
    if (x - 21) % 3 == 2 then db[k] = -1 end
    if not door:has(x, y - 1) or not door:has(x, y - 2) then db[k] = (db[k] or 0) - 1 end
    if y == 47 or y == 51 then db[k] = (db[k] or 0) - 1 end            -- ledges
  end)
  local n = X.pillow(door, 1)
  local nn = {} for k, v in pairs(n) do nn[k] = { A.norm(v[1] - 0.1, v[2], v[3]) } end
  local idx = A.toneN(c, door, nn, WOOD, { bias = db, tok = tok2 })
  door:each(function(x, y) if X.hash(x, y, 4) > 0.86 then A.addT(c, idx, WOOD, x, y, -1, tok2) end end)
  -- iron ring pull
  c:put(27, 48, "#474858", tok2) c:put(26, 49, "#8e90a0", tok2) c:put(27, 50, "#302e3e", tok2) c:put(28, 49, "#302e3e", tok2)
  -- threshold slab
  for x = 19, 30 do c:put(x, yb + 1, x < 22 and MST[6] or MST[4]) end
end

---------------------------------------------------------------- round window + sill
do
  local tok = { r = { name = "win" } }
  local g = c:ellipse(39.5, 45.5, 3, 3)
  local ring = g:grow(1):cut(g)
  ring:each(function(x, y) c:put(x, y, (x < 40 and y < 46) and WOOD[5] or WOOD[2], tok) end)
  g:each(function(x, y)
    local i = 4
    if x < 39 and y < 45 then i = 5 elseif x > 40 and y > 46 then i = 3 end
    if y == 42 or y <= 43 and (x <= 37 or x >= 42) then i = i - 1 end
    c:put(x, y, GLOW[i], tok)
  end)
  for y = 42, 49 do if g:has(39, y) or g:has(40, y) then c:put(39, y, WOOD[3], tok) c:put(40, y, WOOD[2], tok) end end
  for x = 36, 43 do if g:has(x, 45) then c:put(x, 45, WOOD[3], tok) end end
  c:put(37, 43, GLOW[6], tok)
  for x = 34, 45 do c:put(x, 50, x < 36 and MST[6] or (x > 43 and MST[3] or MST[5]), tok) c:put(x, 51, MST[1], tok) end
end

---------------------------------------------------------------- thatch eave fringe
local thatch = HP.mask()
for x = 13, 50 do
  local bot = 40 + ((x * 7) % 3 == 0 and 1 or 0)
  for y = 34, bot do thatch:set(x, y) end
end
do
  local tok = { r = { name = "thatch" } }
  thatch:each(function(x, y)
    local bot = 40 + ((x * 7) % 3 == 0 and 1 or 0)
    local h = X.hash(x, 0, 21)
    local i = 3 + (h > 0.6 and 1 or 0) - (h < 0.2 and 1 or 0)
    if y >= bot - 1 then i = i + 1 end
    if y == bot then i = 6 - ((x % 2 == 0) and 1 or 0) end
    if y <= 37 then i = i - 2 end
    if x > 45 then i = i - 1 end
    c:put(x, y, STRAW[max(1, min(6, i))], tok)
  end)
end

---------------------------------------------------------------- moss roof: lumpy cushions
do
  local function ytop(x) return 20 + ((x - 31.5) / 20) ^ 2 * 13 end
  local list = {}
  local i = 0
  for x = 13, 50, 3 do
    i = i + 1
    local r = 2.8 + X.hash(i, 1, 2) * 1.2
    local yy = ytop(x) + r - 0.5
    list[#list + 1] = { x, yy, r, (38 - yy) * 0.3 + 1 }
  end
  for y = 23, 34, 3.5 do for x = 15, 48, 4 do
    local jx = x + (X.hash(x, floor(y), 3) - 0.5) * 2 + ((floor(y) % 2) * 2)
    if y > ytop(jx) + 2.5 then
      list[#list + 1] = { jx, y, 3.4 + X.hash(x, floor(y), 8), (38 - y) * 0.3 }
    end
  end end
  i = 0
  for x = 12.5, 51, 3.2 do
    i = i + 1
    local r = 2.2 + X.hash(i, 2, 6) * 1.1
    list[#list + 1] = { x, 35.5 + X.hash(i, 3, 6) * 1.2, r, 0 }
  end
  local m, n = A.blobs(list)
  m:cut(c:rect(0, 40, 63, 63))
  local bias = {}
  -- chimney contact shadow on the moss right of it
  m:each(function(x, y) if x >= 45 and x <= 47 and y <= 27 then bias[K(x, y)] = -1 end end)
  local tok = { r = { name = "moss" } }
  local idx = A.toneN(c, m, n, MOSS, { bias = bias, tok = tok, amb = 0.05, wrap = 0.3 })
  -- tiny fronds speckle (lit tips) and dark pits
  m:each(function(x, y) local h = X.hash(x, y, 13) local k = K(x, y)
    if h > 0.9 and idx[k] >= 3 then A.addT(c, idx, MOSS, x, y, 1, tok)
    elseif h < 0.06 and idx[k] >= 3 then A.addT(c, idx, MOSS, x, y, -1, tok) end end)
  -- spore stalks: three little lit tips on top
  for _, p in ipairs{ { 24, 1 }, { 31, 0 }, { 37, 1 } } do
    local x = p[1] local y = floor(ytop(x)) - 1 + p[2]
    if not m:has(x, y) then c:put(x, y, MOSS[4], tok) c:put(x, y - 1, "#d9a040", tok) end
  end
  -- moss strands dripping down the thatch and wall
  for _, s in ipairs{ { 18, 41, 3 }, { 33, 41, 2 }, { 46, 41, 4 }, { 26, 41, 1 } } do
    for j = 0, s[3] - 1 do c:put(s[1], s[2] + j, j == s[3] - 1 and MOSS[5] or MOSS[3], tok) end
  end
end

---------------------------------------------------------------- grass tufts at the footing
do
  local tok = { r = { name = "grass" } }
  local tufts = {
    { 15, { { 0, 3 }, { 1, 5 }, { 2, 4 }, { 3, 2 } } },
    { 44, { { 0, 2 }, { 1, 4 }, { 2, 3 } } },
    { 48, { { 0, 4 }, { 1, 2 } } },
    { 31, { { 0, 2 }, { 1, 3 } } },
  }
  for _, t in ipairs(tufts) do
    for _, b in ipairs(t[2]) do
      local x = t[1] + b[1]
      for j = 0, b[2] - 1 do
        local y = yb - j
        c:put(x + ((j >= 3 and b[1] % 2 == 0) and -1 or 0), y, j == b[2] - 1 and MOSS[5] or (j == 0 and MOSS[2] or MOSS[3]), tok)
      end
    end
  end
end

A.save(c, "kitchen-mossy")
