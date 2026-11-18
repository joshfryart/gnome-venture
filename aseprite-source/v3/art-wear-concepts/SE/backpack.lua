-- backpack.lua: Olivewhistle Shore (SE) backpack concepts, 5 icons 64x64.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, W, G = C.HP, C.X, C.K, C.R, C, C.G
local ink, cream = C.ink, C.cream
local only = app.params.only
local floor, max, min = math.floor, math.max, math.min

local function olive(c, x, y, ramp)
  local m = c:ellipse(x, y, 1.5, 2)
  C.part(c, m, ramp or R.grape, { R = 1 })
  c:put(x - 1, y - 1, (ramp or R.grape)[6])
end

-- 1 Olive Picker's Creel -----------------------------------------------------------
local function b1()
  local c = C.canvas("backpack-1-olive-creel")
  -- branch + leaves behind the rim (drawn first, rim overlaps)
  local stem = c:line({ {22,24}, {26,14}, {32,8}, {40,5} }, 2):add(c:line({ {30,10}, {28,4} }, 1)):add(c:line({ {36,19}, {42,12}, {48,10} }, 1))
  c:fillMask(stem, R.wood[2])
  for _, l in ipairs({ { 26,14, 17,8 }, { 32,8, 30,0 + 1 }, { 33,8, 40,0 + 1 }, { 40,5, 49,3 }, { 42,12, 50,16 }, { 44,11, 47,4 }, { 26,15, 20,17 } }) do
    G.leaf(c, l[1], l[2], l[3], l[4], 2.3, R.sage)
  end
  olive(c, 37, 11) olive(c, 46, 15, R.olive) olive(c, 24, 12, R.olive) olive(c, 30, 16)
  -- basket body
  local body = c:poly{ {13,22}, {51,22}, {45,57}, {19,57} }
  local bi = C.part(c, body, R.wicker, { R = 6, hs = 0.7 })
  W.retone(c, body, bi, R.wicker, function(x, y, i)
    local row = floor((y - 22) / 3)
    if (x - 1) % 5 == 0 then return -2 end                          -- stakes
    if (y - 22) % 3 == 2 then return -1 end                         -- row gaps
    if (floor((x - 1) / 5) + row) % 2 == 0 then return 1 end        -- weaver over the stake
  end)
  -- base band
  local base = c:rrect(18, 53, 46, 58, 2)
  C.part(c, base, R.wicker, { R = 2, b = -1 })
  for x = 19, 45, 2 do c:put(x, 55, R.wicker[2]) end
  -- rolled rim with twist
  local rim = c:rrect(11, 18, 53, 24, 3)
  C.part(c, rim, R.wicker, { R = 3, b = 1 })
  rim:each(function(x, y) if (x + y) % 4 == 0 and y > 18 and y < 24 then c:put(x, y, R.wicker[3]) end end)
  W.hline(c, 13, 51, 25, R.wicker[1])
  -- leather shoulder straps (we see the back)
  for _, sx in ipairs({ 22, 39 }) do
    local s = c:rect(sx, 26, sx + 3, 52)
    C.vc(c, s, R.strap, sx, sx + 3)
    W.vline(c, sx, 26, 52, R.strap[5])
    c:put(sx + 1, 30, R.brass[5]) c:put(sx + 2, 48, R.brass[3])
  end
  -- quirk: small snail climbing the right side
  local shell = c:ellipse(48, 41, 3, 3)
  C.part(c, shell, R.saffron, { R = 2 })
  W.put(c, { {48,40}, {49,41}, {48,42}, {47,41}, {47,39} }, R.saffron[2])
  c:put(48, 41, R.saffron[5]) c:put(46, 39, R.saffron[6])
  local foot = c:poly{ {44,44}, {50,44}, {52,46}, {44,46} }
  C.part(c, foot, R.fleece, { R = 1 })
  W.put(c, { {51,42}, {52,41} }, R.fleece[3])
  c:put(17, 21, cream) c:put(18, 20, R.wicker[6])
  C.save(c, "backpack-1-olive-creel")
end

