-- batch.lua: 8 WONDER pictures, 480x270. Param: name=<picture> or all
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../../lib/hp.lua")
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

pics["wonder-cedar-sanctuary"] = function()
  c:stripes(0, 150, { "#f4a98c", "#f8bf94", "#fbd29c", "#fde2ae", "#fff0c4", "#e8f0d8" }, { 2, 2, 2, 2, 2, 2 })
  for _, s in ipairs{ { 60, 40, 80 }, { 330, 30, 100 }, { 420, 60, 60 } } do cloudpuff(s[1], s[2], s[3], "#fff0dc", "#f4c8b0") end
  local function mtn(pts, col, snow)
    local m = poly(pts); fm(m, col)
    local top = HP.mask(); m:each(function(x, y) if y < snow[1] + (hash(x, 1) % 5) + abs(((x * 7) % 11) - 5) then top:set(x, y) end end)
    top:clip(m); fm(top, "#fff4e4")
    m:each(function(x, y) if x > 0 and not m:has(x, y + 1) then end end)
    return m end
  mtn({ { 0, 150 }, { 70, 84 }, { 110, 112 }, { 170, 70 }, { 250, 130 }, { 300, 96 }, { 360, 62 }, { 420, 110 }, { 479, 82 }, { 479, 150 } }, "#a8a0c8", { 100 })
  hills(142, 8, 40, "#8aa890", 1, 200); hills(158, 7, 55, "#6c9a6c", 3, 240)
  hills(178, 5, 30, "#5a8c58", 5, 269)
  -- meadow + path
  c:terrain(function(x) return 190 + 4 * sin(x / 50) end, "#7cae5c", 269, 0, 479)
  c:terrain(function(x) return 214 + 6 * sin(x / 37) end, "#68a04e", 269, 0, 479)
  local path = poly{ { 214, 262 }, { 266, 262 }, { 256, 218 }, { 224, 218 } }; fm(path, "#e8c88c")
  path:each(function(x, y) if hash(x, y) > 900 then px(x, y, "#c8a46c") end end)
  local CED = RP("#3c8a58", { hi = "#7ccb74", shade = "#2a6a4c", deep = "#1c4a3e" })
  local function cedar(cx, base, sc, tiers)
    local tw = rd(10 * sc)
    local tr = R(cx - tw, base - rd(120 * sc), cx + tw, base); rim(tr, INK); flat(tr, RP("#8a5a3c", { hi = "#c08a58" }))
    for y = base - rd(120 * sc), base do if hash(y, cx) > 600 then px(cx - tw + 3, y, "#5a3a2c") end end
    for i = 1, tiers do
      local ty = base - rd(112 * sc) + (i - 1) * rd(100 * sc / tiers * 1.05)
      local rx, ry = rd((22 + i * (60 / tiers) * 1.2) * sc), rd((9 + i * 2) * sc)
      local m = E(cx, ty, rx, ry):add(E(cx - rd(rx * .55), ty + 3, rd(rx * .5), rd(ry * .8))):add(E(cx + rd(rx * .55), ty + 3, rd(rx * .5), rd(ry * .8)))
      rim(m, INK); fm(m, CED.base)
      m:each(function(x, y)
        local l = -(((x - cx) / rx) * .4 + ((y - ty) / ry) * .9)
        local t = l > .5 and CED.hi or (l > -.2 and CED.base or (l > -.65 and CED.shade or CED.deep))
        if hash(x, y) > 930 then t = CED.hi elseif hash(x, y + 5) > 950 then t = CED.deep end
        px(x, y, t) end)
      for k = -2, 2 do local lx = cx + rd(k * rx * .42); px(lx, ty + ry + 1, INK); px(lx, ty + ry + 2, CED.deep); px(lx, ty + ry + 3, INK) end
    end
    return tw
  end
  cedar(70, 214, .55, 3); cedar(410, 218, .6, 3); cedar(150, 200, .35, 3); cedar(330, 200, .38, 3)
  cedar(240, 232, 1.22, 5)
  -- prayer ribbons + hanging lanterns on the giant
  for _, r in ipairs{ { 190, 134 }, { 214, 116 }, { 262, 118 }, { 294, 136 }, { 176, 160 }, { 308, 160 } } do
    local col = (r[1] % 2 == 0) and "#e0503c" or "#f2c14e"
    fm(R(r[1], r[2], r[1] + 2, r[2] + 11), col); px(r[1] + 1, r[2] + 12, col); px(r[1], r[2] - 1, INK); px(r[1] + 1, r[2] - 1, INK); px(r[1] + 2, r[2] - 1, INK) end
  -- stone ring + sacred fire at the foot
  local ring = E(240, 238, 46, 13); rim(ring, INK); ball(ring, RP("#b8b0c0", {}), 240, 238, 46, 13)
  local inner = E(240, 237, 36, 9); rim(inner, INK); fm(inner, "#3a2c3c")
  for i = 0, 15 do local a = i / 16 * 2 * pi; local sx, sy = 240 + rd(46 * cos(a)), 238 + rd(13 * sin(a)); px(sx, sy, (i % 2 == 0) and "#d8d0dc" or "#8a8298") end
  local fl = poly{ { 226, 238 }, { 230, 224 }, { 236, 230 }, { 240, 212 }, { 246, 228 }, { 252, 220 }, { 256, 238 } }; rim(fl, INK); fm(fl, "#f08a3c")
  fm(poly{ { 232, 238 }, { 238, 224 }, { 241, 228 }, { 244, 222 }, { 250, 238 } }, "#ffd070"); fm(R(238, 232, 244, 238), "#fff2b0")
  sparkle(262, 212); sparkle(216, 220)
  -- quirk: an owl on a low branch of the giant cedar
  local ob = obj(296, 172, 7, 8, RP("#b88458")); fm(E(296, 175, 4, 5), "#f0d8a8")
  for _, ex in ipairs{ 293, 299 } do fm(E(ex, 170, 2, 2), P.cream); px(ex, 170, INK) end
  px(296, 172, "#f0a830"); px(290, 165, INK); px(302, 165, INK); px(291, 166, "#b88458"); px(301, 166, "#b88458")
  -- foreground: tufts, flowers, stones
  for _, t in ipairs{ { 20, 250 }, { 70, 262 }, { 130, 256 }, { 360, 258 }, { 420, 264 }, { 460, 250 } } do tuft(t[1], t[2], "#8cc060", "#58903e") end
  for i = 1, 26 do local x, y = hash(i, 31) % 480, 226 + hash(i, 33) % 40
    if abs(x - 240) > 40 then px(x, y, (i % 3 == 0) and "#f2c14e" or ((i % 3 == 1) and "#f08aa8" or P.cream)); px(x, y + 1, "#58903e") end end
  for _, s in ipairs{ { 100, 244, 9, 5 }, { 388, 248, 11, 6 } } do obj(s[1], s[2], s[3], s[4], RP("#b0a8c0")) end
