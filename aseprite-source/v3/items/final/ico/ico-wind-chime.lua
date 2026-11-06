-- ico-wind-chime (final pass, Opus single pass). Bold icon: a hanging chime. A brass hook ring, two twine strings
-- down to a slim walnut top bar (grain lines, pale end grain on both ends), four slim brass tubes of staggered length
-- on short cords, a round wooden striker in the middle and a leaf-shaped wind sail at the bottom.
-- Material: per-pixel cylinder light on the tubes (6-tone brass, cool-violet shade) with a bright specular streak,
-- a dark bore ellipse and lit rim at each tube top, bevelled bar, AO under the bar where cords meet it,
-- twine twist (alternating light/dark pixels) on the cords.
-- quirk: a tiny sparrow has perched on the right end of the bar.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/../_helpers/_aR1_1.lua")
local HP, X, K = T.HP, T.X, T.K
local floor, max, min, sqrt, abs, sin, cos, pi = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.cos, math.pi
local c = T.new("ico-wind-chime")
local BRASS = { "#5a2f2a", "#8c5028", "#c27e2c", "#e6ae3e", "#ffd86e", "#fff0b4" }
local WOOD  = { "#3e2422", "#5e3628", "#86523a", "#ad7650", "#d29e6c", "#ecc890" }
local TWINE = { "#7a5a40", "#c9a478" }
local LEAF  = { "#1c4a3a", "#26623f", "#348046", "#4fa24e", "#7cc35a", "#b4dc78" }
local SPEC = "#fff8dc"

local BY0, BY1 = 17, 20       -- bar rows
local BX0, BX1 = 12, 51
local CX = 32

-- twine helper: 1 px cord with twist (alternating tones), drawn behind the solid parts
local ttok = { r = { name = "twine" } }
local function cord(x0, y0, x1, y1)
  local n = max(abs(x1 - x0), abs(y1 - y0), 1)
  for i = 0, n do local t = i / n
    local x, y = floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + .5)
    c:put(x, y, (i % 2 == 0) and TWINE[2] or TWINE[1], ttok)
  end
end
-- hanging strings from the ring to the bar ends (a triangle) and to the striker / sail
cord(CX - 1, 11, BX0 + 4, BY0 - 1)
cord(CX + 1, 11, BX1 - 4, BY0 - 1)
cord(CX, BY1 + 1, CX, 35)
cord(CX, 39, CX, 42)

-- hook ring (brass torus, 3 px band)
do
  local ring = HP.ellipse(CX, 8, 3.6, 3.6):cut(HP.ellipse(CX, 8, 1.4, 1.4))
  local n = {}
  ring:each(function(x, y)
    local dx, dy = x + 0.5 - (CX + 0.5), y + 0.5 - 8.5
    local r = sqrt(dx*dx + dy*dy) + 1e-6
    local s = (r - 2.6) / 1.4   -- -1 inner .. +1 outer
    s = max(-0.95, min(0.95, s))
    local nz = sqrt(1 - s*s)
    n[K(x, y)] = { dx / r * s, dy / r * s, nz }
  end)
  T.shade(c, ring, n, BRASS, { amb = 0.08, wrap = 0.2, tok = { r = { name = "ring" } } })
end

-- top bar: bevelled walnut, grain, pale end grain
local btok = { r = { name = "bar" } }
local bar = HP.rrect(BX0, BY0, BX1, BY1, 1)
local bidx = T.pil(c, bar, WOOD, 1.6, { amb = 0.1, wrap = 0.2, tok = btok })
for x = BX0 + 2, BX1 - 2 do
  local y = BY0 + 1 + ((floor(x / 7) % 2 == 0) and 0 or 1)
  if (x % 7) ~= 3 then T.step(c, bidx, WOOD, x, y, -1, btok) end
end
for _, ex in ipairs{ BX0, BX1 } do
  for y = BY0, BY1 do if bar:has(ex, y) then c:put(ex, y, y == BY0 + 1 and WOOD[6] or WOOD[5], btok) end end
end
c:put(BX0 + 1, BY0 + 1, WOOD[5], btok)
-- string knots on top of the bar
c:put(BX0 + 4, BY0, WOOD[1], btok) c:put(BX1 - 4, BY0, WOOD[1], btok)

