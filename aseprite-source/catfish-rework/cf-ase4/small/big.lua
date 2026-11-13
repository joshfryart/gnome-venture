-- big.lua: cf-tile (64x64), cf-bookhead-grey (32x32), cf-banner (480x120, drawn at 2x)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local S = dofile(DIR .. "/sm.lua")
local H, L, part, px, sep = S.H, S.L, S.part, S.px, S.sep
local R = H.R
local PINK, GOLD, BLUE, ORANGE, RED, WOOD, CREAM, TEAL, BROWN, GREEN = H.PINK, H.GOLD, H.BLUE, H.ORANGE, H.RED, H.WOOD, H.CREAM, H.TEAL, H.BROWN, H.GREEN
local floor, abs, sin, cos, pi = S.floor, S.abs, S.sin, S.cos, S.pi
local function line(c, pts, col) L.line(pts):each(function(x, y) c:put(x, y, col, "detail") end) end
local function eye6(c, x, y)
  local rows = { ".####.", "#ffff#", "#f##f#", "#f##f#", "#ffff#", ".####." }
  for j, row in ipairs(rows) do for i = 1, 6 do local ch = row:sub(i, i)
    if ch == '#' then c:put(x + i - 1, y + j - 1, '#', "detail") elseif ch == 'f' then c:put(x + i - 1, y + j - 1, S.CREAMC, "detail") end end end
end

-- BOOKHEAD ---------------------------------------------------------------------------------------------------
do
  local c = S.new(32, 32)
  local cx, cy, hw, hh = 16, 18, 11, 8.5
  local le = L.poly({ { cx - hw - 0.5, cy - 1 }, { cx - hw + 0.5, cy - hh - 6 }, { cx - 3, cy - hh + 0.5 } })
  local re = L.poly({ { cx + hw + 0.5, cy - 1 }, { cx + hw - 0.5, cy - hh - 6 }, { cx + 3, cy - hh + 0.5 } })
  part(c, le, nil, 1, 1) part(c, re, nil, 1, 1)
  local hd = L.ellipse(cx, cy, hw + 0.5, hh) part(c, hd, nil, 2, 2) sep(c, hd)
  local ie = L.poly({ { cx - hw + 2, cy - 3 }, { cx - hw + 2.5, cy - hh - 3 }, { cx - 4, cy - hh + 0.5 } })
  local ie2 = L.poly({ { cx + hw - 2, cy - 3 }, { cx + hw - 2.5, cy - hh - 3 }, { cx + 4, cy - hh + 0.5 } })
  ie:each(function(x, y) c:put(x, y, S.NOSE, "detail") end) ie2:each(function(x, y) c:put(x, y, S.NOSE, "detail") end)
  local mz = L.ellipse(cx, cy + 4.2, 4.6, 2.6):clip(hd) mz:each(function(x, y) c:put(x, y, 'g', "detail") end)
  for _, ex in ipairs({ cx - 7, cx + 4 }) do
    px(c, { { ex + 1, cy - 4, '#' }, { ex + 2, cy - 4, '#' }, { ex, cy - 3, '#' }, { ex + 3, cy - 3, '#' }, { ex, cy - 2, '#' }, { ex + 3, cy - 2, '#' }, { ex + 1, cy - 1, '#' }, { ex + 2, cy - 1, '#' },
      { ex + 1, cy - 3, S.CREAMC }, { ex + 2, cy - 3, S.CREAMC }, { ex + 1, cy - 2, S.CREAMC }, { ex + 2, cy - 2, S.CREAMC } })
    c:put(ex + 2, cy - 3, '#', "detail") c:put(ex + 2, cy - 2, '#', "detail")
  end
  px(c, { { cx - 1, cy + 2, S.NOSE }, { cx, cy + 2, S.NOSE }, { cx - 1, cy + 3, '#' }, { cx, cy + 3, '#' }, { cx - 2, cy + 4, '#' }, { cx + 1, cy + 4, '#' }, { cx - 9, cy + 1, S.NOSE }, { cx + 8, cy + 1, S.NOSE } })
  S.save(c, "cf-bookhead-grey")
end

