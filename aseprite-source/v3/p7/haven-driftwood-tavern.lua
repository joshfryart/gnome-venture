local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local H = X.hash
local INK = GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "tavern" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local function R6(R) return GX.ramp6(R) end
local function blob(cx, cy, rx, ry, R, seed, o) local m = mk(); E(m, cx, cy, rx, ry); m = GX.rough(m, seed, 1); o = o or {}; o.seed = seed; GX.lit(c, m, R6(R), o); return m end

local SAND = { hi = "#fff0c0", base = "#f2c890", shade = "#c8946c", deep = "#8a5a60" }
local WOOD = { hi = "#e8a868", base = "#b86e44", shade = "#82444a", deep = "#4a2840" }
local WOOD2 = { hi = "#d8985c", base = "#a05c40", shade = "#6e3a48", deep = "#3c2238" }
local THATCH = { hi = "#ffd878", base = "#e0a050", shade = "#a8684a", deep = "#603a48" }
local PALM = { hi = "#a8d860", base = "#48a048", shade = "#2a6a48", deep = "#183a40" }
local PALM2 = { hi = "#88c458", base = "#2e8444", shade = "#1c5440", deep = "#122e3a" }
local BARK = { hi = "#d89868", base = "#a0603c", shade = "#6e3c44", deep = "#40243a" }
local CRAB = { hi = "#ff9a6a", base = "#f0583c", shade = "#b83a4a", deep = "#6a2044" }
local TURT = { hi = "#c8e478", base = "#6cb850", shade = "#3a8050", deep = "#1e4a48" }
local SHELL = { hi = "#a8d070", base = "#4a9448", shade = "#2e6444", deep = "#1a3a40" }
local PINK = { hi = "#ffc0d0", base = "#f080a8", shade = "#b04c88", deep = "#6a2c68" }
local CREAM = { hi = "#fffae8", base = "#ffe8c0", shade = "#e0b0a0", deep = "#a07088" }
local STONE = { hi = "#d8d4e8", base = "#a8a4c4", shade = "#7a74a0", deep = "#4a4470" }

---------------------------------------------------------------- sky
local sky = { "#2a1f4e", "#38286c", "#523a8c", "#7a4a9c", "#a85a9a", "#d8707c", "#f49a6a", "#ffc070", "#ffe090" }
GX.bands(c, 0, 138, sky, 3, .16)
for i = 0, 40 do local x, y = floor(H(i, 1, 1) * 478), floor(H(i, 2, 1) * 60); c:px(x, y, "#fff0d0"); if i % 5 == 0 then c:px(x + 1, y, "#d8c0e8"); c:px(x, y + 1, "#d8c0e8") end end
-- sun half set, glow from the left
local function glow(cx, cy, r, col)
  local m = mk(); E(m, cx, cy, r, floor(r * .8)); m:each(function(x, y) if y <= 139 then c:px(x, y, GX.mix(c:get(x, y) or col, col, .35)) end end)
end
glow(96, 138, 70, "#ffb060"); glow(96, 138, 48, "#ffc878")
local sun = mk(); E(sun, 96, 140, 26, 24); sun = GX.rough(sun, 2, 1)
sun:each(function(x, y) if y <= 139 then local dd = sqrt((x - 96) ^ 2 + (y - 140) ^ 2); c:px(x, y, dd < 12 and "#fffbe0" or dd < 20 and "#ffe890" or "#ffc468") end end)
-- clouds
local function cloud(cx, cy, w, R, seed)
  local m = mk(); for i = 0, 4 do E(m, cx - w + i * floor(w / 2.2), cy + (i % 2) * -2, floor(w / 2.4), 4) end
  m = GX.rough(m, seed, 1); GX.lit(c, m, R6(R), { R = 4, tex = .3, sc = 3, seed = seed, ink = false, amb = .3 })
end
local CLR = { hi = "#ffc8a0", base = "#e890a0", shade = "#a860a0", deep = "#6a4090" }
cloud(380, 44, 22, CLR, 4); cloud(190, 70, 26, CLR, 8); cloud(60, 92, 20, CLR, 9)

