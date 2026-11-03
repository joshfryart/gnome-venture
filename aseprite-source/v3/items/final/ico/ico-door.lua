-- ico-door (final, Opus). A round-topped gnome door, front view: three slim vertical oak planks inside a stone
-- arch of chunky voussoirs, two black-iron strap hinges with rivets, a brass ring pull, a stone doorstep.
-- Material: planks with grain lines, knots and a dark gap between boards, a bevelled lit left edge on each plank;
-- iron straps with a bright top bevel and lit rivet heads; brass ring with specular; stones pillowed per block with
-- mortar AO; a 3 px ambient band where the door sinks into the arch; small round peep window of glass (bright rim,
-- pale core).
-- quirk: a tiny mouse hole is gnawed into the bottom-right corner of the door.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA3_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, atan, pi = math.floor, math.sqrt, math.max, math.min, math.abs, math.atan, math.pi
local c = A.new("ico-door")
local WOOD = { "#3e2228", "#5e3428", "#87502f", "#b0743e", "#d29a56", "#efc27e" }
local STONE = { "#3a3c58", "#55587a", "#777b98", "#9ea1b8", "#c8cad8", "#eceaf0" }
local IRON = { "#1f1a2a", "#33304a", "#4e4c68", "#77789a", "#a8abc6" }
local BRASS = { "#6a3a1a", "#a86420", "#e09a2e", "#f8cc52", "#fff0a8" }
local GLASS = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0", "#e8fff6" }
local SPEC = "#fff4d6"

local CX = 32
local OX0, OX1, OTOP, BOT = 14, 49, 6, 53      -- outer arch
local IX0, IX1, ITOP = 19, 44, 11              -- door opening
local function arch(x0, x1, top, bot)
  local r = (x1 - x0 + 1) / 2
  local cx, cy = (x0 + x1 + 1) / 2, top + r
  local m = HP.mask()
  for y = top, bot do for x = x0, x1 do
    local px, py = x + 0.5, y + 0.5
    if py >= cy or (px - cx)^2 + (py - cy)^2 <= r * r then m:set(x, y) end
  end end
  return m, cx, cy, r
end
local outer, acx, acy, ar = arch(OX0, OX1, OTOP, BOT)
local inner = arch(IX0, IX1, ITOP, BOT)
local frame = outer:copy():cut(inner)

-- stone frame: voussoirs around the arch, quoins down the jambs
local stok = A.tok("stone")
local blockId = {}
frame:each(function(x, y)
  local px, py = x + 0.5, y + 0.5
  local id
  if py < acy then
    local a = atan(py - acy, px - acx) -- -pi..0
    id = "v" .. floor((a + pi) / (pi / 7))
  else
    local side = px < CX and "L" or "R"
    local row = floor((py - acy + (side == "L" and 0 or 3)) / 6.5)
    id = side .. row
  end
  blockId[K(x, y)] = id
end)
local blocks = {}
frame:each(function(x, y) local id = blockId[K(x, y)] blocks[id] = blocks[id] or HP.mask() blocks[id]:set(x, y) end)
local mortar = HP.mask()
for id, bm in pairs(blocks) do
  -- 1 px mortar: block pixel whose right/lower neighbour belongs to another block
  bm:each(function(x, y)
    local r, d = blockId[K(x + 1, y)], blockId[K(x, y + 1)]
    if (r and r ~= id) or (d and d ~= id) then mortar:set(x, y) end
    if id:sub(1, 1) == "v" then
      local u = blockId[K(x - 1, y)]
      if u and u ~= id and u:sub(1, 1) ~= "v" then mortar:set(x, y) end
    end
  end)
