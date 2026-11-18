-- coat.lua: Maizehollow (CA) coat concepts 1..5 (front view, laid flat)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local hash = X.hash
local weave = function(m) return function(x, y, i) if (x + y) % 4 == 0 and hash(x, y, 5) < .6 then return -1 end end end

---------------------------------------------------------------- 1 bloom smock
do
  local c = C.new("coat-1-bloom-smock")
  local body = c:rrect(17, 12, 47, 56, 2)
  local slL = c:poly{ {18, 13}, {7, 22}, {6, 32}, {18, 32} }
  local slR = c:poly{ {46, 13}, {57, 22}, {58, 32}, {46, 32} }
  local neck = c:rect(26, 12, 38, 18)
  C.part(c, slL, R.cotton, { R = 3, b = 0, tex = weave() })
  C.part(c, slR, R.cotton, { R = 3, b = -1, tex = weave() })
  C.sep(c, body, slL:copy():add(slR), R.cotton[1])
  local bi = C.part(c, body, R.cotton, { R = 6, tex = weave() })
  -- sleeve hems: red bands
  for _, s in ipairs({ { slL, 0 }, { slR, -1 } }) do
    s[1]:each(function(x, y) if y >= 29 then c:put(x, y, R.cochi[(y == 29 and 5 or 3) + s[2]]) end end)
  end
  -- square yoke of embroidery
  local yoke = c:rect(21, 12, 43, 30):cut(neck)
  yoke:each(function(x, y) c:put(x, y, R.cotton[math.min(6, bi[K(x, y)] + 0)]) end)
  yoke:edge():each(function(x, y) c:put(x, y, R.cochi[3]) end)
  local fl = { {24, 22, R.cochi}, {32, 24, R.marig}, {40, 22, R.cochi}, {24, 15, R.marig}, {40, 15, R.marig}, {28, 27, R.bougain}, {36, 27, R.bougain} }
  for _, f in ipairs(fl) do C.flower(c, f[1], f[2], f[3], R.maize[5]) end
  C.put(c, { {27, 22}, {28, 21}, {36, 22}, {37, 21}, {30, 25}, {34, 25}, {22, 19}, {42, 19}, {25, 18}, {39, 18} }, R.jade[4])
  C.put(c, { {28, 22}, {36, 21}, {22, 20}, {42, 20} }, R.jade[3])
  -- neck opening (back of the smock inside)
  C.fill(c, neck:copy():shrink(1):add(c:rect(27, 12, 37, 17)), R.cotton[2])
  C.hline(c, 27, 37, 17, R.cotton[1])
  -- hem band with zig-zag
  for x = 18, 46 do
    c:put(x, 52, R.cochi[3]) c:put(x, 53, R.cochi[4]) c:put(x, 54, R.cochi[3])
    if x % 4 == 0 then c:put(x, 53, R.maize[5]) end
  end
  C.hline(c, 18, 46, 55, R.cotton[3])
  -- side slits
  C.vline(c, 17, 46, 55, R.cotton[2]) C.vline(c, 47, 46, 55, R.cotton[1])
  -- quirk: a needle stuck through the yoke corner, trailing red thread
  local nd = c:line({ {39, 35}, {47, 27} }, 1)
  nd:each(function(x, y) c:put(x, y, R.steel[2]) c:put(x, y - 1, R.steel[5]) end)
  c:put(47, 25, R.steel[2]) c:put(48, 26, R.steel[2]) c:put(48, 25, R.steel[6])
  local th = G.tube({ {48, 25}, {54, 26}, {50, 38}, {55, 44} }, function() return .6 end)
  th:each(function(x, y) c:put(x, y, R.cochi[4]) end)
  c:put(49, 25, R.cochi[5])
  C.save(c, "coat-1-bloom-smock")
end

