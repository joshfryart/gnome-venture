
---------------------------------------------------------------- w4: extra ramps, helpers
local ORNG  = {"#4a2210","#7a3a14","#b0561c","#d87a28","#f0a048","#f8c878"}
local NAVY  = {"#14182e","#222a4c","#34436e","#4a5e90","#6a82b0","#94aad0"}
local TERRA = {"#4a2418","#7a3a24","#a85634","#c87444","#e09a64","#f2c08c"}
local PLUMR = {"#2c1838","#4a2850","#6e3c72","#925492","#b878b4","#d8a4d4"}
local DUSK  = {"#1c2040","#2a3258","#3c4a70","#52688a","#6c88a4","#8eaabc"}
local BUTTR = {"#6a5a3a","#9a8450","#c8aa62","#e8cc7e","#f6e4a0","#fff0c0"}
local SAND  = {"#7a5a3c","#9a7648","#b89258","#d0aa6a","#e4c488","#f2dcae"}
local FERN  = {"#1c3a2c","#2a5a3a","#3c7a46","#5a9a50","#84bc62","#b4dc84"}
local function polym(pts)
  local m = HP.mask()
  local minx, maxx, miny, maxy = 1e9, -1e9, 1e9, -1e9
  for _, q in ipairs(pts) do minx = min(minx, q[1]); maxx = max(maxx, q[1]); miny = min(miny, q[2]); maxy = max(maxy, q[2]) end
  for y = floor(miny), math.ceil(maxy) do for x = floor(minx), math.ceil(maxx) do
    local inside, n = false, #pts
    local j = n
    local px, py = x + .5, y + .5
    for i = 1, n do
      local xi, yi, xj, yj = pts[i][1], pts[i][2], pts[j][1], pts[j][2]
      if ((yi > py) ~= (yj > py)) and (px < (xj - xi) * (py - yi) / (yj - yi) + xi) then inside = not inside end
      j = i
    end
    if inside then m:set(x, y) end
  end end
  return m
end
local function paintR(m, R, cx, cy, k)
  m:each(function(x, y) local l = lit(x, y, cx, cy, k); P(x, y, R[l > .55 and 5 or (l > .05 and 4 or (l > -.5 and 3 or 2))]) end)
end
local function ell(cx, cy, rx, ry, R, k)
  local m = c:ellipse(cx, cy, rx, ry); c:rim(m, INK); paintR(m, R, cx, cy, k or max(rx, ry)); return m
end
local function box(x0, y0, x1, y1, R)
  local m = rect(x0, y0, x1, y1); c:rim(m, INK)
  m:each(function(x, y)
    local t = 4
    if y == y0 or x == x0 then t = 5 elseif y == y1 or x == x1 then t = 2 elseif x >= x1 - 1 or y >= y1 - 1 then t = 3 end
    P(x, y, R[t])
  end)
  return m
end
local function shadow(x, gy, w) c:fillMask(c:ellipse(x, gy, w, 2), "#58803c") end
local function knob(kx, ky)
  c:fillMask(rect(kx - 2, ky - 2, kx + 2, ky + 2), INK)
  c:fillMask(rect(kx - 1, ky - 1, kx + 1, ky + 1), GOLD[4]); P(kx - 1, ky - 1, GOLD[6]); P(kx + 1, ky + 1, GOLD[2])
  P(kx, ky + 4, INK); P(kx, ky + 5, INK)
end
local function star5(cx, cy, R, r)
  local pts = {}
  for i = 0, 9 do local a = -1.5708 + i * .62832; local rr = (i % 2 == 0) and R or r; pts[#pts + 1] = { cx + cos(a) * rr, cy + sin(a) * rr } end
  return polym(pts)
end
local function stick(x0, y0, x1, y1, w, R)
  local m = c:line({ { x0, y0 }, { x1, y1 } }, w); c:rim(m, INK)
  m:each(function(x, y) P(x, y, (x * 2 + y) % 7 == 0 and R[3] or ((x < (x0 + x1) / 2) and R[5] or R[4])) end)
  return m
end

local PR, OV, K = {}, {}, {}

---------------------------------------------------------------- PROPS (x, gy = ground baseline)
PR.can = function(x, gy) can(x, gy) end
PR.acorn = function(x, gy) acorn(x, gy) end
PR.herbs = function(x) herbs(x) end
PR.chimes = function(x) chimes(x) end
PR.trellis = function(x) trellis(x) end
PR.mush = function(x, gy) shadow(x, gy, 8); mushroom(x, gy, 6, "#e8493b"); mushroom(x + 12, gy, 4, "#f0a048") end

PR.broom = function(x, gy)
  stick(x + 13, gy - 50, x + 3, gy - 14, 2, TIMB)
  local b = HP.mask()
  for y = gy - 16, gy do local hw = 3 + floor((y - gy + 16) * .45); for xx = x - hw + 2, x + hw + 2 do b:set(xx, y) end end
  c:rim(b, INK)
  b:each(function(xx, y) local t = ((xx - x) % 4 < 2) and 5 or 4; if y > gy - 3 then t = 3 end; if xx < x then t = min(6, t + 1) end; P(xx, y, THATCH[t]) end)
  c:fillMask(rect(x - 1, gy - 12, x + 7, gy - 10), "#b0343a"); P(x, gy - 12, "#ec7a58")
end
PR.skep = function(x, gy)
  shadow(x, gy, 14)
  box(x - 11, gy - 7, x + 11, gy, TIMB)
  for i = 0, 3 do ell(x, gy - 12 - i * 6, 11 - i * 2, 4, GOLD, 8) end
  c:fillMask(c:ellipse(x, gy - 10, 3, 2), INK)
  for k = 0, 4 do P(x + 4, gy - 22 + k, "#e8a030") end; P(x + 4, gy - 17, "#fce67c"); P(x - 6, gy - 20, "#fff0c0")
  P(x, gy - 38, GOLD[6]); P(x + 1, gy - 38, GOLD[5])
end
PR.bramble = function(x, gy)
  for y = gy, 112, -1 do
    local vx = floor(x + 7 * sin(y / 11) + (gy - y) * .04)
    P(vx - 1, y, INK); P(vx + 1, y, INK); P(vx, y, (y % 6 < 3) and "#6a3a44" or "#8a4a50")
    if y % 9 == 0 then P(vx + 2, y - 1, "#c8a090"); P(vx - 2, y - 1, "#c8a090") end
    if y % 14 == 3 then local lm = c:ellipse(vx + ((y % 28 == 3) and 5 or -5), y, 4, 2); c:rim(lm, INK); c:fillMask(lm, LEAF[3]); P(vx + ((y % 28 == 3) and 4 or -6), y - 1, LEAF[5]) end
  end
  for _, q in ipairs{ { x + 6, 150 }, { x - 6, 176 }, { x + 4, 130 }, { x - 5, 196 } } do
    local m = c:ellipse(q[1], q[2], 3, 3); c:rim(m, INK); c:fillMask(m, PLUMR[2]); P(q[1] - 1, q[2] - 1, PLUMR[5]); P(q[1] + 1, q[2] + 1, PLUMR[1])
  end
end
PR.berrycrate = function(x, gy)
  shadow(x + 10, gy, 15)
  for k = 0, 8 do local bx, by = x + 2 + (k % 5) * 4, gy - 14 - (k // 5) * 3
    local m = c:ellipse(bx + 1, by, 3, 3); c:rim(m, INK); c:fillMask(m, PLUMR[3]); P(bx, by - 1, PLUMR[6]) end
  local m = box(x, gy - 12, x + 22, gy, TIMB)
  for xx = x + 1, x + 21 do P(xx, gy - 6, TIMB[2]) end
  P(x + 11, gy - 8, "#f8ecd0"); P(x + 12, gy - 8, "#f8ecd0")
end
PR.scraper = function(x, gy)
  box(x, gy - 5, x + 24, gy, TIMB)
  for xx = x + 1, x + 23 do local h = 3 + ((xx * 7) % 3); for k = 1, h do P(xx, gy - 5 - k, (k == h) and "#c8a060" or "#5a3c1c") end; P(xx, gy - 6 - h, INK) end
  for _, px in ipairs{ x - 1, x + 25 } do for y = gy - 12, gy - 6 do P(px, y, INK) end end
end
PR.puddle = function(x, gy)
  local m = c:ellipse(x, gy + 8, 20, 4); c:rim(m, "#2a5a7a")
  m:each(function(xx, y) P(xx, y, (y < gy + 8) and "#82b8d8" or "#5a96bc") end)
  for k = 0, 8 do P(x - 12 + k, gy + 6, "#d4ecf8") end
  local lp = c:ellipse(x + 6, gy + 9, 6, 2); c:rim(lp, INK); c:fillMask(lp, GREEN[4]); P(x + 3, gy + 8, GREEN[6]); P(x + 8, gy + 9, "#82b8d8")
  P(x - 4, gy + 10, "#d4ecf8"); P(x - 3, gy + 10, "#d4ecf8")
end
PR.leafbrella = function(x, gy)
  stick(x, gy, x + 4, gy - 34, 2, TIMB)
  local m = c:ellipse(x + 6, gy - 36, 15, 7); c:rim(m, INK)
  m:each(function(xx, y) local l = lit(xx, y, x + 6, gy - 36, 12); P(xx, y, GREEN[l > .4 and 6 or (l > -.1 and 5 or (l > -.5 and 4 or 3))]) end)
  for k = -12, 12 do P(x + 6 + k, gy - 36 + floor(k * .08), GREEN[2]) end
  for k = -9, 9, 3 do P(x + 6 + k, gy - 38 - floor(abs(k) / 5), GREEN[3]); P(x + 6 + k, gy - 34 + floor(abs(k) / 5), GREEN[3]) end
  P(x - 5, gy - 40, GREEN[6]); P(x - 4, gy - 40, GREEN[6])
end
PR.cloverpatch = function(x, gy)
  for i, d in ipairs{ { 0, 0 }, { 12, 3 }, { 24, -1 }, { 35, 4 } } do
    local cx, cy = x + d[1], gy + d[2]
    local n = (i == 2) and 4 or 3
    for k = 1, n do local a = k * 6.2832 / n - 1.5708; local m = c:ellipse(floor(cx + cos(a) * 3.5), floor(cy - 5 + sin(a) * 3.5), 2, 2); c:rim(m, INK); c:fillMask(m, GREEN[(k == 1) and 5 or 4]) end
    c:fillMask(rect(cx - 1, cy - 6, cx + 1, cy - 4), GREEN[5]); P(cx, cy - 5, "#d4f48a"); P(cx, cy - 3, INK); P(cx, cy - 2, GREEN[3]); P(cx, cy - 1, GREEN[2])
  end
end
PR.net = function(x)
  for xx = x, x + 30 do P(xx, 102, INK); P(xx, 103, TIMB[4]) end
  for k = 0, 5 do local fx = x + 2 + k * 5; local m = c:ellipse(fx, 106, 2, 2); c:rim(m, INK); c:fillMask(m, "#e8493b"); P(fx - 1, 105, "#ff9a8a") end
  for y = 109, 134 do
    local hw = 15 - floor((y - 109) * .18)
    for xx = x + 15 - hw, x + 15 + hw do
      if (xx + y) % 5 == 0 or (xx - y) % 5 == 0 then P(xx, y, "#d8c090") end
    end
  end
  P(x + 14, 136, "#d8c090"); P(x + 16, 136, "#d8c090"); P(x + 12, 135, "#a88c5a"); local st = c:ellipse(x + 10, 128, 2, 2); c:fillMask(st, "#a8d0e8"); P(x + 9, 127, "#e8f4f8")
end
PR.strawhat = function(x, y)
  for yy = y - 12, y - 3 do P(x, yy, IRON[4]) end; P(x - 1, y - 13, INK); P(x, y - 14, INK); P(x + 1, y - 13, INK)
  local br = c:ellipse(x, y, 16, 4); c:rim(br, INK); br:each(function(xx, yy) P(xx, yy, (yy < y) and THATCH[5] or THATCH[3]) end)
  local cone = polym{ { x - 8, y - 1 }, { x, y - 17 }, { x + 8, y - 1 } }; c:rim(cone, INK)
  cone:each(function(xx, yy) P(xx, yy, ((xx + yy) % 4 == 0) and THATCH[3] or ((xx < x) and THATCH[6] or THATCH[4])) end)
  c:fillMask(rect(x - 8, y - 4, x + 8, y - 2), "#4a7ac0"); P(x - 6, y - 4, "#82b4e4"); P(x - 2, y - 4, "#82b4e4")
end
PR.lobsterpot = function(x, gy)
  local m = c:ellipse(x, gy - 2, 13, 11):clip(rect(x - 14, gy - 14, x + 14, gy)); c:rim(m, INK)
  m:each(function(xx, y) P(xx, y, ((xx - x) % 5 == 0 or (y - gy) % 4 == 0) and TIMB[4] or ((xx < x) and "#9bc8d8" or "#5a8aa8")) end)
  c:fillMask(rect(x - 3, gy - 5, x + 3, gy - 2), INK); for k = -2, 2 do P(x + k, gy - 4, TIMB[2]) end
  for k = 0, 6 do P(x + 4 + k, gy - 13 - floor(k * .6), "#d8c090") end
  local fl = c:ellipse(x + 11, gy - 18, 3, 3); c:rim(fl, INK); c:fillMask(fl, "#e8493b"); P(x + 10, gy - 19, "#ff9a8a")
end
PR.buoy = function(x, y)
  local m = c:ellipse(x, y, 6, 8); c:rim(m, INK)
  m:each(function(xx, yy) local band = floor((yy - y + 8) / 3) % 2 == 0; P(xx, yy, band and ((xx < x) and "#f8a888" or "#e8493b") or ((xx < x) and "#fff0d8" or "#d8c4a6")) end)
  P(x, y - 11, INK); P(x, y - 10, IRON[4]); P(x, y - 9, IRON[4]); local k = c:ellipse(x, y - 13, 2, 2); c:rim(k, INK)
  for k2 = -6, 6 do P(x + k2, y + 9, "#a8dce0") end; for k2 = -8, 8, 2 do P(x + k2, y + 10, "#2a6a8a") end
end

PR.conehat = function(p) end  -- (drawn by the fennick overlay)
PR.dewbucket = function(x, gy)
  shadow(x + 8, gy, 12)
  local lf = c:line({ { x - 16, gy - 34 }, { x - 4, gy - 22 }, { x + 4, gy - 12 } }, 3); c:rim(lf, INK); c:fillMask(lf, GREEN[4])
  for k = 0, 4 do P(x + 5, gy - 11 + k * 2, "#a8dce0"); end
  local m = box(x, gy - 14, x + 16, gy, TIMB)
  for _, yy in ipairs{ gy - 11, gy - 3 } do for xx = x, x + 16 do P(xx, yy, IRON[4]) end end
  for xx = x + 2, x + 14 do P(xx, gy - 15, "#82b8d8") end; P(x + 4, gy - 15, "#d4ecf8"); P(x + 5, gy - 15, "#d4ecf8")
end
PR.paperlanterns = function(x)
  for xx = x, x + 56 do P(xx, 98 + floor(5 * sin((xx - x) / 56 * 3.14)), INK) end
  for i, cx in ipairs{ x + 6, x + 20, x + 34, x + 48 } do
    local cy = 98 + floor(5 * sin((cx - x) / 56 * 3.14))
    S.glow(cx, cy + 9, 12, "#ff9a8a", .35)
    local m = c:ellipse(cx, cy + 9, 5, 7); c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, ((yy - cy) % 4 == 0) and ROSE[3] or ((xx < cx) and "#ff9a8a" or "#e8493b")) end)
    c:fillMask(rect(cx - 2, cy + 1, cx + 2, cy + 1), INK); c:fillMask(rect(cx - 2, cy + 16, cx + 2, cy + 16), INK); P(cx, cy + 17, "#f8d070"); P(cx, cy + 18, "#f8d070")
    P(cx - 2, cy + 6, "#ffd0c0")
  end
