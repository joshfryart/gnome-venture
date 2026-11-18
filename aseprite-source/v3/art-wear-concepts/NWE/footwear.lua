-- footwear.lua: Mistmoor (NWE) footwear concepts 1..5 (see concepts.md).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, G, R = C.HP, C.X, C.K, C.G, C.R
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local only = app.params.only
local function T(pts, ox, oy, s) local q = {} for i, p in ipairs(pts) do q[i] = { ox + p[1] * s, oy + p[2] * s } end return q end

---------------------------------------------------------------- 1 alder clogs
if not only or only == "1" then
  local c = C.new("footwear-1-alder-clogs")
  local s = 1.32
  local function clog(ox, oy, b)
    local body = c:poly(T({ {0,5}, {14,5}, {20,7}, {27,10}, {32,13}, {34,16}, {33.6,19}, {31,21.2}, {2,21.2}, {0,19} }, ox, oy, s))
    body:cut(c:ellipse(ox + 12.5 * s, oy + 21.6 * s, 3.2 * s, 1.3 * s))
    local open = c:ellipse(ox + 7.5 * s, oy + 5.2 * s, 6.2 * s, 1.9 * s)
    local all = body:copy():add(open)
    return {
      all = all,
      paint = function()
        local bias = C.bmap(body, b)
        local idx = C.lit(c, body, R.wood, { R = 5, hs = 0.7, bias = bias, cuts = { .22, .4, .56, .72, .88 } })
        -- grain: long streaks along the clog
        C.retone(c, body, idx, R.wood, function(x, y, i)
          if (y * 5 + floor((x - ox) / 7)) % 6 == 0 and X.hash(x, y, 3) < .75 then return -1 end
        end)
        -- sole line
        for x = floor(ox), floor(ox + 34 * s) do
          local y = floor(oy + 19.4 * s)
          if body:has(x, y) and body:has(x, y + 1) then c:put(x, y, R.wood[2]) end
        end
        -- opening: dark hollow with a lit back rim
        local inner = c:ellipse(ox + 7.8 * s, oy + 5.6 * s, 5 * s, 1.2 * s)
        C.colour(c, open:copy():cut(inner), R.wood[5 + min(0, b)])
        open:copy():cut(inner):each(function(x, y) if y > oy + 5.6 * s then c:put(x, y, R.wood[3 + b]) end end)
        C.colour(c, inner, R.wood[1])
        inner:each(function(x, y) if y > oy + 5.9 * s then c:put(x, y, R.wood[2]) end end)
        -- leather instep band with brass studs
        local band = c:poly(T({ {14,5.2}, {18.5,6.4}, {20.5,15}, {15.5,15} }, ox, oy, s))
        C.lit(c, band, R.strap, { R = 1, b = b })
        band:edge():each(function(x, y) if not band:has(x + 1, y) then c:put(x, y, R.strap[1]) end end)
        for _, p in ipairs({ { 16, 8.5 }, { 17.2, 12.5 } }) do
          local px, py = floor(ox + p[1] * s), floor(oy + p[2] * s)
          c:put(px, py, R.brass[5 + min(0, b)]) c:put(px + 1, py, R.brass[3])
        end
      end,
    }
  end
  local back = clog(16, 10, -1)
  local front = clog(5, 22, 0)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  -- glints on the front toe
  C.put(c, { { 45, 38 }, { 46, 38 }, { 47, 39 } }, R.wood[6])
  c:put(44, 38, C.cream)
  -- quirk: moss tuft on the back toe
  local moss = c:ellipse(57, 26.5, 3.4, 2.4):add(c:ellipse(54, 26, 2, 1.6))
  C.lit(c, moss, R.moss, { R = 2 })
  C.put(c, { { 55, 24 }, { 58, 24 }, { 57, 25 } }, R.moss[6])
  C.put(c, { { 54, 23 }, { 57, 23 }, { 59, 24 } }, R.moss[4])
  C.save(c, "footwear-1-alder-clogs")