---------------------------------------------------------------- 2 pleated shirt-jacket
do
  local c = C.new("coat-2-pleated-shirt-jacket")
  local body = c:poly{ {20, 12}, {44, 12}, {46, 20}, {45, 57}, {19, 57}, {18, 20} }
  local slL = c:poly{ {20, 12}, {12, 18}, {6, 46}, {12, 48}, {19, 26} }
  local slR = c:poly{ {44, 12}, {52, 18}, {58, 46}, {52, 48}, {45, 26} }
  C.part(c, slL, R.sage, { R = 3, b = 0, tex = weave() })
  C.part(c, slR, R.sage, { R = 3, b = -1, tex = weave() })
  -- cuffs
  for _, cf in ipairs({ c:poly{ {6, 44}, {12, 46}, {11, 49}, {5, 47} }, c:poly{ {52, 46}, {58, 44}, {59, 47}, {53, 49} } }) do C.part(c, cf, R.sage, { R = 1, b = 1 }) end
  C.sep(c, body, slL:copy():add(slR), R.sage[1])
  local bi = C.part(c, body, R.sage, { R = 6, tex = weave() })
  -- vertical pleats (lit edge + shadow line)
  for _, x in ipairs({ 22, 26, 38, 42 }) do
    for y = 16, 56 do if body:has(x, y) then c:put(x, y, R.sage[2]) c:put(x - 1, y, R.sage[math.min(6, bi[K(x - 1, y)] + 1)]) end end
  end
  -- placket + buttons
  for y = 15, 56 do c:put(32, y, R.sage[2]) c:put(31, y, R.sage[5]) end
  for y = 20, 52, 6 do c:put(33, y, R.cacao[3]) c:put(33, y + 1, R.cacao[2]) end
  -- collar points
  local colL = c:poly{ {22, 11}, {31, 13}, {28, 21} }
  local colR = c:poly{ {42, 11}, {33, 13}, {36, 21} }
  C.part(c, colL, R.sage, { R = 1, b = 1 }) C.part(c, colR, R.sage, { R = 1, b = 0 })
  C.put(c, { {30, 14}, {31, 14}, {32, 14}, {33, 14}, {32, 13} }, R.sage[1])
  -- four patch pockets with flaps
  local function pocket(x0, y0)
    local p = c:rect(x0, y0, x0 + 8, y0 + 8)
    p:each(function(x, y) c:put(x, y, R.sage[math.max(1, bi[K(x, y)] - 0)]) end)
    C.rimDark(c, p, R.sage[2])
    C.hline(c, x0, x0 + 8, y0, R.sage[5]) C.hline(c, x0, x0 + 8, y0 + 1, R.sage[5]) C.hline(c, x0, x0 + 8, y0 + 2, R.sage[2])
    c:put(x0 + 4, y0 + 1, R.cacao[3])
  end
  pocket(21, 22) pocket(35, 22) pocket(21, 41) pocket(35, 41)
  -- quirk: cacao pod poking out of the lower right pocket
  local pod = G.oval(40, 37, 3.5, 6.5, 0.35):cut(c:rect(35, 42, 44, 50))
  C.part(c, pod, R.clay, { R = 2 })
  pod:each(function(x, y) if (x - y // 3) % 3 == 0 then c:put(x, y, R.clay[2]) end end)
  C.put(c, { {38, 33}, {38, 34} }, R.clay[6])
  C.put(c, { {42, 30}, {43, 29}, {43, 28} }, R.cacao[2])
  C.hline(c, 35, 43, 41, R.sage[5]) C.hline(c, 35, 43, 42, R.sage[5]) C.hline(c, 35, 43, 43, R.sage[2])
  c:put(39, 42, R.cacao[3])
  C.save(c, "coat-2-pleated-shirt-jacket")
end

---------------------------------------------------------------- 3 fringed leather vest
do
  local c = C.new("coat-3-fringed-leather-vest")
  local L = c:poly{ {14, 10}, {22, 10}, {31, 34}, {31, 50}, {13, 50}, {13, 30}, {18, 24}, {14, 18} }
  local Rr = c:poly{ {50, 10}, {42, 10}, {33, 34}, {33, 50}, {51, 50}, {51, 30}, {46, 24}, {50, 18} }
  local back = c:poly{ {22, 10}, {42, 10}, {32, 36} }
  C.part(c, back, R.cacao, { R = 2, b = 0 })
  C.hline(c, 23, 41, 10, R.cacao[5])
  C.sep(c, L:copy():add(Rr), back, R.cacao[1])
  local li = C.part(c, L, R.leather, { R = 5 })
  local ri = C.part(c, Rr, R.leather, { R = 5, b = -1 })
  -- tooled vine borders near the front edges
  for y = 14, 48 do
    local xl = 24 + math.floor((y - 12) * 0.3) if y > 34 then xl = 29 end
    if L:has(xl - 2, y) and y % 3 ~= 0 then c:put(xl - 2, y, R.leather[3]) end
    local xr = 40 - math.floor((y - 12) * 0.3) if y > 34 then xr = 35 end
    if Rr:has(xr + 2, y) and y % 3 ~= 0 then c:put(xr + 2, y, R.leather[2]) end
  end
  -- armhole seams
  C.put(c, { {14, 19}, {15, 20}, {16, 21}, {17, 23} }, R.leather[2])
  C.put(c, { {50, 19}, {49, 20}, {48, 21}, {47, 23} }, R.leather[1])
  -- copper studs down the front
  for y = 28, 46, 6 do
    c:put(28, y, R.copper[5]) c:put(29, y, R.copper[3]) c:put(28, y + 1, R.copper[3])
    c:put(35, y, R.copper[5]) c:put(36, y, R.copper[3]) c:put(35, y + 1, R.copper[3])
  end
  -- fringe
  for x = 13, 51 do
    if x ~= 32 then
      local len = 6 + ((x * 7) % 3)
      local side = x < 32 and 0 or -1
      for y = 51, 50 + len do
        if x % 2 == 1 then c:put(x, y, R.leather[(y < 53 and 4 or 3) + side]) end
      end
    end
  end
  C.hline(c, 13, 31, 50, R.leather[2]) C.hline(c, 33, 51, 50, R.leather[1])
  -- shine
  c:put(16, 30, R.leather[6]) c:put(16, 31, R.leather[6])
  -- quirk: a copper bell dangling from the fringe
  C.put(c, { {44, 57}, {44, 58} }, R.strap[2])
  local bell = c:poly{ {42, 59}, {46, 59}, {47, 62}, {41, 62} }
  C.part(c, bell, R.copper, { R = 1 })
  c:put(42, 60, R.copper[6]) c:put(44, 63, R.copper[2])
  C.save(c, "coat-3-fringed-leather-vest")
end

---------------------------------------------------------------- 4 quilted cotton coat
do
  local c = C.new("coat-4-quilted-cotton-coat")
  local body = c:rrect(16, 12, 48, 56, 7)
  local slL = c:rrect(5, 15, 20, 49, 7)
  local slR = c:rrect(44, 15, 59, 49, 7)
  local function quilt(m, b)
    local idx = C.part(c, m, R.cochi, { R = 5, b = b })
    m:each(function(x, y)
      local a, d = (x + y) % 8, (x - y + 64) % 8
      local i = idx[K(x, y)]
      if a == 0 or d == 0 then c:put(x, y, R.cochi[math.max(1, i - 2)])
      elseif a == 1 or d == 1 then c:put(x, y, R.cochi[math.min(6, i + 1)])
      elseif a == 7 or d == 7 then c:put(x, y, R.cochi[math.max(1, i - 1)]) end
    end)
  end
  quilt(slL, 0) quilt(slR, -1)
  -- puffy cuffs
  for _, cf in ipairs({ c:rrect(4, 45, 20, 51, 3), c:rrect(44, 45, 60, 51, 3) }) do C.part(c, cf, R.cotton, { R = 2 }) end
  C.sep(c, body, slL:copy():add(slR), R.cochi[1])
  quilt(body, 0)
  -- front opening + hem band
  for y = 16, 56 do c:put(32, y, R.cochi[1]) c:put(33, y, R.cochi[4]) end
  local hem = c:rrect(16, 51, 48, 57, 3)
  C.part(c, hem, R.cotton, { R = 2 })
  c:put(32, 52, R.cotton[2]) c:put(32, 53, R.cotton[2])
  -- stand collar
  local col = c:rrect(22, 8, 42, 15, 3)
  C.part(c, col, R.cotton, { R = 2, b = 0 })
  C.fill(c, c:rect(27, 9, 37, 11), R.cotton[2])
  C.hline(c, 28, 36, 9, R.cotton[1])
  -- toggles
  for y = 24, 44, 10 do C.put(c, { {30, y}, {31, y}, {34, y}, {35, y} }, R.wood[5]) c:put(32, y, R.wood[3]) c:put(33, y, R.wood[2]) end
  -- quirk: a fluffy cotton boll tucked in the collar
  local boll = c:ellipse(41, 9, 3.5, 3):add(c:ellipse(44, 7, 2.5, 2.5)):add(c:ellipse(43, 11, 2.5, 2))
  C.part(c, boll, R.cotton, { R = 2, b = 1 })
  C.put(c, { {41, 12}, {44, 9}, {40, 10} }, R.cotton[3])
  C.put(c, { {38, 12}, {39, 13}, {46, 10}, {45, 12} }, R.cacao[3])
  c:put(40, 7, C.cream)
  C.save(c, "coat-4-quilted-cotton-coat")
end

---------------------------------------------------------------- 5 indigo field jacket + woven sash
do
  local c = C.new("coat-5-indigo-field-jacket")
  local body = c:poly{ {20, 10}, {44, 10}, {47, 18}, {48, 60}, {16, 60}, {17, 18} }
  local slL = c:poly{ {20, 10}, {11, 15}, {6, 50}, {13, 51}, {18, 24} }
  local slR = c:poly{ {44, 10}, {53, 15}, {58, 50}, {51, 51}, {46, 24} }
  C.part(c, slL, R.indigo, { R = 3, tex = weave() })
  C.part(c, slR, R.indigo, { R = 3, b = -1, tex = weave() })
  -- rolled cuffs (lighter, fold line)
  for _, cf in ipairs({ c:poly{ {6, 45}, {14, 46}, {13, 52}, {5, 51} }, c:poly{ {50, 46}, {58, 45}, {59, 51}, {51, 52} } }) do
    C.part(c, cf, R.indigo, { R = 1, b = 1 })
  end
  C.sep(c, body, slL:copy():add(slR), R.indigo[1])
  local bi = C.part(c, body, R.indigo, { R = 6, tex = weave() })
  -- lapels
  local lapL = c:poly{ {22, 10}, {31, 10}, {31, 30}, {24, 20} }
  local lapR = c:poly{ {42, 10}, {33, 10}, {33, 30}, {40, 20} }
  C.part(c, lapL, R.indigo, { R = 1, b = 1 }) C.part(c, lapR, R.indigo, { R = 1, b = 0 })
  C.fill(c, c:poly{ {29, 10}, {35, 10}, {32, 18} }, R.indigo[1])
  for y = 30, 59 do c:put(32, y, R.indigo[1]) c:put(33, y, R.indigo[5]) end
  -- toggle loops
  for _, y in ipairs({ 24, 30 }) do C.put(c, { {29, y}, {30, y}, {31, y} }, R.maize[4]) C.put(c, { {34, y}, {35, y}, {36, y} }, R.cochi[4]) end
  -- woven striped sash, knot and hanging ends on the right
  local sash = c:rect(16, 37, 48, 43)
  sash:each(function(x, y)
    local u = y - 37
    local col = ({ R.cochi[3], R.maize[5], R.cochi[4], R.cotton[5], R.cochi[4], R.maize[4], R.cochi[2] })[u + 1]
    if x % 4 == 0 and (u == 2 or u == 4) then col = R.indigo[4] end
    c:put(x, y, col)
  end)
  local ends = c:poly{ {40, 42}, {44, 42}, {45, 54}, {41, 54} }:add(c:poly{ {44, 42}, {47, 42}, {50, 52}, {47, 53} })
  ends:each(function(x, y) c:put(x, y, ((x + 0) % 3 == 0) and R.maize[4] or R.cochi[(x < 45) and 4 or 3]) end)
  for x = 41, 50 do if ends:has(x, 53) or ends:has(x, 52) then c:put(x, 54, R.cotton[4]) end end
  local knot = c:rrect(40, 36, 46, 44, 2)
  C.part(c, knot, R.cochi, { R = 1, b = 1 })
  -- pockets
  for _, x0 in ipairs({ 19, 36 }) do C.hline(c, x0, x0 + 8, 48, R.indigo[1]) C.hline(c, x0, x0 + 8, 47, R.indigo[5]) end
  -- quirk: a monarch butterfly resting on the right shoulder
  local bx, by = 48, 14
  local wings = {
    c:poly{ {bx, by}, {bx - 10, by - 8}, {bx - 9, by + 2} }, c:poly{ {bx, by + 1}, {bx - 7, by + 6}, {bx - 1, by + 7} },
    c:poly{ {bx + 1, by}, {bx + 11, by - 8}, {bx + 10, by + 2} }, c:poly{ {bx + 1, by + 1}, {bx + 8, by + 6}, {bx + 2, by + 7} } }
  for i, w in ipairs(wings) do
    C.fill(c, w, R.marig[(i > 2) and 3 or 4])
    w:each(function(x, y) if not w:has(x, y - 1) and (i % 2 == 1) then c:put(x, y, R.marig[6]) end end)
    w:edge():each(function(x, y) if math.abs(x - bx - .5) > 4 or (i % 2 == 0 and not w:has(x, y + 1)) then c:put(x, y, R.cacao[1]) end end)
  end
  C.put(c, { {bx - 9, by - 6}, {bx - 9, by - 2}, {bx + 10, by - 6}, {bx + 10, by - 2}, {bx - 5, by + 6}, {bx + 6, by + 6} }, R.cotton[6])
  C.put(c, { {bx - 4, by - 3}, {bx - 5, by - 1}, {bx + 5, by - 3}, {bx + 6, by - 1} }, R.cacao[2])
  C.vline(c, bx, by - 2, by + 4, R.cacao[1]) C.vline(c, bx + 1, by - 2, by + 4, R.cacao[2])
  C.put(c, { {bx - 1, by - 4}, {bx + 2, by - 4} }, R.cacao[1])
  C.save(c, "coat-5-indigo-field-jacket")
end