end
PR.teapot = function(x, gy)
  box(x - 10, gy - 14, x + 10, gy - 11, TIMB); for _, lx in ipairs{ x - 8, x + 7 } do c:fillMask(rect(lx, gy - 10, lx + 2, gy), INK); c:fillMask(rect(lx + 1, gy - 10, lx + 1, gy - 1), TIMB[3]) end
  local pm = c:ellipse(x - 2, gy - 21, 6, 5); c:rim(pm, INK); paintR(pm, PINK, x - 2, gy - 21, 6)
  local sp = c:line({ { x + 3, gy - 21 }, { x + 8, gy - 26 } }, 2); c:rim(sp, INK); c:fillMask(sp, PINK[4])
  local h = c:line({ { x - 7, gy - 24 }, { x - 11, gy - 21 }, { x - 7, gy - 18 } }, 1); c:rim(h, INK); c:fillMask(h, PINK[3])
  c:fillMask(rect(x - 4, gy - 27, x, gy - 26), INK); P(x - 2, gy - 28, "#fff0d8")
  P(x - 4, gy - 22, "#fff0d8"); local cu = rect(x + 4, gy - 18, x + 7, gy - 15); c:rim(cu, INK); c:fillMask(cu, "#f8ecd0")
  for k = 0, 3 do P(x + 9 + (k % 2), gy - 29 - k * 2, "#f0e4f0") end
end
PR.hollybush = function(x, gy)
  shadow(x, gy, 18)
  ell(x, gy - 10, 16, 11, GREEN, 14); ell(x - 8, gy - 6, 9, 7, LEAF, 9)
  for _, q in ipairs{ { -8, -16 }, { 3, -14 }, { 10, -8 }, { -4, -6 }, { 6, -19 }, { -12, -8 } } do
    local m = c:ellipse(x + q[1], gy + q[2], 2, 2); c:rim(m, INK); c:fillMask(m, "#e8493b"); P(x + q[1] - 1, gy + q[2] - 1, "#ff9a8a")
  end
  for k = 0, 8 do P(x - 12 + k * 3, gy - 19 + (k % 2), GREEN[6]) end
end
PR.stripebanner = function(x)
  local bar = rect(x - 12, 104, x + 12, 106); c:rim(bar, INK); S.obj(bar, TIMB, { base = 4, lit = 1, shade = 1 })
  local m = polym{ { x - 9, 107 }, { x + 9, 107 }, { x + 9, 150 }, { x, 142 }, { x - 9, 150 } }; c:rim(m, INK)
  m:each(function(xx, y) P(xx, y, (floor((y - 107) / 5) % 2 == 0) and ((xx < x) and "#e66a5a" or "#c8382e") or ((xx < x) and "#fff4dc" or "#e8d8b8")) end)
  P(x - 7, 109, "#fff4dc")
end
PR.woodstack = function(x, gy)
  for row = 0, 2 do for k = 0, 3 - row do
    local lx, ly = x + row * 5 + k * 10 + 5, gy - 4 - row * 8
    local m = c:ellipse(lx, ly, 5, 4); c:rim(m, INK); c:fillMask(m, TIMB[5]); c:fillMask(c:ellipse(lx, ly, 3, 2), TIMB[6]); P(lx, ly, TIMB[3]); P(lx + 1, ly, TIMB[3])
  end end
end
PR.groundlantern = function(x, gy)
  S.glow(x, gy - 8, 16, "#ffd070", .45)
  box(x - 5, gy - 2, x + 5, gy, IRON); c:fillMask(rect(x - 4, gy - 12, x + 4, gy - 3), INK); c:fillMask(rect(x - 3, gy - 11, x + 3, gy - 4), "#ffe08a"); c:fillMask(rect(x - 1, gy - 9, x + 1, gy - 6), "#fff6cc")
  for k = -3, 3 do P(x + k, gy - 13, INK) end; P(x, gy - 14, INK); P(x - 1, gy - 15, INK); P(x, gy - 15, IRON[4]); P(x + 1, gy - 15, INK); P(x, gy - 7, IRON[3])
end
PR.juniperbush = function(x, gy)
  shadow(x, gy, 16); ell(x, gy - 11, 14, 11, FERN, 13); ell(x + 8, gy - 6, 8, 6, GREEN, 8)
  for _, q in ipairs{ { -8, -14 }, { 2, -17 }, { 8, -10 }, { -4, -7 }, { 12, -5 }, { -11, -6 } } do
    local m = c:ellipse(x + q[1], gy + q[2], 2, 2); c:rim(m, INK); c:fillMask(m, "#5a78c8"); P(x + q[1] - 1, gy + q[2] - 1, "#c8d8f4"); P(x + q[1] + 1, gy + q[2] + 1, "#2a3a7a")
  end
end
PR.woolbasket = function(x, gy)
  shadow(x + 11, gy, 15)
  for i, q in ipairs{ { 4, -14, "#e8493b" }, { 12, -16, "#82b4e4" }, { 19, -13, "#f8d070" } } do
    local m = c:ellipse(x + q[1], gy + q[2], 5, 5); c:rim(m, INK); c:fillMask(m, q[3])
    for k = -3, 3 do P(x + q[1] + k, gy + q[2] + floor(k * .6), mixc(q[3], "#2b1c26", .3)) end; P(x + q[1] - 2, gy + q[2] - 3, "#fff8e8")
  end
  local m = box(x, gy - 12, x + 22, gy, DIRT)
  m:each(function(xx, yy) if ((floor((xx - x) / 3) + floor((yy - gy) / 3)) % 2 == 0) then P(xx, yy, DIRT[3]) end end)
  for xx = x, x + 22 do P(xx, gy - 12, DIRT[6]) end
  for k = 0, 4 do P(x + 24 + k, gy - 6 + floor(k * .8), "#82b4e4") end
