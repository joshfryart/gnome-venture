-- pluck (Opus third pass, richness): a thicker 2 px drawstring loop clearly hung on the hook, crushed-velvet nap,
-- a gold-embroidered diamond on the purse, a bounce line on the purse bottom and hook, a stamped coin face, and
-- curved sky lift arcs instead of the straight streaks (those read as rain).
-- pluck (Opus second pass). Tag "pluck" (Pluck: may lift an item). Replaces Haiku's tweezers (read as a wrench).
-- A steel fish hook on a taut line comes in from the upper right and has snagged the drawstring loop of a plum
-- velvet coin purse, hauling it up and away: frilled mouth, gold cinch cord, gather folds, lift ticks under it.
-- Material: 6-tone velvet with gather folds and a soft sheen, bevelled steel hook with a bright edge, gold cord twist.
-- quirk: one gold coin has slipped out of the purse and tumbles away.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local HP, X, K = O.HP, O.X, O.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = O.new("pluck")

local VEL  = { "#34163a", "#561f50", "#7e2c68", "#a6407f", "#cc649c", "#ee9cc0" }
local GOLD = { "#6e3a1c", "#a8601e", "#d98322", "#f5b82e", "#ffd860", "#fff0b0" }
local STL  = { "#2e3048", "#4a4d68", "#6e7290", "#9a9eb8", "#c8cce0", "#eef0f8" }
local LINE = { "#8a7a70", "#d8ccb8" }
local SKY  = { "#8bc4ea", "#e4f6ff" }

-- taut line from the upper right down to the hook eye
do
  local tok = O.tok("line")
  for t = 0, 1, 0.01 do
    local x, y = 50 + (38 - 50) * t, 2 + (7 - 2) * t
    c:put(floor(x + .5), floor(y + .5), t < 0.5 and LINE[2] or LINE[1], tok)
  end
end

-- drawstring loop (behind the hook): a gold cord ring hanging from the hook bend down to the purse mouth
local loopM = HP.mask()
do
  local tok = O.tok("loop")
  for y = 24, 40 do for x = 26, 36 do
    local q = ((x - 31) / 3.4) ^ 2 + ((y - 31) / 5.4) ^ 2
    local qi = ((x - 31) / 1.9) ^ 2 + ((y - 31) / 3.9) ^ 2
    if q <= 1 and qi > 1 then loopM:set(x, y) end
  end end
  -- two-tone twist: lit on the upper-left half, darker lower-right, a twist tick every other pixel
  loopM:each(function(x, y)
    local lit = (x - 31) + (y - 32.5) * 0.5 < 0
    local tw = (x + y) % 3 == 0
    c:put(x, y, lit and (tw and GOLD[6] or GOLD[5]) or (tw and GOLD[2] or GOLD[3]), tok)
  end)
end

-- the hook: eye ring, shank, J bend, point + barb
do
  local tok = O.tok("hook")
  local eye, en = O.oval(38, 8, 1.6, 1.8)
  local shank, sn = O.tube({ { 38, 9 }, { 38, 13 }, { 38, 16 }, { 38, 20 } }, function() return 1.35 end)
  local bend, bn = O.tube({ { 38, 19 }, { 38, 28 }, { 24, 28 }, { 24, 16 } }, function(t) return 1.4 - max(0, t - 0.72) * 2.6 end)
  local m = eye:copy():add(shank):add(bend)
  local n = {}
  for k, v in pairs(en) do n[k] = v end
  for k, v in pairs(sn) do n[k] = v end
  for k, v in pairs(bn) do n[k] = v end
  local idx = O.shade(c, m, n, STL, { tok = tok, amb = 0.15 })
  -- eye hole
  c:put(38, 8, "#2b1c26", tok)
  -- bright edge down the lit side of the shank, specular on the shank
  for y = 10, 23 do O.set(c, idx, STL, 37, y, 5, tok) end
  O.set(c, idx, STL, 37, 12, 6, tok) O.set(c, idx, STL, 37, 13, 6, tok)
  -- barb: a tooth on the inside of the point, angled down
  c:put(25, 19, STL[4], tok) c:put(26, 20, STL[3], tok) c:put(25, 20, STL[5], tok)
  O.set(c, idx, STL, 24, 17, 6, tok) O.set(c, idx, STL, 24, 18, 6, tok)
end
-- cord passes OVER the bottom of the bend on the front side (the snag): repaint the near strand over the steel
do
  local tok = O.tok("loop2")
  loopM:each(function(x, y) if y >= 25 and y <= 27 and x <= 31 then c:put(x, y, ((x + y) % 3 == 0) and GOLD[6] or GOLD[5], tok) end end)
  c:put(32, 25, GOLD[2], tok)
end