-- TILE: grey cat on a blue cushion, one paw up holding a fish ------------------------------------------------------
do
  local c = S.new(64, 64)
  local tail = L.tube({ { 14, 53 }, { 6, 50 }, { 5, 42 }, { 8, 36 } }, function() return 2.3 end) part(c, tail, nil, 1, 1) sep(c, tail)
  local body = L.ellipse(28, 44, 14, 15) part(c, body, nil, 3, 3)
  local belly = L.ellipse(26, 47, 8, 9):clip(body) belly:each(function(x, y) if (x + y) % 2 == 0 or y < 52 then c:put(x, y, 'L', "detail") end end)
  belly:each(function(x, y) c:put(x, y, 'L', "detail") end)
  local ch = L.ellipse(26, 47, 7, 8):clip(body) ch:each(function(x, y) if not ch:has(x + 1, y + 1) or not ch:has(x + 1, y) then c:put(x, y, 'l', "detail") end end)
  -- stitched gold collar + bell
  local col = L.rect(14, 33, 40, 35):clip(L.ellipse(28, 40, 14.8, 12))
  line(c, { { 16, 34 }, { 22, 36 }, { 28, 37 }, { 34, 36 }, { 40, 34 } }, GOLD.m) line(c, { { 16, 35 }, { 22, 37 }, { 28, 38 }, { 34, 37 }, { 40, 35 } }, GOLD.s)
  local bell = L.ellipse(28, 41, 2.2, 2.2) part(c, bell, GOLD, 1, 1) sep(c, bell) c:put(27, 40, GOLD.g, "detail")
  -- resting paw
  local rp = L.ellipse(21, 53, 4.5, 3) part(c, rp, nil, 1, 1) sep(c, rp)
  -- cushion
  local cu = H.rrect(4, 54, 58, 62, 3) part(c, cu, BLUE, 2, 2) sep(c, cu)
  for x = 7, 54 do if x % 4 < 2 then c:put(x, 58, GOLD.m, "detail") end end
  local bt = L.ellipse(31, 56, 2.2, 1.6) part(c, bt, GOLD, 1, 1)
  -- head
  local le = L.poly({ { 12, 22 }, { 13, 6 }, { 24, 13 } }) local re = L.poly({ { 44, 22 }, { 43, 6 }, { 32, 13 } })
  part(c, le, nil, 1, 1) part(c, re, nil, 1, 1)
  local hd = L.ellipse(28, 23, 16.5, 12.5) part(c, hd, nil, 3, 3) sep(c, hd)
  L.poly({ { 15, 20 }, { 15, 10 }, { 22, 14 } }):each(function(x, y) c:put(x, y, S.NOSE, "detail") end)
  L.poly({ { 41, 20 }, { 41, 10 }, { 34, 14 } }):each(function(x, y) c:put(x, y, S.NOSE, "detail") end)
  eye6(c, 17, 19) eye6(c, 33, 19)
  local mz = L.ellipse(28, 29, 5.5, 3.2):clip(hd) mz:each(function(x, y) c:put(x, y, 'g', "detail") end)
  px(c, { { 27, 26, S.NOSE }, { 28, 26, S.NOSE }, { 27, 27, '#' }, { 28, 27, '#' }, { 25, 28, '#' }, { 26, 29, '#' }, { 29, 29, '#' }, { 30, 28, '#' }, { 27, 30, '#' }, { 28, 30, '#' },
    { 14, 27, S.NOSE }, { 15, 27, S.NOSE }, { 41, 27, S.NOSE }, { 42, 27, S.NOSE } })
  -- raised paw + fish
  local arm = L.tube({ { 38, 44 }, { 46, 37 }, { 50, 28 } }, function() return 3.2 end) part(c, arm, nil, 2, 1) sep(c, arm)
  local paw = L.ellipse(50, 26, 4.5, 4.2) part(c, paw, nil, 1, 1) sep(c, paw)
  line(c, { { 49, 25 }, { 49, 27 } }, S.CAT.s) line(c, { { 52, 25 }, { 52, 27 } }, S.CAT.s)
  local ft = L.poly({ { 54, 12 }, { 62, 6 }, { 62, 18 } })
  part(c, ft, ORANGE, 1, 1, { lift = -1 }) sep(c, ft)
  local fb = L.ellipse(48, 12, 8, 5.2) part(c, fb, ORANGE, 2, 2) sep(c, fb)
  px(c, { { 43, 11, '#' }, { 43, 12, '#' }, { 44, 11, ORANGE.g }, { 49, 9, ORANGE.L }, { 50, 9, ORANGE.L }, { 49, 14, ORANGE.s }, { 51, 12, ORANGE.s }, { 48, 15, ORANGE.s }, { 46, 14, ORANGE.s } })
  S.save(c, "cf-tile")
end

