-- footwear.lua: CB Sunsprinkle Isles footwear concepts (5 icons, 64x64). See concepts.md.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, W = C.HP, C.X, C.K, C.R, C
local only = app.params.only

local function want(n) return not only or only == n end

------------------------------------------------------------------ 1 palm-plait sandals (top view)
if want("1") then
  local c = C.new("footwear-1-palm-plait-sandals")
  local function sole(cx, cy)
    return c:ellipse(cx, cy + 12, 6, 7):add(c:ellipse(cx + 1, cy - 5, 8, 11))
      :add(c:poly{ {cx-6,cy+2}, {cx+8,cy+2}, {cx+6,cy+13}, {cx-6,cy+13} })
  end
  local function sandal(cx, cy, b, charm)
    local s = sole(cx, cy)
    local rim = s:shift(1, 2):cut(s)
    c:fillMask(rim, R.straw[b and 1 or 2])
    C.lay(c, s, R.straw, { R = 3, b = b or 0, tex = C.basket })
    -- footbed: inner worn patch, rim lit top-left
    s:edge():each(function(x, y) if x <= cx and y <= cy + 4 then c:put(x, y, R.straw[b and 5 or 6]) end end)
    -- heel and toe dents
    local dent = c:ellipse(cx, cy + 12, 3, 3):add(c:ellipse(cx + 1, cy - 8, 4, 5))
    dent:each(function(x, y) if (x + y) % 6 ~= 0 then c:put(x, y, R.straw[(b and 2 or 3)]) end end)
    -- red cord thong + instep band
    local post = { cx + 1, cy - 9 }
    C.tube(c, { {post[1],post[2]}, {cx-2,cy-7}, {cx-6,cy-2}, {cx-7,cy+2} }, 1.3, R.hibis, { b = b })
    C.tube(c, { {post[1],post[2]}, {cx+4,cy-7}, {cx+8,cy-2}, {cx+9,cy+2} }, 1.3, R.hibis, { b = b })
    local band = C.tube(c, { {cx-7,cy+3}, {cx-3,cy+1}, {cx+4,cy+1}, {cx+9,cy+3} }, 1.6, R.hibis, {
      b = b, tex = function(x, y) if x % 3 == 0 then return -1 end end })
    -- strap ends tucked under the sole edge
    c:put(cx - 7, cy + 3, R.hibis[1]) c:put(cx + 9, cy + 3, R.hibis[1])
    if charm then
      -- tiny conch shell on the toe post: spiral body + pointed tip
      local px, py = post[1], post[2] - 1
      local cm = c:ellipse(px, py, 2.5, 2):add(c:poly{ {px+1,py-2}, {px+6,py-1}, {px+1,py+2} })
      C.sep(c, cm, s:copy():add(band))
      W.lit(c, cm, R.shell, { R = 1 })
      W.put(c, { {px-1,py}, {px,py-1}, {px+1,py} }, R.shell[2])
      c:put(px, py, R.coral[4]) c:put(px + 3, py, R.shell[3]) c:put(px + 5, py - 1, R.shell[3])
      c:put(px - 1, py - 1, W.cream)
    end
    return s:copy():add(rim)
  end
  local back = sandal(41, 27, -1, false)
  local fs = sole(23, 31):add(sole(23, 31):shift(1, 2))
  C.sep(c, fs, back)
  sandal(23, 31, nil, true)
  C.save(c, "footwear-1-palm-plait-sandals")
end