-- tubes: x0, len (top at y=TY)
local TY = BY1 + 4
local tubes = { { 14, 21 }, { 22, 27 }, { 38, 24 }, { 46, 17 } }
local TW = 5
for i, tb in ipairs(tubes) do
  local x0, len = tb[1], tb[2]
  local mx = x0 + (TW - 1) / 2
  -- cord from bar to tube top
  cord(floor(mx), BY1 + 1, floor(mx), TY - 1)
  local y0, y1 = TY, TY + len - 1
  local m = HP.rect(x0, y0, x0 + TW - 1, y1)
  -- slanted bottom cut (chimes are cut at an angle)
  m:cut(HP.rect(x0 + 3, y1, x0 + TW - 1, y1))
  local n = {}
  m:each(function(x, y)
    local s = (x + 0.5 - (mx + 0.5)) / (TW / 2 + 0.2)
    s = max(-0.95, min(0.95, s))
    n[K(x, y)] = { s, 0, sqrt(1 - s*s) }
  end)
  local bias = {}
  -- AO just below the top rim
  for x = x0, x0 + TW - 1 do bias[K(x, y0 + 2)] = -1 end
  local tok = { r = { name = "tube" .. i } }
  local idx = T.shade(c, m, n, BRASS, { amb = 0.04, wrap = 0.1, bias = bias, tok = tok, cuts = { 0.12, 0.3, 0.5, 0.7, 0.9 } })
  -- top: dark bore with lit rim
  c:put(x0, y0, BRASS[4], tok) c:put(x0 + 1, y0, BRASS[6], tok) c:put(x0 + 2, y0, BRASS[5], tok)
  c:put(x0 + 3, y0, BRASS[4], tok) c:put(x0 + 4, y0, BRASS[3], tok)
  c:put(x0 + 1, y0 + 1, BRASS[1], tok) c:put(x0 + 2, y0 + 1, BRASS[1], tok) c:put(x0 + 3, y0 + 1, BRASS[2], tok)
  c:put(x0, y0 + 1, BRASS[3], tok) c:put(x0 + 4, y0 + 1, BRASS[2], tok)
  -- specular streak down the lit side, broken once
  for y = y0 + 4, y1 - 3 do if (y - y0) % 11 ~= 7 then c:put(x0 + 1, y, BRASS[6], tok) end end
  c:put(x0 + 1, y0 + 5, SPEC, tok)
  -- cool reflected light on the right edge near the bottom
  for y = y1 - 6, y1 - 2 do c:put(x0 + 4, y, "#8a5a6a", tok) end
end

-- striker: round wooden disc on the centre cord
do
  local m = HP.ellipse(CX, 37, 4.2, 2.2)
  local tok = { r = { name = "striker" } }
  local idx = T.pil(c, m, WOOD, 1.8, { amb = 0.1, wrap = 0.2, tok = tok })
  c:put(CX - 2, 36, WOOD[6], tok) c:put(CX - 1, 36, WOOD[6], tok)
  c:put(CX, 38, WOOD[1], tok) -- cord hole
end

-- wind sail: a leaf-shaped tag hanging at the bottom (blade, midrib, veins)
do
  local tok = { r = { name = "sail" } }
  local lm, ln, LT, LS, len = T.blade(CX, 42, CX - 4, 48, CX, 55, function(t)
    return 4.0 * sin(pi * min(1, t * 1.0 + 0.04)) ^ 0.7 - 0.1 end, { fold = 0.45 })
  local lidx = T.shade(c, lm, ln, LEAF, { amb = 0.12, wrap = 0.28, tok = tok, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 } })
  lm:each(function(x, y) local k = K(x, y)
    local t, s = LT[k], LS[k]
    if abs(s) < 0.16 and t > 0.06 and t < 0.92 then c:put(x, y, LEAF[min(6, (lidx[k] or 3) + 2)], tok)
    elseif t > 0.2 and t < 0.85 and abs(s) > 0.3 and abs(s) < 0.8 then
      local d = (t * len - abs(s) * 3.6) % 3.4
      if d < 0.9 then c:put(x, y, LEAF[max(1, (lidx[k] or 3) - 1)], tok) end
    end
  end)
end

-- quirk: tiny sparrow perched on the right end of the bar, facing left
do
  local map = {
    "...bbb....",
    "..bBBBb...",
    ".obeBBbb..",
    "oo.wBBbbbt",
    "..wwwBbbtt",
    "..wwwwbb.t",
    "....f.f...",
  }
  local P = { b = "#6e4632", B = "#a8704a", e = T.INK, w = "#f2e2c4", o = "#f5b82e", f = "#d98322", t = "#51302b" }
  T.map(c, map, BX1 - 10, BY0 - 7, P, { r = { name = "bird" } })
end

c:sparkle(55, 29)
T.save(c, "ico-wind-chime")
