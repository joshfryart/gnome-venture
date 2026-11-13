-- badges.lua: 9 medals + 5 rosettes, 64x64, Hearth Pop
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(DIR .. "/h3.lua")
local L, R, part, px, sep, leaf, rrect, arcline, star4 = H.L, H.R, H.part, H.px, H.sep, H.leaf, H.rrect, H.arcline, H.star4
local PINK, GREEN, SISAL, CREAM, TERRA, GOLD, WOOD, GREY, BLUE, PLUM, ORANGE, RED, BROWN, STEEL, VIOLET, NAVY, TEAL, SILVER, BRONZE =
  H.PINK, H.GREEN, H.SISAL, H.CREAM, H.TERRA, H.GOLD, H.WOOD, H.GREY, H.BLUE, H.PLUM, H.ORANGE, H.RED, H.BROWN, H.STEEL, H.VIOLET, H.NAVY, H.TEAL, H.SILVER, H.BRONZE
local floor, sin, cos, sqrt, abs, pi, min, max = math.floor, math.sin, math.cos, math.sqrt, math.abs, math.pi, math.min, math.max
local N = H.new
local CX, CY = 31.5, 31.5
local function medal(c, metal, field, quirk)
  local disc = L.ellipse(CX, CY, 28.6, 28.6) part(c, disc, metal, 4, 4)
  -- bevel bead ring
  for i = 0, 23 do
    local a = i * pi / 12 + 0.13
    local x, y = floor(CX + 27 * cos(a) + 0.5), floor(CY + 27 * sin(a) + 0.5)
    c:put(x, y, metal.g, "detail") c:put(x + 1, y, metal.l, "detail") c:put(x, y + 1, metal.l, "detail") c:put(x + 1, y + 1, metal.D, "detail")
  end
  local inner = L.ellipse(CX, CY, 23.4, 23.4)
  part(c, inner, field, 3, 3)
  sep(c, inner)
  -- engraved groove just outside the field
  L.ellipse(CX, CY, 24.6, 24.6):cut(L.ellipse(CX, CY, 23.4, 23.4)):each(function(x, y) c:put(x, y, metal.D, "detail") end)
  return inner
end
local function clipput(m) return function(c, x, y, t, lay) if m:has(x, y) then c:put(x, y, t, lay or "detail") end end end
local function eye(c, x, y, iris, hi)   -- 4x4 bead eye with ink pupil, cream glint
  local rows = { ".ii.", "ic#i", "i##i", ".ii." }
  for j, row in ipairs(rows) do for i = 1, 4 do local ch = row:sub(i, i)
    if ch == 'i' then c:put(x + i - 1, y + j - 1, iris, "detail") elseif ch == 'c' then c:put(x + i - 1, y + j - 1, hi or "#fff4d6", "detail") elseif ch == '#' then c:put(x + i - 1, y + j - 1, '#', "detail") end
  end end
