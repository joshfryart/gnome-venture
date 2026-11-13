-- icons.lua: 16 upgrade icons 64x64, Hearth Pop (1px ink, 5-6 tone ramps, upper-left light, one quirk each)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(DIR .. "/h3.lua")
local L, R, part, px, sep, leaf, rrect, arcline, star4 = H.L, H.R, H.part, H.px, H.sep, H.leaf, H.rrect, H.arcline, H.star4
local PINK, GREEN, SISAL, CREAM, TERRA, GOLD, WOOD, GREY, BLUE, PLUM, ORANGE, RED, BROWN, STEEL, VIOLET =
  H.PINK, H.GREEN, H.SISAL, H.CREAM, H.TERRA, H.GOLD, H.WOOD, H.GREY, H.BLUE, H.PLUM, H.ORANGE, H.RED, H.BROWN, H.STEEL, H.VIOLET
local floor, sin, cos, sqrt, abs, pi, min, max = math.floor, math.sin, math.cos, math.sqrt, math.abs, math.pi, math.min, math.max
local N = H.new
local function eye(c, x, y, ring)
  local rows = { ".rr.", "rc#r", "r##r", ".rr." }
  for j, row in ipairs(rows) do for i = 1, 4 do local ch = row:sub(i, i)
    if ch == 'r' then c:put(x + i - 1, y + j - 1, ring, "detail") elseif ch == 'c' then c:put(x + i - 1, y + j - 1, "#fff4d6", "detail") elseif ch == '#' then c:put(x + i - 1, y + j - 1, '#', "detail") end
  end end
end
local function lineIn(c, m, pts, col) L.line(pts):each(function(x, y) if m:has(x, y) then c:put(x, y, col, "detail") end end) end
local function stitch(c, m, col, mod)   -- dashed stitch line 1px inside the edge
  local inner = m:copy():cut(m:edge())
  inner:edge():each(function(x, y) if (x + y) % (mod or 4) < 2 then c:put(x, y, col, "detail") end end)
end

-- 1 FISH: orange perch, scallop scales, forked tail; quirk: bubbles leaving its mouth --------------------
do
  local c = N()
  local tail = L.poly({ { 40, 33 }, { 57, 19 }, { 52, 33 }, { 57, 47 } })
  part(c, tail, ORANGE, 1, 1, { lift = -1 })
  local dors = L.poly({ { 20, 26 }, { 28, 14 }, { 38, 25 } }) part(c, dors, ORANGE, 1, 1, { lift = -1 })
  local pelv = L.poly({ { 24, 41 }, { 31, 52 }, { 37, 42 } }) part(c, pelv, ORANGE, 1, 1, { lift = -1 })
  for _, t in ipairs({ { 56, 21 }, { 53, 33 }, { 56, 45 } }) do lineIn(c, tail, { { 42, 33 }, t }, ORANGE.D) end
  lineIn(c, dors, { { 28, 25 }, { 28, 16 } }, ORANGE.D) lineIn(c, dors, { { 24, 25 }, { 26, 19 } }, ORANGE.D) lineIn(c, dors, { { 33, 25 }, { 31, 18 } }, ORANGE.D)
  local body = L.ellipse(28, 33, 15.5, 11.5)
  part(c, body, ORANGE, 4, 3)
  sep(c, body)
  for _, ry in ipairs({ 27, 32, 37 }) do
    for sx = 25 + ((ry % 2) * 3), 42, 6 do
      local x = sx
      if body:has(x + 2, ry) and body:has(x, ry) and body:has(x + 1, ry + 2) then
        c:put(x, ry, ORANGE.s, "detail") c:put(x + 1, ry + 1, ORANGE.s, "detail") c:put(x + 2, ry, ORANGE.s, "detail")
        c:put(x + 1, ry, ORANGE.L, "detail")
      end
    end
  end
  for _, p in ipairs({ { 22, 27 }, { 23, 28 }, { 24, 30 }, { 24, 33 }, { 24, 36 }, { 23, 38 }, { 22, 39 } }) do c:put(p[1], p[2], ORANGE.D, "detail") end
  eye(c, 15, 28, "#fff4d6")
  px(c, { { 13, 34, '#' }, { 14, 35, '#' }, { 18, 25, ORANGE.g }, { 19, 24, ORANGE.g } })
  for _, b in ipairs({ { 9, 30, 2.3 }, { 6, 23, 1.8 }, { 9, 16, 1.4 } }) do
    local m = L.ellipse(b[1], b[2], b[3], b[3]) part(c, m, BLUE, 1, 1, { lift = 2 }) c:put(floor(b[1] - 0.7), floor(b[2] - 0.7), "#ffffff", "detail")
  end
  H.finish(c, "cf-up-fish")
end