-- 2 Fisher's Float Net -------------------------------------------------------------
local function b2()
  local c = C.canvas("backpack-2-float-net")
  local bag = c:ellipse(32, 40, 17, 15):add(c:poly{ {22,30}, {29,17}, {35,17}, {42,30} })
  c:fillMask(bag, R.jute[1])
  -- contents seen through the mesh
  local function blob(m, ramp, b) C.part(c, m, ramp, { R = 3, b = b }) end
  local f1 = c:ellipse(24, 44, 7, 6):clip(bag) blob(f1, R.cork)
  local gl = c:ellipse(40, 46, 7, 7):clip(bag) blob(gl, R.sea)
  local lm = c:ellipse(33, 33, 6, 5):clip(bag) blob(lm, R.lemon)
  local f2 = c:ellipse(43, 34, 4, 4):clip(bag):cut(gl) blob(f2, R.cork, -1)
  local f3 = c:ellipse(22, 34, 4, 3):clip(bag):cut(f1) blob(f3, R.cork, -1)
  c:put(37, 42, cream) c:put(38, 42, R.sea[6]) c:put(30, 31, R.lemon[6]) c:put(21, 41, R.cork[6])
  for _, p in ipairs({ {24,44}, {28,46}, {20,47} }) do c:put(p[1], p[2], R.cork[2]) end
  -- net mesh: diamond cords, lit upper-left
  bag:each(function(x, y)
    local a, b = (x + y) % 5 == 0, (x - y) % 5 == 0
    if a or b then
      local lit = (x - 32) + (y - 40) < 0
      c:put(x, y, (a and b) and R.jute[6] or (lit and R.jute[5] or R.jute[3]))
    end
  end)
  -- gathered neck with rope wrap + loop
  local neck = c:rrect(28, 14, 36, 19, 1)
  C.part(c, neck, R.jute, { R = 1 })
  for x = 28, 36 do if x % 2 == 0 then c:put(x, 15, R.jute[2]) c:put(x + 1, 17, R.jute[2]) end end
  local loop = c:line({ {30,14}, {27,8}, {30,4}, {35,4}, {38,8}, {34,14} }, 2)
  loop:each(function(x, y) if not neck:has(x, y) then c:put(x, y, R.jute[(x < 33 and y < 10) and 5 or 3]) end end)
  -- quirk: silver fish charm off the knot
  local cord = c:line({ {37,18}, {41,22} }, 1)
  c:fillMask(cord, R.jute[2])
  local fish = c:ellipse(45, 24, 3.5, 1.5):add(c:poly{ {48,24}, {51,21.5}, {51,26.5} })
  C.part(c, fish, R.steel, { R = 1, b = 1 })
  c:put(43, 23, R.indigo[1]) W.hline(c, 43, 47, 25, R.steel[2]) c:put(44, 23, R.steel[6])
  C.save(c, "backpack-2-float-net")
end

