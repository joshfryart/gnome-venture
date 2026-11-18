-- backpack.lua: five ESA (Thornacre Savanna) backpack concepts. See concepts.md.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local W = C
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local floor, sqrt, sin, max, min, abs = math.floor, math.sqrt, math.sin, math.max, math.min, math.abs
local ink = C.ink

-- rope/strap tube along a bezier, lit
local function rope(c, pts, w, ramp, o)
  o = o or {}
  local m, n, T = G.tube(pts, function() return w end)
  if o.clipOut then m:cut(o.clipOut) end
  local idx = W.toneN(c, m, n, ramp, { cuts = { .2, .38, .55, .72, .88 }, bias = o.b and C.bmap(m, o.b) })
  if o.twist then m:each(function(x, y) if (x + y) % 3 == 0 then local i = idx[K(x, y)] if i then c:put(x, y, ramp[max(1, i - 1)]) end end end) end
  return m
end

------------------------------------------------------------------ 1 coiled basket pack
local function basket(c)
  local body = c:rrect(14, 21, 49, 57, 7)
  local lid = c:ellipse(31.5, 20, 18.5, 5.5):add(c:rrect(13, 18, 50, 24, 2))
  -- sorghum head behind the lid
  local stalk = c:line({ {42,18}, {43,12}, {45,8} }, 1)
  stalk:each(function(x, y) c:put(x, y, R.leafg[4]) end)
  local head = c:ellipse(46, 6, 3, 4.5)
  local hi = C.lit(c, head, R.madder, { R = 2, b = 0 })
  head:each(function(x, y) if (x + y) % 2 == 0 then c:put(x, y, R.ochre[min(6, hi[K(x, y)] + 1)]) end end)
  W.put(c, { {44,4}, {45,3} }, R.ochre[6])
  local leaf = c:line({ {42,14}, {39,10}, {37,9} }, 1)
  leaf:each(function(x, y) c:put(x, y, R.leafg[5]) end)
  W.sep(c, body, lid, ink)
  local idx = C.vcyl(c, body, R.sisal, 14, 49, { cuts = { .2, .36, .52, .7, .88 } })
  -- coil grooves and wrap stitches
  W.retone(c, body, idx, R.sisal, function(x, y, i)
    if y % 3 == 0 then return -1 end
    if (x + floor(y / 3) * 2) % 4 == 0 then return 1 end
  end)
  -- dyed band 1: madder zigzag
  body:each(function(x, y)
    if y >= 29 and y <= 34 then
      local t = abs(((x - 14) % 8) - 4)
      if t <= y - 29 then c:put(x, y, R.madder[min(6, idx[K(x, y)])]) end
    end
    if y >= 46 and y <= 50 and y % 3 ~= 0 then
      if floor((x - 14) / 3) % 2 == 0 then c:put(x, y, R.indigo[min(6, idx[K(x, y)] + 1)]) end
    end
  end)
  -- leather band with brass buckle
  local band = c:rect(14, 39, 49, 41):clip(body)
  C.vcyl(c, band, R.strap, 14, 49)
  W.hline(c, 15, 48, 39, R.strap[5])
  local bk = c:rect(29, 38, 33, 42)
  C.lit(c, bk, R.brass, { R = 1 })
  c:fillMask(c:rect(31, 40, 31, 40), R.strap[2]) c:put(30, 38, C.cream)
  -- lid: coiled dome
  local li = C.lit(c, lid, R.sisal, { R = 4, b = 1, cuts = { .2, .36, .52, .7, .88 } })
  lid:each(function(x, y)
    local d = ((x - 31.5) / 18.5) ^ 2 + ((y - 20) / 5.5) ^ 2
    if floor(d * 5) ~= floor((d + 0.12) * 5) then c:put(x, y, R.sisal[max(1, li[K(x, y)] - 1)]) end
  end)
  W.hline(c, 14, 49, 24, R.sisal[2])
  W.hline(c, 15, 48, 25, R.sisal[1])
  -- knob
  C.bead(c, 31, 14, 1.5, R.wood, R.wood[6])
  c:put(17, 30, R.sisal[6]) c:put(16, 31, C.cream)
end

