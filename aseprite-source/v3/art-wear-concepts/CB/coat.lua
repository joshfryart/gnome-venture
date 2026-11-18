-- coat.lua: CB Sunsprinkle Isles coat concepts (5 icons, 64x64). See concepts.md.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, W, G = C.HP, C.X, C.K, C.R, C, C.G
local only = app.params.only
local function want(n) return not only or only == n end
local function ln(c, pts, col, m) c:line(pts, 1):each(function(x, y) if not m or m:has(x, y) then c:put(x, y, col) end end) end

------------------------------------------------------------------ 1 breeze smock
if want("1") then
  local c = C.new("coat-1-breeze-smock")
  local sl = c:ellipse(16, 23, 7, 6):add(c:poly{ {22,14}, {10,20}, {14,30}, {23,26} })
  local sr = c:ellipse(48, 23, 7, 6):add(c:poly{ {42,14}, {54,20}, {50,30}, {41,26} })
  local body = c:poly{ {22,13}, {42,13}, {51,55}, {13,55} }
  for x = 13, 51 do if (x % 6) == 0 then body:cut(c:rect(x, 55, x + 1, 55)) end end
  C.lay(c, sl, R.cotton, { R = 3, b = -1 }) C.lay(c, sr, R.cotton, { R = 3, b = -1 })
  -- sleeve cuff trim
  for _, s in ipairs({ { sl, 1 }, { sr, -1 } }) do
    s[1]:each(function(x, y) if not s[1]:has(x, y + 1) or not s[1]:has(x, y + 2) then c:put(x, y, R.turq[(x + y) % 2 == 0 and 4 or 3]) end end)
  end
  C.sep(c, body, sl:copy():add(sr), R.cotton[1])
  local bi = C.lay(c, body, R.cotton, { R = 6, cuts = { .22, .4, .56, .72, .9 } })
  -- soft folds down the skirt
  for _, f in ipairs({ { {25,28}, {20,54} }, { {39,28}, {44,54} }, { {32,30}, {32,54} } }) do
    c:line(f, 1):each(function(x, y) if body:has(x, y) then c:put(x, y, R.cotton[math.max(1, bi[K(x, y)] - 1)]) end end)
    c:line(f, 1):shift(-1, 0):each(function(x, y) if body:has(x, y) and y > 32 then c:put(x, y, R.cotton[math.min(6, bi[K(x, y)] + 1)]) end end)
  end
  -- gathered yoke: smocking pleats + cross-stitch band
  for x = 20, 44 do for y = 15, 24 do if body:has(x, y) and x % 3 == 0 then c:put(x, y, R.cotton[math.max(1, bi[K(x, y)] - 1)]) end end end
  for x = 19, 45 do
    if body:has(x, 25) then c:put(x, 25, R.turq[(x % 2 == 0) and 4 or 2]) c:put(x, 26, R.turq[(x % 2 == 1) and 5 or 3]) end
  end
  -- hem stitch
  for x = 15, 49, 2 do if body:has(x, 51) then c:put(x, 51, R.turq[3]) end end
  -- neck opening with a slit
  local neck = c:ellipse(32, 13, 5, 2.5):clip(body)
  c:fillMask(neck, R.cotton[1])
  W.vline(c, 32, 15, 20, R.cotton[2])
  neck:grow(1):cut(neck):clip(body):each(function(x, y) if y > 13 then c:put(x, y, R.turq[4]) end end)
  -- quirk: pink frangipani pinned at the collar
  C.flower2(c, 25, 17, R.flam, "#f5b82e")
  c:put(37, 30, R.cotton[6]) c:put(38, 30, R.cotton[6])
  C.save(c, "coat-1-breeze-smock")
end