-- 3 Amphora Frame ----------------------------------------------------------------
local function b3()
  local c = C.canvas("backpack-3-amphora-frame")
  -- wooden frame: two uprights + crossbars
  local poles = c:rect(16, 6, 19, 59):add(c:rect(44, 6, 47, 59))
  local bars = c:rect(16, 10, 47, 12):add(c:rect(16, 53, 47, 55))
  local pi = C.part(c, bars, R.wood, { R = 1, b = -1 })
  W.hline(c, 17, 46, 10, R.wood[5]) W.hline(c, 17, 46, 53, R.wood[4])
  W.sep(c, poles, bars, R.wood[1])
  C.vc(c, c:rect(16, 6, 19, 59), R.wood, 16, 19)
  C.vc(c, c:rect(44, 6, 47, 59), R.wood, 44, 47, { b = -1 })
  for _, y in ipairs({ 6, 59 }) do c:put(16, y, R.wood[3]) c:put(47, y, R.wood[2]) end
  -- amphora
  local body = c:ellipse(32, 35, 11, 13):add(c:poly{ {26,44}, {38,44}, {32,56} })
  local neck = c:rect(28, 13, 36, 24)
  local lip = c:rrect(26, 11, 38, 15, 1)
  local jar = body:copy():add(neck)
  W.sep(c, jar, poles:copy():add(bars), R.wood[1])
  local ji = C.part(c, body, R.terra, { R = 8, hs = 0.9 })
  C.vc(c, neck:copy():cut(body), R.terra, 28, 36)
  W.hline(c, 28, 36, 24, R.terra[2])
  C.part(c, lip, R.terra, { R = 1, b = 1 })
  W.hline(c, 27, 37, 15, R.terra[1])
  -- painted band (plain wave)
  for x = 22, 42 do
    local y = 30 + ((x % 4 < 2) and 0 or 1)
    if body:has(x, y) then c:put(x, y, R.linen[(x < 30) and 5 or 3]) end
  end
  -- handles
  local hl = c:line({ {28,17}, {22,17}, {20,22}, {22,26} }, 2)
  local hr = c:line({ {36,17}, {42,17}, {44,22}, {42,26} }, 2)
  hl:cut(neck) hr:cut(neck)
  hl:each(function(x, y) c:put(x, y, R.terra[(y < 19) and 5 or 4]) end)
  hr:each(function(x, y) c:put(x, y, R.terra[(y < 19) and 3 or 2]) end)
  -- rope lashing across to the poles
  for _, y in ipairs({ 27, 43 }) do
    for x = 18, 45 do
      if not (y == 27 and (x == 21 or x == 43)) then
        c:put(x, y, ((x + y) % 2 == 0) and R.jute[5] or R.jute[3]) c:put(x, y + 1, ((x + y) % 2 == 0) and R.jute[2] or R.jute[3])
      end
    end
  end
  -- glaze sheen
  W.put(c, { {25,30}, {25,31}, {25,32}, {26,29} }, R.terra[6]) c:put(25, 33, cream)
  -- quirk: cork stopper with a lemon-yellow tassel
  local cork = c:rrect(29, 6, 35, 11, 1)
  C.part(c, cork, R.cork, { R = 1 })
  c:put(30, 7, R.cork[6]) c:put(33, 9, R.cork[2]) c:put(31, 9, R.cork[3])
  local cord = c:line({ {35,8}, {39,7}, {41,9} }, 1)
  c:fillMask(cord, R.strap[3])
  local tas = c:poly{ {40,9}, {42,9}, {44,17}, {38,17} }
  C.part(c, tas, R.lemon, { R = 1 })
  for x = 39, 43, 2 do W.vline(c, x, 13, 16, R.lemon[3]) end
  W.hline(c, 40, 42, 10, R.lemon[2])
  C.save(c, "backpack-3-amphora-frame")
end

-- 4 Sailcloth Seabag -------------------------------------------------------------
local function b4()
  local c = C.canvas("backpack-4-sailcloth-seabag")
  -- rope shoulder loop behind
  local rope = G.tube({ {36,15}, {54,14}, {56,44}, {44,55} }, function() return 1.6 end)
  local body = c:rrect(18, 18, 46, 57, 7):add(c:poly{ {19,22}, {28,13}, {36,13}, {45,22} })
  local ri = C.part(c, rope, R.jute, { R = 1 })
  W.retone(c, rope, ri, R.jute, function(x, y) if (x + y) % 3 == 0 then return -1 end end)
  W.sep(c, body, rope, R.jute[1])
  local idx = C.vc(c, body, R.linen, 18, 46, { tex = C.linen })
  body:each(function(x, y)
    if y >= 22 and floor((y - 22) / 5) % 2 == 0 then c:put(x, y, R.sea[max(1, idx[K(x, y)] - 1)]) end
  end)
  -- cinch folds converging to the neck
  for _, l in ipairs({ { {24,24}, {29,15} }, { {32,26}, {32,15} }, { {40,24}, {35,15} } }) do
    c:line(l, 1):each(function(x, y) if body:has(x, y) then c:put(x, y, R.linen[2]) end end)
  end
  -- base seam
  local base = c:rrect(18, 52, 46, 57, 4):clip(body)
  base:each(function(x, y) c:put(x, y, R.sea[max(1, idx[K(x, y)] - 2)]) end)
  W.hline(c, 21, 43, 52, R.sea[1])
  -- puffed top frill
  local frill = c:ellipse(32, 9, 7, 3.5)
  C.part(c, frill, R.linen, { R = 2, b = 1 })
  W.put(c, { {28,8}, {28,9}, {32,7}, {32,8}, {36,8}, {36,9} }, R.linen[3])
  -- drawstring rope wrap
  local wrap = c:rrect(27, 12, 37, 15, 1)
  C.part(c, wrap, R.jute, { R = 1 })
  for x = 27, 37 do if x % 2 == 0 then c:put(x, 13, R.jute[2]) end end
  -- grommets
  for _, p in ipairs({ {22,28}, {42,28} }) do c:fillMask(c:ellipse(p[1], p[2], 1, 1), R.brass[3]) c:put(p[1] - 1, p[2] - 1, R.brass[6]) end
  -- sheen
  W.vline(c, 21, 30, 46, R.linen[6]) c:put(21, 34, cream)
  -- quirk: coral starfish tied to the drawstring
  local cx, cy = 24, 20
  local star = HP.mask()
  for a = 0, 4 do
    local ang = -math.pi / 2 + a * 2 * math.pi / 5
    star:add(c:line({ {cx, cy}, {cx + 4.5 * math.cos(ang), cy + 4.5 * math.sin(ang)} }, 2))
  end
  star:add(c:ellipse(cx, cy, 1.5, 1.5))
  W.sep(c, star, body, R.sea[1])
  C.part(c, star, R.coral, { R = 1, b = 1 })
  c:put(cx, cy, R.coral[5]) c:put(cx - 1, cy - 2, R.coral[6]) c:put(cx + 2, cy + 1, R.coral[3])
  c:line({ {27,14}, {25,17} }, 1):each(function(x, y) c:put(x, y, R.jute[2]) end)
  C.save(c, "backpack-4-sailcloth-seabag")