------------------------------------------------------------------ 2 calabash carrier
local function calabash(c)
  -- carrying loop on the left
  local loop = rope(c, { {24,29}, {8,24}, {4,42}, {16,50} }, 1.3, R.strap, { twist = true })
  local body = c:ellipse(33, 41, 18, 16)
  local neck = c:ellipse(33, 21, 7.5, 8.5):add(c:poly{ {26,22}, {40,22}, {45,30}, {21,30} })
  local all = body:copy():add(neck)
  W.sep(c, all, loop, ink)
  local n = X.sphere(32.4, 40.4, 17, body)
  local n2 = X.sphere(32.6, 20.6, 8, neck)
  for k, v in pairs(n2) do if not n[k] then n[k] = v end end
  local idx = W.toneN(c, all, n, R.gourd, { cuts = { .2, .36, .52, .7, .88 } })
  -- faint growth stripes
  W.retone(c, all, idx, R.gourd, function(x, y) if (x - 33) % 7 == 0 and y > 26 then return -1 end end)
  -- knotted net
  body:each(function(x, y)
    if y > 29 then
      local a, b = (x + y) % 6 == 0, (x - y) % 6 == 0
      if a or b then
        local i = idx[K(x, y)]
        c:put(x, y, (a and b) and R.strap[min(6, i + 1)] or R.strap[max(1, i - 1)])
      end
    end
  end)
  -- neck cord ring
  for x = 24, 42 do if all:has(x, 29) then c:put(x, 29, R.strap[3]) c:put(x, 30, R.strap[2]) end end
  for x = 25, 41, 3 do c:put(x, 29, R.strap[5]) end
  -- stopper
  local st = c:rrect(29, 9, 37, 14, 1)
  C.vcyl(c, st, R.wood, 29, 37)
  W.hline(c, 30, 36, 9, R.wood[6])
  W.hline(c, 29, 37, 14, R.wood[2])
  -- spec
  W.put(c, { {24,32}, {25,31}, {26,31} }, R.gourd[6]) c:put(24, 33, C.cream)
  c:put(29, 16, R.gourd[6])
  -- quirk: spotted guinea-fowl feather in the stopper
  local fm, fnn, FT, FS = G.tube({ {36,11}, {39,6}, {43,2}, {50,0} }, function(t) return 1.2 + 2.2 * math.sin(math.pi * math.min(1, t * 1.1)) end)
  fm:cut(c:rect(0, 12, 63, 63))
  W.sep(c, fm, st, ink)
  local fi = W.toneN(c, fm, fnn, R.indigo, { cuts = { .2, .36, .52, .7, .88 }, bias = C.bmap(fm, -2) })
  fm:each(function(x, y) if FS[K(x, y)] and math.abs(FS[K(x, y)]) < 0.25 then c:put(x, y, R.wool[4]) elseif (x + y) % 3 == 0 and x % 2 == 0 then c:put(x, y, R.wool[6]) end end)
end

