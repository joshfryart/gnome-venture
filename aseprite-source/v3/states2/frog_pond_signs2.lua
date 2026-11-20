-- frog_pond EMPTY state, pass 2 (small): a small dry cracked mud flat with a rain puddle where the pond
-- will go; a little lily-pad plate floats at the puddle's front edge with a tiny frog sitting on it.
local K = dofile("/tmp/ase/states2/signs4_kit.lua")
local out = app.params.out or "./"
K.init(72, 56, "frog_pond", out)
local P, HP = K.P, K.HP
local px, R, E, ink, pt = K.px, K.R, K.E, K.ink, K.pt
local floor, sqrt = math.floor, math.sqrt
local MUD = { hi = "#dcb98c", base = "#c39a6c", sh = "#a07650", crack = "#7a5238", rim = "#644331" }
local WET = "#7a5238"
local PAD = { hi = P.moss.base, base = P.moss.shade, deep = P.moss.deep }

local function mudflat(m)
  local c = K.c
  c:fillMask(m, MUD.base)
  local seeds = {}
  for gy = 0, 4 do for gx = 0, 5 do
    local h1, h2 = K.hsh(gx * 3 + 1, gy * 7 + 2), K.hsh(gx * 11 + 5, gy * 3 + 9)
    seeds[#seeds + 1] = { 22 + gx * 6 + (gy % 2) * 3 + (h1 % 3) - 1, 30 + gy * 5 + (h2 % 3) - 1 }
  end end
  m:each(function(x, y)
    local d1, d2 = 1e9, 1e9
    for _, s in ipairs(seeds) do
      local dx, dy = (x - s[1]), (y - s[2]) * 1.5
      local d = sqrt(dx * dx + dy * dy)
      if d < d1 then d1, d2 = d, d1 elseif d < d2 then d2 = d end
    end
    if d2 - d1 < 0.9 then px(x, y, MUD.crack) end
  end)
  m:each(function(x, y) if c:get(x, y) == MUD.base and c:get(x, y - 1) == MUD.crack then px(x, y, MUD.hi) end end)
  m:each(function(x, y)
    if not m:has(x, y - 1) then px(x, y, MUD.rim)
    elseif not m:has(x, y - 2) then px(x, y, MUD.sh)
    elseif not m:has(x - 1, y) or not m:has(x + 1, y) then px(x, y, MUD.rim)
    elseif not m:has(x, y + 1) then px(x, y, MUD.hi) end
  end)
end

local function puddle(k)
  local pm = E(36, 37, 10, 5)
  local water = pm:shrink(1)
  K.c:fillMask(pm, WET)
  K.c:fillMask(water, P.sea.base)
  water:each(function(x, y) if not water:has(x, y - 1) then px(x, y, P.sea.shade) end end)
  -- life detail: a ripple ring spreading from where a raindrop fell, in the open water behind the pad
  local rp = ({ { { 32, 35 } }, { { 31, 35 }, { 33, 35 } }, { { 30, 35 }, { 34, 35 }, { 32, 34 } }, { { 29, 36 }, { 35, 36 } } })[k]
  for _, q in ipairs(rp) do if water:has(q[1], q[2]) then px(q[1], q[2], P.sky.hi) end end
  px(41, 34, P.sky.hi); px(42, 34, P.sky.hi)   -- sky glint
end

local function pad(fx, fy)
  -- face 21 x 7, round ends, a small V notch on the left end (ink rim makes 23 x 9)
  local m = K.c:rect(fx, fy, fx + 20, fy + 6)
  for _, q in ipairs{ { fx, fy }, { fx, fy + 6 }, { fx + 20, fy }, { fx + 20, fy + 6 }, { fx, fy + 3 } } do m.s[(q[2] + 256) * 1024 + (q[1] + 256)] = nil end
  -- pad shadow on the water, lower right
  m:copy():shift(1, 2):each(function(x, y) local v = K.c:get(x, y); if v == P.sea.base or v == P.sea.shade or v == P.sky.hi then px(x, y, P.sea.deep) end end)
  ink(m)
  K.c:fillMask(m, PAD.base)
  m:each(function(x, y)
    if not m:has(x - 1, y) or not m:has(x, y - 1) then px(x, y, PAD.hi)
    elseif not m:has(x + 1, y) or not m:has(x, y + 1) then px(x, y, PAD.deep) end
  end)
  K.word(fx + 1, fy + 1, P.cream)
end

local function frog(x, y)   -- 5 x 4 glyph sitting on the pad's top rim
  K.c:paint({
    ".o.o.",
    "oeoeo",
    "ogggo",
    "oGGGo" }, x, y, { o = P.ink, e = P.cream, g = P.moss.hi, G = P.moss.base })
end

local function drawEmpty(k)
  K.newc()
  local dy = ({ 0, 0, 1, 1 })[k]
  local m = K.plotMask({ { 27, 29 }, { 45, 29 }, { 49, 33 }, { 50, 44 }, { 46, 49 }, { 26, 49 }, { 22, 44 }, { 23, 33 } }, 5)
  mudflat(m)
  puddle(k)
  K.corners({ { 26, 30 }, { 46, 30 }, { 47, 48 }, { 25, 48 } }, 3)
  K.pebble(23, 39)
  K.flower(47, 37, P.gold.base, P.gold.deep)   -- one marsh marigold
  local fx, fy = 26, 40 + dy
  pad(fx, fy)
  frog(fx + 14, fy - 5)
  return K.c
end

local frames = {}
for k = 1, 4 do frames[k] = drawEmpty(k) end
K.saveStrip(frames, "frog_pond-empty", "empty")