-- 2 SILK: pink silk bow with a V-cut tail; quirk: a little brass bell on the knot ----------------------------
do
  local c = N()
  local lt = L.poly({ { 27, 37 }, { 33, 37 }, { 26, 58 }, { 21, 52 }, { 14, 57 } }) part(c, lt, PINK, 1, 1, { lift = -1 })
  local rt = L.poly({ { 31, 37 }, { 37, 37 }, { 51, 58 }, { 44, 52 }, { 38, 57 } }) part(c, rt, PINK, 1, 1, { lift = -1 })
  local ll = L.poly({ { 30, 31 }, { 17, 16 }, { 7, 21 }, { 7, 37 }, { 17, 44 }, { 30, 35 } })
  local rl = L.poly({ { 34, 31 }, { 47, 16 }, { 57, 21 }, { 57, 37 }, { 47, 44 }, { 34, 35 } })
  part(c, ll, PINK, 2, 3) part(c, rl, PINK, 2, 3)
  stitch(c, ll, PINK.L) stitch(c, rl, PINK.s)
  lineIn(c, ll, { { 29, 32 }, { 14, 24 } }, PINK.s) lineIn(c, ll, { { 29, 34 }, { 11, 33 } }, PINK.s)
  lineIn(c, rl, { { 35, 32 }, { 50, 24 } }, PINK.s) lineIn(c, rl, { { 35, 34 }, { 53, 33 } }, PINK.s)
  lineIn(c, lt, { { 29, 40 }, { 24, 54 } }, PINK.s) lineIn(c, rt, { { 34, 40 }, { 44, 54 } }, PINK.s)
  sep(c, ll) sep(c, rl)
  local knot = rrect(28, 28, 35, 38, 2) part(c, knot, PINK, 2, 2, { lift = 1 }) sep(c, knot)
  px(c, { { 29, 29, PINK.g }, { 30, 29, PINK.L }, { 29, 31, PINK.L } })
  local bell = L.ellipse(32, 44, 3.6, 3.6) part(c, bell, GOLD, 2, 2) sep(c, bell)
  px(c, { { 30, 42, GOLD.g }, { 31, 41, GOLD.g }, { 32, 47, GOLD.D }, { 33, 47, GOLD.D }, { 32, 44, GOLD.D }, { 31, 44, GOLD.D } })
  px(c, { { 17, 20, PINK.g }, { 18, 20, PINK.L }, { 10, 24, PINK.L } })
  H.finish(c, "cf-up-silk")
end

-- 3 CATNIP: sprig with veined leaves and a violet bud; quirk: a ladybird on a leaf ---------------------------
do
  local c = N()
  local stem = L.tube({ { 32, 58 }, { 31, 46 }, { 33, 34 }, { 32, 24 } }, function() return 1.5 end)
  part(c, stem, GREEN, 1, 1)
  local function lf(pts, w, lift)
    local m = leaf(pts, w) part(c, m, GREEN, 2, 2, { lift = lift or 0 }) sep(c, m)
    local rib = L.line({ pts[1], pts[2], pts[3] })
    rib:each(function(x, y) if m:has(x, y) then c:put(x, y, GREEN.L, "detail") end end)
    -- veins
    local p0, p1, p2 = pts[1], pts[2], pts[3]
    for k = 1, 3 do
      local t = k / 4
      local bx, by = p0[1] + (p2[1] - p0[1]) * t, p0[2] + (p2[2] - p0[2]) * t
      local dir = (p2[2] < p0[2]) and 1 or -1
      for s = -1, 1, 2 do for d = 1, 2 do
        local vx, vy = floor(bx + 0.5 + (p2[1] > p0[1] and d or -d)), floor(by + 0.5 + s * d)
        if m:has(vx, vy) then c:put(vx, vy, GREEN.s, "detail") end
      end end
    end
    return m
  end
  lf({ { 31, 51 }, { 21, 47 }, { 8, 49 } }, 5, -1) lf({ { 32, 49 }, { 43, 43 }, { 56, 44 } }, 5)
  lf({ { 32, 39 }, { 24, 33 }, { 13, 31 } }, 4.4, 0) lf({ { 33, 37 }, { 42, 31 }, { 52, 28 } }, 4.4, 1)
  -- violet bud spike
  local buds = { { 32, 23, 3.8, 3.2 }, { 29, 18, 3.4, 3 }, { 35, 18, 3.4, 3 }, { 32, 13, 3.2, 3.2 }, { 32, 18, 2.6, 2.6 } }
  for _, b in ipairs(buds) do local m = L.ellipse(b[1], b[2], b[3], b[4]) part(c, m, VIOLET, 1, 1) px(c, { { b[1] - 1, floor(b[2] - 1), VIOLET.g } }) sep(c, m) end
  -- ladybird on the right lower leaf
  local lb = L.ellipse(44, 44, 3.2, 2.6) part(c, lb, RED, 1, 1)
  px(c, { { 41, 44, '#' }, { 42, 44, '#' }, { 44, 42, '#' }, { 43, 44, '#' }, { 46, 43, '#' }, { 45, 46, '#' }, { 43, 42, RED.g } })
  H.finish(c, "cf-up-catnip")
end