------------------------------------------------------------------ 2 indigo wrap-coat
if want("2") then
  local c = C.new("coat-2-indigo-wrap-coat")
  local sl = c:poly{ {21,11}, {9,18}, {6,40}, {17,41}, {21,27} }
  local sr = c:poly{ {43,11}, {55,18}, {58,40}, {47,41}, {43,27} }
  local body = c:poly{ {20,9}, {44,9}, {47,57}, {17,57} }
  local si = C.lay(c, sl, R.indigo, { R = 3, b = -1 }) C.lay(c, sr, R.indigo, { R = 3, b = -1 })
  -- sleeve mouths: inner dark + cuff band
  W.hline(c, 7, 16, 40, R.indigo[1]) W.hline(c, 48, 57, 40, R.indigo[1])
  for _, s in ipairs({ sl, sr }) do s:each(function(x, y) if y >= 36 and y <= 37 then c:put(x, y, R.cotton[y == 36 and 5 or 3]) end end) end
  C.sep(c, body, sl:copy():add(sr), R.indigo[1])
  local bi = C.lay(c, body, R.indigo, { R = 6, cuts = { .22, .4, .56, .72, .9 } })
  -- under-lapel (behind) then over-lapel crossing left shoulder -> right waist
  local lap2 = c:line({ {41,10}, {33,22} }, 3):clip(body)
  c:fillMask(lap2, R.indigo[2])
  local lap = c:line({ {23,10}, {33,21}, {41,32} }, 4):clip(body)
  C.sep(c, lap, body)
  local li = C.lay(c, lap, R.cotton, { R = 1 })
  -- overlap edge shadow down the front
  c:line({ {41,33}, {40,56} }, 1):each(function(x, y) c:put(x, y, R.indigo[1]) c:put(x - 1, y, R.indigo[5]) end)
  -- sun-orange sash with a side knot and tails
  local sash = c:rect(17, 31, 47, 35):clip(body)
  C.lay(c, sash, R.sunset, { R = 1 })
  W.hline(c, 18, 46, 31, R.sunset[6])
  W.hline(c, 18, 46, 36, R.indigo[1])
  local knot = c:ellipse(44, 33, 2.5, 2.5)
  W.lit(c, knot, R.sunset, { R = 1 })
  local t1 = C.tube(c, { {44,35}, {46,40}, {45,45}, {47,50} }, 1.5, R.sunset)
  local t2 = C.tube(c, { {43,35}, {41,40}, {42,44}, {40,47} }, 1.3, R.sunset, { b = -1 })
  -- quirk: carved wooden fish toggle on the long tail
  local fish = c:ellipse(48, 53, 2.6, 1.6)
  C.sep(c, fish, t1)
  W.lit(c, fish, R.wood, { R = 1 })
  W.put(c, { {51,51}, {51,52}, {51,54}, {51,55}, {50,53} }, R.wood[3])
  c:put(46, 52, W.ink) c:put(47, 54, R.wood[2]) c:put(48, 52, R.wood[6])
  c:put(24, 40, R.indigo[6]) c:put(24, 41, R.indigo[6])
  C.save(c, "coat-2-indigo-wrap-coat")
end

------------------------------------------------------------------ 3 check-weave jacket
if want("3") then
  local c = C.new("coat-3-check-weave-jacket")
  local plaid = function(x, y, i)
    local a, b = (x % 6) < 2, (y % 6) < 2
    if a and b then return -2 elseif a or b then return -1 elseif (x % 6 == 4 and y % 2 == 0) or (y % 6 == 4 and x % 2 == 0) then return 1 end
  end
  local sl = c:poly{ {19,14}, {11,19}, {8,47}, {15,47}, {19,26} }
  local sr = c:poly{ {45,14}, {53,19}, {56,47}, {49,47}, {45,26} }
  local body = c:poly{ {18,13}, {46,13}, {48,46}, {16,46} }
  C.lay(c, sl, R.check, { R = 3, b = -1, tex = plaid }) C.lay(c, sr, R.check, { R = 3, b = -1, tex = plaid })
  W.hline(c, 9, 15, 45, R.wood[2]) W.hline(c, 9, 15, 46, R.wood[3]) W.hline(c, 49, 55, 45, R.wood[2]) W.hline(c, 49, 55, 46, R.wood[3])
  C.sep(c, body, sl:copy():add(sr), R.check[1])
  C.lay(c, body, R.check, { R = 5, tex = plaid })
  -- front opening and hem band
  W.vline(c, 32, 22, 46, R.check[1]) W.vline(c, 33, 22, 46, R.check[5])
  W.hline(c, 17, 47, 44, R.check[2])
  -- big cream collar (two lapels)
  local col = c:poly{ {20,12}, {31,12}, {32,24}, {24,20} }:add(c:poly{ {33,12}, {44,12}, {40,20}, {32,24} })
  C.sep(c, col, body)
  C.lay(c, col, R.cotton, { R = 2 })
  W.put(c, { {32,13}, {32,14}, {32,15}, {32,16} }, R.check[1])
  -- coconut-shell buttons
  for _, y in ipairs({ 28, 34, 40 }) do
    C.ball(c, 30, y, 1.5, R.wood, true)
    c:put(30, y, R.wood[1])
  end
  -- chest pocket + quirk: round sea-grape leaf poking out
  local leaf = c:ellipse(40, 27, 3.5, 3.2)
  local lf = C.lay(c, leaf, R.palm, { R = 2 })
  W.put(c, { {40,26}, {40,27}, {40,28}, {39,25}, {41,25} }, R.hibis[3])
  c:put(38, 25, R.palm[6])
  local pk = c:rect(36, 29, 44, 35)
  C.sep(c, pk, leaf)
  C.lay(c, pk, R.check, { R = 1, tex = plaid })
  W.hline(c, 36, 44, 29, R.check[5]) W.hline(c, 36, 44, 30, R.check[2])
  for y = 31, 35, 2 do c:put(36, y, R.cotton[4]) c:put(44, y, R.cotton[3]) end
  c:put(22, 26, R.check[6]) c:put(23, 26, W.cream)
  C.save(c, "coat-3-check-weave-jacket")
