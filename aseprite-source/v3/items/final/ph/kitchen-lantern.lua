-- kitchen-lantern (final, Opus single pass). A slim, tall half-timbered kitchen cottage seen 3/4: cream plaster front
-- gable with dark oak posts, braces and a wall plate; the side wall recedes to the right in shade under a slate roof
-- (staggered tabs with lit lower lips and dark gaps, pale ridge cap). A tin stovepipe with a lipped cap rises from the
-- roof. Green plank door with an arch and brass knob, warm glowing 4-pane window on a sill, a round gable vent, a stone
-- plinth. An iron bracket on the front corner holds a ribbed red paper lantern that glows and warms the plaster beside it.
-- Material: per-pixel plane + bevel light, slate tabs, wood grain, stone pillows, AO under the barge boards and eaves,
-- contact shadow from beams, stovepipe and lantern. quirk: a pale moth flutters at the lantern.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new("kitchen-lantern")

local PLASTER = { "#7a5a6e", "#a6868e", "#c8afa8", "#e4d0bc", "#f4e6cc", "#fff4e0" }
local WARMPL  = { "#8a5a52", "#b8826e", "#dca684", "#f2c896", "#ffdca8", "#fff0c8" }
local TIMBER  = { "#33202a", "#4e2e2c", "#6c4234", "#8c5a40", "#ac7852", "#cc9a6a" }
local SLATE   = { "#20244a", "#2e3866", "#3e5088", "#526aa6", "#6e8cc4", "#9ab6de" }
local STONE   = { "#36324a", "#524e66", "#726e86", "#9290a4", "#b4b2c2", "#d6d4e0" }
local IRON    = { "#1e1a26", "#302e3e", "#474858", "#666878", "#8e90a0", "#c0c4d0" }
local GLOW    = { "#8a3a1e", "#c25a24", "#e88a2e", "#f8b440", "#ffd870", "#fff2b8" }
local LANT    = { "#6e1e30", "#a82c36", "#d4443a", "#f06a44", "#ff9a5c", "#ffd08a" }
local DOOR    = { "#1c3632", "#285244", "#386c50", "#4c885a", "#68a666", "#90c47c" }

local x0, x1, yw, yb = 18, 35, 31, 52
local xm = 27
local DX, DY = 10, -5
local function pil(m, R, tx, ty, tz)
  local n = X.pillow(m, R)
  local o = {}
  for k, v in pairs(n) do o[k] = { A.norm(v[1] + tx, v[2] + ty, v[3] + (tz or 0)) } end
  return o
end
local function tone(m, n, ramp, bias, tok) return A.toneN(c, m, n, ramp, { bias = bias, tok = tok }) end

c:groundShadow(31, 54, 17, 1)

---------------------------------------------------------------- masks
local front = HP.poly{ { x0, yb + 1 }, { x0, yw }, { xm, yw - 11 }, { x1 + 1, yw }, { x1 + 1, yb + 1 } }
local side = HP.poly{ { x1 + 1, yw }, { x1 + 1 + DX, yw + DY }, { x1 + 1 + DX, yb + 1 + DY }, { x1 + 1, yb + 1 } }
local apx, apy = xm, yw - 14
local roof = HP.poly{ { apx, apy }, { apx + DX + 1, apy + DY }, { x1 + 5 + DX, yw + 2 + DY }, { x1 + 4, yw + 2 } }
roof:cut(front)
local boardL = c:line({ { x0 - 3, yw + 1 }, { xm - 0.5, apy + 1 } }, 3)
local boardR = c:line({ { xm - 0.5, apy + 1 }, { x1 + 3, yw + 1 } }, 3)
local boards = boardL:copy():add(boardR)

---------------------------------------------------------------- side wall (shade side)
do
  local sb = {}
  X.ao(sb, side, roof, 2, -1)
  local n = pil(side, 2, 0.95, 0, 0)
  local tok = { r = { name = "side" } }
  local idx = tone(side, n, PLASTER, sb, tok)
  -- de-skewed coordinates for side details
  side:each(function(x, y)
    local yy = y + (x - x1 - 1) * 0.5
    local lx = x - x1 - 1
    -- far corner post + wall plate + mid rail
    if lx >= DX - 2 or yy < yw + 2 or (yy >= yw + 9 and yy < yw + 11) then
      local i = (lx >= DX - 2 and lx == DX - 1) and 1 or 2
      if yy < yw + 2 and yy >= yw + 1 then i = 3 end
      c:put(x, y, TIMBER[i], tok)
    end
    -- stone plinth rows
    if yy >= yb - 4 + 0.01 then
      local row = floor((yy - (yb - 4)) / 2.5)
      local col = floor((lx + row * 2) / 4)
      local fx = (lx + row * 2) % 4
      local fy = (yy - (yb - 4)) - row * 2.5
      local i = 2
      if fx == 3 or fy < 0.6 then i = 1 elseif fx == 0 and fy < 1.6 then i = 3 end
      c:put(x, y, STONE[i], tok)
    end
    -- slit window glowing
    if lx >= 3 and lx <= 5 and yy >= yw + 3 and yy <= yw + 7 then
      local edge = lx == 3 or lx == 5 or yy < yw + 3.6 or yy > yw + 6.6
      c:put(x, y, edge and TIMBER[2] or ((lx == 4 and yy < yw + 5) and GLOW[4] or GLOW[3]), tok)
    end
  end)