-- 4 GLITTER: slim blue fish with diamond scales, violet crest; quirk: sparkle trail ------------------------------
do
  local c = N()
  local tail = L.poly({ { 18, 34 }, { 4, 19 }, { 9, 34 }, { 4, 49 } }) part(c, tail, BLUE, 1, 1, { lift = -1 })
  lineIn(c, tail, { { 16, 34 }, { 6, 21 } }, BLUE.D) lineIn(c, tail, { { 16, 34 }, { 6, 47 } }, BLUE.D)
  local crest = L.poly({ { 20, 28 }, { 22, 15 }, { 27, 25 }, { 31, 12 }, { 35, 25 }, { 40, 16 }, { 41, 29 } }) part(c, crest, VIOLET, 1, 1)
  local body = L.ellipse(31, 35, 15, 10.4)
  part(c, body, BLUE, 4, 3) sep(c, body)
  for k = -3, 3 do
    for t = -9, 9 do
      local x1, y1 = 31 + k * 5 + t, 35 + t
      local x2, y2 = 31 + k * 5 + t, 35 - t
      if body:has(x1, y1) and x1 > 22 and (k + t) % 2 == 0 then c:put(x1, y1, BLUE.s, "detail") end
      if body:has(x2, y2) and x2 > 22 and (k + t) % 2 == 0 then c:put(x2, y2, BLUE.l, "detail") end
    end
  end
  local fin = L.poly({ { 30, 42 }, { 36, 52 }, { 40, 41 } }) part(c, fin, VIOLET, 1, 1) sep(c, body)
  eye(c, 38, 30, "#fff4d6")
  px(c, { { 45, 37, '#' }, { 44, 38, '#' }, { 27, 28, BLUE.g }, { 28, 27, BLUE.g } })
  for _, s in ipairs({ { 51, 12, 5 }, { 13, 11, 3 }, { 54, 47, 3 }, { 8, 52, 2 } }) do star4(c, s[1], s[2], s[3], GOLD.m, "#ffffff") end
  px(c, { { 47, 20, GOLD.l }, { 48, 24, GOLD.m }, { 20, 8, GOLD.l } })
  H.finish(c, "cf-up-glitter")
end

-- 5 STRING: wound spool of blue thread; quirk: loose thread curl ending in a gold bead --------------------------
do
  local c = N()
  local core = L.rect(20, 17, 43, 47)
  part(c, core, BLUE, 4, 4)
  core:each(function(x, y) if y % 4 == 0 then c:put(x, y, BLUE.s, "detail") elseif y % 4 == 2 and x < 36 then c:put(x, y, BLUE.l, "detail") end end)
  -- diagonal wrap strands
  for y = 18, 46, 4 do for x = 20, 43 do local yy = y + floor((x - 20) / 6) if core:has(x, yy) and (x % 3 ~= 0) then c:put(x, yy, BLUE.L, "detail") end end end
  local ft = rrect(15, 9, 48, 17, 3) part(c, ft, WOOD, 2, 2) sep(c, ft)
  for x = 17, 46, 5 do c:put(x, 12, WOOD.s, "detail") c:put(x + 1, 12, WOOD.s, "detail") c:put(x + 2, 14, WOOD.l, "detail") end
  local fb = rrect(15, 47, 48, 55, 3) part(c, fb, WOOD, 2, 2) sep(c, fb)
  for x = 17, 46, 6 do c:put(x, 50, WOOD.s, "detail") c:put(x + 1, 50, WOOD.s, "detail") c:put(x + 3, 53, WOOD.l, "detail") end
  local th = L.tube({ { 43, 36 }, { 51, 35 }, { 56, 41 }, { 54, 48 }, { 50, 50 } }, function() return 1.1 end)
  part(c, th, BLUE, 1, 1, { lift = 1 }) sep(c, th)
  local bead = L.ellipse(50, 51, 2.6, 2.6) part(c, bead, GOLD, 1, 1) px(c, { { 49, 50, GOLD.g } })
  H.finish(c, "cf-up-string")
end

-- 6 SPRING: violet coil on a red pad, gold pom; quirk: boing ticks -------------------------------------------
do
  local c = N()
  local baseM = L.ellipse(32, 52, 12.4, 5) part(c, baseM, RED, 3, 3)
  L.ellipse(32, 50, 8, 2.6):each(function(x, y) c:put(x, y, RED.L, "detail") end)
  for k = 0, 4 do
    local cy = 20 + k * 6
    local back = L.tube(arcline(32, cy, 13, 4.6, pi, 2 * pi, 10), function() return 1.2 end)
    part(c, back, VIOLET, 1, 1, { lift = -2 })
  end
  for k = 0, 4 do
    local cy = 20 + k * 6
    local front = L.tube(arcline(32, cy, 13.4, 4.8, 0, pi, 12), function() return 2.3 end)
    part(c, front, VIOLET, 2, 2) sep(c, front)
    px(c, { { 24, cy + 4, VIOLET.g }, { 25, cy + 4, VIOLET.L }, { 26, cy + 4, VIOLET.L } })
  end
  local stem = L.rect(31, 11, 33, 16) part(c, stem, STEEL, 1, 1)
  local pom = L.ellipse(32, 9, 4.8, 4.8) part(c, pom, GOLD, 2, 2) px(c, { { 30, 7, GOLD.g }, { 31, 6, GOLD.L } })
  sep(c, pom)
  -- boing ticks
  for _, t in ipairs({ { { 42, 6 }, { 46, 3 } }, { { 44, 10 }, { 49, 10 } }, { { 22, 6 }, { 18, 3 } }, { { 20, 10 }, { 15, 10 } } }) do
    L.line(t):each(function(x, y) c:put(x, y, GOLD.m, "detail") end)
  end
  H.finish(c, "cf-up-spring")