end

------------------------------------------------------------------ 4 sailcloth longcoat
if want("4") then
  local c = C.new("coat-4-sailcloth-longcoat")
  local sl = c:poly{ {22,11}, {15,15}, {11,44}, {17,45}, {21,24} }
  local sr = c:poly{ {42,11}, {49,15}, {53,44}, {47,45}, {43,24} }
  local body = c:poly{ {21,9}, {43,9}, {49,58}, {15,58} }
  local wear = function(x, y, i) if X.hash(x, y, 11) < .12 then return -1 elseif (x % 3 == 0 and y % 2 == 0) then return -1 end end
  C.lay(c, sl, R.canvas, { R = 3, b = -1, tex = wear }) C.lay(c, sr, R.canvas, { R = 3, b = -1, tex = wear })
  W.hline(c, 12, 16, 42, R.canvas[2]) W.hline(c, 48, 52, 42, R.canvas[2])
  C.sep(c, body, sl:copy():add(sr), R.canvas[1])
  local bi = C.lay(c, body, R.canvas, { R = 6, cuts = { .22, .4, .56, .72, .9 }, tex = wear })
  -- front edge, back vent at the hem
  W.vline(c, 32, 12, 58, R.canvas[1]) W.vline(c, 31, 12, 58, R.canvas[5])
  -- stand collar
  local col = c:rrect(24, 6, 40, 11, 2)
  C.sep(c, col, body)
  C.lay(c, col, R.canvas, { R = 2 })
  W.hline(c, 25, 39, 11, R.canvas[1])
  W.vline(c, 32, 7, 10, R.canvas[2])
  -- mended patch on the shoulder (darker sail patch, white stitches)
  local mp = c:rect(36, 14, 41, 19)
  c:fillMask(mp, R.indigo[4]) W.hline(c, 36, 41, 14, R.indigo[5])
  for _, p in ipairs({ {35,14}, {35,16}, {35,18}, {37,20}, {39,20}, {42,15}, {42,17} }) do c:put(p[1], p[2], R.cotton[5]) end
  -- deep patch pockets
  for _, px in ipairs({ 18, 36 }) do
    local pk = c:rect(px, 40, px + 9, 49)
    C.lay(c, pk, R.canvas, { R = 1, b = (px > 30) and -1 or 0 })
    W.hline(c, px, px + 9, 40, R.canvas[2]) W.hline(c, px, px + 9, 41, R.canvas[5])
    for y = 43, 49, 2 do c:put(px, y, R.canvas[2]) c:put(px + 9, y, R.canvas[2]) end
    W.hline(c, px, px + 9, 50, R.canvas[1])
  end
  -- rope frog toggles across the opening
  for i, y in ipairs({ 18, 25, 32 }) do
    ln(c, { {27,y}, {37,y} }, R.sisal[4])
    ln(c, { {27,y+1}, {37,y+1} }, R.sisal[2])
    W.put(c, { {26,y}, {26,y+1}, {38,y}, {38,y+1} }, R.sisal[3])
    c:put(27, y, R.sisal[6])
    if i < 3 then
      C.ball(c, 32, y, 1.5, R.wood) c:put(31, y - 1, R.wood[6])
    else
      -- quirk: one odd button, a pale sand dollar
      local sd = c:ellipse(32, y, 2.6, 2.6)
      W.lit(c, sd, R.shell, { R = 1 })
      W.put(c, { {32,y-1}, {31,y}, {33,y}, {31,y+1}, {33,y+1} }, R.shell[3])
      c:put(32, y, R.shell[6]) c:put(31, y - 2, W.cream)
    end
  end
  c:put(19, 22, R.canvas[6]) c:put(19, 23, R.canvas[6])
  C.save(c, "coat-4-sailcloth-longcoat")