end

---------------------------------------------------------------- 2 drain brogues
if not only or only == "2" then
  local c = C.new("footwear-2-drain-brogues")
  local upper = c:poly{ {6,25}, {20,23}, {24,29}, {33,33}, {46,35}, {54,38}, {58,42}, {58,46}, {6,46} }
  local sole = c:rrect(5, 45, 59, 49, 2)
  local heel = c:rrect(6, 44, 18, 51, 1)
  C.lit(c, heel, R.sole, { R = 1, b = -1 })
  C.lit(c, sole, R.sole, { R = 1 })
  C.hline(c, 7, 57, 46, R.sole[5])
  for x = 20, 56, 3 do c:put(x, 49, R.sole[2]) end
  C.sep(c, upper, sole:copy():add(heel), C.ink)
  local ui = C.lit(c, upper, R.leather, { R = 6, hs = 0.7, cuts = { .2, .38, .54, .7, .88 } })
  -- collar opening (dark) at the top
  local open = c:poly{ {8,25}, {19,23.5}, {21,26}, {9,27.5} }
  C.colour(c, open, R.leather[1])
  C.hline(c, 9, 20, 28, R.leather[2])
  -- wing toe cap seam with a row of drain holes
  local cap = { {44,35}, {42,38}, {42,42}, {44,45} }
  c:line(cap, 1):each(function(x, y) if upper:has(x, y) then c:put(x, y, R.leather[2]) end end)
  for _, p in ipairs({ {45,37}, {44,40}, {45,43} }) do c:put(p[1], p[2], R.leather[1]) end
  -- side panel seam + holes (the drain holes)
  c:line({ {14,30}, {16,36}, {20,40}, {30,42}, {40,42} }, 1):each(function(x, y) c:put(x, y, R.leather[2]) end)
  for x = 16, 40, 3 do
    local y = (x < 22) and 37 + floor((x - 16) / 3) or 39
    if upper:has(x, y) then c:put(x, y, R.leather[1]) c:put(x, y - 1, R.leather[5]) end
  end
  for _, p in ipairs({ {26,36}, {30,37}, {34,38}, {38,39}, {28,40}, {32,40}, {36,41} }) do c:put(p[1], p[2], R.leather[1]) end
  -- lacing slit + criss-cross cream laces
  c:line({ {21,25}, {24,29}, {32,33} }, 1):each(function(x, y) c:put(x, y, R.leather[1]) end)
  local laceC = { "#b4a084", "#e6d6b0", "#fbf1d8" }
  local function lace(pts) c:line(pts, 1):each(function(x, y) c:put(x, y, ((x + y) % 2 == 0) and laceC[2] or laceC[3]) end) end
  lace{ {20,27}, {26,31} } lace{ {20,30}, {25,27} } lace{ {24,32}, {30,34} } lace{ {24,35}, {29,31} }
  -- loose lace ends flopping over the collar, knotted tips
  lace{ {21,26}, {18,22}, {14,21}, {11,23} } lace{ {21,26}, {23,21}, {26,19}, {28,20} }
  C.put(c, { {10,23}, {10,24} }, R.leather[2]) C.put(c, { {29,20}, {29,21} }, R.leather[2])
  c:put(21, 26, laceC[1])
  -- shine on the toe
  C.put(c, { {48,37}, {49,37}, {50,38} }, R.leather[6]) c:put(47, 37, C.cream)
  -- quirk: heather sprig pushed through the laces
  c:line({ {27,30}, {31,24}, {34,19} }, 1):each(function(x, y) if not upper:has(x, y) or y < 31 then c:put(x, y, R.moss[3]) end end)
  local fl = { {31,23}, {33,22}, {32,21}, {34,20}, {35,19}, {33,18}, {35,17}, {34,16}, {36,18} }
  for i, p in ipairs(fl) do c:put(p[1], p[2], R.heather[(i % 3 == 0) and 6 or ((i % 2 == 0) and 4 or 5)]) end
  c:put(36, 16, R.heather[3]) c:put(32, 20, R.moss[4])
  C.save(c, "footwear-2-drain-brogues")
