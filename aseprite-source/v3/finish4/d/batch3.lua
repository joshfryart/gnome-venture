-- batch.lua: 8 WONDER pictures, 480x270. Param: name=<picture> or all
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../../lib/hp.lua")
local GX = dofile(d .. "/../../gather/gx.lua")
local vn = GX.vn
local P = HP.P
local INK = P.ink
local floor, sin, cos, abs, min, max, sqrt, pi = math.floor, math.sin, math.cos, math.abs, math.min, math.max, math.sqrt, math.pi
local function hash(a, b) return ((a * 73856093) ~ (b * 19349663) ~ (a * b * 83492791)) % 1000 end
local function rd(v) return floor(v + .5) end
local function hx(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
local function mix(a, b, t) local r1,g1,b1 = hx(a); local r2,g2,b2 = hx(b)
  return string.format("#%02x%02x%02x", rd(r1+(r2-r1)*t), rd(g1+(g2-g1)*t), rd(b1+(b2-b1)*t)) end
local function RP(base, o) o = o or {}
  return { hi = o.hi or mix(base, "#fff0c8", .42), base = base, shade = o.shade or mix(base, "#4a2a5a", .35), deep = o.deep or mix(base, "#2b1c26", .62) } end

local c
local function E(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry or rx) end
local function R(x0, y0, x1, y1) return c:rect(x0, y0, x1, y1) end
local function fm(m, h) c:fillMask(m, h) return m end
local function px(x, y, h) c:px(x, y, h) end
local function rim(m, h) return c:rim(m, h or INK) end
local function poly(p) return c:poly(p) end
-- light-from-upper-left shading of mask m (centre cx,cy radii rx,ry)
local function ball(m, Rm, cx, cy, rx, ry)
  m:each(function(x, y)
    local l = -(((x - cx) / rx) * .55 + ((y - cy) / ry) * .8)
    px(x, y, l > .55 and Rm.hi or (l > -.15 and Rm.base or (l > -.6 and Rm.shade or Rm.deep)))
  end)
end
local function obj(cx, cy, rx, ry, Rm) local m = E(cx, cy, rx, ry); rim(m, INK); ball(m, Rm, cx, cy, rx, ry); return m end
local function flat(m, Rm) -- edge-lit form for polygons/rects
  fm(m, Rm.base)
  m:each(function(x, y)
    if not m:has(x - 1, y - 1) and (not m:has(x - 1, y) or not m:has(x, y - 1)) then px(x, y, Rm.hi)
    elseif not m:has(x + 1, y) or not m:has(x, y + 1) then px(x, y, Rm.shade) end
  end)
  return m
end
local function lightOver(m, col, t, ph) -- hard-pixel checker tint
  m:each(function(x, y) if (x + y + (ph or 0)) % 2 == 0 then local h = c:get(x, y); if h then px(x, y, mix(h, col, t)) end end end)
end
local function stars(n, y0, y1, seed, col)
  for i = 1, n do local x, y = hash(i, seed) % 480, y0 + hash(i, seed + 7) % (y1 - y0)
    px(x, y, col or P.cream); if i % 7 == 0 then px(x + 1, y, col or P.cream); px(x, y + 1, col or P.cream) end end
end
local function hills(base, amp, wl, col, ph, y1) c:terrain(function(x) return base + amp * sin(x / wl + ph) + amp * .4 * sin(x / (wl * .43) + ph * 2) end, col, y1 or 269, 0, 479) end
local function tuft(x, y, g1, g2) for i = -2, 2 do px(x + i, y - (i % 2 == 0 and 3 or 2), g1); px(x + i, y - 1, g2); px(x + i, y, g2) end; px(x, y - 4, g1) end
local function sparkle(x, y) c:sparkle(x, y) end

---------------------------------------------------------------- creatures / props
local function flamingo(x, y, s, d, o)
  o = o or {}
  local by, bw, bh = y - rd(17 * s), max(3, rd(9 * s)), max(2, rd(6 * s))
  local PINK, HI, DK = "#ec7a96", "#ffb0b8", "#b8446a"
  local pts = {}
  local n = max(4, rd(22 * s))
  for i = 0, n do local t = i / n
    pts[#pts + 1] = { x + d * (rd(6 * s) + rd(5 * s * sin(t * 3.2 + (o.curl or 0)))), by - rd(2 * s) - rd(t * 21 * s) } end
  local r = max(1, rd(1.3 * s))
  local hd = pts[#pts]
  local legc = DK
  if s >= .9 then
    for _, lx in ipairs{ -2, 2 } do
      local up = (o.one and lx == 2)
      for yy = by + bh, y do local xx = x + rd(lx * s) + ((up and yy > y - rd(6 * s)) and d * rd(3 * s) or 0); px(xx, min(yy, up and y - rd(4*s) or y), legc) end
    end
    px(x - rd(2 * s) - 1, y, legc); px(x + rd(2 * s) + 1, y, legc)
  else for yy = by + bh, y do px(x, yy, legc) end end
  local bd = E(x, by, bw, bh); rim(bd, INK)
  for _, p in ipairs(pts) do rim(E(p[1], p[2], r, r), INK) end
  rim(E(hd[1], hd[2] - 1, r + 1, r + 1), INK)
  fm(bd, PINK); ball(bd, { hi = HI, base = PINK, shade = "#d05a80", deep = DK }, x, by, bw, bh)
  for _, p in ipairs(pts) do fm(E(p[1], p[2], r, r), PINK); px(p[1] - (r > 1 and 1 or 0), p[2], HI) end
  fm(E(hd[1], hd[2] - 1, r + 1, r + 1), PINK)
  if s >= .9 then
    fm(E(x - d * rd(2 * s), by, rd(5 * s), rd(3 * s)), "#d9567a")
    for i = 0, rd(4 * s) do px(x - d * (rd(3 * s) + i), by + rd(2 * s), "#7a2a4a") end   -- black-ish tail tips
    px(hd[1] + d * 1, hd[2] - 1 - (r > 1 and 1 or 0), P.cream)
    for i = 1, max(2, rd(3 * s)) do px(hd[1] + d * (r + i), hd[2] - 1 + (i > 2 and 1 or 0), i > 1 and "#4a2a3a" or P.cream) end
    px(hd[1] + d * (r + 1), hd[2], INK)
  else px(hd[1] + d * 2, hd[2], INK) end
end

local function goat(x, y, s, d, o)
  o = o or {}
  local W = RP("#f0e2c4", { shade = "#c8b090", deep = "#8a6a58" })
  local bw, bh = rd(18 * s), rd(10 * s)
  for _, lx in ipairs{ -12, -8, 8, 12 } do
    local l = R(x + rd(lx * s) - 1, y - rd(8 * s), x + rd(lx * s) + 1, y); rim(l, INK); fm(l, W.shade)
    px(x + rd(lx * s) - 1, y, INK); px(x + rd(lx * s) + 1, y, INK)
  end
  local b = obj(x, y - rd(14 * s), bw, bh, W)
  -- neck + head
  local hx0, hy0 = x + d * rd(17 * s), y - rd(26 * s)
  local nk = poly{ { x + d * rd(10 * s), y - rd(21 * s) }, { x + d * rd(14 * s), y - rd(28 * s) }, { x + d * rd(19 * s), y - rd(26 * s) }, { x + d * rd(14 * s), y - rd(14 * s) } }
  rim(nk, INK); fm(nk, W.base)
  local hd = obj(hx0, hy0, rd(6 * s), rd(5 * s), W)
  local ms = E(hx0 + d * rd(4 * s), hy0 + rd(2 * s), rd(3 * s), rd(2.5 * s)); rim(ms, INK); fm(ms, "#d8b8a0")
  px(hx0 + d * rd(6 * s), hy0 + rd(2 * s), INK)
  px(hx0 + d * rd(1 * s), hy0 - 1, INK); px(hx0 + d * rd(1 * s), hy0, INK)
  -- horns + ear + beard
  for i = 0, rd(5 * s) do px(hx0 - d * rd(2 * s) - d * i, hy0 - rd(5 * s) - i, INK); px(hx0 - d * rd(2 * s) - d * i + d, hy0 - rd(5 * s) - i, "#c8a060") end
  fm(R(hx0 - rd(3*s), hy0 + rd(1*s), hx0 - rd(1*s), hy0 + rd(3*s)), W.shade)
  for i = 0, rd(3 * s) do px(hx0 + d * rd(3 * s), hy0 + rd(5 * s) + i, W.hi); px(hx0 + d * rd(3 * s) - d, hy0 + rd(5 * s) + i, W.shade) end
  px(x - d * bw, y - rd(18 * s), INK)
  return hx0, hy0
end

local function mush(x, y, s, cap, glow)
  local st = R(x - s, y - rd(5 * s), x + s, y); rim(st, INK); fm(st, "#f4e8d0"); fm(R(x + s, y - rd(5 * s), x + s, y), "#c8b0a0")
  local cm = E(x, y - rd(6 * s), rd(5 * s), rd(3.5 * s)):clip(R(x - 40, y - 60, x + 40, y - rd(5 * s) + 1))
  cm = E(x, y - rd(6 * s), rd(5 * s), rd(3.5 * s))
  rim(cm, INK); ball(cm, cap, x, y - rd(6 * s), rd(5 * s), rd(3.5 * s))
  for _, o in ipairs{ { -2, -1 }, { 2, 0 }, { 0, -3 }, { -3, 1 } } do px(x + rd(o[1] * s * .9), y - rd(6 * s) + rd(o[2] * s * .8), P.cream) end
end

local function lantern(cx, cy, w, h, col, glow)
  local Rm = RP(col, { hi = mix(col, "#fff6c8", .6) })
  fm(R(cx - rd(w * .3), cy - h - 2, cx + rd(w * .3), cy - h), INK)
  local m = E(cx, cy, w, h); rim(m, INK); fm(m, col)
  m:each(function(x, y) local l = (x - cx) / w
    px(x, y, abs(l) < .25 and Rm.hi or (l < -.1 and col or Rm.shade)) end)
  for i = -1, 1 do px(cx + i * rd(w * .55), cy, Rm.deep) end
  for x = cx - rd(w * .6), cx + rd(w * .6) do px(x, cy - h, Rm.deep); px(x, cy + h, Rm.deep) end
  px(cx, cy + h + 1, "#ffd070"); px(cx, cy + h + 2, "#ffd070")
end

local function cloudpuff(x, y, w, col, under) c:cloud(x, y, w, col, under) end

---------------------------------------------------------------- pictures
local pics = {}
local function M() return HP.mask() end
local function Dm(m, cx, cy, rx, ry) return GX.disc(m, floor(cx), floor(cy), max(1, floor(rx + .5)), max(1, floor((ry or rx) + .5))) end
local function lit(m, Rr, o) o = o or {}; o.R = o.R or 8; o.sc = o.sc or 3; return GX.lit(c, m, GX.ramp6(Rr), o) end

-- polyline sweep: tapered limb
local function limb(pts, r0, r1, X, Y, S)
  local m = M(); local n = #pts - 1
  for i = 1, n do for k = 0, 14 do
    local t = k / 14; local u = ((i - 1) + t) / n
    Dm(m, X(pts[i][1] + (pts[i + 1][1] - pts[i][1]) * t), Y(pts[i][2] + (pts[i + 1][2] - pts[i][2]) * t), (r0 + (r1 - r0) * u) * S, (r0 + (r1 - r0) * u) * S)
  end end
  return m
end

-- goat with real anatomy: barrel body, deep chest, jointed legs with hocks, wedge head, swept horns, beard
local function goat2(x, y, s, d, chew)
  local function X(v) return x + d * floor(v * s) end
  local function Y(v) return y + floor(v * s) end
  local COAT = { hi = "#fff6e0", base = "#eddcc0", shade = "#c4a88c", deep = "#84685c" }
  local LEGC = { hi = "#c8ac8c", base = "#9c7c60", shade = "#6e5646", deep = "#443438" }
  local FAR = { hi = "#c4a888", base = "#a08468", shade = "#725a4c", deep = "#483c3c" }
  local HORN = { hi = "#f4e0a8", base = "#c8a060", shade = "#8a6444", deep = "#4a3434" }
  local function L(pts, a, b) return limb(pts, a, b, X, Y, s) end
  local fr = { { { 9, -32 }, { 11, -20 }, { 10, -10 }, { 10, -1 } }, { { -13, -34 }, { -9, -22 }, { -17, -12 }, { -15, -1 } } }
  for _, p in ipairs(fr) do local m = L(p, 5, 2.2); lit(m, FAR, { R = 3, rimlight = false }) end
  local nr = { { { 17, -32 }, { 18, -20 }, { 17, -10 }, { 17, -1 } }, { { -21, -36 }, { -14, -22 }, { -24, -12 }, { -22, -1 } } }
  -- tail
  lit(L({ { -26, -44 }, { -30, -53 } }, 3.2, 1.6), COAT, { R = 3 })
  -- body
  local body = M(); Dm(body, X(-2), Y(-37), 27 * s, 14.5 * s); Dm(body, X(14), Y(-37), 14 * s, 16 * s); Dm(body, X(-18), Y(-38), 11 * s, 13 * s)
  body:add(L({ { 18, -44 }, { 26, -54 }, { 32, -62 } }, 8.5, 5.5))
  local head = M(); Dm(head, X(37), Y(-63), 6.5 * s, 5.8 * s); Dm(head, X(45), Y(-60), 6 * s, 4.4 * s); Dm(head, X(43), Y(-57), 5 * s, 3 * s)
  body:add(head)
  lit(body, COAT, { R = floor(15 * s), tex = .25, amb = .3 })
  -- patches
  local P1 = { hi = "#c89870", base = "#a8785a", shade = "#7a5448", deep = "#52383c" }
  for _, pa in ipairs{ { -10, -40, 9, 6 }, { 6, -28, 7, 5 }, { -22, -33, 6, 6 }, { 24, -52, 4, 4 } } do
    local pm = M(); Dm(pm, X(pa[1]), Y(pa[2]), pa[3] * s, pa[4] * s)
    pm:each(function(xx, yy) if body:has(xx, yy) and body:has(xx + 1, yy) and body:has(xx, yy + 1) and body:has(xx - 1, yy) and body:has(xx, yy - 1) then
      local l = -(((xx - X(pa[1])) / (pa[3] * s)) * .6 + ((yy - Y(pa[2])) / (pa[4] * s)) * .8)
      c:px(xx, yy, l > .4 and P1.hi or (l > -.3 and P1.base or P1.shade)) end end)
  end
  -- belly shade line + fur ticks
  body:each(function(xx, yy) if vn(xx, yy, 3, 8) > .8 and body:has(xx, yy + 1) and body:has(xx + d, yy) and yy > Y(-36) then c:px(xx, yy, COAT.shade) end end)
  -- near legs
  for _, p in ipairs(nr) do local m = L(p, p[1][1] > 0 and 5.2 or 6.5, 2.2); lit(m, LEGC, { R = 3 }) end
  for _, p in ipairs(nr) do local hx, hy = X(p[4][1]), Y(-1); c:rim(Dm(M(), hx, hy, 2.4 * s, 1.6 * s), INK); c:fillMask(Dm(M(), hx, hy, 2.4 * s, 1.6 * s), "#3a2830") end
  for _, p in ipairs(fr) do local hx, hy = X(p[4][1]), Y(-1); c:fillMask(Dm(M(), hx, hy, 2.4 * s, 1.5 * s), "#3a2830") end
  -- ear, horn, beard
  local ear = L({ { 31, -64 }, { 25, -62 }, { 20, -60 } }, 3.4, 1.4); lit(ear, COAT, { R = 3 }); c:px(X(27), Y(-62), "#e8a0a0")
  local horn = L({ { 34, -68 }, { 32, -80 }, { 24, -88 }, { 17, -87 } }, 2.8, 1); lit(horn, HORN, { R = 3 })
  for k = 1, 3 do local hxx, hyy = X(33 - k * 1.2), Y(-71 - k * 3.4); c:px(hxx, hyy, HORN.deep); c:px(hxx + d, hyy, HORN.deep) end
  lit(L({ { 43, -56 }, { 44, -49 } }, 2.4, 1), COAT, { R = 2, rimlight = false })
  -- face
  local ex, ey = X(40), Y(-65)
  c:fillMask(c:rect(min(ex, ex + d), ey, max(ex, ex + d), ey + 1), INK); c:px(ex, ey, "#ffe8a0")
  c:px(X(51), Y(-61), INK); c:px(X(51), Y(-60), INK)
  for k = 0, 4 do c:px(X(44 + k), Y(-57) + (k > 2 and 1 or 0), "#8c6a5c") end
  c:px(X(47), Y(-62), "#c89c8c")
  if chew then
    for _, g in ipairs{ { 52, -56 }, { 54, -53 }, { 50, -54 } } do local gm = Dm(M(), X(g[1]), Y(g[2]), 3 * s, 3 * s); c:rim(gm, INK); lit(gm, { hi = "#c090d8", base = "#7a4a9a", shade = "#58307a", deep = "#341c54" }, { R = 3, ink = false }) end
    c:fillMask(c:rect(X(52), Y(-60), X(52), Y(-57)), "#5aa04a")
  end
end

pics["wonder-goat-path-vineyards"] = function()
  c:stripes(0, 120, { "#8ec8e8", "#a8d8ee", "#c4e6f0", "#e0f0e8", "#f8f0d0" }, { 3, 3, 3, 3, 3 })
  cloudpuff(60, 44, 70, P.cream, "#c8e0f0"); cloudpuff(330, 36, 80, P.cream, "#c8e0f0"); cloudpuff(210, 66, 40, P.cream, "#d0e4f0")
  hills(110, 8, 45, "#a8b8a0", 2, 160)
  hills(124, 10, 52, "#8aa878", 0, 200)
  -- the terraced hill: each band's contour curves; vine rows follow that curve
  local bands = { { 140, 7, 70, 0, "#b8a45c", "#8a7844" }, { 168, 8, 58, 1.6, "#a8944f", "#7c6a3c" }, { 198, 9, 64, 3.1, "#98804a", "#6e5c36" }, { 232, 10, 72, 4.4, "#88703e", "#5e4e30" }, { 270, 10, 60, 5.7, "#7a6438", "#54452c" } }
  local function edge(i, x) local b = bands[i]; return b[1] + b[2] * sin(x / b[3] + b[4]) + b[2] * .35 * sin(x / (b[3] * .41) + b[4] * 2) end
  -- path (S-curve in perspective), used to keep vines off it
  local PB = { { 244, 138 }, { 296, 190 }, { 176, 214 }, { 214, 272 } }
  local function bz(t) local u = 1 - t; return u*u*u*PB[1][1] + 3*u*u*t*PB[2][1] + 3*u*t*t*PB[3][1] + t*t*t*PB[4][1], u*u*u*PB[1][2] + 3*u*u*t*PB[2][2] + 3*u*t*t*PB[3][2] + t*t*t*PB[4][2] end
  local pathm = M()
  for k = 0, 260 do local t = k / 260; local x, y = bz(t); Dm(pathm, x, y, 4 + 50 * t ^ 1.3, 2 + 14 * t ^ 1.3) end
  for i, b in ipairs(bands) do
    c:terrain(function(x) return edge(i, x) end, b[5], 269, 0, 479)
  end
  for i, b in ipairs(bands) do
    for x = 0, 479 do
      local y0 = floor(edge(i, x) + .5)
      if not pathm:has(x, y0 + 1) then
        px(x, y0, "#e8d68c"); px(x, y0 + 1, (x % 5 < 2) and "#c8b478" or "#9c8858"); px(x, y0 + 2, b[6])
        if (x // 3) % 4 ~= 0 then px(x, y0 + 3, "#7a6240") end
      end
    end
  end
  -- vine rows along the curves
  local function vinerow(i, off, seed)
    for x = 2, 477, 5 do
      local y = floor(edge(i, x) + off + sin(x * .3) * .5)
      if not pathm:has(x, y) and not pathm:has(x + 3, y) and not pathm:has(x - 3, y) then
        local lm = M(); Dm(lm, x, y, 4, 2.6); Dm(lm, x + 2, y - 1, 3, 2)
        lit(lm, { hi = "#9cd068", base = "#58a048", shade = "#3a7a40", deep = "#265a38" }, { R = 3, ink = false, rimlight = false, tex = .3, seed = seed + x })
        px(x - 1, y - 2, "#c8ec88")
        if (x // 5 + seed) % 3 == 0 then px(x, y + 3, "#7a4a9a"); px(x + 1, y + 4, "#9a60b4"); px(x - 1, y + 4, "#5a2a7a") end
      end
    end
    for x = 0, 479 do local y = floor(edge(i, x) + off + 3 + sin(x * .3) * .5); if not pathm:has(x, y) and x % 2 == 0 then px(x, y, "#6a5436") end end
  end
  for i = 1, 4 do local h = edge(i + 1, 240) - edge(i, 240); vinerow(i, 11, i * 11); if h > 26 then vinerow(i, 22, i * 13) end end
  vinerow(5, 11, 61)
  -- the S-curve path itself
  pathm:each(function(x, y) local n = vn(x, y, 3, 5); px(x, y, n > .8 and "#c8a870" or (n < .16 and "#f8ecc0" or "#ecd8a0")) end)
  c:rim(pathm, "#8a6a40")
  -- farmhouse + cypress on the ridge
  local hs = R(60, 112, 98, 134); rim(hs, INK); flat(hs, RP("#f4e4c4", { shade = "#d0b890" }))
  local rf = poly{ { 54, 114 }, { 79, 94 }, { 104, 114 } }; rim(rf, INK); flat(rf, RP("#d0503c", { hi = "#f08a60" }))
  fm(R(74, 120, 82, 134), "#6a3c2c"); fm(R(64, 118, 69, 124), "#8ab8d8"); fm(R(90, 118, 94, 124), "#8ab8d8")
  for _, x in ipairs{ 110, 118, 392, 402 } do local cy = poly{ { x - 5, 134 }, { x, 92 }, { x + 5, 134 } }; rim(cy, INK); fm(cy, "#2c6a48"); cy:each(function(xx, yy) if xx < x - 1 and hash(xx, yy) > 500 then px(xx, yy, "#4a9a5c") end end) end
  -- hero goat chewing a grape cluster, on the path
  fm(E(236, 252, 54, 5), "#b89c68")
  goat2(222, 252, 1.55, 1, true)
  -- small goats on terraces
  goat2(120, edge(2, 120) + 22, .52, 1); goat2(392, edge(3, 392) + 20, .6, -1); goat2(70, edge(4, 70) + 24, .7, 1)
  for _, b in ipairs{ { 60, 256 }, { 94, 262 }, { 420, 258 } } do
    local m = poly{ { b[1] - 18, b[2] - 12 }, { b[1] + 18, b[2] - 12 }, { b[1] + 14, b[2] + 8 }, { b[1] - 14, b[2] + 8 } }; rim(m, INK); flat(m, RP("#b88a50", { hi = "#e0b878" }))
    for y = b[2] - 8, b[2] + 6, 4 do for x = b[1] - 14, b[1] + 14 do if m:has(x, y) then px(x, y, "#7a5a34") end end end
    for k = 0, 8 do local gx, gy = b[1] - 14 + k * 3.5 + (k % 2), b[2] - 15 - (k % 3); local g = E(rd(gx), rd(gy), 4, 4); rim(g, INK); ball(g, RP("#7a4a9a", { hi = "#c090d8" }), rd(gx), rd(gy), 4, 4) end end
  for _, t in ipairs{ { 20, 262 }, { 450, 266 }, { 300, 262 } } do tuft(t[1], t[2], "#9acc68", "#5a9a44") end
end

pics["wonder-lantern-festival-river"] = function()
  c:stripes(0, 150, { "#161640", "#1e1c52", "#2a2262", "#3a2a72", "#52347c", "#7a4684" }, { 3, 3, 3, 3, 3, 3 })
  stars(60, 0, 80, 12, "#fff0d0")
  local mn = E(100, 44, 16, 16); fm(mn, "#fff0c0"); ball(mn, RP("#fff0c0", { hi = "#fffbe8", shade = "#e8d8a8", deep = "#d0c090" }), 100, 44, 16, 16)
  hills(120, 10, 60, "#3a2c66", 1, 170); hills(138, 8, 45, "#2c2458", 3, 200)
  local function tier(cx, y, w, col) local m = poly{ { cx - w - 6, y }, { cx - w, y - 6 }, { cx + w, y - 6 }, { cx + w + 6, y } }; rim(m, INK); flat(m, RP(col, { hi = mix(col, "#fff0c8", .4) })); end
  for i = 0, 3 do local y = 132 - i * 16; local w = 16 - i * 3
    local b = R(240 - w + 2, y - 12, 240 + w - 2, y - 5); rim(b, INK); flat(b, RP("#c8584a", { hi = "#f08a6a" })); fm(R(237, y - 11, 243, y - 6), "#ffd070")
    tier(240, y - 12, w, "#7a3a5a") end
  fm(R(239, 56, 241, 62), INK); px(240, 54, "#ffd070")
  -- river in true perspective: half-width grows from the horizon, gentle bend
  local function cxr(y) return 240 + 16 * sin((y - 148) * .028) end
  local function hw(y) return 12 + ((y - 148) ^ 1.1) * 1.5 end
  local riv = M()
  for y = 149, 269 do local w = hw(y); for x = floor(cxr(y) - w), floor(cxr(y) + w) do if x >= 0 and x <= 479 then riv:set(x, y) end end end
  for y = 149, 269 do
    local t = (y - 148) / 121; local row = log and 0 or 0
    local rr = math.log(1 + (y - 148) * .4) * 8; local fr = rr - floor(rr)
    local w = hw(y)
    for x = 0, 479 do
      if riv:has(x, y) then
        local col = t < .2 and "#2c3a7c" or (t < .5 and "#2a4a8a" or (t < .8 and "#2a5a98" or "#2c68a0"))
        local ripple = fr < .14 and ((floor(x / (3 + t * 9)) + floor(rr)) % 3 ~= 0)
        if ripple then col = t < .5 and "#3e5ea8" or "#4a74b8" end
        local mx = 100 + (cxr(y) - 240) * .2
        if abs(x - mx) < 3 + t * 22 and ripple then col = (floor(rr) % 2 == 0) and "#fff0c0" or "#e8d090" end
        local edge = min(x - (cxr(y) - w), (cxr(y) + w) - x)
        if edge < 2 then col = "#5a7ab0" end
        c:px(x, y, col)
      else
        -- banks: dark land with lit rim and grass texture
        local lx = (x - cxr(y)); local e = abs(lx) - w
        local col = "#1c3a4c"
        if e < 4 then col = "#3a6a60" elseif e < 10 then col = "#2a5058" end
        if hash(x, y) > 930 and e > 6 then col = "#2c6a58" end
        c:px(x, y, col)
      end
    end
  end
  fm(R(0, 148, 479, 150), "#2c2458")
  local function tree(x, y, s) fm(R(x - 1, y - rd(20 * s), x + 1, y), "#2a1c30"); obj(x, y - rd(28 * s), rd(14 * s), rd(12 * s), RP("#2c6a58", { hi = "#4a9a78" })); fm(E(x + 2, y + 1, rd(10 * s), 2), "#142c3c") end
  tree(40, 196, 1.4); tree(110, 190, 1); tree(430, 196, 1.5); tree(372, 180, .9); tree(190, 170, .5); tree(296, 168, .5); tree(18, 236, 1.7); tree(462, 238, 1.8)
  -- richer stone bridge: three arches, parapet with lamp posts, reflection
  local by, bx0, bx1 = 168, 116, 364
  local deck = R(bx0, by - 10, bx1, by + 14); rim(deck, INK)
  local BR = RP("#8a7aa8", { hi = "#c0b0d8", shade = "#5c4e80", deep = "#3a3060" })
  fm(deck, BR.base)
  deck:each(function(x, y)
    local row = floor((y - (by - 10)) / 4); local off = (row % 2) * 4; local col = (x - bx0 + off) % 9
    local h = hash(floor((x - bx0 + off) / 9), row)
    px(x, y, (y - (by - 10)) % 4 == 3 and BR.shade or (col == 0 and BR.shade or (h > 800 and BR.hi or (h < 200 and BR.shade or BR.base)))) end)
  fm(R(bx0, by - 10, bx1, by - 9), BR.hi)
  for k = 0, 2 do
    local acx = 178 + k * 62 - (k == 2 and 0 or 0); local aw = k == 1 and 24 or 20
    local m = E(acx, by + 14, aw, 14):clip(R(acx - aw, by - 2, acx + aw, by + 14)); rim(m, INK)
    m:each(function(x, y) local t = (y - (by - 2)) / 16; c:px(x, y, t < .3 and "#161840" or (t < .7 and "#242c68" or "#2c3a7c")) end)
    for x = acx - aw, acx + aw do px(x, by - 2 - floor(sqrt(max(0, 1 - ((x - acx) / aw) ^ 2)) * 0), BR.hi) end
  end
  for x = bx0, bx1, 12 do fm(R(x, by - 18, x + 2, by - 10), BR.base); px(x, by - 18, BR.hi); px(x + 2, by - 17, BR.shade) end
  fm(R(bx0, by - 15, bx1, by - 14), BR.hi); fm(R(bx0, by - 14, bx1, by - 13), BR.shade)
  for _, lx in ipairs{ bx0 + 2, 240, bx1 - 2 } do
    fm(R(lx - 1, by - 28, lx + 1, by - 18), INK); lantern(lx, by - 32, 5, 6, "#f2a83c")
    for k = 0, 5 do px(lx, by + 18 + k * 3, mix("#f2b83c", "#2a4a8a", .35 + k * .08)); if k % 2 == 0 then px(lx + 1, by + 19 + k * 3, mix("#f2b83c", "#2a4a8a", .5)) end end
  end
  for x = bx0, bx1, 3 do px(x, by + 17 + (x % 2), "#161840") end
  local function stringl(x0, y0, x1, y1, n)
    for k = 0, 40 do local t = k / 40; px(rd(x0 + (x1 - x0) * t), rd(y0 + (y1 - y0) * t + 18 * sin(t * pi)), INK) end
    for i = 1, n - 1 do local t = i / n; local x, y = rd(x0 + (x1 - x0) * t), rd(y0 + (y1 - y0) * t + 18 * sin(t * pi))
      lantern(x, y + 8, 4, 5, (i % 3 == 0) and "#f2603c" or ((i % 3 == 1) and "#f2b83c" or "#e0508a")) end
  end
  stringl(0, 40, 200, 70, 6); stringl(479, 40, 280, 70, 6)
  -- floating lanterns with reflections, scale with depth, kept inside the river
  local cols = { "#f2603c", "#f2b83c", "#e0508a", "#ffd070", "#f28a3c" }
  local list = {}
  for i = 0, 28 do
    local y = 184 + (hash(i, 5) % 70); local w = hw(y)
    list[#list + 1] = { y = y, x = rd(cxr(y) + ((hash(i, 7) % 200) / 100 - 1) * w * .75), col = cols[1 + i % 5], t = (y - 148) / 121 }
  end
  table.sort(list, function(a, b) return a.y < b.y end)
  for _, l in ipairs(list) do
    local s = 3 + rd(l.t * 6); local x, y, col = l.x, l.y, l.col
    fm(E(x, y + s + 2, s + 4, 2), mix(col, "#1c2a5c", .65))
    for k = 1, 5 do local cc = mix(col, "#2a4a8a", .45 + k * .08); for xx = x - rd(s * .5), x + rd(s * .5) do if (xx + k) % 2 == 0 then px(xx, y + s + 3 + k * 2, cc) end end end
    lantern(x, y, s, s - 1, col)
  end
  -- hero raft
  fm(E(240, 246, 60, 9), "#173060")
  local raft = poly{ { 190, 244 }, { 290, 244 }, { 282, 256 }, { 198, 256 } }; rim(raft, INK); flat(raft, RP("#a8704c", { hi = "#d8a070" }))
  for x = 198, 282, 10 do for y = 245, 255 do px(x, y, "#6a4a38") end end
  for k = 0, 6 do fm(R(222 + (k % 2) * 4, 258 + k * 2, 258 - (k % 2) * 4, 258 + k * 2), mix("#f2603c", "#173060", .4 + k * .07)) end
  lantern(240, 218, 18, 20, "#f2603c")
  fm(R(231, 216, 249, 218), "#ffd070"); fm(R(237, 208, 243, 226), "#fff0b0")
  lantern(206, 232, 9, 10, "#f2b83c"); lantern(274, 232, 9, 10, "#e0508a")
  sparkle(240, 190); sparkle(180, 210); sparkle(300, 204)
  fm(E(398, 252, 14, 3), "#2e8a50"); rim(E(398, 252, 14, 3), INK); fm(E(398, 252, 13, 2), "#48b060")
  obj(398, 246, 6, 5, RP("#6cc060")); px(395, 243, P.cream); px(401, 243, P.cream); px(395, 243, INK); px(401, 243, INK)
  fm(R(403, 238, 403, 246), INK); lantern(406, 238, 3, 4, "#ffd070")
  for _, f in ipairs{ { 20, 262 }, { 450, 266 } } do tuft(f[1], f[2], "#3c8a68", "#2a6a50") end
end

---------------------------------------------------------------- run
local only = app.params.name
local order = { "wonder-goat-path-vineyards", "wonder-lantern-festival-river" }
for _, n in ipairs(order) do
  if not only or only == "all" or only == n then
    c = HP.canvas{ w = 480, h = 270, scale = 1, name = n }
    local ok, e = xpcall(pics[n], debug.traceback); if not ok then print(e) end
    c:hem(2); c:hem(267)
    c:save{ aseprite = d .. "/out/" .. n .. ".aseprite", png = d .. "/out/" .. n .. ".png", scale = 1 }
  end
end