end
PR.leafpile = function(x, gy)
  local m = HP.mask()
  for y = gy - 12, gy do local hw = floor(18 * sqrt(max(0, 1 - ((gy - y - 0) / 14) ^ 2)) + .5); for xx = x - hw, x + hw do m:set(xx, y) end end
  c:rim(m, INK)
  m:each(function(xx, y) local h = hash(xx // 2, y // 2, 9); P(xx, y, (h < .25) and ORNG[4] or (h < .5) and "#d4503f" or (h < .75) and GOLD[4] or ORNG[5]); if y > gy - 3 then P(xx, y, mixc(c:get(xx, y), "#4a2210", .4)) end end)
  for k = 0, 5 do P(x - 12 + k * 4, gy - 8 + (k % 3), GOLD[6]) end
  P(x + 20, gy - 2, "#d4503f"); P(x + 22, gy, GOLD[4]); P(x - 22, gy - 1, ORNG[4])
end
PR.rake = function(x, gy)
  stick(x + 2, gy, x + 10, gy - 46, 2, TIMB)
  local hd = rect(x - 4, gy - 2, x + 8, gy); c:rim(hd, INK); c:fillMask(hd, IRON[4])
  for k = 0, 6 do P(x - 3 + k * 2, gy + 1, INK); P(x - 3 + k * 2, gy + 2, IRON[3]) end
end
PR.starjar = function(x, gy)
  S.glow(x, gy - 8, 16, "#c8f0ff", .4)
  local m = box(x - 6, gy - 14, x + 6, gy, { "#14182e", "#2a4a6a", "#5a96bc", "#a8dcf0", "#e0f6ff", "#fffaf0" }); c:fillMask(rect(x - 3, gy - 12, x + 3, gy - 2), "#e8fbff"); P(x - 2, gy - 10, "#fffaf0"); P(x + 2, gy - 6, "#82d4f0"); P(x, gy - 8, "#ffe08a")
  c:fillMask(rect(x - 5, gy - 17, x + 5, gy - 15), INK); c:fillMask(rect(x - 4, gy - 16, x + 4, gy - 16), TIMB[4])
end
PR.telescope = function(x, gy)
  for _, d in ipairs{ -11, 0, 11 } do local l = c:line({ { x + 2, gy - 22 }, { x + 2 + d, gy } }, 1); c:rim(l, INK); c:fillMask(l, TIMB[4]) end
  local t = c:line({ { x - 12, gy - 14 }, { x + 18, gy - 40 } }, 7); c:rim(t, INK)
  t:each(function(xx, yy) local cy = gy - 14 - (xx - (x - 12)) * .87; P(xx, yy, (yy < cy) and BLUEW[5] or BLUEW[3]) end)
  local b = c:line({ { x + 12, gy - 35 }, { x + 18, gy - 40 } }, 7); c:fillMask(b, GOLD[4]); local rg = c:line({ { x - 4, gy - 22 }, { x - 1, gy - 24 } }, 8); c:fillMask(rg, GOLD[3])
  P(x - 11, gy - 14, "#a8f0ff"); P(x - 12, gy - 15, "#e8ffff")
  local kn = c:ellipse(x + 2, gy - 22, 3, 3); c:rim(kn, INK); c:fillMask(kn, GOLD[4])
end
PR.easel = function(x, gy)
  for _, d in ipairs{ -12, 12 } do local l = c:line({ { x + d // 3, gy - 46 }, { x + d, gy } }, 2); c:rim(l, INK); c:fillMask(l, TIMB[4]) end
  c:fillMask(c:line({ { x, gy - 40 }, { x, gy - 8 } }, 1), TIMB[3])
  local cv = box(x - 13, gy - 44, x + 13, gy - 14, { "#14182e", "#222a4c", "#2a3460", "#34436e", "#4a5e90", "#f8ecd0" })
  cv:each(function(xx, yy) if yy > gy - 43 and xx > x - 13 and yy < gy - 15 and xx < x + 13 then P(xx, yy, (yy < gy - 30) and "#2a3460" or "#3c3a78") end end)
  for _, s in ipairs{ { -8, -38 }, { 4, -34 }, { 9, -40 }, { -2, -26 }, { -9, -22 } } do P(x + s[1], gy + s[2], "#fff0b0"); P(x + s[1] + 1, gy + s[2], "#f8d070") end
  local mm = c:ellipse(x + 6, gy - 24, 3, 3); mm:cut(c:ellipse(x + 8, gy - 25, 3, 3)); c:fillMask(mm, "#f8d070")
  c:fillMask(rect(x - 14, gy - 14, x + 14, gy - 12), TIMB[3]); c:fillMask(rect(x - 12, gy - 12, x - 8, gy - 12), "#e8493b"); c:fillMask(rect(x - 6, gy - 12, x - 4, gy - 12), "#82b4e4")
end
PR.bookstack = function(x, gy)
  shadow(x + 12, gy, 18)
  local cols = { { "#4a7ac0", 22, 6 }, { "#d4503f", 18, 5 }, { "#58a860", 20, 5 }, { "#f0a048", 15, 5 } }
  local yy = gy
  for i, b in ipairs(cols) do
    local R = { mixc(b[1], "#101020", .6), mixc(b[1], "#101020", .35), mixc(b[1], "#101020", .15), b[1], mixc(b[1], "#fff0d8", .3), mixc(b[1], "#fff0d8", .55) }
    local ox = (i % 2 == 0) and 3 or 0
    box(x + ox, yy - b[3], x + ox + b[2], yy, R); c:fillMask(rect(x + ox + 2, yy - 3, x + ox + b[2] - 2, yy - 3), "#f8ecd0")
    yy = yy - b[3] - 1
  end
  P(x + 18, yy - 1, INK)
end
PR.inkwell = function(x, gy)
  local m = ell(x, gy - 5, 6, 5, { "#14182e", "#222a4c", "#34436e", "#4a5e90", "#7e94bc", "#c8d8f4" }, 6); c:fillMask(rect(x - 3, gy - 12, x + 3, gy - 9), INK); c:fillMask(rect(x - 2, gy - 11, x + 2, gy - 10), IRON[4])
  local q = c:line({ { x + 1, gy - 12 }, { x + 9, gy - 34 } }, 1); c:rim(q, INK); c:fillMask(q, "#f8ecd0")
  local v = polym{ { x + 9, gy - 34 }, { x + 16, gy - 36 }, { x + 11, gy - 24 }, { x + 5, gy - 22 } }; c:rim(v, INK); c:fillMask(v, "#f8ecd0"); for k = 0, 5 do P(x + 8 + k, gy - 31 + floor(k * .8), "#c8a090") end
end
PR.plumtree = function(x, gy)
  shadow(x, gy, 16)
  local tm = rect(x - 2, gy - 28, x + 2, gy); c:rim(tm, INK); S.obj(tm, TIMB, { base = 4, lit = 1, shade = 1 })
  GX.foliage(c, x, gy - 40, 30, 26, R4(LEAF), x)
  for _, q in ipairs{ { -10, -36 }, { 4, -30 }, { 10, -44 }, { -4, -46 }, { -12, -26 }, { 12, -33 } } do
    local m = c:ellipse(x + q[1], gy + q[2], 3, 3); c:rim(m, INK); c:fillMask(m, PLUMR[3]); P(x + q[1] - 1, gy + q[2] - 1, PLUMR[6]); P(x + q[1] + 1, gy + q[2] + 1, PLUMR[1])
  end
end
PR.pottower = function(x, gy)
  shadow(x, gy, 14)
  for i, w in ipairs{ 22, 18, 14 } do
    local y1 = gy - (i - 1) * 12
    local m = polym{ { x - w // 2, y1 - 12 }, { x + w // 2, y1 - 12 }, { x + w // 2 - 3, y1 }, { x - w // 2 + 3, y1 } }; c:rim(m, INK)
    m:each(function(xx, yy) local t = (yy < y1 - 9) and 5 or ((xx < x) and 4 or 3); if yy < y1 - 10 then t = 5 end; P(xx, yy, TERRA[t]) end)
    for xx = x - w // 2 + 1, x + w // 2 - 1 do P(xx, y1 - 12, TERRA[6]) end
    local fc = ({ "#ffd24a", "#f0809c", "#fff0d8" })[i]
    for k = -1, 1 do P(x + k * 4, y1 - 15 - (k + 1) % 2, "#3a704a"); P(x + k * 4, y1 - 14, "#3a704a"); local fx, fy = x + k * 4, y1 - 17 - (k + 1) % 2; P(fx, fy, "#ffd24a"); P(fx - 1, fy, fc); P(fx + 1, fy, fc); P(fx, fy - 1, fc); P(fx, fy + 1, fc) end
  end
end
PR.pinwheel = function(x, gy)
  stick(x, gy, x + 1, gy - 36, 2, TIMB)
  local cx, cy = x + 1, gy - 38
  local cols = { "#e8493b", "#4a7ac0", "#ffd24a", "#58a860" }
  for i = 0, 3 do
    local a = i * 1.5708
    local ax, ay = cos(a), sin(a); local bx, by = cos(a + 1.5708), sin(a + 1.5708)
    local m = polym{ { cx, cy }, { cx + ax * 10, cy + ay * 10 }, { cx + ax * 10 + bx * 6, cy + ay * 10 + by * 6 } }; c:rim(m, INK); c:fillMask(m, cols[i + 1])
  end
  c:fillMask(c:ellipse(cx, cy, 2, 2), GOLD[5]); P(cx - 1, cy - 1, GOLD[6])
end
PR.fernpot = function(x, gy)
  shadow(x, gy, 14)
  for i = -3, 3 do
    local len = 26 - abs(i) * 3
    for t = 0, 1, .03 do
      local fx = floor(x + i * 7 * t + (i * 6) * t * t * .5 + .5); local fy = floor(gy - 12 - len * sin(t * 1.5) * (1 - .3 * abs(i) / 3) + t * t * 14 * abs(i) / 3 + .5)
      P(fx, fy, FERN[(t < .5) and 4 or 5]); if t > .15 and floor(t * 33) % 2 == 0 then P(fx, fy + 1, FERN[3]); P(fx + (i >= 0 and 1 or -1), fy - 1, FERN[6]) end
    end
  end
  local m = polym{ { x - 10, gy - 14 }, { x + 10, gy - 14 }, { x + 7, gy }, { x - 7, gy } }; c:rim(m, INK)
  m:each(function(xx, yy) P(xx, yy, (yy < gy - 11) and TERRA[5] or ((xx < x) and TERRA[4] or TERRA[3])) end)
end
PR.hangfern = function(x, y)
  for _, dx in ipairs{ -6, 6 } do for yy = y - 14, y - 1 do P(x + dx // 2 * (yy - y + 14) // 14 * 2 + 0, yy, INK) end end
  for xx = x - 6, x + 6 do P(xx, y - 14, INK) end
  local m = c:ellipse(x, y + 1, 8, 4):clip(rect(x - 9, y, x + 9, y + 6)); c:rim(m, INK); paintR(m, DIRT, x, y, 8)
  for i = -3, 3 do for t = 0, 1, .05 do local fx, fy = floor(x + i * 4 + i * 3 * t), floor(y + 2 + 20 * t * (.5 + abs(i) / 6)); P(fx, fy, FERN[4 + (floor(t * 20) % 2)]); if floor(t * 20) % 2 == 0 then P(fx + 1, fy, FERN[3]) end end end
end
PR.amphora = function(x, gy)
  shadow(x, gy, 14)
  local pts = { { x - 5, gy - 40 }, { x + 5, gy - 40 }, { x + 4, gy - 34 }, { x + 12, gy - 24 }, { x + 11, gy - 10 }, { x + 4, gy }, { x - 4, gy }, { x - 11, gy - 10 }, { x - 12, gy - 24 }, { x - 4, gy - 34 } }
  local m = polym(pts); c:rim(m, INK); paintR(m, TERRA, x - 4, gy - 24, 14)
  for xx = x - 11, x + 11 do for _, yy in ipairs{ gy - 20, gy - 12 } do if m:has(xx, yy) then P(xx, yy, "#2b1c26") end end end
  for xx = x - 11, x + 11 do if m:has(xx, gy - 16) then P(xx, gy - 16, (xx % 4 < 2) and GOLD[4] or "#fff0c0") end end
  local h1 = c:line({ { x - 5, gy - 37 }, { x - 12, gy - 33 }, { x - 11, gy - 27 } }, 1); c:rim(h1, INK)
  local lip = rect(x - 6, gy - 43, x + 6, gy - 40); c:rim(lip, INK); c:fillMask(lip, TERRA[5]); P(x - 5, gy - 43, TERRA[6])
end
PR.drum = function(x, gy)
  shadow(x, gy, 14)
  local m = rect(x - 11, gy - 22, x + 11, gy); m:add(c:ellipse(x, gy, 11, 3)); c:rim(m, INK)
  m:each(function(xx, yy) P(xx, yy, (xx < x - 4) and TERRA[5] or ((xx > x + 5) and TERRA[2] or TERRA[3])) end)
  for k = -9, 9, 6 do local l = c:line({ { x + k, gy - 20 }, { x + k + 3, gy - 2 } }, 1); c:fillMask(l, "#f8ecd0"); local l2 = c:line({ { x + k + 3, gy - 20 }, { x + k, gy - 2 } }, 1); c:fillMask(l2, "#f8ecd0") end
  local top = c:ellipse(x, gy - 22, 11, 4); c:rim(top, INK); c:fillMask(top, "#e8d0a0"); c:fillMask(c:ellipse(x - 2, gy - 23, 6, 2), "#f8ecd0")
end
PR.kentebanner = function(x)
  local bar = rect(x - 14, 104, x + 14, 106); c:rim(bar, INK); S.obj(bar, TIMB, { base = 4, lit = 1, shade = 1 })
  local m = rect(x - 12, 107, x + 12, 150); c:rim(m, INK)
  m:each(function(xx, yy)
    local band = floor((yy - 107) / 7); local cols = { "#d4503f", "#f4c84a", "#3a8a50", "#2b1c26", "#f4c84a", "#d4503f" }
    local col = cols[band % 6 + 1]
    if (xx + yy) % 6 == 0 and band % 2 == 0 then col = "#fff0d0" end
    if yy < 109 then col = mixc(col, "#fff0d0", .3) end
    P(xx, yy, col)
  end)
  for xx = x - 12, x + 12, 3 do P(xx, 151, "#d4503f"); P(xx, 152, "#f4c84a") end
end
PR.sunflowers = function(x, gy)
  for i, d in ipairs{ { 0, 62 }, { 16, 48 }, { 31, 70 } } do
    local fx, ft = x + d[1], gy - d[2]
    for y = gy, ft + 6, -1 do P(fx, y, INK); P(fx + 1, y, GREEN[(y % 4 < 2) and 4 or 3]); P(fx + 2, y, INK) end
    local lm = c:ellipse(fx + 7, gy - 16 - i * 4, 6, 3); c:rim(lm, INK); c:fillMask(lm, GREEN[4]); P(fx + 4, gy - 18 - i * 4, GREEN[6])
    for k = 0, 11 do local a = k * .5236; local px, py = floor(fx + 1 + cos(a) * 9), floor(ft + sin(a) * 9); local pm = c:ellipse(px, py, 3, 3); c:rim(pm, INK); c:fillMask(pm, (k % 2 == 0) and "#ffd24a" or "#f8b020") end
    local dm2 = c:ellipse(fx + 1, ft, 5, 5); c:rim(dm2, INK); c:fillMask(dm2, "#6a4428"); P(fx - 1, ft - 2, "#946a38"); P(fx + 2, ft + 2, "#46282a")
  end
end
PR.sundial = function(x, gy)
  shadow(x, gy, 16)
  box(x - 6, gy - 16, x + 6, gy, STONE)
  local top = c:ellipse(x, gy - 18, 15, 5); c:rim(top, INK); top:each(function(xx, yy) P(xx, yy, (yy < gy - 18) and STONE[6] or STONE[4]) end)
  for k = 0, 8 do local a = 3.14 + k * .39; P(floor(x + cos(a) * 12), floor(gy - 18 + sin(a) * 3.4 + 1), INK) end
  local g = polym{ { x - 1, gy - 19 }, { x - 1, gy - 28 }, { x + 7, gy - 19 } }; c:rim(g, INK); c:fillMask(g, GOLD[4]); P(x, gy - 26, GOLD[6]); P(x + 8, gy - 17, "#4a2a5a"); P(x + 10, gy - 17, "#4a2a5a")
end
PR.bed = function(x, gy)
  shadow(x + 18, gy, 26)
  box(x, gy - 12, x + 36, gy, TIMB); for xx = x + 1, x + 35 do P(xx, gy - 6, TIMB[2]) end
  for xx = x + 1, x + 35 do P(xx, gy - 13, "#5a3c2c") end
  local cols = { "#f0809c", "#ffd24a", "#c8b8ec", "#fff0d8", "#e8493b", "#f0809c", "#82b4e4" }
  for i = 0, 6 do local fx = x + 3 + i * 5; local h = 6 + (i * 5) % 7; for k = 0, h do P(fx, gy - 13 - k, GREEN[4 - (k % 2)]) end
    local fy = gy - 14 - h; P(fx, fy, "#ffe38a"); P(fx - 1, fy, cols[i + 1]); P(fx + 1, fy, cols[i + 1]); P(fx, fy - 1, cols[i + 1]); P(fx, fy + 1, cols[i + 1]) end
end
PR.wheelbarrow = function(x, gy)
  shadow(x + 14, gy, 20)
  local tub = polym{ { x, gy - 22 }, { x + 26, gy - 22 }, { x + 22, gy - 8 }, { x + 5, gy - 8 } }; c:rim(tub, INK)
  tub:each(function(xx, yy) P(xx, yy, (yy < gy - 20) and BARN[5] or ((xx < x + 12) and BARN[4] or BARN[3])) end)
  for k = 0, 4 do local px = x + 4 + k * 5; P(px, gy - 25 - (k % 2), GREEN[5]); P(px + 1, gy - 24, GREEN[4]); P(px, gy - 23, GREEN[3]) end
  P(x + 9, gy - 28, "#f0809c"); P(x + 8, gy - 28, "#fac4d4"); P(x + 19, gy - 27, "#ffd24a"); P(x + 18, gy - 27, "#fff0d8")
  local lg = c:line({ { x + 24, gy - 12 }, { x + 34, gy - 18 } }, 2); c:rim(lg, INK); c:fillMask(lg, TIMB[4])
  local wl = c:ellipse(x + 8, gy - 4, 5, 5); c:rim(wl, INK); c:fillMask(wl, IRON[3]); c:fillMask(c:ellipse(x + 8, gy - 4, 2, 2), GOLD[4])
  c:fillMask(rect(x + 20, gy - 8, x + 21, gy), INK)
end
PR.signpost = function(x, gy)
  local pm = rect(x, gy - 62, x + 4, gy); c:rim(pm, INK); S.obj(pm, TIMB, { base = 4, lit = 1, shade = 1 })
  for i, d in ipairs{ { -1, 56, 22 }, { 1, 44, 18 }, { -1, 32, 20 } } do
    local y0 = gy - d[2]; local x0, x1 = x + 2 - (d[1] < 0 and d[3] or 0), x + 2 + (d[1] > 0 and d[3] or 0)
    local tip = (d[1] < 0) and { x0 - 4, y0 + 3 } or { x1 + 4, y0 + 3 }
    local m = polym{ { x0, y0 }, { x1, y0 }, (d[1] > 0) and tip or { x1, y0 + 6 }, (d[1] > 0) and { x1, y0 + 6 } or tip, { x0, y0 + 6 } }
    if d[1] < 0 then m = polym{ { x0, y0 }, { x1, y0 }, { x1, y0 + 6 }, { x0, y0 + 6 }, tip } else m = polym{ { x0, y0 }, { x1, y0 }, tip, { x1, y0 + 6 }, { x0, y0 + 6 } } end
    c:rim(m, INK); m:each(function(xx, yy) P(xx, yy, (yy == y0) and OAK[6] or ((yy >= y0 + 5) and OAK[3] or OAK[5])) end)
    for k = 2, d[3] - 4, 4 do P(x0 + k + (d[1] < 0 and 3 or 0), y0 + 3, TIMB[2]) end
  end
  P(x + 2, gy - 64, INK); P(x + 2, gy - 63, TIMB[5])
end
PR.luggage = function(x, gy)
  shadow(x + 14, gy, 20)
  local a = box(x, gy - 14, x + 28, gy, { "#3a1814", "#5a2a24", "#843230", "#a6483a", "#c66648", "#e08c62" })
  for _, sx in ipairs{ x + 6, x + 22 } do c:fillMask(rect(sx, gy - 14, sx + 1, gy), "#2b1c26"); c:fillMask(rect(sx - 1, gy - 14, sx - 1, gy), GOLD[4]) end
  c:fillMask(rect(x + 12, gy - 8, x + 16, gy - 5), GOLD[4]); P(x + 13, gy - 7, INK)
  local b = box(x + 5, gy - 26, x + 23, gy - 15, { "#1c3434", "#2a5240", "#3a704a", "#529054", "#78b064", "#a8d080" })
  c:fillMask(rect(x + 13, gy - 26, x + 14, gy - 15), "#2b1c26"); P(x + 8, gy - 22, "#ffd24a"); P(x + 9, gy - 22, "#ffd24a"); P(x + 18, gy - 19, "#f0809c"); P(x + 19, gy - 20, "#fff0d8")
  for k = 0, 3 do P(x + 12 + k, gy - 29, INK) end; P(x + 12, gy - 28, INK); P(x + 15, gy - 28, INK)
end
PR.anchor = function(x, gy)
  local col = IRON
  c:fillMask(rect(x - 1, gy - 26, x + 1, gy - 4), INK); c:fillMask(rect(x, gy - 25, x, gy - 5), col[5])
  local bar = rect(x - 7, gy - 22, x + 7, gy - 20); c:rim(bar, INK); c:fillMask(bar, col[5])
  local r = c:ellipse(x, gy - 29, 3, 3); r:cut(c:ellipse(x, gy - 29, 1, 1)); c:rim(r, INK); c:fillMask(r, col[5])
  local arc = c:ellipse(x, gy - 10, 12, 10):clip(rect(x - 13, gy - 10, x + 13, gy)); c:rim(arc, INK); arc:cut(c:ellipse(x, gy - 10, 9, 7)); c:fillMask(arc, col[4])
  P(x - 12, gy - 11, col[6]); P(x + 12, gy - 11, col[6]); P(x - 11, gy - 12, INK); P(x + 11, gy - 12, INK)
end
PR.ropecoil = function(x, gy)
  for k = 0, 3 do local m = c:ellipse(x, gy - k * 2, 12 - k, 4); c:rim(m, INK); c:fillMask(m, (k % 2 == 0) and "#d8c090" or "#b89a68") end
  c:fillMask(c:ellipse(x, gy - 8, 5, 2), "#8a6a3c"); for k = -10, 10, 4 do P(x + k, gy - 2 - abs(k) // 5, "#fff0c0") end
end
PR.lilypads = function(x, y)
  for _, q in ipairs{ { 0, 0, 9 }, { 22, 6, 7 }, { 10, 14, 6 }, { -14, 8, 5 } } do
    local m = c:ellipse(x + q[1], y + q[2], q[3], floor(q[3] / 2) + 1); c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, (yy < y + q[2]) and GREEN[5] or GREEN[4]) end)
    for k = 0, q[3] - 2 do P(x + q[1] + k, y + q[2], GREEN[3]) end; P(x + q[1] - 2, y + q[2] - 1, GREEN[6])
  end
  local fl = c:ellipse(x + 1, y - 2, 3, 2); c:rim(fl, INK); c:fillMask(fl, "#fac4d4"); P(x + 1, y - 3, "#ffd24a")
end
PR.dandelion = function(x, gy)
  stick(x, gy, x + 3, gy - 70, 2, FERN)
  local cx, cy = x + 3, gy - 78
  S.glow(cx, cy, 16, "#f4f8ff", .25)
  for k = 0, 17 do local a = k * .349; local ex, ey = floor(cx + cos(a) * 10), floor(cy + sin(a) * 10)
    local l = c:line({ { cx, cy }, { ex, ey } }, 1); c:fillMask(l, "#e8eef8"); P(ex, ey, "#fffaf0"); P(floor(cx + cos(a) * 11), floor(cy + sin(a) * 11), "#fffaf0") end
  c:fillMask(c:ellipse(cx, cy, 2, 2), "#8a7a60")
  P(cx + 14, cy - 8, "#fffaf0"); P(cx + 18, cy - 14, "#e8eef8"); P(cx - 16, cy - 4, "#fffaf0")
end
PR.cauldron = function(x, gy)
  shadow(x, gy, 18)
  for _, d in ipairs{ -9, 9 } do c:fillMask(rect(x + d - 1, gy - 4, x + d + 1, gy), INK) end
  S.glow(x, gy - 22, 22, "#a8f070", .3)
  local m = c:ellipse(x, gy - 12, 14, 11); c:rim(m, INK); m:each(function(xx, yy) local l = lit(xx, yy, x, gy - 12, 14); P(xx, yy, IRON[l > .5 and 5 or (l > 0 and 4 or (l > -.5 and 3 or 2))]) end)
  local rim = c:ellipse(x, gy - 21, 13, 3); c:rim(rim, INK); c:fillMask(rim, IRON[5]); c:fillMask(c:ellipse(x, gy - 21, 11, 2), "#8ae060")
  for _, b in ipairs{ { -4, -27, 3 }, { 4, -29, 2 }, { 0, -33, 2 }, { 8, -25, 2 } } do local bm = c:ellipse(x + b[1], gy + b[2], b[3], b[3]); c:rim(bm, "#4a8a30"); c:fillMask(bm, "#b4f080"); P(x + b[1] - 1, gy + b[2] - 1, "#f0ffd0") end
  P(x - 8, gy - 16, IRON[6]); P(x - 9, gy - 14, IRON[6]); for _, d in ipairs{ -13, 13 } do P(x + d, gy - 18, INK) end
end
PR.lampwall = function(x, y) end
PR.shutter = function() end

---------------------------------------------------------------- DOOR OVERLAYS (dm = door mask)
local function onm(dm, x, y, col) if dm:has(x, y) then P(x, y, col) end end
OV.peep = function(p, dm)
  local m = c:ellipse(240, 152, 8, 8); c:rim(m, INK); c:fillMask(m, GOLD[3])
  local g = c:ellipse(240, 152, 6, 6); c:rim(g, GOLD[1]); c:fillMask(g, "#3a2c4a"); S.glow(240, 152, 14, "#ffd070", .25)
  for k = -5, 5 do P(240 + k, 152, GOLD[4]); P(240, 152 + k, GOLD[4]) end
  P(237, 149, "#fff0b0"); P(238, 148, "#fff0b0"); P(243, 155, "#f8d070"); P(236, 154, "#f8d070")
  for _, d in ipairs{ { -8, 0 }, { 8, 0 }, { 0, -8 }, { 0, 8 } } do P(240 + d[1], 152 + d[2], GOLD[6]) end
end
OV.thorns = function(p, dm)
  for y = 144, 198, 9 do for x = 224, 258, 9 do
    local xo = ((y - 144) // 9 % 2 == 1) and 4 or 0
    local sx = x + xo
    if dm:has(sx, y) and dm:has(sx, y - 3) then P(sx, y - 3, IRON[6]); P(sx, y - 2, IRON[5]); P(sx - 1, y - 1, IRON[4]); P(sx, y - 1, IRON[4]); P(sx + 1, y - 1, IRON[3]); P(sx, y, INK) end
  end end
end
OV.clover = function(p, dm)
  S.glow(240, 168, 18, "#d4f48a", .25)
  for _, q in ipairs{ { 235, 160 }, { 245, 160 }, { 235, 171 }, { 245, 171 } } do
    local m = c:ellipse(q[1], q[2], 5, 5); c:rim(m, INK); m:each(function(x, y) local l = lit(x, y, q[1], q[2], 5); P(x, y, LEAF[l > .3 and 6 or (l > -.3 and 5 or 4)]) end)
    P(q[1], q[2], LEAF[3])
  end
  c:fillMask(c:ellipse(240, 165, 3, 3), LEAF[4]); P(239, 164, LEAF[6])
  for y = 177, 196 do P(240 + floor(sin((y - 177) / 5) * 2), y, LEAF[(y % 4 < 2) and 4 or 3]) end
end
OV.dewdrop = function(p, dm)
  local pts = { { 240, 140 } }
  for a = -2.3, 2.3, .25 do pts[#pts + 1] = { 240 + sin(a) * 12, 163 - cos(a) * 12 + 2 } end
  pts[#pts + 1] = { 240, 140 }
  local m = polym(pts); c:rim(m, INK)
  m:each(function(x, y) local l = lit(x, y, 240, 160, 14); P(x, y, BLUEW[l > .5 and 6 or (l > 0 and 5 or (l > -.5 and 4 or 3))]) end)
  P(235, 160, "#fff8dc"); P(235, 159, "#fff8dc"); P(236, 157, "#fff8dc"); P(244, 168, BLUEW[2])
  for k = -6, 6 do P(240 + k, 188, BLUEW[6]) end; for k = -9, 9 do P(240 + k, 191, BLUEW[5]) end
end
OV.conehat = function(p, dm)   -- wizard-hat awning over the round door
  local base = 134
  local m = polym{ { 238, 100 }, { 243, 100 }, { 262, base }, { 218, base } }
  m:add(polym{ { 243, 100 }, { 247, 106 }, { 244, 112 } })
  c:rim(m, INK)
  m:each(function(x, y) local t = (y - 100) / 34; local l = (240 - x) / 22 - t * .2; P(x, y, BLUEW[l > .25 and 5 or (l > -.2 and 4 or 3)]) end)
  c:fillMask(rect(223, base - 8, 257, base - 5), GOLD[4]); for x = 223, 257 do P(x, base - 8, GOLD[6]); P(x, base - 5, GOLD[2]) end; c:fillMask(rect(236, base - 9, 243, base - 4), INK); c:fillMask(rect(237, base - 8, 242, base - 5), GOLD[5])
  local br = c:ellipse(240, base + 1, 31, 4); c:rim(br, INK); br:each(function(x, y) P(x, y, (y < base + 1) and BLUEW[4] or BLUEW[2]) end)
  for _, s in ipairs{ { 236, 116 }, { 244, 124 }, { 233, 128 }, { 248, 112 } } do P(s[1], s[2], "#fff0b0"); P(s[1] + 1, s[2], "#f8d070"); P(s[1], s[2] + 1, "#f8d070") end
end
OV.star = function(p, dm)
  S.glow(240, 166, 22, "#ffd070", .35)
  local m = star5(240, 166, 14, 6); c:rim(m, INK)
  m:each(function(x, y) P(x, y, (x + y < 404) and GOLD[6] or GOLD[4]) end)
  P(239, 160, "#fffbe0"); P(238, 161, "#fffbe0")
  for _, s in ipairs{ { 226, 150 }, { 255, 152 }, { 227, 186 }, { 254, 188 } } do P(s[1], s[2], "#fff6cc"); P(s[1] + 1, s[2], "#ffd24a"); P(s[1] - 1, s[2], "#ffd24a"); P(s[1], s[2] + 1, "#ffd24a"); P(s[1], s[2] - 1, "#ffd24a") end
end
OV.wreath = function(p, dm)
  local cx, cy = 240, 160
  for i = 0, 27 do local a = i * .2244; local x, y = floor(cx + cos(a) * 13), floor(cy + sin(a) * 13)
    local m = c:ellipse(x, y, 3, 3); c:rim(m, INK); c:fillMask(m, (i % 2 == 0) and GREEN[4] or GREEN[3]); P(x - 1, y - 1, GREEN[6]) end
  for i = 0, 27 do local a = i * .2244; local x, y = floor(cx + cos(a) * 13), floor(cy + sin(a) * 13); P(x, y, (i % 2 == 0) and GREEN[5] or GREEN[4]) end
  for _, a in ipairs{ .4, 1.2, 2.3, 3.4, 4.3, 5.4 } do local x, y = floor(cx + cos(a) * 13), floor(cy + sin(a) * 13); local m = c:ellipse(x, y, 2, 2); c:rim(m, INK); c:fillMask(m, "#e8493b"); P(x - 1, y - 1, "#ff9a8a") end
  local bw = polym{ { 240, 174 }, { 231, 170 }, { 231, 180 } }; c:rim(bw, INK); c:fillMask(bw, "#d4503f"); local bw2 = polym{ { 240, 174 }, { 249, 170 }, { 249, 180 } }; c:rim(bw2, INK); c:fillMask(bw2, "#b0343a")
  c:fillMask(rect(239, 172, 241, 176), "#d4503f"); P(239, 172, "#ff9a8a")
  for y = 176, 184 do P(237, y, "#d4503f"); P(243, y + 1, "#b0343a") end
end
OV.knit = function(p, dm)
  local cols = { { "#f4e6c8", "#d8c4a0" }, { "#5a8fd0", "#3f6cb4" }, { "#f4e6c8", "#d8c4a0" }, { "#d4503f", "#b0343a" } }
  dm:each(function(x, y)
    local band = floor((y - 130) / 9) % 4 + 1; local cc = cols[band]
    local ph = (x + (y // 3) * 2) % 4
    P(x, y, (ph < 2) and cc[1] or cc[2]); if (y % 3 == 2) then P(x, y, mixc(cc[2], "#2b1c26", .25)) end
  end)
  dm:each(function(x, y) if not dm:has(x, y - 1) or not dm:has(x - 1, y) then P(x, y, "#5a3c1c") end end)
end
OV.mapleleaf = function(p, dm)
  local half = { { 0, -15 }, { 3, -8 }, { 9, -11 }, { 7, -3 }, { 14, -4 }, { 8, 3 }, { 12, 8 }, { 3, 6 }, { 2, 14 } }
  local pts = {}
  for _, q in ipairs(half) do pts[#pts + 1] = { 240 + q[1], 164 + q[2] } end
  for i = #half, 1, -1 do pts[#pts + 1] = { 240 - half[i][1], 164 + half[i][2] } end
  local m = polym(pts); c:rim(m, INK)
  m:each(function(x, y) local l = lit(x, y, 240, 164, 16); P(x, y, (l > .4) and "#f08a58" or (l > -.2 and "#d4503f" or "#a6283a")) end)
  for y = -14, 17 do P(240, 164 + y, (y > 13) and INK or "#8a1c2a") end
  for _, d in ipairs{ { 1, -1 }, { -1, -1 }, { 1, 1 }, { -1, 1 } } do for k = 1, 6 do P(240 + d[1] * k, 164 + d[2] * k - 2, "#8a1c2a") end end
  P(236, 156, "#ffc898"); P(235, 157, "#ffc898")
end
OV.constel = function(p, dm)
  local st = { { 229, 150 }, { 238, 160 }, { 250, 154 }, { 246, 172 }, { 232, 182 }, { 244, 192 } }
  for i = 1, #st - 1 do local l = c:line({ st[i], st[i + 1] }, 1); l:each(function(x, y) if dm:has(x, y) then P(x, y, "#a48ae0") end end) end
  for _, s in ipairs(st) do S.glow(s[1], s[2], 8, "#ffd070", .25); P(s[1], s[2], "#fffbe0"); for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do P(s[1] + d[1], s[2] + d[2], "#f8d070") end end
end
OV.quill = function(p, dm)
  local sh = c:line({ { 226, 196 }, { 252, 146 } }, 2); c:rim(sh, INK); c:fillMask(sh, "#f8ecd0")
  local v = polym{ { 252, 146 }, { 262, 140 }, { 262, 158 }, { 252, 174 }, { 238, 182 }, { 240, 170 } }; c:rim(v, INK)
  v:each(function(x, y) local l = lit(x, y, 248, 160, 16); P(x, y, (l > .2) and BLUEW[5] or BLUEW[4]); if ((x - y) % 5 == 0) then P(x, y, BLUEW[3]) end end)
  c:fillMask(c:line({ { 226, 196 }, { 252, 146 } }, 1), "#f8ecd0"); P(226, 197, INK); P(225, 198, "#2b1c26"); P(260, 144, BLUEW[6]); P(259, 146, BLUEW[6])
  for k = 0, 8 do P(228 + k * 2, 190 - floor(k * 3.6) , "#fff8e8") end
  P(230, 202, INK); P(231, 202, INK); P(232, 203, INK)
end
OV.petals = function(p, dm)
  S.glow(240, 168, 18, "#ffd070", .2)
  for i = 0, 7 do local a = i * .7854; local x, y = floor(240 + cos(a) * 10), floor(168 + sin(a) * 10)
    local m = c:ellipse(x, y, 5, 5); c:rim(m, INK); m:each(function(xx, yy) local l = lit(xx, yy, x, y, 5); P(xx, yy, ((i % 2 == 0) and ROSE or PINK)[l > .2 and 6 or 5]) end) end
  c:fillMask(c:ellipse(240, 168, 5, 5), INK); c:fillMask(c:ellipse(240, 168, 4, 4), "#ffd24a"); P(238, 166, "#fff0b0"); P(242, 170, "#e8a030")
  for y = 182, 198 do P(240 + floor(sin((y - 182) / 4) * 2), y, GREEN[(y % 4 < 2) and 4 or 3]) end
end
OV.fern = function(p, dm)
  for y = 198, 142, -1 do P(240, y, FERN[3]) end
  for y = 198, 146, -3 do
    local t = (198 - y) / 52; local len = 11 * sin(t * 3.1) + 1.5
    for k = 1, floor(len) do P(240 - k, y - k // 2, FERN[(k > len - 3) and 5 or 4]); P(240 + k, y - k // 2, FERN[(k > len - 3) and 6 or 4]); P(240 - k, y - k // 2 + 1, FERN[2]); P(240 + k, y - k // 2 + 1, FERN[3]) end
  end
  P(240, 141, FERN[6]); P(240, 142, FERN[5])
end
OV.kente = function(p, dm)
  local cols = { "#d4503f", "#f4c84a", "#3a8a50", "#f0a048" }
  for _, by in ipairs{ 148, 172 } do
    for y = by, by + 12 do for x = 218, 261 do if dm:has(x, y) then
      local k = floor((x - 218) / 6); local ph = (x - 218) % 6; local hh = (k % 2 == 0) and ph or (5 - ph)
      local inside = (y - by) >= (hh * 2) and (y - by) <= 12 - hh * 2 + 0
      local col = inside and cols[(k % 4) + 1] or "#2b1c26"
      if y == by or y == by + 12 then col = "#2b1c26" end
      P(x, y, col)
    end end end
  end
end
OV.sun = function(p, dm)
  S.glow(240, 166, 24, "#ffd070", .4)
  for i = 0, 11 do local a = i * .5236; local x0, x1 = 240 + cos(a) * 11, 240 + cos(a) * 19; local y0, y1 = 166 + sin(a) * 11, 166 + sin(a) * 19
    local m = polym{ { x0 - sin(a) * 3, y0 + cos(a) * 3 }, { x0 + sin(a) * 3, y0 - cos(a) * 3 }, { x1, y1 } }; c:rim(m, INK); c:fillMask(m, (i % 2 == 0) and GOLD[6] or GOLD[5]) end
  local d = c:ellipse(240, 166, 10, 10); c:rim(d, INK); d:each(function(x, y) local l = lit(x, y, 240, 166, 10); P(x, y, (l > .3) and "#fff0b0" or (l > -.3 and GOLD[6] or GOLD[5])) end)
  P(236, 163, INK); P(244, 163, INK); for k = -3, 3 do P(240 + k, 170 + (abs(k) > 2 and -1 or 0), INK) end
end
OV.blossom = function(p, dm)
  local function arc(sd)
    for t = 0, 1, .02 do
      local x = floor(240 + sd * (23 - t * 4 + 3 * sin(t * 14))); local y = floor(204 - t * 74 + 0)
      if t > .75 then x = floor(240 + sd * (20 - (t - .75) * 80)); y = floor(204 - .75 * 74 - (t - .75) * 30) end
      P(x - 1, y, INK); P(x + 1, y, INK); P(x, y, GREEN[(floor(t * 50) % 2 == 0) and 5 or 4])
      if floor(t * 50) % 8 == 3 then local lm = c:ellipse(x + sd * 4, y, 3, 2); c:rim(lm, INK); c:fillMask(lm, LEAF[4]); P(x + sd * 3, y - 1, LEAF[6]) end
    end
  end
  arc(-1); arc(1)
  for _, q in ipairs{ { 214, 190 }, { 266, 186 }, { 212, 166 }, { 268, 160 }, { 216, 146 }, { 262, 140 }, { 226, 130 }, { 252, 128 }, { 240, 126 } } do
    local x, y = q[1], q[2]; local cc = ((x + y) % 3 == 0) and "#fac4d4" or (((x + y) % 3 == 1) and "#f0809c" or "#fff0d8")
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do local m = c:ellipse(x + d[1] * 2, y + d[2] * 2, 2, 2); c:rim(m, INK) end
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do c:fillMask(c:ellipse(x + d[1] * 2, y + d[2] * 2, 2, 2), cc) end
    P(x, y, "#ffd24a"); P(x - 1, y - 1, "#fff0b0")
  end
end
OV.monocle = function(p, dm)
  S.glow(240, 160, 20, "#fff0b0", .25)
  local r = c:ellipse(240, 160, 13, 13); c:rim(r, INK); paintR(r, GOLD, 240, 160, 13)
  local g = c:ellipse(240, 160, 9, 9); c:rim(g, GOLD[1]); g:each(function(x, y) local l = lit(x, y, 240, 160, 9); P(x, y, (l > .3) and "#e8f8ff" or (l > -.3 and "#a8dcf0" or "#6aaad0")) end)
  for k = 0, 5 do P(234 + k, 155 - k // 3, "#fffbe8") end; P(236, 160, "#fffbe8"); P(246, 166, "#4a8ab8")
  local ch = c:line({ { 250, 170 }, { 256, 180 }, { 252, 192 }, { 258, 200 } }, 1); ch:each(function(x, y) if (x + y) % 2 == 0 then P(x, y, GOLD[5]) else P(x, y, INK) end end)
  for k = 0, 5 do P(238 + k * 2, 146 - (k % 2), GOLD[2]) end
end
OV.wheel = function(p, dm)
  S.glow(240, 164, 22, "#ffd070", .25)
  for i = 0, 7 do local a = i * .7854; local l = c:line({ { 240, 164 }, { floor(240 + cos(a) * 17), floor(164 + sin(a) * 17) } }, 2); c:rim(l, INK); c:fillMask(l, TIMB[5]); local kn = c:ellipse(floor(240 + cos(a) * 20), floor(164 + sin(a) * 20), 2, 2); c:rim(kn, INK); c:fillMask(kn, GOLD[4]) end
  local rg = c:ellipse(240, 164, 14, 14); rg:cut(c:ellipse(240, 164, 10, 10)); c:rim(rg, INK); paintR(rg, TIMB, 240, 164, 14)
  c:fillMask(c:ellipse(240, 164, 4, 4), INK); c:fillMask(c:ellipse(240, 164, 3, 3), GOLD[4]); P(239, 163, GOLD[6])
end
OV.spots = function(p, dm)
  for _, s in ipairs{ { 228, 152, 5 }, { 250, 148, 4 }, { 242, 168, 6 }, { 226, 182, 4 }, { 254, 186, 5 }, { 236, 198, 3 }, { 252, 166, 2 } } do
    local m = c:ellipse(s[1], s[2], s[3], s[3]); m:each(function(x, y) if dm:has(x, y) then local l = lit(x, y, s[1], s[2], s[3]); P(x, y, (l > .2) and "#fff8e8" or "#e8d4b8") end end)
  end
end

---------------------------------------------------------------- shared kind pieces
local function copyt(t) local r = {}; for k, v in pairs(t) do r[k] = v end; return r end
local function theDoor(p, dflt)
  local o = copyt(p.d); o.noknob = true
  for k, v in pairs(dflt) do if o[k] == nil then o[k] = v end end
  local dm = door(o)
  p._dm = dm; p._o = o
  return dm
end
local function groundFin(p, tv, fcols, fav, y0, y1)
  for i = 1, tv do tuft(floor(hash(i, 1, 6) * 470) + 6, 212 + floor(hash(i, 2, 6) * 54), p.tuft or GREEN) end
  if fcols then flowers(10, p.seed or 3, y0 or 212, y1 or 266, fcols, fav or function(x) return x > 190 and x < 290 end) end
end
local DD = { x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1 }

---------------------------------------------------------------- KIND: cottage
K.cottage = function(p)
  local W = p.wall or CREAM
  for y = 60, 205 do for x = 0, 479 do
    local n = vn(x, y, 6, 3) * .5 + vn(x, y, 2.3, 9) * .5
    local v = .64 + (n - .5) * .4 - (y - 70) / 136 * .1 + (hash(x, y, 2) > .96 and .1 or 0)
    P(x, y, W[GX.idx(v, { .2, .35, .5, .6, .8 })])
  end end
  local BM = p.beam or TIMB
  local function beam(m) c:rim(m, INK); S.obj(m, BM, { base = 4, lit = 1, shade = 1 }); S.planks(m, BM, { w = 99, vert = false, base = 4, seed = 2 }) end
  for _, x in ipairs{ 0, 100, 392, 470 } do beam(rect(x, 66, x + 8, 196)) end
  beam(rect(0, 66, 479, 76)); beam(rect(0, 186, 479, 193))
  for _, b in ipairs{ { 108, 80, 130, 106 }, { 392, 80, 372, 106 }, { 8, 180, 34, 150 }, { 470, 180, 444, 150 } } do
    local bm = c:line({ { b[1], b[2] }, { b[3], b[4] } }, 4); c:rim(bm, INK); S.obj(bm, BM, { base = 4, lit = 1, shade = 1 })
  end
  stones(function(x, y) return y >= 194 and y <= 205 end, 0, 194, 479, 205, STONE, { rh = 6, seed = 4, wmin = 9 })
  local rm = HP.mask()
  for x = 0, 479 do local yb = 63 + floor(3 * sin(x / 7) + 2 * sin(x / 3.3 + 1)); for y = 0, yb do rm:set(x, y) end end
  local RR = p.roof
  rm:each(function(x, y)
    if p.tiles then
      local row = floor(y / 9); local xo = (x + (row % 2) * 7) % 14; local d = (xo - 7) / 7
      local t = y % 9; local v = .6 + (hash(floor((x + (row % 2) * 7) / 14), row, 6) - .5) * .3 - x / 480 * .08
      if t >= 6 + floor(2 * (1 - d * d)) then v = v - .35 elseif t < 2 then v = v + .15 end
      P(x, y, RR[GX.idx(v)])
    else
      local row0 = floor((y + 1.8 * sin(x / 6 + floor(y / 11) * 1.7)) / 11)
      local t = (y + floor(2 * sin(x / 6 + row0 * 1.7))) % 11
      local v = .55 + (hash(x // 1, row0, 6) - .5) * .35 + (vn(x, y, 4, 7) - .5) * .25 - x / 480 * .1
      if t < 2 then v = v - .32 elseif t >= 8 then v = v + .18 end
      if hash(x, y // 3, 8) > .9 then v = v - .15 end
      P(x, y, RR[GX.idx(v)])
    end
  end)
  c:rim(rm, INK)
  for y = 64, 67 do for x = 0, 479 do local cur = c:get(x, y); if cur and not rm:has(x, y) and cur ~= INK then P(x, y, mixc(cur, "#3a2030", .4 - (y - 64) * .08)) end end end
  grass(function(x) return 206 + floor(sin(x / 30) * 1.2) end, GREEN, 5)
  local pm = HP.mask()
  for y = 206, 269 do local hw = 30 + (y - 206) * .5; for x = floor(240 - hw), floor(240 + hw) do pm:set(x, y) end end
  stones(function(x, y) return pm:has(x, y) end, 190, 206, 290, 269, p.path or STONE, { rh = 8, seed = 11, wmin = 9, wvar = 10, shade = function() return -1 end })
  if p.windows then
    window(130, 116, 166, 152, p.windows[1], true, p.windows[2]); window(372, 116, 408, 152, p.windows[1], true, p.windows[3] or p.windows[2])
  end
  step(204, 276, 205, STONE)
  local dm = theDoor(p, DD)
  plate(240, 84, p.plate)
  groundFin(p, 26, p.fcols, p.fav, 210, 266); for x = 20, 96, 11 do tuft(x, 204, GREEN) end
  return dm
end

---------------------------------------------------------------- KIND: burrow
K.burrow = function(p)
  sky(p.sky or { "#7fb8e4", "#98c8ec", "#b0d8f2", "#c8e6f6", "#e0f0f2" }, p.seed or 2, 200)
  if p.night then
    for i = 1, 70 do local x, y = floor(hash(i, 1, 4) * 478), floor(hash(i, 2, 4) * 120); P(x, y, "#fff0b0"); if i % 5 == 0 then P(x + 1, y, "#f8d070"); P(x - 1, y, "#f8d070"); P(x, y + 1, "#f8d070"); P(x, y - 1, "#f8d070") end end
    S.glow(66, 50, 26, "#fff0b0", .25)
    local mm = c:ellipse(66, 50, 12, 12); mm:cut(c:ellipse(72, 46, 10, 10)); c:rim(mm, INK); mm:each(function(x, y) P(x, y, (x + y < 112) and "#fff6cc" or "#ffe08a") end)
  else
    c:cloud(40, 66, 54, "#f8f0e0", "#d6e6f0"); c:cloud(380, 44, 44, "#f8f0e0", "#d6e6f0")
  end
  hills(function(x) return 150 + 10 * sin(x / 40) + 5 * sin(x / 15) end, p.far or { "#3c6e5a", "#4c8068", "#6a9c7c", "#86b494", "#a4cca8", "#bcdcb4" }, 215, 3)
  grass(function(x) return 207 + floor(sin(x / 25) * 1.2) end, p.grass or GREEN, 4)
  local HR = p.hill or GREEN
  local hm = HP.mask()
  for y = 40, 214 do for x = 20, 460 do if ((x - 240) / 222) ^ 2 + ((y - 215) / 172) ^ 2 <= 1 then hm:set(x, y) end end end
  hm = GX.rough(hm, 5, 1); c:rim(hm, INK)
  hm:each(function(x, y)
    local nx, ny = (x - 240) / 222, (y - 215) / 172; local nz = sqrt(max(0, 1 - nx * nx - ny * ny))
    local v = .5 + (-nx * .35 - ny * .3 + nz * .25) + (vn(x, y, 7, 4) - .5) * .3
    if hash(x, y // 4, 3) > .93 then v = v - .12 end
    P(x, y, HR[GX.idx(v)])
  end)
  for i = 1, 240 do local x, y = 30 + floor(hash(i, 1, 9) * 420), 56 + floor(hash(i, 2, 9) * 146); if hm:has(x, y) and hm:has(x, y - 2) and free(x, y) then P(x, y, HR[6]); P(x, y + 1, HR[3]) end end
  for _, x in ipairs{ 210, 268 } do local pm = rect(x, 64, x + 2, 100); c:rim(pm, INK); S.obj(pm, TIMB, { base = 4, lit = 0, shade = 1 }) end
  local bar = rect(208, 70, 272, 73); c:rim(bar, INK); S.obj(bar, TIMB, { base = 4, lit = 1, shade = 1 })
  plate(240, 84, p.plate, { w = 40 })
  local dm
  if p.d.shape == "round" then
    dm = theDoor(p, { x0 = 207, y0 = 135, x1 = 272, y1 = 203, f = 5, blocks = true, pw = 8 })
    for x = 206, 274 do if hash(x, 1, 8) > .5 then GX.tuft(c, x, 130 - floor(abs(x - 240) ^ 2 / 60) + 6, R4(HR)) end end
    step(210, 270, 205, STONE, { h = 4 })
  else
    step(206, 274, 205, STONE, { h = 4 })
    dm = theDoor(p, { x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, f = 5, pw = 7 })
    for x = 208, 272 do if hash(x, 1, 8) > .5 then GX.tuft(c, x, 134 - floor(abs(x - 240) ^ 2 / 60) + 4, R4(HR)) end end
  end
  for i = 1, 14 do tuft(floor(hash(i, 1, 6) * 470) + 6, 210 + floor(hash(i, 2, 6) * 56), p.tuft or GREEN) end
  if p.fcols then flowers(14, 21, 70, 190, p.fcols, function(x, y) return (x > 195 and x < 285 and y > 60) or (x > 285 and x < 330 and y < 150) end) end
  return dm
end

---------------------------------------------------------------- KIND: treehouse
K.treehouse = function(p)
  sky(p.sky or { "#7fb8e4", "#98c8ec", "#b0d8f2", "#c8e6f6", "#dcf0f8" }, p.seed or 7, 215)
  c:cloud(24, 110, 46, "#f8f0e0", "#d6e6f0"); c:cloud(410, 130, 40, "#f8f0e0", "#d6e6f0")
  hills(function(x) return 172 + 8 * sin(x / 44) + 4 * sin(x / 13) end, { "#4a6a8a", "#5f80a0", "#7a9cba", "#93b4cc", "#aac8dc", "#c0d8e8" }, 215, 5)
  hills(function(x) return 190 + 6 * sin(x / 31 + 2) end, p.far or { "#2c5a48", "#3a6e56", "#4c8466", "#62a078", "#7ab88a", "#98cc9c" }, 215, 6)
  grass(function(x) return 207 + floor(sin(x / 28) * 1.3) end, GREEN, 8)
  local TR = p.trunk or OAK
  local tx0, tx1 = p.tx0 or 150, p.tx1 or 326
  GX.trunk(c, tx0, tx1, 30, 208, R4(TR), p.tseed or 4, { moss = { hi = GREEN[5], base = GREEN[4], shade = GREEN[3], deep = GREEN[2] } })
  local FA, FB = p.fol or GREEN, p.fol2 or LEAF
  for _, b in ipairs{ { 30, 34, 72, 40 }, { 130, 24, 84, 34 }, { 250, 20, 90, 34 }, { 370, 30, 84, 38 }, { 450, 40, 56, 34 }, { 70, 52, 56, 22 }, { 230, 44, 70, 24 }, { 400, 54, 56, 20 } } do
    GX.foliage(c, b[1], b[2], b[3], b[4], R4(b[1] % 2 == 0 and FA or FB), b[1] + 3)
  end
  for _, k in ipairs{ { tx0 + 18, 120 }, { tx1 - 16, 190 } } do local km = c:ellipse(k[1], k[2], 3, 4); c:rim(km, INK); c:fillMask(km, TR[2]); P(k[1] - 1, k[2] - 2, TR[3]) end
  local dm
  if p.d.shape == "round" then dm = theDoor(p, { x0 = 211, y0 = 145, x1 = 270, y1 = 204, f = 5, pw = 7 }); step(208, 272, 205, TIMB)
  else dm = theDoor(p, { x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, f = 5, pw = 7 }); for i = 0, 14 do local lx = 213 + floor(i * 3.4); P(lx, 133 + floor(abs(i - 7) / 3), GREEN[4 + i % 2]); P(lx, 132 + floor(abs(i - 7) / 3), GREEN[5]) end; step(208, 272, 205, TIMB) end
  plate(240, 84, p.plate)
  for i = 0, 5 do P(205 + i * 8, 77 + i % 2 * 2, FA[4]); P(206 + i * 8, 78 + i % 2 * 2, FA[5]) end
  if p.ladder then
    local lx = p.ladder
    local peg = rect(lx - 10, 92, lx + 10, 95); c:rim(peg, INK); S.obj(peg, TIMB, { base = 4, lit = 1, shade = 1 })
    for y = 96, 202 do local xo = floor(sin(y / 26) * 1.4 + .5)
      for _, rx in ipairs{ lx - 7 + xo, lx + 7 + xo } do P(rx - 1, y, INK); P(rx, y, DIRT[5]); P(rx + 1, y, DIRT[2]) end
      if (y - 96) % 10 == 5 then for x = lx - 8 + xo, lx + 8 + xo do P(x, y, INK); P(x, y + 1, (x < lx + xo) and TIMB[5] or TIMB[3]); P(x, y + 2, INK) end end
    end
  end
  if p.fungus then
    for _, f in ipairs{ { 288, 156, 8 }, { 292, 168, 6 }, { 284, 178, 5 } } do
      local fm = c:ellipse(f[1], f[2], f[3], 3):clip(rect(f[1] - f[3] - 1, f[2] - 1, f[1] + f[3] + 1, f[2] + 3))
      c:rim(fm, INK); fm:each(function(x, y) P(x, y, (y == f[2] - 1 or y == f[2]) and p.fungus[1] or ((y >= f[2] + 2) and p.fungus[3] or p.fungus[2])) end)
      P(f[1] - 2, f[2] - 1, "#fff0d8"); P(f[1] + 2, f[2] + 1, "#fff0d8")
    end
  end
  groundFin(p, 20, p.fcols, function(x) return x > 160 and x < 330 end)
  return dm
end

---------------------------------------------------------------- KIND: hut
K.hut = function(p)
  sky(p.sky or { "#8ec8e8", "#a8d8ec", "#c4e4ee", "#f0e8cc", "#f8dcb0" }, p.seed or 3, 215)
  c:cloud(30, 70, 46, "#fff4e0", "#f0d0b0"); c:cloud(400, 52, 40, "#fff4e0", "#f0d0b0")
  hills(function(x) return 176 + 8 * sin(x / 60 + 1) end, p.hillr, 215, 4)
  grass(function(x) return 207 + floor(sin(x / 22) * 1.2) end, p.ground, 9, { tex = .3 })
  local function banana(bx, by, sc, GR)
    for k = 1, 7 do
      local a = -2.7 + k * .32; local lm = HP.mask()
      for t = 0, 1, .04 do local px, py = bx + cos(a) * 46 * sc * t, by - 50 * sc + sin(a) * 40 * sc * t + 24 * sc * t * t; GX.disc(lm, floor(px), floor(py), max(1, floor(5 * sc * (1 - t) + 1))) end
      c:rim(lm, INK); S.obj(lm, GR, { base = (k % 2 == 0) and 4 or 3, lit = 2, shade = 2 })
      for t = 0, 1, .05 do P(floor(bx + cos(a) * 46 * sc * t), floor(by - 50 * sc + sin(a) * 40 * sc * t + 24 * sc * t * t), GR[6]) end
    end
    local tm = rect(bx - 3, by - 50 * sc, bx + 3, by); c:rim(tm, INK); S.obj(tm, p.trunkr or LEAF, { base = 3 })
  end
  if p.bg == "bush" then
    for _, b in ipairs{ { 40, 188, 46, 30 }, { 84, 194, 40, 22 }, { 440, 186, 48, 32 }, { 396, 196, 36, 20 } } do GX.foliage(c, b[1], b[2], b[3], b[4], R4(p.bushr or GREEN), b[1]) end
  else banana(44, 206, 1, p.bgr or GREEN); banana(436, 206, 1.1, p.bgr or GREEN) end
  local WR = p.wall or DIRT
  local wm = rect(142, 70, 338, 206)
  wm:each(function(x, y)
    local k = floor((x - 142) / 4); local t = 4 + ((hash(k, 1, 3) > .5) and 0 or -1)
    if (x - 142) % 4 == 0 then t = 2 elseif (x - 142) % 4 == 1 then t = t + 1 end
    if (y - 70) % 24 < 3 then t = (y - 70) % 24 == 0 and 6 or 3; if (y - 70) % 24 == 2 then t = 2 end end
    if hash(x, y // 6, 3) > .94 then t = t - 1 end
    local s = (x - 240) / 98; if s > .6 then t = t - 1 end
    P(x, y, WR[max(1, min(6, t + 1))])
  end)
  c:rim(wm, INK)
  for _, x in ipairs{ 142, 332 } do local pm = rect(x, 70, x + 6, 206); c:rim(pm, INK); S.obj(pm, TIMB, { base = 4, lit = 1, shade = 2 }); for y = 82, 200, 24 do for xx = x, x + 6 do P(xx, y, TIMB[2]) end end end
  local RR = p.roof
  local rm = HP.mask()
  for y = 6, 72 do local t = (y - 6) / 66; local hw = 6 + (t ^ .8) * 132 + floor(2 * sin(y / 5)); for x = floor(240 - hw), floor(240 + hw) do rm:set(x, y) end end
  for x = 100, 380 do local hw = abs(x - 240); if hw > 100 then for y = 62, 74 do if hash(x, 5, 4) > .2 then rm:set(x, y) end end end end
  rm:each(function(x, y)
    local row = floor((y + 1.6 * sin(x / 5)) / 9); local t = (y + floor(1.6 * sin(x / 5))) % 9; local s = (x - 240) / 138
    local v = .62 - s * .22 + (hash(x, row, 5) - .5) * .3 + (vn(x, y, 4, 7) - .5) * .2
    if t < 2 then v = v - .3 elseif t >= 6 then v = v + .15 end
    if hash(x, y // 4, 5) > .88 then v = v - .14 end
    P(x, y, RR[GX.idx(v)])
  end)
  c:rim(rm, INK)
  for y = 73, 76 do for x = 100, 380 do local cur = c:get(x, y); if cur and not rm:has(x, y) and wm:has(x, y) and cur ~= INK then P(x, y, mixc(cur, "#3a2030", .45 - (y - 73) * .1)) end end end
  local fin = c:ellipse(240, 6, 3, 4); c:rim(fin, INK); c:fillMask(fin, RR[3])
  step(204, 276, 205, TIMB, { h = 4 })
  local dm = theDoor(p, DD)
  for y = 138, 202, 16 do for x = DX0 - 4, DX1 + 4, 1 do if x < DX0 or x > DX1 then P(x, y, WR[6]); P(x, y + 1, TIMB[2]) end end end
  plate(240, 84, p.plate)
  for i = 1, 16 do tuft(floor(hash(i, 1, 6) * 470) + 6, 214 + floor(hash(i, 2, 6) * 52), p.tuft) end
  if p.fcols then flowers(8, 5, 214, 266, p.fcols, function(x) return x > 190 and x < 290 end) end
  return dm
end

---------------------------------------------------------------- KIND: stone
K.stone = function(p)
  sky(p.sky or { "#a4c8e8", "#b8d4ec", "#cce0f0", "#e0ecf4", "#f0f0ec" }, p.seed or 6, 215)
  c:cloud(30, 84, 50, "#f8f0e0", "#d6e6f0"); c:cloud(410, 60, 44, "#f8f0e0", "#d6e6f0")
  hills(function(x) return 168 + 10 * sin(x / 50) end, { "#58708a", "#6c88a0", "#84a0b4", "#9cb6c6", "#b4cad4", "#cadce0" }, 215, 3)
  hills(function(x) return 190 + 7 * sin(x / 33 + 1) end, p.far or { "#2c5a48", "#3a6e56", "#4c8466", "#62a078", "#7ab88a", "#98cc9c" }, 215, 7)
  grass(function(x) return 207 + floor(sin(x / 26) * 1.2) end, GREEN, 10)
  local wx0, wx1 = p.wx0 or 140, p.wx1 or 340
  local WR = p.wall or STONE
  local top = (p.roof == nil) and 52 or 66
  local function cyl(x, y) local s = (x - 240) / ((wx1 - wx0) / 2); return (s > .82) and -2 or ((s > .55) and -1 or ((s < -.85) and -1 or 0)) end
  local wm = rect(wx0, top, wx1, 206)
  if p.crenel then for x = wx0, wx1, 24 do wm:add(rect(x, 40, x + 13, top)) end end
  c:rim(wm, INK)
  stones(function(x, y) return wm:has(x, y) end, wx0, 38, wx1, 206, WR, { rh = p.rh or 9, seed = p.sseed or 5, shade = cyl, wmin = p.wmin })
  moss(function(x, y) return wm:has(x, y) end, wx0, top, wx1, 206, 13, function(x, y) return (p.mossk or .56) + (206 - y) / 150 * .22 + ((x < wx0 + 10 or x > wx1 - 10) and -.1 or 0) end, 5)
  if p.crenel then
    for x = wx0, wx1 do P(x, top, INK) end
    for x = wx0, wx1, 24 do for xx = x + 1, x + 12 do P(xx, 40, WR[6]); P(xx, 41, WR[5]) end end
  end
  if p.slits then for _, sx in ipairs(p.slits) do c:fillMask(rect(sx, 96, sx + 3, 118), INK); c:fillMask(rect(sx + 1, 98, sx + 2, 116), p.slitc or "#3a2c4a"); P(sx + 1, 98, "#ffe08a"); P(sx + 1, 99, "#ffe08a") end end
  local rm
  if p.roof then
    rm = HP.mask()
    if p.rk == "dome" then
      for y = 14, 72 do local hw = floor(138 * sqrt(max(0, 1 - ((72 - y) / 58) ^ 2)) + .5); for x = 240 - hw, 240 + hw do rm:set(x, y) end end
    else
      for y = 12, 72 do local t = (y - 12) / 60; local hw = 5 + (t ^ .9) * 132; for x = floor(240 - hw), floor(240 + hw) do rm:set(x, y) end end
    end
    c:rim(rm, INK)
    if p.thatch then
      rm:each(function(x, y) local row = floor((y + 1.6 * sin(x / 5)) / 8); local t = (y + floor(1.6 * sin(x / 5))) % 8; local v = .6 - (x - 240) / 300 + (hash(x, row, 5) - .5) * .3
        if t < 2 then v = v - .3 elseif t >= 6 then v = v + .15 end; P(x, y, p.roof[GX.idx(v)]) end)
    else
      stones(function(x, y) return rm:has(x, y) end, 90, 12, 390, 72, p.roof, { rh = 6, seed = 8, wmin = 8, wvar = 6, shade = function(x, y) local s = (x - 240) / 130; return (s > .5) and -1 or ((s < -.2) and 1 or 0) end })
    end
    if p.roofmoss then moss(function(x, y) return rm:has(x, y) end, 90, 12, 390, 72, 17, function(x, y) return .66 - (72 - y) / 200 end, 4) end
    if p.roofdots then for _, d in ipairs(p.roofdots) do local dm2 = c:ellipse(d[1], d[2], d[3], d[3]); dm2:each(function(x, y) if rm:has(x, y) then P(x, y, INK) end end); if rm:has(d[1] - 1, d[2] - 1) then P(d[1] - 1, d[2] - 1, "#5a2a44") end end end
    if p.roofstars then for _, d in ipairs(p.roofstars) do P(d[1], d[2], "#fff0b0"); P(d[1] + 1, d[2], "#f8d070"); P(d[1] - 1, d[2], "#f8d070"); P(d[1], d[2] + 1, "#f8d070"); P(d[1], d[2] - 1, "#f8d070") end end
    local fin = c:ellipse(240, 10, 3, 4); c:rim(fin, INK); c:fillMask(fin, (p.finc or STONE)[4]); P(239, 8, (p.finc or STONE)[6])
    for y = 73, 76 do for x = 100, 380 do local cur = c:get(x, y); if cur and not rm:has(x, y) and wm:has(x, y) and cur ~= INK then P(x, y, mixc(cur, "#2a1830", .5 - (y - 73) * .12)) end end end
  else
    local pole = rect(239, 10, 241, 40); c:rim(pole, INK); c:fillMask(pole, TIMB[4])
    local fl = polym{ { 242, 12 }, { 262, 16 }, { 254, 20 }, { 262, 24 }, { 242, 26 } }; c:rim(fl, INK); fl:each(function(x, y) P(x, y, (y < 19) and p.flag[2] or p.flag[1]) end)
  end
  stones(function(x, y) return y >= 196 and y <= 206 and abs(x - 240) < (wx1 - wx0) / 2 + 14 end, wx0 - 14, 196, wx1 + 14, 206, WR, { rh = 6, seed = 20, wmin = 12, shade = function() return -1 end })
  for x = wx0 - 14, wx1 + 14 do if abs(x - 240) < (wx1 - wx0) / 2 + 14 then P(x, 195, INK) end end
  step(204, 276, 205, STONE)
  local dm = theDoor(p, { x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, f = 6, pw = 6, blocks = true })
  if not p.nomossdoor then
    local fmask = dmask(p.d.shape or "arch", DX0 - 6, DY0 - 6, DX1 + 6, DY1)
    moss(function(x, y) return fmask:has(x, y) and not dm:has(x, y) end, 210, 128, 270, 204, 31, function(x, y) return .6 + (y - 128) / 400 end, 4)
  end
  plate(240, 84, p.plate)
  groundFin(p, 18, p.fcols, nil, 212, 266)
  return dm
end

---------------------------------------------------------------- KIND: boat
K.boat = function(p)
  sky(p.sky or { "#8ec4ea", "#a4d4ee", "#bce2f2", "#d4eef6", "#eaf4ee" }, p.seed or 4, 150)
  c:cloud(44, 80, 52, "#f8f0e0", "#d6e6f0"); c:cloud(396, 56, 46, "#f8f0e0", "#d6e6f0")
  hills(function(x) return 128 + 8 * sin(x / 45) + 3 * sin(x / 12) end, { "#4a6a8a", "#5f80a0", "#7a9cba", "#93b4cc", "#aac8dc", "#c0d8e8" }, 152, 3)
  local WT = p.water or { "#1e4a6a", "#2a6a8a", "#3a86a4", "#52a0b8", "#78bccc", "#a8dce0" }
  for y = 146, 269 do for x = 0, 479 do
    local v = .72 - (y - 146) / 124 * .45 + (vn(x, y * 2.2, 10, 3) - .5) * .25
    P(x, y, WT[GX.idx(v, { .2, .36, .5, .62, .8 })])
  end end
  for i = 1, 70 do local x, y = floor(hash(i, 1, 5) * 480), 152 + floor(hash(i, 2, 5) * 116)
    if not (x > 130 and x < 350 and y < 242) then for k = 0, 3 + floor(hash(i, 3, 5) * 5) do P(x + k, y, WT[6]) end; for k = 1, 3 do P(x + k + 1, y + 1, WT[2]) end end end
  for _, px in ipairs{ 356, 408, 462 } do
    local pm = rect(px, 214, px + 6, 258); c:rim(pm, INK); S.obj(pm, TIMB, { base = 3, lit = 0, shade = 2 })
    for y = 232, 260 do if (y % 4) == 0 then for x = px, px + 6 do P(x, y, TIMB[1]) end end end
    for x = px - 2, px + 8 do P(x, 258, WT[6]); P(x, 259, WT[5]) end
  end
  local dkm = rect(344, 200, 479, 214); c:rim(dkm, INK)
  dkm:each(function(x, y)
    local t
    if y <= 205 then t = ((x // 17 + y) % 2 == 0) and 5 or 4; if (x % 17) == 0 then t = 2 end; if y == 200 then t = 6 end
    elseif y <= 208 then t = 5 else t = (y == 214) and 2 or ((y % 2 == 0) and 3 or 4) end
    if y > 205 and y <= 208 then t = (y == 206) and 6 or 5 end
    if hash(x, y, 3) > .94 then t = max(2, t - 1) end
    P(x, y, TIMB[t])
  end)
  for x = 344, 479 do P(x, 206, TIMB[2]) end
  for _, nx in ipairs{ 360, 394, 430, 466 } do P(nx, 203, TIMB[1]); P(nx + 1, 203, TIMB[2]) end
  local HU = p.hull or SBLUE
  local hm = HP.mask()
  for y = 208, 240 do local inset = floor((y - 208) * .42); for x = 138 + inset, 342 - inset do hm:set(x, y) end end
  c:rim(hm, INK)
  hm:each(function(x, y)
    local t = (y < 214) and 5 or 4
    if y >= 214 and y <= 217 then t = 6 end; if y > 217 and y < 232 then t = 3 end; if y >= 232 then t = 2 end
    local s = (x - 240) / 100; if s > .7 then t = t - 1 end; if y > 217 and (x % 14) == 0 then t = t - 1 end
    P(x, y, (y >= 214 and y <= 217) and (p.stripe or CREAM)[(s > .7) and 4 or 5] or HU[max(1, min(6, t))])
  end)
  for _, px in ipairs{ 170, 210, 270, 310 } do
    local pm = c:ellipse(px, 226, 4, 4); c:rim(pm, INK); c:fillMask(pm, HU[2]); c:fillMask(c:ellipse(px, 226, 3, 3), "#a8d4ec"); P(px - 2, 224, "#e8f4f8"); P(px + 2, 228, "#6aa0c0")
  end
  for x = 130, 350 do if abs(x - 240) < 108 then local cur = c:get(x, 241); if cur then P(x, 241, WT[2]); P(x, 242, WT[3]) end end end
  for x = 150, 330, 4 do P(x, 243, WT[5]); P(x + 1, 243, WT[5]) end
  local tire = HP.mask(); for y = 222, 235 do for x = 338, 345 do tire:set(x, y) end end
  c:rim(tire, INK); tire:each(function(x, y) P(x, y, (x < 341) and "#5a5a6e" or "#34344a") end)
  local CB = p.wall or TEAL
  local cm = rect(152, 66, 328, 205); c:rim(cm, INK)
  cm:each(function(x, y)
    local t = 4; if (y - 66) % 7 == 0 then t = 2 elseif (y - 66) % 7 == 1 then t = 5 end
    if (x - 152) > 160 then t = t - 1 end; if hash(x, y // 7, 3) > .96 then t = t - 1 end
    P(x, y, CB[max(1, min(6, t))])
  end)
  if p.chimney then
    local ch = rect(274, 28, 288, 60); c:rim(ch, INK); stones(function(x, y) return ch:has(x, y) end, 274, 28, 288, 60, BARN, { rh = 5, seed = 4, wmin = 7, wvar = 4 })
    for k, q in ipairs{ { 280, 20, 4 }, { 286, 10, 5 }, { 294, 0, 6 } } do local sm = c:ellipse(q[1], q[2], q[3], q[3] - 1); c:rim(sm, INK); c:fillMask(sm, CREAM[5]); P(q[1] - 1, q[2] - 1, CREAM[6]) end
  end
  local rm = HP.mask()
  local RR = p.roof
  if p.rk == "lily" then
    for y = 36, 69 do local hw = floor(100 * sqrt(max(0, 1 - ((69 - y) / 33) ^ 2)) + .5); for x = 240 - hw, 240 + hw do rm:set(x, y) end end
    for y = 36, 52 do for x = 240, 246 do if x - 240 < (52 - y) * .5 + 1 and y < 52 - (x - 240) * 2 then rm:cut(rect(x, y, x, y)) end end end
    c:rim(rm, INK)
    rm:each(function(x, y) local a = math.atan(y - 76, x - 240); local ray = (floor((a + 3.14) / .2) % 2 == 0); local l = lit(x, y, 220, 50, 80); P(x, y, RR[(l > .3) and (ray and 5 or 6) or (ray and 4 or 5)]); if y >= 66 then P(x, y, RR[3]) end end)
    for _, q in ipairs{ { 190, 56 }, { 276, 52 }, { 232, 46 } } do P(q[1], q[2], RR[6]); P(q[1] + 1, q[2], RR[6]) end
  else
    for y = 46, 69 do local ins = floor((70 - y) * .3); for x = 142 + ins, 338 - ins do rm:set(x, y) end end
    c:rim(rm, INK)
    rm:each(function(x, y)
      if p.straw then
        local row = floor((y + 1.2 * sin(x / 5)) / 6); local t = (y + floor(1.2 * sin(x / 5))) % 6; local v = .62 - (x - 240) / 400 + (hash(x, row, 5) - .5) * .3
        if t < 1 then v = v - .3 elseif t >= 4 then v = v + .15 end; P(x, y, RR[GX.idx(v)])
      else
        local t = (y - 46) // 4; local col = RR[max(1, min(6, 5 - t))]
        if (x // 9) % 2 == 0 and y > 52 then col = RR[max(1, min(6, 5 - t - 1))] end; P(x, y, col)
      end
    end)
    for x = 142, 338 do P(x, 69, RR[2]) end
  end
  for y = 70, 73 do for x = 152, 328 do local cur = c:get(x, y); if cur and cur ~= INK then P(x, y, mixc(cur, "#102a30", .4 - (y - 70) * .09)) end end end
  local dk = rect(140, 204, 340, 210); c:rim(dk, INK)
  dk:each(function(x, y) local t = (y == 204) and 6 or ((y >= 209) and 2 or 4); if (x % 15) == 0 and y > 205 then t = 2 end; P(x, y, OAK[t]) end)
  local pm = c:ellipse(185, 128, 12, 12); c:rim(pm, INK); c:fillMask(pm, GOLD[3])
  local pg = c:ellipse(185, 128, 9, 9); c:rim(pg, GOLD[1]); c:fillMask(pg, p.glass or SBLUE[4])
  pg:each(function(x, y) if y < 128 then P(x, y, SBLUE[5]) end end)
  for k = 0, 5 do P(180 + k, 124 - k + 3, SBLUE[6]) end
  for x = 177, 193 do P(x, 128, GOLD[2]) end; for y = 120, 136 do P(185, y, GOLD[2]) end
  if p.ring then
    local lr = c:ellipse(318, 168, 8, 8); lr:cut(c:ellipse(318, 168, 3, 3)); c:rim(lr, INK)
    lr:each(function(x, y) local a = floor((math.atan(y - 168, x - 318) + 3.1416) / .7854); P(x, y, (a % 2 == 0) and p.ring or CREAM[5]) end); P(313, 162, "#ff9a8a")
  end
  local dm = theDoor(p, { x0 = DX0, y0 = DY0, x1 = DX1, y1 = DY1, f = 4, pw = 7 })
  plate(240, 84, p.plate)
  return dm
end

---------------------------------------------------------------- the villagers
local V = {}
V["babka-wren"] = { home = "hut", wall = DIRT, roof = THATCH, ground = GREEN, hillr = { "#3c6e5a", "#4c8068", "#6a9c7c", "#86b494", "#a4cca8", "#bcdcb4" }, bg = "bush", bushr = GREEN,
  sky = { "#8ec8e8", "#a8d8ec", "#c4e4ee", "#dcecd8", "#f0eccc" }, tuft = GREEN, plate = REDW, fcols = { "#e8493b", "#ffd24a", "#fff2dc" },
  d = { shape = "arch", frame = TIMB, wood = REDW, woven = true, seed = 2, kx = 255, ky = 186 }, over = "peep",
  props = { { "broom", 192 }, { "herbs", 172 }, { "skep", 280 } } }
V["bramble-thornwick"] = { home = "cottage", wall = CREAM, roof = THATCH, tiles = false, windows = { TEAL, { "#c8b8ec", "#ffd24a", "#f5a0c0", "#fff2dc" } }, plate = VIO,
  d = { shape = "rect", frame = TIMB, wood = VIO, straps = { 150, 186 }, seed = 3, pw = 7, kx = 254, ky = 178 }, over = "thorns", fcols = { "#c8b8ec", "#ffd24a", "#fff2dc" },
  props = { { "bramble", 104 }, { "berrycrate", 184 }, { "scraper", 276 } } }
V["clover-puddlejump"] = { home = "stone", wall = STONE, roof = BARN, roofdots = { { 200, 52, 5 }, { 262, 58, 4 }, { 232, 38, 3 }, { 300, 62, 5 }, { 170, 66, 4 }, { 280, 40, 3 } }, finc = BARN, plate = GREEN,
  d = { shape = "arch", frame = STONE, wood = GREEN, seed = 4, pw = 6, blocks = true, kx = 253, ky = 180 }, over = "clover", fcols = { "#fff2dc", "#c8b8ec" },
  props = { { "puddle", 176 }, { "leafbrella", 284 }, { "cloverpatch", 120 } } }
V["dew-dewberry"] = { home = "boat", wall = VIOLET, roof = THATCH, straw = true, hull = TEAL, stripe = GOLD, chimney = false, plate = GOLD, glass = "#82b4e4",
  d = { shape = "arch", frame = CREAM, wood = GOLD, seed = 5, pw = 7, kx = 254, ky = 180 }, over = "dewdrop", gy = 204,
  props = { { "lobsterpot", 292 }, { "buoy", 100, 186 }, { "strawhat", 172, 100 }, { "net", 264 } } }
V["fennick-hollowell"] = { home = "treehouse", trunk = OAK, ladder = 186, fungus = { "#f2a060", "#e08040", "#c4622c" }, plate = BLUEW, fcols = { "#ffd24a", "#fff2dc", "#c8b8ec" },
  d = { shape = "round", frame = TIMB, wood = BLUEW, seed = 9, pw = 7, kx = 255, ky = 190 }, over = "conehat",
  props = { { "dewbucket", 132 }, { "mush", 278 } } }
V["grandmother-hoshi"] = { home = "treehouse", trunk = ROSE, tx0 = 146, tx1 = 332, fol = PINK, fol2 = ROSE, far = { "#6a4a7a", "#7e5e8e", "#9a78a4", "#b496b8", "#cab0c8", "#e0cade" },
  sky = { "#c8b8e8", "#dcc8ec", "#ecd8ee", "#f8e4ea", "#fdeee0" }, plate = PINK, fcols = { "#fac4d4", "#fff2dc", "#ffd24a" }, tseed = 6,
  d = { shape = "arch", frame = TIMB, wood = PINK, seed = 9, pw = 7, kx = 254, ky = 182 }, over = "star",
  props = { { "paperlanterns", 150 }, { "teapot", 190, 206 }, { "pottower", 276 } } }
V["holly-barkley"] = { home = "stone", wall = STONE, wx0 = 150, wx1 = 330, roof = GREEN, roofmoss = false, finc = BARN, plate = BARN, far = { "#2c4a48", "#3a5e56", "#4c7466", "#62907a", "#7aa88a", "#98bc9c" },
  d = { shape = "arch", frame = STONE, wood = DIRT, seed = 4, pw = 6, blocks = true, straps = { 150, 184 }, kx = 252, ky = 176 }, over = "wreath", fcols = { "#e8493b", "#fff2dc" }, nomossdoor = false,
  props = { { "hollybush", 292 }, { "stripebanner", 186 }, { "woodstack", 100 } } }
V["juniper-burrowman"] = { home = "burrow", hill = GREEN, plate = BLUEW, fcols = { "#c8b8ec", "#ffd24a", "#fff2dc" },
  d = { shape = "round", frame = STONE, wood = BLUEW, seed = 6, pw = 8, blocks = true, kx = 256, ky = 188 }, over = "knit",
  props = { { "juniperbush", 170 }, { "woolbasket", 282 }, { "groundlantern", 196 } } }
V["lantern-lou"] = { home = "boat", wall = NAVY, roof = BARN, chimney = true, hull = BARN, stripe = GOLD, ring = "#e8c030", plate = BARN, water = { "#16304e", "#1e4a6a", "#2a6a8a", "#3a86a4", "#5aa4bc", "#8ccad8" },
  sky = { "#7a9ad0", "#98b4dc", "#b4c8e4", "#d8d8e8", "#f0dcc8" },
  d = { shape = "arch", frame = CREAM, wood = BARN, seed = 5, pw = 7, kx = 254, ky = 186 }, over = "wheel", gy = 204,
  props = { { "anchor", 164 }, { "ropecoil", 294 }, { "lanternline", 160, 98 } } }
V["maple-leafwhisker"] = { home = "burrow", hill = LEAF, far = { "#8a6a3a", "#a08044", "#b89a58", "#cdb270", "#dcc88c", "#ecdcaa" }, grass = LEAF, tuft = LEAF,
  sky = { "#a8c8e0", "#c4d4e0", "#e0dcd8", "#f4e0c8", "#f8d8b0" }, plate = ORNG, fcols = { "#d4503f", "#f0a048", "#ffd24a" },
  d = { shape = "arch", frame = TIMB, wood = ORNG, seed = 6, pw = 7, kx = 254, ky = 182 }, over = "mapleleaf",
  props = { { "leafpile", 176 }, { "rake", 286 }, { "acorn", 150 } } }
V["moss-sunpatch"] = { home = "stone", wall = SAND, wx0 = 146, wx1 = 334, roof = VIOLET, roofstars = { { 190, 50 }, { 270, 44 }, { 226, 34 }, { 308, 62 }, { 168, 64 } }, roofmoss = false, finc = GOLD, plate = GOLD, mossk = .64,
  d = { shape = "arch", frame = STONE, wood = GOLD, seed = 4, pw = 6, blocks = true, kx = 253, ky = 182 }, over = "sun", fcols = { "#ffd24a", "#fff2dc" },
  props = { { "sunflowers", 160 }, { "sundial", 286 } } }
V["nocturne"] = { home = "burrow", night = true, hill = DUSK, far = { "#1c2040", "#2a3258", "#3c4a70", "#52688a", "#6c88a4", "#8eaabc" }, grass = { "#14183a", "#1e2a52", "#2a3e66", "#3a5478", "#4e6e88", "#6a8ca0" },
  tuft = { "#1e2a52", "#2a3e66", "#3a5478", "#4e6e88", "#6a8ca0", "#8ab0bc" }, seed = 2,
  sky = { "#1a1840", "#2a2658", "#403a74", "#6a4e88", "#a06a8c" }, plate = VIO, fcols = { "#a48ae0", "#c8b4f4", "#fff0b0" },
  d = { shape = "round", frame = STONE, wood = VIO, seed = 6, pw = 8, blocks = true, kx = 256, ky = 190 }, over = "constel",
  props = { { "telescope", 168 }, { "easel", 286 }, { "starjar", 196 } } }
V["old-baobab-kito"] = { home = "stone", wall = TERRA, wx0 = 132, wx1 = 348, roof = SAND, rk = "dome", thatch = true, finc = TERRA, plate = GOLD, mossk = .9, far = { "#7a5a3c", "#9a7648", "#b89258", "#d0aa6a", "#e4c488", "#f2dcae" },
  sky = { "#e0c090", "#ecd0a0", "#f4dcb4", "#fae8c8", "#fff4dc" },
  d = { shape = "rect", frame = TERRA, wood = DIRT, seed = 4, pw = 6, blocks = false, f = 6, kx = 254, ky = 186 }, over = "kente", fcols = { "#d4503f", "#ffd24a" }, nomossdoor = true,
  props = { { "amphora", 168 }, { "drum", 290 }, { "kentebanner", 160 } } }
V["petalpin-greenfinger"] = { home = "treehouse", trunk = OAK, tx0 = 154, tx1 = 322, fol = GREEN, fol2 = LEAF, plate = LEAF, ladder = nil, fungus = { "#fac4d4", "#f0809c", "#c8546e" }, fcols = { "#f0809c", "#ffd24a", "#fff2dc", "#c8b8ec" },
  d = { shape = "arch", frame = TIMB, wood = LEAF, seed = 9, pw = 7, kx = 254, ky = 184 }, over = "blossom",
  props = { { "bed", 100 }, { "can", 178 }, { "wheelbarrow", 270 } } }
V["quill-brambleby"] = { home = "burrow", hill = GREEN, far = { "#3c6e5a", "#4c8068", "#6a9c7c", "#86b494", "#a4cca8", "#bcdcb4" }, plate = CREAM, fcols = { "#c8b8ec", "#f0809c" },
  d = { shape = "rect", frame = TIMB, wood = CREAM, seed = 6, pw = 7, f = 5, kx = 254, ky = 188 }, over = "quill",
  props = { { "bookstack", 178 }, { "inkwell", 276 }, { "plumtree", 124 } } }
V["sage-dewberry"] = { home = "cottage", wall = BUTTR, roof = ROSE, tiles = true, beam = TIMB, windows = { PINK, { "#f0809c", "#ffd24a", "#fff2dc", "#c8b8ec" } }, plate = PINK, path = SAND,
  d = { shape = "round", frame = TIMB, wood = PINK, seed = 3, pw = 7, kx = 254, ky = 186 }, over = "petals", fcols = { "#f0809c", "#ffd24a", "#fff2dc" },
  props = { { "pottower", 186 }, { "pinwheel", 282 } } }
V["tansy-fernsway"] = { home = "hut", wall = LEAF, roof = FERN, ground = GREEN, hillr = { "#2c5a48", "#3a6e56", "#4c8466", "#62a078", "#7ab88a", "#98cc9c" }, bg = "banana", bgr = FERN, trunkr = LEAF,
  sky = { "#a8d8c8", "#bce0d0", "#d0e8d4", "#e4f0d8", "#f4f4dc" }, tuft = GREEN, plate = GREEN, fcols = { "#f0809c", "#fff2dc" },
  d = { shape = "rect", frame = TIMB, wood = GREEN, woven = true, seed = 2, kx = 255, ky = 186 }, over = "fern",
  props = { { "hangfern", 186, 100 }, { "fernpot", 172 }, { "can", 276 } } }
V["tumble-waymarsh"] = { home = "stone", wall = { "#2c2840", "#46425a", "#625e78", "#807c94", "#a09cb0", "#c4c0d0" }, wx0 = 150, wx1 = 330, roof = nil, crenel = true, flag = { "#d4503f", "#ec7a58" }, plate = TEAL, slits = { 166, 196 }, rh = 8, mossk = .7,
  d = { shape = "arch", frame = STONE, wood = TEAL, seed = 4, pw = 6, blocks = true, straps = { 150, 184 }, kx = 253, ky = 178 }, over = "monocle", fcols = { "#ffd24a", "#fff2dc" },
  props = { { "signpost", 120 }, { "luggage", 168 } } }
V["yarrow-mossfoot"] = { home = "boat", wall = MOSSR, roof = GREEN, rk = "lily", hull = TIMB, stripe = GOLD, ring = nil, plate = ROSE, water = { "#1c4a4a", "#2a6a60", "#3a8a70", "#58a888", "#82c4a0", "#b4e0b4" }, glass = "#c8e8a0",
  d = { shape = "arch", frame = CREAM, wood = ROSE, seed = 5, pw = 7, kx = 254, ky = 182 }, over = "spots", gy = 204,
  props = { { "cauldron", 288 }, { "dandelion", 146 }, { "lilypads", 80, 232 }, { "lilypads", 420, 252 } } }

PR.lanternline = function(x, y)
  for xx = x, x + 56 do P(xx, y - 2 + floor(2 * sin((xx - x) / 9)), INK) end
  for k = 0, 3 do
    local cx = x + 6 + k * 15; local cy = y + 2 + floor(2 * sin((cx - x) / 9))
    S.glow(cx, cy + 4, 11, "#ffd070", .4)
    c:fillMask(rect(cx - 3, cy, cx + 3, cy + 9), INK); c:fillMask(rect(cx - 2, cy + 1, cx + 2, cy + 8), (k % 2 == 0) and "#ffe08a" or "#ffb868"); c:fillMask(rect(cx - 1, cy + 3, cx + 1, cy + 6), "#fff6cc"); P(cx, cy - 1, IRON[4])
  end
end

---------------------------------------------------------------- run
local p = V[name]
local dm = K[p.home](p)
if p.over then OV[p.over](p, dm) end
knob(p._o.kx or (p._o.x1 - 8), p._o.ky or ((p._o.y0 + p._o.y1) // 2 + 6))
local gy = p.gy or 206
for _, q in ipairs(p.props) do
  local f = PR[q[1]]
  if q[1] == "paperlanterns" or q[1] == "kentebanner" or q[1] == "net" or q[1] == "stripebanner" or q[1] == "bramble" then f(q[2], gy)
  elseif q[3] then f(q[2], q[3]) else f(q[2], gy) end
end
lantern(300, 120, p.home == "burrow" and { post = { TIMB, 206 } } or nil)
c:save{ aseprite = OUT .. "door-" .. name .. ".aseprite", png = OUT .. "door-" .. name .. ".png", scale = 1 }
end

build(NAME)
