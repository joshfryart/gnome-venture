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
-------------------------------------------------------------------------------
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
  -- hollow
  local hm = archm(240, 118, 206, 36)
  hm:each(function(x, y) local t = (y - 118) / 90; c:px(x, y, t < .4 and "#1c1424" or (t < .75 and "#2a1c30" or "#3c2a3c")) end)
  c:rim(hm, INK)
  c:fillMask(c:rect(224, 160, 227, 162), "#f8c84a"); c:fillMask(c:rect(250, 160, 253, 162), "#f8c84a")
  c:px(225, 161, INK); c:px(251, 161, INK)
  -- coil around trunk
  local coil = sweep(function(t) return 138 + t * 204, 82 + 16 * sin(t * pi) - t * 6 end, 260, function(t) return 10 end)
  L(coil, SN, { R = 10, tex = .3 }); spots(coil, 7, SN.deep)
  -- main body
  local function bf(t) return 492 - t * 372, 238 + 13 * sin(t * 9) - max(0, t - .86) * 190 end
  local body = sweep(bf, 400, function(t) return 8 + 6 * t end)
  L(body, SN, { R = 12, tex = .3 }); spots(body, 3, SN.deep)
  local hx, hy = bf(1)
  hx, hy = floor(hx - 6), floor(hy - 4)
  local head = D(hx, hy, 19, 12, 4); head:add(D(hx - 18, hy + 3, 12, 8)); head = GX.rough(head, 5, 1)
  L(head, SN, { R = 12, tex = .2 })
  eye(hx - 8, hy - 8, "#ffe27a"); c:px(hx - 28, hy + 2, INK); c:px(hx - 26, hy + 2, INK)
  for i = 0, 10 do c:px(hx - 30 - i, hy + 6, "#e8403c") end
  c:px(hx - 41, hy + 5, "#e8403c"); c:px(hx - 41, hy + 7, "#e8403c")
  -- lily pads + flower
  for _, p in ipairs{ { 60, 245, 14 }, { 190, 256, 12 }, { 400, 252, 15 }, { 300, 224, 10 } } do
    local lm = D(p[1], p[2], p[3], 4, p[1]); L(lm, FR, { R = 4, rimlight = false })
  end
  GX.flower(c, 60, 242, "#ff9ac8", "#ffe38a"); GX.flower(c, 402, 249, "#ff9ac8", "#ffe38a")
  -- parrot on a vine
  for y = 20, 62 do c:px(396, y, "#2e6a46"); c:px(397, y, "#4e9a4c") end
  local tail = sweep(function(t) return 404 + t * 6, 56 + t * 22 end, 12, function(t) return 2.5 - t end)
  L(tail, { hi = "#58c8e8", base = "#2e88c8", shade = "#2c5ca0", deep = "#1c3c74" }, { R = 3, rimlight = false })
  local body2 = D(400, 50, 8, 11, 8); L(body2, { hi = "#ff8a6a", base = "#e0382c", shade = "#a02034", deep = "#5c1c34" }, { R = 8 })
  local hd = D(399, 37, 6, 6, 9); L(hd, { hi = "#ff8a6a", base = "#e0382c", shade = "#a02034", deep = "#5c1c34" }, { R = 5 })
  c:fillMask(c:rect(394, 37, 395, 40), "#f8d85a"); eye(397, 35, CREAM)
  c:fillMask(D(404, 50, 4, 7), "#2e88c8")
  for i = 0, 5 do GX.tuft(c, 24 + i * 3 * (i % 2 == 0 and 1 or -1) + 60, 220, FR) end
end