end

---------------------------------------------------------------- front face: plaster with beams
local beams = HP.mask()
beams:add(c:rect(x0, yw, x0 + 1, yb - 4)):add(c:rect(x1 - 1, yw, x1, yb - 4)):add(c:rect(x0, yw, x1, yw + 1))
beams:add(c:line({ { x0 + 2, yw - 1 }, { xm - 3, yw - 6 } }, 2)):add(c:line({ { x1 - 2, yw - 1 }, { xm + 2, yw - 6 } }, 2))
beams:clip(front)
local door = HP.mask()
for y = yb - 13, yb do for x = x0 + 3, x0 + 8 do
  if y >= yb - 10 or (x + .5 - (x0 + 6)) ^ 2 + (y + .5 - (yb - 10)) ^ 2 <= 9.5 then door:set(x, y) end
end end
local doorFrame = door:grow(1):cut(door):clip(front)
local win = c:rect(x0 + 6 + 0, yw + 4, x0 + 11 + 0, yw + 9)    -- glass incl frame below
local winF = c:rect(x0 + 5, yw + 3, x0 + 11, yw + 9)
local glass = c:rect(x0 + 6, yw + 4, x0 + 10, yw + 8)
local sill = c:rect(x0 + 4, yw + 10, x0 + 12, yw + 10)
local vent = c:ellipse(xm - 0.5, yw - 6.5, 1.5, 1.5)
local plinth = c:rect(x0, yb - 3, x1, yb):cut(door):cut(doorFrame)
local plaster = front:copy():cut(beams):cut(door):cut(doorFrame):cut(winF):cut(sill):cut(plinth):cut(vent)
do
  local pb = {}
  X.ao(pb, plaster, boards, 2, -1)
  -- beams stand proud: shadow lower-right
  local function cast(caster, dx, dy)
    caster:shift(dx, dy):each(function(x, y) if plaster:has(x, y) and not caster:has(x, y) then
      local k = K(x, y) pb[k] = (pb[k] or 0) - 1 end end)
  end
  cast(beams, 1, 1) cast(sill, 0, 1) cast(winF, 1, 1)
  local n = pil(plaster, 2, -0.12, 0, 0)
  local tok = { r = { name = "plaster" } }
  local idx = tone(plaster, n, PLASTER, pb, tok)
  -- faint trowel texture
  plaster:each(function(x, y) local h = X.hash(x, y, 3)
    local k = K(x, y)
    if h > 0.93 then A.addT(c, idx, PLASTER, x, y, -1, tok) elseif h < 0.05 then A.addT(c, idx, PLASTER, x, y, 1, tok) end end)
  -- warm spill from the lantern
  plaster:each(function(x, y)
    local d = sqrt((x - 11) ^ 2 + (y - 42) ^ 2)
    if d < 10.5 then c:put(x, y, WARMPL[max(1, min(6, idx[K(x, y)] + (d < 8 and 1 or 0)))], tok) end
  end)
end
-- beams: rounded oak with grain
do
  local n = pil(beams, 1, -0.1, 0, 0)
  local tok = { r = { name = "beam" } }
  local idx = tone(beams, n, TIMBER, nil, tok)
  beams:each(function(x, y) if X.hash(x, y, 7) > 0.8 then A.addT(c, idx, TIMBER, x, y, -1, tok) end end)
end
-- door: vertical planks, arch, knob
do
  local db = {}
  door:each(function(x, y)
    local k = K(x, y)
    if (x - x0) % 2 == 0 and x > x0 + 3 then db[k] = -1 end
    if not door:has(x, y - 1) then db[k] = (db[k] or 0) - 1 end       -- recess AO at the head
  end)
  local n = pil(door, 1, -0.1, 0, 0)
  local tok = { r = { name = "door" } }
  local idx = tone(door, n, DOOR, db, tok)
  local fn = pil(doorFrame, 1, -0.1, 0, 0)
  tone(doorFrame, fn, TIMBER, nil, { r = { name = "dframe" } })
  c:put(x0 + 7, yb - 6, "#f5b82e", tok) c:put(x0 + 7, yb - 5, "#8f4a1f", tok) c:put(x0 + 6, yb - 6, "#ffe38a", tok)
  -- hinge straps
  for _, yy in ipairs{ yb - 9, yb - 3 } do for x = x0 + 3, x0 + 5 do c:put(x, yy, IRON[x == x0 + 3 and 4 or 3], tok) end end