end

------------------------------------------------------------------ 5 sunset batik vest
if want("5") then
  local c = C.new("coat-5-sunset-batik-vest")
  local body = c:poly{ {18,9}, {25,9}, {32,29}, {39,9}, {46,9}, {43,17}, {48,24}, {48,46}, {41,52}, {33,48}, {31,48}, {23,52}, {16,46}, {16,24}, {21,17} }
  -- back panel lining seen through the V and below the neck
  local back = c:poly{ {24,8}, {40,8}, {38,14}, {32,30}, {26,14} }
  c:fillMask(back, R.coral[1])
  W.hline(c, 26, 38, 9, R.coral[2])
  local bi = C.lay(c, body, R.sunset, { R = 5, cuts = { .22, .4, .56, .72, .9 } })
  -- batik: pale wax-resist rings on orange, deepening to coral toward the hem
  body:each(function(x, y)
    local i = bi[K(x, y)]
    local ramp = (y > 34 + ((x * 7) % 3)) and R.coral or R.sunset
    local best = 1e9
    for _, r in ipairs({ {23,38}, {41,38}, {22,22}, {42,22} }) do best = math.min(best, math.sqrt((x - r[1])^2 + (y - r[2])^2)) end
    local ring = best % 4
    if ring >= 1.6 and ring < 2.6 and best < 11 then c:put(x, y, (ramp == R.coral) and R.shell[math.min(6, i + 1)] or R.sunset[math.min(6, i + 2)])
    else c:put(x, y, ramp[i]) end
    if best < 1 then c:put(x, y, R.hibis[4]) end
  end)
  -- armhole + V-neck binding
  body:edge():each(function(x, y)
    local arm = (y < 25 and (x < 22 or x > 42))
    local vee = (y < 30 and x > 23 and x < 41 and not body:has(x, y - 1) == false and (body:has(x + 1, y) ~= body:has(x - 1, y)))
    if arm or vee then c:put(x, y, R.coral[x < 32 and 4 or 2]) end
  end)
  -- front opening
  W.vline(c, 32, 30, 47, R.coral[1]) W.vline(c, 31, 30, 47, R.sunset[5])
  -- sea-glass buttons
  for _, y in ipairs({ 33, 38, 43 }) do
    local b = c:ellipse(34, y, 1.2, 1.2)
    W.lit(c, b, R.seaglass, { R = 1 })
    c:put(34, y - 1, R.seaglass[6])
  end
  -- welt pockets
  for _, px in ipairs({ 19, 37 }) do
    W.hline(c, px, px + 8, 41, R.coral[1]) W.hline(c, px, px + 8, 42, R.coral[5])
  end
  -- quirk: green anole peeking out of the left pocket (head, eye, orange dewlap, toes)
  local head = c:poly{ {20,41}, {20,37}, {23,34}, {27,34}, {29,37}, {28,41} }
  C.sep(c, head, body)
  W.lit(c, head, R.palm, { R = 1 })
  W.hline(c, 22, 26, 35, R.palm[6]) c:put(23, 35, W.cream)
  c:put(25, 37, W.ink) c:put(26, 37, R.palm[2])
  W.put(c, { {21,39}, {21,40}, {22,40}, {22,41}, {23,41} }, R.sunset[5]) c:put(21, 40, R.sunset[6])
  W.put(c, { {29,40}, {30,40}, {30,41} }, R.palm[4]) c:put(31, 41, R.palm[3])
  W.hline(c, 19, 27, 42, R.coral[5])
  c:put(21, 12, R.sunset[6]) c:put(21, 13, W.cream)
  C.save(c, "coat-5-sunset-batik-vest")
end
