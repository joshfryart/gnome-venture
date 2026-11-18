-- WCA coat concepts (5). Run: AppRun -b --script-param png=<dir>/ --script coat.lua [--script-param only=<name>]
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local ink, cream = C.ink, C.cream
local floor, abs, max, min = math.floor, math.abs, math.max, math.min
local function mirror(pts) local o = {} for i = #pts, 1, -1 do o[#o + 1] = { 63 - pts[i][1], pts[i][2] } end return o end
local function clampi(i) return max(1, min(6, i)) end

-- 1. Strip-Weave Smock: wide smock of narrow woven strips, batwing sleeves. quirk: patch pocket
local function smock(c)
  local Lp = { {22,10}, {8,20}, {4,36}, {15,38}, {19,27} }
  local slL, slR = c:poly(Lp), c:poly(mirror(Lp))
  local body = c:poly{ {21,9}, {42,9}, {51,55}, {12,55} }
  local neck = c:poly{ {26,9}, {37,9}, {31.5,19} }
  local strips = { R.kente, R.forest, R.kente, R.palm }
  local function stripe(m, idx, horiz)
    m:each(function(x, y)
      local u = horiz and y or x
      local s = strips[(u // 5) % 4 + 1]
      local i = idx[K(x, y)]
      if u % 5 == 0 then i = i - 1 end
      -- small woven blocks inside the gold strips
      if s == R.kente and (u % 5 == 2) and ((horiz and x or y) % 6 == 0) then s = R.palm end
      c:put(x, y, s[clampi(i)])
    end)
  end
  local il = C.lay(c, slL, R.kente, { R = 3, bias = -1 }) stripe(slL, il, true)
  local ir = C.lay(c, slR, R.kente, { R = 3, bias = -1 }) stripe(slR, ir, true)
  C.sep(c, body, slL:copy():add(slR), ink)
  local bi = C.lay(c, body, R.kente, { R = 5, cuts = { .22, .4, .56, .72, .88 } })
  stripe(body, bi, false)
  -- neck: inside of the back
  c:fillMask(neck, R.forest[1])
  neck:grow(1):cut(neck):clip(body):each(function(x, y) c:put(x, y, R.kente[y < 14 and 5 or 3]) end)
  -- hem and cuff shadow
  C.underline(c, body, R.palm[1])
  C.hline(c, 13, 50, 53, R.palm[2])
  -- quirk: stitched patch pocket on the right hip
  local pk = c:rrect(35, 38, 45, 48, 1)
  C.sep(c, pk, body, R.palm[1])
  C.lay(c, pk, R.forest, { R = 1, bias = 1 })
  for x = 36, 44, 2 do c:put(x, 39, R.cotton[6]) end
  for y = 41, 47, 2 do c:put(36, y, R.cotton[5]) c:put(44, y, R.cotton[4]) end
  C.hline(c, 36, 44, 40, R.forest[2])
end

-- 2. Mudcloth Vest: sleeveless, dark mud-dyed cloth, cream dots and dashes. quirk: kola-nut button
local function vest(c)
  local Lp = { {23,6}, {17,7}, {16,12}, {13,20}, {9,24}, {9,53}, {32,53}, {32,33}, {26,18} }
  local pl, pr = c:poly(Lp), c:poly(mirror(Lp))
  local backin = c:poly{ {22,6}, {41,6}, {32,32} }
  c:fillMask(backin, R.mud[1])
  C.hline(c, 24, 39, 7, R.mud[2])
  local function panel(m, b, side)
    local i = C.lay(c, m, R.mud, { R = 4, bias = b, cuts = { .2, .36, .52, .68, .84 } })
    C.speckle(c, m, i, R.mud, 0.05, side)
    -- plain mud-cloth pattern: dash rows, dot rows, a zig-zag row
    m:shrink(2):each(function(x, y)
      local lit = (i[K(x, y)] or 3) >= 3
      local col = lit and R.cotton[5] or R.cotton[3]
      if y % 9 == 2 and x % 4 < 2 then c:put(x, y, col)
      elseif y % 9 == 5 and x % 3 == 1 then c:put(x, y, col)
      elseif y % 9 == 7 and (x + y) % 4 == 0 then c:put(x, y, R.ember[lit and 4 or 3]) end
    end)
    -- ember edge binding along the front opening and hem
    m:edge():each(function(x, y) if y > 46 or (side == 1 and x >= 24 and y < 50) or (side == 2 and x <= 39 and y < 50) then c:put(x, y, R.ember[lit and 3 or 3]) end end)
  end
  panel(pl, 0, 1)
  C.sep(c, pr, pl, ink)
  panel(pr, -1, 2)
  -- armhole binding
  for _, p in ipairs({ {16,10}, {15,13}, {14,16}, {13,19}, {11,22} }) do c:put(p[1], p[2], R.ember[4]) end
  for _, p in ipairs({ {47,10}, {48,13}, {49,16}, {50,19}, {52,22} }) do c:put(p[1], p[2], R.ember[2]) end
  -- quirk: red kola-nut button with a cord loop
  c:line({ {33,31}, {36,30}, {36,34}, {33,34} }, 1):each(function(x, y) c:put(x, y, R.cotton[4]) end)
  local bt = c:ellipse(31, 32, 2.6, 2.2)
  C.sep(c, bt, pl:copy():add(pr), ink)
  C.lay(c, bt, R.ember, { R = 2 })
  c:put(30, 31, R.ember[6]) c:put(31, 34, R.ember[1]) c:put(32, 32, R.ember[2])
  c:put(12, 27, R.mud[6]) c:put(12, 28, R.mud[6])
end

-- 3. Raffia Rain Coat: three tiers of raffia fringe, palm-dyed collar. quirk: raindrop
local function raincoat(c)
  local function tier(pts, bot, b)
    local m = c:poly(pts)
    m:each(function(x, y) if y > bot - ((x * 5 + 3) % 4) then m.s[K(x, y)] = nil end end)
    return m
  end
  local t3 = tier({ {14,40}, {50,40}, {56,58}, {8,58} }, 58, -1)
  local t2 = tier({ {17,24}, {47,24}, {51,45}, {13,45} }, 45, 0)
  local t1 = tier({ {21,9}, {43,9}, {53,20}, {57,31}, {7,31}, {11,20} }, 31, 1)
  local function fringe(m, b)
    local i = C.lay(c, m, R.raffia, { R = 4, bias = b })
    C.retone(c, m, i, R.raffia, function(x, y, j)
      if x % 2 == 0 then return -1 end
      if X.hash(x, 1, 9) < .3 then return 1 end
    end)
    return i
  end
  fringe(t3, -1)
  C.sep(c, t2, t3, ink)
  t2:shift(0, 1):cut(t2):clip(t3):each(function(x, y) c:put(x, y + 1, R.raffia[1]) end)
  fringe(t2, 0)
  C.sep(c, t1, t2, ink)
  t1:shift(0, 1):cut(t1):clip(t2):each(function(x, y) c:put(x, y + 1, R.raffia[1]) end)
  fringe(t1, 1)
  -- palm-dyed band across each tier just under the tier above
  for _, b in ipairs({ { t2, 34, 35 }, { t3, 49, 50 }, { t1, 22, 23 } }) do
    b[1]:each(function(x, y) if y >= b[2] and y <= b[3] then c:put(x, y, R.palm[(x < 30) and 4 or 3]) end end)
    b[1]:each(function(x, y) if y == b[2] + 1 and x % 4 == 0 then c:put(x, y, R.kente[5]) end end)
  end
  -- collar ring and neck hole
  local col = c:ellipse(32, 10, 10, 3.5)
  C.lay(c, col, R.palm, { R = 2 })
  local nh = c:ellipse(32, 9, 5, 1.5)
  c:fillMask(nh, R.raffia[1])
  C.hline(c, 28, 36, 11, R.palm[6])
  -- quirk: a raindrop sliding off the bottom fringe
  local dr = c:poly{ {47,58}, {49.5,61.5}, {49,63}, {45,63}, {44.5,61.5} }
  local dt = c:poly{ {44,52}, {46,55}, {45,57}, {44,55} }
  C.lay(c, dt, R.water, { R = 1 })
  C.lay(c, dr, R.water, { R = 2 })
  c:put(46, 61, cream)
end

-- 4. Adire Jacket: fitted indigo jacket, resist rings, cream piping. quirk: hibiscus
local function adire(c)
  local Ls = { {23,9}, {17,13}, {11,28}, {8,50}, {15,52}, {18,34}, {20,22} }
  local sl, sr = c:poly(Ls), c:poly(mirror(Ls))
  local body = c:poly{ {22,7}, {41,7}, {46,13}, {46,54}, {17,54}, {17,13} }
  local il = C.lay(c, sl, R.indigo, { R = 3, bias = 0 })
  local ir = C.lay(c, sr, R.indigo, { R = 3, bias = -1 })
  -- cuffs
  C.paintIf(c, sl, R.cotton[4], function(x, y) return y >= 48 end)
  C.paintIf(c, sr, R.cotton[3], function(x, y) return y >= 48 end)
  C.sep(c, body, sl:copy():add(sr), ink)
  local bi = C.lay(c, body, R.indigo, { R = 5, cuts = { .22, .4, .56, .72, .88 } })
  -- resist rings
  local function rings(m, idx, ox)
    for gy = 14, 50, 7 do for gx = 6, 58, 7 do
      local x0, y0 = gx + ((gy // 7) % 2) * 3 + ox, gy
      local ring = { {0,-1}, {1,-1}, {-1,0}, {2,0}, {-1,1}, {2,1}, {0,2}, {1,2} }
      local ok = true
      for _, d in ipairs(ring) do if not m:shrink(1):has(x0 + d[1], y0 + d[2]) then ok = false end end
      if ok then for _, d in ipairs(ring) do
        local i = idx[K(x0 + d[1], y0 + d[2])] or 3
        c:put(x0 + d[1], y0 + d[2], i >= 4 and R.indigo[6] or R.indigo[4])
      end end
    end end
  end
  rings(body, bi, 0) rings(sl, il, 1) rings(sr, ir, 1)
  -- wrap-over front: diagonal edge from right neck to left hip with cream piping
  local edge = c:line({ {38,8}, {33,20}, {27,34}, {22,44} }, 1)
  edge:shift(1, 0):clip(body):each(function(x, y) c:put(x, y, R.indigo[1]) end)
  edge:clip(body):each(function(x, y) c:put(x, y, R.cotton[5]) end)
  -- under-flap fold shadow
  for y = 44, 53 do c:put(22, y, R.indigo[2]) end
  -- collar band + hem piping
  local collar = c:poly{ {22,6}, {41,6}, {38,10}, {32,12}, {25,10} }
  C.lay(c, collar, R.cotton, { R = 1 })
  local nk = c:poly{ {26,6}, {37,6}, {32,9} }
  c:fillMask(nk, R.indigo[1])
  C.hline(c, 18, 45, 53, R.cotton[4]) C.hline(c, 18, 45, 54, R.cotton[2])
  -- quirk: red hibiscus in the buttonhole
  local hb = c:ellipse(36, 17, 3.6, 3.6)
  C.sep(c, hb, body, ink)
  local hi = C.lay(c, hb, R.ember, { R = 2, bias = 1 })
  C.put(c, { {36,14}, {33,17}, {39,17}, {34,20}, {38,20} }, R.ember[1])
  c:put(36, 17, R.kente[5]) c:put(37, 16, R.kente[6]) c:put(37, 18, R.kente[3])
  c:put(34, 15, R.ember[6])
  C.put(c, { {40,20}, {41,21}, {42,21} }, R.plantain[4])
end

-- 5. Kapok Jerkin: puffy quilted cotton, ochre binding, cap sleeves. quirk: kapok fluff
local function jerkin(c)
  local capL, capR = c:ellipse(15, 19, 7, 7), c:ellipse(48, 19, 7, 7)
  local body = c:rrect(14, 10, 49, 53, 7)
  local ql = function(m, idx)
    C.retone(c, m, idx, R.cotton, function(x, y, i)
      local u, v = (x + y) % 8, (x - y) % 8
      if u == 0 or v == 0 then return -2 end
      if (u == 2 or u == 3) and (v == 2 or v == 3) then return 1 end
      if u >= 6 or v >= 6 then return -1 end
    end)
  end
  ql(capL, C.lay(c, capL, R.cotton, { R = 4, bias = -1 }))
  ql(capR, C.lay(c, capR, R.cotton, { R = 4, bias = -2 }))
  C.sep(c, body, capL:copy():add(capR), ink)
  local bi = C.lay(c, body, R.cotton, { R = 7, cuts = { .2, .38, .54, .7, .86 } })
  ql(body, bi)
  -- ochre binding: front opening, hem, stand collar
  local front = c:rect(31, 12, 32, 53)
  C.vcyl(c, front, R.ochre, 31, 32)
  C.vline(c, 33, 12, 52, R.cotton[1])
  local hem = c:rrect(14, 50, 49, 53, 2):clip(body)
  C.lay(c, hem, R.ochre, { R = 1 })
  C.hline(c, 16, 47, 50, R.ochre[5])
  local collar = c:rrect(20, 6, 43, 12, 3)
  C.sep(c, collar, body, ink)
  C.lay(c, collar, R.ochre, { R = 2 })
  local nk = c:ellipse(31.5, 8, 7, 1.5)
  c:fillMask(nk, R.ochre[1])
  -- strap toggles
  for _, ty in ipairs({ 20, 30, 40 }) do
    C.hline(c, 28, 35, ty, R.strap[3]) C.hline(c, 28, 35, ty + 1, R.strap[1])
    c:put(29, ty, R.strap[5])
  end
  -- quirk: a tuft of kapok fluff escaping the left side seam
  local fl = c:ellipse(13, 37, 2.6, 2.2):add(c:ellipse(10, 35, 1.6, 1.4))
  C.sep(c, fl, body, ink)
  C.lay(c, fl, R.cotton, { R = 1, bias = 2 })
  c:put(12, 36, cream) c:put(14, 38, R.cotton[3]) c:put(10, 36, R.cotton[4])
  C.put(c, { {8,33}, {7,32} }, R.cotton[5])
  c:put(15, 37, R.cotton[1]) c:put(15, 38, R.cotton[1])
end

C.run{
  { "coat-1-strip-weave-smock", smock },
  { "coat-2-mudcloth-vest", vest },
  { "coat-3-raffia-rain-coat", raincoat },
  { "coat-4-adire-jacket", adire },
  { "coat-5-kapok-jerkin", jerkin },
}