end
for id, bm in pairs(blocks) do
  local b = bm:copy():cut(mortar)
  local n = X.pillow(b, 1.6)
  local bias = {}
  local hsh = X.hash(#id, id:byte(#id), 3)
  b:each(function(x, y) if hsh > 0.6 then bias[K(x, y)] = -1 end end)
  A.shade(c, b, n, STONE, { amb = 0.15, wrap = 0.35, bias = bias, tok = stok, cuts = { 0.16, 0.34, 0.52, 0.7, 0.88 },
    tilt = { 32, 30, 26, 0.12 } })
end
mortar:each(function(x, y) c:put(x, y, STONE[1], stok) end)

-- door planks
local wtok = A.tok("wood")
local door = inner:copy()
local planks = { { IX0, 27 }, { 28, 36 }, { 37, IX1 } }
local grainSeed = { 1, 7, 13 }
for pi_, pl in ipairs(planks) do
  local pm = door:copy():clip(c:rect(pl[1], 0, pl[2], 63))
  local x0, x1 = pl[1], pl[2]
  local n = {}
  pm:each(function(x, y)
    local s = ((x + 0.5) - (x0 + x1 + 1) / 2) / ((x1 - x0 + 1) / 2) -- -1..1 across the plank
    local sn = max(-0.9, min(0.9, s * 0.75))
    if s < -0.75 then sn = -0.8 end
    n[K(x, y)] = { sn, 0, sqrt(1 - sn * sn) }
  end)
  local bias = {}
  -- ambient band where the door sinks into the arch
  X.ao(bias, pm, frame, 2, -1)
  pm:each(function(x, y) if y >= BOT - 2 then local k = K(x, y) bias[k] = (bias[k] or 0) - 1 end end)
  local idx = A.shade(c, pm, n, WOOD, { amb = 0.12, wrap = 0.4, bias = bias, tok = wtok, cuts = { 0.14, 0.3, 0.5, 0.72, 0.9 },
    tilt = { 32, 32, 24, 0.14 } })
  -- grain: wavy vertical lines, one step darker; a knot on the middle plank
  pm:each(function(x, y)
    local u = x - x0
    local wv = floor(1.2 * math.sin((y + grainSeed[pi_] * 3) / 5.5) + 0.5)
    if (u == 2 + wv and y % 9 ~= 4) or (u == 6 + wv and (y + grainSeed[pi_]) % 11 > 2 and x < x1 - 1) then
      A.step(c, idx, WOOD, x, y, -1, wtok) end
  end)
  -- dark gap between boards
  if pi_ > 1 then pm:each(function(x, y) if x == x0 then c:put(x, y, WOOD[1], wtok) end end) end
  -- lit bevel on the plank's left edge
  pm:each(function(x, y) if x == x0 + 1 and y > 18 and y < BOT - 4 and idx[K(x, y)] and idx[K(x, y)] >= 3 then A.step(c, idx, WOOD, x, y, 1, wtok) end end)
end
-- knot
for _, p in ipairs{ { 33, 41, 1 }, { 34, 41, 1 }, { 32, 42, 2 }, { 33, 42, 1 }, { 34, 42, 1 }, { 35, 42, 2 }, { 33, 43, 2 }, { 34, 43, 2 } } do
  c:put(p[1], p[2], WOOD[p[3]], wtok) end
c:put(33, 41, WOOD[2], wtok)

-- iron strap hinges (3 px tall), from the left edge across most of the door, with rivets
local itok = A.tok("iron")
local function strap(y)
  local m = c:rect(IX0, y, 39, y + 2):clip(door)
  m:add(c:rect(39, y - 0, 41, y + 2):clip(door)) -- arrow end
  m:set(42, y + 1)
  m:each(function(x, y2)
    local i = (y2 == y) and 4 or ((y2 == y + 1) and 3 or 2)
    if x >= 40 then i = i - 1 end
    c:put(x, y2, IRON[max(1, i)], itok)
  end)
  c:put(IX0 + 2, y, IRON[5], itok) c:put(IX0 + 3, y, IRON[5], itok)
  -- rivets: 1 px lit heads with a dark under-pixel
  for _, rx in ipairs{ 22, 30, 37 } do c:put(rx, y + 1, IRON[5], itok) c:put(rx + 1, y + 1, IRON[2], itok) end
  -- contact shadow under the strap
  for x = IX0, 41 do if door:has(x, y + 3) then local h = c:get(x, y + 3)
    for i, w in ipairs(WOOD) do if w == h then c:put(x, y + 3, WOOD[max(1, i - 2)], wtok) end end end end
  return m
end
strap(24) strap(44)

-- brass ring pull on the right plank
local btok = A.tok("brass")
local ring = A.ring(40.5, 34, 1.6, 3.0)
local rn = X.pillow(ring, 1.2)
local ridx = A.shade(c, ring, rn, BRASS, { amb = 0.15, wrap = 0.3, tok = btok, cuts = { 0.2, 0.42, 0.62, 0.84 } })
-- back plate
for _, p in ipairs{ { 39, 29 }, { 40, 29 }, { 41, 29 }, { 42, 29 }, { 40, 30 }, { 41, 30 } } do c:put(p[1], p[2], BRASS[2], btok) end
c:put(39, 29, BRASS[4], btok)
c:put(38, 32, SPEC, btok)
-- shadow cast by the ring onto the door (lower right)
ring:shift(1, 1):each(function(x, y) if not ring:has(x, y) and door:has(x, y) and not A.ring(40.5, 34, 0, 1.5):has(x, y) then
  local h = c:get(x, y) for i, w in ipairs(WOOD) do if w == h then c:put(x, y, WOOD[max(1, i - 2)], wtok) end end end end)

-- round peep window near the top
local gtok = A.tok("glass")
local win = A.ell(32, 17, 3, 3)
local wn = X.sphere(32, 17, 3, win)
local gidx = A.shade(c, win, wn, { GLASS[2], GLASS[3], GLASS[3], GLASS[4] }, { amb = 0.2, tok = gtok, cuts = { 0.3, 0.55, 0.8 } })
win:edge():each(function(x, y) if x + y < 32 + 17 then c:put(x, y, GLASS[5], gtok) else c:put(x, y, GLASS[1], gtok) end end)
c:put(31, 15, SPEC, gtok)

-- quirk: mouse hole bottom-right of the door
local hole = arch(38, 42, BOT - 5, BOT)
hole:each(function(x, y) c:put(x, y, (y <= BOT - 4 or x == 38) and "#1e1420" or "#3a2430", wtok) end)
c:put(39, BOT - 6, WOOD[6], wtok) c:put(40, BOT - 6, WOOD[6], wtok) c:put(38, BOT - 5, WOOD[6], wtok) -- gnawed lit lip
c:put(41, BOT - 2, "#d8c8e0", wtok) c:put(40, BOT - 2, "#d8c8e0", wtok) -- a glinting mouse eye in the dark

-- doorstep slab
local step = c:rect(OX0 - 2, BOT + 1, OX1 + 2, BOT + 3)
local sn = X.pillow(step, 1.4)
A.shade(c, step, sn, STONE, { amb = 0.15, wrap = 0.3, tok = A.tok("step"), cuts = { 0.16, 0.34, 0.52, 0.7, 0.88 } })
for x = IX0, IX1 do c:put(x, BOT + 1, STONE[2], stok) end -- door's contact shadow on the step
A.save(c, "ico-door")
