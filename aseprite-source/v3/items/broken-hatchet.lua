-- broken-hatchet (pass 3B, final). Side-on hatchet, slim: 4-5 px bellied handle with a flared butt, narrow neck,
-- short bearded blade. Snapped under the head: head + stub knocked up-right, long pale splinters, one sliver flying.
-- Realism (hpx.lua): wood = cylinder light in 6 tones + wavy grain + a small knot; fresh break faces pale.
-- Steel = polished "horizon" (sky-lit upper half, ground-dark lower half) with a specular streak on the horizon,
-- ground bevel with a dark ridge and a bright cutting edge, cool reflected light on the underside, raised eye boss,
-- the handle end + dark wedge showing through the eye, AO where wood meets steel.
-- History: broken-hatchet.p1 (pass 1), broken-hatchet.p2 (previous final).
-- quirk: gold thread wrapped round the grip (twisted, with contact shadow), loose end unravelling into a curl.
local LIB = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local out = app.params.out or "./"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "broken-hatchet" }

local WOOD  = { "#4a2a22", "#6a3c2a", "#8b5233", "#ad6d3e", "#c98a50", "#e0aa6e" }
local FRESH = { "#d7a66a", "#f0cd95" }
local STEEL = { "#3c3e57", "#555973", "#72778f", "#9296ab", "#b7bacb", "#dddfe8" }
local SPEC, BOUNCE = "#f5f6fa", "#89a3c8"
local GOLD  = { "#8f4a1f", "#c97a22", "#f0ae2c", "#ffda74" }
local wtok, stok, gtok = { r = { name = "wood" } }, { r = { name = "steel" } }, { r = { name = "thread" } }

-- handle cylinder: A (top, in the eye) -> B (butt), unshifted layout coords
local AX, AY, BX, BY = 43, 7, 23, 53
local hm, hn, hT, hS = X.cyl(AX, AY, BX, BY, function(t)
  local w = 1.45 + 0.45 * math.sin(math.pi * math.min(1, t * 1.05))
  if t > 0.92 then w = w + 0.75 end                   -- butt swell
  if t > 0.985 then w = w - 0.7 end
  return w
end)
local hv = X.light(hn, { amb = 0.12, wrap = 0.3 })
local function grainBias(x, y)
  local k = K(x, y)
  local s, t = hS[k], hT[k]
  if not s then return 0 end
  for gi, g in ipairs{ -0.42, 0.28 } do
    local gg = g + 0.16 * math.sin(t * 26 + gi * 2)    -- wavy grain line
    if math.abs(s - gg) < 0.17 and ((t * 40 + gi * 5) % 9) > 2 then return -1 end
  end
  return 0
end
local function wood(m, dx, dy, bias)
  m:each(function(x, y)
    local k = K(x, y)
    local i = math.floor((hv[k] or 0.3) * 5.99) + 1 + grainBias(x, y) + ((bias and bias[k]) or 0)
    c:put(x + dx, y + dy, WOOD[math.max(1, math.min(6, i))], wtok)
  end)
end