-------------------------------------------------------------------------------
P["delve-beaverdam-tunnels"] = function()
  local WD = { hi = "#d8a060", base = "#946040", shade = "#5c3c3c", deep = "#34202c" }
  GX.bands(c, 0, 118, { "#5a9ad0", "#78b4e0", "#98cae8", "#b8dcee", "#d8ecf0" }, 3, .2)
  for _, cl in ipairs{ { 70, 30, 40, 8 }, { 190, 52, 30, 6 }, { 400, 26, 46, 9 } } do
    c:fillMask(GX.rough(D(cl[1], cl[2], cl[3], cl[4]), cl[1], 1), "#f4f8f0"); c:fillMask(c:rect(cl[1] - cl[3] + 4, cl[2] + 4, cl[1] + cl[3] - 4, cl[2] + 5), "#c4dcec")
  end
  GX.ground(c, function(x) return 98 + floor((GX.vn(x, 0, 18, 6) - .5) * 14) end, { hi = "#5c9a8c", base = "#3c7a74", shade = "#2c5c64", deep = "#1c3c4c" }, 8, { top = .5, fall = .3 })
  water(function(x) return 120 end, { "#4a9cc8", "#3c88b8", "#2e70a0", "#245a88", "#1c4870" }, 6, "#9ad0e8", "#1c4468")
  -- lodge dome
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
  -- tunnel mouth
  local mm = archm(300, 150, 206, 34)
  mm:each(function(x, y) local t = (y - 150) / 56; c:px(x, y, t < .45 and "#2c1c2c" or (t < .8 and "#4c3040" or "#8c5438")) end)
  c:rim(mm, INK)
  c:fillMask(GX.disc(M(), 300, 198, 12, 5), "#f4b85a"); c:fillMask(GX.disc(M(), 300, 198, 6, 3), "#ffe8a0")
  -- beaver
  local BR = { hi = "#e0a070", base = "#a8683c", shade = "#6c4034", deep = "#3c2430" }
  local tail = D(338, 200, 18, 6, 3); L(tail, { hi = "#8c6c58", base = "#5c4440", shade = "#3c2c38", deep = "#2c2030" }, { R = 5 })
  for i = 0, 6 do c:px(326 + i * 4, 198 + (i % 2) * 2, "#2c2030") end
  local body = D(300, 190, 17, 18, 4); L(body, BR, { R = 14 })
  c:fillMask(D(300, 195, 9, 11), "#d8a070")
  local head = D(300, 164, 14, 12, 5); L(head, BR, { R = 11 })
  c:fillMask(D(300, 169, 7, 5), "#e8b888")
  for _, ex in ipairs{ -1, 1 } do L(D(300 + ex * 12, 154, 4, 4), BR, { R = 4, rimlight = false }); c:px(300 + ex * 12, 154, "#6c4034") end
  eye(293, 160); eye(305, 160)
  c:fillMask(c:rect(299, 169, 300, 172), CREAM); c:px(299, 173, "#c8a888"); c:px(298, 166, INK); c:px(301, 166, INK)
  c:fillMask(D(288, 204, 5, 3), BR.base); c:fillMask(D(312, 204, 5, 3), BR.base); c:rim(D(288, 204, 5, 3), INK); c:rim(D(312, 204, 5, 3), INK)
  -- dam logs left
  local function log(x0, y0, len, r)
    local m = HP.rrect(x0, y0, x0 + len, y0 + 12, 5)
    L(m, WD, { R = 6, tex = .4 })
    local e = D(x0 + len - 2, y0 + 6, 5, 6); L(e, { hi = "#f0d098", base = "#d8a060", shade = "#a8704c", deep = "#6c4034" }, { R = 5 })
    c:px(x0 + len - 2, y0 + 6, WD.shade); c:px(x0 + len - 3, y0 + 5, WD.shade); c:px(x0 + len - 1, y0 + 7, WD.shade)
  end
  log(0, 190, 112, 0); log(10, 177, 100, 0); log(4, 164, 90, 0); log(40, 202, 120, 0)
  for i = 0, 3 do c:fillMask(c:rect(20 + i * 24, 156, 24 + i * 24, 164), "#2e8a50") end
  -- foreground floating logs + duckling
  log(40, 236, 150); log(260, 250, 170)
  c:fillMask(D(92, 232, 8, 6), "#f8d84a"); L(D(92, 232, 8, 6), { hi = "#fff0a0", base = "#f8d84a", shade = "#d89a38", deep = "#a05c34" }, { R = 6 })
  L(D(86, 224, 5, 5), { hi = "#fff0a0", base = "#f8d84a", shade = "#d89a38", deep = "#a05c34" }, { R = 5 })
  c:fillMask(c:rect(80, 225, 82, 226), "#e8782c"); eye(86, 222)
end

