-- frog_pond EMPTY state: a dry cracked mud flat with a rain puddle where the pond will go;
-- the sign is a lily pad floating on the puddle, ripples spread, a dragonfly patrols.
local K = dofile("/tmp/ase/states2/signs4_kit.lua")
local out = app.params.out or "./"
K.init(72, 56, "frog_pond", out)
local P, HP = K.P, K.HP
local px, R, E, ink, pt = K.px, K.R, K.E, K.ink, K.pt
local floor, sqrt = math.floor, math.sqrt
local MUD = { hi = "#dcb98c", base = "#c39a6c", sh = "#a07650", crack = "#7a5238", rim = "#644331" }
local WET1, WET2 = "#7a5238", "#563628"
local PAD = { hi = P.moss.base, base = P.moss.shade, deep = P.moss.deep, under = "#1d4140", vein = "#4fa35c" }

local function mudflat(m)
  c = K.c
  c:fillMask(m, MUD.base)
  -- crazed cracks: Voronoi borders between jittered cells (wider than tall: 3/4 view)
  local seeds = {}
  for gy = 0, 6 do for gx = 0, 10 do
    local h1, h2 = K.hsh(gx * 3 + 1, gy * 7 + 2), K.hsh(gx * 11 + 5, gy * 3 + 9)
    seeds[#seeds + 1] = { 2 + gx * 7 + (gy % 2) * 3 + (h1 % 5) - 2, 21 + gy * 5 + (h2 % 5) - 2 }
  end end
  m:each(function(x, y)
    local d1, d2 = 1e9, 1e9
    for _, s in ipairs(seeds) do
      local dx, dy = (x - s[1]), (y - s[2]) * 1.5
      local d = sqrt(dx * dx + dy * dy)
      if d < d1 then d1, d2 = d, d1 elseif d < d2 then d2 = d end
    end
    if d2 - d1 < 0.8 then px(x, y, MUD.crack)
    elseif d1 < 1.2 then px(x, y, MUD.hi) end      -- curled flake tops catch the light
  end)
  -- lit lower lip of each crack
  m:each(function(x, y) if c:get(x, y) == MUD.base and c:get(x, y - 1) == MUD.crack then px(x, y, MUD.hi) end end)
  m:each(function(x, y)
    if not m:has(x, y - 1) then px(x, y, MUD.rim)
    elseif not m:has(x, y - 2) then px(x, y, MUD.sh)
    elseif not m:has(x - 1, y) or not m:has(x + 1, y) then px(x, y, MUD.rim)
    elseif not m:has(x, y + 1) then px(x, y, MUD.hi) end
  end)
  m:edge():each(function(x, y) if not m:has(x, y + 1) then px(x, y, MUD.sh) end end)
end

local function puddle(k)
  local pm = E(36, 39, 24, 10):cut(pt{ { 12, 39 }, { 60, 38 }, { 36, 49 }, { 37, 49 }, { 20, 31 }, { 53, 31 }, { 21, 31 } })
  local w = pm:shrink(1)
  local water = w:shrink(1)
  water:add(E(36, 39, 21, 8))
  K.c:fillMask(pm, WET1); K.c:fillMask(w, WET2)
  K.c:fillMask(water, P.sea.base)
  water:each(function(x, y) if not water:has(x, y - 1) or not water:has(x - 1, y) then px(x, y, P.sea.shade) end end)   -- far bank shades the water
  -- ripple ring spreading from the pad
  local rx = ({ 19, 20, 21, 22 })[k]
  E(36, 38 + (k > 2 and 1 or 0), rx, ({ 7, 8, 8, 9 })[k]):edge():each(function(x, y)
    if water:has(x, y) and K.c:get(x, y) == P.sea.base and (x + y) % 3 ~= 0 then px(x, y, P.sea.hi) end
  end)
  -- sky glints
  R(46, 46, 50, 46, P.sky.hi); R(17, 42, 18, 42, P.sky.hi)
  return water
end

local function pad(dy)
  local cx, cy = 36, 38 + dy
  local m = E(cx, cy, 16, 6)
  -- V notch at the top, left of centre, clear of the letters
  for _, q in ipairs{ { 29, -6 }, { 30, -6 }, { 31, -6 }, { 32, -6 }, { 30, -5 }, { 31, -5 }, { 31, -4 }, { 29, -5 } } do m.s[(cy + q[2] + 256) * 1024 + (q[1] + 256)] = nil end
  local under = m:copy():shift(0, 1):cut(m)
  -- pad shadow on the water, lower right
  m:copy():shift(2, 2):cut(m):each(function(x, y) local v = K.c:get(x, y); if v == P.sea.base or v == P.sea.hi or v == P.sea.shade then px(x, y, P.sea.deep) end end)
  ink(m, under)
  K.c:fillMask(under, PAD.under)
  K.c:fillMask(m, PAD.base)
  -- radial veins from the notch tip, only in the margin ring around the lettering
  local vx, vy = 31, cy - 3
  for a = 0, 15 do
    local ang = a / 16 * math.pi * 2
    for r = 4, 26 do
      local x, y = floor(vx + math.cos(ang) * r + .5), floor(vy + math.sin(ang) * r * .4 + .5)
      local inBox = (x >= 20 and x <= 50 and y >= cy - 3 and y <= cy + 3)
      if m:has(x, y) and not inBox then px(x, y, PAD.vein) end
    end
  end
  m:each(function(x, y)
    if not m:has(x - 1, y) or not m:has(x, y - 1) then px(x, y, PAD.hi)
    elseif not m:has(x + 1, y) or not m:has(x, y + 1) then px(x, y, PAD.deep) end
  end)
  px(24, cy - 4, P.moss.hi); px(25, cy - 4, P.moss.hi)   -- wet glint
  -- frog icon, then the word
  K.c:paint({
    ".h..h.",
    "hkhhkh",
    "hhhhhh",
    "hddddh",
    ".hhhh." }, 22, cy - 2, { h = P.moss.hi, k = P.ink, d = PAD.deep })
  K.word(30, cy - 2, P.cream, PAD.under)
end

local function dragonfly(x, y, up)   -- (x, y) = head; body runs right, 7 long
  local body = K.c:rect(x, y, x + 6, y)
  local wing = up and pt{ { x + 1, y - 1 }, { x + 2, y - 1 }, { x + 3, y - 1 }, { x + 2, y - 2 }, { x + 3, y - 2 }, { x + 4, y - 2 } }
    or pt{ { x + 1, y + 1 }, { x + 2, y + 1 }, { x + 3, y + 1 }, { x + 2, y + 2 }, { x + 3, y + 2 }, { x + 4, y + 2 } }
  local wing2 = up and pt{ { x + 1, y + 1 }, { x + 2, y + 1 } } or pt{ { x + 1, y - 1 }, { x + 2, y - 1 } }
  ink(body, wing, wing2)
  K.c:fillMask(wing, P.sky.hi); K.c:fillMask(wing2, P.sky.base)
  K.c:fillMask(body, P.sea.base); px(x, y, P.dusk.base); px(x + 1, y, P.sea.shade); px(x + 6, y, P.sea.deep); px(x + 5, y, P.sea.shade)
end

local function cattails(xs, yb, hs)
  local all, l = HP.mask(), {}
  for i, x in ipairs(xs) do
    local st, hd = K.c:rect(x, yb - hs[i], x, yb), K.c:rect(x, yb - hs[i] - 3, x, yb - hs[i] - 1)
    all:add(st):add(hd); l[#l + 1] = { st, hd, x, yb - hs[i] - 3 }
  end
  K.c:rim(all, P.ink)
  for _, q in ipairs(l) do K.c:fillMask(q[1], P.moss.shade); K.c:fillMask(q[2], P.wood.shade); px(q[3], q[4], P.wood.base) end
end

local function drawEmpty(k)
  K.newc()
  local dy = ({ 0, 0, 1, 1 })[k]
  local m = K.plotMask({ { 10, 23 }, { 62, 23 }, { 67, 54 }, { 5, 54 } }, 5)
  mudflat(m)
  puddle(k)
  K.corners({ { 13, 28 }, { 59, 28 }, { 64, 52 }, { 8, 52 } }, 5)
  pad(dy)
  -- bank life: cattails, marsh marigolds, forget-me-nots, pebbles
  cattails({ 2, 4 }, 44, { 12, 16 })
  K.flower(68, 22, P.gold.base, P.gold.deep); K.flower(69, 47, P.sky.base, P.gold.hi)
  K.flower(3, 50, P.sky.base, P.gold.hi)
  K.tuft(40, 55); K.tuft(64, 30)
  K.pebble(12, 46); K.pebble(53, 26)
  -- dragonfly patrol
  local D = { { 10, 12 }, { 20, 9 }, { 31, 12 }, { 20, 15 } }
  dragonfly(D[k][1], D[k][2], k % 2 == 1)
  return K.c
end

local frames = {}
for k = 1, 4 do frames[k] = drawEmpty(k) end
K.saveStrip(frames, "frog_pond-empty", "empty")
