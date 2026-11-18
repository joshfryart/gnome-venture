-- backpack.lua: SA "Rainroot Reaches" backpack concepts, 5 icons (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local abs, floor, sqrt, max, min = math.abs, math.floor, math.sqrt, math.max, math.min

---------------------------------------------------------------- 1 striped bundle cloth
do
  local c = C.new("backpack-1-striped-bundle-cloth")
  local body = c:ellipse(32, 39, 21, 16)
  local knot = c:ellipse(32, 22, 5, 4)
  local earL = c:poly{ {29,18}, {17,7}, {12,10}, {13,15}, {27,26} }
  local earR = c:poly{ {35,18}, {46,6}, {51,8}, {51,13}, {37,26} }
  local seq = { R.yarnA, R.yarnA, R.straw, R.indigo, R.straw, R.yarnA, R.yarnA, R.alpaca, R.indigo, R.alpaca }
  local bandB = function(x, y) return seq[floor((y + (x - 32) ^ 2 * 0.012) / 2) % #seq + 1] end
  -- ears first (behind the knot)
  for _, e in ipairs({ earL, earR }) do
    local ei = C.lit(c, e, R.yarnA, { R = 2, bias = -1 })
    C.swap(c, e, ei, R.straw, function(x, y) return (x - y) % 7 == 0 end)
    C.swap(c, e, ei, R.indigo, function(x, y) return (x - y) % 7 == 1 end)
  end
  C.sep(c, body, earL:copy():add(earR), R.yarnA[1])
  local bi = C.litm(c, body, bandB, { R = 7, hs = 0.8, cuts = { .2, .36, .52, .7, .88 } })
  -- gathered folds radiating down from the knot
  local folds = { -0.9, -0.45, 0.05, 0.5, 0.95 }
  body:each(function(x, y)
    local dx, dy = x - 32, y - 22
    if dy > 4 then
      local a = dx / dy
      for _, f in ipairs(folds) do
        local d = abs(a - f) * dy
        if d < 0.7 and dy < 26 then
          local i = bi[K(x, y)]
          c:put(x, y, bandB(x, y)[max(1, i - 2)])
          if c:get(x - 1, y) and body:has(x - 1, y) then c:put(x - 1, y, bandB(x - 1, y)[min(6, (bi[K(x - 1, y)] or 3) + 1)]) end
        end
      end
    end
  end)
  -- knot on top
  C.sep(c, knot, body:copy():add(earL):add(earR), R.yarnA[1])
  local ki = C.lit(c, knot, R.yarnA, { R = 2 })
  C.put(c, { {31,20}, {32,21}, {33,22}, {34,23} }, R.yarnA[2])
  c:put(30, 20, R.yarnA[6])
  -- quirk: a quinoa seed head poking out of the knot
  local stem = c:line({ {32,19}, {32,12}, {33,8} }, 1)
  stem:each(function(x, y) if not knot:has(x, y) then c:put(x, y, "#5a7a2e") end end)
  local head = c:ellipse(33, 6, 2.2, 3.5):add(c:ellipse(31, 9, 1.4, 1.4)):add(c:ellipse(35, 10, 1.4, 1.4))
  head:each(function(x, y) c:put(x, y, ({ "#c84a3a", "#e2a63e", "#d86a3a", "#a83a32" })[floor(X.hash(x, y, 3) * 4) + 1]) end)
  c:put(32, 4, "#f4c070") c:put(32, 5, "#f4c070") c:put(31, 8, "#f4c070")
  c:put(19, 30, C.cream) c:put(20, 29, R.alpaca[6])
  C.save(c, "backpack-1-striped-bundle-cloth")
end

---------------------------------------------------------------- 2 cone vine basket
do
  local c = C.new("backpack-2-cone-vine-basket")
  local body = c:poly{ {13,16}, {51,16}, {41,52}, {37,56}, {27,56}, {23,52} }
  local rim = c:ellipse(32, 16, 19, 4.5)
  local mouth = c:ellipse(32, 15, 16, 2.6)
  -- tumpline strap arching behind
  local strap = c:line({ {15,17}, {14,10}, {19,4}, {32,2}, {45,4}, {50,10}, {49,17} }, 3)
  strap:cut(body):cut(rim)
  C.lit(c, strap, R.strap, { R = 1 })
  strap:each(function(x, y) if not strap:has(x, y - 1) then c:put(x, y, R.strap[5]) end end)
  C.sep(c, body:copy():add(rim), strap, R.strap[1])
  -- body: diagonal plait
  local n = {}
  body:each(function(x, y)
    local hw = 19 - (y - 16) * 0.33
    local t = max(-.95, min(.95, (x - 32) / max(4, hw)))
    n[K(x, y)] = { t * 0.95, -0.1, sqrt(1 - t * t) }
  end)
  local bi = C.toneN(c, body, n, R.straw, { cuts = { .2, .36, .52, .7, .88 } })
  C.retone(c, body, bi, R.straw, function(x, y)
    local a, b = (x + y) % 4, (x - y) % 4
    if (floor((y - 16) / 4)) % 2 == 0 then
      if a == 0 then return -1 elseif a == 2 then return 1 end
    else
      if b == 0 then return -1 elseif b == 2 then return 1 end
    end
  end)
  -- wrapped rings
  for _, ry in ipairs({ 30, 44 }) do
    body:each(function(x, y) if y == ry then c:put(x, y, R.strap[(bi[K(x, y)] or 3) > 3 and 4 or 2]) elseif y == ry + 1 then c:put(x, y, R.straw[1]) end end)
  end
  -- rim: rolled vine
  C.sep(c, rim, body, R.straw[1])
  C.lit(c, rim, R.straw, { R = 2, bias = 1 })
  rim:each(function(x, y) if (x + floor(y / 2)) % 3 == 0 then c:put(x, y, R.straw[3]) end end)
  -- dark mouth
  c:fillMask(mouth, R.cacao[2])
  mouth:each(function(x, y) if not mouth:has(x, y - 1) then c:put(x, y, R.cacao[1]) end end)
  -- quirk: a ripe cacao pod peeking over the rim
  local pm, pn = G.oval(39, 9, 4.5, 8, -0.5)
  local pod = pm:copy():cut(c:rect(0, 15, 63, 63):cut(mouth))
  pm = pod
  local pi = C.toneN(c, pm, pn, R.autumn, { cuts = { .2, .36, .52, .7, .88 } })
  pm:each(function(x, y) if (x - floor((y) * 0.5)) % 3 == 0 then c:put(x, y, R.autumn[max(1, (pi[K(x, y)] or 3) - 2)]) end end)
  c:put(37, 4, R.autumn[6]) c:put(36, 5, R.autumn[6])
  local lf = G.blade(29, 13, 24, 8, 21, 3, function(t) return 2.6 * math.sin(math.pi * min(1, t * 1.05)) end)
  lf:cut(mouth:copy():cut(c:rect(0, 0, 63, 14)))
  C.sep(c, lf, pm, R.leafG[1])
  C.lit(c, lf, R.leafG, { R = 1 })
  C.put(c, { {27,11}, {26,10}, {25,9}, {24,8} }, R.leafG[6])
  c:put(17, 22, C.cream) c:put(18, 22, R.straw[6])
  C.save(c, "backpack-2-cone-vine-basket")
end

---------------------------------------------------------------- 3 highland carry frame
do
  local c = C.new("backpack-3-highland-carry-frame")
  local poleL = c:rrect(15, 4, 19, 58, 1)
  local poleR = c:rrect(44, 4, 48, 58, 1)
  local rungs = c:rect(18, 11, 45, 13):add(c:rect(18, 32, 45, 34)):add(c:rect(18, 51, 45, 53))
  local grain = function(x, y, i) if y % 5 == 0 and X.hash(x, y, 4) < .6 then return -1 end end
  local ri = C.lit(c, rungs, R.wood, { R = 1, bias = -1 })
  C.hline(c, 18, 45, 11, R.wood[5]) C.hline(c, 18, 45, 32, R.wood[5]) C.hline(c, 18, 45, 51, R.wood[5])
  for _, p in ipairs({ poleL, poleR }) do
    C.sep(c, p, rungs, R.wood[1])
    local x0, x1 = (p == poleL) and 15 or 44, (p == poleL) and 19 or 48
    local pi = C.vcyl(c, p, R.wood, x0, x1)
    C.retone(c, p, pi, R.wood, grain)
  end
  -- gourd lashed in the middle
  local low = c:ellipse(31.5, 40, 10.5, 10)
  local up = c:ellipse(31.5, 24, 6, 6.5)
  local neck = c:rect(29, 16, 34, 30)
  local gourd = low:copy():add(up):add(neck)
  C.sep(c, gourd, rungs:copy():add(poleL):add(poleR), R.wood[1])
  local gn = {}
  low:each(function(x, y) gn[K(x, y)] = true end)
  local gi = C.lit(c, gourd, R.gourd, { R = 6, hs = 0.9, cuts = { .2, .36, .52, .7, .88 } })
  -- waist crease between lobes
  C.hline(c, 26, 37, 30, R.gourd[2]) C.hline(c, 27, 36, 31, R.gourd[3])
  -- burnt-line band on the lower lobe
  for x = 22, 41 do if low:has(x, 42) then c:put(x, 42, R.gourd[1]) end if low:has(x, 44) and x % 2 == 0 then c:put(x, 44, R.gourd[2]) end end
  -- cork stopper
  local cork = c:rrect(29, 13, 34, 17, 1)
  C.lit(c, cork, R.balsa, { R = 1 })
  c:put(30, 14, R.balsa[6])
  -- cord lashing round the gourd and frame
  local cord = c:line({ {16,22}, {26,26}, {37,26}, {47,22} }, 1):add(c:line({ {16,46}, {22,44}, {41,44}, {47,46} }, 1))
  cord:each(function(x, y) c:put(x, y, R.canvas[(x + y) % 2 == 0 and 5 or 3]) end)
  -- wraps at joints
  for _, j in ipairs({ {17,12}, {46,12}, {17,33}, {46,33}, {17,52}, {46,52} }) do
    for dy = -2, 2 do
      c:put(j[1] - 2, j[2] + dy, R.canvas[2]) c:put(j[1] - 1, j[2] + dy, R.canvas[dy % 2 == 0 and 5 or 4])
      c:put(j[1], j[2] + dy, R.canvas[dy % 2 == 0 and 4 or 3]) c:put(j[1] + 1, j[2] + dy, R.canvas[3]) c:put(j[1] + 2, j[2] + dy, R.canvas[2])
    end
  end
  -- gloss on gourd
  c:put(25, 35, C.cream) c:put(26, 34, R.gourd[6]) c:put(27, 20, R.gourd[6])
  -- quirk: small yellow flower wedged in the top-left lashing
  local fl = c:ellipse(13, 9, 2.4, 2.4)
  C.lit(c, fl, R.brass, { R = 1 })
  c:put(13, 9, R.autumn[3]) c:put(12, 8, R.brass[6])
  c:put(15, 7, "#3f9150") c:put(14, 6, "#5cac48")
  C.save(c, "backpack-3-highland-carry-frame")
end

---------------------------------------------------------------- 4 leaf-flap satchel
do
  local c = C.new("backpack-4-leaf-flap-satchel")
  local body = c:rrect(11, 20, 53, 55, 10)
  local strap = c:line({ {16,23}, {16,14}, {22,7}, {32,5}, {42,7}, {48,14}, {48,23} }, 3)
  strap:cut(body)
  C.lit(c, strap, R.strap, { R = 1 })
  strap:each(function(x, y) if not strap:has(x - 1, y) or not strap:has(x, y - 1) then c:put(x, y, R.strap[5]) end end)
  C.sep(c, body, strap, R.strap[1])
  local bi = C.lit(c, body, R.palm, { R = 6, hs = 0.8, cuts = { .2, .36, .52, .7, .88 } })
  -- basket weave checks
  C.retone(c, body, bi, R.palm, function(x, y)
    local cx, cy = floor(x / 3), floor(y / 3)
    local horiz = (cx + cy) % 2 == 0
    if horiz and y % 3 == 2 then return -1 end
    if not horiz and x % 3 == 2 then return -1 end
  end)
  -- leaf flap: wide leaf, tip pointing down
  local flap, fn, FT, FS = G.blade(32, 19, 31, 34, 33, 49, function(t) return max(0, 15 * math.sin(math.pi * min(1, t * 0.95 + 0.08)) ^ 0.7) end, { fold = 0.35 })
  flap:clip(c:rect(0, 19, 63, 63))
  C.sep(c, flap, body, R.palm[1])
  -- shadow under the flap
  flap:shift(1, 2):cut(flap):clip(body):each(function(x, y) c:put(x, y, R.palm[1]) end)
  C.toneN(c, flap, fn, R.leafG, { cuts = { .2, .36, .52, .7, .88 } })
  flap:each(function(x, y)
    local s, t = FS[K(x, y)], FT[K(x, y)]
    if s and abs(s) < 0.07 and t < 0.95 then c:put(x, y, R.leafG[6]) end
    local d = (t or 0) * 30 - abs(s or 0) * 9
    if s and abs(s) > 0.15 and abs(s) < 0.75 and floor(d) % 6 == 0 then c:put(x, y, s < 0 and R.leafG[5] or R.leafG[2]) end
  end)
  -- stem toggle at the top
  local st = c:rect(31, 17, 33, 21)
  C.lit(c, st, R.leafG, { R = 1 }) c:put(31, 17, R.leafG[6])
  -- quirk: leaf-cutter ant carrying a petal scrap across the flap
  local AD, AL = "#5e1c22", "#9a3a2e"
  local ant = c:ellipse(40, 49, 1.6, 1.3):add(c:rect(42, 48, 43, 49)):add(c:ellipse(45.5, 48.5, 1.5, 1.5))
  local legs = c:line({ {41,51}, {40,53} }, 1):add(c:line({ {42,50}, {42,53} }, 1)):add(c:line({ {43,50}, {44,53} }, 1))
    :add(c:line({ {46,47}, {48,44} }, 1)):add(c:line({ {47,48}, {49,46} }, 1))
  C.sep(c, ant:copy():add(legs), body, R.palm[2])
  c:fillMask(legs, AD) c:fillMask(ant, AD)
  c:put(39, 48, AL) c:put(45, 47, AL) c:put(46, 47, AD)
  local sc = c:poly{ {45,38}, {52,40}, {50,45}, {44,43} }
  C.sep(c, sc, body:copy():add(flap), R.palm[1])
  C.lit(c, sc, R.pink, { R = 1 })
  c:put(48, 45, AD) c:put(48, 46, AD) c:put(46, 40, R.pink[6]) c:put(47, 40, R.pink[6])
  c:put(15, 28, C.cream) c:put(16, 27, R.palm[6])
  C.save(c, "backpack-4-leaf-flap-satchel")
end

---------------------------------------------------------------- 5 market net bag
do
  local c = C.new("backpack-5-market-net-bag")
  local fruits = {
    { 22, 40, 8.5, R.autumn },   -- orange
    { 41, 41, 8.5, R.passion },  -- passionfruit
    { 31, 48, 8, R.brass },      -- yellow fruit
    { 31, 31, 7.5, R.passion },  -- split passionfruit on top (quirk)
  }
  local bag = c:poly{ {26,22}, {38,22}, {48,34}, {50,44}, {42,55}, {22,55}, {13,45}, {15,33} }
  local all = bag:copy()
  for _, f in ipairs(fruits) do all:add(c:ellipse(f[1], f[2], f[3], f[3])) end
  -- cord loop
  local loop = c:line({ {29,21}, {24,13}, {26,5}, {32,3}, {38,5}, {40,13}, {35,21} }, 2)
  loop:cut(all)
  loop:each(function(x, y) c:put(x, y, R.string[(x < 32) and 5 or 3]) end)
  -- bag interior shadow
  C.lit(c, all, R.cacao, { R = 2, bias = -1 })
  local fm = HP.mask()
  for i, f in ipairs(fruits) do
    local m = c:ellipse(f[1], f[2], f[3], f[3])
    m:cut(fm)
    local n = X.sphere(f[1] - .5, f[2] - .5, f[3], m)
    C.toneN(c, m, n, f[4], { cuts = { .2, .36, .52, .7, .88 } })
    fm:add(c:ellipse(f[1], f[2], f[3], f[3]))
    c:put(floor(f[1] - f[3] * 0.45), floor(f[2] - f[3] * 0.5), f[4] == R.passion and R.passion[6] or C.cream)
  end
  -- split passionfruit: yellow pulp with dark seeds
  local pulp = c:ellipse(31, 30, 5, 4.5)
  C.lit(c, pulp, R.brass, { R = 1 })
  C.put(c, { {29,29}, {32,28}, {30,32}, {33,31}, {28,31}, {34,29}, {31,30} }, R.cacao[1])
  C.put(c, { {29,28}, {32,27}, {30,31}, {33,30} }, R.brass[6])
  pulp:edge():each(function(x, y) if y >= 30 then c:put(x, y, "#f4e8c8") end end)
  -- knotted net lattice over everything inside the bag outline
  all:each(function(x, y)
    if y > 22 and ((x + y) % 8 == 0 or (x - y) % 8 == 0) and not pulp:has(x, y) then
      local lit = (x + y < 72)
      c:put(x, y, R.string[lit and 5 or 3])
      if (x + y) % 8 == 0 and (x - y) % 8 == 0 then c:put(x, y, R.string[6]) end
    end
  end)
  -- gathered neck
  local neck = c:rrect(27, 20, 37, 24, 1)
  C.lit(c, neck, R.string, { R = 1 })
  C.vline(c, 30, 20, 24, R.string[2]) C.vline(c, 34, 20, 24, R.string[2])
  C.save(c, "backpack-5-market-net-bag")
end