end
-- window: frame, glowing panes, sill
do
  local tok = { r = { name = "win" } }
  winF:each(function(x, y) c:put(x, y, (x == x0 + 5 or y == yw + 3) and TIMBER[4] or TIMBER[2], tok) end)
  glass:each(function(x, y)
    local lx, ly = x - (x0 + 6), y - (yw + 4)
    local i = 4
    if lx <= 1 and ly <= 1 then i = 5 elseif lx >= 3 and ly >= 3 then i = 3 end
    if ly == 0 and lx ~= 2 then i = i - 1 end                -- head shadow
    if lx == 2 or ly == 2 then c:put(x, y, TIMBER[3], tok) else c:put(x, y, GLOW[i], tok) end
  end)
  c:put(x0 + 6, yw + 5, GLOW[6], tok)
  sill:each(function(x, y) c:put(x, y, (x == x0 + 4) and TIMBER[6] or (x > x0 + 10 and TIMBER[3] or TIMBER[5]), tok) end)
  -- vent
  vent:each(function(x, y) c:put(x, y, GLOW[3], tok) end)
  c:put(xm - 1, yw - 7, GLOW[5], tok)
  vent:grow(1):cut(vent):clip(front):cut(beams):each(function(x, y) c:put(x, y, TIMBER[(x < xm and y < yw - 6) and 4 or 2], tok) end)
end
-- plinth stones
do
  local tok = { r = { name = "plinth" } }
  plinth:each(function(x, y)
    local ly = y - (yb - 3)
    local row = ly < 2 and 0 or 1
    local fy = ly - row * 2
    local off = row * 2
    local fx = (x - x0 + off) % 5
    local i = 4
    if fx == 4 or (fy == 0 and row == 1) then i = 2
    elseif fx == 0 and fy == 0 then i = 6
    elseif fx == 0 or fy == 0 then i = 5
    elseif fx == 3 then i = 3 end
    if x > x1 - 3 then i = i - 1 end
    c:put(x, y, STONE[max(1, i)], tok)
  end)
  -- step slab
  for x = x0 + 2, x0 + 9 do c:put(x, yb + 1, x == x0 + 2 and STONE[5] or STONE[4]) end
  for x = x0 + 3, x0 + 9 do c:put(x, yb + 2, STONE[2]) end
end

---------------------------------------------------------------- roof: slate tabs
do
  local tok = { r = { name = "roof" } }
  local ex, ey = (x1 + 4) - apx, (yw + 2) - apy          -- ridge -> eave
  local det = DX * ey - DY * ex
  local rb = {}
  local L = sqrt(ex * ex + ey * ey)
  local n0 = { A.norm(0.42, -0.62, 0.66) }
  local n = {}
  local P = {}
  roof:each(function(x, y)
    local rx, ry = x + .5 - apx, y + .5 - apy
    local a = (rx * ey - ry * ex) / det                       -- along ridge 0..1
    local b = (DX * ry - DY * rx) / det                       -- down slope 0..1
    local s = b * L
    local row = floor((s - 1.2) / 2.6)
    local f = (s - 1.2) - row * 2.6
    local u = a * 11.2 + (row % 2) * 2
    local fu = u % 4.2
    local ny = 0
    local k = K(x, y)
    local bias = 0
    if s < 1.6 then bias = 2                                   -- ridge cap
    else
      if f < 0.8 then bias = -1 elseif f > 1.9 then bias = 1 end
      if fu < 0.75 and f > 0.8 then bias = -2 end
      if X.hash(row, floor(u / 4.2), 11) > 0.82 and bias == 0 then bias = -1 end
    end
    rb[k] = bias
    n[k] = n0
  end)
  -- stovepipe contact shadow on the roof (falls lower-right of the pipe)
  for y = 17, 26 do for x = 42, 44 do if roof:has(x, y) and x - 42 <= (y - 17) * 0.6 + 1 then rb[K(x, y)] = (rb[K(x, y)] or 0) - 1 end end end
  -- eave tip lighter end
  local idx = tone(roof, n, SLATE, rb, tok)
