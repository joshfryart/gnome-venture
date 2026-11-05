-- finish4/b: twelve polished WONDER/LAIR pictures. Param name=<picture> (or all)
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local V3 = d .. "/../.."
local HP = dofile(V3 .. "/lib/hp.lua")
local GX = dofile(V3 .. "/gather/gx.lua")
local H = GX.X.hash
local floor, max, min, sin, cos, sqrt, abs, pi = math.floor, math.max, math.min, math.sin, math.cos, math.sqrt, math.abs, math.pi
local INK, CREAM, GOLD = "#2b1c26", "#fff1cf", "#f2b84a"
local mix = GX.mix
local function RR(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end

local c
local function R(x0, y0, x1, y1) return c:rect(floor(x0), floor(y0), floor(x1), floor(y1)) end
local function P(x, y, h) c:px(floor(x), floor(y), h) end
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
local function PL(pts) local t = {} for i, p in ipairs(pts) do t[i] = { floor(p[1] + .5), floor(p[2] + .5) } end return HP.poly(t) end
-- spline brush; optional out table collects samples
local function spline(pts, r0, r1, rf, steps, out)
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
    if out then out[#out + 1] = { x, y, r } end
  end
  return m
end
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
local function ridge(fn, col, ybot)
  for x = 0, 479 do for y = floor(fn(x)), ybot do P(x, y, col) end end
end
local function tint(m, col, t) m:each(function(x, y) local o = c:get(x, y); if o then P(x, y, mix(o, col, t)) end end) end
local function glow(cx, cy, r, col, t)
  for k = 3, 1, -1 do tint(E(cx, cy, r * k / 3 * 1.3, r * k / 3 * 1.3), col, t * (4 - k) / 3 * .9) end
end
local function foot() c:hem(2, 0, 479); c:hem(267, 0, 479) end
local function tuft(x, y, Rm) GX.tuft(c, x, y, Rm) end
local function cloudp(cx, cy, w, col, shade)
  local m = HP.mask(); for i = 0, 3 do disc(m, cx + i * w / 3 - w / 2, cy - (i % 2) * 2, w / 4, 5) end
  fill(m, col); fill(m:shift(0, 3):cut(m), shade)
end
local function ln(x0, y0, x1, y1, col, th)
  th = th or 1
  local n = max(abs(x1 - x0), abs(y1 - y0), 1)
  for i = 0, n do
    local x, y = floor(x0 + (x1 - x0) * i / n + .5), floor(y0 + (y1 - y0) * i / n + .5)
    for a = 0, th - 1 do for b = 0, th - 1 do P(x + a, y + b, col) end end
  end
end
local GRASS = RR("#9ad45a", "#5fae48", "#3f8442", "#2a5c3c")
local PICS, ORDER = {}, {}
local function pic(name, fn) PICS[name] = fn; ORDER[#ORDER + 1] = name end
local function mk() return HP.mask() end
local function rough(m, s) return GX.rough(m, s, 1) end
local function litL(m, Rm, seed, o)
  o = o or {}
  o.R = o.R or 8; o.tex = o.tex or .4; o.sc = o.sc or 4; o.seed = seed; if o.rimlight == nil then o.rimlight = true end; o.amb = o.amb or .25
  return GX.lit(c, m, GX.ramp6(Rm), o)
end
local function halo(cx, cy, r, ry, t, seed, col)
  local m = rough(disc(mk(), cx, cy, r, ry), seed)
  m:each(function(x, y) local o = c:get(x, y); if o then P(x, y, mix(o, col, t)) end end)
end
local function pine(x, by, h, Rm, SN, seed)
  local tr = mk(); for y = by - 8, by do for xx = x - 2, x + 2 do tr:set(xx, y) end end
  litL(tr, { hi = "#a8704a", base = "#6e4a48", shade = "#4a3040", deep = "#2e2034" }, seed, { R = 3 })
  for i = 4, 1, -1 do
    local yt = by - h + (i - 1) * floor(h / 5)
    local th, w = floor(h / 3.3), 5 + i * floor(h / 11)
    local yb = yt + th
    local m = rough(PL({ { x, yt }, { x + w, yb }, { x + floor(w * .5), yb - 3 }, { x, yb }, { x - floor(w * .5), yb - 3 }, { x - w, yb } }), seed + i)
    litL(m, Rm, seed + i, { R = 6, tex = .5, sc = 3 })
    m:each(function(xx, yy) if not m:has(xx, yy - 2) and not m:has(xx - 1, yy - 1) or (not m:has(xx, yy - 1) and (xx + yy) % 2 == 0 and xx < x + w * .4) then P(xx, yy, SN[6]) elseif not m:has(xx, yy - 3) then P(xx, yy, SN[5]) end end)
  end
end
local function layer(peaks, cap, Rm, seed, haze, ybot, hz)
  local R6s = GX.ramp6(Rm)
  local function rg(x)
    local best = cap
    for _, p in ipairs(peaks) do best = min(best, p[2] + abs(x - p[1]) * p[3]) end
    return floor(best + (GX.vn(x, 0, 5, seed) - .5) * 6)
  end
  for x = 0, 479 do
    local top = rg(x); local sl = rg(x + 3) - rg(x - 3)
    for y = top, ybot do
      local v = .5 - sl * .04 + (GX.vn(x, y, 6, seed + 1) - .5) * .5
      if y - top < 2 and sl < 0 then v = .9 end
      P(x, y, mix(R6s[GX.idx(v)], hz, min(1, (y - top) / max(1, ybot - top)) * haze))
    end
  end
end
local function eyeL(x, y, rx, ry, col)
  local m = disc(mk(), x, y, rx, ry); local Rr = GX.ramp6(col)
  m:each(function(xx, yy) local t = ((xx - x) / rx) ^ 2 + ((yy - y) / ry) ^ 2; P(xx, yy, t < .25 and Rr[6] or (t < .6 and Rr[5] or Rr[4])) end)
  P(x, y, "#1a1020"); P(x, y + 1, "#1a1020"); P(x - floor(rx / 2), y - floor(ry / 2), "#fffbe0")
end
-- voronoi cells inside a mask: fn(x,y,cx,cy,id,d1,gap) draws
local function vor(m, cw, ch, seed, fn, ox, oy)
  ox, oy = ox or 0, oy or 0
  m:each(function(x, y)
    local gx, gy = floor((x - ox) / cw), floor((y - oy) / ch)
    local d1, d2, bx, by = 1e9, 1e9, 0, 0
    local qx, qy
    for j = -1, 1 do for i = -1, 1 do
      local cx, cy = gx + i, gy + j
      local px_ = (cx + .2 + H(cx, cy, seed) * .6) * cw + ox
      local py_ = (cy + .2 + H(cx, cy, seed + 1) * .6) * ch + oy
      local dd = sqrt((x - px_) ^ 2 + ((y - py_) * cw / ch) ^ 2)
      if dd < d1 then d2 = d1; d1 = dd; bx, by, qx, qy = cx, cy, px_, py_ elseif dd < d2 then d2 = dd end
    end end
    fn(x, y, qx, qy, H(bx, by, seed + 2), d1, d2 - d1)
  end)
end
local function shadeTo(x, y, col, t) local o = c:get(x, y); if o then P(x, y, mix(o, col, t)) end end
-- limb through points
local function limb(pts, r0, r1, steps) return spline(pts, r0, r1, nil, steps or 8) end
local function dither(m, col, t, par) m:each(function(x, y) if (x + y) % 2 == (par or 0) then shadeTo(x, y, col, t) end end) end
local function dust(cx, cy, rx, ry, col, seed)
  local m = rough(disc(mk(), cx, cy, rx, ry), seed)
  m:each(function(x, y) if (x + y) % 2 == 0 or GX.vn(x, y, 4, seed) > .6 then shadeTo(x, y, col, .55) end end)
end

---------------------------------------------------------------- 1 great migration
local function gnu(x, y, s, d, ang, Rm, dark, seed)
  local function p(a, b) return { x + d * a * s, y + b * s } end
  local function pl(list) local t = {} for i, q in ipairs(list) do t[i] = p(q[1], q[2]) end return PL(t) end
  local lr = max(.7, 1.5 * s)
  local function leg(pts, r) local q = {} for i, v in ipairs(pts) do q[i] = p(v[1], v[2]) end return limb(q, r, r * .62, 6) end
  local far = leg({ { 14, -16 }, { 15, -8 }, { 14, -3 }, { 14.5, 0 } }, lr * .9):add(leg({ { -12, -16 }, { -9, -11 }, { -13, -6 }, { -11.5, 0 } }, lr * .9))
  local near = leg({ { 9, -16 }, { 10.5, -8 }, { 9, -3 }, { 9.5, 0 } }, lr):add(leg({ { -16, -17 }, { -13, -11 }, { -18, -6 }, { -16.5, 0 } }, lr * 1.1))
  local body = pl({ { 5, -35 }, { 11, -33.5 }, { 16, -27 }, { 14, -18 }, { 9, -14 }, { -1, -13 }, { -9, -14 }, { -17, -17 }, { -20, -23 }, { -18, -28 }, { -9, -31 }, { -1, -33 } })
  local neck = limb({ p(8, -27), p(14, -27), p(19, -25) }, 6.5 * s, 5 * s)
  -- head: rotated polygon around the poll
  local hb = { 19, -27 - (ang or 0) * .0 }
  local ca, sa = cos((ang or 0)), sin((ang or 0))
  local function hp(a, b) local rx_ = a * ca - b * sa; local ry_ = a * sa + b * ca; return { x + d * (hb[1] + rx_) * s, y + (hb[2] + ry_) * s } end
  local function hpl(list) local t = {} for i, q in ipairs(list) do t[i] = hp(q[1], q[2]) end return PL(t) end
  local head = hpl({ { -2, -4 }, { 4, -5 }, { 11, -1 }, { 15, 3 }, { 15, 8 }, { 11, 10 }, { 5, 8 }, { 0, 5 }, { -3, 1 } })
  local horn = limb({ hp(1, -4), hp(1, -8), hp(5, -11), hp(7, -16) }, max(.6, .9 * s), max(.5, .5 * s), 8)
  local beard = hpl({ { 8, 9 }, { 11, 9 }, { 8, 16 }, { 5, 10 } })
  local mane = limb({ p(5, -35), p(11, -33), p(17, -29), p(20, -25) }, max(.8, 2.4 * s), max(.7, 1.6 * s), 8)
  local tail = limb({ p(-19, -25), p(-23, -19), p(-23, -11) }, max(.5, .7 * s), max(.5, .9 * s), 6)
  local tuft = disc(mk(), x + d * -23 * s, y - 9.5 * s, max(1, 1.8 * s), max(1.5, 3 * s))
  local all = body:copy():add(near):add(far):add(neck):add(head):add(horn):add(mane):add(tail)
  if s >= .8 then c:rim(all, INK) end
  local dk = dark
  if s >= 1.3 then
    lit(far, RR(dk.base, dk.shade, dk.deep, dk.deep), seed + 1, { R = 3, tex = .1, ink = false })
    lit(near, dk, seed + 2, { R = 3, tex = .2, ink = false })
    lit(body, Rm, seed + 3, { R = floor(9 * s), tex = .35, ink = false, sc = 3 })
    lit(neck, dk, seed + 4, { R = floor(4 * s), tex = .3, ink = false })
    lit(head, dk, seed + 5, { R = floor(4 * s), tex = .2, ink = false })
    -- vertical flank stripes, hide in shade
    body:each(function(xx, yy)
      local lx = (xx - x) / s * d
      if lx > -14 and lx < 9 and yy < y - 16 * s then
        local k = floor((lx + 20) / 2.6)
        if k % 2 == 0 and H(k, floor(yy / 5), seed) > .22 then shadeTo(xx, yy, dk.deep, .55) end
      end
    end)
  else
    fill(far, dk.shade); fill(near, dk.base); fill(body, Rm.base); fill(neck, dk.base); fill(head, dk.base)
    body:each(function(xx, yy) if not body:has(xx - d, yy - 1) then P(xx, yy, Rm.hi) elseif not body:has(xx, yy + 1) then P(xx, yy, Rm.shade) end end)
  end
  fill(mane, dk.deep); fill(tail, dk.deep); fill(tuft, dk.deep); fill(beard, dk.deep)
  fill(horn, "#e8d8b0")
  if s >= 1.3 then
    horn:each(function(xx, yy) if not horn:has(xx + d, yy + 1) then P(xx, yy, "#a88a6a") end end)
    c:rim(horn, INK)
    local e = hp(7, 1); P(e[1], e[2], "#ffe8a0"); P(e[1] + d, e[2], INK)
    local nz = hp(14, 6); P(nz[1], nz[2], INK); if s > 2 then P(nz[1], nz[2] + 1, INK) end
    -- hoof tips and knee marks
    local hf = { p(9.5, 0), p(14.5, 0), p(-11.5, 0), p(-16.5, 0) }
    for _, q in ipairs(hf) do fill(R(q[1] - lr * .6, q[2] - 1, q[1] + lr * .6, q[2]), INK) end
  else
    local e = hp(7, 1); P(e[1], e[2], "#ffe8a0")
  end
end
local function zebra(x, y, s, d, ang, seed)
  local function p(a, b) return { x + d * a * s, y + b * s } end
  local function pl(list) local t = {} for i, q in ipairs(list) do t[i] = p(q[1], q[2]) end return PL(t) end
  local lr = max(.7, 1.1 * s)
  local function leg(pts, r) local q = {} for i, v in ipairs(pts) do q[i] = p(v[1], v[2]) end return limb(q, r, r * .6, 6) end
  local legsF = leg({ { 12, -14 }, { 12.5, -8 }, { 12, -3 }, { 12.5, 0 } }, lr):add(leg({ { -12, -15 }, { -10, -10 }, { -14, -5 }, { -13, 0 } }, lr))
  local legsN = leg({ { 8, -14 }, { 9, -8 }, { 8, -3 }, { 8.5, 0 } }, lr):add(leg({ { -15, -16 }, { -13, -9 }, { -17, -5 }, { -16, 0 } }, lr * 1.1))
  local body = pl({ { 12, -30 }, { 15, -24 }, { 12, -16 }, { 3, -14 }, { -8, -15 }, { -16, -18 }, { -19, -25 }, { -15, -30 }, { -4, -30 } })
  local ca, sa = cos(ang or 0), sin(ang or 0)
  local hb = { 21, -42 }
  local function hp(a, b) return { x + d * (hb[1] + a * ca - b * sa) * s, y + (hb[2] + a * sa + b * ca) * s } end
  local function hpl(list) local t = {} for i, q in ipairs(list) do t[i] = hp(q[1], q[2]) end return PL(t) end
  local neck = limb({ p(9, -26), p(15, -34), p(20, -41) }, 6.2 * s, 3.6 * s, 8)
  local head = hpl({ { -2, -3 }, { 3, -4 }, { 9, 0 }, { 15, 5 }, { 15, 9 }, { 10, 9 }, { 4, 5 }, { -1, 3 } })
  local ear = hpl({ { -1, -3 }, { 0, -8 }, { 3, -3 } })
  local mane = limb({ p(10, -29), p(15, -37), p(20, -43) }, max(.7, 1.4 * s), max(.6, 1 * s), 6)
  local tail = limb({ p(-18, -26), p(-23, -19), p(-22, -8) }, max(.5, .7 * s), max(.5, 1.1 * s), 6)
  local all = body:copy():add(legsN):add(legsF):add(neck):add(head):add(ear):add(tail):add(mane)
  if s >= .8 then c:rim(all, INK) end
  local ZW = RR("#fff1dc", "#e8d4bc", "#b89aa0", "#7e6678")
  local ZD = "#3c2e40"
  if s >= 1.2 then
    lit(legsF, ZW, seed + 1, { R = 3, tex = .1, ink = false }); lit(legsN, ZW, seed + 2, { R = 3, tex = .1, ink = false })
    lit(body, ZW, seed + 3, { R = floor(8 * s), tex = .2, ink = false }); lit(neck, ZW, seed + 4, { R = floor(3 * s), tex = .1, ink = false })
    lit(head, ZW, seed + 5, { R = floor(3 * s), tex = .1, ink = false })
  else
    fill(legsF, ZW.shade); fill(legsN, ZW.base); fill(body, ZW.base); fill(neck, ZW.base); fill(head, ZW.base)
  end
  all:each(function(xx, yy)
    local lx, ly = (xx - x) / s * d, (yy - y) / s
    local st
    if lx > 9 then st = floor((ly + lx * 1.1) / 2.4) % 2 == 0 -- neck slants
    elseif ly > -13 then st = floor((lx) / 2.3) % 2 == 0 and ly < -2 -- legs: rings
    else st = floor((lx + ly * .45) / 2.3) % 2 == 0 end
    if ly > -3 then st = floor(ly / 2) % 2 == 0 end
    if st then P(xx, yy, ZD) end
  end)
  fill(mane, ZD); fill(tail, ZD)
  local snout = hp(13, 7); fill(disc(mk(), snout[1], snout[2], max(1, 1.8 * s), max(1, 1.4 * s)), "#8a6a70")
  local e = hp(5, 0); P(e[1], e[2], INK)
end
pic("wonder-the-great-migration", function()
  GX.bands(c, 0, 160, { "#8a4a8c", "#c85a8c", "#e87a7c", "#ff9a6c", "#ffb868", "#ffd488", "#ffe8a8" }, 14, .1)
  for _, k in ipairs{ { 90, 40, 50 }, { 400, 34, 56 }, { 220, 66, 40 }, { 40, 84, 36 } } do cloudp(k[1], k[2], k[3], "#ffb890", "#d86a7c") end
  halo(310, 150, 120, 60, .25, 3, "#ffe0a0")
  fill(E(310, 150, 50, 50), "#ffb878"); fill(E(310, 150, 45, 45), "#ffd890"); fill(E(310, 150, 41, 41), "#fff4c0")
  GX.ground(c, function(x) return 150 end, RR("#f8d08a", "#d49a58", "#9a6a48", "#5a3a40"), 15, { top = .8, fall = .55, tex = .3 })
  ridge(function(x) return 146 + floor(2 * sin(x / 20)) end, "#c4705a", 152)
  for i = 0, 90 do P(floor(H(i, 1, 1) * 480), 154 + floor(H(i, 2, 1) * 110), "#ffe0a0") end
  -- acacia silhouettes with real flat canopies
  local function acacia(x, y, s)
    local tr = limb({ { x, y }, { x + 2 * s, y - 12 * s }, { x - 1 * s, y - 24 * s } }, 2 * s, 1.2 * s, 8); fill(tr, "#6a3a40")
    local can = rough(E(x, y - 27 * s, 24 * s, 5 * s):add(E(x - 12 * s, y - 24 * s, 12 * s, 4 * s)):add(E(x + 14 * s, y - 25 * s, 12 * s, 4 * s)), 9 + floor(x))
    lit(can, RR("#a8c060", "#5a8a3c", "#3a603a", "#24402e"), floor(x), { R = 5, tex = .5, sc = 3 })
  end
  acacia(60, 152, 2.2); acacia(430, 150, 1.6); acacia(160, 150, .9)
  local RM = RR("#b89484", "#8a6a78", "#604a62", "#40304a")
  local DK = RR("#7a6070", "#483848", "#33283a", "#241c2a")
  local ZB = 0
  local rows = { { 160, .36, 34 }, { 167, .46, 28 }, { 177, .62, 22 }, { 190, .85, 15 }, { 206, 1.2, 10 }, { 226, 1.75, 6 } }
  for ri, row in ipairs(rows) do
    local y, s, n = row[1], row[2], row[3]
    -- dust cloud behind each row
    for k = 0, 5 do dust(40 + k * 90 + ri * 13, y - 6 * s, 50 * s + 20, 6 + 4 * s, "#f0b080", ri * 9 + k) end
    for i = 0, n do
      local x = (i * 480 / n + floor(H(i, ri, 3) * 20) - 4 + ri * 17) % 500 - 10
      local haze = max(0, .5 - ri * .08)
      local hz = mix(RM.base, "#e8a070", haze + .1)
      local Rm = RR(mix(RM.hi, "#e8a070", haze), mix(RM.base, "#e8a070", haze), mix(RM.shade, "#e8a070", haze * .8), RM.deep)
      local Dm = RR(mix(DK.base, "#e8a070", haze), mix(DK.base, "#e8a070", haze * .8), mix(DK.shade, "#e8a070", haze * .6), DK.deep)
      local graze = H(i, ri, 4) < .35
      local fx = floor(x)
      if ri >= 5 and fx > 120 and fx < 400 then
      elseif H(i, ri, 6) < .1 then zebra(fx, y, s * 1.02, H(i, ri, 7) < .5 and 1 or -1, graze and .9 or .15, 300 + i + ri * 20)
      else gnu(fx, y, s, H(i, ri, 7) < .5 and 1 or -1, graze and 1.0 or 0, Rm, Dm, 100 + i + ri * 20) end
    end
  end
  for i = 0, 40 do local x, y = floor(H(i, 5, 5) * 480), 190 + floor(H(i, 6, 5) * 70); fill(E(x, y, 4, 1), "#e8a070") end
  -- foreground: bull, calf, zebra
  fill(E(160, 266, 100, 5), "#9a6046")
  gnu(170, 266, 3.1, 1, 0, RM, DK, 7)
  gnu(300, 266, 1.7, 1, 1.1, RM, DK, 8)
  zebra(385, 266, 2.4, -1, .5, 9)
  for i = 0, 30 do dust(floor(H(i, 8, 8) * 470), 262 + floor(H(i, 9, 8) * 8), 12, 2, "#f0b080", i) end
  -- quirk: oxpecker bird in a red gnome hat on the bull's hump
  local bx, by = 170 + 5 * 3.1, 266 - 37 * 3.1
  local br = E(bx, by, 6, 5); c:rim(br, INK); fill(br, "#fff0d0")
  local hat = PL({ { bx - 5, by - 3 }, { bx, by - 14 }, { bx + 5, by - 3 } }); c:rim(hat, INK); fill(hat, "#e0443a")
  P(bx + 3, by, INK); P(bx + 7, by + 1, "#f0a030"); P(bx + 8, by + 1, "#f0a030")
  c:sparkle(430, 232)
end)

---------------------------------------------------------------- 2 grey wolf king
pic("lair-of-the-grey-wolf-king", function()
  GX.bands(c, 0, 190, { "#1c2048", "#2a3264", "#3a4880", "#50629a", "#7284ae", "#9aa4c0" }, 6, .2)
  stars(0, 110, 90, 4, { "#f0f0ff", "#c8d0f0" })
  local MX, MY = 250, 92
  halo(MX, MY, 136, 126, .1, 3, "#f4f4ff"); halo(MX, MY, 110, 104, .14, 4, "#f4f4ff"); halo(MX, MY, 94, 88, .2, 5, "#f4f4ff")
  local mn = rough(disc(mk(), MX, MY, 80, 80), 6)
  litL(mn, { hi = "#fffef4", base = "#f2f2fa", shade = "#d8dcf0", deep = "#b4bce0" }, 6, { R = 80, tex = .2, ink = false, rimlight = false, amb = .5 })
  for _, q in ipairs{ { 300, 60, 10 }, { 314, 108, 12 }, { 196, 128, 7 }, { 272, 34, 4 }, { 200, 52, 6 } } do disc(mk(), q[1], q[2], q[3], q[3]):each(function(x, y) P(x, y, "#d4d8f0") end) end
  layer({ { 60, 150, .6 }, { 190, 138, .8 }, { 330, 134, .7 }, { 450, 140, .7 } }, 170, { hi = "#b0b8d4", base = "#8490b8", shade = "#6874a4", deep = "#505c90" }, 11, .3, 220, "#a0a8c8")
  for _, q in ipairs{ { 20, 210, 60 }, { 52, 214, 46 }, { 100, 208, 56 }, { 380, 210, 52 }, { 420, 214, 64 }, { 460, 212, 48 }, { 340, 214, 36 }, { 140, 216, 34 } } do
    pine(q[1], q[2], q[3], { hi = "#5a8a8a", base = "#356a6c", shade = "#264a5c", deep = "#1c3246" }, GX.ramp6({ hi = "#f4f4ff", base = "#e4e8f4", shade = "#b0b8d8", deep = "#7c88b8" }), q[1])
  end
  GX.ground(c, function(x) return 222 + floor((GX.vn(x, 0, 30, 4) - .5) * 8) end, { hi = "#f8f8ff", base = "#d4d8f0", shade = "#9ca4d4", deep = "#6c78b4" }, 12, { top = .85, fall = .5, tex = .3 })
  -- spire
  local sp = rough(PL({ { 110, 236 }, { 140, 206 }, { 168, 190 }, { 190, 168 }, { 206, 158 }, { 296, 156 }, { 314, 170 }, { 330, 192 }, { 356, 210 }, { 380, 236 } }), 51)
  local RK = { hi = "#c4c0d4", base = "#8a86a4", shade = "#5a5478", deep = "#38304e" }
  litL(sp, RK, 52, { R = 26, tex = .6, sc = 4 })
  sp:each(function(x, y) if y < 164 and not sp:has(x, y - 2) then P(x, y, "#f4f4ff") end end)
  local den = rough(PL({ { 196, 236 }, { 196, 214 }, { 208, 198 }, { 238, 192 }, { 262, 202 }, { 272, 236 } }), 54); c:rim(den, INK)
  den:each(function(x, y) P(x, y, y > 218 and "#241830" or "#1b1223") end)
  local YE = { hi = "#fffbb0", base = "#ffd23c", shade = "#e0902c", deep = "#9a5a30" }
  eyeL(222, 212, 4, 3, YE); eyeL(244, 212, 4, 3, YE)
  for k = 0, 4 do P(226 + k * 4, 222, "#f4f4ff"); P(226 + k * 4, 223, "#f4f4ff") end
  -- the wolf king: head in profile, inside the moon disc, howling up and to the right
  local function W(pts) local t = {} for i, q in ipairs(pts) do t[i] = { MX + q[1] * 1.2, MY + q[2] * 1.2 } end return PL(t) end
  local upper = W({ { -30, 16 }, { -35, -4 }, { -31, -19 }, { -29, -25 }, { -35, -46 }, { -18, -33 }, { -14, -28 }, { -6, -28 }, { 3, -24 }, { 16, -34 }, { 30, -43 }, { 36, -42 }, { 38, -37 }, { 36, -32 }, { 28, -29 }, { 24, -22 }, { 19, -19 }, { 14, -14 }, { 8, -8 }, { 2, -2 } })
  local lower = W({ { 6, -8 }, { 16, -13 }, { 26, -17 }, { 35, -19 }, { 38, -14 }, { 34, -10 }, { 26, -4 }, { 18, 4 }, { 10, 10 } })
  local neck = W({ { -30, 16 }, { -38, 36 }, { -50, 54 }, { -66, 66 }, { -72, 84 }, { 44, 84 }, { 38, 66 }, { 26, 50 }, { 20, 36 }, { 14, 24 }, { 6, 12 }, { 10, 4 }, { 0, -2 } })
  -- ruff: jagged fur spikes on throat
  local ruff = W({ { 10, 8 }, { 24, 14 }, { 16, 20 }, { 30, 30 }, { 20, 34 }, { 34, 46 }, { 22, 48 }, { 32, 62 }, { 18, 58 }, { 14, 40 } })
  local whole = upper:copy():add(lower):add(neck):add(ruff)
  c:rim(whole, "#1a1830")
  local FUR = { hi = "#aab6e0", base = "#5a6492", shade = "#3c4270", deep = "#242850" }
  litL(neck:copy():add(ruff), FUR, 61, { R = 22, tex = .5, sc = 3, ink = false, amb = .15 })
  litL(upper, FUR, 62, { R = 16, tex = .45, sc = 3, ink = false, amb = .2 })
  litL(lower, FUR, 63, { R = 6, tex = .3, sc = 3, ink = false, amb = .15 })
  -- fur streaks
  whole:each(function(x, y) if H(x // 2, y // 3, 66) > .84 and whole:has(x + 1, y + 1) then P(x, y, "#5c64a0") elseif H(x // 3, y // 2, 67) > .9 then P(x, y, FUR.deep) end end)
  -- pale muzzle underside and cheek so the snout reads
  local mz = W({ { 14, -17 }, { 22, -21 }, { 28, -26 }, { 36, -31 }, { 36, -25 }, { 28, -24 }, { 22, -18 } }):clip(upper)
  fill(mz, "#aab4d8")
  mz:each(function(x, y) if not mz:has(x, y + 1) then P(x, y, "#e4e8f8") end end)
  local nose = W({ { 33, -44 }, { 39, -43 }, { 40, -37 }, { 35, -35 } }); fill(nose, "#16141e"); P(MX + 43, MY - 51, "#6a6a90")
  -- open mouth: teeth
  for k = 0, 4 do P(MX + 19 + k * 4, MY - 18 - floor(k * 1.6), "#fffbe8"); P(MX + 19 + k * 4, MY - 17 - floor(k * 1.6), "#fffbe8") end
  for k = 0, 3 do P(MX + 36 - k * 4, MY - 22 + floor(k * .6), "#fffbe8") end
  fill(W({ { 14, -9 }, { 24, -13 }, { 30, -13 }, { 22, -8 } }), "#c8586a") -- tongue
  -- eye + brow
  eyeL(MX + 3, MY - 21, 4, 3, YE)
  ln(MX - 5, MY - 28, MX + 10, MY - 24, FUR.deep, 2)
  -- inner ear
  fill(W({ { -30, -26 }, { -33, -40 }, { -22, -30 } }), "#5a3a70")
  -- howl breath mist off the muzzle
  for _, q in ipairs{ { 306, 28, 3 }, { 316, 22, 3 }, { 326, 15, 2 }, { 334, 10, 2 } } do fill(E(q[1], q[2], q[3], q[3]), "#f4f6ff") end
  ln(78, 226, 78, 168, "#6e4a48", 2)
  local fl = PL({ { 80, 170 }, { 110, 174 }, { 104, 182 }, { 110, 192 }, { 80, 190 } }); litL(fl, { hi = "#c8ccdc", base = "#888ea8", shade = "#5a6084", deep = "#3a4068" }, 65, { R = 5, tex = .3 })
  for x = 84, 100 do P(x, 180, "#f5cf6a") end
  for i = 0, 7 do local x, y = 360 + i * 14, 246 + (i % 2) * 6 - floor(i * .5)
    fill(E(x, y, 2, 2), "#8c98c8"); for _, q in ipairs{ { -3, -3 }, { -1, -4 }, { 1, -4 }, { 3, -3 } } do P(x + q[1], y + q[2], "#8c98c8") end end
  for i = 1, 60 do P(floor(H(i, 7, 3) * 479), floor(H(i, 7, 4) * 262), "#f4f4ff") end
end)

local which = app.params.name or "all"
for _, name in ipairs(ORDER) do
  if which == "all" or which == name then
    c = HP.canvas{ w = 480, h = 270, scale = 1, name = name }
    local ok, err = xpcall(PICS[name], debug.traceback)
    if not ok then print("ERR " .. name .. ": " .. err) end
    foot()
    c:save{ aseprite = d .. "/out/" .. name .. ".aseprite", png = d .. "/out/" .. name .. ".png", scale = 1 }
  end
end