end

---------------------------------------------------------------- 3 felted fleece boots
if not only or only == "3" then
  local c = C.new("footwear-3-felted-fleece-boots")
  local function boot(dx, dy, b)
    local shaft = c:poly{ {13+dx,17+dy}, {28+dx,17+dy}, {29.5+dx,26+dy}, {28+dx,33+dy}, {29+dx,40+dy}, {12+dx,42+dy}, {11+dx,33+dy}, {12.5+dx,26+dy} }
    local foot = c:rrect(11+dx, 37+dy, 30+dx, 50+dy, 5):add(c:ellipse(33+dx, 45.5+dy, 6.5, 4.6))
    local body = shaft:copy():add(foot)
    local sole = c:rrect(11+dx, 49+dy, 39+dx, 51+dy, 1)
    local cuff = c:poly{ {9+dx,10+dy}, {31+dx,9+dy}, {32+dx,19+dy}, {28+dx,21+dy}, {24+dx,19.5+dy}, {19+dx,21.5+dy}, {14+dx,20+dy}, {8.5+dx,21+dy} }
    local B = { all = body:copy():add(sole):add(cuff) }
    B.paint = function()
      C.lit(c, sole, R.leather, { R = 1, b = b - 1 })
      local bi = C.vcyl(c, shaft, R.feltgrey, 11 + dx, 30 + dx, { bias = C.bmap(shaft, b) })
      local fi = C.lit(c, foot:copy():cut(shaft), R.feltgrey, { R = 6, hs = 0.6, b = b })
      C.speckle(c, shaft, bi, R.feltgrey, 0.12, 4)
      -- slouch folds
      for _, f in ipairs({ { 26, 13, 22 }, { 31, 14, 25 }, { 36, 13, 24 } }) do
        local y = f[1] + dy
        c:line({ {f[2]+dx, y}, {f[2]+dx+4, y+1}, {f[3]+dx+4, y} }, 1):each(function(x, yy) if shaft:has(x, yy) then c:put(x, yy, R.feltgrey[2]) end end)
        c:line({ {f[2]+dx, y-1}, {f[2]+dx+4, y} }, 1):each(function(x, yy) if shaft:has(x, yy) then c:put(x, yy, R.feltgrey[5 + min(0, b)]) end end)
      end
      C.hline(c, 12 + dx, 28 + dx, 22 + dy, R.feltgrey[1])
      -- folded cuff with a red diamond band
      local ci = C.lit(c, cuff, R.feltgrey, { R = 3, b = b + 1, cuts = { .2, .36, .52, .7, .9 } })
      for x = 10 + dx, 31 + dx do
        local u = (x - dx) % 4
        local y0 = 15 + dy
        if cuff:has(x, y0) then
          c:put(x, y0, R.yarnA[(u == 2) and 3 + b or 4 + b])
          if u == 2 then c:put(x, y0 - 1, R.yarnA[5 + b]) c:put(x, y0 + 1, R.yarnA[3 + b]) end
        end
        if cuff:has(x, 12 + dy) and (x % 2 == 0) then c:put(x, 12 + dy, R.feltgrey[3 + b]) end
      end
      return ci
    end
    return B
  end
  local back = boot(12, -5, -1)
  local front = boot(0, 0, 0)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  C.vline(c, 14, 24, 38, R.feltgrey[5]) c:put(14, 24, R.feltgrey[6])
  C.put(c, { {33,42}, {34,42} }, R.feltgrey[6])
  -- quirk: carved wooden sheep button on the front cuff
  local sh = c:ellipse(22, 17, 3.2, 2.2)
  C.colour(c, sh:copy():grow(1):cut(sh), C.ink)
  C.lit(c, sh, R.fleece, { R = 1, b = 1 })
  C.put(c, { {20,16}, {22,15} }, R.fleece[6])
  C.put(c, { {25,17}, {26,17}, {25,18}, {26,18} }, R.peat[3]) c:put(26, 17, R.peat[1])
  C.put(c, { {20,20}, {23,20} }, R.peat[2])
  C.save(c, "footwear-3-felted-fleece-boots")
