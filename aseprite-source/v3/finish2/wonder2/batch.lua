-- wonder2 batch: nine WONDER pictures, 480x270. Param name=<picture> (or all)
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local V3 = d .. "/../.."
local HP = dofile(V3 .. "/lib/hp.lua")
local GX = dofile(V3 .. "/gather/gx.lua")
local H = GX.X.hash
local floor, max, min, sin, cos, sqrt, abs = math.floor, math.max, math.min, math.sin, math.cos, math.sqrt, math.abs
local INK, CREAM, GOLD = "#2b1c26", "#fff1cf", "#f2b84a"
local mix = GX.mix
local function RR(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local WHITE = RR("#fff4e0", "#efe2d0", "#c9b8b0", "#9a8a92")
local BLACK = RR("#6a5a70", "#3d3042", "#2e2334", "#241c28")

local c
local function R(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
local function P(x, y, h) c:px(x, y, h) end
local function fill(m, h) c:fillMask(m, h) return m end
local function disc(m, cx, cy, rx, ry)
  ry = ry or rx
  cx, cy = floor(cx + .5), floor(cy + .5)
  for y = floor(cy - ry), floor(cy + ry) do for x = floor(cx - rx), floor(cx + rx) do
    if ((x - cx) / (rx + .3)) ^ 2 + ((y - cy) / (ry + .3)) ^ 2 <= 1 then m:set(x, y) end
  end end
  return m
end
local function E(cx, cy, rx, ry) return disc(HP.mask(), cx, cy, rx, ry) end
local function spline(pts, r0, r1, rf, steps)
  local m = HP.mask()
  local n = #pts
  local total = (n - 1) * (steps or 14)
  for s = 0, total do
    local u = s / total * (n - 1)
    local i = min(n - 2, floor(u)); local t = u - i
    local p0, p1, p2, p3 = pts[max(1, i)], pts[i + 1], pts[i + 2], pts[min(n, i + 3)]
    local function cr(a, b, c2, d2) return .5 * ((2 * b) + (-a + c2) * t + (2 * a - 5 * b + 4 * c2 - d2) * t * t + (-a + 3 * b - 3 * c2 + d2) * t * t * t) end
    local x, y = cr(p0[1], p1[1], p2[1], p3[1]), cr(p0[2], p1[2], p2[2], p3[2])
    local tt = s / total
    local r = rf and rf(tt) or (r0 + (r1 - r0) * tt)
    disc(m, x, y, max(.5, r), max(.5, r))
  end
  return m
end
-- flat architecture shading: noise + left/top highlight, right/bottom shade
local function flat(m, Rm, seed, o)
  o = o or {}
  if o.ink ~= false then c:rim(m, INK) end
  m:each(function(x, y)
    local n = GX.vn(x, y, o.sc or 4, seed) * .6 + H(x, y, seed) * .4
    local col = Rm.base
    if n > (o.hiT or .7) then col = Rm.hi elseif n < (o.shT or .3) then col = Rm.shade end
    if not m:has(x - 2, y - 1) or not m:has(x - 1, y - 2) then col = Rm.hi end
    if not m:has(x + 2, y + 1) or not m:has(x + 1, y + 2) then col = Rm.shade end
    if not m:has(x + 1, y + 1) and not m:has(x + 2, y + 2) then col = Rm.deep end
    P(x, y, col)
  end)
  return m
end
local function lit(m, Rm, seed, o)
  o = o or {}
  o.seed = seed; o.R = o.R or 6
  return GX.lit(c, m, GX.ramp6(Rm), o)
end
local function stars(y0, y1, n, seed, cols)
  for i = 1, n do
    local x, y = floor(H(i, seed, 1) * 478) + 1, y0 + floor(H(i, seed, 2) * (y1 - y0))
    local col = cols[1 + floor(H(i, seed, 3) * #cols)]
    P(x, y, col)
    if H(i, seed, 4) < .12 then P(x + 1, y, col); P(x - 1, y, col); P(x, y + 1, col); P(x, y - 1, col) end
  end
end
local function sky(cols, y0, y1, seed, shaft, lift) GX.bands(c, y0, y1, cols, seed, .12, shaft, lift) end
local function ridge(fn, col, ybot, seedcol)
  for x = 0, 479 do for y = floor(fn(x)), ybot do P(x, y, col) end end
end
local function tint(m, col, t) m:each(function(x, y) local o = c:get(x, y); if o then P(x, y, mix(o, col, t)) end end) end
local function sag(x0, y0, x1, y1, s, n)
  local pts = {}
  for i = 0, n do local t = i / n; pts[#pts + 1] = { floor(x0 + (x1 - x0) * t + .5), floor(y0 + (y1 - y0) * t + s * 4 * t * (1 - t) + .5) } end
  return pts
end
local function glow(cx, cy, r, col, t) -- hard-pixel banded halo over what is there
  for k = 3, 1, -1 do
    local m = E(cx, cy, r * k / 3 * 1.3, r * k / 3 * 1.3)
    tint(m, col, t * (4 - k) / 3 * .9)
  end
end
local function foot() c:hem(2, 0, 479); c:hem(267, 0, 479) end
local function tuft(x, y, Rm) GX.tuft(c, x, y, Rm) end
local GRASS = RR("#9ad45a", "#5fae48", "#3f8442", "#2a5c3c")

---------------------------------------------------------------- 1 lighthouse of the lost lantern
local function lighthouse()
  sky({ "#2a2058", "#3d2a72", "#5a3586", "#8a4690", "#c25f86", "#ee8a78", "#ffb877", "#ffd88a" }, 0, 172, 3)
  stars(0, 90, 70, 5, { "#ffe9b0", "#ffd0e0", "#c8d0ff" })
  -- crescent moon
  local mn = E(70, 44, 14, 14); mn:cut(E(77, 40, 12, 12)); fill(mn, "#ffeaa8")
  -- clouds
  for _, cl in ipairs({ { 330, 60, 40 }, { 120, 108, 50 }, { 410, 112, 34 } }) do
    local m = HP.mask(); for i = 0, 3 do disc(m, cl[1] + i * cl[3] / 3 - cl[3] / 2, cl[2] - (i % 2) * 3, cl[3] / 4, 4) end
    fill(m, "#7a4a8c"); fill(m:shift(0, -2):cut(m:shift(0, 1)), "#e8909a")
  end
  ridge(function(x) return 168 + floor(3 * sin(x / 20)) end, "#8a4a82", 172)
  -- sea
  for y = 172, 269 do for x = 0, 479 do
    local t = (y - 172) / 98
    local cols = { "#e8826e", "#b8587e", "#8a4880", "#5c3a7c", "#3e2e6c", "#2c2458" }
    local i = 1 + floor((t + (GX.vn(x, y * 2.4, 14, 9) - .5) * .25) * 6); i = max(1, min(6, i))
    P(x, y, cols[i])
  end end
  -- far island
  ridge(function(x) if x < 40 or x > 140 then return 999 end return 166 - floor(8 * sin((x - 40) / 100 * 3.1416)) end, "#5a3a78", 174)
  -- beams across the dusk (before tower so tower sits over)
  local bl = HP.poly({ { 240, 96 }, { 0, 62 }, { 0, 110 } }):copy()
  local br = HP.poly({ { 240, 96 }, { 479, 60 }, { 479, 112 } })
  for _, b in ipairs({ bl, br }) do b:each(function(x, y) if y < 172 then local o = c:get(x, y); if o then P(x, y, mix(o, "#ffe49a", .42 - abs(x - 240) / 700)) end end end) end
  -- headland rock
  local rock = HP.poly({ { 120, 230 }, { 160, 205 }, { 205, 196 }, { 275, 196 }, { 320, 206 }, { 360, 230 }, { 380, 262 }, { 100, 262 } })
  rock = GX.rough(rock, 4, 2)
  lit(rock, RR("#d09a8a", "#8c5e7c", "#5e4272", "#3a2c5c"), 7, { R = 14, tex = .6 })
  -- tower
  local tw = HP.mask()
  for y = 100, 200 do
    local t = (y - 100) / 100; local hw = floor(8 + t * 14)
    for x = 240 - hw, 240 + hw do tw:set(x, y) end
  end
  c:rim(tw, INK)
  tw:each(function(x, y)
    local t = (y - 100) / 100; local hw = 8 + t * 14
    local s = (x - 240) / hw
    local red = floor((y - 100) / 15) % 2 == 0
    local Rm = red and RR("#f47a6a", "#c93f56", "#8e2a52", "#5e1e46") or RR("#fff1cf", "#f2dcb4", "#caa68e", "#9a7a84")
    local col = Rm.base
    if s < -.55 then col = Rm.hi elseif s > .35 then col = Rm.shade end
    if s > .8 then col = Rm.deep end
    if (y - 100) % 15 == 0 then col = Rm.deep end
    P(x, y, col)
  end)
  -- door and little windows
  fill(R(235, 186, 245, 200), INK); fill(R(236, 187, 244, 200), "#ffcf70"); c:rim(R(235, 186, 245, 200), INK)
  for _, wy in ipairs({ 130, 160 }) do fill(R(238, wy, 242, wy + 6), INK); fill(R(239, wy + 1, 241, wy + 5), "#ffd98a") end
  -- gallery + lantern room + roof
  local gal = R(222, 92, 258, 99); flat(gal, RR("#8c7a9c", "#5e4e7c", "#463a64", "#2e2650"), 2)
  for x = 223, 257, 4 do fill(R(x, 86, x, 91), INK) end
  fill(R(222, 86, 258, 86), INK)
  local lr = R(228, 72, 252, 91); c:rim(lr, INK); fill(lr, "#ffe48a")
  fill(R(230, 74, 250, 89), "#fff6c8"); fill(R(234, 76, 246, 87), "#ffffd8" == nil and CREAM or CREAM)
  for _, x in ipairs({ 228, 240, 252 }) do fill(R(x, 72, x, 91), "#8e2a52") end
  local roof = HP.poly({ { 225, 72 }, { 255, 72 }, { 240, 56 } }); c:rim(roof, INK); fill(roof, "#c93f56"); fill(HP.poly({ { 225, 72 }, { 240, 72 }, { 240, 56 }, { 236, 60 } }), "#f47a6a")
  fill(R(239, 48, 241, 56), INK); P(240, 47, GOLD); P(240, 48, GOLD)
  glow(240, 80, 40, "#fff0a8", .5)
  -- sea glints from beam
  for i = 1, 60 do local y = 174 + floor(H(i, 3, 3) * 90); local x = 240 + floor((H(i, 5, 3) - .5) * (20 + (y - 172) * .8))
    for k = 0, 2 + floor(H(i, 4, 4) * 4) do P(x + k, y, "#ffd98a") end end
  -- foreground dark rocks + foam
  local fr = GX.rough(HP.poly({ { 0, 270 }, { 0, 232 }, { 40, 226 }, { 90, 240 }, { 130, 270 } }), 8, 2)
  lit(fr, RR("#a8708a", "#6a4a78", "#46345e", "#2e2448"), 9, { R = 12 })
  local fr2 = GX.rough(HP.poly({ { 479, 270 }, { 479, 226 }, { 430, 222 }, { 395, 244 }, { 370, 270 } }), 11, 2)
  lit(fr2, RR("#a8708a", "#6a4a78", "#46345e", "#2e2448"), 12, { R = 12 })
  for x = 100, 380 do if H(x, 5, 6) < .22 then P(x, 261 + floor(H(x, 2, 2) * 2), "#ffdcc0") end end
  -- quirk: crab carrying the lost lantern, left rock
  local cb = E(52, 226, 11, 6); lit(cb, RR("#ff9a6a", "#e0584a", "#a03a4a", "#6a2840"), 14, { R = 5 })
  for _, s in ipairs({ -1, 1 }) do for k = 0, 2 do local lx = 52 + s * (9 + k * 2); fill(R(lx, 228 + k, lx, 231 + k), INK) end end
  P(48, 221, INK); P(48, 220, CREAM); P(56, 221, INK); P(56, 220, CREAM)
  fill(E(66, 214, 4, 4), "#e0584a"); c:rim(E(66, 214, 4, 4), INK)
  fill(R(62, 218, 63, 222), "#e0584a")
  fill(R(65, 197, 69, 208), INK); fill(R(66, 198, 68, 207), "#ffd25a"); fill(R(66, 199, 67, 202), CREAM); fill(R(64, 196, 70, 196), INK)
  glow(67, 202, 14, "#ffe49a", .5)
  fill(R(66, 194, 68, 195), INK)
  c:sparkle(88, 198)
end

---------------------------------------------------------------- 2 mud mosque library
local function mosque()
  sky({ "#4aa8e0", "#6cbce8", "#8ccdee", "#b0dcec", "#d8e6d8", "#f6e8c0" }, 0, 150, 2)
  for _, cl in ipairs({ { 90, 40, 34 }, { 390, 56, 40 }, { 300, 28, 24 } }) do
    local m = HP.mask(); for i = 0, 3 do disc(m, cl[1] + i * cl[3] / 3 - cl[3] / 2, cl[2] - (i % 2) * 2, cl[3] / 4, 5) end
    fill(m, "#fff1d8"); fill(m:shift(0, 3):cut(m), "#e4d4c4")
  end
  ridge(function(x) return 150 + floor(6 * sin(x / 40 + 1)) end, "#e8c48a", 200)
  ridge(function(x) return 164 + floor(5 * sin(x / 30 + 4)) end, "#dcb078", 214)
  -- ground
  GX.ground(c, function(x) return 204 + floor(2 * sin(x / 25)) end, RR("#ffe4a8", "#ecc47c", "#c8955c", "#946a48"), 5, { top = .9, fall = .5 })
  local AD = RR("#f0b878", "#d08e58", "#a8653f", "#774230")
  local AD2 = RR("#f8c88a", "#dca064", "#b27846", "#824e36")
  -- wings
  for _, w in ipairs({ { 106, 196 }, { 284, 374 } }) do
    flat(R(w[1], 140, w[2], 206), AD, 4 + w[1])
    for k = 0, 2 do local wx = w[1] + 14 + k * 26
      local ar = E(wx + 5, 168, 6, 8):copy(); ar:add(R(wx - 1, 168, wx + 11, 188)); c:rim(ar, INK); fill(ar, "#5a3426")
      fill(R(wx + 1, 180, wx + 9, 188), "#ffcf6a"); fill(R(wx + 3, 170, wx + 7, 180), "#ffe49a")
      for sy = 172, 186, 4 do fill(R(wx + 1, sy, wx + 9, sy), "#c43e4e") end -- book spines in shelf
    end
    -- wing top parapet
    flat(R(w[1] - 2, 134, w[2] + 2, 141), AD2, 8)
    for x = w[1], w[2] - 3, 12 do flat(R(x, 128, x + 5, 135), AD2, x) end
  end
  -- domes on wings
  for _, dx in ipairs({ 151, 329 }) do
    local dm = HP.mask(); disc(dm, dx, 130, 20, 20); dm:cut(R(dx - 22, 131, dx + 22, 160))
    c:rim(dm, INK); lit(dm, RR("#9cecf4", "#3c9ed0", "#2a6aa8", "#1e4684"), dx, { R = 14, tex = .25, ink = false })
    fill(R(dx, 100, dx, 110), INK); P(dx, 99, GOLD); P(dx, 100, GOLD)
    fill(R(dx - 3, 108, dx + 3, 110), GOLD)
  end
  -- side towers (tapered, with toron sticks)
  for _, tx in ipairs({ 96, 384 }) do
    local t = HP.mask()
    for y = 56, 206 do local hw = floor(10 + (y - 56) * .045); for x = tx - hw, tx + hw do t:set(x, y) end end
    flat(t, AD, tx)
    for y = 76, 196, 18 do fill(R(tx - 16, y, tx + 16, y), INK); fill(R(tx - 14, y, tx - 11, y), "#5a3426"); fill(R(tx + 11, y, tx + 14, y), "#5a3426") end
    fill(R(tx - 3, 96, tx + 3, 112), INK); fill(R(tx - 2, 97, tx + 2, 111), "#ffd98a")
    local cap = HP.poly({ { tx - 12, 56 }, { tx + 12, 56 }, { tx, 36 } }); c:rim(cap, INK); fill(cap, "#3c9ed0"); fill(HP.poly({ { tx - 12, 56 }, { tx, 56 }, { tx, 36 } }), "#9cecf4")
    P(tx, 33, GOLD); P(tx, 34, GOLD); P(tx, 35, GOLD); P(tx - 1, 34, GOLD); P(tx + 1, 34, GOLD)
  end
  -- central grand facade
  local cf = HP.mask()
  for y = 66, 206 do local hw = floor(42 - max(0, 90 - y) * .0); for x = 198, 282 do cf:set(x, y) end end
  cf:cut(R(198, 66, 205, 72)):cut(R(275, 66, 282, 72))
  flat(cf, AD2, 31)
  for k = 0, 4 do fill(R(206 + k * 16, 60, 213 + k * 16, 66), AD2); c:rim(R(206 + k * 16, 60, 213 + k * 16, 66), INK) end
  fill(R(204, 78, 276, 82), "#2e6ab0"); for x = 204, 276, 4 do P(x, 80, "#9cecf4"); P(x + 2, 79, "#ffe49a") end
  for y = 90, 150, 20 do fill(R(198, y, 202, y), INK); fill(R(278, y, 282, y), INK); fill(R(194, y, 197, y), "#5a3426"); fill(R(283, y, 286, y), "#5a3426") end
  -- big glowing arched door
  local dr = E(240, 176, 14, 18):copy(); dr:add(R(226, 176, 254, 206)); c:rim(dr, "#2e6ab0"); c:rim(dr:copy():grow(1), INK)
  fill(dr, "#ffcf6a"); fill(E(240, 176, 10, 13):add(R(230, 176, 250, 206)):clip(dr), "#fff0b8")
  glow(240, 190, 34, "#ffe49a", .4)
  fill(R(239, 160, 241, 206), "#a8653f"); -- inner pillar of light shelf
  for y = 172, 202, 7 do fill(R(228, y, 252, y), "#c43e4e"); fill(R(232, y + 1, 236, y + 4), "#3c9ed0"); fill(R(244, y + 1, 249, y + 4), "#6cae50") end
  -- steps
  for k = 0, 2 do flat(R(216 - k * 6, 206 + k * 3, 264 + k * 6, 208 + k * 3), AD2, 40 + k) end
  -- cypress + palm
  for _, cx in ipairs({ 60, 424 }) do local m = spline({ { cx, 206 }, { cx, 170 }, { cx, 130 } }, 0, 0, function(t) return 7 - abs(t - .35) * 8 end); lit(m, RR("#6cbc60", "#3c8a4c", "#2a6244", "#1e4a3c"), cx, { R = 6 }) end
  -- quirk: tortoise carrying a book stack
  local tt = E(150, 232, 22, 12); tt:cut(R(120, 233, 190, 250)); lit(tt, RR("#bce08a", "#6cae50", "#3f8442", "#2a5c3c"), 55, { R = 9, tex = .5 })
  fill(E(176, 230, 7, 6), "#8cbe5c"); c:rim(E(176, 230, 7, 6), INK); P(179, 228, INK); P(178, 227, CREAM)
  for _, lx in ipairs({ 138, 162 }) do fill(R(lx, 241, lx + 6, 246), "#6a9a4c"); c:rim(R(lx, 241, lx + 6, 246), INK) end
  local bk = { { "#c43e4e", 24 }, { "#3c9ed0", 20 }, { "#f2b84a", 22 }, { "#6cae50", 16 } }
  for i, b in ipairs(bk) do local by = 222 - i * 6
    flat(R(150 - b[2] / 2 + (i % 2) * 2, by, 150 + b[2] / 2 + (i % 2) * 2, by + 5), RR(mix(b[1], CREAM, .35), b[1], mix(b[1], INK, .3), mix(b[1], INK, .55)), i) end
  -- sand ripples
  for i = 1, 80 do local x, y = floor(H(i, 1, 9) * 478), 212 + floor(H(i, 2, 9) * 56); for k = 0, 4 do P(x + k, y, "#f8dca0") end; for k = 1, 4 do P(x + k, y + 1, "#c8955c") end end
end

---------------------------------------------------------------- 3 panda bamboo grove
local function bamboo(x, y0, y1, w, Rm, seed)
  local m = R(x, y0, x + w, y1); c:rim(m, INK)
  for y = y0, y1 do for xx = x, x + w do
    local s = (xx - x) / w; local col = Rm.base
    if s < .3 then col = Rm.hi elseif s > .7 then col = Rm.shade end
    P(xx, y, col)
  end end
  local ny = y0 + floor(H(seed, 1, 1) * 18)
  while ny < y1 do fill(R(x - 1, ny, x + w + 1, ny + 1), INK); P(x, ny, Rm.hi); fill(R(x + 1, ny + 2, x + 1, ny + 2), Rm.deep); ny = ny + 22 + floor(H(ny, seed, 2) * 10) end
end
local function panda(cx, cy, s, bite)
  local function e(x, y, rx, ry, Rm, seed, ro) local m = E(cx + x * s, cy + y * s, max(1, rx * s), max(1, ry * s)); lit(m, Rm, seed, { R = ro or max(3, floor(ry * s * .6)), tex = .12 }); return m end
  local function eb(x, y, rx, ry, col) fill(E(cx + x * s, cy + y * s, max(1, rx * s), max(1, ry * s)), col) end
  c:rim(E(cx, cy + 4 * s, 44 * s, 48 * s), INK) -- soft body shadow rim guard
  e(-26, 52, 20, 13, BLACK, 31); e(26, 52, 20, 13, BLACK, 32)           -- legs
  e(0, 18, 46, 48, WHITE, 33, 18)                                       -- body
  e(-40, 18, 11, 22, BLACK, 34); e(40, 18, 11, 22, BLACK, 35)           -- arms
  for _, sx in ipairs({ -1, 1 }) do eb(sx * 26, 56, 5, 3, "#6a4a58") end
  e(-24, -42, 11, 11, BLACK, 36, 5); e(24, -42, 11, 11, BLACK, 37, 5)   -- ears
  e(0, -22, 36, 31, WHITE, 38, 14)                                      -- head
  for _, sx in ipairs({ -1, 1 }) do
    local pm = E(cx + sx * 15 * s, cy - 22 * s, max(2, 8 * s), max(3, 11 * s)); lit(pm, BLACK, 40 + sx, { R = 3, tex = 0 })
    eb(sx * 15 + sx * 0, -22, 3, 4, "#fff4e0"); eb(sx * 15, -22, 2, 3, INK); P(floor(cx + (sx * 15 - 1) * s), floor(cy - 24 * s), CREAM)
  end
  eb(0, -10, 8, 6, "#f0e6d8"); eb(0, -14, 5, 3, INK); eb(0, -5, 2, 1, "#8a4a58"); P(floor(cx), floor(cy - 6 * s), INK)
  eb(-18, -8, 5, 3, "#f5a0a0"); eb(18, -8, 5, 3, "#f5a0a0")
  if bite then
    local bm = spline({ { cx - 52 * s, cy + 56 * s }, { cx - 30 * s, cy + 10 * s }, { cx - 10 * s, cy - 8 * s } }, 4, 4)
    bamboo(floor(cx - 14 * s), floor(cy - 6 * s), floor(cy + 42 * s), 8, RR("#c8f08a", "#8cd25a", "#5aa048", "#3a7040"), 77)
  end
end
local function panda_grove()
  sky({ "#c8e8a0", "#b8e0a0", "#a4d6a0", "#8ccaa0" }, 0, 270, 4)
  local layers = { { 8, 5, "#a8d8a8", "#88c098", "#6aa688" }, { 12, 7, "#7cc08a", "#5ca878", "#3f8a68" }, { 18, 9, "#4aa060", "#368850", "#286a48" } }
  for li, L in ipairs(layers) do
    local n = ({ 22, 16, 11 })[li]
    for i = 0, n do
      local x = floor((i + H(i, li, 7) * .8) * 480 / n)
      local y0 = floor(H(i, li, 8) * 20) - 10
      bamboo(x, y0, 240, L[2], RR(mix(L[3], "#ffffd0", .3), L[3], L[4], L[5]), i + li * 9)
      if H(i, li, 9) < .7 then -- leaves
        for k = 1, 4 do local ly = 30 + floor(H(i, k, li) * 100); local dir = (k % 2 == 0) and 1 or -1
          for j = 0, 6 do P(x + dir * (j + 2), ly + floor(j * .5), L[3]); P(x + dir * (j + 2), ly + floor(j * .5) + 1, L[4]) end end
      end
    end
    if li < 3 then for y = 150, 270 do for x = 0, 479 do if (x + y) % 2 == 0 and y < 200 + li * 10 then local o = c:get(x, y); P(x, y, mix(o, "#dff2b0", .12)) end end end end
  end
  -- warm light shafts
  for y = 0, 230 do for x = 0, 479 do if ((x + y * .6) // 22) % 5 == 0 then local o = c:get(x, y); if o then P(x, y, mix(o, "#ffe9a0", .17)) end end end end
  -- ground
  GX.ground(c, function(x) return 212 + floor(3 * sin(x / 18)) end, RR("#bce86a", "#7cc048", "#4a9040", "#2e6a3c"), 6, { top = .9, fall = .55 })
  for i = 1, 36 do tuft(floor(H(i, 1, 4) * 470) + 4, 220 + floor(H(i, 2, 4) * 44), GRASS) end
  -- fallen bamboo leaves
  for i = 1, 40 do local x, y = floor(H(i, 5, 5) * 470), 218 + floor(H(i, 6, 5) * 46); for k = 0, 3 do P(x + k, y - floor(k / 2), "#e8d070") end end
  -- focal panda
  c:fillMask(E(240, 256, 62, 7), "#3a7a3c")
  panda(240, 170, 1, true)
  -- quirk: a cub with a leaf on its head, on a stump at right
  fill(R(366, 226, 392, 250), "#a8704a"); flat(R(366, 226, 392, 250), RR("#d8a070", "#a8704a", "#7a4a3c", "#523030"), 5)
  fill(R(367, 226, 391, 228), "#e8c088")
  panda(379, 196, .36, false)
  local lf = { { 377, 168 }, { 378, 167 }, { 379, 166 }, { 380, 167 }, { 381, 168 }, { 379, 168 } }
  for _, p in ipairs(lf) do P(p[1], p[2] + 3, "#5fae48") end; P(379, 171, "#9ad45a"); P(380, 171, "#9ad45a")
end

---------------------------------------------------------------- 4 pearl diver cove (underwater)
local function pearl()
  local function shaft(x, y) return floor((x + y * .55) / 17) % 4 == 0 and y < 200 end
  sky({ "#8ef0e0", "#58d8dc", "#38bcd4", "#2a98c8", "#2278b8", "#1c5aa0", "#18428a" }, 0, 270, 6, shaft, "#d8fff0")
  -- surface ripple
  for x = 0, 479 do local y = 6 + floor(2 * sin(x / 9)); P(x, y, "#e8fff4"); P(x, y - 1, "#bff6ee"); for yy = 0, y - 2 do P(x, yy, "#9ef4ea") end end
  -- sand floor
  GX.ground(c, function(x) return 214 + floor(5 * sin(x / 34 + 1)) end, RR("#fff0c0", "#f2cf8a", "#cf9f68", "#98704c"), 9, { top = .88, fall = .5 })
  -- rock walls left and right
  local function wall(pts, seed)
    local m = GX.rough(HP.poly(pts), seed, 2)
    lit(m, RR("#6aa8c0", "#3e7aa0", "#2c5a88", "#1e3e6c"), seed, { R = 14, tex = .5 })
  end
  wall({ { -4, 40 }, { 70, 60 }, { 90, 130 }, { 130, 200 }, { 150, 250 }, { -4, 270 } }, 3)
  wall({ { 484, 30 }, { 410, 70 }, { 390, 140 }, { 350, 210 }, { 330, 250 }, { 484, 270 } }, 5)
  -- distant fish shoal
  for i = 1, 9 do local fx, fy = 170 + floor(H(i, 1, 2) * 140), 60 + floor(H(i, 2, 2) * 60)
    fill(E(fx, fy, 4, 2), "#ffdc8a"); fill(HP.poly({ { fx + 3, fy }, { fx + 7, fy - 3 }, { fx + 7, fy + 3 } }), "#f2a860"); P(fx - 2, fy - 1, INK) end
  -- coral clusters
  local function coral(x, y, col, n, seed)
    for i = 1, n do
      local a = -1.57 + (i - (n + 1) / 2) * .5
      local m = spline({ { x, y }, { x + cos(a) * 14, y + sin(a) * 14 + 6 }, { x + cos(a) * 26 + (H(i, seed, 1) - .5) * 8, y + sin(a) * 36 } }, 3, 1.4)
      lit(m, RR(mix(col, "#ffffff", .5), col, mix(col, INK, .35), mix(col, INK, .6)), seed + i, { R = 3, tex = .3 })
    end
  end
  coral(170, 226, "#f26a8a", 5, 3); coral(318, 228, "#ffa05a", 5, 6); coral(112, 238, "#c06ae0", 4, 9); coral(372, 236, "#f26a8a", 4, 11)
  -- giant clam
  local lo = E(240, 224, 56, 22); lo:cut(R(170, 190, 310, 213)); lit(lo, RR("#fff0e0", "#e8c8b0", "#b8908c", "#806068"), 21, { R = 14, tex = .4 })
  for k = -4, 4 do local gx = 240 + k * 12; for y = 214, 242 do if lo:has(gx + floor((y - 224) * k * .08), y) then P(gx + floor((y - 224) * k * .08), y, "#a07880") end end end
  local mant = E(240, 205, 50, 12); mant:cut(R(180, 160, 300, 204)); lit(mant, RR("#ffb0d0", "#e87aa8", "#b04e86", "#7a3468"), 22, { R = 6, tex = .5 })
  -- upper shell (open fan, behind)
  local up = HP.poly({ { 188, 204 }, { 176, 160 }, { 200, 128 }, { 240, 118 }, { 280, 128 }, { 304, 160 }, { 292, 204 } })
  up = GX.rough(up, 23, 1)
  local upBack = up:copy()
  c:rim(upBack, INK)
  upBack:each(function(x, y)
    local a = math.atan(x - 240, 210 - y); local idx = floor(a * 7 + 20)
    local v = .55 + (idx % 2 == 0 and .12 or -.05) + (240 - x) / 400 + (H(x, y, 5) - .5) * .1
    local Rm = GX.ramp6(RR("#fff0e0", "#e8c8b0", "#b8908c", "#806068"))
    P(x, y, Rm[GX.idx(max(0, min(1, v)))])
  end)
  -- inside of the open shell: nacre
  local nac = HP.poly({ { 196, 202 }, { 188, 162 }, { 206, 138 }, { 240, 130 }, { 274, 138 }, { 292, 162 }, { 284, 202 } })
  lit(nac, RR("#fff6f0", "#f4d4e8", "#c8a0d0", "#8e70a8"), 24, { R = 16, tex = .2, ink = false })
  -- the pearl
  local pm = E(240, 190, 18, 18)
  glow(240, 190, 50, "#fff6d8", .55)
  lit(pm, RR("#ffffff" == nil and CREAM or "#fffaf0", "#f8ecf0", "#d4b8d8", "#a88ac0"), 25, { R = 12, tex = .1 })
  fill(E(233, 183, 4, 3), "#fffaf0"); P(231, 181, "#ffffff" == nil and CREAM or "#fffaf0"); c:sparkle(268, 160); c:sparkle(212, 172)
  -- quirk: seahorse on the shell rim holding a bubble
  local sh = spline({ { 300, 160 }, { 308, 150 }, { 306, 138 }, { 298, 130 }, { 296, 120 } }, 4, 1.5)
  lit(sh, RR("#ffe08a", "#f2a840", "#c06a38", "#8a4430"), 27, { R = 3, tex = .3 })
  fill(R(292, 114, 296, 117), "#f2a840"); c:rim(R(292, 114, 296, 117), INK); P(296, 116, INK); P(298, 118, "#ffe08a")
  for _, b in ipairs({ { 292, 100, 4 }, { 300, 88, 2 }, { 160, 150, 3 }, { 332, 110, 3 }, { 196, 96, 2 }, { 220, 70, 3 }, { 264, 80, 2 } }) do
    local m = E(b[1], b[2], b[3], b[3]); c:rim(m, "#d8fff8"); P(b[1] - 1, b[2] - 1, "#ffffff" == nil and CREAM or "#fff8e8")
  end
  -- foreground rocks and weed
  for _, x in ipairs({ 60, 90, 420, 450 }) do local m = spline({ { x, 270 }, { x + (x < 240 and 6 or -6), 235 }, { x + (x < 240 and -4 or 4), 205 } }, 5, 2); lit(m, RR("#7cd070", "#3fa050", "#2a7044", "#1e4c3c"), x, { R = 4, tex = .3 }) end
end

---------------------------------------------------------------- 5 pink river dolphin pools
local function dolphin(pts, sc, flip, seed)
  local m = spline(pts, 0, 0, function(t) return sc * (3 + 11 * sin(min(1, t * 1.15) * 3.14 * .85) ^ 1.2) * (t > .9 and (1 - (t - .9) * 5) or 1) end)
  local R5 = RR("#ffc8d8", "#f28aae", "#c4588e", "#8a3a6e")
  lit(m, R5, seed, { R = 8, tex = .25 })
  local n = #pts
  local tail, head = pts[1], pts[n]
  local dir = head[1] > tail[1] and 1 or -1
  -- flukes at tail
  local fl = HP.poly({ { tail[1], tail[2] }, { tail[1] - dir * 10 * sc, tail[2] - 12 * sc }, { tail[1] - dir * 5 * sc, tail[2] + 2 }, { tail[1] - dir * 12 * sc, tail[2] + 10 * sc } })
  c:rim(fl, INK); fill(fl, "#c4588e")
  -- long beak
  local bk = spline({ { head[1], head[2] }, { head[1] + dir * 10 * sc, head[2] + 4 * sc }, { head[1] + dir * 18 * sc, head[2] + 7 * sc } }, 3.5 * sc, 1.6 * sc)
  lit(bk, R5, seed + 1, { R = 3, tex = 0 })
  -- eye + fin
  local ex, ey = head[1] - dir * 2 * sc, head[2] - 4 * sc
  P(floor(ex), floor(ey), INK); P(floor(ex), floor(ey) - 1, CREAM)
  local mid = pts[floor((n + 1) / 2)]
  local fin = HP.poly({ { mid[1] - dir * 4, mid[2] - 12 * sc }, { mid[1] + dir * 5, mid[2] - 15 * sc - 2 }, { mid[1] + dir * 6, mid[2] - 8 * sc } })
  c:rim(fin, INK); fill(fin, "#c4588e")
  fill(HP.poly({ { head[1] - dir * 4, head[2] + 4 }, { head[1] - dir * 12 * sc, head[2] + 10 * sc }, { head[1] - dir * 2, head[2] + 9 * sc } }), "#c4588e")
  return m
end
local function dolphins()
  sky({ "#c8e8b0", "#a8d8a0", "#7cc490", "#4aa078", "#2e7e68" }, 0, 150, 3)
  -- far forest
  ridge(function(x) return 88 + floor(10 * sin(x / 24) + 6 * sin(x / 9)) end, "#5aa070", 160)
  ridge(function(x) return 104 + floor(8 * sin(x / 31 + 2) + 4 * sin(x / 11)) end, "#3a8460", 170)
  -- water
  for y = 150, 269 do for x = 0, 479 do
    local t = (y - 150) / 120; local cols = { "#6cc8a0", "#4eb090", "#389480", "#2a7a74", "#226468", "#1c5058" }
    local i = max(1, min(6, 1 + floor((t + (GX.vn(x * .3, y, 8, 4) - .5) * .25) * 6))); P(x, y, cols[i])
  end end
  -- ripples
  for i = 1, 70 do local x, y = floor(H(i, 1, 6) * 460), 156 + floor(H(i, 2, 6) * 112); local w = 4 + floor(H(i, 3, 6) * 8); for k = 0, w do P(x + k, y, "#9ee8c0") end end
  -- distant and mid tree trunks
  local TR = RR("#c8946a", "#8c5e48", "#5e3c3c", "#3a2634")
  for i, x in ipairs({ 30, 100, 170, 310, 390, 450 }) do
    local w = 8 + (i % 3) * 3; local m = R(x, -2, x + w, 178 + (i % 2) * 8)
    flat(m, TR, 70 + i, { sc = 2 })
    for k = 1, 6 do local vx = x + 2 + k; local vl = 20 + floor(H(i, k, 5) * 70); for y = 0, vl do if H(vx, y, 1) < .9 then P(vx, 80 + y, "#4aa05a") end end; break end
    for s = 0, 5 do local rx = x + w + s; fill(R(rx, 178 + (i % 2) * 8 - s, rx, 184 + (i % 2) * 8), TR.shade) end
  end
  -- canopy leaves along top
  for i = 0, 8 do GX.foliage(c, i * 60 + 10, 6, 40, 20, RR("#9ad45a", "#4aa048", "#2e7a44", "#1e5438"), 40 + i) end
  -- reflection of dolphin (dark, hard pixels) first
  local refl = E(240, 238, 52, 10); for y = 230, 246 do for x = 190, 290 do if refl:has(x, y) and (y % 2 == 0) then P(x, y, "#4a7c80") end end end
  -- lily pads
  for _, lp in ipairs({ { 80, 222, 16 }, { 120, 244, 12 }, { 350, 236, 18 }, { 420, 218, 12 }, { 30, 248, 14 }, { 290, 256, 10 } }) do
    local m = E(lp[1], lp[2], lp[3], max(3, lp[3] // 3)); lit(m, RR("#b8f08a", "#6cc058", "#3f9050", "#2a6a44"), lp[1], { R = 4, tex = .3 })
    P(lp[1] + lp[3] // 2, lp[2], "#2e7a44")
  end
  -- focal leaping dolphin (centre) + second dolphin smaller behind
  dolphin({ { 160, 215 }, { 190, 168 }, { 232, 130 }, { 275, 138 }, { 310, 176 } }, 1.0, 1, 51)
  dolphin({ { 378, 196 }, { 360, 174 }, { 338, 168 }, { 320, 184 } }, .55, -1, 61)
  -- splash droplets
  for i = 1, 22 do local a = H(i, 2, 8) * 6.28; local r = 6 + H(i, 3, 8) * 14; local x, y = 160 + cos(a) * r, 220 + sin(a) * r * .5 - 4
    if y < 224 then P(floor(x), floor(y), i % 3 == 0 and "#ffffff" == nil and CREAM or "#d8fff0"); end end
  for x = 140, 190 do if H(x, 1, 2) < .5 then P(x, 221, "#e8fff0") end end
  -- quirk: frog on lily pad
  local fg = E(350, 230, 6, 4); lit(fg, RR("#d8f070", "#8ccc48", "#4e9a44", "#2e6a3c"), 77, { R = 3, tex = 0 })
  fill(R(346, 224, 347, 226), "#8ccc48"); fill(R(353, 224, 354, 226), "#8ccc48"); P(346, 224, INK); P(354, 224, INK); P(346, 223, "#ffe49a"); P(354, 223, "#ffe49a")
  -- sun-dapple glints
  for i = 1, 30 do local x, y = floor(H(i, 7, 7) * 470), 160 + floor(H(i, 8, 7) * 100); c:px(x, y, "#e8ffd0"); c:px(x + 1, y, "#e8ffd0") end
end

---------------------------------------------------------------- 6 prayer flag pass
local function flags()
  sky({ "#5a9ae0", "#78b4ec", "#98c8f0", "#b8d8f4", "#d8e8f4", "#f4ecd8" }, 0, 170, 5)
  for _, cl in ipairs({ { 80, 40, 40 }, { 400, 30, 46 }, { 250, 22, 26 } }) do
    local m = HP.mask(); for i = 0, 3 do disc(m, cl[1] + i * cl[3] / 3 - cl[3] / 2, cl[2] - (i % 2) * 2, cl[3] / 4, 5) end
    fill(m, "#fff6e0"); fill(m:shift(0, 3):cut(m), "#c8d8ec")
  end
  -- snow peaks
  local function peak(cx, top, base, hw, seed, Rm)
    local m = GX.rough(HP.poly({ { cx, top }, { cx + hw, base }, { cx - hw, base } }), seed, 1)
    c:rim(m, "#4a5a88")
    m:each(function(x, y)
      local s = (x - cx) / max(1, hw * (y - top) / (base - top))
      local n = GX.vn(x, y, 5, seed)
      local col = s < -.05 + (n - .5) * .3 and (y < top + (base - top) * .55 and "#fff6e0" or "#dce4f0") or (y < top + (base - top) * .5 and "#b8c4e4" or "#7c88b8")
      if y > top + (base - top) * .62 + (n - .5) * 14 then col = s < 0 and "#8a90b8" or "#5e6694" end
      P(x, y, col)
    end)
  end
  peak(110, 70, 176, 90, 3); peak(380, 54, 176, 110, 6); peak(250, 86, 176, 80, 9); peak(470, 100, 176, 60, 12); peak(8, 96, 176, 70, 15)
  -- mid ridge and pass
  GX.ground(c, function(x) return 176 + floor(8 * sin(x / 40 + 2)) end, RR("#e0c498", "#a88460", "#7a5a50", "#4e3a40"), 4, { top = .8, fall = .5 })
  GX.ground(c, function(x) return 208 + floor(5 * sin(x / 28)) end, RR("#e8d0a0", "#bc9468", "#8a6a58", "#5a4448"), 8, { top = .9, fall = .55 })
  -- poles
  local function pole(x, ytop, ybot, seed)
    local m = R(x, ytop, x + 4, ybot); flat(m, RR("#d8a468", "#a8703e", "#7a4a34", "#523028"), seed, { sc = 2 })
    fill(R(x - 1, ytop - 2, x + 5, ytop), INK); P(x + 2, ytop - 6, GOLD); P(x + 2, ytop - 5, GOLD); P(x + 2, ytop - 4, GOLD); P(x + 1, ytop - 5, GOLD); P(x + 3, ytop - 5, GOLD)
    fill(R(x - 3, ybot - 1, x + 7, ybot + 2), "#8a6a58"); c:rim(R(x - 3, ybot - 1, x + 7, ybot + 2), INK)
  end
  -- stupa (focal)
  local function tier(x0, x1, y0, y1, seed) flat(R(x0, y0, x1, y1), RR("#fff6e0", "#f2e4cc", "#c8aca4", "#8e7684"), seed, { sc = 3 }) end
  tier(190, 290, 220, 232, 1); tier(200, 280, 208, 220, 2); tier(210, 270, 198, 208, 3)
  local dm = E(240, 196, 30, 36); dm:cut(R(200, 197, 280, 240)); lit(dm, RR("#fffaf0", "#f4e8d4", "#cdb0a8", "#907a88"), 4, { R = 22, tex = .15 })
  fill(R(206, 190, 274, 192), "#c43e4e"); fill(R(206, 193, 274, 193), "#8e2a52")
  flat(R(226, 150, 254, 164), RR("#ffe49a", "#f2b84a", "#c07a3a", "#8a4a30"), 6)
  for _, sx in ipairs({ -1, 1 }) do local ex = 240 + sx * 7; fill(R(ex - 3, 155, ex + 2, 158), CREAM); fill(R(ex - 1, 155, ex, 157), INK); P(ex - 3 + (sx > 0 and 0 or 5), 154, INK) end
  fill(R(239, 160, 241, 160), "#c07a3a")
  for k = 0, 5 do local w = 12 - k * 2; flat(R(240 - w // 2 - 1, 144 - k * 5, 240 + w // 2 + 1, 148 - k * 5), RR("#ffe49a", "#f2b84a", "#c07a3a", "#8a4a30"), 10 + k) end
  fill(R(239, 108, 241, 114), "#f2b84a"); c:rim(R(239, 108, 241, 114), INK); local sun = E(240, 104, 4, 4); lit(sun, RR("#ffe49a", "#f2b84a", "#c07a3a", "#8a4a30"), 14, { R = 3, tex = 0 })
  glow(240, 130, 36, "#fff0b0", .3)
  -- poles + string lines
  pole(30, 118, 214, 1); pole(446, 108, 218, 2); pole(120, 150, 212, 3); pole(356, 144, 214, 4)
  local FC = { "#3c7ad8", "#fff1cf", "#e0484e", "#4cb25a", "#f6c240" }
  local function line(x0, y0, x1, y1, sg, off)
    local pts = sag(x0, y0, x1, y1, sg, 60)
    for _, p in ipairs(pts) do P(p[1], p[2], INK) end
    for i = 3, #pts - 3, 3 do
      local p = pts[i]; local k = (i // 3 + off) % 5 + 1
      local fh = 10
      for yy = 1, fh do local wob = floor(sin(i * .6 + yy * .4) * 1.2)
        for xx = 0, 4 do P(p[1] + xx + wob, p[2] + yy, yy > fh - 2 and mix(FC[k], INK, .35) or (xx == 0 and mix(FC[k], CREAM, .3) or FC[k])) end end
      fill(R(p[1], p[2] + 1, p[1] + 4, p[2] + 1), mix(FC[k], INK, .3))
    end
  end
  line(32, 118, 238, 106, 22, 0); line(244, 106, 448, 108, 22, 2)
  line(122, 150, 240, 118, 12, 1); line(240, 118, 358, 144, 12, 3)
  line(32, 124, 122, 152, 8, 4)
  -- foreground rocks, grass, mani stones
  for _, r in ipairs({ { 60, 250, 20, 8 }, { 150, 258, 26, 9 }, { 340, 256, 22, 8 }, { 430, 252, 26, 10 }, { 240, 262, 18, 5 } }) do
    local m = GX.rough(E(r[1], r[2], r[3], r[4]), r[1], 1); lit(m, RR("#c8b090", "#8a7060", "#5e4a58", "#3e3040"), r[1], { R = 5, tex = .5 })
  end
  for i = 1, 16 do tuft(floor(H(i, 4, 4) * 460) + 10, 236 + floor(H(i, 5, 4) * 30), RR("#c8e068", "#8ab858", "#5e8a48", "#3e6040")) end
  -- quirk: yak in a red saddle blanket
  local yk = E(392, 232, 18, 10); lit(yk, RR("#7a5a60", "#4e3a48", "#362a3a", "#261c2c"), 91, { R = 8, tex = .5 })
  fill(R(381, 225, 399, 232), "#e0484e"); c:rim(R(381, 225, 399, 232), INK); for x = 382, 398, 3 do P(x, 229, "#f6c240") end
  for _, lx in ipairs({ 380, 386, 396, 402 }) do fill(R(lx, 240, lx + 2, 246), "#362a3a"); c:rim(R(lx, 240, lx + 2, 246), INK) end
  local hd = E(372, 232, 7, 7); lit(hd, RR("#7a5a60", "#4e3a48", "#362a3a", "#261c2c"), 92, { R = 4, tex = .3 })
  P(369, 230, CREAM); P(369, 231, INK)
  for _, sx in ipairs({ 366, 378 }) do for k = 0, 4 do P(sx + (sx < 372 and -k or k) // 1, 224 - k, "#efe0bc") end end
end

---------------------------------------------------------------- 7 root wrapped temple
local function temple()
  sky({ "#103a34", "#14483c", "#1a5a44", "#206c4c", "#2c8452" }, 0, 270, 2, function(x, y) return ((x - y * .5) // 20) % 6 == 0 and y < 240 end, "#ffe8a0")
  -- far trees
  for i = 0, 12 do local x = i * 40 + 10; local m = R(x, 0, x + 8, 230); flat(m, RR("#4a8a58", "#2e6a48", "#1e4a3c", "#143428"), i, { sc = 2 }) end
  for y = 0, 250 do for x = 0, 479 do if (x * 3 + y) % 7 == 0 and H(x, y, 2) < .1 then P(x, y, "#2a7a50") end end end
  -- god rays
  for y = 0, 240 do for x = 0, 479 do if ((x - y * .45) // 24) % 5 == 0 then local o = c:get(x, y); if o then P(x, y, mix(o, "#ffe8a0", .15)) end end end end
  -- ground
  GX.ground(c, function(x) return 226 + floor(3 * sin(x / 22)) end, RR("#8ad060", "#4a9a48", "#2e6a40", "#1e4a38"), 4, { top = .8, fall = .5 })
  -- stone ramp
  local ST = RR("#d8dcb0", "#9ea888", "#6a7a6c", "#44564e")
  local function tierR(x0, x1, y0, y1, seed) local m = R(x0, y0, x1, y1); flat(m, ST, seed, { sc = 3 })
    for y = y0 + 3, y1 - 2, 6 do for x = x0 + (floor(y / 6) % 2) * 5, x1, 10 do if m:has(x, y) then P(x, y, ST.deep) end end end
    for y = y0 + 3, y1 - 2, 6 do for x = x0, x1 do if m:has(x, y) and H(x, y, seed) < .85 then P(x, y, c:get(x, y)) end end end
    return m end
  tierR(160, 320, 202, 232, 1); tierR(178, 302, 172, 202, 2); tierR(196, 284, 142, 172, 3); tierR(212, 268, 112, 142, 4); tierR(226, 254, 88, 112, 5)
  -- moss patches
  for y = 88, 232 do for x = 160, 320 do local o = c:get(x, y); if o and (o == ST.base or o == ST.hi) and GX.vn(x, y, 6, 3) > .62 then P(x, y, o == ST.hi and "#9ed070" or "#5aa050") end end end
  -- doorway with warm glow
  local dr = E(240, 202, 11, 14); dr:add(R(229, 202, 251, 232)); dr:clip(R(229, 190, 251, 232)); c:rim(dr, INK); fill(dr, "#ffcf6a"); fill(E(240, 208, 6, 10):clip(dr), "#fff0b8")
  glow(240, 215, 36, "#ffe49a", .38)
  fill(R(236, 222, 244, 232), "#fff0b8")
  -- carved face on top tier
  fill(R(232, 94, 236, 98), INK); fill(R(244, 94, 248, 98), INK); P(233, 95, "#ffe49a"); P(245, 95, "#ffe49a"); fill(R(236, 103, 244, 104), INK)
  -- roots: draped and wrapping
  local RT = RR("#c89a6a", "#8e6244", "#5e3e3c", "#3a2634")
  local roots = {
    { { 232, 60 }, { 210, 110 }, { 186, 160 }, { 160, 210 }, { 140, 250 } },
    { { 246, 70 }, { 270, 110 }, { 296, 160 }, { 326, 212 }, { 348, 252 } },
    { { 200, 20 }, { 214, 70 }, { 240, 130 }, { 226, 190 }, { 208, 240 } },
    { { 280, 10 }, { 262, 70 }, { 244, 120 }, { 262, 180 }, { 286, 244 } },
    { { 60, 0 }, { 80, 70 }, { 110, 130 }, { 124, 200 }, { 112, 256 } },
    { { 420, 0 }, { 400, 80 }, { 372, 140 }, { 360, 200 }, { 372, 256 } },
  }
  for i, r in ipairs(roots) do
    local m = spline(r, 0, 0, function(t) return (i <= 4 and 5 or 9) + t * (i <= 4 and 5 or 6) + sin(t * 9 + i) * 1.2 end)
    lit(m, RT, 30 + i, { R = 5, tex = .5, sc = 3 })
  end
  -- hanging vines + ferns
  for i = 1, 22 do local x = floor(H(i, 1, 3) * 470); local len = 20 + floor(H(i, 2, 3) * 50); for y = 0, len do P(x + floor(sin(y / 6 + i)), y, y % 7 == 6 and "#9ad45a" or "#3f8a48") end end
  for i = 1, 18 do tuft(floor(H(i, 6, 6) * 470) + 4, 236 + floor(H(i, 7, 6) * 28), GRASS) end
  -- canopy edge
  GX.foliage(c, 80, 6, 90, 22, RR("#6cc058", "#368a48", "#245e3c", "#173e30"), 5); GX.foliage(c, 400, 4, 100, 22, RR("#6cc058", "#368a48", "#245e3c", "#173e30"), 6)
  -- quirk: a golden-eyed frog on the temple roof stone, plus fireflies
  local fg = E(240, 83, 8, 5); lit(fg, RR("#d8f070", "#8ccc48", "#4e9a44", "#2e6a3c"), 5, { R = 4, tex = 0 })
  fill(E(235, 78, 2, 2), "#ffe49a"); fill(E(245, 78, 2, 2), "#ffe49a"); P(235, 78, INK); P(245, 78, INK)
  for i = 1, 22 do local x, y = 60 + floor(H(i, 8, 8) * 360), 120 + floor(H(i, 9, 8) * 120); c:sparkle(x, y) ; P(x, y, "#ffe49a") end
  for i = 1, 3 do local x, y = 120 + i * 120, 232 + i * 8; fill(E(x, y, 14, 6), "#8a6a58") end
end

---------------------------------------------------------------- 8 starpath canoe
local function canoe()
  sky({ "#0e1038", "#161850", "#1e2062", "#2a2c78", "#3a3a8a", "#5a4a96", "#8a5aa0", "#c874a0" }, 0, 176, 4)
  stars(0, 160, 130, 7, { "#fff1cf", "#c8d0ff", "#ffd0e0", "#9ec8ff" })
  -- milky band
  for i = 1, 260 do local t = H(i, 1, 1); local x = floor(t * 480); local y = floor(150 - t * 130 + (H(i, 2, 1) - .5) * 40); P(x, y, i % 3 == 0 and "#fff1cf" or "#8a8ad8") end
  -- crescent
  local mn = E(410, 50, 13, 13); mn:cut(E(417, 46, 11, 11)); fill(mn, "#ffeaa8")
  ridge(function(x) if x < 330 or x > 470 then return 999 end return 168 - floor(12 * sin((x - 330) / 140 * 3.1416)) end, "#3a2c6c", 178)
  -- sea
  for y = 176, 269 do for x = 0, 479 do
    local t = (y - 176) / 94; local cols = { "#6a4a98", "#4a3c88", "#34307a", "#262866", "#1c1e56", "#141644" }
    local i = max(1, min(6, 1 + floor((t + (GX.vn(x * .25, y * 1.6, 7, 2) - .5) * .3) * 6))); P(x, y, cols[i])
  end end
  -- star path: gold dotted lane in sky and its glittering reflection in the water
  for i = 0, 28 do local t = i / 28; local x = 240 + floor(sin(t * 3) * 40 + t * 120 - 40) ; local y = 120 - floor(t * 110); c:sparkle(x, y); if i % 4 == 0 then P(x, y, GOLD) end end
  for i = 1, 90 do local y = 180 + floor(H(i, 5, 5) * 88); local x = 240 + floor((H(i, 6, 5) - .5) * (14 + (y - 176) * .6)); P(x, y, "#ffe49a"); P(x + 1, y, "#ffd0a0") end
  -- turtle swimming (quirk), far left
  local tt = E(80, 230, 14, 7); tt:cut(R(60, 232, 100, 244)); lit(tt, RR("#bce08a", "#6cae50", "#3f8442", "#2a5c3c"), 55, { R = 6, tex = .5 })
  fill(E(98, 228, 4, 3), "#8cbe5c"); c:rim(E(98, 228, 4, 3), INK); P(99, 227, CREAM)
  fill(R(70, 235, 78, 238), "#6cae50"); c:rim(R(70, 235, 78, 238), INK)
  -- outrigger float and booms
  local fl = spline({ { 130, 236 }, { 180, 241 }, { 226, 238 } }, 3, 3, function(t) return 2 + 3 * sin(t * 3.14) end)
  lit(fl, RR("#d8a468", "#a8703e", "#7a4a34", "#523028"), 12, { R = 3, tex = .3 })
  for _, x in ipairs({ 168, 208 }) do fill(R(x, 222, x + 1, 238), INK); P(x, 223, "#d8a468") end
  fill(HP.poly({ { 168, 224 }, { 240, 218 }, { 240, 222 }, { 168, 228 } }), "#7a4a34")
  -- hull
  local hull = HP.poly({ { 196, 196 }, { 210, 218 }, { 250, 230 }, { 300, 230 }, { 346, 218 }, { 372, 194 }, { 364, 200 }, { 345, 208 }, { 300, 214 }, { 250, 214 }, { 212, 208 } })
  hull = spline({ { 188, 190 }, { 214, 220 }, { 280, 232 }, { 346, 220 }, { 380, 188 } }, 0, 0, function(t) return 3 + 9 * sin(t * 3.14) end)
  lit(hull, RR("#ffc888", "#d8803f", "#a2503a", "#6a3030"), 14, { R = 8, tex = .4, sc = 3 })
  for x = 214, 346, 14 do for y = 206, 226 do if hull:has(x, y) then P(x, y, "#6a3030") end end end
  for x = 208, 356, 3 do local y = 214; if hull:has(x, y) then P(x, y, GOLD) end end
  -- mast, boom and crab-claw sail
  fill(R(284, 100, 287, 214), INK); fill(R(285, 101, 286, 213), "#d8a468")
  local sail = HP.poly({ { 286, 106 }, { 346, 120 }, { 336, 150 }, { 318, 186 }, { 300, 206 }, { 286, 208 } })
  c:rim(sail, INK)
  sail:each(function(x, y) local n = GX.vn(x, y, 5, 3); local s = (x - 286) / 60; local col = "#f6e4bc"
    if s > .5 then col = "#d8b48c" end; if s > .78 then col = "#b88a74" end
    if (x + y // 2) % 11 == 0 then col = "#c43e4e" end
    P(x, y, col) end)
  fill(R(286, 106, 346, 107), "#c43e4e")
  -- star-compass painted on sail
  c:sparkle(310, 150); fill(R(300, 150, 320, 150), "#c43e4e"); fill(R(310, 140, 310, 160), "#c43e4e"); P(310, 150, GOLD)
  -- bow lantern + glow
  fill(R(368, 176, 372, 186), INK); fill(R(369, 177, 371, 185), "#ffd25a"); fill(R(370, 178, 370, 181), CREAM)
  glow(370, 182, 26, "#ffe49a", .45)
  -- parrot on mast top (quirk)
  local pr = E(292, 96, 5, 6); lit(pr, RR("#ff8a7a", "#e0404a", "#a02a4a", "#6a2040"), 3, { R = 3, tex = 0 })
  fill(R(296, 92, 299, 95), "#f6c240"); P(295, 93, INK); fill(R(289, 100, 291, 106), "#3c7ad8")
  -- creature crew: two curious gulls... a little otter pair? keep: two sleeping geckos on the gunwale
  for _, gx in ipairs({ 236, 250 }) do local g = E(gx, 206, 5, 3); lit(g, RR("#ffe08a", "#8ccc48", "#4e9a44", "#2e6a3c"), gx, { R = 2, tex = 0 }); P(gx + 3, 205, INK) end
  -- wake foam
  for x = 190, 390 do if H(x, 2, 2) < .35 then P(x, 232 + floor(H(x, 3, 3) * 3), "#b8b8f0") end end
  c:sparkle(60, 60); c:sparkle(330, 30)
end

---------------------------------------------------------------- 9 stone head watchers
local function head(cx, by, h, Rm, seed, knot)
  local w = floor(h * .42)
  local m = HP.poly({ { cx - w * .62, by }, { cx + w * .62, by }, { cx + w * .55, by - h * .62 }, { cx + w * .6, by - h * .9 }, { cx + w * .5, by - h }, { cx - w * .5, by - h }, { cx - w * .6, by - h * .9 }, { cx - w * .55, by - h * .62 } })
  flat(m, Rm, seed, { sc = 5 })
  local ey = floor(by - h * .8)
  local bw = floor(w * .5)
  fill(R(cx - bw - 1, ey - 1, cx + bw + 1, ey + 1), Rm.shade)
  for _, sx in ipairs({ -1, 1 }) do fill(R(cx + sx * floor(w * .26) - 2, ey + 2, cx + sx * floor(w * .26) + 2, ey + 5), Rm.deep) end
  local nw = max(2, floor(w * .11))
  fill(R(cx - nw, ey + 2, cx + nw, floor(by - h * .5)), Rm.base); fill(R(cx - nw, ey + 2, cx - nw, floor(by - h * .5)), Rm.hi); fill(R(cx + nw, ey + 2, cx + nw, floor(by - h * .5)), Rm.shade)
  fill(R(cx - nw - 1, floor(by - h * .5), cx + nw + 1, floor(by - h * .5)), Rm.deep)
  fill(R(cx - floor(w * .3), floor(by - h * .36), cx + floor(w * .3), floor(by - h * .36)), Rm.deep)
  fill(R(cx - floor(w * .26), floor(by - h * .36) + 1, cx + floor(w * .26), floor(by - h * .36) + 1), Rm.shade)
  fill(R(cx - floor(w * .2), floor(by - h * .2), cx + floor(w * .2), floor(by - h * .2)), Rm.shade)
  if knot then
    local kw = floor(w * .46)
    local km = R(cx - kw, floor(by - h * 1.14), cx + kw, floor(by - h)); flat(km, RR("#f68a68", "#c8484a", "#8e2e4a", "#5e2040"), seed + 3, { sc = 3 })
  end
end
local function stoneheads()
  sky({ "#6aa4e0", "#8cc0e8", "#b4d4ec", "#f0dcc0", "#ffd0a0", "#ffc088" }, 0, 150, 8)
  -- sun
  glow(150, 140, 60, "#fff0b8", .35)
  local sun = E(150, 138, 16, 16); lit(sun, RR("#fff6c8", "#ffe07a", "#f2b84a", "#e0884a"), 3, { R = 8, tex = 0, ink = false })
  for _, cl in ipairs({ { 340, 50, 50 }, { 70, 40, 34 }, { 430, 90, 38 } }) do
    local m = HP.mask(); for i = 0, 3 do disc(m, cl[1] + i * cl[3] / 3 - cl[3] / 2, cl[2] - (i % 2) * 2, cl[3] / 4, 5) end
    fill(m, "#fff1d8"); fill(m:shift(0, 3):cut(m), "#f2c0a8")
  end
  -- sea
  for y = 150, 190 do for x = 0, 479 do
    local t = (y - 150) / 40; local cols = { "#f8c898", "#7cc0d8", "#4aa0c8", "#3a84b8" }
    local i = max(1, min(4, 1 + floor((t + (GX.vn(x * .3, y, 6, 3) - .5) * .3) * 4))); P(x, y, cols[i])
  end end
  for i = 1, 40 do local x, y = 100 + floor(H(i, 1, 1) * 100), 152 + floor(H(i, 2, 1) * 36); for k = 0, 3 + floor(H(i, 3, 1) * 4) do P(x + k, y, "#fff0b8") end end
  -- grassy hills
  GX.ground(c, function(x) return 186 + floor(8 * sin(x / 60 + 1) + 3 * sin(x / 17)) end, RR("#b8e870", "#74c050", "#3f9048", "#2a6a42"), 3, { top = .88, fall = .6 })
  -- far heads (small, hazy)
  local HZ = RR("#c8b8b0", "#9a8ca0", "#706486", "#504870")
  for _, h in ipairs({ { 40, 196, 40 }, { 108, 192, 44 }, { 380, 192, 44 }, { 440, 198, 40 } }) do head(h[1], h[2], h[3], HZ, h[1], false) end
  -- mid heads
  local MD = RR("#d8ccc0", "#a89aa4", "#766a8c", "#504872")
  head(150, 226, 78, MD, 21, true); head(330, 226, 78, MD, 22, true)
  -- FOCAL central head
  local FD = RR("#ece0d0", "#b8a8b0", "#82749a", "#564a78")
  head(240, 268, 150, FD, 31, true)
  -- shadow of heads on grass
  -- offerings and flowers
  for i = 1, 30 do GX.flower(c, 20 + floor(H(i, 3, 3) * 440), 238 + floor(H(i, 4, 3) * 26), ({ "#ff8aa8", "#ffe07a", "#fff1cf", "#c88aff" })[1 + i % 4]) end
  for i = 1, 20 do tuft(floor(H(i, 7, 7) * 460) + 10, 234 + floor(H(i, 8, 7) * 30), GRASS) end
  -- quirk: a small crab-hatted bird perched on the central knot, and a stone bowl of golden fruit
  local bd = E(240, 112, 7, 6); lit(bd, RR("#fff1cf", "#f2b84a", "#c07a3a", "#8a4a30"), 4, { R = 3, tex = 0 })
  fill(R(246, 110, 249, 111), "#e0484e"); P(244, 110, INK); fill(R(236, 116, 238, 118), INK)
  for i = 1, 5 do local fx = 188 + i * 7; fill(E(fx, 262, 4, 4), "#ffcf6a"); c:rim(E(fx, 262, 4, 4), INK); P(fx - 1, 261, CREAM) end
  fill(R(184, 266, 230, 268), "#8a7a8c")
  c:sparkle(200, 60); c:sparkle(310, 80)
end

local SCENES = {
  ["wonder-lighthouse-of-the-lost-lantern"] = lighthouse,
  ["wonder-mud-mosque-library"] = mosque,
  ["wonder-panda-bamboo-grove"] = panda_grove,
  ["wonder-pearl-diver-cove"] = pearl,
  ["wonder-pink-river-dolphin-pools"] = dolphins,
  ["wonder-prayer-flag-pass"] = flags,
  ["wonder-root-wrapped-temple"] = temple,
  ["wonder-starpath-canoe"] = canoe,
  ["wonder-stone-head-watchers"] = stoneheads,
}
local order = { "wonder-lighthouse-of-the-lost-lantern", "wonder-mud-mosque-library", "wonder-panda-bamboo-grove", "wonder-pearl-diver-cove", "wonder-pink-river-dolphin-pools", "wonder-prayer-flag-pass", "wonder-root-wrapped-temple", "wonder-starpath-canoe", "wonder-stone-head-watchers" }
local which = app.params.name or "all"
for _, name in ipairs(order) do
  if which == "all" or which == name then
    c = HP.canvas{ w = 480, h = 270, scale = 1, name = name }
    SCENES[name]()
    foot()
    c:save{ aseprite = d .. "/out/" .. name .. ".aseprite", png = d .. "/out/" .. name .. ".png", scale = 1 }
  end
end