-- break line with long splinters (lower piece keeps a tall sliver on the right)
local zig = { {27,29},{30,32},{31,30},{32,33},{33,31},{34,34},{35,28},{36,33},{38,32},{42,32} }
local function side(extra) local t = {} for _, p in ipairs(zig) do t[#t+1] = p end t[#t+1] = extra[2] t[#t+1] = extra[1] return t end
local below, above = c:poly(side{ {0,63},{63,63} }), c:poly(side{ {0,0},{63,0} })
local low = hm:copy():clip(below)
local stub = hm:copy():clip(above):cut(below:shift(0, -1)):cut(below:shift(-1, -1))
local SX, SY = 2, -3

-- lower piece: grip thread contact shadows go in its bias
local lowBias = {}
local wraps = { 43, 46, 49 }
local function wrapPix(y0, f)
  local tc = (y0 - AY) / (BY - AY)
  local xc = math.floor(AX + (BX - AX) * tc + 0.5)
  for i = -4, 4 do f(xc + i, y0 - math.floor(i / 2)) end
end
for _, y0 in ipairs(wraps) do wrapPix(y0, function(x, y) if low:has(x, y + 1) then lowBias[K(x, y + 1)] = -1 end end) end
wood(low, 0, 0, lowBias)
-- fresh break face (pale) along the top of the lower piece
low:each(function(x, y) if not low:has(x, y - 1) and hT[K(x, y)] < 0.66 then
  c:put(x, y, FRESH[2], wtok) if low:has(x, y + 1) and not low:has(x, y - 2) then c:put(x, y + 1, FRESH[1], wtok) end end end)

-- stub (shifted with the head)
wood(stub, SX, SY)
stub:each(function(x, y) if not stub:has(x, y + 1) then c:put(x + SX, y + SY, FRESH[1], wtok) end end)

-- head: slim neck, short bearded blade
local head = c:poly{ {46,12},{39,12},{31,13},{24,12},{19,10},{15,9},{12,11},{11,15},{11,20},{12,24},{14,27},{16,29},
  {18,28},{21,24},{26,20},{32,18},{39,19},{46,19} }
local boss = c:rrect(39, 10, 47, 21, 3)
head:add(boss)
local horizon = 15                                    -- sky/ground split on the polished cheek
local bevel = head:copy():cut(head:shift(3, 0)):clip(c:rect(0, 0, 22, 63))
local ridge = bevel:shift(1, 0):cut(bevel):clip(head):clip(c:rect(0, 0, 23, 63))
local edgeL = head:copy():cut(head:shift(1, 0)):clip(c:rect(0, 0, 22, 63))   -- the cutting edge itself
local bn = X.pillow(boss, 1.5)
local bv = X.light(bn, { amb = 0.15, wrap = 0.2 })
head:each(function(x, y)
  local i
  if boss:has(x, y) then
    i = math.floor(bv[K(x, y)] * 5.99) + 1 + (y < horizon and 0 or -1)   -- rounded boss, same sky/ground split
    if not boss:has(x - 1, y) and head:has(x - 1, y) then i = 2 end        -- seam where the boss rises from the neck
  elseif bevel:has(x, y) then
    i = y < horizon + 1 and 6 or 5
  else
    i = y < horizon and 5 or 3
    if y == horizon - 1 then i = 6 end                  -- specular streak on the horizon
    if y == horizon then i = 2 end
  end
  if ridge:has(x, y) then i = y < horizon and 3 or 2 end
  if not head:has(x, y - 1) and not boss:has(x, y) then i = 6 end   -- top edge catches the light
  c:put(x + SX, y + SY, STEEL[math.max(1, math.min(6, i))], stok)
end)
-- cutting edge: brightest on the upper part, plus the one sparkle
edgeL:each(function(x, y) if y < horizon + 3 then c:put(x + SX, y + SY, STEEL[6], stok) end end)
c:put(11 + SX, 16 + SY, SPEC, stok) c:put(11 + SX, 17 + SY, SPEC, stok)
-- cool reflected light along the underside (beard + neck), not on the boss
head:each(function(x, y) if not head:has(x, y + 1) and x > 13 and x < 38 then c:put(x + SX, y + SY, BOUNCE, stok) end end)
-- boss bottom: AO where the stub enters
for x = 40, 46 do if head:has(x, 21) then c:put(x + SX, 21 + SY, STEEL[1], stok) end end
-- eye: handle end through the top (end grain + dark wedge), dark gap each side
local ex0, ex1 = 41, 45
for x = ex0, ex1 do c:put(x + SX, 9 + SY, WOOD[4], wtok) c:put(x + SX, 10 + SY, WOOD[3], wtok) end
c:put(ex0 + SX, 9 + SY, WOOD[6], wtok) c:put(ex0 + 1 + SX, 9 + SY, WOOD[5], wtok)
c:put(43 + SX, 9 + SY, WOOD[1], wtok) c:put(43 + SX, 10 + SY, WOOD[1], wtok)        -- wedge
c:put(40 + SX, 10 + SY, STEEL[1], stok) c:put(46 + SX, 10 + SY, STEEL[1], stok)
for x = 40, 46 do c:put(x + SX, 11 + SY, x >= ex0 and x <= ex1 and STEEL[1] or STEEL[6], stok) end

-- flying sliver (pale face up-left)
local chip = c:poly{ {47,29},{52,26},{53,27},{49,31} }
chip:each(function(x, y) c:put(x, y, (x + y < 77) and FRESH[2] or WOOD[4], wtok) end)

-- quirk: thread wraps (twisted: alternate light / mid, shade on the right), loose end curling
for _, y0 in ipairs(wraps) do
  wrapPix(y0, function(x, y)
    if low:has(x, y) then
      local s = hS[K(x, y)] or 0
      local g = s < -0.2 and 4 or s < 0.5 and 3 or 2
      if (x % 2 == 1) and g > 2 then g = g - 1 end
      c:put(x, y, GOLD[g], gtok)
    end
  end)
end
c:paint({
  "ab..........",
  "..ab........",
  "....ab...ab.",
  "......b.a..b",
  ".......b...b",
  "........abb.",
}, 27, 49, { a = GOLD[4], b = GOLD[3] })

-- final placement: whole drawing 3 px down
for y = 60, 0, -1 do for x = 0, 63 do
  c.pix[(y + 3) * 64 + x], c.own[(y + 3) * 64 + x] = c.pix[y * 64 + x], c.own[y * 64 + x]
end end
for y = 0, 2 do for x = 0, 63 do c.pix[y * 64 + x], c.own[y * 64 + x] = nil, nil end end
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "broken-hatchet.aseprite", png = out .. "broken-hatchet.png" }