-------------------------------------------------------------------------------
P["delve-fynbos-fire-trails"] = function()
  GX.bands(c, 0, 200, { "#4a3a78", "#7a4a8c", "#c0587c", "#e8805a", "#f4a84c", "#ffd078" }, 3, .25)
  for i = 5, 1, -1 do c:fillMask(GX.rough(D(120, 160, 16 + i * 14, 12 + i * 9, 40 + i), 1), ({ "#ffe6a0", "#fcd080", "#f8b868", "#f09a60", "#e07c60" })[i]) end
  local mt = HP.poly({ { 0, 176 }, { 30, 146 }, { 60, 124 }, { 80, 116 }, { 250, 116 }, { 290, 134 }, { 340, 160 }, { 400, 176 } })
  mt = GX.rough(mt, 21, 1)
  L(mt, { hi = "#c0689c", base = "#7a4a8c", shade = "#563c78", deep = "#3c2c64" }, { R = 40, amb = .4, ink = false, tex = .5 })
  local mt2 = HP.poly({ { 300, 176 }, { 380, 140 }, { 440, 128 }, { 480, 150 }, { 480, 176 } })
  L(GX.rough(mt2, 22, 1), { hi = "#a85a90", base = "#6c4286", shade = "#4c3470", deep = "#34285c" }, { R = 30, amb = .4, ink = false })
  local gr = { hi = "#d89a5a", base = "#a8643c", shade = "#6c3c3c", deep = "#3c2434" }
  GX.ground(c, function(x) return 178 + floor((GX.vn(x, 0, 30, 3) - .5) * 10) end, gr, 5)
  -- cliff with cave
  local cm = M()
  for x = 236, 479 do
    local t = (x - 236) / 243
    local top = 62 + floor(70 * (1 - sin(min(1, t * 1.2) * pi / 2) ^ 2) + (GX.vn(x, 0, 12, 7) - .5) * 14)
    for y = top, 214 do cm:set(x, y) end
  end
  local opening = archm(372, 112, 216, 40)
  cm:cut(opening); cm = GX.rough(cm, 8, 1)
  L(cm, { hi = "#d89868", base = "#9c5c48", shade = "#643c48", deep = "#38243a" }, { R = 22, tex = .8, sc = 4, amb = .3, rimlight = false })
  opening:each(function(x, y) local t = (y - 112) / 104; c:px(x, y, t < .45 and "#241830" or (t < .7 and "#4c2438" or (t < .88 and "#8c3c34" or "#d8602c"))) end)
  c:rim(opening, INK)
  for i = 0, 18 do c:px(340 + floor(H(i, 1, 4) * 64), 120 + floor(H(i, 2, 4) * 90), i % 3 == 0 and "#ffe8a0" or "#f8a83c") end
  -- sandy trail
  local trail = sweep(function(t) local x, y = bez({ 40, 262 }, { 160, 236 }, { 260, 252 }, { 372, 214 }, t); return x, y end, 300, function(t) return 26 - 15 * t end)
  L(trail, { hi = "#f8d8a0", base = "#d8a070", shade = "#a8704c", deep = "#6c4a40" }, { R = 12, ink = false, rimlight = false, tex = .3 })
  for i = 0, 8 do
    local x, y = bez({ 40, 262 }, { 160, 236 }, { 260, 252 }, { 372, 214 }, (i + .5) / 9.5)
    flame(floor(x) + (i % 2 == 0 and -22 + i * 1.5 or 18 - i), floor(y) - (i % 2 == 0 and -9 or 12) + 4, i < 4 and 2 or 1)
  end
  -- fynbos bushes + proteas
  local BU = { hi = "#d8c860", base = "#7c9a48", shade = "#4c6a40", deep = "#2c4234" }
  GX.foliage(c, 56, 230, 66, 26, BU, 41); GX.foliage(c, 440, 242, 60, 22, BU, 42)
  local function protea(x, y, r)
    for y2 = y + r, y + 30 do c:px(x, y2, "#4c6a40"); c:px(x + 1, y2, "#7c9a48") end
    for k = 0, 11 do local a = k / 12 * 2 * pi; c:fillMask(D(x + floor(cos(a) * r), y + floor(sin(a) * r * .85), 3, 3), k % 2 == 0 and "#c83c80" or "#ff9ac8") end
    L(D(x, y, r - 1, r - 2, x), { hi = "#ffd0e0", base = "#f06a9c", shade = "#b83c80", deep = "#6c2060" }, { R = r, amb = .4 })
    c:fillMask(D(x, y, r // 2, r // 2), "#f8e0b0")
  end
  protea(36, 214, 11); protea(80, 224, 8); protea(430, 226, 10); protea(462, 232, 7)
  -- sunbird quirk
  local SB = { hi = "#9cf0c8", base = "#2cb08c", shade = "#1c6c80", deep = "#1c3c64" }
  sweep(function(t) return 100 + t * 16, 218 + t * 10 end, 8, function(t) return 2 end):each(function(x, y) c:px(x, y, SB.shade) end)
  local sb = D(94, 214, 7, 5, 3); L(sb, SB, { R = 5 })
  L(D(87, 211, 4, 4), SB, { R = 4 }); eye(85, 210, "#fff4dc")
  for i = 0, 7 do c:px(82 - i, 212 + floor(i * .3), "#3c2c44") end
  c:fillMask(D(94, 217, 4, 2), "#f8d84a")
end

-------------------------------------------------------------------------------
P["delve-jaguar-root-caves"] = function()
  -- backdrop through arch
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
  GX.ground(c, function(x) return 212 + floor((GX.vn(x, 0, 18, 9) - .5) * 6) end, { hi = "#c8a478", base = "#8c6a52", shade = "#5c4850", deep = "#3a2c3c" }, 5)
  for y = 214, 269 do for x = 320, 480 do
    local lx = 335 + (y - 214) * -.9
    if x > lx and x < 470 + (y - 214) * .3 and H(x // 3, y // 2, 4) < .55 then c:px(x, y, GX.mix(c:get(x, y) or "#8c6a52", "#ffe8a0", .3)) end
  end end
  for _, s in ipairs{ { 40, 20, 40, 9 }, { 96, 24, 26, 7 }, { 150, 30, 34, 8 }, { 220, 36, 20, 6 }, { 290, 30, 28, 7 } } do stal(s[1], s[2], s[3], s[4], s[1], { hi = "#9a7a88", base = "#6e5068", shade = "#4c3858", deep = "#2c2038" }) end
  local RT = { hi = "#d8a060", base = "#946040", shade = "#5c3c3c", deep = "#34202c" }
  for i = 1, 15 do
    local x0, len = floor(8 + H(i, 1, 9) * 290), 30 + floor(H(i, 2, 9) * 90)
    local rr = 2 + floor(H(i, 3, 9) * 2)
    L(sweep(function(t) return x0 + sin(t * 3 + i) * 4, t * len end, 30, function(t) return rr * (1 - .5 * t) end), RT, { R = 3, tex = .3, rimlight = false })
  end
  -- stone + cub
  L(HP.rrect(112, 204, 236, 226, 6), { hi = "#b8b0c0", base = "#7c7490", shade = "#54506c", deep = "#363450" }, { R = 8 })
  local JG = { hi = "#ffc470", base = "#e88a2c", shade = "#b05a28", deep = "#6c3426" }
  local tail = sweep(function(t) return 190 + t * 36, 204 - 24 * sin(t * pi * .9) end, 40, function(t) return 5 - 2 * t end)
  L(tail, JG, { R = 4 }); spots(tail, 3, INK)
  local body = D(166, 186, 22, 22, 4); L(body, JG, { R = 20 }); c:fillMask(D(166, 194, 11, 12), "#f8d8a0"); spots(body, 5, INK)
  c:fillMask(D(150, 207, 8, 4), JG.base); c:fillMask(D(182, 207, 8, 4), JG.base); c:rim(D(150, 207, 8, 4), INK); c:rim(D(182, 207, 8, 4), INK)
  for _, ex in ipairs{ -1, 1 } do L(D(166 + ex * 18, 136, 7, 7), JG, { R = 6 }); c:fillMask(D(166 + ex * 18, 137, 3, 3), "#8c4c4c") end
  local head = D(166, 152, 21, 17, 6); L(head, JG, { R = 16 }); spots(head, 8, INK)
  c:fillMask(D(166, 159, 11, 7), "#f8d8a0"); c:fillMask(c:rect(165, 155, 167, 156), "#8c4c4c"); c:px(166, 158, INK)
  eye(155, 148, "#ffe27a"); eye(175, 148, "#ffe27a")
  -- banana + gems
  L(sweep(function(t) return 246 + t * 20, 212 - 7 * sin(t * pi) end, 14, function(t) return 3 end), { hi = "#fff0a0", base = "#f8d84a", shade = "#d89a38", deep = "#a05c34" }, { R = 3 })
  gem(60, 232, 7, 6, { hi = "#b8fff0", base = "#38d0c4", shade = "#1e8aa0", deep = "#16506c" }, 4)
  gem(84, 244, 5, 4, { hi = "#ffc0e8", base = "#e458b4", shade = "#a42c8c", deep = "#5c1c5c" }, 5)
end

-------------------------------------------------------------------------------
P["delve-mangrove-root-maze"] = function()
  local FR = { hi = "#88d070", base = "#3e9a58", shade = "#26705a", deep = "#18483f" }
  GX.bands(c, 0, 160, { "#2e6a5c", "#3c8a70", "#5cae84", "#8ccc98", "#c8ecb0" }, 3, .25)
  for i = 5, 1, -1 do c:fillMask(GX.rough(D(240, 118, 20 + i * 15, 16 + i * 11, 30 + i), 1), ({ "#f8ffd0", "#e0f4b8", "#c0e8b0", "#9cd8a8", "#78c4a0" })[i]) end
  water(function(x) return 152 end, { "#4ab0a4", "#3a9494", "#2e7a84", "#246270", "#1c4a5c" }, 7, "#9ae0c8", "#16405a")
  for i = 0, 8 do c:fillMask(c:rect(214 + (i % 3) * 3, 156 + i * 4, 266 - (i % 4) * 3, 156 + i * 4), i % 2 == 0 and "#cfeec0" or "#8cd0b0") end
  local RW = { hi = "#c88a5c", base = "#8c4c3c", shade = "#5c2c3c", deep = "#341c2c" }
  local RD = { hi = "#7c8c70", base = "#4c6458", shade = "#344c4c", deep = "#223840" }
  local function arc(rx, ry, base, r, R, seed, cx)
    cx = cx or 240
    local m = sweep(function(t) local a = t * pi; return cx - rx * cos(a) + sin(t * 20 + seed) * 2, base - ry * sin(a) end, 260, function(t) return r * (1 + .3 * abs(cos(t * pi))) end)
    L(m, R, { R = r + 2, tex = .4, rimlight = false })
  end
  arc(70, 96, 196, 4, RD, 1); arc(96, 116, 206, 5, RD, 2); arc(54, 74, 196, 3, RD, 3)
  GX.foliage(c, 80, 14, 110, 30, FR, 51); GX.foliage(c, 400, 10, 120, 30, FR, 52); GX.foliage(c, 240, 0, 110, 14, FR, 53)
  -- side trunks with prop roots
  for _, sd in ipairs{ { 40, 1 }, { 440, -1 } } do
    local x = sd[1]
    L(sweep(function(t) return x + sin(t * 4) * 3, t * 150 end, 150, function(t) return 9 + t * 3 end), RW, { R = 8, tex = .4, rimlight = false })
    for k = 1, 4 do
      local tx = x + sd[2] * (30 + k * 32)
      L(sweep(function(t) local px, py = bez({ x, 90 }, { x + sd[2] * 20, 130 }, { tx - sd[2] * 20, 170 }, { tx, 232 }, t); return px, py end, 160, function(t) return 5 - 2.5 * t end), RW, { R = 4, tex = .3, rimlight = false })
    end
  end
  arc(150, 150, 232, 8, RW, 4); arc(190, 170, 250, 9, RW, 5)
  -- mud bank + frog
  L(GX.rough(D(240, 252, 76, 20, 3), 7, 1), { hi = "#a8805c", base = "#7c5444", shade = "#54384a", deep = "#34243c" }, { R = 18, tex = .6 })
  local FG = { hi = "#c8f07a", base = "#6cc044", shade = "#3c8c44", deep = "#245a3c" }
  L(D(224, 244, 8, 5), FG, { R = 5 }); L(D(256, 244, 8, 5), FG, { R = 5 })
  local body = D(240, 232, 20, 16, 4); L(body, FG, { R = 16 }); c:fillMask(D(240, 238, 11, 8), "#e8f4a0")
  local hd = D(240, 214, 18, 11, 5); L(hd, FG, { R = 11 })
  for _, ex in ipairs{ -1, 1 } do local e = D(240 + ex * 11, 204, 6, 6); L(e, FG, { R = 5 }); c:fillMask(D(240 + ex * 11, 205, 3, 3), "#ffe27a"); c:px(240 + ex * 11, 205, INK) end
  for i = 0, 11 do c:px(231 + i, 219 + (i > 3 and i < 8 and 1 or 0), INK) end
  -- hanging lantern (jar of fireflies)
  for y = 100, 164 do c:px(300, y, RW.deep) end
  for i = 3, 1, -1 do c:fillMask(GX.disc(M(), 300, 172, 6 + i * 5, 6 + i * 5), ({ "#7cc464", "#a8dc70", "#d0ec7c" })[i]) end
  L(HP.rrect(295, 164, 305, 178, 3), { hi = "#fffbc0", base = "#f8d850", shade = "#d89a38", deep = "#a05c34" }, { R = 5, amb = .6 })
  c:fillMask(c:rect(294, 162, 306, 163), INK)
end

-------------------------------------------------------------------------------
P["delve-pirate-gull-grottoes"] = function()
  local cx, cy, rx, ry = 240, 118, 176, 104
  local HZ = 134
  GX.bands(c, 0, HZ, { "#78b8e8", "#98d0f0", "#b8e4f4", "#e8f4e8" }, 3, .1)
  for y = HZ, 269 do for x = 0, 479 do
    local t = (y - HZ) / (270 - HZ) + (GX.vn(x * .4, y, 5, 5) - .5) * .25
    c:px(x, y, ({ "#4ac0d0", "#38a8c8", "#2c8cb8", "#2474a8", "#1c5c98" })[max(1, min(5, floor(t * 5) + 1))])
  end end
  for i = 0, 60 do local x, y = floor(H(i, 1, 3) * 470), HZ + 3 + floor(H(i, 2, 3) * 80); c:fillMask(c:rect(x, y, x + 5 + floor(H(i, 3, 3) * 10), y), i % 3 == 0 and "#b8f0f0" or "#1c5c98") end
  -- island
  L(GX.rough(D(176, HZ - 2, 40, 9, 4), 4, 1), { hi = "#8cd070", base = "#4e9a56", shade = "#2e6a50", deep = "#1c4440" }, { R = 8, ink = false })
  for _, b in ipairs{ { 160, 1 }, { 170, 2 }, { 180, 1 }, { 190, 2 } } do c:fillMask(c:rect(b[1], HZ - 8 - b[2], b[1] + 5, HZ - 3), "#f8e8c8"); c:fillMask(c:rect(b[1], HZ - 9 - b[2], b[1] + 5, HZ - 9 - b[2]), "#e8603c") end
  -- sailboat quirk
  L(HP.poly({ { 318, HZ + 8 }, { 354, HZ + 8 }, { 348, HZ + 15 }, { 324, HZ + 15 } }), { hi = "#d8a060", base = "#946040", shade = "#5c3c3c", deep = "#34202c" }, { R = 4 })
  L(HP.poly({ { 336, HZ + 6 }, { 336, HZ - 22 }, { 350, HZ + 6 } }), { hi = "#fff4dc", base = "#f0dcc0", shade = "#c8a8a0", deep = "#9a7c88" }, { R = 8, rimlight = false })
  L(HP.poly({ { 333, HZ + 6 }, { 333, HZ - 14 }, { 324, HZ + 6 } }), { hi = "#ff8a6a", base = "#e0382c", shade = "#a02034", deep = "#5c1c34" }, { R = 6, rimlight = false })
  for _, g in ipairs{ { 250, 50 }, { 270, 60 }, { 130, 70 } } do c:px(g[1], g[2], INK); c:px(g[1] + 1, g[2] - 1, INK); c:px(g[1] + 2, g[2], INK); c:px(g[1] + 3, g[2] - 1, INK); c:px(g[1] + 4, g[2], INK) end
  local RK = { hi = "#c8b0a0", base = "#8c7c88", shade = "#5c5470", deep = "#38344e" }
  local function open(x, y) return ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2 <= 1 end
  rockMass(open, RK, 17, 270)
  for _, s in ipairs{ { 110, 40, 20, 7 }, { 150, 26, 28, 8 }, { 205, 18, 22, 6 }, { 262, 17, 30, 8 }, { 318, 24, 18, 6 }, { 362, 36, 26, 7 } } do
    local top = cy - floor(ry * sqrt(max(0, 1 - ((s[1] - cx) / rx) ^ 2)))
    stal(s[1], top - 4, s[3] + 4, s[4], s[1], { hi = "#d8c4b4", base = "#9c8c98", shade = "#6c6482", deep = "#44405c" })
  end
  GX.ground(c, function(x) return 208 + floor((GX.vn(x, 0, 22, 6) - .5) * 12) - floor(max(0, 100 - abs(x - 240)) * .12) end, { hi = "#f0d8a0", base = "#c89c68", shade = "#8c6450", deep = "#583c3c" }, 5)
  -- chest + gold
  local WD = { hi = "#d09a5a", base = "#8c5438", shade = "#5c3436", deep = "#34202c" }
  L(HP.rrect(104, 188, 178, 222, 4), WD, { R = 10 })
  c:fillMask(c:rect(104, 196, 178, 198), "#e8b84a"); c:fillMask(c:rect(137, 192, 145, 206), "#e8b84a"); c:fillMask(c:rect(139, 198, 143, 202), INK)
  L(GX.rough(D(141, 186, 36, 11, 3), 3, 1), { hi = "#fff0a0", base = "#f4c84a", shade = "#c8883c", deep = "#8c5438" }, { R = 12, amb = .5 })
  for i = 0, 14 do local x, y = 112 + floor(H(i, 1, 2) * 60), 176 + floor(H(i, 2, 2) * 10); c:fillMask(c:rect(x, y, x + 2, y + 1), i % 2 == 0 and "#fff0a0" or "#e8a83c") end
  for i = 0, 5 do c:fillMask(c:rect(86 + i * 4, 224 + (i % 2) * 3, 89 + i * 4, 225 + (i % 2) * 3), "#f4c84a") end
  c:sparkle(150, 170)
  -- gulls
  local GU = { hi = "#fffaf0", base = "#e8e4e8", shade = "#aab0c8", deep = "#7a82a8" }
  local function gull(gx, gy, f, kind)
    for _, lx in ipairs{ -5, 5 } do for k = 0, 8 do c:px(gx + lx, gy + 14 + k, "#e8782c") end c:fillMask(c:rect(gx + lx - 2 + (f < 0 and 0 or 0), gy + 22, gx + lx + 2, gy + 22), "#e8782c") end
    L(D(gx, gy, 15, 17, gx), GU, { R = 15 })
    L(D(gx - f * 6, gy + 2, 8, 12, gx + 1), { hi = "#b8c0d8", base = "#8c98b8", shade = "#5c6890", deep = "#3c4470" }, { R = 8 })
    L(D(gx + f * 2, gy - 20, 10, 9, gx + 2), GU, { R = 9 })
    for k = 0, 8 do c:fillMask(c:rect(gx + f * (10 + k), gy - 21 + floor(k * .3), gx + f * (10 + k), gy - 19 + floor(k * .3) + (k < 4 and 1 or 0)), "#f8a83c") end
    eye(gx + f * 5, gy - 24)
    if kind == "hat" then
      L(HP.poly({ { gx - 14, gy - 26 }, { gx + 14, gy - 26 }, { gx + 6, gy - 38 }, { gx - 6, gy - 38 } }), { hi = "#5c5478", base = "#3c3458", shade = "#2c2444", deep = "#1c1430" }, { R = 6, rimlight = false })
      c:fillMask(c:rect(gx - 14, gy - 27, gx + 14, gy - 26), "#e8b84a"); c:px(gx, gy - 33, CREAM); c:px(gx - 1, gy - 32, CREAM); c:px(gx + 1, gy - 32, CREAM)
    else
      c:fillMask(D(gx + f * 5, gy - 22, 4, 4), INK)
      for k = 0, 9 do c:px(gx + f * 5 - k * f, gy - 26 + floor(k * .6), INK) end
      c:fillMask(c:rect(gx + f * 12, gy - 18, gx + f * 14, gy - 16), "#f4c84a")
    end
  end
  gull(270, 192, -1, "hat"); gull(360, 200, -1, "patch")
end

local names = { "delve-anaconda-hollows", "delve-beaverdam-tunnels", "delve-fynbos-fire-trails", "delve-jaguar-root-caves", "delve-mangrove-root-maze", "delve-pirate-gull-grottoes" }
local want = app.params.name
for _, n in ipairs(names) do
  if want == nil or want == "" or want == "all" or want == n then
    c = HP.canvas{ w = 480, h = 270, scale = 1, name = n }
    P[n]()
    c:hem(2); c:hem(267)
    c:save{ aseprite = d.."/out/"..n..".aseprite", png = d.."/out/"..n..".png", scale = 1 }
  end
end