-- BANNER: 240x60 logical, saved doubled to 480x120 -----------------------------------------------------------------
do
  local W, Hh = 240, 60
  local c = L.canvas(W, Hh, true)
  local WALL = R("#b49a78", "#d8bf94", "#f0dcae", "#f6e6bc", "#fbf0d2", "#ffffff")
  local FLOOR = R("#7a4c2c", "#a2703e", "#c8905a", "#d6a468", "#e4b87c", "#f4d29a")
  local function layer(n) c.curLayer = n end
  layer("wall")
  for y = 3, 39 do for x = 0, W - 1 do c:put(x, y, (y > 33 and "#e4cc9c") or ((y < 5) and WALL.b) or ((y % 12 == 0 and false) and WALL.b) or WALL.m, "wall", true) end end
  for x = 0, W - 1 do if x % 24 == 0 then for y = 5, 32 do c:put(x, y, WALL.b, "wall", true) end end end
  for x = 0, W - 1 do c:put(x, 33, WALL.b, "wall", true) c:put(x, 34, "#e4cc9c", "wall", true) c:put(x, 39, FLOOR.s, "wall", true) end
  for y = 3, 5 do for x = 0, W - 1 do c:put(x, y, WALL.l, "wall", true) end end
  -- faint paw prints on the wall
  for _, p in ipairs({ { 8, 24 }, { 30, 16 }, { 66, 28 }, { 156, 14 }, { 186, 26 }, { 214, 18 }, { 232, 30 } }) do
    for _, d in ipairs({ { 0, 1 }, { 1, 1 }, { -1, 1 }, { 0, 2 }, { 1, 2 }, { -1, 2 }, { 0, 3 }, { -2, 0 }, { 2, 0 }, { -1, -1 }, { 1, -1 } }) do end
    local q = { { 0, 1 }, { 1, 1 }, { -1, 1 }, { 0, 2 }, { -1, -1 }, { 1, -1 }, { -2, 0 }, { 2, 0 } }
    for _, d in ipairs(q) do c:put(p[1] + d[1], p[2] + d[2], WALL.b, "wall", true) end
  end
  -- floor planks
  for y = 40, 56 do for x = 0, W - 1 do
    local row = (y - 40) // 5
    local seam = ((x + row * 23) % 46 == 0) or ((y - 40) % 5 == 4)
    c:put(x, y, seam and FLOOR.s or ((y - 40) % 5 == 0 and FLOOR.l or ((x * 7 + row * 13) % 11 == 0 and FLOOR.b or FLOOR.m)), "floor", true)
  end end
  -- borders (ink + wood, gold studs)
  for x = 0, W - 1 do
    c:put(x, 0, '#', "border", true) c:put(x, 1, WOOD.s, "border", true) c:put(x, 2, WOOD.m, "border", true)
    c:put(x, 57, WOOD.m, "border", true) c:put(x, 58, WOOD.s, "border", true) c:put(x, 59, '#', "border", true)
    if x % 6 == 2 then c:put(x, 1, GOLD.l, "border", true) c:put(x, 58, GOLD.l, "border", true) end
  end
  for y = 0, 59 do c:put(0, y, '#', "border", true) c:put(W - 1, y, '#', "border", true) end
  -- props -----------------------------------------------------------------------------------------------------
  local function shadow(cx, cy, rx) L.ellipse(cx, cy, rx, 2):each(function(x, y) if y >= 41 and y <= 56 then c:put(x, y, FLOOR.b, "shadow", true) end end) end
  layer("picture")
  do   -- framed fish picture
    line(c, { { 31, 4 }, { 24, 9 } }, "#6a4128") line(c, { { 31, 4 }, { 38, 9 } }, "#6a4128")
    local fr = H.rrect(19, 8, 43, 27, 1) part(c, fr, GOLD, 1, 1)
    local inn = H.rrect(21, 10, 41, 25, 0) part(c, inn, CREAM, 1, 1, { lift = 1 })
    sep(c, inn)
    local fb = L.ellipse(30, 18, 6, 3.6) part(c, fb, ORANGE, 1, 1)
    local ft = L.poly({ { 35, 18 }, { 40, 14 }, { 40, 22 } }) part(c, ft, ORANGE, 1, 1, { lift = -1 })
    px(c, { { 26, 17, '#' }, { 27, 17, ORANGE.g } })
    c.obj:each(function() end)
    L.rect(19, 8, 43, 27):grow(1):cut(L.rect(19, 8, 43, 27)):each(function(x, y) c:put(x, y, '#', "ink") end)
  end
  layer("pouf")
  do
    shadow(34, 50, 24)
    local side = H.rrect(11, 38, 56, 49, 3) part(c, side, PINK, 3, 2, { lift = -1 })
    for x = 14, 52, 5 do line(c, { { x, 41 }, { x, 47 } }, PINK.s) end
    local top = L.ellipse(33.5, 38, 22.5, 6.2) part(c, top, PINK, 2, 2, { lift = 1 })
    local bt = L.ellipse(33, 38, 2, 1.5) part(c, bt, GOLD, 1, 1)
    for x = 16, 50 do if x % 4 < 2 then c:put(x, 38 + floor(abs(x - 33) ^ 2 / 90 + 0.5) - 3 + 4, GOLD.m, "detail") end end
    local all = side:copy():add(top) sep(c, top)
    all:grow(1):cut(all):each(function(x, y) c:put(x, y, '#', "ink") end)
  end
  layer("rug")
  do   -- wall rug on a gold rod
    local rod = H.rrect(74, 9, 138, 13, 1) part(c, rod, WOOD, 1, 1)
    for _, x in ipairs({ 73, 139 }) do local k = L.ellipse(x, 11, 2.6, 2.6) part(c, k, GOLD, 1, 1) sep(c, k) end
    local rg = L.poly({ { 77, 14 }, { 135, 14 }, { 135, 33 }, { 128, 36 }, { 120, 33 }, { 108, 36 }, { 96, 33 }, { 86, 36 }, { 77, 33 } })
    part(c, rg, RED, 2, 2) sep(c, rg)
    for x = 79, 133 do if x % 4 < 2 then c:put(x, 16, GOLD.l, "detail") end end
    for x = 79, 133 do if x % 4 < 2 then c:put(x, 31, GOLD.m, "detail") end end
    local pad = L.ellipse(106, 27, 7, 4.4) part(c, pad, CREAM, 1, 1)
    for _, t in ipairs({ { 96, 21 }, { 102, 18 }, { 110, 18 }, { 116, 21 } }) do part(c, L.ellipse(t[1], t[2], 2.6, 2.8), CREAM, 1, 1) end
    L.line({ { 76, 11 }, { 75, 4 } }):each(function() end)
    line(c, { { 82, 9 }, { 98, 3 } }, "#6a4128") line(c, { { 130, 9 }, { 114, 3 } }, "#6a4128")
    L.rect(73, 8, 139, 13):grow(1):cut(L.rect(73, 8, 139, 13)):each(function(x, y) if y >= 8 and y <= 14 and (x < 71 or x > 141 or y == 8 or y == 14) then c:put(x, y, '#', "ink") end end)
  end
  layer("yarn")
  do
    shadow(66, 53, 8)
    S.ball(c, 66, 49, 6.5, RED, { ph = 0.5 }) sep(c, L.ellipse(66, 49, 6.5, 6.5))
    local th = L.tube({ { 61, 53 }, { 56, 55 }, { 51, 54 } }, function() return 0.7 end) part(c, th, RED, 1, 1)
    L.ellipse(66, 49, 6.5, 6.5):grow(1):each(function(x, y) if not L.ellipse(66, 49, 6.5, 6.5):has(x, y) and not c:get(x, y) then end end)
  end
  layer("cat")
  do
    shadow(161, 54, 15)
    local tail = L.tube({ { 168, 52 }, { 177, 50 }, { 178, 42 } }, function() return 1.8 end) part(c, tail, nil, 1, 1) sep(c, tail)
    S.cat(c, 160, 34, nil, { hw = 8.5, hh = 7, big = true })
    for _, p in ipairs({ { 156, 31 }, { 157, 31 }, { 163, 31 }, { 164, 31 } }) do end
    local fl = L.ellipse(160, 52, 7, 2.5) part(c, fl, nil, 1, 1)
    px(c, { { 154, 53, S.CAT.L }, { 155, 53, S.CAT.L }, { 165, 53, S.CAT.L }, { 166, 53, S.CAT.L } })
    -- gold collar
    for x = 155, 165 do c:put(x, 43, GOLD.m, "detail") end c:put(160, 44, GOLD.l, "detail")
  end
  layer("fish")
  do
    shadow(208, 53, 10)
    local ft = L.poly({ { 213, 50 }, { 220, 46 }, { 220, 55 } }) part(c, ft, GOLD, 1, 1, { lift = -1 }) sep(c, ft)
    local fb = L.ellipse(205, 50, 8, 4.4) part(c, fb, GOLD, 2, 2) sep(c, fb)
    px(c, { { 199, 49, '#' }, { 200, 49, GOLD.g }, { 205, 47, GOLD.g }, { 206, 47, GOLD.g }, { 203, 52, GOLD.s }, { 206, 51, GOLD.s } })
  end
  -- ink pass for everything with c.obj (cat, yarn, fish)
  -- (props with their own ink rings were drawn above)
  local ring = L.mask()
  c.obj:each(function(x, y)
    for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
      local q = L.K(x + d[1], y + d[2])
    end
  end)
  -- double to 480x120
  local big = L.canvas(480, 120, true)
  for k, t in pairs(c.t) do
    local x, y = L.XY(k)
    for dy = 0, 1 do for dx = 0, 1 do big:put(x * 2 + dx, y * 2 + dy, t, c.ly[k], true) end end
  end
  big:save(H.OUT, "cf-banner") print("cf-banner", big:colours())
end