end
-- barge boards with pale end grain at the tips
do
  local tok = { r = { name = "board" } }
  local nL, nR = { A.norm(-0.5, -0.65, 0.6) }, { A.norm(0.55, -0.5, 0.65) }
  local n, bb = {}, {}
  boards:each(function(x, y)
    local k = K(x, y)
    n[k] = boardL:has(x, y) and nL or nR
    -- inner (lower) edge of the board darker
    if not boards:has(x, y + 1) and front:has(x, y + 1) then bb[k] = -1 end
    if not boards:has(x, y - 1) then bb[k] = (bb[k] or 0) + 1 end
  end)
  local idx = tone(boards, n, TIMBER, bb, tok)
  for _, p in ipairs{ { x0 - 3, yw + 1 }, { x0 - 2, yw + 2 }, { x1 + 3, yw + 1 }, { x1 + 2, yw + 2 } } do
    if boards:has(p[1], p[2]) then c:put(p[1], p[2], TIMBER[6], tok) end end
  c:put(xm - 1, apy + 1, TIMBER[6], tok)
end

---------------------------------------------------------------- stovepipe
do
  local tok = { r = { name = "pipe" } }
  local pm, pn = X.cyl(40, 10, 40, 24, function() return 1.5 end)
  pm:cut(c:rect(0, 0, 63, 9))
  -- clip pipe bottom along the roof slope
  local cut = HP.mask()
  pm:each(function(x, y) if y > 20 + (x - 39) * -0.4 + 2 then cut:set(x, y) end end)
  pm:cut(cut)
  local pb = {}
  pm:each(function(x, y) if (y == 14 or y == 18) then pb[K(x, y)] = -1 end if y == 15 or y == 19 then pb[K(x, y)] = 1 end end)
  local idx = A.toneN(c, pm, pn, IRON, { bias = pb, tok = tok })
  c:put(39, 12, IRON[6], tok) c:put(39, 13, IRON[6], tok)
  -- cap
  for x = 37, 43 do c:put(x, 8, x < 40 and IRON[5] or IRON[4], tok) c:put(x, 9, x < 39 and IRON[3] or IRON[2], tok) end
  c:put(37, 8, IRON[6], tok)
  -- flashing collar
  for x = 38, 42 do local y = floor(22 + (x - 39) * -0.4 + 0.5) c:put(x, y, x < 40 and IRON[4] or IRON[2], tok) end
end

---------------------------------------------------------------- bracket + paper lantern
do
  local tok = { r = { name = "bracket" } }
  for x = 10, x0 - 1 do c:put(x, yw + 3, x == 10 and IRON[5] or IRON[3], tok) end
  for i = 0, 3 do c:put(x0 - 1 - i, yw + 7 - i, IRON[2], tok) end
  c:put(10, yw + 4, IRON[4], tok) c:put(11, yw + 4, IRON[2], tok)           -- hook
  c:put(11, yw + 5, IRON[3], tok)
end
do
  local tok = { r = { name = "lantern" } }
  local cx, cy, rx, ry = 11, 42, 3, 3.6
  local m = c:ellipse(cx, cy, rx, ry)
  m:cut(c:rect(0, 0, 63, 37))
  local n = X.sphere(cx, cy, 3.6, m)
  local L = X.light(n, { amb = 0.05, wrap = 0.3 })
  local v = {}
  m:each(function(x, y)
    local k = K(x, y)
    local r = sqrt(((x - cx) / (rx + .5)) ^ 2 + ((y - cy) / (ry + .5)) ^ 2)
    v[k] = 0.55 * L[k] + 0.5 * (1 - r)
  end)
  local bias = {}
  m:each(function(x, y) if (y - 37) % 2 == 0 and abs(x - cx) < 3 then bias[K(x, y)] = -1 end end)
  local idx = X.tone(c, m, v, LANT, { cuts = { 0.12, 0.26, 0.4, 0.56, 0.7 }, bias = bias, tok = tok })
  c:put(cx - 1, cy - 2, "#fff0c0", tok)
  -- caps
  for x = cx - 2, cx + 2 do c:put(x, 37, x <= cx - 1 and TIMBER[4] or TIMBER[2], tok) c:put(x, 46, x <= cx - 1 and TIMBER[3] or TIMBER[1], tok) end
  c:put(cx, 36, IRON[3], tok)
  -- tassel
  c:put(cx, 47, "#f5b82e", tok) c:put(cx, 48, "#d98322", tok) c:put(cx - 1, 49, "#d98322", tok) c:put(cx + 1, 49, "#8f4a1f", tok)
end
-- quirk: a moth at the lantern
do
  local map = {
    "w..w",
    "WkkW",
    ".kk.",
  }
  local C = { w = "#f0e2c0", W = "#c8b48c", k = "#4a3830" }
  for yy, row in ipairs(map) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if C[ch] then c:put(4 + xx, 30 + yy, C[ch]) end end end
end

A.save(c, "kitchen-lantern")
