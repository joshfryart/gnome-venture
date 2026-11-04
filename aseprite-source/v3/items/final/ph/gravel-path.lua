-- gravel-path (aC10_0, Opus single pass). A placeable path tile seen in 3/4: a slim diamond slab of loose gravel
-- (dozens of individual pebbles from four stone ramps, each sphere-lit with its own hi pixel and shade side, dark
-- grit in the gaps) held between two timber edging boards (grain, pale end grain, nail heads). Front faces show a
-- cross-section: gravel layer over banded soil with embedded stones; the right face carries the board's plank side.
-- AO along the inside of both boards. No ground shadow (flat tile).
-- quirk: a tiny clover has pushed up between the pebbles.
local NAME = "gravel-path"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local GRIT  = { "#2f2630", "#43383f", "#5a4c4f" }
local STONES = {
  { "#3f3f55", "#5d5e76", "#7e809a", "#a3a5bb", "#c8cad9", "#e6e7ef" },  -- cool grey
  { "#5a4436", "#80644c", "#a68765", "#c7a983", "#e2caa4", "#f6e6c8" },  -- warm tan
  { "#3b4656", "#566578", "#76879b", "#98aabb", "#bccbd6", "#dfe8ee" },  -- blue slate
  { "#5e3f3a", "#83584c", "#a87865", "#c99b84", "#e3bea6", "#f6dccb" },  -- rose granite
}
local WOOD = { "#43271f", "#64392a", "#865236", "#a86c43", "#c98e5c", "#e7b884" }
local SOIL = { "#2e1d1e", "#45292a", "#5f3a32", "#7b4e3c" }
local CLOVER = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }

-- diamond top: centre (32,28), half extents 26 x 13
local CX, CY, RX, RY, DEPTH = 32, 27, 26, 13, 6
local function inTop(x, y) return abs(x + 0.5 - CX) / RX + abs(y + 0.5 - CY) / RY <= 1 end
local top = HP.mask()
for y = CY - RY, CY + RY do for x = CX - RX, CX + RX do if inTop(x, y) then top:set(x, y) end end end
-- side faces: every top pixel on the lower edge extruded down DEPTH
local left, right = HP.mask(), HP.mask()
top:each(function(x, y)
  for d = 1, DEPTH do
    if not top:has(x, y + d) then
      if x + 0.5 < CX then left:set(x, y + d) else right:set(x, y + d) end
    end
  end
end)
-- boards: strips along the upper-left edge (L->T) and lower-right edge (B->R), 3 px wide in x
local function edgeDist(x, y, sx, sy) -- distance inward from the edge whose outward normal is (sx,sy) in diamond space
  return 1 - (sx * (x + 0.5 - CX) / RX + sy * (y + 0.5 - CY) / RY)
end
local boardA, boardB = HP.mask(), HP.mask()
top:each(function(x, y)
  if edgeDist(x, y, -1, -1) < 0.12 then boardA:set(x, y) end
  if edgeDist(x, y, 1, 1) < 0.12 then boardB:set(x, y) end
end)
local gravel = top:copy():cut(boardA):cut(boardB)

-- side faces ------------------------------------------------------------------------------
local stok = { r = { name = "side" } }
left:each(function(x, y)
  local d = y - CY - RY + abs(x + 0.5 - CX) / RX * RY   -- depth below the top edge, 0..DEPTH
  local col
  if d <= 2.2 then col = (X.hash(x, y, 2) > 0.5) and STONES[1][3] or STONES[2][3]
    if X.hash(x, y, 5) > 0.7 then col = GRIT[2] end
  else col = (d < 4.2) and SOIL[4] or SOIL[3]
    if X.hash(x, y, 9) > 0.82 then col = STONES[2][4] end
  end
  c:put(x, y, col, stok)
end)
-- right face: plank side of board B over soil
right:each(function(x, y)
  local d = y - CY - RY + abs(x + 0.5 - CX) / RX * RY
  local col
  if d <= 3.2 then
    col = WOOD[3]
    if floor(d) == 1 and (x % 7 < 4) then col = WOOD[2] end           -- grain streak
    if d < 1.2 then col = WOOD[4] end                                   -- bright top arris
  else col = (d < 5) and SOIL[2] or SOIL[1]
    if X.hash(x, y, 11) > 0.84 then col = STONES[1][2] end
  end
  c:put(x, y, col, stok)
end)
-- separation line under the board on the right face, darker row where faces meet
right:each(function(x, y)
  local d = y - CY - RY + abs(x + 0.5 - CX) / RX * RY
  if d > 3.2 and d <= 4.2 then c:put(x, y, SOIL[1], stok) end
end)
-- end grain of board B on the left face at the bottom corner
for yy = 0, 3 do c:put(CX - 1, CY + RY + yy, WOOD[5 - min(yy, 2)], stok) end