------------------------------------------------------------------ 3 grain sack pack
local function sack(c)
  local body = c:ellipse(32, 43, 18, 13):add(c:poly{ {23,28}, {41,28}, {48,40}, {16,40} })
  local neck = c:poly{ {27,19}, {37,19}, {38,29}, {26,29} }
  local ruff = c:poly{ {23,11}, {26,14}, {28,10}, {31,13}, {34,9}, {36,13}, {39,10}, {41,15}, {38,20}, {26,20} }
  local earL = c:ellipse(14, 52, 3, 3) local earR = c:ellipse(50, 52, 3, 3)
  local weave = function(x, y, i) if (x % 2 == 0 and y % 2 == 0) or X.hash(x, y, 4) < .07 then return -1 end end
  -- rope from the tied corners up to the neck (behind)
  local rl = rope(c, { {14,52}, {9,42}, {14,30}, {26,25} }, 1.0, R.strap, { twist = true })
  local rr = rope(c, { {50,52}, {55,42}, {50,30}, {38,25} }, 1.0, R.strap, { twist = true })
  W.sep(c, body:copy():add(neck), rl:copy():add(rr), ink)
  local bi = C.lit(c, body, R.canvas, { R = 7, cuts = { .22, .38, .55, .72, .9 } })
  W.retone(c, body, bi, R.canvas, weave)
  -- sag folds
  W.put(c, { {22,32}, {21,34}, {21,36} }, R.canvas[3]) W.put(c, { {42,33}, {43,35} }, R.canvas[2])
  -- plain market stripes
  body:each(function(x, y) if y == 40 or y == 43 then c:put(x, y, R.madder[min(6, bi[K(x, y)])]) end end)
  local ni = C.lit(c, neck, R.canvas, { R = 2, b = -1 })
  W.retone(c, neck, ni, R.canvas, function(x, y) if x % 3 == 0 then return -1 end end)
  W.sep(c, ruff, neck, R.canvas[1])
  local ri = C.lit(c, ruff, R.canvas, { R = 2 })
  W.retone(c, ruff, ri, R.canvas, function(x, y) if (x - 1) % 3 == 0 and y > 13 then return -1 end end)
  -- tied corners
  for _, e in ipairs({ earL, earR }) do C.lit(c, e, R.canvas, { R = 1, b = -1 }) end
  W.vline(c, 16, 50, 54, R.strap[3]) W.vline(c, 48, 50, 54, R.strap[2])
  -- drawstring and knot
  for x = 25, 39 do c:put(x, 24, R.strap[4]) c:put(x, 25, R.strap[2]) end
  C.bead(c, 39, 25, 1.6, R.strap)
  W.put(c, { {40,27}, {41,28}, {41,29}, {42,30} }, R.strap[4])
  c:put(20, 36, R.canvas[6]) c:put(21, 35, R.canvas[6])
  -- quirk: tiny yellow weaver bird perched on the knot
  local bird = c:ellipse(43, 21, 3.2, 2.4):add(c:ellipse(46, 18, 2.2, 2.2))
  local tail = c:poly{ {38,21}, {41,20}, {41,23}, {38,24} }
  W.sep(c, bird:copy():add(tail), c:rect(0, 0, 63, 63):cut(bird):cut(tail), ink)
  C.lit(c, tail, R.ochre, { R = 1 })
  C.lit(c, bird, R.brass, { R = 2, b = 0 })
  W.put(c, { {46,18}, {47,18}, {47,19} }, R.umber[2])
  c:put(46, 17, R.umber[3])
  c:put(49, 18, R.ochre[3]) c:put(48, 19, R.ochre[2])
  W.put(c, { {42,22}, {43,22}, {44,23} }, R.ochre[4])
  W.put(c, { {42,24}, {44,24} }, R.umber[3])
end

------------------------------------------------------------------ 4 acacia frame pack
local function frame(c)
  -- quirk behind: thorny acacia twig with yellow puffballs, top right
  local tw = c:line({ {43,14}, {48,8}, {53,4} }, 1):add(c:line({ {49,8}, {55,9} }, 1))
  tw:each(function(x, y) c:put(x, y, R.wood[3]) end)
  W.put(c, { {46,9}, {51,5}, {53,10} }, R.wool[5])
  for _, p in ipairs({ {54,3}, {56,8}, {50,4} }) do C.bead(c, p[1], p[2], 1.6, R.brass, R.brass[6]) end
  local poleL = c:rect(16, 3, 19, 60)
  local poleR = c:rect(44, 3, 47, 60)
  local barT = c:rect(13, 9, 50, 11)
  local barB = c:rect(13, 52, 50, 54)
  -- back layer: poles and bars
  C.vcyl(c, poleL, R.wood, 16, 19, { b = -1 })
  C.vcyl(c, poleR, R.wood, 44, 47, { b = -1 })
  W.sep(c, barT:copy():add(barB), poleL:copy():add(poleR), R.wood[1])
  C.hcyl(c, barT, R.wood, 9, 11) C.hcyl(c, barB, R.wood, 52, 54)
  -- logs
  local logs = {
    { 9, 41, 49, 4 }, { 14, 33, 53, 4 }, { 10, 25, 46, 4 },
  }
  local lm = {}
  for i, L in ipairs(logs) do lm[i] = c:rrect(L[1], L[2] - L[4], L[3], L[2] + L[4], 2) end
  for i, L in ipairs(logs) do
    local m = lm[i]
    for j = i + 1, #logs do W.sep(c, lm[j], m, ink) end
    local idx = C.hcyl(c, m, R.barkg, L[2] - L[4], L[2] + L[4])
    m:each(function(x, y) if X.hash(x, y, i) < .18 then c:put(x, y, R.barkg[max(1, idx[K(x, y)] - 1)]) end end)
    m:each(function(x, y) if (x + i) % 9 == 0 and y ~= L[2] - 4 then c:put(x, y, R.barkg[2]) end end)
    -- cut end (left) with rings
    local e = c:ellipse(L[1] + 1.5, L[2], 2, L[4])
    e:clip(m)
    C.lit(c, e, R.wood, { R = 1, b = 1 })
    c:put(L[1] + 1, L[2], R.wood[3]) c:put(L[1] + 2, L[2], R.wood[4])
  end
  -- striped cloth roll on top
  local roll = c:rrect(12, 13, 51, 20, 3)
  W.sep(c, roll, lm[3], ink)
  local ri = C.hcyl(c, roll, R.yarnB, 13, 20)
  roll:each(function(x, y) if (x - 12) % 7 >= 5 then c:put(x, y, R.canvas[ri[K(x, y)]]) elseif (x - 12) % 7 == 0 then c:put(x, y, R.autumn[ri[K(x, y)]]) end end)
  -- front poles over the load: lashings
  for _, p in ipairs({ { 16, 19 }, { 44, 47 } }) do
    for _, ly in ipairs({ 17, 30, 44 }) do
      local w = c:rect(p[1] - 1, ly - 1, p[2] + 1, ly + 1)
      C.lit(c, w, R.strap, { R = 1, b = 1 })
      W.hline(c, p[1] - 1, p[2] + 1, ly, R.strap[3])
    end
  end
  W.vline(c, 16, 4, 8, R.wood[5]) W.vline(c, 44, 4, 8, R.wood[5])
  W.vline(c, 16, 56, 59, R.wood[5]) W.vline(c, 44, 56, 59, R.wood[5])
  c:put(14, 14, C.cream)