end

-- 7 MOTOR: steel gear with a red hub driving a wand; quirk: a spark bolt ----------------------------------------
do
  local c = N()
  local gx, gy = 25, 38
  local gear = L.mask()
  for y = gy - 15, gy + 15 do for x = gx - 15, gx + 15 do
    local dx, dy = x - gx, y - gy
    local r = sqrt(dx * dx + dy * dy)
    local th = math.atan(dy, dx) + pi
    local tooth = (floor(th / (2 * pi) * 16)) % 2 == 0
    if r <= 10.6 or (r <= 14.4 and tooth and r > 9) then gear:set(x, y) end
  end end
  part(c, gear, STEEL, 3, 3) sep(c, gear)
  L.ellipse(gx, gy, 8, 8):each(function(x, y) if gear:has(x, y) and sqrt((x - gx) ^ 2 + (y - gy) ^ 2) > 7 then c:put(x, y, STEEL.s, "detail") end end)
  for _, a in ipairs({ 0.7, 2.3, 3.9, 5.5 }) do c:put(floor(gx + 8.6 * cos(a)), floor(gy + 8.6 * sin(a)), STEEL.g, "detail") end
  local hub = L.ellipse(gx, gy, 5.6, 5.6) part(c, hub, RED, 2, 2) sep(c, hub)
  local bolt = L.ellipse(gx, gy, 2, 2) part(c, bolt, STEEL, 1, 1)
  px(c, { { gx - 3, gy - 3, RED.g }, { gx - 2, gy - 4, RED.L } })
  local arm = L.tube({ { gx, gy }, { 40, 24 }, { 52, 13 } }, function() return 1.5 end)
  part(c, arm, WOOD, 1, 1) sep(c, arm)
  local tip = L.ellipse(53, 11, 4, 4) part(c, tip, GOLD, 2, 2) px(c, { { 51, 9, GOLD.g }, { 52, 8, GOLD.L } }) sep(c, tip)
  local bolt2 = L.poly({ { 51, 35 }, { 58, 35 }, { 54, 42 }, { 59, 42 }, { 47, 56 }, { 50, 46 }, { 45, 46 } })
  part(c, bolt2, GOLD, 1, 1) px(c, { { 52, 36, GOLD.g }, { 53, 36, GOLD.g } }) sep(c, bolt2)
  H.finish(c, "cf-up-motor")
end

-- 8 DOUBLE: two crossed wands tied with a blue bow; quirk: one tip is a pompom, one a bell ----------------------
do
  local c = N()
  local function wand(a, b, tipKind)
    local sh = L.tube({ a, b }, function() return 1.5 end)
    part(c, sh, WOOD, 1, 1) sep(c, sh)
    local dx, dy = b[1] - a[1], b[2] - a[2]
    local g = L.tube({ a, { a[1] + dx * 0.34, a[2] + dy * 0.34 } }, function() return 2.8 end)
    part(c, g, RED, 2, 2) sep(c, g)
    for i = 1, 4 do local t = 0.05 + i * 0.07 local x, y = a[1] + dx * t, a[2] + dy * t
      for d = -3, 3 do local px_, py_ = floor(x + d * 0.7 + 0.5), floor(y + d * 0.7 * (dx / dy) * -1 * (-1) + 0.5)
        if g:has(px_, py_) and i % 2 == 0 then c:put(px_, py_, RED.l, "detail") end end end
    local tp = L.ellipse(b[1], b[2], 4, 4)
    if tipKind == 1 then part(c, tp, GOLD, 2, 2) px(c, { { b[1] - 2, b[2] - 2, GOLD.g } }) else part(c, tp, PINK, 2, 2) px(c, { { b[1] - 2, b[2] - 2, PINK.g }, { b[1] - 1, b[2] - 3, PINK.L }, { b[1] + 1, b[2], PINK.s } }) end
    sep(c, tp)
  end
  wand({ 9, 55 }, { 52, 11 }, 1) wand({ 55, 55 }, { 12, 11 }, 2)
  local ll = L.poly({ { 31, 33 }, { 21, 26 }, { 18, 33 }, { 21, 40 } })
  local rl = L.poly({ { 33, 33 }, { 43, 26 }, { 46, 33 }, { 43, 40 } })
  part(c, ll, BLUE, 1, 2) part(c, rl, BLUE, 1, 2) sep(c, ll) sep(c, rl)
  local knot = rrect(29, 29, 34, 36, 2) part(c, knot, BLUE, 1, 1, { lift = -1 }) sep(c, knot)
  px(c, { { 22, 29, BLUE.L }, { 24, 28, BLUE.g }, { 41, 29, BLUE.L }, { 30, 30, BLUE.g } })
  H.finish(c, "cf-up-double")