end

---------------------------------------------------------------- 4 birch-bark slippers
if not only or only == "4" then
  local c = C.new("footwear-4-birch-bark-slippers")
  local ang = -0.55
  local ca, sa = math.cos(ang), math.sin(ang)
  local function slipper(cx, cy, b)
    local m, n = G.oval(cx, cy, 19, 9.5, ang, 1.4)
    -- heel opening toward -u
    local ox, oy = cx - ca * 9, cy - sa * 9
    local open = G.oval(ox, oy, 7.5, 5, ang, 1)
    return {
      all = m,
      paint = function()
        local bias = C.bmap(m, b)
        -- woven checker of bark strips along the diagonals
        m:each(function(x, y)
          local u = (x - cx) * ca + (y - cy) * sa
          local v = -(x - cx) * sa + (y - cy) * ca
          local a, d = floor((u + v + 42) / 6), floor((u - v + 42) / 6)
          if (a + d) % 2 == 0 then bias[K(x, y)] = bias[K(x, y)] - 2 end
        end)
        local idx = C.toneN(c, m, n, R.birch, { bias = bias, cuts = { .18, .32, .48, .64, .82 } })
        -- strip seams + lenticel dashes
        m:each(function(x, y)
          local u = (x - cx) * ca + (y - cy) * sa
          local v = -(x - cx) * sa + (y - cy) * ca
          local fu, fv = (u + v + 42) % 6, (u - v + 42) % 6
          if fu < 0.7 or fv < 0.7 then c:put(x, y, R.birch[max(1, idx[K(x, y)] - 2)]) end
          if X.hash(x, y, 9) < 0.025 then c:put(x, y, R.birch[2]) c:put(x + 1, y, R.birch[2]) end
        end)
        -- opening: leather-bound rim, dark inside
        local inner = open:copy():shrink(1)
        C.colour(c, open:copy():cut(inner), R.strap[4 + b])
        open:copy():cut(inner):each(function(x, y) if (x - ox) + (y - oy) > 2 then c:put(x, y, R.strap[2 + b]) end end)
        C.colour(c, inner, R.peat[3])
        inner:each(function(x, y) if (x - ox) * 0.6 + (y - oy) > 0.5 then c:put(x, y, R.peat[2]) end end)
        -- toe stitch knot
        local tx, ty = floor(cx + ca * 15 + 0.5), floor(cy + sa * 15 + 0.5)
        C.put(c, { {tx,ty}, {tx-1,ty} }, R.strap[3])
      end,
    }
  end
  local back = slipper(28, 25, -1)
  local front = slipper(34, 41, 0)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  -- quirk: ladybird on the front toe
  local lb = c:ellipse(47, 33, 2.4, 2)
  C.colour(c, lb:copy():grow(1):cut(lb), C.ink)
  C.lit(c, lb, R.berry, { R = 1 })
  C.put(c, { {47,32}, {47,33}, {47,34} }, C.ink)
  C.put(c, { {46,34}, {48,32} }, R.peat[1])
  C.put(c, { {49,30}, {50,30}, {50,31} }, C.ink)
  c:put(45, 32, R.berry[6])
  C.save(c, "footwear-4-birch-bark-slippers")
end