end

-- 5 Lemon-Grove Satchel ------------------------------------------------------------
local function b5()
  local c = C.canvas("backpack-5-lemon-satchel")
  -- strap arc
  local strap = G.tube({ {16,30}, {14,6}, {50,6}, {48,30} }, function() return 2 end)
  local body = c:rrect(10, 26, 54, 55, 7)
  local si = C.part(c, strap, R.strap, { R = 1 })
  strap:each(function(x, y) if not strap:has(x, y - 1) or not strap:has(x - 1, y) then c:put(x, y, R.strap[5]) end end)
  -- lemon + leaf peeking from under the flap (behind body edge top-right)
  local lem = c:ellipse(45, 22, 6, 5):add(c:poly{ {50,19}, {54,18}, {52,22} })
  local lf = HP.mask()
  W.sep(c, body, strap, R.strap[1])
  C.part(c, lem, R.lemon, { R = 3 })
  W.put(c, { {43,20}, {44,19}, {42,21}, {47,20} }, R.lemon[6]) c:put(42, 19, cream)
  G.leaf(c, 40, 19, 32, 13, 2.4, R.leaf)
  W.sep(c, body, lem, R.lemon[2])
  local bi = C.part(c, body, R.leather, { R = 6, hs = 0.6, b = -1 })
  -- flap with rounded bottom
  local flap = c:rrect(10, 24, 54, 34, 4):add(c:ellipse(32, 36, 18, 8):clip(c:rect(10, 30, 54, 46)))
  for x = 14, 50 do local yb for y = 46, 24, -1 do if flap:has(x, y) then yb = y break end end if yb then c:put(x, yb + 1, R.leather[1]) c:put(x, yb + 2, R.leather[2]) end end
  C.part(c, flap, R.leather, { R = 4, b = 1 })
  -- tooled stitch along the flap edge
  local inner = flap:shrink(2):edge()
  local i = 0
  local pts = {}
  inner:each(function(x, y) if y > 27 then pts[#pts + 1] = { x, y } end end)
  for _, p in ipairs(pts) do if (p[1] + p[2]) % 3 ~= 0 then c:put(p[1], p[2], R.leather[3]) end end
  -- tooled almond-blossom: 5 dots + centre
  for _, p in ipairs({ {32,34}, {30,35}, {34,35}, {31,37}, {33,37} }) do c:put(p[1], p[2], R.leather[3]) end
  c:put(32, 36, R.leather[6])
  -- brass buckle and closing strap
  local tab = c:rect(30, 42, 34, 50)
  C.vc(c, tab, R.strap, 30, 34)
  local bk = c:rect(29, 43, 35, 47)
  C.part(c, bk, R.brass, { R = 1 })
  c:fillMask(c:rect(31, 44, 33, 46), R.strap[2])
  c:put(29, 43, R.brass[6])
  -- side gusset seam + sheen
  W.vline(c, 13, 38, 51, R.leather[3])
  W.put(c, { {15,27}, {16,27}, {17,27} }, R.leather[6]) c:put(15, 28, cream)
  -- strap rivets
  c:put(16, 31, R.brass[5]) c:put(48, 31, R.brass[3])
  C.save(c, "backpack-5-lemon-satchel")
end

local all = { b1, b2, b3, b4, b5 }
for i, f in ipairs(all) do if not only or tonumber(only) == i then f() end end
