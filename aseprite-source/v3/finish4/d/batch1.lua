local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt, math.pi
local H, INK = X.hash, GX.INK
local c
local CREAM = "#fff4dc"
local function M() return HP.mask() end
local function D(cx, cy, rx, ry, seed, r)
  local m = GX.disc(M(), cx, cy, rx, ry or rx)
  if seed then m = GX.rough(m, seed, r or 1) end
  return m
end
local function L(m, R, o)
  o = o or {}; o.R = o.R or 8; o.sc = o.sc or 3
  if o.rimlight == nil then o.rimlight = true end
  return GX.lit(c, m, GX.ramp6(R), o)
end
local function sweep(fn, n, rfn)
  local m = M()
  for i = 0, n do local t = i / n; local x, y = fn(t); GX.disc(m, floor(x), floor(y), max(1, floor(rfn(t) + .5))) end
  return m
end
local function eye(x, y, col)
  c:fillMask(c:rect(x, y, x + 1, y + 2), INK); c:px(x, y, col or CREAM)
end
local function water(ey, cols, seed, hi, lo)
  for x = 0, 479 do
    local y0 = ey(x)
    for y = y0, 269 do
      local t = (y - y0) / (270 - y0) + (GX.vn(x * .35, y, 5, seed) - .5) * .35
      c:px(x, y, cols[max(1, min(#cols, floor(t * #cols) + 1))])
    end
  end
  for i = 0, 80 do
    local x, y = floor(H(i, 1, seed) * 470), 150 + floor(H(i, 2, seed) * 118)
    if y > ey(x) + 4 then c:fillMask(c:rect(x, y, x + 5 + floor(H(i, 3, seed) * 12), y), i % 3 == 0 and hi or lo) end
  end
end
local function rockMass(open, R, seed, ylim)
  local m = M()
  for y = 0, (ylim or 270) - 1 do for x = 0, 479 do if not open(x, y) then m:set(x, y) end end end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, GX.ramp6(R), { R = 14, tex = .8, sc = 4, seed = seed, amb = .28, fn = function(x, y) return (H(x // 3, y // 5, 8) - .5) * .18 end })
  m:each(function(x, y) if H(x // 4, y // 2, 12) < .02 and m:has(x + 3, y) then c:px(x, y, R.deep); c:px(x + 1, y, R.deep); c:px(x + 2, y + 1, R.deep) end end)
  return m
end
local function stal(cx, y0, len, hw, seed, R)
  local m = M()
  for y = y0, y0 + len do
    local t = (y - y0) / len; local w = floor(hw * (1 - t) ^ .8 + .5)
    for x = cx - w, cx + w do m:set(x, y) end
  end
  GX.lit(c, GX.rough(m, seed, 1), GX.ramp6(R), { R = hw, tex = .5, sc = 3, seed = seed, rimlight = true })
end
local function gem(cx, cy, rx, ry, R, seed)
  local m = GX.rough(D(cx, cy, rx, ry), seed, 2)
  GX.lit(c, m, GX.ramp6(R), { R = max(rx, ry) * .9, amb = .45, tex = .35, seed = seed, rimlight = true })
  c:px(cx - rx // 2, cy - ry // 2, "#f8ffff")
end
local function flame(x, y, s)
  local m = M(); GX.disc(m, x, y, 3 * s, 3 * s)
  for yy = 0, 8 * s do local w = floor(3 * s * (1 - yy / (8 * s + 1))); for xx = -w, w do m:set(x + xx, y - 3 * s - yy + 3) end end
  c:rim(m, "#7a2c30")
  c:fillMask(m, "#e8602c")
  c:fillMask(GX.disc(M(), x, y + 1, 2 * s, 2 * s), "#f8a83c")
  c:fillMask(GX.disc(M(), x, y + 2, s, s), "#fff0b0")
end
local function spots(m, seed, col)
  m:each(function(x, y)
    local bx, by = x // 5, y // 4
    if H(bx, by, seed) < .2 then
      local lx, ly = x % 5, y % 4
      if lx < 3 and ly < 3 and not (lx == 2 and ly == 2) then c:px(x, y, col) end
    end
  end)
end
local function archm(cx, top, bot, hw)
  local m = M(); GX.disc(m, cx, top + hw, hw, hw)
  for y = top + hw, bot do for x = cx - hw, cx + hw do m:set(x, y) end end
  return m
end
local function bez(a, b, cc, dd, t)
  local u = 1 - t
  return u*u*u*a[1] + 3*u*u*t*b[1] + 3*u*t*t*cc[1] + t*t*t*dd[1], u*u*u*a[2] + 3*u*u*t*b[2] + 3*u*t*t*cc[2] + t*t*t*dd[2]
end

local P = {}

-- tapering curved tongue of flame: returns mask
local function tongue(x, y, h, w, sway, seed)
  return sweep(function(t) return x + sway * sin(t * 2.4 + seed) * t + sway * .5 * t * t, y - t * h end, 40, function(t) return max(.6, w * (1 - t) ^ .75) end)
end
local function fire(x, y, s, seed)
  c:fillMask(D(x, y + 1, 12 * s, 3 * s), "#7a3c3c"); c:fillMask(D(x, y, 9 * s, 2 * s), "#c8503c")
  local defs = { { -7, .7, 5, -3 }, { 7, .8, 5, 4 }, { 0, 1.15, 7, 2 }, { -3, .55, 4, 5 }, { 4, .5, 4, -4 } }
  local ms = {}
  for i, f in ipairs(defs) do ms[i] = tongue(x + f[1] * s, y, 26 * f[2] * s, f[3] * s, f[4] * s, seed + i) end
  for i = 1, #defs do c:rim(ms[i], "#6a2430") end
  for i = 1, #defs do c:fillMask(ms[i], "#e0402c") end
  for i, f in ipairs(defs) do c:fillMask(tongue(x + f[1] * s + 1, y - 1, 22 * f[2] * s, f[3] * s * .66, f[4] * s, seed + i), "#f48a34") end
  for i, f in ipairs(defs) do if i <= 3 then c:fillMask(tongue(x + f[1] * s + 1, y - 2, 15 * f[2] * s, f[3] * s * .36, f[4] * s * .8, seed + i), "#ffd45a") end end
  c:fillMask(D(x, y - 1, 3 * s, 2 * s), "#fff0b0")
  for i = 1, 6 do c:px(x + floor((H(i, 1, seed) - .5) * 30 * s), y - floor(14 * s + H(i, 2, seed) * 26 * s), i % 2 == 0 and "#ffd45a" or "#f48a34") end
end
local function stepslab(m, ramp) end

P["delve-fynbos-fire-trails"] = function()
  GX.bands(c, 0, 200, { "#4a3a78", "#7a4a8c", "#c0587c", "#e8805a", "#f4a84c", "#ffd078" }, 3, .25)
  for i = 5, 1, -1 do c:fillMask(GX.rough(D(120, 160, 16 + i * 14, 12 + i * 9, 40 + i), 1), ({ "#ffe6a0", "#fcd080", "#f8b868", "#f09a60", "#e07c60" })[i]) end
  -- smoke/ash haze streaks
  for i = 0, 5 do c:fillMask(c:rect(20 + i * 70, 30 + (i % 3) * 14, 70 + i * 70, 32 + (i % 3) * 14), "#a0507c") end
  local mt = HP.poly({ { 0, 176 }, { 30, 146 }, { 60, 124 }, { 80, 116 }, { 250, 116 }, { 290, 134 }, { 340, 160 }, { 400, 176 } })
  mt = GX.rough(mt, 21, 1)
  L(mt, { hi = "#c0689c", base = "#7a4a8c", shade = "#563c78", deep = "#3c2c64" }, { R = 40, amb = .4, ink = false, tex = .35 })
  local mt2 = HP.poly({ { 300, 176 }, { 380, 140 }, { 440, 128 }, { 480, 150 }, { 480, 176 } })
  L(GX.rough(mt2, 22, 1), { hi = "#a85a90", base = "#6c4286", shade = "#4c3470", deep = "#34285c" }, { R = 30, amb = .4, ink = false, tex = .3 })
  local gr = { hi = "#d89a5a", base = "#a8643c", shade = "#6c3c3c", deep = "#3c2434" }
  GX.ground(c, function(x) return 178 + floor((GX.vn(x, 0, 30, 3) - .5) * 10) end, gr, 5)
  -- calm cliff: smooth silhouette, big flat strata
  local cm = M()
  for x = 236, 479 do
    local t = (x - 236) / 243
    local top = 66 + floor(64 * (1 - sin(min(1, t * 1.15) * pi / 2) ^ 2) + (GX.vn(x, 0, 40, 7) - .5) * 5)
    for y = top, 214 do cm:set(x, y) end
  end
  local opening = archm(372, 112, 216, 40)
  cm:cut(opening); cm = GX.rough(cm, 8, 1)
  local CR = { hi = "#d89868", base = "#9c5c48", shade = "#643c48", deep = "#38243a" }
  L(cm, CR, { R = 26, tex = .22, sc = 6, amb = .3, rimlight = false })
  for k = 0, 6 do
    local yy = 90 + k * 20
    cm:each(function(x, y) if y == yy + floor(sin(x * .05 + k) * 2) then c:px(x, y, (x // 7) % 5 == 0 and CR.base or CR.shade) end end)
    cm:each(function(x, y) if y == yy + 1 + floor(sin(x * .05 + k) * 2) and (x // 9) % 3 ~= 0 then c:px(x, y, CR.hi) end end)
  end
  c:rim(cm, INK)
  opening:each(function(x, y) local t = (y - 112) / 104; c:px(x, y, t < .45 and "#241830" or (t < .7 and "#4c2438" or (t < .88 and "#8c3c34" or "#d8602c"))) end)
  c:rim(opening, INK)
  for i = 0, 18 do c:px(340 + floor(H(i, 1, 4) * 64), 120 + floor(H(i, 2, 4) * 90), i % 3 == 0 and "#ffe8a0" or "#f8a83c") end
  -- sandy trail
  local B = { { 40, 262 }, { 160, 236 }, { 260, 252 }, { 372, 214 } }
  local trail = sweep(function(t) return bez(B[1], B[2], B[3], B[4], t) end, 300, function(t) return 26 - 15 * t end)
  L(trail, { hi = "#f8d8a0", base = "#d8a070", shade = "#a8704c", deep = "#6c4a40" }, { R = 12, ink = false, rimlight = false, tex = .3 })
  -- flames: far (small) to near (big) along the trail
  local fl = { { .92, -16, 1 }, { .8, 20, 1 }, { .66, -22, 1.2 }, { .52, 24, 1.3 }, { .38, -26, 1.6 }, { .24, 26, 1.8 }, { .1, -22, 2.1 } }
  for i, f in ipairs(fl) do
    local x, y = bez(B[1], B[2], B[3], B[4], f[1])
    fire(floor(x + f[2] * f[3] * .6), floor(y + (f[2] > 0 and 6 or 2) * f[3]), f[3], i * 5)
  end
  local BU = { hi = "#d8c860", base = "#7c9a48", shade = "#4c6a40", deep = "#2c4234" }
  GX.foliage(c, 56, 232, 66, 26, BU, 41); GX.foliage(c, 440, 242, 60, 22, BU, 42)
  local function protea(x, y, r)
    for y2 = y + r, y + 30 do c:px(x, y2, "#4c6a40"); c:px(x + 1, y2, "#7c9a48") end
    for k = 0, 11 do local a = k / 12 * 2 * pi; c:fillMask(D(x + floor(cos(a) * r), y + floor(sin(a) * r * .85), 3, 3), k % 2 == 0 and "#c83c80" or "#ff9ac8") end
    L(D(x, y, r - 1, r - 2, x), { hi = "#ffd0e0", base = "#f06a9c", shade = "#b83c80", deep = "#6c2060" }, { R = r, amb = .4 })
    c:fillMask(D(x, y, r // 2, r // 2), "#f8e0b0")
  end
  protea(36, 214, 11); protea(80, 226, 8); protea(430, 226, 10); protea(462, 232, 7)
  local SB = { hi = "#9cf0c8", base = "#2cb08c", shade = "#1c6c80", deep = "#1c3c64" }
  sweep(function(t) return 100 + t * 16, 218 + t * 10 end, 8, function(t) return 2 end):each(function(x, y) c:px(x, y, SB.shade) end)
  local sb = D(94, 214, 7, 5, 3); L(sb, SB, { R = 5 })
  L(D(87, 211, 4, 4), SB, { R = 4 }); eye(85, 210, "#fff4dc")
  for i = 0, 7 do c:px(82 - i, 212 + floor(i * .3), "#3c2c44") end
  c:fillMask(D(94, 217, 4, 2), "#f8d84a")
end

P["delve-jaguar-root-caves"] = function()
  local AX, AT, AB, AH = 398, 66, 218, 64
  GX.bands(c, 0, 269, { "#8cd0d0", "#a8dcc8", "#c8ecc0", "#f4f0b8" }, 3, .1)
  c:fillMask(GX.disc(M(), 410, 112, 14, 14), "#fff4b0"); c:fillMask(GX.disc(M(), 410, 112, 9, 9), "#ffffd0")
  GX.ground(c, function(x) return 150 + floor((GX.vn(x, 0, 30, 4) - .5) * 30) end, { hi = "#7cc464", base = "#4e9a56", shade = "#34704c", deep = "#244c40" }, 3, { top = .7, fall = .4 })
  for _, t in ipairs{ { 360, 160, 40 }, { 430, 150, 50 } } do
    L(HP.poly({ { t[1] - t[3], 200 }, { t[1], 200 - t[3] * 1.4 }, { t[1] + t[3], 200 } }), { hi = "#78c068", base = "#3c8a54", shade = "#2c6048", deep = "#1c4038" }, { R = 20, ink = false })
  end
  local RK = { hi = "#7a5a68", base = "#563c52", shade = "#3c2a42", deep = "#241a30" }
  local arch = archm(AX, AT, AB, AH)
  rockMass(function(x, y) return arch:has(x, y) or y >= 212 end, RK, 13, 214)
  local FL = { hi = "#c8a478", base = "#8c6a52", shade = "#5c4850", deep = "#3a2c3c" }
  GX.ground(c, function(x) return 212 + floor((GX.vn(x, 0, 18, 9) - .5) * 6) end, FL, 5)
  -- clean light patch: three flat stepped bands, no dither
  local function band(inset, tint)
    local pm = HP.poly({ { 316 + inset, 214 }, { 476 - inset, 214 }, { 479, 269 }, { 262 + inset * 2, 269 } })
    pm:each(function(x, y) c:px(x, y, GX.mix(c:get(x, y) or FL.base, "#ffe8a0", tint)) end)
  end
  band(0, .16); band(10, .16); band(22, .18)
  for k = 0, 3 do c:fillMask(c:rect(340 + k * 24, 224 + k * 10, 346 + k * 24, 225 + k * 10), "#fff4c8") end
  for _, s in ipairs{ { 40, 20, 40, 9 }, { 96, 24, 26, 7 }, { 150, 30, 34, 8 }, { 220, 36, 20, 6 }, { 290, 30, 28, 7 } } do stal(s[1], s[2], s[3], s[4], s[1], { hi = "#9a7a88", base = "#6e5068", shade = "#4c3858", deep = "#2c2038" }) end
  local RT = { hi = "#d8a060", base = "#946040", shade = "#5c3c3c", deep = "#34202c" }
  for i = 1, 15 do
    local x0, len = floor(8 + H(i, 1, 9) * 290), 30 + floor(H(i, 2, 9) * 90)
    local rr = 2 + floor(H(i, 3, 9) * 2)
    L(sweep(function(t) return x0 + sin(t * 3 + i) * 4, t * len end, 30, function(t) return rr * (1 - .5 * t) end), RT, { R = 3, tex = .3, rimlight = false })
  end
  -- stone + big cub
  L(HP.rrect(92, 204, 262, 230, 7), { hi = "#b8b0c0", base = "#7c7490", shade = "#54506c", deep = "#363450" }, { R = 8 })
  local JG = { hi = "#ffc470", base = "#e88a2c", shade = "#b05a28", deep = "#6c3426" }
  local CH = { hi = "#fff0c8", base = "#f8d8a0", shade = "#d8a070", deep = "#a06c4c" }
  local fx, fy, s = 176, 206, 1.45
  local function S(v) return floor(v * s) end
  local tail = sweep(function(t) return fx + S(20) + t * S(52), fy - S(4) - S(36) * sin(t * pi * .9) end, 50, function(t) return S(5) - S(2) * t end)
  L(tail, JG, { R = 5 }); spots(tail, 3, INK)
  c:fillMask(D(fx + S(70), fy - S(30), 4, 4), INK)
  local body = D(fx, fy - S(22), S(22), S(23), 4); L(body, JG, { R = S(20) }); spots(body, 5, INK)
  c:fillMask(D(fx, fy - S(14), S(11), S(13)), CH.base); c:fillMask(D(fx - 3, fy - S(17), S(8), S(7)), CH.hi)
  for _, ex in ipairs{ -1, 1 } do
    local m = D(fx + ex * S(11), fy - S(3), S(8), S(5), 6 + ex); L(m, JG, { R = S(6) }); c:fillMask(c:rect(fx + ex * S(11) - 2, fy - 3, fx + ex * S(11) + 2, fy - 1), CH.base)
    for k = -1, 1 do c:px(fx + ex * S(11) + k * 3, fy - 1, INK) end
  end
  local hy = fy - S(58)
  for _, ex in ipairs{ -1, 1 } do L(D(fx + ex * S(17), hy - S(14), S(7), S(7)), JG, { R = S(6) }); c:fillMask(D(fx + ex * S(17), hy - S(13), S(3), S(4)), "#8c4c4c"); c:px(fx + ex * S(17), hy - S(18), CH.hi) end
  local head = D(fx, hy, S(21), S(17), 6); L(head, JG, { R = S(17) }); spots(head, 8, INK)
  c:fillMask(D(fx, hy + S(8), S(12), S(8)), CH.base)
  c:fillMask(D(fx, hy + S(3), S(5), S(3)), "#8c4c4c"); c:fillMask(c:rect(fx - 1, hy + S(3), fx + 1, hy + S(4)), INK)
  for k = 0, 3 do c:px(fx, hy + S(5) + k, INK) end; c:px(fx - 2, hy + S(9), INK); c:px(fx + 2, hy + S(9), INK)
  eye(fx - S(10), hy - S(5), "#ffe27a"); eye(fx + S(9), hy - S(5), "#ffe27a")
  for k = 0, 5 do c:px(fx - S(14) - k, hy + S(3) + floor(k * .3), CH.shade); c:px(fx + S(14) + k, hy + S(3) + floor(k * .3), CH.shade) end
  L(sweep(function(t) return 292 + t * 26, 220 - 8 * sin(t * pi) end, 14, function(t) return 3 end), { hi = "#fff0a0", base = "#f8d84a", shade = "#d89a38", deep = "#a05c34" }, { R = 3 })
  gem(60, 236, 7, 6, { hi = "#b8fff0", base = "#38d0c4", shade = "#1e8aa0", deep = "#16506c" }, 4)
  gem(84, 248, 5, 4, { hi = "#ffc0e8", base = "#e458b4", shade = "#a42c8c", deep = "#5c1c5c" }, 5)
end

-- log with bark grooves, ringed end cap and tooth marks
local function blog(x0, y0, len, h, bite)
  local WD = { hi = "#d8a060", base = "#946040", shade = "#5c3c3c", deep = "#34202c" }
  local m = HP.rrect(x0, y0, x0 + len, y0 + h, h // 2)
  L(m, WD, { R = h // 2, tex = .3 })
  for i = 0, floor(len / 4) do
    local x = x0 + 8 + floor(H(i, 1, 21) * (len - 24)); local y = y0 + 2 + floor(H(i, 2, 21) * (h - 4))
    for k = 0, 4 + floor(H(i, 3, 21) * 6) do if m:has(x + k, y) then c:px(x + k, y, i % 3 == 0 and WD.hi or WD.deep) end end
  end
  for i = 0, 3 do c:px(x0 + 6 + i * 3, y0 + h // 2 + 1, WD.deep) end
  local ex = x0 + len - h // 2 + 1
  local ring = { "#6c4034", "#c88c50", "#e8b878", "#c88c50", "#f0d098" }
  for k = 1, 5 do local rr = max(1, floor(h / 2 * (1 - (k - 1) * .19))); c:fillMask(D(ex, y0 + h // 2, max(1, rr * .6), rr), ring[k]) end
  c:px(ex, y0 + h // 2, "#6c4034")
  c:rim(D(ex, y0 + h // 2, floor(h * .3), h // 2), INK)
  if bite then for k = 0, 3 do local bx = x0 + 18 + k * 5; c:fillMask(c:rect(bx, y0, bx + 1, y0 + 2), "#2c1c2a"); c:px(bx, y0 + 3, "#e8b878") end end
end

P["delve-beaverdam-tunnels"] = function()
  local WD = { hi = "#d8a060", base = "#946040", shade = "#5c3c3c", deep = "#34202c" }
  GX.bands(c, 0, 118, { "#5a9ad0", "#78b4e0", "#98cae8", "#b8dcee", "#d8ecf0" }, 3, .2)
  for _, cl in ipairs{ { 70, 30, 40, 8 }, { 190, 52, 30, 6 }, { 400, 26, 46, 9 } } do
    c:fillMask(GX.rough(D(cl[1], cl[2], cl[3], cl[4]), cl[1], 1), "#f4f8f0"); c:fillMask(c:rect(cl[1] - cl[3] + 4, cl[2] + 4, cl[1] + cl[3] - 4, cl[2] + 5), "#c4dcec")
  end
  GX.ground(c, function(x) return 98 + floor((GX.vn(x, 0, 18, 6) - .5) * 14) end, { hi = "#5c9a8c", base = "#3c7a74", shade = "#2c5c64", deep = "#1c3c4c" }, 8, { top = .5, fall = .3 })
  water(function(x) return 120 end, { "#4a9cc8", "#3c88b8", "#2e70a0", "#245a88", "#1c4870" }, 6, "#9ad0e8", "#1c4468")
  local cx, by, rx, ry = 300, 204, 170, 104
  local dome = M()
  for x = cx - rx, cx + rx do
    local top = by - floor(ry * sqrt(max(0, 1 - ((x - cx) / rx) ^ 2)) + (GX.vn(x, 0, 8, 4) - .5) * 5)
    for y = top, by do dome:set(x, y) end
  end
  dome = GX.rough(dome, 14, 1)
  L(dome, WD, { R = 46, tex = .5, amb = .3, rimlight = false })
  for i = 0, 380 do
    local x, y = cx - rx + floor(H(i, 1, 5) * rx * 2), 100 + floor(H(i, 2, 5) * 104)
    local len, dy = 8 + floor(H(i, 3, 5) * 10), floor((H(i, 4, 5) - .5) * 6)
    local col = H(i, 5, 5) < .5 and WD.hi or WD.deep
    for k = 0, len do if dome:has(x + k, y + floor(dy * k / len)) and dome:has(x + k, y + 2) then c:px(x + k, y + floor(dy * k / len), col) end end
  end
  c:rim(dome, INK)
  local mm = archm(300, 140, 206, 44)
  mm:each(function(x, y) local t = (y - 140) / 66; c:px(x, y, t < .45 and "#2c1c2c" or (t < .8 and "#4c3040" or "#8c5438")) end)
  c:rim(mm, INK)
  c:fillMask(GX.disc(M(), 300, 200, 18, 5), "#f4b85a"); c:fillMask(GX.disc(M(), 300, 200, 9, 3), "#ffe8a0")
  blog(0, 190, 120, 14, true); blog(10, 176, 104, 14); blog(4, 162, 92, 14, true); blog(46, 204, 130, 14)
  for i = 0, 3 do c:fillMask(c:rect(20 + i * 24, 152, 24 + i * 24, 160), "#2e8a50") end
  -- big beaver, sitting, gnawing a branch
  local BR = { hi = "#e0a070", base = "#a8683c", shade = "#6c4034", deep = "#3c2430" }
  local bx, by2 = 304, 232
  c:fillMask(D(bx, by2 + 2, 52, 8), "#2c5c78")
  local tail = D(bx + 56, by2 - 8, 30, 10, 3); L(tail, { hi = "#8c6c58", base = "#5c4440", shade = "#3c2c38", deep = "#2c2030" }, { R = 8 })
  tail:each(function(x, y) if (x + (y // 3) * 3) % 6 == 0 then c:px(x, y, "#2c2030") end end)
  local body = D(bx, by2 - 36, 33, 36, 4); L(body, BR, { R = 28 })
  body:each(function(x, y) if H(x // 2, y // 3, 7) < .1 and y % 3 == 0 then c:px(x, y, BR.deep) end end)
  c:fillMask(D(bx + 2, by2 - 26, 17, 21), "#d8a070"); c:fillMask(D(bx - 2, by2 - 30, 11, 12), "#e8b888")
  for _, ex in ipairs{ -1, 1 } do local m = D(bx + ex * 22, by2 - 3, 12, 6, 9 + ex); L(m, BR, { R = 7 }); for k = -1, 1 do c:px(bx + ex * 22 + k * 3, by2 - 1, INK) end end
  local hx, hy = bx - 6, by2 - 84
  L(D(hx, hy, 27, 23, 5), BR, { R = 22 })
  for _, ex in ipairs{ -1, 1 } do L(D(hx + ex * 21, hy - 17, 6, 6), BR, { R = 5, rimlight = false }); c:fillMask(D(hx + ex * 21, hy - 16, 3, 3), BR.deep) end
  c:fillMask(D(hx - 3, hy + 9, 14, 9), "#e8b888")
  c:fillMask(D(hx - 3, hy + 3, 5, 3), INK); c:px(hx - 5, hy + 2, "#6c6c88")
  c:fillMask(c:rect(hx - 6, hy + 12, hx - 4, hy + 20), "#fff4dc"); c:fillMask(c:rect(hx - 2, hy + 12, hx, hy + 20), "#fff4dc"); c:px(hx - 5, hy + 20, "#c8a888"); c:px(hx - 1, hy + 20, "#c8a888")
  c:fillMask(c:rect(hx - 3, hy + 12, hx - 3, hy + 20), INK); c:rim(c:rect(hx - 6, hy + 12, hx, hy + 20), INK)
  for k = 0, 4 do c:px(hx - 12 - k, hy + 10 + floor(k * .5), INK); c:px(hx + 6 + k, hy + 10 + floor(k * .5), INK) end
  eye(hx - 14, hy - 6); eye(hx + 8, hy - 6)
  -- stick held in paws
  sweep(function(t) return bx - 28 + t * 56, by2 - 40 - t * 8 end, 20, function(t) return 3 end):each(function(x, y) end)
  L(sweep(function(t) return bx - 26 + t * 54, by2 - 42 - t * 10 end, 40, function(t) return 3 end), WD, { R = 3 })
  blog(40, 238, 150, 14, true); blog(250, 252, 200, 14)
  L(D(120, 240, 8, 6), { hi = "#fff0a0", base = "#f8d84a", shade = "#d89a38", deep = "#a05c34" }, { R = 6 })
  L(D(114, 232, 5, 5), { hi = "#fff0a0", base = "#f8d84a", shade = "#d89a38", deep = "#a05c34" }, { R = 5 })
  c:fillMask(c:rect(108, 233, 110, 234), "#e8782c"); eye(114, 230)
end

P["delve-anaconda-hollows"] = function()
  local FR = { hi = "#9cd870", base = "#4e9a4c", shade = "#2e6a46", deep = "#1c4434" }
  local TR = { hi = "#c8985c", base = "#8c5c3c", shade = "#5c3c34", deep = "#34202c" }
  local SN = { hi = "#c4ea78", base = "#5aa044", shade = "#2e7040", deep = "#1c4434" }
  GX.bands(c, 0, 269, { "#24543c", "#2e6a46", "#3c8250", "#56a05a", "#7cbc66" }, 3, .25)
  local FT = { hi = "#4a8a58", base = "#2e6a46", shade = "#245238", deep = "#1a3c30" }
  for i, x in ipairs{ 22, 84, 408, 452 } do GX.trunk(c, x, x + 12, 0, 196, FT, 20 + i) end
  GX.foliage(c, 70, 18, 100, 30, FR, 31); GX.foliage(c, 420, 14, 110, 34, FR, 32); GX.foliage(c, 245, 4, 150, 22, FR, 33)
  local edge = function(x) return 214 + floor((GX.vn(x, 0, 24, 4) - .5) * 14) end
  GX.ground(c, function(x) return 178 + floor((GX.vn(x, 0, 30, 4) - .5) * 10) end, { hi = "#b88a58", base = "#8c5c3c", shade = "#5c3c34", deep = "#3a2430" }, 5)
  water(edge, { "#3c9a8c", "#2e8484", "#247078", "#1c5868", "#164458" }, 9, "#7cc8b4", "#18405a")
  GX.trunk(c, 150, 330, 0, 208, TR, 11, { moss = FR })
  -- hollow with lit interior gradient (warm light pours from the lower left)
  local hm = archm(240, 108, 206, 38)
  local g = { "#1c1424", "#2a1c30", "#3c2a3c", "#5c3c44", "#8c5a48", "#c08a58" }
  hm:each(function(x, y)
    local t = (y - 108) / 98 * .65 + (1 - ((x - 214) / 76)) * .1 + (GX.vn(x, y, 6, 3) - .5) * .06
    t = max(0, min(.999, t + max(0, (y - 170)) / 120 * .35))
    c:px(x, y, g[floor(t * 6) + 1])
  end)
  for k = 0, 8 do c:fillMask(c:rect(214 + k * 8, 112 + (k % 3) * 3, 215 + k * 8, 122 + (k % 3) * 8), "#1c1424") end
  for i = 0, 6 do c:fillMask(c:rect(222 + i * 6, 188 + (i % 2) * 3, 224 + i * 6, 190 + (i % 2) * 3), "#d8a860") end
  c:rim(hm, INK)
  local lip = M(); hm:each(function(x, y) if not hm:has(x - 2, y) and not hm:has(x, y - 2) then end end)
  for y = 120, 206 do c:px(203, y, TR.hi); c:px(204, y, TR.base) end
  c:fillMask(c:rect(236, 140, 238, 142), "#f8c84a"); c:px(237, 141, INK)
  -- coil around trunk
  local coil = sweep(function(t) return 138 + t * 204, 80 + 16 * sin(t * pi) - t * 6 end, 260, function(t) return 13 end)
  L(coil, SN, { R = 13, tex = .3 }); spots(coil, 7, SN.deep)
  -- main body flows right to left, rising into a big head
  local function bf(t) return 500 - t * 380, 240 + 13 * sin(t * 9) - max(0, t - .84) * 120 end
  local body = sweep(bf, 400, function(t) return 10 + 8 * t end)
  L(body, SN, { R = 16, tex = .3 }); spots(body, 3, SN.deep)
  body:each(function(x, y) if y > 226 and (x + y) % 9 == 0 then c:px(x, y, "#f4e8a0") end end)
  local hx, hy = 112, 214
  local head = D(hx, hy, 28, 19, 4); head:add(D(hx - 26, hy + 5, 18, 12)); head:add(D(hx + 14, hy + 8, 18, 13)); head = GX.rough(head, 5, 1)
  L(head, SN, { R = 18, tex = .2 })
  for k = 0, 5 do c:px(hx - 12 + k * 7, hy - 14 + (k % 2) * 3, SN.deep); c:px(hx - 11 + k * 7, hy - 13 + (k % 2) * 3, SN.deep) end
  c:fillMask(c:rect(hx - 40, hy + 12, hx - 8, hy + 13), "#f4e8a0")
  c:fillMask(c:rect(hx - 40, hy + 14, hx - 10, hy + 14), SN.deep)
  for k = 0, 7 do c:px(hx - 38 + k * 4, hy + 15, "#fff4dc") end
  c:fillMask(c:rect(hx - 40, hy - 2, hx - 36, hy), INK); c:px(hx - 38, hy - 1, SN.hi)
  -- big eye
  c:fillMask(D(hx - 9, hy - 7, 6, 5), INK); c:fillMask(D(hx - 9, hy - 7, 5, 4), "#ffd84a"); c:fillMask(c:rect(hx - 10, hy - 10, hx - 9, hy - 4), INK); c:px(hx - 11, hy - 9, "#fff8d8")
  -- tongue
  for i = 0, 22 do c:px(hx - 41 - i, hy + 12 + floor(sin(i * .5) * 1.4), "#e8403c"); c:px(hx - 41 - i, hy + 13 + floor(sin(i * .5) * 1.4), "#b82c3c") end
  for i = 0, 6 do c:px(hx - 63 - i, hy + 10 - i // 2, "#e8403c"); c:px(hx - 63 - i, hy + 17 + i // 2, "#e8403c") end
  for _, p in ipairs{ { 60, 245, 14 }, { 190, 256, 12 }, { 400, 252, 15 }, { 300, 224, 10 } } do
    local lm = D(p[1], p[2], p[3], 4, p[1]); L(lm, FR, { R = 4, rimlight = false })
  end
  GX.flower(c, 60, 242, "#ff9ac8", "#ffe38a"); GX.flower(c, 402, 249, "#ff9ac8", "#ffe38a")
  for y = 20, 62 do c:px(396, y, "#2e6a46"); c:px(397, y, "#4e9a4c") end
  local tail = sweep(function(t) return 404 + t * 6, 56 + t * 22 end, 12, function(t) return 2.5 - t end)
  L(tail, { hi = "#58c8e8", base = "#2e88c8", shade = "#2c5ca0", deep = "#1c3c74" }, { R = 3, rimlight = false })
  local body2 = D(400, 50, 8, 11, 8); L(body2, { hi = "#ff8a6a", base = "#e0382c", shade = "#a02034", deep = "#5c1c34" }, { R = 8 })
  local hd = D(399, 37, 6, 6, 9); L(hd, { hi = "#ff8a6a", base = "#e0382c", shade = "#a02034", deep = "#5c1c34" }, { R = 5 })
  c:fillMask(c:rect(394, 37, 395, 40), "#f8d85a"); eye(397, 35, CREAM)
  c:fillMask(D(404, 50, 4, 7), "#2e88c8")
end

local names = { "delve-anaconda-hollows", "delve-beaverdam-tunnels", "delve-fynbos-fire-trails", "delve-jaguar-root-caves" }
local want = app.params.name
for _, n in ipairs(names) do
  if want == nil or want == "" or want == "all" or want == n then
    c = HP.canvas{ w = 480, h = 270, scale = 1, name = n }
    P[n]()
    c:hem(2); c:hem(267)
    c:save{ aseprite = d.."/out/"..n..".aseprite", png = d.."/out/"..n..".png", scale = 1 }
  end
end