end

pics["wonder-cenote-of-echoes"] = function()
  c:stripes(0, 269, { "#1c2c3c", "#223a48", "#2a4856", "#2e5258" }, { 2, 2, 2, 2 })
  -- limestone wall
  local WALL = RP("#7a8c88", { hi = "#aab8a8", shade = "#4e625e", deep = "#2e4040" })
  fm(R(0, 0, 479, 269), WALL.shade)
  for y = 0, 190 do for x = 0, 479 do if hash(x // 3, y // 2) > 880 then px(x, y, WALL.base) elseif hash(x // 2, y // 3 + 9) > 960 then px(x, y, WALL.deep) end end end
  -- the open sky hole
  local hole = E(240, 52, 150, 38)
  rim(hole, INK); c:stripes(14, 90, { "#9ad4e8", "#bde4ee", "#dff2ea" }, { 3, 3, 3 }); -- repaint only inside hole below
  local skyc = { "#8cd0e8", "#a8dcec", "#c8ecee", "#e8f6e8" }
  hole:each(function(x, y) px(x, y, skyc[min(4, 1 + floor((y - 14) / 20))]) end)
  cloudpuff(220, 52, 40, "#fffdf0", "#cfe6e8")
  -- jungle rim on top of hole
  local function bush(cx, cy, rx, ry, col) local m = E(cx, cy, rx, ry); rim(m, INK); ball(m, RP(col, { hi = mix(col, "#e8f090", .45) }), cx, cy, rx, ry) end
  for i = 0, 18 do local a = pi + i / 18 * pi; local x, y = 240 + rd(150 * cos(a)), 52 + rd(38 * sin(a)); bush(x, y - 2, 14 + hash(i, 3) % 6, 8 + hash(i, 5) % 4, (i % 2 == 0) and "#3a8a4c" or "#2c7448") end
  for i = 0, 5 do local x = 90 + i * 60 + hash(i, 2) % 20
    for y = 66, 66 + 20 + hash(i, 4) % 40 do px(x, y, ((y + i) % 3 == 0) and "#2a6a3c" or "#3c8c4c") end end   -- hanging roots
  -- light shaft: dithered, widening downward
  local shaft = poly{ { 170, 56 }, { 300, 56 }, { 360, 200 }, { 150, 200 } }
  lightOver(shaft, "#fff4b8", .5, 0)
  local core = poly{ { 200, 60 }, { 270, 60 }, { 300, 200 }, { 190, 200 } }
  lightOver(core, "#ffffe0", .5, 1)
  -- water basin
  local pool = E(240, 214, 214, 52); rim(pool, INK)
  fm(pool, "#1c6a84")
  pool:each(function(x, y) local dy = (y - 162) / 104; px(x, y, dy < .25 and "#1a5e78" or (dy < .45 and "#1f7a94" or (dy < .7 and "#28a0aa" or "#44c8c0"))) end)
  -- sunlit pool surface where shaft lands, plus echo rings
  for k = 1, 5 do local rx, ry = 24 + k * 22, 5 + k * 4
    local ringm = E(240, 206, rx, ry):copy():cut(E(240, 206, rx - 2, ry - 1)):clip(pool)
    ringm:each(function(x, y) if (x + k) % 3 ~= 0 then px(x, y, (k % 2 == 1) and "#d8fff0" or "#8ee8dc") end end) end
  local lit = E(240, 206, 36, 9); fm(lit, "#e8fff0"); fm(E(240, 206, 22, 5), P.cream)
  for i = 0, 40 do local x, y = 60 + hash(i, 41) % 360, 180 + hash(i, 43) % 66; if pool:has(x, y) then px(x, y, "#9aeee0"); px(x + 1, y, "#9aeee0") end end
  -- stepping stones to the centre
  for _, s in ipairs{ { 150, 232, 16, 6 }, { 196, 222, 13, 5 }, { 286, 224, 13, 5 }, { 332, 234, 16, 6 } } do
    fm(E(s[1] + 3, s[2] + s[4] + 2, s[3] - 2, 2), "#134a64"); obj(s[1], s[2], s[3], s[4], WALL) end
  -- central echo stone with a glowing rune
  local es = E(240, 204, 11, 7); rim(es, INK); ball(es, WALL, 240, 204, 11, 7)
  fm(R(239, 198, 241, 202), "#ffe38a"); sparkle(240, 192)
  -- foreground ledges, ferns, stalactites
  for _, f in ipairs{ { 20, 252, 56, 30 }, { 452, 254, 60, 30 } } do local m = E(f[1], f[2], f[3], f[4]); rim(m, INK); ball(m, WALL, f[1], f[2], f[3], f[4]) end
  local function fern(x, y, dir)
    for i = -5, 5 do local len = 22 - abs(i) * 2
      for t = 0, len do local xx, yy = x + rd(t * cos(-1.2 + i * .28) * dir), y - rd(t * -sin(-1.2 + i * .28) * .75) - floor(t * .4)
        px(xx, yy, (t % 3 == 0) and "#8ed068" or "#3c9a4c") end end end
  fern(52, 226, 1); fern(448, 228, -1); fern(84, 242, 1)
  for _, s in ipairs{ { 40, 0, 14, 40 }, { 120, 0, 10, 28 }, { 420, 0, 13, 36 }, { 360, 0, 8, 22 } } do
    local m = poly{ { s[1] - s[3], s[2] }, { s[1] + s[3], s[2] }, { s[1] + 1, s[2] + s[4] }, { s[1], s[2] + s[4] + 3 } }; rim(m, INK); flat(m, WALL) end
  -- quirk: a singing frog on a lily pad, with notes
  fm(E(330, 228, 11, 3), "#2e8a50"); rim(E(330, 228, 11, 3), INK); fm(E(330, 228, 10, 2), "#4cb064")
  obj(330, 222, 6, 5, RP("#6cc060")); px(327, 219, P.cream); px(333, 219, P.cream); px(327, 219, INK); px(333, 219, INK); fm(R(328, 224, 332, 224), "#c85a5a")
  for _, n in ipairs{ { 342, 214 }, { 350, 206 }, { 346, 196 } } do px(n[1], n[2], INK); px(n[1] + 1, n[2], INK); px(n[1] + 1, n[2] - 1, INK); px(n[1] + 1, n[2] - 2, INK); px(n[1] + 2, n[2] - 2, INK) end
end

pics["wonder-coffee-ceremony-hut"] = function()
  c:stripes(0, 160, { "#2a2358", "#3c2f70", "#5a3a80", "#8a4a88", "#c45e7a", "#ee8a6a", "#fbb878" }, { 3, 3, 3, 3, 3, 3, 3 })
  stars(60, 0, 80, 4)
  fm(E(404, 36, 14, 14), "#fff0c0"); fm(E(410, 32, 12, 12), "#3c2f70"); fm(E(410, 32, 12, 12), "#3c2f70")
  fm(E(404, 36, 14, 14):copy():cut(E(411, 32, 13, 13)), "#fff0c0")
  hills(150, 6, 60, "#5a3a6c", 2, 220)
  hills(160, 4, 40, "#463058", 4, 240)
  local function acacia(x, y, s) fm(R(x - 1, y - rd(14 * s), x + 1, y), "#2a1c30"); fm(E(x, y - rd(16 * s), rd(26 * s), rd(4 * s)), "#2a1c30"); fm(E(x - rd(8*s), y - rd(19*s), rd(12*s), rd(3*s)), "#2a1c30") end
  acacia(86, 168, 1.3); acacia(420, 170, 1)
  -- ground
  c:terrain(function(x) return 186 + 2 * sin(x / 60) end, "#8a5a4a", 269, 0, 479)
  c:terrain(function(x) return 214 + 3 * sin(x / 45) end, "#a8704e", 269, 0, 479)
  for i = 1, 90 do local x, y = hash(i, 51) % 480, 190 + hash(i, 53) % 78; px(x, y, (i % 2 == 0) and "#c48a5c" or "#6e4438") end
  -- the hut: round clay wall + conical thatch
  fm(E(240, 192, 60, 8), "#5a3a40")
  local wall = R(188, 140, 292, 192); rim(wall, INK); ball(wall, RP("#d49a68", { hi = "#f0c088", shade = "#a06a4c", deep = "#6a4038" }), 240, 150, 70, 60)
  for y = 150, 190, 8 do for x = 188, 292 do if hash(x, y) > 500 then px(x, y, "#a06a4c") end end end
  local door = poly{ { 224, 192 }, { 224, 160 }, { 230, 152 }, { 250, 152 }, { 256, 160 }, { 256, 192 } }; rim(door, INK); fm(door, "#ffb850")
  fm(poly{ { 228, 192 }, { 228, 162 }, { 232, 156 }, { 248, 156 }, { 252, 162 }, { 252, 192 } }, "#ffd878"); fm(R(236, 160, 244, 192), "#fff0b0")
  for x = 232, 248, 8 do for y = 160, 192 do px(x, y, "#b06a3c") end end
  local roof = poly{ { 170, 146 }, { 240, 62 }, { 310, 146 } }; rim(roof, INK); fm(roof, "#c8963c")
  roof:each(function(x, y) local l = -((x - 240) * .6 + (y - 110) * .5) / 60
    local row = (y // 4) % 2; local t = (l > .25) and "#f0c868" or (l > -.2 and "#d8a444" or "#98682c")
    if (x + row * 2) % 5 == 0 then t = (l > .25) and "#c8963c" or "#6e4a2a" end
    if y % 4 == 3 then t = "#6e4a2a" end px(x, y, t) end)
  for x = 170, 310 do local yy = 146 + ((x % 4 == 0) and 2 or 0); px(x, yy, INK); end
  fm(R(239, 56, 241, 66), INK); fm(R(238, 50, 242, 56), "#c8963c"); px(240, 48, INK)
  -- rug in front, striped
  local rug = poly{ { 140, 252 }, { 340, 252 }, { 360, 222 }, { 120, 222 } }; rim(rug, INK); fm(rug, "#d0503c")
  rug:each(function(x, y) local k = ((x + (y - 222)) // 6) % 4; px(x, y, k == 0 and "#f2c14e" or (k == 2 and "#3c8a8c" or "#d0503c")) end)
  for x = 122, 358 do if x % 3 ~= 2 then px(x, 221, "#f2c14e") end end
  -- brazier with jebena
  local br = poly{ { 214, 246 }, { 266, 246 }, { 258, 234 }, { 222, 234 } }; rim(br, INK); flat(br, RP("#5a4a60", { hi = "#8a7a90" }))
  for x = 226, 254, 4 do px(x, 238, "#f08a3c"); px(x + 1, 237, "#ffd070") end
  fm(R(222, 232, 258, 233), "#f0623c"); for x = 224, 256, 3 do px(x, 232, "#ffd070") end
  local pot = E(240, 214, 12, 14); rim(pot, INK); ball(pot, RP("#7a4a3c", { hi = "#b0806a" }), 240, 214, 12, 14)
  local nk = poly{ { 235, 202 }, { 245, 202 }, { 243, 190 }, { 237, 190 } }; rim(nk, INK); flat(nk, RP("#7a4a3c", { hi = "#b0806a" }))
  fm(R(235, 186, 245, 190), "#2b1c26"); fm(R(236, 187, 244, 188), "#8a6a5a")
  local sp = poly{ { 250, 210 }, { 262, 196 }, { 264, 198 }, { 253, 214 } }; rim(sp, INK); fm(sp, "#7a4a3c")
  for i = 0, 5 do px(222 - i, 206 + i * 2 // 2 - 3, INK); px(222 - i, 207 + i // 2 - 3, "#7a4a3c") end
  for i = 0, 3 do px(210, 200 + i * 4, INK) end
  fm(R(240, 212, 240, 218), "#e8c8a0")
  -- steam / incense
  for i = 0, 40 do px(263 + rd(4 * sin(i / 4)), 194 - i, (i % 3 == 0) and "#f4e8e0" or "#d8c8d8") end
  for i = 0, 36 do px(236 + rd(5 * sin(i / 5 + 1)), 180 - i, (i % 3 == 0) and "#f4e8e0" or "#c8b8cc") end
  -- cups in a row, popcorn bowl
  for i = 0, 4 do local x = 156 + i * 14; obj(x, 238, 5, 4, RP("#f4e8d8", { shade = "#c8b0a0" })); fm(E(x, 236, 3, 1), "#4a2c28") end
  local bowl = E(302, 240, 16, 9); rim(bowl, INK); ball(bowl, RP("#6a8a9a", { hi = "#a8c4cc" }), 302, 240, 16, 9)
  for i = 0, 30 do local a = hash(i, 9) / 1000 * 2 * pi; local r = hash(i, 11) / 1000 * 11; local x, y = 302 + rd(r * cos(a)), 235 + rd(r * sin(a) * .5)
    px(x, y, "#fff4d8"); px(x + 1, y, "#f4d890"); px(x, y - 1, "#fff4d8") end
  -- quirk: a ginger cat watching the pot
  obj(180, 240, 9, 7, RP("#e0873c")); obj(190, 230, 6, 5, RP("#e0873c"))
  for _, ex in ipairs{ 187, 193 } do px(ex, 229, INK) end
  px(185, 224, INK); px(186, 225, "#e0873c"); px(194, 224, INK); px(193, 225, "#e0873c")
  for i = 0, 6 do px(171 - i, 244 - i // 3, "#e0873c"); px(171 - i, 245 - i // 3, INK) end
  for x = 184, 196, 3 do px(x, 237, "#a85a2c") end
  -- lanterns on poles
  for _, x in ipairs{ 80, 400 } do fm(R(x, 160, x + 1, 214), INK); lantern(x, 160, 5, 7, "#f2a23c") end
  sparkle(270, 176)
end

pics["wonder-fairy-ring-clearing"] = function()
  c:stripes(0, 160, { "#10182c", "#16203c", "#1c2a4c", "#223458", "#2a4466" }, { 3, 3, 3, 3, 3 })
  stars(70, 0, 90, 8)
  local mn = E(380, 40, 20, 20); rim(mn, "#c8d8f0"); fm(mn, "#fff6d0"); ball(mn, RP("#fff0c0", { hi = "#fffbe8", shade = "#e8d8a8", deep = "#d0c090" }), 380, 40, 20, 20)
  fm(E(372, 34, 4, 3), "#e8d8a8"); fm(E(388, 46, 3, 3), "#e8d8a8")
  local function trunks(col, hi, ys, n, seed, wmin, wv)
    for i = 0, n do local x = (i * 480 // n) + hash(i, seed) % 30 - 10; local w = wmin + hash(i, seed + 1) % wv
      fm(R(x, 0, x + w, ys), col); fm(R(x, 0, x, ys), hi) end end
  trunks("#1a3048", "#244060", 190, 14, 1, 7, 6)
  c:terrain(function(x) return 184 + 2 * sin(x / 30) end, "#1c3a44", 269, 0, 479)
  trunks("#122438", "#1c3450", 200, 9, 2, 12, 10)
  c:terrain(function(x) return 196 + 3 * sin(x / 40) end, "#244a48", 269, 0, 479)
  for i = 0, 20 do local x = hash(i, 15) % 480; local y = 40 + hash(i, 17) % 130; fm(E(x, y, 14, 3), "#1e5a50"); px(x - 6, y, "#2e7a60") end
  c:terrain(function(x) return 206 + 4 * sin(x / 55) end, "#2e6a4c", 269, 0, 479)
  c:terrain(function(x) return 232 + 3 * sin(x / 33 + 1) end, "#3a7c50", 269, 0, 479)
  -- ring: glowing grass disc
  local disc = E(240, 224, 124, 26); fm(disc, "#4a9a5c")
  fm(E(240, 224, 100, 20), "#68b868"); fm(E(240, 225, 70, 14), "#88d078")
  local lit = E(240, 224, 124, 26):copy():cut(E(240, 224, 118, 24)); fm(lit, "#a8e890")
  for i = 0, 50 do local x, y = 130 + hash(i, 21) % 220, 208 + hash(i, 23) % 36; if disc:has(x, y) then px(x, y, "#c8f4a0"); end end
  -- stump house at the back of the ring (quirk: tiny lit door)
  local st = E(240, 200, 26, 6); rim(st, INK)
  local sb = poly{ { 216, 200 }, { 220, 170 }, { 260, 170 }, { 264, 200 } }; rim(sb, INK); flat(sb, RP("#8a5a48", { hi = "#c48a68" }))
  fm(E(240, 170, 20, 4), "#d8a878"); rim(E(240, 170, 20, 4), INK); fm(E(240, 170, 20, 4), "#d8a878"); fm(E(240, 170, 12, 2), "#e8c090")
  fm(E(240, 170, 20, 4):copy():cut(E(240, 169, 18, 3)), "#a8704c")
  local dr = poly{ { 233, 200 }, { 233, 184 }, { 237, 179 }, { 243, 179 }, { 247, 184 }, { 247, 200 } }; rim(dr, INK); fm(dr, "#ffc860"); fm(R(237, 184, 243, 200), "#fff0b0")
  fm(R(229, 164, 231, 169), "#f06a8a"); fm(E(230, 163, 3, 2), "#f06a8a")
  -- ring of toadstools
  local list = {}
  for i = 0, 15 do local a = i / 16 * 2 * pi + .2; list[#list + 1] = { 240 + rd(122 * cos(a)), 224 + rd(25 * sin(a)), a } end
  table.sort(list, function(p, q) return p[2] < q[2] end)
  for i, m in ipairs(list) do
    local front = m[2] > 224
    local s = front and 2.0 or 1.4
    local col = (i % 3 == 0) and RP("#f06a4a", { hi = "#ffa070" }) or ((i % 3 == 1) and RP("#d8486a", { hi = "#ff8aa0" }) or RP("#c85ab0", { hi = "#f090d8" }))
    mush(m[1], m[2], s, col) end
  -- motes spiralling up from the middle
  for i = 0, 40 do local t = i / 40; local x, y = 240 + rd(30 * sin(t * 14) * (1 - t * .5)), 218 - rd(t * 150)
    px(x, y, (i % 3 == 0) and "#fff6a8" or "#b8f8a8"); if i % 5 == 0 then px(x + 1, y, "#fff6a8"); px(x, y - 1, "#fff6a8") end end
  sparkle(240, 100); sparkle(196, 150); sparkle(290, 130)
  for i = 0, 22 do local x, y = hash(i, 61) % 480, 100 + hash(i, 63) % 140; px(x, y, "#ffe880"); px(x + 1, y, "#c8c060") end
  -- foreground leaf rocks and ferns
  for _, r in ipairs{ { 30, 262, 40, 14 }, { 454, 260, 44, 16 } } do local m = E(r[1], r[2], r[3], r[4]); rim(m, INK); ball(m, RP("#4a6a6c", { hi = "#7aa0a0" }), r[1], r[2], r[3], r[4]) end
  for _, t in ipairs{ { 70, 252 }, { 400, 254 }, { 150, 264 }, { 330, 266 } } do tuft(t[1], t[2], "#7cc878", "#3c8a58") end
  mush(60, 248, 2.6, RP("#f06a4a", { hi = "#ffa070" })); mush(424, 252, 2.2, RP("#d8486a", { hi = "#ff8aa0" }))
end

pics["wonder-flamingo-shallows"] = function()
  c:stripes(0, 124, { "#f2a0a8", "#f6b4ae", "#f8c8b4", "#fbdcbc", "#fdecc8", "#fff4d8" }, { 3, 3, 3, 3, 3, 3 })
  cloudpuff(50, 44, 70, "#ffe0d0", "#f2a8b0"); cloudpuff(340, 30, 90, "#ffe0d0", "#f2a8b0"); cloudpuff(210, 64, 50, "#fff0dc", "#f6b8b4")
  fm(E(240, 118, 36, 36):clip(R(0, 0, 479, 120)), "#fff0b8")
  local sun = E(240, 120, 34, 34):clip(R(0, 0, 479, 121)); fm(sun, "#ffe8a0"); fm(E(240, 120, 24, 24):clip(R(0, 0, 479, 121)), "#fff6c8")
  hills(112, 4, 50, "#c8a0b8", 1, 130); hills(120, 3, 30, "#b08aa8", 4, 134)
  local function acacia(x, y, s) fm(R(x - 1, y - rd(10 * s), x, y), "#6a4a68"); fm(E(x, y - rd(12 * s), rd(18 * s), rd(3 * s)), "#6a4a68"); fm(E(x - rd(5*s), y - rd(15*s), rd(9*s), rd(2*s)), "#6a4a68") end
  acacia(70, 128, 1.2); acacia(400, 128, 1); acacia(150, 128, .7); acacia(330, 128, .8)
  -- water bands (shallows) with a pink tint and horizon
  c:stripes(128, 269, { "#e8a0b8", "#e496b6", "#d88ab4", "#c880b0", "#b878b0", "#a070a8" }, { 2, 2, 3, 3, 3, 3 })
  for i = 0, 140 do local y = 130 + (i * 53) % 138; local x = hash(i, 71) % 480; local l = 4 + hash(i, 73) % 12
    for k = 0, l do px(x + k, y, (y < 190) and "#ffd0d0" or "#d8a8d0") end end
  -- sun glitter column
  for y = 130, 200, 3 do local w = 4 + (y - 130) // 4; for k = -w, w do if (hash(k, y) % 3 == 0) then px(240 + k, y, "#fff0b8") end end end
  -- distant flocks
  for r = 0, 3 do for i = 0, 11 do local x = 20 + i * 40 + hash(i, r) % 20 + r * 11; local y = 142 + r * 12; flamingo(x, y, .45 + r * .12, (i % 2 == 0) and 1 or -1) end end
  -- mid flamingos
  flamingo(90, 214, 1.1, 1, { curl = .3 }); flamingo(130, 224, 1.0, -1, { one = true }); flamingo(350, 216, 1.1, -1, { curl = .5 }); flamingo(392, 226, 1.0, 1)
  -- reflections of the big ones, ripples
  local function refl(x, y, w) for k = 0, 8 do for xx = x - w + k, x + w - k do if (xx + k) % 2 == 0 then px(xx, y + 3 + k * 2, "#f4a8c0") end end end end
  refl(240, 226, 24); refl(90, 216, 8); refl(350, 218, 8)
  -- the heroine: a big central flamingo, wings half spread
  local x, y, s = 240, 236, 2.3
  flamingo(x, y, s, 1, { curl = 0 })
  local wing = poly{ { 226, 190 }, { 196, 178 }, { 180, 196 }, { 196, 204 }, { 212, 206 }, { 232, 204 } }; rim(wing, INK); fm(wing, "#f08aa4")
  wing:each(function(px_, py_) if (px_ - py_) % 6 == 0 then px(px_, py_, "#ffb0c0") elseif py_ > 198 then px(px_, py_, "#b8446a") end end)
  px(184, 196, INK); px(188, 200, INK)
  -- her flock-mate facing her
  flamingo(300, 238, 1.7, -1, { curl = 1.2 })
  -- heart of necks: ripples around feet
  for k = 1, 3 do local rr = E(240, 238, 18 + k * 12, 3 + k * 2):copy():cut(E(240, 238, 17 + k * 12, 2 + k * 2)); rr:each(function(xx, yy) if (xx + k) % 2 == 0 then px(xx, yy, "#fff0e0") end end) end
  -- quirk: a grey chick in the shallows wearing a feather
  obj(160, 250, 6, 5, RP("#b8a8b0", { hi = "#e0d4d8" })); obj(166, 243, 4, 4, RP("#b8a8b0", { hi = "#e0d4d8" })); px(168, 242, INK); px(171, 244, "#f0a830"); px(172, 244, "#f0a830")
  for i = 0, 4 do px(164 - i // 2, 238 - i, "#f06a8a") end
  px(158, 255, "#8a6a7a"); px(163, 255, "#8a6a7a")
  -- reeds and sandbar
  c:terrain(function(x) return 258 + 3 * sin(x / 30) end, "#f4d8a8", 269, 0, 479)
  for i = 0, 60 do local x, y = hash(i, 81) % 480, 260 + hash(i, 83) % 9; px(x, y, "#d8b078") end
  for _, rx in ipairs{ 20, 38, 440, 462 } do for k = 0, 4 do local h = 36 + hash(rx, k) % 20; local x0 = rx + k * 3
    for y = 0, h do px(x0 + rd(y / 14 * (k - 2)), 262 - y, (y % 5 == 0) and "#c8d078" or "#7aa058") end
    fm(R(x0 + rd(h / 14 * (k - 2)) - 1, 262 - h - 5, x0 + rd(h / 14 * (k - 2)) + 1, 262 - h), "#8a5a3c") end end
end

pics["wonder-goat-path-vineyards"] = function()
  c:stripes(0, 120, { "#8ec8e8", "#a8d8ee", "#c4e6f0", "#e0f0e8", "#f8f0d0" }, { 3, 3, 3, 3, 3 })
  cloudpuff(60, 44, 70, P.cream, "#c8e0f0"); cloudpuff(330, 36, 80, P.cream, "#c8e0f0"); cloudpuff(210, 66, 40, P.cream, "#d0e4f0")
  hills(118, 8, 45, "#a8b8a0", 2, 160)
  hills(134, 10, 52, "#8aa878", 0, 200)
  -- terraces: warm ground bands with vine rows
  local ter = { { 150, "#b8a05a", "#9a8444" }, { 176, "#a89050", "#8a7640" }, { 204, "#98804a", "#7c6a3c" }, { 236, "#88703e", "#6a5a34" } }
  for i, t in ipairs(ter) do
    c:terrain(function(x) return t[1] + 3 * sin(x / (50 + i * 8) + i) end, t[2], 269, 0, 479)
    for x = 0, 479 do local y = rd(t[1] + 3 * sin(x / (50 + i * 8) + i)); px(x, y, "#d8c47c"); px(x, y + 1, t[3]) end
    -- vines on the terrace
    for x = 4, 476, 11 do local y = rd(t[1] + 3 * sin(x / (50 + i * 8) + i)) + 8 + (i * 2)
      if abs(x - 240) > 28 or y < 186 then
        local v = E(x, y, 6, 4); rim(v, INK); ball(v, RP("#4a8a3c", { hi = "#8cc860" }), x, y, 6, 4)
        px(x - 2, y + 4, "#7a4a8a"); px(x - 1, y + 5, "#9a5aa8"); px(x + 2, y + 4, "#7a4a8a"); px(x + 3, y + 5, "#9a5aa8") end end
  end
  -- winding path down the middle
  local path = poly{ { 232, 150 }, { 252, 150 }, { 262, 176 }, { 300, 204 }, { 330, 236 }, { 340, 269 }, { 140, 269 }, { 190, 236 }, { 222, 204 }, { 224, 176 } }
  fm(path, "#ecd8a0"); path:each(function(x, y) if hash(x, y) > 910 then px(x, y, "#c8a870") elseif hash(x, y + 3) > 960 then px(x, y, "#f8ecc0") end end)
  for y = 150, 269 do local m = HP.mask(); end
  rim(path, "#8a6a40")
  -- farmhouse + cypress up the hill
  local hs = R(60, 112, 98, 134); rim(hs, INK); flat(hs, RP("#f4e4c4", { shade = "#d0b890" }))
  local rf = poly{ { 54, 114 }, { 79, 94 }, { 104, 114 } }; rim(rf, INK); flat(rf, RP("#d0503c", { hi = "#f08a60" }))
  fm(R(74, 120, 82, 134), "#6a3c2c"); fm(R(64, 118, 69, 124), "#8ab8d8"); fm(R(90, 118, 94, 124), "#8ab8d8")
  for _, x in ipairs{ 110, 118, 392, 402 } do local cy = poly{ { x - 5, 134 }, { x, 92 }, { x + 5, 134 } }; rim(cy, INK); fm(cy, "#2c6a48"); cy:each(function(xx, yy) if xx < x - 1 and hash(xx, yy) > 500 then px(xx, yy, "#4a9a5c") end end) end
  -- ripe grape pergola frame framing the path
  for _, x in ipairs{ 126, 354 } do fm(R(x, 160, x + 3, 236), INK); fm(R(x + 1, 160, x + 2, 236), "#8a5a3c") end
  fm(R(126, 156, 354, 160), INK); fm(R(127, 157, 353, 158), "#8a5a3c")
  for x = 130, 350, 6 do local len = 5 + hash(x, 5) % 8; fm(R(x, 160, x + 1, 160 + len), "#5aa04a"); if x % 12 == 0 then fm(E(x, 160 + len + 3, 3, 4), "#7a4a8a"); px(x - 1, 160 + len + 2, "#b080c0"); rim(E(x, 160 + len + 3, 3, 4), INK) end end
  -- the goat of the path: hero centred, chewing a grape cluster (quirk)
  fm(E(246, 241, 26, 4), "#a88858")
  local hx0, hy0 = goat(236, 238, 2.0, 1)
  fm(E(hx0 + 14, hy0 + 8, 3, 4), "#7a4a8a"); px(hx0 + 13, hy0 + 6, "#b080c0"); px(hx0 + 14, hy0 + 11, "#5a2a6a")
  -- small goats on upper terraces
  goat(120, 192, .7, 1); goat(370, 218, .8, -1); goat(176, 172, .5, 1)
  -- baskets of grapes in the foreground
  for _, b in ipairs{ { 60, 256 }, { 94, 262 }, { 410, 258 } } do
    local m = poly{ { b[1] - 18, b[2] - 12 }, { b[1] + 18, b[2] - 12 }, { b[1] + 14, b[2] + 8 }, { b[1] - 14, b[2] + 8 } }; rim(m, INK); flat(m, RP("#b88a50", { hi = "#e0b878" }))
    for y = b[2] - 8, b[2] + 6, 4 do for x = b[1] - 14, b[1] + 14 do if m:has(x, y) then px(x, y, "#7a5a34") end end end
    for k = 0, 8 do local gx, gy = b[1] - 14 + k * 3.5 + (k % 2), b[2] - 15 - (k % 3); local g = E(rd(gx), rd(gy), 4, 4); rim(g, INK); ball(g, RP("#7a4a9a", { hi = "#c090d8" }), rd(gx), rd(gy), 4, 4) end end
  for _, t in ipairs{ { 20, 262 }, { 450, 266 }, { 300, 262 } } do tuft(t[1], t[2], "#9acc68", "#5a9a44") end
end

pics["wonder-gorilla-glade"] = function()
  c:stripes(0, 150, { "#b8e0a0", "#a0d498", "#88c890", "#70b888", "#5aa880", "#4a9878" }, { 3, 3, 3, 3, 3, 3 })
  for i = 0, 16 do local x = i * 30 + hash(i, 3) % 12; local w = 5 + hash(i, 5) % 5; fm(R(x, 0, x + w, 150), "#3c7a5c"); fm(R(x, 0, x, 150), "#5a9a70") end
  hills(130, 5, 40, "#58a068", 1, 200)
  -- god rays
  for _, r in ipairs{ { 90, 160 }, { 200, 120 }, { 320, 150 }, { 420, 120 } } do
    local m = poly{ { r[1], 0 }, { r[1] + 28, 0 }, { r[1] + 28 + r[2] * .35, 200 }, { r[1] + r[2] * .35 - 10, 200 } }; lightOver(m, "#fff6b8", .45, r[1]) end
  c:terrain(function(x) return 168 + 4 * sin(x / 60) end, "#68b050", 269, 0, 479)
  c:terrain(function(x) return 196 + 3 * sin(x / 45 + 2) end, "#58a048", 269, 0, 479)
  c:terrain(function(x) return 232 + 3 * sin(x / 38) end, "#4a9040", 269, 0, 479)
  for i = 1, 140 do local x, y = hash(i, 91) % 480, 170 + hash(i, 93) % 98; px(x, y, (i % 3 == 0) and "#88c860" or "#3a7a38") end
  -- fruit trees
  local function ftree(x, y, s)
    local tr = R(x - rd(6 * s), y - rd(70 * s), x + rd(6 * s), y); rim(tr, INK); flat(tr, RP("#8a5a3c", { hi = "#c08a58" }))
    for _, o in ipairs{ { 0, -86, 34, 22 }, { -28, -72, 24, 16 }, { 28, -72, 24, 16 }, { 0, -66, 30, 14 } } do
      local cx, cy = x + rd(o[1] * s), y + rd(o[2] * s); obj(cx, cy, rd(o[3] * s), rd(o[4] * s), RP("#3c9a4c", { hi = "#90d060" })) end
    for i = 0, 7 do local fx, fy = x + rd((hash(i, 5) % 56 - 28) * s), y + rd(-(70 + hash(i, 7) % 28) * s); local f = E(fx, fy, 3, 3); rim(f, INK); ball(f, RP("#f08a3c", { hi = "#ffc070" }), fx, fy, 3, 3) end
  end
  ftree(70, 214, 1.1); ftree(410, 218, 1.1); ftree(160, 188, .7); ftree(330, 190, .7)
  -- the silverback
  local FUR = RP("#5a4c68", { hi = "#8a7c98", shade = "#3a2e4a", deep = "#241c32" })
  fm(E(240, 250, 70, 8), "#3a7a34")
  obj(205, 238, 22, 14, FUR); obj(275, 238, 22, 14, FUR)       -- feet/legs
  local body = E(240, 188, 66, 56); rim(body, INK); ball(body, FUR, 240, 188, 66, 56)
  local arms = { { 184, 190, -1 }, { 296, 190, 1 } }
  for _, a in ipairs(arms) do
    local am = E(a[1] + a[3] * 4, a[2], 22, 40); rim(am, INK); ball(am, FUR, a[1] + a[3] * 4, a[2], 22, 40)
    local fist = E(a[1] + a[3] * 10, 232, 15, 11); rim(fist, INK); ball(fist, FUR, a[1] + a[3] * 10, 232, 15, 11)
    for k = -1, 1 do px(a[1] + a[3] * 10 + k * 4, 234, "#241c32") end end
  local sad = E(240, 154, 52, 22):clip(R(180, 134, 300, 168)); fm(sad, "#a8a4b8")  -- silver saddle
  sad:each(function(x, y) local l = -(((x - 240) / 52) * .5 + ((y - 154) / 22) * .8); px(x, y, l > .45 and "#d8d4e4" or (l > -.2 and "#a8a4b8" or "#7c7894")) end)
  local chest = E(240, 196, 34, 30); fm(chest, FUR.shade); chest:each(function(x, y) if (x + y) % 5 == 0 then px(x, y, FUR.deep) end end)
  fm(E(240, 192, 28, 24), FUR.base); px(226, 184, FUR.hi); px(227, 184, FUR.hi)
  -- head
  local hd = E(240, 128, 28, 26); rim(hd, INK); ball(hd, FUR, 240, 128, 28, 26)
  local crest = E(240, 108, 18, 9); rim(crest, INK); ball(crest, FUR, 240, 108, 18, 9)
  fm(R(220, 120, 260, 126), FUR.deep)            -- brow ridge
  local face = E(240, 134, 18, 15); fm(face, "#6a5a68"); fm(E(239, 133, 16, 13), "#8a7078"); fm(E(240, 142, 11, 7), "#a8888c")
  for _, ex in ipairs{ 230, 248 } do fm(R(ex, 127, ex + 3, 130), "#c8602c"); px(ex + 1, 128, INK); px(ex, 127, P.cream) end
  px(236, 140, INK); px(244, 140, INK); fm(R(237, 146, 243, 146), "#4a3040")
  -- fruit pile at his feet + quirk: baby with a leaf hat on his shoulder
  for i, f in ipairs{ { 214, 252 }, { 228, 258 }, { 244, 254 }, { 262, 258 }, { 276, 252 }, { 236, 248 } } do local g = E(f[1], f[2], 5, 5); rim(g, INK); ball(g, RP((i % 2 == 0) and "#f08a3c" or "#e05a4c", { hi = "#ffc070" }), f[1], f[2], 5, 5); px(f[1], f[2] - 6, "#3c9a4c") end
  local bb = obj(310, 244, 14, 12, FUR); obj(310, 226, 11, 10, FUR)
  fm(E(310, 230, 6, 4), "#8a7078"); px(306, 224, P.cream); px(314, 224, P.cream); px(306, 225, INK); px(314, 225, INK); px(310, 229, INK)
  local leaf = poly{ { 298, 218 }, { 322, 218 }, { 310, 204 } }; rim(leaf, INK); flat(leaf, RP("#5ab84c", { hi = "#a8e070" })); for y = 206, 217 do px(310, y, "#2c7a3c") end
  -- second young one at left + ferns
  obj(150, 248, 14, 11, FUR); obj(150, 232, 10, 9, FUR); fm(E(150, 235, 5, 3), "#8a7078"); px(147, 230, P.cream); px(153, 230, P.cream); px(147, 231, INK); px(153, 231, INK)
  fm(R(144, 242, 156, 244), "#241c32")
  local function fern(x, y, dir) for i = -4, 4 do local len = 20 - abs(i) * 2; for t = 0, len do local xx, yy = x + rd(t * cos(-1.2 + i * .3) * dir), y - rd(t * -sin(-1.2 + i * .3) * .7) - floor(t * .35); px(xx, yy, (t % 3 == 0) and "#a0e068" or "#3c9a48") end end end
  fern(30, 262, 1); fern(448, 264, -1); fern(104, 266, 1); fern(380, 266, -1)
  sparkle(340, 70)
end

pics["wonder-lantern-festival-river"] = function()
  c:stripes(0, 150, { "#161640", "#1e1c52", "#2a2262", "#3a2a72", "#52347c", "#7a4684" }, { 3, 3, 3, 3, 3, 3 })
  stars(60, 0, 80, 12, "#fff0d0")
  local mn = E(100, 44, 16, 16); fm(mn, "#fff0c0"); ball(mn, RP("#fff0c0", { hi = "#fffbe8", shade = "#e8d8a8", deep = "#d0c090" }), 100, 44, 16, 16)
  hills(120, 10, 60, "#3a2c66", 1, 170); hills(138, 8, 45, "#2c2458", 3, 200)
  -- pagoda on the far hill
  local function tier(cx, y, w, col) local m = poly{ { cx - w - 6, y }, { cx - w, y - 6 }, { cx + w, y - 6 }, { cx + w + 6, y } }; rim(m, INK); flat(m, RP(col, { hi = mix(col, "#fff0c8", .4) })); end
  for i = 0, 3 do local y = 132 - i * 16; local w = 16 - i * 3
    local b = R(240 - w + 2, y - 12, 240 + w - 2, y - 5); rim(b, INK); flat(b, RP("#c8584a", { hi = "#f08a6a" })); fm(R(237, y - 11, 243, y - 6), "#ffd070")
    tier(240, y - 12, w, "#7a3a5a") end
  fm(R(239, 56, 241, 62), INK); px(240, 54, "#ffd070")
  -- river: widening perspective
  local riv = poly{ { 226, 148 }, { 254, 148 }, { 330, 200 }, { 479, 240 }, { 479, 269 }, { 0, 269 }, { 0, 240 }, { 150, 200 } }
  fm(riv, "#2a4a8a")
  riv:each(function(x, y) local t = (y - 148) / 121; px(x, y, t < .2 and "#2c3a7c" or (t < .5 and "#2a4a8a" or (t < .8 and "#2a5a98" or "#2c68a0"))) end)
  -- banks with trees
  local lb = poly{ { 0, 168 }, { 140, 168 }, { 226, 148 }, { 150, 200 }, { 0, 240 } }; fm(lb, "#1c3a4c")
  local rb = poly{ { 479, 168 }, { 340, 168 }, { 254, 148 }, { 330, 200 }, { 479, 240 } }; fm(rb, "#1c3a4c")
  fm(R(0, 148, 479, 150), "#2c2458")
  local function tree(x, y, s) fm(R(x - 1, y - rd(20 * s), x + 1, y), "#2a1c30"); obj(x, y - rd(28 * s), rd(14 * s), rd(12 * s), RP("#2c6a58", { hi = "#4a9a78" })) end
  tree(40, 196, 1.4); tree(110, 190, 1); tree(430, 196, 1.5); tree(360, 180, .9); tree(190, 176, .6); tree(292, 176, .6)
  -- stone bridge midway
  local br = poly{ { 120, 166 }, { 360, 166 }, { 350, 176 }, { 130, 176 } }; rim(br, INK); flat(br, RP("#8a7aa8", { hi = "#b8a8d0" }))
  fm(E(240, 176, 22, 14):clip(R(200, 164, 280, 178)), "#2c3a7c")
  for x = 130, 350, 8 do fm(R(x, 160, x + 2, 166), "#a898c0"); px(x, 160, "#fff0d0") end
  for x = 130, 350 do px(x, 160 + ((x % 8 < 3) and 0 or 1), INK) end
  -- strings of lanterns
  local function stringl(x0, y0, x1, y1, n)
    for i = 0, n do local t = i / n; local x, y = rd(x0 + (x1 - x0) * t), rd(y0 + (y1 - y0) * t + 18 * sin(t * pi)); px(x, y, INK)
      if i > 0 and i < n then lantern(x, y + 8, 4, 5, (i % 3 == 0) and "#f2603c" or ((i % 3 == 1) and "#f2b83c" or "#e0508a")) end end
    for k = 0, 40 do local t = k / 40; px(rd(x0 + (x1 - x0) * t), rd(y0 + (y1 - y0) * t + 18 * sin(t * pi)), INK) end end
  stringl(0, 40, 200, 70, 6); stringl(479, 40, 280, 70, 6)
  -- floating lanterns on the river with reflections
  local cols = { "#f2603c", "#f2b83c", "#e0508a", "#ffd070", "#f28a3c" }
  for i = 0, 26 do
    local y = 156 + (hash(i, 5) % 100); local t = (y - 148) / 121
    local half = 14 + t * 190; local x = 240 + rd((hash(i, 7) % 200 / 100 - 1) * half * .8)
    local s = 4 + rd(t * 5); local col = cols[1 + i % 5]
    for k = 1, 4 do px(x, y + s + 2 + k * 2, mix(col, "#2a4a8a", .5)); px(x + 1, y + s + 3 + k * 2, mix(col, "#2a4a8a", .6)) end
    fm(E(x, y + s, s + 3, 2), "#1c2a5c"); lantern(x, y, s, s - 1, col)
  end
  -- hero: a big lantern raft in the foreground
  fm(E(240, 244, 56, 8), "#173060")
  local raft = poly{ { 190, 244 }, { 290, 244 }, { 282, 256 }, { 198, 256 } }; rim(raft, INK); flat(raft, RP("#a8704c", { hi = "#d8a070" }))
  for x = 198, 282, 10 do for y = 245, 255 do px(x, y, "#6a4a38") end end
  lantern(240, 218, 18, 20, "#f2603c")
  fm(R(231, 216, 249, 218), "#ffd070"); fm(R(237, 208, 243, 226), "#fff0b0")
  lantern(206, 232, 9, 10, "#f2b83c"); lantern(274, 232, 9, 10, "#e0508a")
  sparkle(240, 190); sparkle(180, 210); sparkle(300, 204)
  -- quirk: a frog on a lily pad holding a tiny lantern
  fm(E(398, 252, 14, 3), "#2e8a50"); rim(E(398, 252, 14, 3), INK); fm(E(398, 252, 13, 2), "#48b060")
  obj(398, 246, 6, 5, RP("#6cc060")); px(395, 243, P.cream); px(401, 243, P.cream); px(395, 243, INK); px(401, 243, INK)
  fm(R(403, 238, 403, 246), INK); lantern(406, 238, 3, 4, "#ffd070")
  for _, f in ipairs{ { 20, 262 }, { 450, 266 } } do tuft(f[1], f[2], "#3c8a68", "#2a6a50") end
end

---------------------------------------------------------------- run
local only = app.params.name
local order = { "wonder-cedar-sanctuary", "wonder-cenote-of-echoes", "wonder-coffee-ceremony-hut", "wonder-fairy-ring-clearing", "wonder-flamingo-shallows", "wonder-goat-path-vineyards", "wonder-gorilla-glade", "wonder-lantern-festival-river" }
for _, n in ipairs(order) do
  if not only or only == "all" or only == n then
    c = HP.canvas{ w = 480, h = 270, scale = 1, name = n }
    pics[n]()
    c:hem(2); c:hem(267)
    c:save{ aseprite = d .. "/out/" .. n .. ".aseprite", png = d .. "/out/" .. n .. ".png", scale = 1 }
  end
end
