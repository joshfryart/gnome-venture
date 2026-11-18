-- cloak.lua: Maizehollow (CA) cloak concepts 1..5
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(DIR .. "/common.lua")
local HP, X, K, R, G = C.HP, C.X, C.K, C.R, C.G
local hash = X.hash
local ixtle = { "#4a4a38", "#686a4e", "#8a8c66", "#aaab80", "#c8c89c", "#e2e0bc" } -- pale agave fibre

---------------------------------------------------------------- 1 hearthstripe poncho
do
  local c = C.new("cloak-1-hearthstripe-poncho")
  local body = c:poly{ {22, 9}, {42, 9}, {58, 32}, {58, 50}, {6, 50}, {6, 32} }
  local bi = C.part(c, body, R.clay, { R = 6, tex = function(x, y) if (x + y) % 3 == 0 and hash(x, y, 2) < .5 then return -1 end end })
  local function band(y0, y1, ramp, d)
    body:each(function(x, y) if y >= y0 and y <= y1 then c:put(x, y, ramp[math.max(1, math.min(6, bi[K(x, y)] + (d or 0)))]) end end)
  end
  band(38, 39, R.maize, 1) band(41, 43, R.indigo, 1) band(45, 45, R.cotton, 0) band(47, 48, R.maize, 1)
  band(26, 26, R.maize, 1) band(28, 28, R.cotton, 0)
  -- stepped diamond in the centre front
  for y = 15, 35 do
    local hw = 10 - math.abs(y - 25)
    if hw >= 0 then
      for x = 32 - hw, 32 + hw do
        local d = math.abs(x - 32) + math.abs(y - 25)
        local col
        if d % 4 == 0 then col = R.maize[5] elseif d % 4 == 1 then col = R.indigo[3] elseif d % 4 == 2 then col = R.indigo[2] else col = R.cotton[5] end
        if d == 0 then col = R.cochi[5] end
        c:put(x, y, col)
      end
    end
  end
  -- fold shadows from the shoulders
  for _, f in ipairs({ { {20, 14}, {12, 48} }, { {44, 14}, {52, 48} } }) do
    c:line(f, 1):each(function(x, y) if body:has(x, y) and y > 24 then c:put(x, y, R.clay[2]) end end)
  end
  -- neck opening with a rolled collar
  local col = c:ellipse(32, 9, 7, 3)
  C.part(c, col, R.clay, { R = 2, b = 1 })
  C.fill(c, c:ellipse(32, 9, 4, 1.2), R.cacao[1])
  -- fringe
  for x = 7, 57 do if x % 2 == 1 then local len = 4 + (x * 5) % 3 for y = 51, 50 + len do c:put(x, y, (y == 51) and R.clay[3] or R.maize[(x < 32) and 4 or 3]) end end end
  C.hline(c, 6, 58, 50, R.clay[2])
  -- quirk: bougainvillea blossom caught in the fringe
  local p1 = c:poly{ {12, 51}, {17, 48}, {18, 53} }
  local p2 = c:poly{ {17, 53}, {23, 51}, {21, 57} }
  local p3 = c:poly{ {12, 54}, {17, 54}, {13, 58} }
  C.part(c, p1, R.bougain, { R = 1, b = 1 }) C.part(c, p2, R.bougain, { R = 1 }) C.part(c, p3, R.bougain, { R = 1, b = -1 })
  c:put(17, 53, R.cotton[6]) c:put(16, 52, R.maize[5])
  C.save(c, "cloak-1-hearthstripe-poncho")
end