-- gravel bed: grit then pebbles ------------------------------------------------------------
local gtok = { r = { name = "grit" } }
gravel:each(function(x, y) c:put(x, y, GRIT[1 + floor(X.hash(x, y, 1) * 2.2)], gtok) end)
local aoB = {}
X.ao(aoB, gravel, boardA, 2, -1)
X.ao(aoB, gravel, boardB, 1, -1)
local placed = HP.mask()
local id = 0
for y = CY - RY, CY + RY, 2 do
  for x = CX - RX, CX + RX, 3 do
    local jx = x + floor(X.hash(x, y, 21) * 3) + ((y // 2) % 2) * 1
    local jy = y + floor(X.hash(x, y, 22) * 2)
    local r = 1.0 + X.hash(x, y, 23) * 1.0
    local pm = c:ellipse(jx, jy, r + 0.35, r * 0.72 + 0.2)
    pm:clip(gravel)
    local free = pm:copy():cut(placed)
    if free:count() >= 3 then
      id = id + 1
      local ramp = STONES[1 + floor(X.hash(jx, jy, 24) * 4) % 4]
      local n = X.sphere(jx - 0.2, jy - 0.3, r + 0.4, free)
      local v = X.light(n, { amb = 0.12, wrap = 0.2 })
      local tok = { r = { name = "peb" .. id } }
      local idx = X.tone(c, free, v, ramp, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, bias = aoB, tok = tok })
      placed:add(free:grow(1):clip(gravel))
    end
  end
end

-- boards on top ---------------------------------------------------------------------------
local function board(m, sx, sy, name)
  local tok = { r = { name = name } }
  local n = X.pillow(m, 1.2)
  local v = X.light(n, { amb = 0.2, wrap = 0.3 })
  local idx = X.tone(c, m, v, WOOD, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }, tok = tok })
  m:each(function(x, y) local k = K(x, y)
    local e = edgeDist(x, y, sx, sy)
    if e > 0.05 and e < 0.08 and (x % 9) < 6 then c:put(x, y, WOOD[max(1, idx[k] - 1)], tok) end   -- grain line
    if e >= 0.1 then c:put(x, y, WOOD[max(1, idx[k] - 1)], tok) end                               -- inner shadow row
  end)
  return tok
end
local tA = board(boardA, -1, -1, "boardA")
local tB = board(boardB, 1, 1, "boardB")
-- nail heads + pale end grain where each board ends
local function nail(x, y, tok) if top:has(x, y) and top:has(x - 1, y) then c:put(x, y, STONES[1][2], tok) c:put(x - 1, y, STONES[1][5], tok) end end
nail(17, 18, tA) nail(27, 13, tA) nail(39, 39, tB) nail(49, 34, tB)
for _, q in ipairs{ { CX - RX + 1, CY - 1 }, { CX - RX + 2, CY - 1 }, { CX, CY - RY }, { CX - 1, CY - RY + 1 } } do if top:has(q[1], q[2]) then c:put(q[1], q[2], WOOD[6], tA) end end
for _, q in ipairs{ { CX + RX - 1, CY }, { CX + RX - 2, CY + 1 }, { CX, CY + RY }, { CX + 1, CY + RY - 1 } } do if top:has(q[1], q[2]) then c:put(q[1], q[2], WOOD[5], tB) end end

-- quirk: a tiny three-leaf clover between the pebbles
local qtok = { r = { name = "clover" } }
local qx, qy = 37, 24
local clover = {
  "..ab.ab..",
  ".acbbcbb.",
  ".abbdbbd.",
  "..ddcdd..",
  "...abb...",
  "...bbdd..",
  "....dd...",
  "....e....",
}
-- contact shadow of the clover on the gravel (drawn before the clover)
for _, q in ipairs{ { 1, 2 }, { 2, 2 }, { 3, 1 }, { 4, 0 }, { 1, 3 }, { 0, 3 } } do
  local x, y = qx + q[1], qy + q[2]
  if gravel:has(x, y) then c:put(x, y, GRIT[1], gtok) end
end
local map = { a = CLOVER[4], b = CLOVER[3], c = "#e9f5c6", d = CLOVER[2], e = CLOVER[1] }
for j, row in ipairs(clover) do for i = 1, #row do local ch = row:sub(i, i)
  if map[ch] then c:put(qx + i - 5, qy + j - 6, map[ch], qtok) end end end
G.save2(c, NAME)