end

-- 9 SUNBEAM: window light falling on boards; quirk: dust motes ----------------------------------------------------
do
  local c = N()
  local FL = R("#6e3f2a", "#9a5a36", "#c9803f", "#e0a058", "#f2c07a", "#fff0c0")
  local flo = L.poly({ { 6, 37 }, { 58, 37 }, { 62, 56 }, { 2, 56 } })
  part(c, flo, FL, 3, 2)
  for _, y in ipairs({ 43, 49 }) do for x = 2, 62 do if flo:has(x, y) then c:put(x, y, FL.D, "detail") if flo:has(x, y + 1) then c:put(x, y + 1, FL.L, "detail") end end end end
  for _, p in ipairs({ { 20, 38, 43 }, { 40, 38, 43 }, { 12, 44, 49 }, { 32, 44, 49 }, { 52, 44, 49 }, { 22, 50, 56 }, { 44, 50, 56 } }) do for y = p[2] + 1, p[3] - 1 do if flo:has(p[1], y) then c:put(p[1], y, FL.D, "detail") end end end
  local beam = L.poly({ { 12, 20 }, { 30, 6 }, { 54, 37 }, { 26, 37 } })
  part(c, beam, GOLD, 0, 3, { lift = 1 })
  beam:each(function(x, y) c:put(x, y, ((x + y) % 7 < 3) and "#fff0c0" or "#ffe38a", "light") end)
  local pool = L.poly({ { 26, 38 }, { 54, 38 }, { 60, 52 }, { 32, 52 } })
  pool:each(function(x, y) c:put(x, y, "#ffe38a", "light") end)
  for y = 38, 52 do local xm = 40 + (y - 38) * 0.4 c:put(floor(xm), y, FL.m, "detail") c:put(floor(xm) + 1, y, FL.m, "detail") end
  for x = 28, 58 do c:put(x + floor((x - 28) * 0.0), 45, FL.m, "detail") end
  local sun = L.ellipse(14, 14, 6.2, 6.2) part(c, sun, GOLD, 2, 2) px(c, { { 12, 12, GOLD.g }, { 13, 11, GOLD.g } }) sep(c, sun)
  for a = 0, 7 do
    local ang = a * pi / 4 + 0.2
    local r0, r1 = 8.8, 11.4
    L.line({ { floor(14 + r0 * cos(ang) + 0.5), floor(14 + r0 * sin(ang) + 0.5) }, { floor(14 + r1 * cos(ang) + 0.5), floor(14 + r1 * sin(ang) + 0.5) } }):each(function(x, y) c:put(x, y, GOLD.m, "detail") end)
  end
  for _, p in ipairs({ { 31, 22 }, { 38, 28 }, { 28, 30 }, { 44, 33 }, { 36, 18 } }) do c:put(p[1], p[2], "#ffffff", "detail") end
  H.finish(c, "cf-up-sunbeam")
end

-- 10 RUG: braided oval rug; quirk: one curled-up corner -----------------------------------------------------------
do
  local c = N()
  local cx, cy, rx, ry = 31.5, 36, 26, 15.4
  local m = L.ellipse(cx, cy, rx, ry)
  local chev = { TERRA, CREAM, GOLD }
  m:each(function(x, y)
    local dx, dy = (x - cx) / rx, (y - cy) / ry
    local r = sqrt(dx * dx + dy * dy)
    local t
    if r > 0.78 then
      local th = math.atan(dy, dx)
      local seg = floor((th + pi) / (2 * pi) * 40)
      local rp = chev[seg % 3 + 1]
      local key = 'm'
      if r > 0.9 then key = (dy > 0.1) and 's' or 'l' elseif r < 0.83 then key = (dy > 0) and 'b' or 'l' end
      t = rp[key]
    elseif r > 0.64 then
      t = (r > 0.7) and CREAM.m or CREAM.b
      if dy < -0.3 and r < 0.7 then t = CREAM.l end
    else
      local key = 'm'
      if y % 3 == 0 then key = 'b' elseif y % 6 == 1 then key = 'l' end
      t = GREEN[key]
      if r > 0.36 and r < 0.43 then t = CREAM.m end
      if r < 0.16 then t = TERRA.m end
    end
    c:put(x, y, t, "detail")
  end)
  m:each(function(x, y) local dx, dy = (x - cx) / rx, (y - cy) / ry if sqrt(dx * dx + dy * dy) > 0.93 and dy > 0.45 then c:put(x, y, TERRA.D, "detail") end end)
  -- curled corner (lower right): the underside rolled up
  local flap = L.poly({ { 47, 41 }, { 55, 38 }, { 58, 43 }, { 54, 50 }, { 47, 49 } })
  part(c, flap, CREAM, 2, 2, { lift = -1 })
  local roll = L.ellipse(52, 46, 4.4, 3.2) part(c, roll, CREAM, 1, 1, { lift = 1 })
  px(c, { { 50, 45, CREAM.g }, { 51, 44, CREAM.g }, { 55, 47, CREAM.D }, { 54, 48, CREAM.D }, { 53, 50, TERRA.s } })
  sep(c, flap)
  H.finish(c, "cf-up-rug")