end

------------------------------------------------------------------ 5 herder's satchel
local function satchel(c)
  local strap = rope(c, { {14,30}, {12,6}, {52,6}, {50,30} }, 1.6, R.strap)
  local body = c:poly{ {12,24}, {52,24}, {54,49}, {10,49} }:add(c:rrect(10, 24, 54, 50, 4))
  -- fringe
  local fr = HP.mask()
  for x = 12, 52, 2 do fr:add(c:rect(x, 50, x, 56 + ((x % 4 == 0) and 1 or 0))) end
  W.sep(c, body, strap, ink)
  fr:each(function(x, y) c:put(x, y, ((x % 4 == 0) and R.leather[3] or R.leather[4])) end)
  fr:each(function(x, y) if not fr:has(x, y + 1) then c:put(x, y, R.leather[2]) end end)
  local bi = C.lit(c, body, R.leather, { R = 4, b = -1 })
  -- flap
  local flap = c:rrect(11, 22, 53, 32, 3):add(c:ellipse(32, 32, 21, 10)):clip(c:rect(0, 0, 63, 44))
  W.sep(c, flap, body, R.leather[1])
  local fi = C.lit(c, flap, R.leather, { R = 4, cuts = { .2, .36, .54, .7, .88 } })
  -- bead row along the flap edge
  local cols = { R.ember[4], R.jay[4], R.brass[4], R.canvas[6] }
  local e = HP.mask()
  flap:each(function(x, y) if not flap:has(x, y + 1) and y > 30 then e:set(x, y) end end)
  e:each(function(x, y) c:put(x, y - 1, cols[(floor(x / 2) % 4) + 1]) c:put(x, y, R.leather[2]) end)
  -- tooled stitch line
  for x = 14, 50, 2 do c:put(x, 25, R.leather[6]) end
  -- quirk: cowrie-shell button
  local cw = c:ellipse(32, 43, 2.2, 3)
  C.lit(c, cw, R.wool, { R = 1, b = 1 })
  W.vline(c, 32, 42, 45, R.wool[2]) c:put(31, 41, R.wool[6])
  c:put(14, 28, C.cream) c:put(15, 27, R.leather[6])
end

C.run{
  { "backpack-1-coiled-basket-pack", basket },
  { "backpack-2-calabash-carrier", calabash },
  { "backpack-3-grain-sack-pack", sack },
  { "backpack-4-acacia-frame-pack", frame },
  { "backpack-5-herders-satchel", satchel },
}