---------------------------------------------------------------- 5 herringbone gaiters
if not only or only == "5" then
  local c = C.new("footwear-5-herringbone-gaiters")
  local hb = function(x, y, i) local p = (x + abs((y % 8) - 4)) % 4 if p == 0 then return -1 elseif p == 2 then return 1 end end
  local function gaiter(dx, dy, b)
    local body = c:poly{ {0+dx,0+dy}, {15+dx,0+dy}, {16+dx,26+dy}, {24+dx,33+dy}, {26+dx,40+dy}, {-1+dx,40+dy}, {-1.5+dx,26+dy} }
    local band = c:rrect(-1+dx, -2+dy, 16+dx, 2+dy, 1)
    local strap = c:rrect(2+dx, 40+dy, 16+dx, 42+dy, 1)
    return {
      all = body:copy():add(band):add(strap),
      paint = function()
        C.lit(c, strap, R.strap, { R = 1, b = b - 1 })
        local idx = C.vcyl(c, body, R.tweed, dx - 1, dx + 18, { bias = C.bmap(body, b + 1), cuts = { .2, .34, .5, .68, .86 } })
        C.retone(c, body, idx, R.tweed, hb)
        -- spat lower edge roll + front seam
        body:each(function(x, y) if not body:has(x, y + 1) then c:put(x, y, R.tweed[2]) end end)
        c:line({ {16+dx,27+dy}, {23+dx,34+dy} }, 1):each(function(x, y) if body:has(x, y) then c:put(x, y, R.tweed[2]) end end)
        -- leather top binding
        C.lit(c, band, R.leather, { R = 1, b = b })
        C.hline(c, dx, 15 + dx, 3 + dy, R.tweed[1])
        -- buckle straps on the right side
        for _, yy in ipairs({ 8, 18, 28 }) do
          local y = yy + dy
          local st = c:rect(8 + dx, y, 16 + dx + ((yy == 28) and 3 or 0), y + 2)
          C.colour(c, st, R.strap[4 + b]) C.hline(c, 8 + dx, 16 + dx, y, R.strap[5 + b]) C.hline(c, 8 + dx, 16 + dx, y + 2, R.strap[2 + b])
          local bk = c:rect(10 + dx, y - 1, 13 + dx, y + 3)
          C.colour(c, bk, R.brass[4 + b])
          C.colour(c, c:rect(11 + dx, y, 12 + dx, y + 2), R.strap[3 + b])
          C.vline(c, 10 + dx, y - 1, y + 3, R.brass[5 + b]) C.hline(c, 10 + dx, 13 + dx, y + 3, R.brass[2])
          C.vline(c, 13 + dx, y, y + 3, R.brass[2])
          c:put(10 + dx, y - 1, R.brass[6])
        end
      end,
    }
  end
  local back = gaiter(30, 6, -1)
  local front = gaiter(13, 14, 0)
  back.paint()
  C.sep(c, front.all, back.all, C.ink)
  front.paint()
  C.vline(c, 14, 19, 46, R.tweed[6])
  -- quirk: snail climbing the front gaiter
  local shell = c:ellipse(16, 37, 3.4, 3.4)
  local bodyS = c:poly{ {12,40}, {20,40}, {21,42}, {11,42} }:add(c:rect(11, 37, 12, 41))
  C.colour(c, bodyS:copy():add(shell):grow(1):cut(bodyS):cut(shell), C.ink)
  C.lit(c, bodyS, R.feltgrey, { R = 1, b = 1 })
  C.lit(c, shell, R.wicker, { R = 2 })
  C.put(c, { {16,37}, {17,37}, {17,38}, {16,39}, {15,39}, {14,38}, {14,36}, {15,35}, {17,35}, {18,36} }, R.wicker[2])
  c:put(15, 35, R.wicker[6])
  C.put(c, { {10,35}, {10,36}, {12,35}, {12,36} }, R.feltgrey[3])
  C.put(c, { {10,34}, {12,34} }, C.ink)
  C.save(c, "footwear-5-herringbone-gaiters")
end