end
local function whisk(c, x, y, dir, col)
  for k = 0, 4 do c:put(x + dir * k, y - (k // 3), col, "detail") end
  for k = 0, 3 do c:put(x + dir * k, y + 2 + (k // 2), col, "detail") end
end
local function head(c, cx, cy, hw, hh, coat, o)
  o = o or {}
  local le = L.poly({ { cx - hw, cy - hh * 0.3 }, { cx - hw + 1, cy - hh - 7 }, { cx - hw * 0.35, cy - hh * 0.85 } })
  local re = L.poly({ { cx + hw, cy - hh * 0.3 }, { cx + hw - 1, cy - hh - 7 + (o.bend or 0) }, { cx + hw * 0.35, cy - hh * 0.85 } })
  part(c, le, coat, 1, 1) part(c, re, coat, 1, 1)
  local hd = L.ellipse(cx, cy, hw + 0.6, hh) part(c, hd, coat, 3, 3) sep(c, hd)
  local ie = L.poly({ { cx - hw + 3, cy - hh * 0.4 }, { cx - hw + 3, cy - hh - 3 }, { cx - hw * 0.55, cy - hh * 0.8 } })
  local ie2 = L.poly({ { cx + hw - 3, cy - hh * 0.4 }, { cx + hw - 3, cy - hh - 3 + (o.bend or 0) }, { cx + hw * 0.55, cy - hh * 0.8 } })
  part(c, ie, PINK, 1, 1, { lift = 1 }) part(c, ie2, PINK, 1, 1, { lift = 1 })
  if o.stripes then for k = -1, 1 do for d = 0, 2 do c:put(cx + k * 3, cy - hh + 1 + d, o.stripes, "detail") end end end
  local mz = L.ellipse(cx, cy + hh * 0.35, hw * 0.55, hh * 0.45)
  if o.muzzle then mz:each(function(x, y) if hd:has(x, y) then c:put(x, y, o.muzzle, "detail") end end) end
  return hd
end
local function face(c, cx, cy, hw, hh, eyeL, eyeR, o)
  o = o or {}
  local ex = floor(hw * 0.5)
  eye(c, floor(cx - ex - 1.5), floor(cy - hh * 0.2), eyeL) eye(c, floor(cx + ex - 1.5), floor(cy - hh * 0.2), eyeR)
  px(c, { { floor(cx) - 1, floor(cy + hh * 0.3), PINK.s }, { floor(cx), floor(cy + hh * 0.3), PINK.s }, { floor(cx) - 1, floor(cy + hh * 0.3) - 1, PINK.m }, { floor(cx), floor(cy + hh * 0.3) - 1, PINK.m } })
  local my = floor(cy + hh * 0.3) + 1
  px(c, { { floor(cx) - 1, my + 1, '#' }, { floor(cx), my + 1, '#' }, { floor(cx) - 2, my + 2, '#' }, { floor(cx) + 1, my + 2, '#' } })
  if o.tongue then px(c, { { floor(cx) - 1, my + 3, PINK.m }, { floor(cx), my + 3, PINK.m }, { floor(cx), my + 4, PINK.s } }) end
end
local function stars(c, m, list, col)
  for _, s in ipairs(list) do
    for d = -s[3], s[3] do if m:has(s[1] + d, s[2]) then c:put(s[1] + d, s[2], (abs(d) <= 0) and "#ffffff" or col, "detail") end if m:has(s[1], s[2] + d) then c:put(s[1], s[2] + d, (abs(d) <= 0) and "#ffffff" or col, "detail") end end
  end
end
local function dots(c, m, list, col) for _, p in ipairs(list) do if m:has(p[1], p[2]) then c:put(p[1], p[2], col, "detail") end end end

-- FIRST CAT: orange kitten, tongue out ---------------------------------------------------------------------------
do
  local c = N()
  local f = medal(c, BRONZE, TEAL)
  dots(c, f, { { 14, 18 }, { 50, 16 }, { 46, 46 }, { 16, 46 }, { 52, 30 } }, TEAL.L)
  local hd = head(c, 31, 33, 14, 11, ORANGE, { stripes = ORANGE.s, muzzle = ORANGE.L })
  hd:each(function(x, y) if (x - 31) ^ 2 / 36 + (y - 38) ^ 2 / 30 <= 1 then c:put(x, y, CREAM.l, "detail") end end)
  for k = -1, 1 do for d = 0, 2 do c:put(31 + k * 3, 24 + d, ORANGE.s, "detail") end end
  face(c, 31, 33, 14, 11, "#6fd06a", "#6fd06a", { tongue = true })
  whisk(c, 16, 37, -1, CREAM.g) whisk(c, 46, 37, 1, CREAM.g)
  star4(c, 49, 17, 3, GOLD.m, "#ffffff")
  H.finish(c, "cf-badge-first_cat")
end

-- FULL HOUSE: cosy cottage at dusk, cat ears in the windows; quirk: chimney smoke curls into a heart ---------------
do
  local c = N()
  local f = medal(c, GOLD, VIOLET)
  dots(c, f, { { 14, 16 }, { 50, 14 }, { 18, 28 }, { 48, 24 }, { 42, 10 } }, "#ffe38a")
  star4(c, 15, 15, 2, "#ffe38a", "#ffffff") star4(c, 49, 14, 2, "#ffe38a", "#ffffff")
  -- ground
  L.rect(8, 46, 55, 54):each(function(x, y) if f:has(x, y) then c:put(x, y, (y == 46) and GREEN.l or GREEN.s, "detail") end end)
  local chim = L.rect(38, 22, 43, 34) part(c, chim, TERRA, 1, 1) sep(c, chim)
  for y = 24, 33, 3 do for x = 38, 43 do c:put(x, y, TERRA.D, "detail") end end
  local wall = L.rect(15, 32, 48, 48) part(c, wall, CREAM, 2, 3) sep(c, wall)
  for y = 36, 46, 4 do for x = 16, 47 do c:put(x, y, CREAM.b, "detail") end end
  local roof = L.poly({ { 11, 33 }, { 31.5, 15 }, { 52, 33 } }) part(c, roof, RED, 3, 3) sep(c, roof)
  for t = 0, 6 do local y = 20 + t * 2 for x = 12, 51 do if roof:has(x, y) and (x + t) % 4 == 0 then c:put(x, y, RED.D, "detail") end end end
  -- door and windows (warm lit)
  local door = rrect(28, 38, 35, 48, 2) part(c, door, WOOD, 1, 1) sep(c, door) px(c, { { 34, 43, GOLD.L } })
  for _, w in ipairs({ { 18, 37, 24, 43 }, { 39, 37, 45, 43 } }) do
    local wm = L.rect(w[1], w[2], w[3], w[4])
    wm:each(function(x, y) c:put(x, y, (y < w[2] + 3) and "#ffe38a" or GOLD.l, "detail") end)
    sep(c, wm)
    local mx = (w[1] + w[3]) // 2
    for y = w[2], w[4] do c:put(mx, y, WOOD.m, "detail") end
    -- two sleepy cat ears in the glass
    px(c, { { w[1] + 1, w[4] - 1, '#' }, { w[1] + 1, w[4] - 2, '#' }, { w[3] - 1, w[4] - 1, '#' }, { w[3] - 1, w[4] - 2, '#' }, { w[1] + 2, w[4], '#' }, { w[3] - 2, w[4], '#' } })
  end
  local ro = L.rect(31, 28, 32, 30) part(c, ro, GOLD, 1, 1)
  -- heart smoke
  local heart = { ".##.##.", "#######", "#######", ".#####.", "..###..", "...#..." }
  local hm = L.mask()
  for j, row in ipairs(heart) do for i = 1, #row do if row:sub(i, i) == '#' then hm:set(37 + i - 1, 10 + j - 1) c:put(37 + i - 1, 10 + j - 1, (j == 1 or j == 2) and SILVER.L or SILVER.l, "detail") end end end
  px(c, { { 38, 10, "#ffffff" }, { 39, 11, "#ffffff" } })
  sep(c, hm)
  px(c, { { 39, 17, SILVER.L }, { 40, 19, SILVER.l }, { 39, 21, SILVER.l } })
  H.finish(c, "cf-badge-full_house")
end

-- ODD EYED: white cat, one blue and one amber eye ------------------------------------------------------------------
do
  local c = N()
  local f = medal(c, SILVER, R("#1c0f2e", "#33184a", "#4a2a6a", "#6a4690", "#8c6cb4", "#cdb4f0"))
  dots(c, f, { { 14, 18 }, { 50, 16 }, { 46, 48 }, { 16, 46 }, { 52, 32 }, { 12, 32 } }, "#b89ae0")
  local hd = head(c, 31, 34, 14, 11, CREAM, { bend = 2 })
  -- bigger odd eyes: 5x5 beads
  local function big(x, y, iris, dark)
    local rows = { ".iii.", "icc#i", "i###i", "i###i", ".iii." }
    for j, row in ipairs(rows) do for i = 1, 5 do local ch = row:sub(i, i)
      if ch == 'i' then c:put(x + i - 1, y + j - 1, iris, "detail") elseif ch == 'c' then c:put(x + i - 1, y + j - 1, "#ffffff", "detail") elseif ch == '#' then c:put(x + i - 1, y + j - 1, (ch == '#' and dark) or '#', "detail") end
    end end
  end
  big(21, 28, "#4fa8ff", '#') big(35, 28, "#f2a020", '#')
  px(c, { { 31, 37, PINK.s }, { 32, 37, PINK.s }, { 31, 36, PINK.m }, { 32, 36, PINK.m }, { 31, 39, '#' }, { 32, 39, '#' }, { 30, 40, '#' }, { 33, 40, '#' } })
  whisk(c, 16, 38, -1, SILVER.g) whisk(c, 47, 38, 1, SILVER.g)
  -- quirk: a tiny pink freckle patch and a nicked ear tip
  px(c, { { 36, 25, PINK.L }, { 38, 26, PINK.L }, { 41, 24, CREAM.D } })
  star4(c, 14, 14, 2, "#ffd0e8", "#ffffff")
  H.finish(c, "cf-badge-odd_eyed")
end

-- LEGENDARY: crowned grey cat ----------------------------------------------------------------------------------------
do
  local c = N()
  local f = medal(c, GOLD, R("#4a1030", "#7a1f3a", "#a02c4a", "#c4405a", "#e0607a", "#ffb0c0"))
  dots(c, f, { { 14, 24 }, { 50, 22 }, { 12, 38 }, { 52, 38 }, { 44, 50 }, { 20, 50 } }, "#ffb0c0")
  local hd = head(c, 31, 38, 13, 10, GREY, { stripes = GREY.s })
  face(c, 31, 38, 13, 10, "#ffd257", "#ffd257", {})
  whisk(c, 17, 42, -1, GREY.g) whisk(c, 45, 42, 1, GREY.g)
  -- crown, tilted one step
  local crown = L.poly({ { 21, 29 }, { 20, 16 }, { 26, 22 }, { 31, 12 }, { 37, 21 }, { 43, 14 }, { 42, 28 } })
  part(c, crown, GOLD, 2, 2) sep(c, crown)
  for x = 22, 41 do c:put(x, 26, GOLD.D, "detail") c:put(x, 27, GOLD.s, "detail") end
  px(c, { { 31, 24, RED.m }, { 32, 24, RED.m }, { 31, 25, RED.s }, { 32, 25, RED.s }, { 31, 23, RED.g }, { 25, 24, "#ffffff" }, { 38, 24, "#ffffff" } })
  for _, p in ipairs({ { 20, 16 }, { 31, 12 }, { 43, 14 } }) do c:put(p[1], p[2] - 1, "#ffffff", "detail") end
  star4(c, 49, 15, 3, "#ffe38a", "#ffffff") star4(c, 13, 16, 2, "#ffe38a", "#ffffff")
  H.finish(c, "cf-badge-legendary")
end

-- NAP badges -----------------------------------------------------------------------------------------------------------
local function napcat(c, f, o)
  local body = L.ellipse(33, 41, 16, 8.4) part(c, body, CREAM, 3, 3)
  local hd = L.ellipse(20, 38, 7, 6.2) part(c, hd, CREAM, 2, 2)
  local e1 = L.poly({ { 14, 35 }, { 15, 28 }, { 19, 32 } }) local e2 = L.poly({ { 22, 32 }, { 26, 28 }, { 26, 35 } })
  part(c, e1, CREAM, 1, 1) part(c, e2, CREAM, 1, 1)
  sep(c, body) sep(c, hd)
  -- patches
  for _, sx in ipairs({ 30, 35, 40 }) do for d = 0, 3 do if body:has(sx + d, 35 + d) then c:put(sx + d, 35 + d, CREAM.s, "detail") end if body:has(sx + d + 1, 35 + d) then c:put(sx + d + 1, 35 + d, CREAM.b, "detail") end end end
  -- closed eyes and nose
  px(c, { { 17, 38, '#' }, { 18, 39, '#' }, { 19, 39, '#' }, { 22, 38, '#' }, { 23, 39, '#' }, { 24, 39, '#' }, { 20, 41, PINK.m }, { 21, 41, PINK.m } })
  px(c, { { 14, 31, PINK.m }, { 25, 31, PINK.m } })
  local tail = L.tube({ { 48, 42 }, { 44, 47 }, { 34, 48 } }, function() return 1.7 end) part(c, tail, CREAM, 1, 1) sep(c, tail)
  for x = 18, 46 do if body:has(x, 47) then c:put(x, 47, CREAM.D, "detail") end end
  if o.cap then
    local cap = L.poly({ { 14, 33 }, { 24, 33 }, { 28, 24 }, { 33, 29 }, { 26, 22 }, { 20, 24 } })
    local cp = L.poly({ { 14, 33 }, { 26, 32 }, { 30, 24 }, { 24, 22 }, { 17, 26 } }) part(c, cp, RED, 2, 2) sep(c, cp)
    local pom = L.ellipse(31, 24, 2.4, 2.4) part(c, pom, CREAM, 1, 1) sep(c, pom)
    for x = 15, 25 do c:put(x, 32, CREAM.m, "detail") end
  end
end
local function zee(c, x, y, s, col)
  for i = 0, s do c:put(x + i, y, col, "detail") c:put(x + i, y + s, col, "detail") c:put(x + s - i, y + i, col, "detail") end
end
do   -- nap1: moon + one Z
  local c = N()
  local f = medal(c, BRONZE, NAVY)
  dots(c, f, { { 16, 16 }, { 28, 12 }, { 48, 28 }, { 14, 30 }, { 44, 16 }, { 38, 12 } }, "#c8d8ff")
  local moon = L.ellipse(19, 18, 6.2, 6.2):cut(L.ellipse(22, 16, 5.4, 5.4))
  moon:each(function(x, y) c:put(x, y, (x + y < 36) and GOLD.L or GOLD.m, "detail") end) sep(c, moon)
  napcat(c, f, {})
  zee(c, 41, 18, 5, "#ffffff") zee(c, 46, 12, 3, "#c8d8ff")
  H.finish(c, "cf-badge-nap1")
end
do   -- nap5: five stars + nightcap
  local c = N()
  local f = medal(c, SILVER, NAVY)
  for i = 0, 4 do
    local a = pi + 0.5 + i * (pi - 1.0) / 4
    local sx, sy = floor(CX + 17.5 * cos(a) + 0.5), floor(CY + 15 * sin(a) + 3.5)
    star4(c, sx, sy, (i == 2) and 3 or 2, GOLD.m, "#ffffff")
  end
  napcat(c, f, { cap = true })
  zee(c, 43, 22, 4, "#ffffff")
  H.finish(c, "cf-badge-nap5")
end

-- BOOK badges ----------------------------------------------------------------------------------------------------------------
local function book(c, f, filled, o)
  -- open book: two page spreads on a green cover
  local cover = L.poly({ { 8, 22 }, { 55, 22 }, { 57, 49 }, { 6, 49 } }) part(c, cover, GREEN, 2, 2) sep(c, cover)
  local lp = L.poly({ { 10, 20 }, { 31, 24 }, { 31, 47 }, { 10, 44 } }) part(c, lp, CREAM, 1, 2) sep(c, lp)
  local rp = L.poly({ { 53, 20 }, { 32, 24 }, { 32, 47 }, { 53, 44 } }) part(c, rp, CREAM, 2, 1) sep(c, rp)
  for x = 31, 32 do for y = 24, 47 do c:put(x, y, CREAM.D, "detail") end end
  -- page edge lines
  for y = 46, 48 do for x = 8, 29 do if (y - 46) == 0 then end end end
  local cols = { RED, BLUE, ORANGE, GREEN, PINK, VIOLET, RED, BLUE, ORANGE, GREEN, PINK, VIOLET }
  local k = 0
  for side = 0, 1 do for row = 0, 2 do for col = 0, 1 do
    k = k + 1
    local x0 = (side == 0) and (12 + col * 9) or (35 + col * 9)
    local y0 = ((side == 0) and (26 + col * 0) or (26)) + row * 6 + ((side == 0) and floor((x0 - 10) / 8) or -floor((x0 - 35) / 8))
    y0 = y0 + ((side == 0) and 0 or 0)
    local ramp = cols[k]
    if k <= filled then
      for dy = 0, 3 do for dx = 0, 3 do c:put(x0 + dx, y0 + dy, (dy == 3) and ramp.s or ramp.m, "detail") end end
      c:put(x0 + 1, y0 + 1, "#fff4d8", "detail")
    else
      for dx = 0, 3 do c:put(x0 + dx, y0, CREAM.s, "detail") c:put(x0 + dx, y0 + 3, CREAM.s, "detail") end
      for dy = 1, 2 do c:put(x0, y0 + dy, CREAM.s, "detail") c:put(x0 + 3, y0 + dy, CREAM.s, "detail") end
    end
  end end end
  o.extra(c)
end
do
  local c = N()
  local f = medal(c, BRONZE, R("#1f3a2a", "#2a5a3c", "#3a7a4a", "#58a060", "#80c07a", "#c8f0b0"))
  dots(c, f, { { 14, 14 }, { 50, 14 }, { 32, 12 } }, "#a8e08a")
  book(c, f, 3, { extra = function(c)   -- ribbon bookmark hangs below the page
    local rb = L.poly({ { 40, 44 }, { 44, 44 }, { 44, 55 }, { 42, 52 }, { 40, 55 } }) part(c, rb, RED, 1, 1) sep(c, rb)
  end })
  H.finish(c, "cf-badge-book12")
end
do
  local c = N()
  local f = medal(c, SILVER, R("#1f3a2a", "#2a5a3c", "#3a7a4a", "#58a060", "#80c07a", "#c8f0b0"))
  dots(c, f, { { 14, 14 }, { 50, 14 }, { 32, 12 } }, "#a8e08a")
  book(c, f, 6, { extra = function(c)   -- a pencil tucked in the gutter
    local pc = L.tube({ { 28, 20 }, { 38, 12 } }, function() return 1.2 end) part(c, pc, GOLD, 1, 1) sep(c, pc)
    px(c, { { 39, 11, PINK.m }, { 40, 10, PINK.m }, { 27, 21, '#' } })
  end })
  H.finish(c, "cf-badge-book_half")
end
do
  local c = N()
  local f = medal(c, GOLD, R("#1f3a2a", "#2a5a3c", "#3a7a4a", "#58a060", "#80c07a", "#c8f0b0"))
  dots(c, f, { { 14, 14 }, { 50, 14 } }, "#a8e08a")
  book(c, f, 12, { extra = function(c)   -- gold star sticker over the gutter and sparkles
    local st = L.poly({ { 32, 10 }, { 34.5, 16.5 }, { 41, 16.5 }, { 36, 20.5 }, { 38, 27 }, { 32, 23 }, { 26, 27 }, { 28, 20.5 }, { 23, 16.5 }, { 29.5, 16.5 } })
    part(c, st, GOLD, 1, 1) sep(c, st) px(c, { { 31, 15, GOLD.g }, { 32, 14, GOLD.g } })
    star4(c, 12, 18, 2, "#ffe38a", "#ffffff") star4(c, 52, 18, 2, "#ffe38a", "#ffffff")
  end })
  H.finish(c, "cf-badge-book_full")
end

-- RIBBONS ---------------------------------------------------------------------------------------------------------------------
local function rosette(name, ramp, centre, o)
  local c = N()
  local cx, cy = 31.5, o.cy or 25
  local S = o.s or 1
  -- tails
  for _, t in ipairs(o.tails) do
    local pts = {}
    for _, p in ipairs(t.p) do pts[#pts + 1] = { cx + (p[1] - 31.5) * S, cy + (p[2] - 25) * S } end
    local m = L.poly(pts) part(c, m, t.ramp or ramp, 1, 1, { lift = t.lift or -1 }) sep(c, m)
    if t.stripe then L.line({ { floor(pts[1][1] + .5), floor(pts[1][2] + .5) }, { floor(pts[#pts - 1][1] + .5), floor(pts[#pts - 1][2] + .5) } }):each(function(x, y) if m:has(x, y) then c:put(x, y, t.stripe, "detail") end end) end
    t.m = m
  end
  local R1 = 22 * S
  local outer = L.mask()
  for y = floor(cy - R1 - 3), floor(cy + R1 + 3) do for x = floor(cx - R1 - 3), floor(cx + R1 + 3) do
    local dx, dy = x - cx, y - cy
    local r, th = sqrt(dx * dx + dy * dy), math.atan(dy, dx)
    if r <= R1 - 1.6 + 1.7 * math.abs(cos(7 * th)) then outer:set(x, y) end
  end end
  part(c, outer, ramp, 3, 3) sep(c, outer)
  for i = 0, 13 do local th = i * pi / 7 + pi / 14 for r = 8 * S, R1 - 4 do local x, y = floor(cx + r * cos(th) + 0.5), floor(cy + r * sin(th) + 0.5) if outer:has(x, y) then c:put(x, y, ramp.s, "detail") end end end
  local mid = L.mask()
  for y = floor(cy - 16 * S), floor(cy + 16 * S) do for x = floor(cx - 16 * S), floor(cx + 16 * S) do
    local dx, dy = x - cx, y - cy
    local r, th = sqrt(dx * dx + dy * dy), math.atan(dy, dx)
    if r <= 13.4 * S + 1.2 * math.abs(cos(7 * th + 0.45)) then mid:set(x, y) end
  end end
  part(c, mid, ramp, 2, 2, { lift = 1 }) sep(c, mid)
  local disc = L.ellipse(cx, cy, 9.4 * S, 9.4 * S) part(c, disc, GOLD, 2, 2) sep(c, disc)
  local face = L.ellipse(cx, cy, 6.6 * S, 6.6 * S) part(c, face, centre.ramp or GOLD, 1, 1, { lift = 1 })
  centre.draw(c, cx, cy)
  if o.extra then o.extra(c, cx, cy) end
  H.finish(c, name)
end
local function paw(c, x, y, col, sh)
  for _, p in ipairs({ { -3, -1 }, { -1, -3 }, { 1, -3 }, { 3, -1 } }) do c:put(floor(x + p[1]), floor(y + p[2]), col, "detail") end
  for _, p in ipairs({ { -1, 0 }, { 0, 0 }, { 1, 0 }, { -2, 1 }, { -1, 1 }, { 0, 1 }, { 1, 1 }, { 2, 1 }, { -1, 2 }, { 0, 2 }, { 1, 2 } }) do c:put(floor(x + p[1]), floor(y + p[2]), (p[2] == 2 or p[1] == 2) and sh or col, "detail") end
end
local PURPLE = R("#2a1a5a", "#4a2e96", "#6a4cc0", "#8a6ee0", "#aa90f0", "#e0d4ff")
local BLUER = R("#1a3a7a", "#2a60b8", "#3a84e0", "#62a8f4", "#90c8ff", "#d8eeff")
local REDR = R("#6e1428", "#b02840", "#dc3c48", "#f06858", "#ff9a80", "#ffd8c8")
local WHITE = R("#7a7090", "#b0a8c4", "#e4e0ee", "#f4f0fa", "#ffffff", "#ffffff")
local GREENR = R("#1f4a3a", "#2f7a48", "#44a050", "#6ec060", "#98dc78", "#d4f4a8")
local TL = function(a, b, c_, d, e) return { p = { a, b, c_, d, e } } end
rosette("cf-ribbon-best", PURPLE, { draw = function(c, x, y)
  local k = 0.86
  local st = L.poly({ { x, y - 6 * k }, { x + 1.8 * k, y - 1.8 * k }, { x + 6 * k, y - 1.5 * k }, { x + 2.6 * k, y + 1.4 * k }, { x + 4 * k, y + 5.5 * k }, { x, y + 3 * k }, { x - 4 * k, y + 5.5 * k }, { x - 2.6 * k, y + 1.4 * k }, { x - 6 * k, y - 1.5 * k }, { x - 1.8 * k, y - 1.8 * k } })
  part(c, st, RED, 1, 1) px(c, { { floor(x) - 1, floor(y) - 2, RED.g } })
end }, { tails = {
  { p = { { 22, 38 }, { 32, 40 }, { 26, 62 }, { 20, 56 }, { 12, 61 } }, ramp = PURPLE, stripe = GOLD.m },
  { p = { { 31, 40 }, { 42, 38 }, { 51, 61 }, { 44, 56 }, { 36, 62 } }, ramp = PURPLE, stripe = GOLD.m },
  { p = { { 27, 39 }, { 37, 39 }, { 35, 59 }, { 32, 54 }, { 29, 59 } }, ramp = GOLD },
}, extra = function(c, x, y)   -- quirk: a small gold crown pin on top
  local cr = L.poly({ { x - 4, 9 }, { x - 4, 3 }, { x - 2, 6 }, { x, 2 }, { x + 2, 6 }, { x + 4, 3 }, { x + 4, 9 } }) part(c, cr, GOLD, 1, 1) sep(c, cr) px(c, { { floor(x), 6, RED.m } })
end, cy = 29, s = 0.86 })
rosette("cf-ribbon-blue", BLUER, { draw = function(c, x, y) paw(c, x, y - 1, "#ffffff", BLUE.g) end }, { tails = {
  { p = { { 22, 38 }, { 32, 40 }, { 25, 60 }, { 20, 55 }, { 13, 58 } }, ramp = BLUER },
  { p = { { 31, 40 }, { 42, 38 }, { 51, 58 }, { 44, 55 }, { 38, 60 } }, ramp = BLUER },
}, extra = function(c, x, y) px(c, { { 14, 16, BLUER.g }, { 15, 15, BLUER.g } }) end })
rosette("cf-ribbon-red", REDR, { draw = function(c, x, y)
  local hm = { ".##.##.", "#######", "#######", ".#####.", "..###..", "...#..." }
  for j, row in ipairs(hm) do for i = 1, #row do if row:sub(i, i) == '#' then c:put(floor(x) - 3 + i - 1, floor(y) - 3 + j - 1, (j <= 2) and "#ffd8d8" or "#ffb0b0", "detail") end end end
end }, { tails = {
  { p = { { 24, 38 }, { 34, 40 }, { 40, 60 }, { 34, 55 }, { 28, 59 } }, ramp = REDR },
  { p = { { 29, 40 }, { 40, 38 }, { 24, 60 }, { 19, 55 }, { 14, 59 } }, ramp = REDR },
} })
rosette("cf-ribbon-white", WHITE, { draw = function(c, x, y)
  -- tiny fish
  local fb = L.ellipse(x - 1, y, 3.4, 2.4) part(c, fb, ORANGE, 1, 1)
  local ft = L.poly({ { x + 1.5, y }, { x + 5, y - 3 }, { x + 5, y + 3 } }) part(c, ft, ORANGE, 1, 1)
  px(c, { { floor(x) - 3, floor(y) - 1, '#' } })
end }, { tails = {
  { p = { { 22, 38 }, { 32, 40 }, { 26, 60 }, { 21, 55 }, { 14, 58 } }, ramp = WHITE },
  { p = { { 31, 40 }, { 42, 38 }, { 51, 58 }, { 45, 56 }, { 38, 60 } }, ramp = WHITE },
}, extra = function(c, x, y) px(c, { { 12, 18, "#ffffff" } }) end })
rosette("cf-ribbon-part", GREENR, { draw = function(c, x, y)
  -- leaf sprout
  local l1 = leaf({ { x, y + 3 }, { x - 3, y - 1 }, { x - 5, y - 4 } }, 2.2) part(c, l1, GREEN, 1, 1)
  local l2 = leaf({ { x, y + 3 }, { x + 3, y - 1 }, { x + 5, y - 4 } }, 2.2) part(c, l2, GREEN, 1, 1)
  L.rect(floor(x), floor(y) + 1, floor(x), floor(y) + 4):each(function(px_, py_) c:put(px_, py_, GREEN.s, "detail") end)
end }, { s = 0.74, cy = 30, tails = {
  { p = { { 22, 38 }, { 32, 40 }, { 26, 60 }, { 21, 56 }, { 15, 60 } }, ramp = GREENR },
  { p = { { 31, 40 }, { 42, 38 }, { 49, 60 }, { 44, 56 }, { 38, 60 } }, ramp = GREENR },
} })