end

-- 11 SCRATCH: sisal post, carpet perch and base; quirk: frayed tuft and claw marks ------------------------------------
do
  local c = N()
  local slab = rrect(12, 46, 52, 56, 3) part(c, slab, GREEN, 3, 2)
  for x = 15, 49, 4 do c:put(x, 49, GREEN.l, "detail") end
  local post = L.rect(25, 18, 39, 47) part(c, post, SISAL, 3, 2)
  post:each(function(x, y) local v = (x + y * 2) % 6 if v == 0 then c:put(x, y, SISAL.b, "detail") elseif v == 1 and x < 32 then c:put(x, y, SISAL.L, "detail") end end)
  sep(c, post)
  for _, p in ipairs({ { 28, 28 }, { 29, 30 }, { 30, 32 }, { 33, 38 }, { 34, 40 } }) do c:put(p[1], p[2], SISAL.D, "detail") end
  local perch = rrect(13, 8, 51, 20, 4) part(c, perch, GREEN, 3, 3) sep(c, perch)
  for x = 17, 47, 3 do c:put(x, 11 + (x % 2) * 2, GREEN.L, "detail") end
  local rope = L.line({ { 46, 21 }, { 46, 30 } }) rope:each(function(x, y) c:put(x, y, SISAL.m, "detail") end)
  local pom = L.ellipse(46.5, 34, 4, 4) part(c, pom, PINK, 2, 2) px(c, { { 44, 32, PINK.g }, { 45, 31, PINK.L } }) sep(c, pom)
  for _, p in ipairs({ { 40, 30 }, { 41, 29 }, { 42, 28 }, { 41, 31 }, { 42, 32 }, { 43, 33 } }) do c:put(p[1], p[2], SISAL.l, "detail") end
  H.finish(c, "cf-up-scratch")
end

-- 12 WINDOW: green sash window with sill; quirk: a robin visiting a pane ------------------------------------------------
do
  local c = N()
  local fr = rrect(10, 6, 53, 49, 3) part(c, fr, GREEN, 2, 2)
  local panes = { { 15, 11, 30, 26 }, { 34, 11, 48, 26 }, { 15, 30, 30, 44 }, { 34, 30, 48, 44 } }
  for pi_, p in ipairs(panes) do
    local pm = L.rect(p[1], p[2], p[3], p[4])
    pm:each(function(x, y) local t = (y - p[2]) / (p[4] - p[2]) c:put(x, y, (t < 0.4) and "#7cc0f0" or ((t < 0.75) and "#a4d8f8" or "#c0e6fa"), "detail") end)
    for x = p[1], p[3] do c:put(x, p[2], "#3a6a98", "detail") end for y = p[2], p[4] do c:put(p[1], y, "#5a88b8", "detail") end
    for t = 0, 3 do c:put(p[1] + 3 + t, p[2] + 7 - t, "#ffffff", "detail") end
    sep(c, pm)
  end
  px(c, { { 20, 13, "#fff8e8" }, { 21, 13, "#fff8e8" }, { 22, 13, "#fff8e8" }, { 21, 12, "#fff8e8" } })
  -- robin in the lower right pane
  local bd = L.ellipse(41, 38, 5.4, 4.2) part(c, bd, BROWN, 1, 1)
  local br = L.ellipse(43, 39, 3.2, 2.9) part(c, br, ORANGE, 1, 1, { lift = -1 })
  local hd = L.ellipse(44, 34, 3, 2.8) part(c, hd, BROWN, 1, 1)
  local tl = L.poly({ { 37, 40 }, { 33, 44 }, { 38, 43 } }) part(c, tl, BROWN, 1, 1, { lift = -1 })
  px(c, { { 45, 33, '#' }, { 47, 35, GOLD.m }, { 48, 35, GOLD.m }, { 44, 33, BROWN.g }, { 40, 36, BROWN.L }, { 42, 42, GOLD.m }, { 44, 42, GOLD.m } })
  local sill = rrect(6, 49, 57, 57, 2) part(c, sill, WOOD, 3, 2) sep(c, sill)
  for x = 9, 54, 7 do c:put(x, 52, WOOD.s, "detail") c:put(x + 1, 52, WOOD.s, "detail") c:put(x + 3, 54, WOOD.L, "detail") end
  px(c, { { 12, 8, GREEN.g }, { 13, 8, GREEN.L } })
  H.finish(c, "cf-up-window")
end