------------------------------------------------------------------ 2 mahogany clogs (side)
if want("2") then
  local c = C.new("footwear-2-mahogany-clogs")
  local function clog(dx, dy, b)
    local body = c:poly{ {8+dx,36+dy}, {17+dx,36+dy}, {21+dx,39+dy}, {27+dx,36+dy}, {35+dx,31+dy}, {43+dx,32+dy},
      {48+dx,37+dy}, {49+dx,45+dy}, {46+dx,49+dy}, {10+dx,49+dy}, {7+dx,45+dy} }
    body:cut(c:rect(18+dx, 47+dy, 32+dx, 50+dy))
    local paint = function()
      local bm = C.bias(body, b or 0)
      local i = W.lit(c, body, R.mahog, { R = 4, bias = bm, cuts = { .22, .4, .56, .72, .88 } })
      W.retone(c, body, i, R.mahog, function(x, y, j)
        if (y - dy) % 3 == 0 and X.hash((x - dx) // 5, y, 9) < .6 then return -1 end
      end)
      -- foot opening (dark hollow)
      local hole = c:ellipse(17 + dx, 38 + dy, 7, 1.6):clip(body)
      c:fillMask(hole, R.mahog[1])
      W.hline(c, 11 + dx, 22 + dx, 37 + dy, R.mahog[1])
      -- carved groove above the blocks
      for x = 9 + dx, 47 + dx do if body:has(x, 45 + dy) then c:put(x, 45 + dy, R.mahog[2]) end end
      for x = 10 + dx, 46 + dx do if body:has(x, 46 + dy) then c:put(x, 46 + dy, R.mahog[b and 3 or 4]) end end
      -- polished toe glint
      if not b then c:put(40, 34, R.mahog[6]) c:put(41, 34, W.cream) c:put(39, 35, R.mahog[6]) end
      -- lagoon-blue leather strap over the instep
      C.tube(c, { {15+dx,38+dy}, {17+dx,30+dy}, {26+dx,29+dy}, {29+dx,36+dy} }, 1.6, R.turq, { b = b })
      W.put(c, { {16+dx,38+dy}, {29+dx,37+dy} }, R.brass[b and 3 or 4])
    end
    return body, paint
  end
  local bb, bp = clog(9, -9, -1)
  local fb, fp = clog(0, 0, nil)
  bp()
  C.sep(c, fb:copy():add(c:line({ {15,38}, {17,30}, {26,29}, {29,36} }, 4)), bb)
  fp()
  -- quirk: painted hibiscus on the toe
  W.put(c, { {44,42}, {45,42}, {45,43} }, R.palm[4]) c:put(46, 43, R.palm[3])
  C.flower2(c, 41, 40, R.hibis, "#ffd25a")
  C.save(c, "footwear-2-mahogany-clogs")
end

------------------------------------------------------------------ 3 sisal-sole slipper (single)
if want("3") then
  local c = C.new("footwear-3-sisal-sole-slippers")
  -- ankle ribbons first (behind)
  C.tube(c, { {13,31}, {6,22}, {12,13}, {19,17} }, 1.4, R.coral, { b = -1 })
  local up = c:poly{ {9,42}, {10,31}, {18,28}, {22,33}, {30,33}, {38,30}, {46,32}, {53,37}, {55,42} }
  local sole = c:rrect(7, 41, 56, 48, 3)
  C.lay(c, up, R.turq, { R = 4, cuts = { .22, .4, .56, .72, .88 }, tex = C.weave })
  -- opening
  local hole = c:ellipse(26, 33, 5, 1.5):clip(up)
  c:fillMask(hole, R.turq[1])
  -- cream piping along the top edge
  up:edge():each(function(x, y) if not up:has(x, y - 1) and not hole:has(x, y + 1) then c:put(x, y, R.cotton[x < 30 and 6 or 5]) end end)
  -- heel seam
  W.vline(c, 14, 31, 40, R.turq[2])
  -- sole: coiled braid
  C.sep(c, up, sole, R.sisal[1])
  local si = C.lay(c, sole, R.sisal, { R = 2 })
  W.retone(c, sole, si, R.sisal, function(x, y) local q = (x // 2 + y) % 3 if q == 0 then return -1 elseif q == 2 and y < 45 then return 1 end end)
  W.hline(c, 9, 54, 48, R.sisal[1])
  -- front ribbon over the top
  C.tube(c, { {19,31}, {22,20}, {30,9}, {36,15} }, 1.4, R.coral, { cuts = { .2, .36, .54, .7, .86 } })
  c:put(34, 11, R.coral[6])
  -- quirk: coral starfish stitched on the side
  local sf = { {39,34}, {39,35}, {36,36}, {37,36}, {38,36}, {39,36}, {40,36}, {41,36}, {42,36}, {38,37}, {39,37}, {40,37}, {37,38}, {41,38}, {36,39}, {42,39} }
  W.put(c, sf, R.coral[4])
  W.put(c, { {39,34}, {36,36}, {37,36}, {37,38}, {36,39} }, R.coral[6])
  c:put(39, 36, R.sunset[6])
  -- canvas glint
  c:put(47, 35, R.turq[6]) c:put(48, 35, R.turq[6])
  C.save(c, "footwear-3-sisal-sole-slippers")
end

------------------------------------------------------------------ 4 mangrove gaiters (tall pair)
if want("4") then
  local c = C.new("footwear-4-mangrove-gaiters")
  local function gaiter(dx, dy, b)
    local leg = c:poly{ {14+dx,13+dy}, {28+dx,13+dy}, {27+dx,39+dy}, {15+dx,39+dy} }
    local foot = c:rrect(13+dx, 37+dy, 30+dx, 48+dy, 3):add(c:ellipse(33+dx, 44+dy, 6, 4))
    local cuff = c:rrect(12+dx, 8+dy, 30+dx, 15+dy, 2)
    local all = leg:copy():add(foot):add(cuff)
    local paint = function()
      local fb = C.bias(foot, b or 0)
      C.lay(c, foot:copy():cut(leg), R.leather, { R = 4, biasmap = fb })
      W.hline(c, 14 + dx, 38 + dx, 48 + dy, R.leather[1])
      -- moccasin pucker stitches on the toe
      for x = 30 + dx, 36 + dx, 2 do c:put(x, 41 + dy, R.leather[2]) end
      W.hline(c, 15 + dx, 27 + dx, 40 + dy, R.leather[2])
      -- leg wrap: spiral bands
      local idx = W.vcyl(c, leg, R.turq, 14 + dx, 28 + dx, { bias = C.bias(leg, b or 0), cuts = { .2, .36, .52, .7, .9 } })
      W.retone(c, leg, idx, R.turq, function(x, y) local q = (x - dx + 2 * (y - dy)) % 9 if q == 0 then return -2 elseif q == 1 then return 1 end end)
      -- rope cross-lacing
      for _, y0 in ipairs({ 17, 24, 31 }) do
        local l1 = c:line({ {15+dx,y0+dy}, {27+dx,y0+6+dy} }, 1)
        local l2 = c:line({ {27+dx,y0+dy}, {15+dx,y0+6+dy} }, 1)
        l1:each(function(x, y) c:put(x, y, R.sisal[b and 4 or 5]) end)
        l2:each(function(x, y) c:put(x, y, R.sisal[b and 3 or 4]) end)
        c:put(21 + dx, y0 + 3 + dy, R.sisal[2])
      end
      -- folded knee cuff
      C.lay(c, cuff, R.cotton, { R = 2, b = b or 0 })
      W.hline(c, 13 + dx, 29 + dx, 12 + dy, R.cotton[2])
      W.hline(c, 13 + dx, 28 + dx, 13 + dy, R.cotton[b and 4 or 5])
      W.hline(c, 14 + dx, 27 + dx, 16 + dy, R.turq[1])
    end
    return all, paint
  end
  local ba, bp = gaiter(12, -5, -1)
  local fa, fp = gaiter(0, 0, nil)
  bp()
  C.sep(c, fa, ba)
  fp()
  c:put(16, 20, R.turq[6]) c:put(16, 21, R.turq[6])
  -- quirk: little red mangrove crab on the front shin
  local body = c:ellipse(21, 29, 2.6, 1.6)
  W.lit(c, body, R.hibis, { R = 1 })
  W.put(c, { {16,26}, {17,26}, {17,27}, {25,26}, {26,26}, {25,27} }, R.hibis[5])
  W.put(c, { {16,27}, {26,27} }, R.hibis[3])
  W.put(c, { {18,28}, {24,28} }, R.hibis[3])
  W.put(c, { {17,30}, {18,31}, {25,30}, {24,31}, {19,31}, {23,31} }, R.hibis[2])
  W.put(c, { {20,27}, {22,27} }, W.ink)
  c:put(20, 28, R.hibis[6])
  C.save(c, "footwear-4-mangrove-gaiters")
end

------------------------------------------------------------------ 5 curl-toe reef bootie (single)
if want("5") then
  local c = C.new("footwear-5-curl-toe-reef-booties")
  local shaft = c:rrect(13, 17, 31, 42, 4)
  local foot = c:ellipse(30, 40, 15, 7):add(c:rrect(13, 34, 30, 46, 4))
  local curl, cT = C.tube(c, { {40,40}, {49,41}, {54,35}, {50,30} }, function(t) return 4.2 - t * 3.2 end, R.seaglass)
  local body = shaft:copy():add(foot)
  local sole = c:rrect(14, 45, 46, 49, 2)
  C.lay(c, sole, R.strap, { R = 1 })
  W.hline(c, 15, 45, 49, R.strap[1])
  C.sep(c, body, curl)
  local scales = function(x, y, i)
    local dy = y % 4 local ox = (x + 2 * ((y // 4) % 2)) % 4
    if (ox == 0 and dy < 3) or (dy == 3 and ox ~= 0) then return -1 elseif ox == 2 and dy == 0 then return 1 end
  end
  C.lay(c, body, R.seaglass, { R = 6, cuts = { .22, .4, .56, .72, .88 }, tex = scales })
  C.sep(c, sole, body, R.strap[1])
  -- toe curl overlap again on top of the foot near its root
  C.tube(c, { {40,40}, {49,41}, {54,35}, {50,30} }, function(t) return t < .12 and -1 or 4.2 - t * 3.2 end, R.seaglass)
  c:put(52, 32, R.seaglass[6]) c:put(50, 30, R.seaglass[3])
  -- rolled cotton cuff
  local cuff = c:rrect(11, 12, 33, 19, 3)
  C.lay(c, cuff, R.cotton, { R = 2 })
  W.hline(c, 12, 32, 16, R.cotton[3])
  W.hline(c, 13, 31, 20, R.seaglass[1])
  -- ankle tie: cord band + dangle with sea-glass bead
  W.hline(c, 13, 31, 26, R.sisal[4]) W.hline(c, 13, 31, 27, R.sisal[2])
  for x = 14, 30, 3 do c:put(x, 26, R.sisal[6]) end
  local dang = c:line({ {32,27}, {34,29}, {35,32}, {35,34} }, 1)
  dang:each(function(x, y) c:put(x, y, R.sisal[3]) end)
  c:put(32, 26, R.sisal[5]) c:put(33, 26, R.sisal[4])
  local bead = c:ellipse(35.5, 36, 2, 2)
  C.sep(c, bead, body)
  W.lit(c, bead, R.turq, { R = 1 })
  c:put(35, 35, R.turq[6]) c:put(34, 35, W.cream)
  -- leather glint
  c:put(16, 22, R.seaglass[6]) c:put(16, 23, R.seaglass[6]) c:put(17, 22, W.cream)
  C.save(c, "footwear-5-curl-toe-reef-booties")
end