-- the purse
local purse = HP.mask()
local body, bodyN = O.oval(31, 48.5, 11, 8.5)
local neck = c:poly{ { 27, 37 }, { 35, 37 }, { 41, 45 }, { 21, 45 } }
purse:add(body):add(neck)
do
  local tok = O.tok("purse")
  local n = X.pillow(purse, 7)
  for k, v in pairs(bodyN) do local a = n[k] if a then n[k] = { O.norm(a[1] * .4 + v[1] * .6, a[2] * .4 + v[2] * .6, a[3] * .4 + v[3] * .6) } end end
  local idx = O.shade(c, purse, n, VEL, { tok = tok, amb = 0.1, wrap = 0.3 })
  -- gather folds radiating down from the cinch
  for _, f in ipairs{ { 26, -0.55 }, { 29, -0.18 }, { 33, 0.2 }, { 36, 0.55 } } do
    for y = 40, 47 do
      local x = floor(f[1] + f[2] * (y - 40) * 1.6 + .5)
      O.step(c, idx, VEL, x, y, -2, tok)
      if y < 45 then O.step(c, idx, VEL, x - 1, y, 1, tok) end
    end
  end
  -- bottom seam shadow + a cool bounce on the lower rim
  body:each(function(x, y) if not body:has(x, y + 1) and x > 24 then O.step(c, idx, VEL, x, y - 1, -1, tok) end end)
  -- sheen
  for _, p in ipairs{ { 24, 46 }, { 25, 45 }, { 24, 47 } } do O.set(c, idx, VEL, p[1], p[2], 6, tok) end
  -- crushed-velvet nap: short diagonal flecks one step lighter / darker on the mid tones
  purse:each(function(x, y)
    local i = idx[K(x, y)]
    if i and i >= 3 and i <= 5 and y > 40 then
      local h = O.hash(floor((x + y) / 2), floor((x - y) / 3), 21)
      if h > 0.86 then O.step(c, idx, VEL, x, y, 1, tok) elseif h < 0.1 then O.step(c, idx, VEL, x, y, -1, tok) end
    end
  end)
  -- bounce line: violet reflected light one pixel above the bottom edge on the shade side
  body:each(function(x, y) if body:has(x, y + 1) and not body:has(x, y + 2) and x > 27 and x < 40 then c:put(x, y, "#8a4a8e", tok) end end)
  -- gold-embroidered diamond on the front (cross-stitched, lit corner)
  O.map(c, { "..h..", ".gsg.", "hs.sg", ".gsg.", "..s.." }, 33, 45, { h = GOLD[6], g = GOLD[4], s = GOLD[3] }, tok)
end
-- frilled mouth above the cinch
do
  local tok = O.tok("frill")
  local fr = c:poly{ { 24, 33 }, { 38, 33 }, { 35, 38 }, { 27, 38 } }
  local fn = X.pillow(fr, 3)
  local idx = O.shade(c, fr, fn, VEL, { tok = tok, amb = 0.25 })
  -- scalloped top edge: notch every third pixel, pleat lines
  for x = 24, 38 do if x % 3 == 0 then O.erase(c, HP.mask():set(x, 33)) end end
  for _, x in ipairs{ 27, 30, 33, 36 } do O.step(c, idx, VEL, x, 35, -2, tok) O.step(c, idx, VEL, x, 36, -2, tok) end
  -- inside of the mouth (dark) where the frill opens
  for x = 27, 35 do if x % 3 ~= 0 then c:put(x, 34, VEL[1], tok) end end
end
-- gold cinch cord with twist and a knot at the front
do
  local tok = O.tok("cinch")
  for x = 26, 36 do
    c:put(x, 38, ((x % 2) == 0) and GOLD[5] or GOLD[4], tok)
    c:put(x, 39, ((x % 2) == 0) and GOLD[3] or GOLD[2], tok)
  end
  O.map(c, { ".hb.", "hbbs", ".ss." }, 30, 37, { h = GOLD[6], b = GOLD[4], s = GOLD[2] }, tok)
  -- the cord's loose end hangs down the front
  for _, p in ipairs{ { 32, 40, 4 }, { 32, 41, 3 }, { 33, 42, 4 }, { 33, 43, 2 } } do c:put(p[1], p[2], GOLD[p[3]], tok) end
end

-- lift arcs: two curved sky lines on the left of the purse, swinging up (it is being hauled up and away)
do
  local tok = O.tok("lift")
  for _, a in ipairs{ { 14.5, 2.3, 3.0 }, { 17.5, 2.4, 2.9 } } do
    for t = a[2], a[3], 0.02 do
      local x, y = floor(31 + math.cos(t) * a[1] + .5), floor(46 + math.sin(t) * a[1] + .5)
      if not purse:has(x, y) and not purse:has(x + 1, y) then c:put(x, y, (t < (a[2] + a[3]) / 2) and SKY[2] or SKY[1], tok) end
    end
  end
end

-- quirk: a coin slipped out and tumbles away (seen at an angle), with a little spin tick
do
  local tok = O.tok("coin")
  local m, n = O.oval(48, 50, 2.4, 3.6, 0.35)
  local idx = O.shade(c, m, n, GOLD, { tok = tok, amb = 0.2 })
  -- rim on the shade side
  m:each(function(x, y) if not m:has(x + 1, y) then O.set(c, idx, GOLD, x, y, 2, tok) end end)
  O.set(c, idx, GOLD, 47, 48, 6, tok)
  -- stamped face: a tiny acorn-shaped mark pressed into the coin
  c:put(48, 50, GOLD[2], tok) c:put(48, 51, GOLD[2], tok) c:put(49, 50, GOLD[3], tok) c:put(48, 49, GOLD[3], tok)
  c:put(52, 45, SKY[2], tok) c:put(53, 46, SKY[1], tok)
  c:put(51, 56, SKY[1], tok) c:put(52, 57, SKY[2], tok)
end

O.save(c, "pluck")