-- 13 BOWL: pink bowl of kibble; quirk: a fish biscuit stuck in the heap ------------------------------------------------
do
  local c = N()
  local body = L.poly({ { 8, 33 }, { 56, 33 }, { 51, 49 }, { 44, 55 }, { 20, 55 }, { 13, 49 } }) part(c, body, PINK, 4, 4)
  local rim = L.ellipse(32, 33, 24.4, 7) part(c, rim, PINK, 2, 3, { lift = 1 })
  local hole = L.ellipse(32, 33.6, 20, 4.4) part(c, hole, PINK, 1, 1, { lift = -2 })
  sep(c, body)
  local fe = L.ellipse(29, 44, 6, 3.4) part(c, fe, CREAM, 1, 1)
  local ft = L.poly({ { 34, 44 }, { 40, 40 }, { 40, 48 } }) part(c, ft, CREAM, 1, 1)
  px(c, { { 24, 43, '#' }, { 26, 41, CREAM.g } })
  for x = 14, 50 do local t = c:get(x, 50) if t == PINK.s or t == PINK.m or t == PINK.b then c:put(x, 50, PINK.D, "detail") end end
  local ns = { { 22, 26, 5, 3.8 }, { 31, 22, 5.2, 4 }, { 40, 26, 5, 3.8 }, { 47, 29, 4, 3 }, { 15, 29, 4, 3 }, { 27, 30, 5, 3.4 }, { 37, 31, 5, 3.4 } }
  for _, n in ipairs(ns) do local m = L.ellipse(n[1], n[2], n[3], n[4]) part(c, m, BROWN, 1, 1) px(c, { { n[1] - 2, floor(n[2] - 1), BROWN.g }, { n[1] + 1, floor(n[2] + 1), BROWN.D } }) sep(c, m) end
  rim:each(function(x, y) if y >= 35 and not hole:has(x, y) then c:put(x, y, (y <= 36) and PINK.L or PINK.m, "detail") end end)
  local bis = L.ellipse(44, 17, 5, 3) part(c, bis, ORANGE, 1, 1)
  local bt = L.poly({ { 48, 17 }, { 53, 12 }, { 53, 21 } }) part(c, bt, ORANGE, 1, 1)
  px(c, { { 41, 16, '#' }, { 44, 15, ORANGE.g } }) sep(c, bis) sep(c, bt)
  H.finish(c, "cf-up-bowl")
end

-- 14 TOYBOX: nailed crate with toys; quirk: the mouse's tail dangles over the front -----------------------------------------
do
  local c = N()
  local wand = L.tube({ { 46, 28 }, { 53, 14 } }, function() return 1.1 end) part(c, wand, WOOD, 1, 1) sep(c, wand)
  local fea = L.ellipse(54, 10, 3.2, 5) part(c, fea, BLUE, 1, 1) px(c, { { 53, 7, BLUE.g } }) sep(c, fea)
  local yb = L.ellipse(21, 24, 8, 8) part(c, yb, PINK, 3, 3)
  for t = -7, 7 do local x, y = 21 + t, floor(24 + t * 0.5 + 0.5) if yb:has(x, y) then c:put(x, y, PINK.s, "detail") end if yb:has(x, y - 4) then c:put(x, y - 4, PINK.s, "detail") end end
  px(c, { { 16, 19, PINK.g }, { 17, 18, PINK.L } }) sep(c, yb)
  local mh = L.ellipse(36, 26, 6.4, 5.4) part(c, mh, GREY, 2, 2)
  local e1 = L.ellipse(31, 20, 3, 3) part(c, e1, PINK, 1, 1, { lift = -1 }) local e2 = L.ellipse(41, 20, 3, 3) part(c, e2, PINK, 1, 1, { lift = -1 })
  px(c, { { 33, 26, '#' }, { 39, 26, '#' }, { 36, 29, PINK.s }, { 34, 23, GREY.g }, { 35, 22, GREY.L } })
  sep(c, mh) sep(c, e1) sep(c, e2)
  local crate = rrect(7, 29, 57, 57, 3) part(c, crate, WOOD, 2, 3) sep(c, crate)
  for x = 8, 56 do c:put(x, 30, WOOD.g, "light") c:put(x, 31, WOOD.L, "light") c:put(x, 38, WOOD.D, "detail") c:put(x, 39, WOOD.l, "detail") c:put(x, 48, WOOD.D, "detail") c:put(x, 49, WOOD.l, "detail") end
  for _, p in ipairs({ { 14, 34 }, { 28, 35 }, { 44, 34 }, { 20, 43 }, { 40, 44 }, { 12, 52 }, { 33, 53 }, { 48, 52 } }) do for d = 0, 3 do c:put(p[1] + d, p[2], WOOD.s, "detail") end end
  for _, sx in ipairs({ 9, 53 }) do
    L.rect(sx, 31, sx + 3, 56):each(function(x, y) c:put(x, y, (x == sx) and STEEL.L or ((x == sx + 3) and STEEL.s or STEEL.m), "detail") end)
    for y = 34, 54, 10 do c:put(sx + 1, y, STEEL.g, "detail") c:put(sx + 2, y, STEEL.D, "detail") end
  end
  local heart = { "..##...##..", ".####.####.", ".#########.", "..#######..", "...#####...", "....###....", ".....#....." }
  for j, row in ipairs(heart) do for i = 1, #row do if row:sub(i, i) == '#' then c:put(26 + i - 1, 40 + j - 1, (j <= 2 and i < 6) and PINK.L or ((j > 4) and PINK.s or PINK.m), "detail") end end end
  local hm = L.mask() for j, row in ipairs(heart) do for i = 1, #row do if row:sub(i, i) == '#' then hm:set(26 + i - 1, 40 + j - 1) end end end
  sep(c, hm)
  local tail = L.tube({ { 41, 30 }, { 47, 33 }, { 49, 39 }, { 46, 45 } }, function() return 0.9 end) part(c, tail, PINK, 1, 1, { lift = -1 }) sep(c, tail)
  H.finish(c, "cf-up-toybox")