---------------------------------------------------------------- 2 dappled rebozo (draped loop, knotted fringe)
do
  local c = C.new("cloak-2-dappled-rebozo")
  -- shawl worn folded into a triangle, point down; long knotted fringe on both lower edges
  local tri = c:poly{ {5, 8}, {59, 8}, {32, 44} }
  local idx = C.part(c, tri, R.agave, { R = 6 })
  -- ikat: stripes parallel to the top edge with feathered breaks
  tri:each(function(x, y)
    local i = idx[K(x, y)]
    local u = (y - 8) % 7
    if u == 2 or u == 4 then
      local h = hash(x // 3, y, 4)
      if h > .3 then c:put(x, y, R.cotton[math.min(6, i + 1)]) else c:put(x, y, R.agave[math.max(1, i - 1)]) end
    elseif u == 3 and (x + y) % 5 == 0 then c:put(x, y, R.bougain[4]) end
  end)
  -- folded top edge: a lit roll
  for x = 6, 58 do c:put(x, 8, R.agave[6]) c:put(x, 9, R.agave[5]) c:put(x, 10, R.agave[2]) end
  -- soft folds towards the point
  for _, f in ipairs({ { {20, 12}, {30, 40} }, { {44, 12}, {34, 40} } }) do
    c:line(f, 1):each(function(x, y) if tri:has(x, y) then c:put(x, y, R.agave[2]) end end)
  end
  -- knotted net band + long strands under both diagonal edges
  local function edgeY(x) local l = 8 + (x - 5) * 36 / 27 local r = 8 + (59 - x) * 36 / 27 return math.floor(math.min(l, r)) end
  for x = 6, 58 do
    local y0 = edgeY(x) + 1
    if not tri:has(x, y0) then
      if (x % 2 == 0) then for y = y0, y0 + 2 do if (x + y) % 2 == 0 then c:put(x, y, R.cotton[4]) end end end
      if x % 2 == 0 then
        local len = 8 - (x % 3)
        for y = y0 + 2, y0 + 2 + len do c:put(x, y, R.agave[x < 32 and 4 or 3]) end
      end
    end
  end
  -- quirk: a seed-pod rattle bead on one strand
  local pod = G.oval(22, 41, 1.6, 2.4, 0)
  C.part(c, pod, R.cacao, { R = 1, b = 1 })
  c:put(21, 40, R.cacao[6])
  C.save(c, "cloak-2-dappled-rebozo")
end

---------------------------------------------------------------- 3 palm rain cape (shingled leaves) + tree frog
do
  local c = C.new("cloak-3-palm-rain-cape")
  local rows = {}
  local tiers = { { 4, 16, 10 }, { 12, 28, 16 }, { 22, 40, 21 }, { 33, 52, 26 }, { 44, 60, 30 } }
  local all = HP.mask()
  -- bottom tier first so upper tiers overlap
  for ti = #tiers, 1, -1 do
    local y0, y1, hw = tiers[ti][1], tiers[ti][2], tiers[ti][3]
    local m = c:poly{ {32 - hw * .55, y0}, {32 + hw * .55, y0}, {32 + hw, y1 - 3}, {32 - hw, y1 - 3} }
    -- ragged leaf tips along the bottom
    for x = math.floor(32 - hw), math.ceil(32 + hw) do
      local k = (x + ti) % 3
      local tip = (k == 0) and 3 or ((k == 1) and 1 or 2)
      for y = y1 - 3, y1 - 3 + tip do if x >= 32 - hw and x <= 32 + hw then m:set(x, y) end end
    end
    if ti < #tiers then C.sep(c, m, all, R.straw[1]) end
    local b = ({ 1, 1, 0, 0, -1 })[ti]
    local idx = C.part(c, m, R.straw, { R = 3, b = b })
    m:each(function(x, y)
      local i = idx[K(x, y)]
      -- leaf strips radiating from the peak
      local u = math.floor((x - 32) * 10 / (y + 6) + 100)
      if (x - 32) * 10 % (y + 6) < 3 and false then end
      local w = ((x - 32) / (y - y0 + hw * .9 + 1)) * 6
      if math.floor(w * 2 + 50) % 3 == 0 then c:put(x, y, R.straw[math.max(1, i - 1)])
      elseif y >= y1 - 3 and (x + ti) % 3 == 0 then c:put(x, y, R.maize[math.min(6, i)]) end
    end)
    all:add(m)
  end
  -- peak tie cord
  C.hline(c, 28, 36, 8, R.cacao[2]) C.hline(c, 28, 36, 9, R.cacao[3])
  C.put(c, { {29, 10}, {28, 11}, {28, 12} }, R.cacao[3]) C.put(c, { {35, 10}, {36, 11}, {37, 12} }, R.cacao[2])
  local top = c:poly{ {30, 1}, {34, 1}, {35, 6}, {29, 6} }
  C.part(c, top, R.straw, { R = 1, b = 1 })
  -- quirk: red-eyed tree frog sheltering at the hem (right)
  local fb = G.oval(48, 56, 4.5, 3, 0.2)
  C.part(c, fb, R.jade, { R = 2, b = 1 })
  for _, e in ipairs({ { 45, 53 }, { 50, 53 } }) do
    C.put(c, { {e[1], e[2]}, {e[1] + 1, e[2]}, {e[1], e[2] - 1}, {e[1] + 1, e[2] - 1} }, R.cochi[4])
    c:put(e[1], e[2] - 1, R.cochi[6]) c:put(e[1] + 1, e[2], C.ink)
  end
  C.put(c, { {43, 58}, {42, 59}, {53, 58}, {54, 59} }, R.marig[4])
  C.put(c, { {46, 58}, {47, 58}, {48, 58} }, R.maize[6])
  C.save(c, "cloak-3-palm-rain-cape")
end

---------------------------------------------------------------- 4 agave-fibre mantle knotted at one shoulder
do
  local c = C.new("cloak-4-agave-fibre-mantle")
  local back = c:poly{ {22, 12}, {46, 18}, {54, 36}, {44, 34} }
  local front = c:poly{ {14, 12}, {24, 10}, {40, 22}, {48, 38}, {56, 61}, {44, 56}, {30, 58}, {18, 56}, {8, 58}, {7, 34} }
  C.part(c, back, ixtle, { R = 2, b = -1 })
  C.sep(c, front, back, ixtle[1])
  local fi = C.part(c, front, ixtle, { R = 6 })
  -- open coarse weave: holes on a grid, thick yarn ridges
  front:each(function(x, y)
    local i = fi[K(x, y)]
    if x % 4 == 0 and y % 4 == 0 then c:put(x, y, ixtle[math.max(1, i - 2)])
    elseif (x + y) % 4 == 1 and hash(x, y, 6) < .35 then c:put(x, y, ixtle[math.min(6, i + 1)]) end
  end)
  -- diagonal drape folds
  for _, f in ipairs({ { {16, 16}, {12, 56} }, { {19, 16}, {26, 56} }, { {23, 16}, {40, 55} }, { {28, 18}, {50, 56} } }) do
    c:line(f, 1):each(function(x, y) if front:has(x, y) then c:put(x, y, ixtle[2]) if front:has(x - 1, y) then c:put(x - 1, y, ixtle[5]) end end end)
  end
  -- hem: frayed loose ends
  for x = 8, 55 do if front:has(x, 57) and x % 3 ~= 0 then c:put(x, 58, ixtle[3]) if x % 3 == 1 then c:put(x, 59, ixtle[2]) end end end
  -- shoulder knot with two ears
  local ear1 = c:poly{ {14, 12}, {8, 3}, {13, 2}, {19, 10} }
  local ear2 = c:poly{ {20, 12}, {26, 3}, {29, 7}, {23, 14} }
  C.sep(c, ear1:copy():add(ear2), front, ixtle[1])
  C.part(c, ear1, ixtle, { R = 2, b = 1 }) C.part(c, ear2, ixtle, { R = 2 })
  for _, e in ipairs({ ear1, ear2 }) do e:each(function(x, y) if (x + y) % 4 == 0 then c:put(x, y, ixtle[2]) end end) end
  local knot = c:ellipse(18, 13, 4, 3.5)
  C.part(c, knot, ixtle, { R = 2, b = 0 })
  C.put(c, { {16, 12}, {17, 13}, {19, 14}, {20, 13} }, ixtle[2])
  -- quirk: a prickly-pear blossom tied at the knot
  local pad = G.oval(26, 15, 2.5, 3.5, 0.6)
  C.part(c, pad, R.jade, { R = 1 })
  local fl = c:ellipse(25, 10, 3, 2.5)
  C.part(c, fl, R.maize, { R = 2, b = 1 })
  C.put(c, { {24, 10}, {25, 11}, {26, 10} }, R.marig[3]) c:put(25, 10, R.jade[4]) c:put(23, 9, R.maize[6])
  C.put(c, { {28, 14}, {27, 17} }, R.maize[6])
  C.save(c, "cloak-4-agave-fibre-mantle")
end

---------------------------------------------------------------- 5 sun hood cloak + dragonfly
do
  local c = C.new("cloak-5-sun-hood-cloak")
  local cape = c:poly{ {22, 22}, {42, 22}, {56, 58}, {8, 58} }
  local ci = C.part(c, cape, R.cotton, { R = 7, tex = function(x, y) if (x + y) % 4 == 0 and hash(x, y, 8) < .5 then return -1 end end })
  -- folds
  for _, f in ipairs({ { {26, 30}, {18, 57} }, { {38, 30}, {46, 57} }, { {32, 34}, {32, 57} } }) do
    c:line(f, 1):each(function(x, y) if cape:has(x, y) then c:put(x, y, R.cotton[2]) if cape:has(x - 1, y) then c:put(x - 1, y, R.cotton[6]) end end end)
  end
  -- red border along the hem + front edges
  cape:each(function(x, y) if y >= 54 then c:put(x, y, R.cochi[(y == 54) and 5 or 3]) end end)
  for y = 25, 54 do c:put(31, y, R.cochi[4]) c:put(33, y, R.cochi[3]) c:put(32, y, R.cotton[2]) end
  for x = 9, 55, 4 do if cape:has(x, 56) then c:put(x, 56, R.maize[5]) end end
  -- hood: big peaked shape, deep opening with red lining
  local hood = c:poly{ {32, 2}, {46, 18}, {47, 28}, {32, 34}, {17, 28}, {18, 18} }
  local open = c:ellipse(32, 24, 7, 6):clip(hood)
  C.sep(c, hood, cape, R.cotton[1])
  C.part(c, hood, R.cotton, { R = 4, b = 1 })
  C.fill(c, open:copy():grow(1):clip(hood), R.cochi[3])
  open:grow(1):clip(hood):each(function(x, y) if x < 32 and not open:has(x, y) then c:put(x, y, R.cochi[5]) end end)
  C.fill(c, open, R.cochi[1])
  open:each(function(x, y) if y > 25 then c:put(x, y, R.cochi[2]) end end)
  open:each(function(x, y) if y > 28 then c:put(x, y, R.cochi[3]) end end)
  -- hood seam to the peak
  for y = 4, 13 do c:put(32, y, R.cotton[3]) end
  -- clasp
  local cl = c:ellipse(32, 34, 2, 2)
  C.part(c, cl, R.copper, { R = 1 }) c:put(31, 33, R.copper[6])
  -- quirk: a blue dragonfly resting on the hood
  C.put(c, { {38, 8}, {39, 9}, {40, 10}, {41, 11}, {42, 12}, {43, 13} }, R.turq[2])
  C.put(c, { {39, 8}, {40, 9} }, R.turq[4])
  C.put(c, { {38, 7}, {37, 8} }, R.turq[5])
  for _, w in ipairs({ { {36, 10}, {35, 11}, {34, 12} }, { {37, 11}, {36, 12}, {36, 13} }, { {41, 7}, {42, 6}, {43, 5} }, { {42, 8}, {43, 8}, {44, 7} } }) do
    C.put(c, w, R.turq[5])
  end
  C.save(c, "cloak-5-sun-hood-cloak")
end