---------------------------------------------------------------- sea
local sea = { "#f09878", "#d06c84", "#9a4c8c", "#6a3e86", "#4a3a80", "#34447e", "#2c5488", "#2a6490" }
GX.bands(c, 139, 190, sea, 5, .24)
for i = 0, 70 do  -- sun glitter column + wave dashes
  local y = 140 + floor(H(i, 5, 1) ^ 1.2 * 46); local x = 96 + floor((H(i, 6, 1) - .5) * (16 + (y - 140) * .5))
  c:fillMask(c:rect(x, y, x + 1 + i % 4, y), i % 3 == 0 and "#fff0b0" or "#ffc070")
end
for i = 0, 50 do local x, y = floor(H(i, 7, 1) * 470), 142 + floor(H(i, 8, 1) * 44); c:fillMask(c:rect(x, y, x + 3 + i % 5, y), "#3e5c9c") end

---------------------------------------------------------------- sand
local function yfn(x) return 186 + floor(3 * sin(x / 37) + 2 * sin(x / 11 + 1)) end
GX.ground(c, yfn, SAND, 7, { top = .86, fall = .55, tex = .3, sc = 8 })
for x = 0, 479 do
  local y0 = yfn(x)
  for k = 1, 3 do c:px(x, y0 + k, k < 2 and "#b88470" or "#d8a888") end
  c:px(x, y0 - 1, "#fff0e0"); c:px(x, y0, "#fff8f0")
  if GX.vn(x, 3, 5, 9) > .45 then c:px(x, y0 - 2, "#f8c8c0") end
end
for i = 0, 60 do local x, y = floor(H(i, 71, 1) * 480), 200 + floor(H(i, 73, 1) * 68); c:px(x, y, i % 2 == 0 and "#b88470" or "#fff4d8") end

---------------------------------------------------------------- boat + sail (distant)
local hull = mk()
for x = 186, 230 do local u = (x - 208) / 22; local t = 126 + floor(6 * u * u); for y = t, 133 - floor(2 * u * u) do hull:set(x, y) end end
GX.lit(c, GX.rough(hull, 3, 1), R6(WOOD), { R = 5, tex = .3, seed = 3, rimlight = true })
c:fillMask(c:rect(196, 130, 222, 130), WOOD.deep)
c:fillMask(c:rect(207, 108, 208, 126), INK)
local sail = c:poly{ { 210, 106 }, { 230, 124 }, { 210, 124 } }
GX.lit(c, sail, R6(CREAM), { R = 7, tex = .25, seed = 5, rimlight = true })
local sail2 = c:poly{ { 205, 112 }, { 205, 124 }, { 194, 124 } }
GX.lit(c, sail2, R6(PINK), { R = 5, tex = .2, seed = 6, rimlight = true })
for k = 0, 8 do c:px(186 + k * 5, 135 + k % 2, "#6a5090") end

---------------------------------------------------------------- palms
local function bez(p0, p1, p2, t) local u = 1 - t; return u*u*p0[1] + 2*u*t*p1[1] + t*t*p2[1], u*u*p0[2] + 2*u*t*p1[2] + t*t*p2[2] end
local function palmTrunk(p0, p1, p2, r0, r1, seed)
  local m = mk()
  for i = 0, 80 do local x, y = bez(p0, p1, p2, i / 80); E(m, floor(x), floor(y), floor(r0 + (r1 - r0) * i / 80 + .5)) end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, R6(BARK), { R = 4, tex = .35, sc = 2.4, seed = seed, rimlight = true, fn = function(x, y) return (floor(y / 3) % 2) * .14 - .07 end })