end

-- 15 CATTREE: pink platforms on sisal poles; quirk: a bell on a string ------------------------------------------------------
do
  local c = N()
  local function pole(y0, y1) local m = L.rect(28, y0, 36, y1) part(c, m, SISAL, 2, 2) m:each(function(x, y) local v = (x + y * 2) % 6 if v == 0 then c:put(x, y, SISAL.b, "detail") elseif v == 1 and x < 32 then c:put(x, y, SISAL.L, "detail") end end) sep(c, m) end
  pole(19, 32) pole(37, 52)
  local function plat(x0, y0, x1, y1) local m = rrect(x0, y0, x1, y1, 3) part(c, m, PINK, 3, 3) for x = x0 + 2, x1 - 2 do c:put(x, y0, PINK.g, "light") end for x = x0 + 4, x1 - 4, 5 do c:put(x, y0 + 3, PINK.l, "detail") end sep(c, m) end
  plat(7, 51, 57, 59) plat(12, 30, 52, 38)
  local bowl = L.ellipse(32, 14, 21.4, 8) part(c, bowl, PINK, 3, 3)
  local inner = L.ellipse(32, 12.4, 16.6, 5) part(c, inner, CREAM, 2, 2)
  for x = 20, 44, 4 do c:put(x, 13, CREAM.s, "detail") c:put(x + 1, 11, CREAM.L, "detail") end
  sep(c, bowl)
  local str = L.line({ { 15, 38 }, { 15, 45 } }) str:each(function(x, y) c:put(x, y, GOLD.s, "detail") end)
  local bell = L.ellipse(15, 48, 3.4, 3.4) part(c, bell, GOLD, 2, 2) px(c, { { 14, 47, GOLD.g }, { 15, 50, GOLD.D }, { 16, 50, GOLD.D } }) sep(c, bell)
  H.finish(c, "cf-up-cattree")
end

-- 16 CATFLAP: arched wooden frame, swing flap with paw; quirk: a fish tag on a pin ------------------------------------------
do
  local c = N()
  local function arch(x0, x1, ytop, ybot)
    local r = (x1 - x0 + 1) / 2
    local cx, cy = (x0 + x1) / 2, ytop + r
    local m = L.rect(x0, floor(cy), x1, ybot)
    L.ellipse(cx, cy, r, r):each(function(x, y) if y < floor(cy) then m:set(x, y) end end)
    return m
  end
  local outer = arch(8, 55, 5, 58) part(c, outer, WOOD, 3, 3)
  for y = 24, 57 do c:put(9, y, WOOD.L, "detail") end
  local inner = arch(14, 49, 11, 54) inner:each(function(x, y) c:put(x, y, "#2a1a28", "shade") end)
  L.rect(15, 49, 48, 54):each(function(x, y) if inner:has(x, y) then c:put(x, y, (y == 49) and GOLD.L or GOLD.m, "detail") end end)
  local flap = L.poly({ { 17, 15 }, { 47, 15 }, { 45, 48 }, { 19, 48 } }) part(c, flap, STEEL, 2, 2)
  for t = 0, 13 do c:put(22 + t, 41 - t, STEEL.g, "detail") end for t = 0, 7 do c:put(31 + t, 44 - t, STEEL.L, "detail") end
  for _, p in ipairs({ { 0, 1 }, { 2, 0 }, { 4, 0 }, { 6, 1 }, { 2, 3 }, { 3, 3 }, { 4, 3 }, { 1, 4 }, { 2, 4 }, { 3, 4 }, { 4, 4 }, { 5, 4 }, { 2, 5 }, { 3, 5 }, { 4, 5 } }) do c:put(29 + p[1], 24 + p[2] * 1, CREAM.L, "detail") end
  for _, p in ipairs({ { 5, 4 }, { 4, 5 }, { 6, 1 } }) do c:put(29 + p[1], 24 + p[2], CREAM.m, "detail") end
  L.rect(21, 13, 43, 16):each(function(x, y) c:put(x, y, (y == 13) and GOLD.L or ((y == 14) and GOLD.m or GOLD.s), "detail") end)
  px(c, { { 23, 14, GOLD.g }, { 41, 14, GOLD.D } })
  sep(c, outer)
  px(c, { { 58, 22, GOLD.m } })
  L.line({ { 58, 23 }, { 58, 27 } }):each(function(x, y) c:put(x, y, CREAM.m, "detail") end)
  local tag = L.ellipse(57.5, 32, 2.4, 3.4) part(c, tag, ORANGE, 1, 1)
  local tt = L.poly({ { 55, 35 }, { 60, 35 }, { 57.5, 38 } }) part(c, tt, ORANGE, 1, 1)
  px(c, { { 56, 30, '#' }, { 57, 29, ORANGE.g } })
  H.finish(c, "cf-up-catflap")
end