end
local function frond(cx, cy, adeg, L, droop, R, seed)
  local m, mid = mk(), {}
  local ca, sa = cos(adeg / 57.3), -sin(adeg / 57.3)
  for i = 0, floor(L) do
    local t = i / floor(L)
    local x, y = floor(cx + ca * L * t), floor(cy + sa * L * t + droop * t * t)
    local w = floor(5.5 * sin(pi * min(1, t * 1.15)) ^ .75 * (.6 + .4 * (i % 3 == 0 and 1 or .35)) + .5)
    for k = -w, w do m:set(x, y + k) end
    mid[#mid + 1] = { x, y }
  end
  GX.lit(c, m, R6(R), { R = 3, tex = .35, sc = 2, seed = seed, rimlight = true, amb = .3 })
  for i = 2, #mid - 3 do c:px(mid[i][1], mid[i][2], R.deep) end
end
local function crown(cx, cy, angs, L, droop, seed)
  for i, a in ipairs(angs) do frond(cx, cy, a, L - (i % 2) * 5, droop, (i % 2 == 0) and PALM or PALM2, seed + i) end
end
local function nuts(ps) for _, p in ipairs(ps) do blob(p[1], p[2], 3, 3, { hi = "#b88050", base = "#7a4a34", shade = "#52303a", deep = "#33202e" }, p[1], { R = 3, tex = .1, rimlight = true }) end end
-- left palm
palmTrunk({50, 200}, {32, 120}, {44, 62}, 5, 3, 31)
crown(44, 62, {170, 140, 105, 65, 30, 0, 200}, 38, 18, 40); nuts{ {40, 67}, {47, 68}, {44, 71} }

---------------------------------------------------------------- tavern hut
-- shadow on sand
local sh = mk(); E(sh, 355, 208, 92, 5); sh = GX.rough(sh, 5, 1); c:fillMask(sh, "#8a5a78")
-- back wall (dark interior) with posts
local wall = c:rect(282, 118, 428, 206)
GX.lit(c, wall, R6({ hi = "#c8784c", base = "#8a4a4a", shade = "#5a3248", deep = "#34223c" }), { R = 30, tex = .5, sc = 3, seed = 12, rimlight = false,
  fn = function(x, y) return ((x // 7) % 2) * .06 - .05 + (y < 150 and .1 or 0) end })
for x = 282, 428, 7 do for y = 120, 205 do c:px(x, y, "#34223c") end end
for _, px in ipairs{ 282, 426 } do c:fillMask(c:rect(px - 1, 112, px + 2, 206), INK); c:fillMask(c:rect(px, 112, px + 1, 206), WOOD.base); c:fillMask(c:rect(px, 112, px, 206), WOOD.hi) end
-- shelf with bottles
c:fillMask(c:rect(290, 148, 418, 150), INK); c:fillMask(c:rect(290, 148, 418, 148), WOOD.hi)
local bc = { "#58c8a8", "#f0a040", "#e86088", "#a078e0", "#58c8a8", "#f0a040", "#e86088", "#a078e0", "#58c8a8", "#f0a040" }
for i, col in ipairs(bc) do
  local bx = 296 + (i - 1) * 13
  c:fillMask(c:rect(bx, 139, bx + 4, 147), INK); c:fillMask(c:rect(bx + 1, 140, bx + 3, 147), col); c:px(bx + 1, 141, GX.mix(col, "#ffffff", .5)); c:fillMask(c:rect(bx + 1, 135, bx + 3, 138), INK); c:px(bx + 2, 136, "#ffe8b0")
end
-- thatch roof
local roof = mk()
for y = 66, 124 do
  local t = (y - 66) / 58
  local x0 = floor(300 - t * 36 + (GX.vn(0, y, 6, 4) - .5) * 4); local x1 = floor(404 + t * 36 + (GX.vn(1, y, 6, 5) - .5) * 4)
  for x = x0, x1 do roof:set(x, y) end
end
for x = 262, 442 do for k = 0, 3 do if H(x // 3, k, 8) < .55 then roof:set(x, 124 + k) end end end  -- ragged hem
roof = GX.rough(roof, 9, 1)
GX.lit(c, roof, R6(THATCH), { R = 26, tex = .55, sc = 3, seed = 21, h = 1, wrap = .4, rimlight = true,
  fn = function(x, y) return (H(x // 2, y // 5, 3) - .5) * .22 - ((y - 66) % 6 == 0 and .12 or 0) end })
for i = 0, 70 do local x, y = 276 + floor(H(i, 3, 3) * 160), 74 + floor(H(i, 4, 3) * 48); if roof:has(x, y) and roof:has(x, y + 4) then for k = 0, 3 do c:px(x, y + k, k < 2 and THATCH.deep or THATCH.shade) end end end
-- striped awning
local aw = mk()
for x = 270, 440 do local y1 = 134 + floor(1.5 * sin(x / 5.5) + 1.5); for y = 124, y1 do aw:set(x, y) end end
aw = GX.rough(aw, 3, 1)
GX.lit(c, aw, function(x, y) return ((x // 9) % 2 == 0) and R6({ hi = "#ff9a88", base = "#e8485c", shade = "#a02c5c", deep = "#601c50" }) or R6(CREAM) end,
  { R = 6, tex = .2, sc = 3, seed = 4, rimlight = true })
-- counter (driftwood planks)
local ctr = c:rect(270, 172, 440, 206)
GX.lit(c, ctr, R6(WOOD), { R = 30, tex = .5, sc = 2, seed = 30, rimlight = true, h = 1,
  fn = function(x, y) return ((y - 172) // 7 % 2) * .09 - .04 + (y < 177 and .15 or 0) end })
for y = 179, 205, 7 do for x = 271, 439 do if (x + y) % 5 ~= 0 then c:px(x, y, WOOD.deep) end end end
for x = 276, 439, 29 do for y = 180, 204 do if H(x, y, 2) < .9 then c:px(x + (y % 2), y, WOOD.shade) end end end
for _, nx in ipairs{ 288, 340, 392, 428 } do c:px(nx, 184, WOOD.hi); c:px(nx, 196, WOOD.deep) end
c:fillMask(c:rect(268, 170, 442, 173), INK); c:fillMask(c:rect(269, 171, 441, 171), "#f4b878"); c:fillMask(c:rect(269, 172, 441, 172), WOOD.hi)

-- shell sign on roof
local sg = mk(); E(sg, 352, 98, 15, 13); sg:cut(c:rect(330, 108, 376, 120)); sg = GX.rough(sg, 6, 1)
GX.lit(c, sg, R6(PINK), { R = 12, tex = .2, sc = 3, seed = 6, rimlight = true,
  fn = function(x, y) local a = math.atan(y - 112, x - 352); return (floor(a * 7) % 2) * .14 - .07 end })
for k = -6, 6 do local a = -pi / 2 + k * .24; for r = 3, 13 do local x, y = 352 + floor(cos(a) * r + .5), 112 + floor(sin(a) * r * .92 + .5); if sg:has(x, y) and r % 3 ~= 0 and k % 2 == 0 then c:px(x, y, PINK.deep) end end end
c:fillMask(c:rect(348, 110, 356, 114), "#ffd898"); c:fillMask(c:rect(349, 111, 355, 111), "#fff0c0"); c:fillMask(c:rect(347, 109, 357, 109), INK)

-- bartender: crab behind the counter
local cx, cy = 352, 168
for _, s in ipairs{ -1, 1 } do   -- raised claws
  local arm = mk(); for k = 0, 8 do E(arm, cx + s * (13 + k // 2), cy - 4 - k, 2) end
  GX.lit(c, GX.rough(arm, 15 + s, 1), R6(CRAB), { R = 2, tex = .2, seed = 5, rimlight = true })
  local cl = mk(); E(cl, cx + s * 18, cy - 15, 6, 5); cl:cut(c:rect(cx + s * 18 - 1, cy - 21, cx + s * 18 + 1, cy - 17)); cl = GX.rough(cl, 20 + s, 1)
  GX.lit(c, cl, R6(CRAB), { R = 5, tex = .2, seed = 9, rimlight = true })
end
local body = blob(cx, cy - 6, 17, 12, CRAB, 17, { R = 10, tex = .3, sc = 3, rimlight = true })
for _, s in ipairs{ -1, 1 } do   -- eyes on stalks
  c:fillMask(c:rect(cx + s * 6, cy - 24, cx + s * 6, cy - 17), INK)
  local e = mk(); E(e, cx + s * 6, cy - 27, 4, 4); GX.lit(c, e, R6(CREAM), { R = 3, tex = 0, rimlight = true })
  c:fillMask(c:rect(cx + s * 6 - 1 + (s > 0 and 0 or 1), cy - 28, cx + s * 6 + (s > 0 and 1 or 0), cy - 26), INK)
end
-- bandana (quirk: paper umbrella drink on the head)
c:fillMask(c:rect(cx - 8, cy - 14, cx + 8, cy - 12), INK); c:fillMask(c:rect(cx - 7, cy - 14, cx + 7, cy - 13), "#58c8d8"); for k = -6, 6, 4 do c:px(cx + k, cy - 14, "#fffae8") end
c:fillMask(c:rect(cx + 10, cy - 36, cx + 10, cy - 24), INK)
local um = c:poly{ { cx + 3, cy - 34 }, { cx + 10, cy - 40 }, { cx + 18, cy - 34 } }; GX.lit(c, um, R6(PINK), { R = 4, tex = 0, rimlight = true })
-- smile + apron
c:fillMask(c:rect(cx - 3, cy - 4, cx + 3, cy - 4), INK); c:px(cx - 4, cy - 5, INK); c:px(cx + 4, cy - 5, INK)
c:px(cx - 9, cy - 5, "#ff8aa0"); c:px(cx - 8, cy - 5, "#ff8aa0"); c:px(cx + 8, cy - 5, "#ff8aa0"); c:px(cx + 9, cy - 5, "#ff8aa0")
-- (apron peeks above counter)
local ap = c:rect(cx - 8, cy + 1, cx + 8, cy + 3); GX.lit(c, ap, R6(CREAM), { R = 3, tex = 0, rimlight = true })
c:fillMask(c:rect(cx - 8, cy + 1, cx + 8, cy + 1), "#e8485c")

-- coconut cups on counter
local function cup(x, y, col, straw)
  local m = mk(); E(m, x, y, 6, 5); m:cut(c:rect(x - 8, y - 7, x + 8, y - 3)); m = GX.rough(m, x, 1)
  GX.lit(c, m, R6({ hi = "#d8985c", base = "#8a5438", shade = "#5e3638", deep = "#38222e" }), { R = 4, tex = .2, seed = x, rimlight = true })
  c:fillMask(c:rect(x - 5, y - 4, x + 5, y - 3), INK); c:fillMask(c:rect(x - 4, y - 4, x + 4, y - 4), col)
  c:fillMask(c:rect(x + 2, y - 11, x + 2, y - 4), straw); c:px(x + 3, y - 11, straw)
end
cup(296, 170, "#ff8aa0", "#fff0c0"); cup(314, 170, "#ffd060", "#58c8d8"); cup(396, 170, "#a0e078", "#fff0c0"); cup(416, 170, "#ff8aa0", "#58c8d8")
-- hanging lanterns (glowing flat rings)
local function lantern(x, y, r, glowr)
  for yy = y - glowr, y + glowr do for xx = x - glowr, x + glowr do
    local dd = sqrt((xx - x) ^ 2 + (yy - y) ^ 2); local cur = c:get(xx, yy)
    if cur and dd > r and dd <= glowr and not (xx == x and false) then
      c:px(xx, yy, GX.mix(cur, "#ffa040", dd < r + 3 and .38 or .2))
    end
  end end
  local m = mk(); E(m, x, y, r, r + 1); c:rim(m, INK)
  m:each(function(xx, yy) local dd = sqrt((xx - x) ^ 2 + ((yy - y) * r / (r + 1)) ^ 2); c:px(xx, yy, dd < r * .35 and "#fffbe0" or dd < r * .6 and "#ffe890" or dd < r * .85 and "#ffb848" or "#e87a38") end)
end
for _, lx in ipairs{ 302, 334, 380, 418 } do c:fillMask(c:rect(lx, 135, lx, 140), INK); lantern(lx, 144, 4, 11) end

-- bunting from pole to roof
local function bunting(x0, y0, x1, y1, sag, cols)
  local n = 9
  for i = 0, 40 do local t = i / 40; local x = floor(x0 + (x1 - x0) * t); local y = floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t)); c:px(x, y, INK) end
  for i = 1, n do
    local t = i / (n + 1); local x = floor(x0 + (x1 - x0) * t); local y = floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t))
    local col = cols[(i - 1) % #cols + 1]
    c:px(x - 1, y + 1, INK); c:px(x, y + 1, col); c:px(x + 1, y + 1, INK); c:px(x - 1, y + 2, col); c:px(x, y + 2, col); c:px(x + 1, y + 2, col); c:px(x - 1, y + 3, INK); c:px(x, y + 3, col); c:px(x + 1, y + 3, INK); c:px(x, y + 4, INK)
  end
end
bunting(236, 112, 284, 104, 8, { "#f0585c", "#ffd060", "#58c8d8", "#f080a8" })

---------------------------------------------------------------- pole lantern + stone table
c:fillMask(c:rect(238, 124, 240, 214), INK); c:fillMask(c:rect(239, 124, 239, 214), WOOD.base); c:fillMask(c:rect(238, 124, 238, 214), WOOD.hi)
lantern(239, 118, 6, 16)

---------------------------------------------------------------- barrel + turtle customer
local bsh = mk(); E(bsh, 162, 250, 34, 4); bsh = GX.rough(bsh, 3, 1); c:fillMask(bsh, "#8a5a78")
local bar = mk()
for y = 196, 250 do local t = (y - 196) / 54; local hw = floor(22 + 4 * sin(t * pi)); for x = 162 - hw, 162 + hw do bar:set(x, y) end end
GX.lit(c, GX.rough(bar, 11, 1), R6(WOOD2), { R = 22, tex = .45, sc = 2, seed = 11, rimlight = true,
  fn = function(x, y) return ((x // 6) % 2) * .07 - .035 end })
for _, by in ipairs{ 204, 240 } do for x = 136, 188 do if bar:has(x, by) then c:px(x, by, "#6a7098"); c:px(x, by + 1, STONE.shade); c:px(x, by + 2, STONE.deep); if bar:has(x, by - 1) then c:px(x, by - 1, STONE.hi) end end end end
local top = mk(); E(top, 162, 196, 24, 5); GX.lit(c, top, R6(WOOD), { R = 6, tex = .3, seed = 12, rimlight = true })
-- turtle
local tx, ty = 160, 192
for _, lx in ipairs{ tx - 14, tx + 8 } do blob(lx + 3, ty, 5, 3, TURT, lx, { R = 3, tex = 0, rimlight = true }) end
local shellm = mk(); E(shellm, tx, ty - 14, 20, 15); shellm:cut(c:rect(tx - 24, ty - 1, tx + 24, ty + 6)); shellm = GX.rough(shellm, 23, 1)
GX.lit(c, shellm, R6(SHELL), { R = 15, tex = .35, sc = 3, seed = 23, rimlight = true,
  fn = function(x, y) local gx2 = ((x + 3) // 9 + ((y // 7) % 2) * .5); local e = ((x + 3) % 9 == 0 or (y % 7 == 0)) and -.2 or 0; return e end })
c:fillMask(c:rect(tx - 20, ty - 2, tx + 20, ty - 1), "#e8c878")
local hd = blob(tx + 24, ty - 16, 8, 7, TURT, 24, { R = 7, tex = .25, rimlight = true })
c:fillMask(c:rect(tx + 24, ty - 20, tx + 25, ty - 18), INK); c:px(tx + 24, ty - 20, "#fffae8"); c:fillMask(c:rect(tx + 27, ty - 13, tx + 30, ty - 13), INK); c:px(tx + 28, ty - 12, "#ff8aa0")
blob(tx + 14, ty - 10, 5, 4, TURT, 26, { R = 4, tex = 0, rimlight = true })
-- straw sun hat (quirk: small paper hat is a floppy straw, not pointed)
local hat = mk(); E(hat, tx + 24, ty - 24, 11, 3); local crn = mk(); E(crn, tx + 24, ty - 26, 6, 5)
GX.lit(c, hat, R6(THATCH), { R = 4, tex = .3, seed = 7, rimlight = true }); GX.lit(c, crn, R6(THATCH), { R = 4, tex = .3, seed = 8, rimlight = true })
c:fillMask(c:rect(tx + 19, ty - 25, tx + 29, ty - 24), "#e8485c")
-- mug in flipper
local mug = c:rect(tx + 15, ty - 14, tx + 22, ty - 6); GX.lit(c, mug, R6({ hi = "#ffe090", base = "#e0a048", shade = "#a06048", deep = "#603848" }), { R = 4, tex = 0, rimlight = true })
c:fillMask(c:rect(tx + 15, ty - 14, tx + 22, ty - 13), "#fffae8")

-- round stone table
local tb = mk(); E(tb, 212, 202, 24, 5); GX.lit(c, GX.rough(tb, 31, 1), R6(STONE), { R = 8, tex = .4, sc = 3, seed = 31, rimlight = true })
c:fillMask(c:rect(211, 207, 213, 238), INK); c:fillMask(c:rect(212, 207, 212, 238), STONE.shade); c:fillMask(c:rect(211, 207, 211, 238), STONE.base)
local fo = mk(); E(fo, 212, 240, 10, 2); GX.lit(c, fo, R6(STONE), { R = 3, tex = 0, rimlight = true })
cup(204, 200, "#ffd060", "#58c8d8")

---------------------------------------------------------------- right palm (foreground)
palmTrunk({462, 270}, {440, 190}, {420, 118}, 6, 4, 33)
crown(420, 116, {172, 148, 118, 82, 40, 10}, 38, 18, 60); nuts{ {416, 122}, {423, 123}, {419, 127} }

---------------------------------------------------------------- foreground: log, shells, starfish
local lg = mk(); for x = 0, 62 do for y = 238 - floor((GX.vn(x, 0, 8, 2)) * 2), 260 - floor(GX.vn(x, 1, 8, 3) * 2) do lg:set(x, y) end end
GX.lit(c, GX.rough(lg, 3, 1), R6({ hi = "#e8b888", base = "#b87850", shade = "#7e4a4c", deep = "#46283e" }), { R = 10, tex = .5, sc = 2, seed = 3, rimlight = true, fn = function(x, y) return (y % 5 == 0) and -.12 or 0 end })
local ring = mk(); E(ring, 62, 249, 5, 11); GX.lit(c, ring, R6({ hi = "#ffe0a8", base = "#e8b070", shade = "#a8704c", deep = "#5e3a44" }), { R = 8, tex = .2, seed = 4, rimlight = true })
for r = 3, 9, 3 do for a = 0, 20 do c:px(62 + floor(cos(a / 3) * r * .5 + .5), 249 + floor(sin(a / 3) * r + .5), "#a8704c") end end
local function shell(x, y, R, seed)
  local m = mk(); E(m, x, y, 9, 8); m:cut(c:rect(x - 12, y + 4, x + 12, y + 10)); m = GX.rough(m, seed, 1)
  GX.lit(c, m, R6(R), { R = 8, tex = .15, seed = seed, rimlight = true, fn = function(px, py) return (floor(math.atan(py - y - 5, px - x) * 6) % 2) * .13 - .065 end })
end
shell(206, 252, PINK, 3); shell(262, 254, CREAM, 6); shell(300, 250, { hi = "#ffd8a0", base = "#f0985c", shade = "#b8584c", deep = "#683048" }, 9)
local function star(x, y)
  local pts = {}
  for k = 0, 9 do local r = (k % 2 == 0) and 9 or 4; local a = -pi / 2 + k * pi / 5; pts[#pts + 1] = { x + floor(r * cos(a) + .5), y + floor(r * sin(a) + .5) } end
  local m = c:poly(pts); GX.lit(c, m, R6({ hi = "#ffb48a", base = "#f0642e", shade = "#c4402e", deep = "#6e2038" }), { R = 6, tex = .3, sc = 2, seed = 5, rimlight = true })
end
star(100, 250); star(372, 246)
-- coconut-drink bowl w/ pink fruit at barrel foot
shell(130, 246, { hi = "#ff9a70", base = "#d84a4a", shade = "#983a58", deep = "#582444" }, 12)
-- grass tufts
for _, p in ipairs{ {120,232},{440,236},{280,232},{70,224},{470,230} } do GX.tuft(c, p[1], p[2], { hi = "#c4d868", base = "#78a848", shade = "#3e784a", deep = "#245040" }) end

---------------------------------------------------------------- music notes
local function note(x, y)
  c:fillMask(c:rect(x, y + 6, x + 3, y + 8), INK); c:fillMask(c:rect(x + 1, y + 6, x + 2, y + 7), "#fff0c0")
  c:fillMask(c:rect(x + 3, y, x + 3, y + 6), INK); c:fillMask(c:rect(x + 3, y, x + 6, y + 1), INK); c:px(x + 4, y + 1, "#fff0c0")
end
note(105, 144); note(124, 160); note(200, 150); note(176, 130)

---------------------------------------------------------------- gold stitched hem top and bottom
c:hem(1, 0, 479); c:hem(268, 0, 479)

c:save{ aseprite = d.."/out/haven-driftwood-tavern.aseprite", png = d.."/out/haven-driftwood-tavern.png", scale = 1 }
