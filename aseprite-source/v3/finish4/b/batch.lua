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


---------------------------------------------------------------- 3 cenote
local function stalac(x, y0, w, len, seed, far, CX)
  local Rm = far and RR("#506070", "#3a4858", "#2a3444", "#1c2430") or RR("#6e7888", "#46526a", "#303a50", "#1c2234")
  local m = mk()
  for yy = 0, len do
    local t = yy / len
    local hw = (w * (1 - t) ^ .75 + .6) * (1 + (GX.vn(yy, seed, 7, seed + 2) - .5) * .55)
    local cx = x + (CX - x) * .1 * t + (GX.vn(yy, seed, 5, seed) - .5) * 3
    for xx = floor(cx - hw), floor(cx + hw) do m:set(xx, y0 + yy) end
    if yy % 9 == 5 and yy > 8 then m:set(floor(cx - hw) - 1, y0 + yy); m:set(floor(cx + hw) + 1, y0 + yy) end
  end
  litL(m, Rm, seed, { R = max(3, floor(w * .8)), tex = .5, sc = 3 })
  -- dark ring bands and drip tip
  m:each(function(xx, yy) if (yy - y0) % 9 == 6 and (xx + yy) % 2 == 0 then P(xx, yy, Rm.deep) end end)
  m:each(function(xx, yy) if not m:has(xx, yy + 1) and m:has(xx, yy - 1) then P(xx, yy, far and "#5a7080" or "#7a9aaa") end end)
  return m
end
pic("wonder-cenote-of-echoes", function()
  sky({ "#182226", "#202c32", "#283840", "#223038" }, 0, 270, 3)
  for y = 0, 269 do for x = 0, 479 do
    local h = H(x // 3, y // 2, 5)
    if (y + floor(GX.vn(x, y, 22, 7) * 8)) % 11 == 0 and h > .4 then P(x, y, "#34464e") elseif h > .93 then P(x, y, "#34484e") elseif h < .06 then P(x, y, "#121a20") end
  end end
  local CX, CY = 240, 56
  local hole = rough(E(CX, CY, 112, 34), 71)
  local outer = rough(E(CX, CY, 140, 52), 72)
  local ring = outer:copy():cut(hole)
  local skyc = { "#8cd0e8", "#a8dcec", "#c8ecee", "#e8f6e8" }
  hole:each(function(x, y) P(x, y, skyc[max(1, min(4, 1 + floor((y - 22) / 14)))]) end)
  cloudp(210, 50, 44, "#fffdf0", "#cfe6e8"); cloudp(300, 40, 30, "#fffdf0", "#cfe6e8")
  c:rim(hole, INK)
  local RK = RR("#b4b8b4", "#868c90", "#586070", "#38404e")
  lit(ring, RK, 73, { R = 20, tex = .7, sc = 3 })
  ring:each(function(x, y) if hole:has(x, y + 1) or hole:has(x - 1, y + 1) then P(x, y, RK.hi) end end)
  for i = 0, 14 do local a = pi + (i + .5) / 15 * pi; local x, y = CX + 138 * cos(a), CY + 50 * sin(a)
    if i % 2 == 0 then GX.foliage(c, floor(x), floor(y) + 2, 12 + (i % 3) * 3, 6, RR("#8cd05a", "#4a9a48", "#2e6e44", "#1e4a38"), 80 + i) end end
  for i = 0, 6 do local x = 120 + i * 40 + floor(H(i, 2, 2) * 16); local len = 20 + floor(H(i, 4, 4) * 44); for y = 76, 76 + len do P(x + floor(sin(y / 7 + i)), y, y % 6 == 5 and "#9ad45a" or "#4a8a48") end end
  local function ringBot(x) local u = (x - CX) / 140; if abs(u) >= .98 then return 0 end return floor(CY + 52 * sqrt(1 - u * u)) - 5 end
  -- far small stalactites along the lip, converging toward the centre
  for i, x in ipairs{ 130, 152, 176, 204, 276, 304, 328, 350 } do
    local y0 = ringBot(x); if y0 > 0 then stalac(x, y0, 4 + (i % 3), 14 + (i * 7) % 14, 40 + i, true, CX) end
  end
  for i, x in ipairs{ 110, 164, 192, 288, 318, 364 } do
    local y0 = ringBot(x); if y0 > 0 then stalac(x, y0, 7, 30 + (i * 11) % 18, 60 + i, false, CX) end
  end
  -- light shaft: slim rays fanning out, not a solid wedge
  for k = 0, 9 do
    local tx = 150 + k * 21 + floor(H(k, 3, 3) * 6)
    local bx = 70 + k * 38 + floor(H(k, 4, 3) * 12)
    local w0, w1 = 3 + floor(H(k, 5, 3) * 5), 9 + floor(H(k, 6, 3) * 14)
    local ray = PL({ { tx - w0, 84 }, { tx + w0, 84 }, { bx + w1, 230 }, { bx - w1, 230 } })
    ray:each(function(x, y) local o = c:get(x, y); if o then
      local tt = (y - 84) / 146
      if (x + y) % 2 == 0 then P(x, y, mix(o, "#fff4b8", .42 - tt * .1)) elseif (x // 2 + y) % 3 == 0 then P(x, y, mix(o, "#fff4b8", .16)) end end end)
  end
  local fan = PL({ { 140, 84 }, { 340, 84 }, { 400, 228 }, { 80, 228 } })
  fan:each(function(x, y) if (x % 3 == 0 and y % 3 == 0) then shadeTo(x, y, "#fff4b8", .3) end end)
  -- pool basin
  local ledge = E(240, 232, 214, 44); lit(ledge, RK, 5, { R = 18, tex = .6 })
  local pool = E(240, 232, 190, 34)
  c:rim(pool, INK)
  pool:each(function(x, y) local dy = (y - 198) / 68; P(x, y, dy < .2 and "#1a5e78" or (dy < .45 and "#1f7a94" or (dy < .75 and "#28a0aa" or "#44c8c0"))) end)
  for k = 1, 5 do local rx, ry = 20 + k * 24, 4 + k * 5
    E(240, 226, rx, ry):copy():cut(E(240, 226, rx - 2, ry - 1)):clip(pool):each(function(x, y) if (x + k) % 3 ~= 0 then P(x, y, (k % 2 == 1) and "#d8fff0" or "#8ee8dc") end end) end
  fill(E(240, 226, 62, 12), "#e8fff0"); fill(E(240, 226, 36, 7), CREAM)
  for i = 0, 40 do local x, y = 70 + floor(H(i, 41, 1) * 340), 204 + floor(H(i, 43, 1) * 56); if pool:has(x, y) then P(x, y, "#9aeee0"); P(x + 1, y, "#9aeee0") end end
  -- stalagmite reflections of the big drips: dark streaks in the water
  for _, sx in ipairs{ 90, 380 } do for y = 214, 246 do if pool:has(sx, y) and y % 2 == 0 then P(sx + floor(sin(y / 3)), y, "#16485c") end end end
  for _, s in ipairs{ { 156, 242, 16, 6 }, { 200, 236, 12, 5 }, { 290, 238, 12, 5 }, { 334, 244, 16, 6 } } do lit(E(s[1], s[2], s[3], s[4]), RK, s[1], { R = 5, tex = .5 }) end
  lit(E(240, 222, 12, 8), RK, 7, { R = 6, tex = .4 }); fill(R(239, 214, 241, 220), "#ffe38a"); c:sparkle(240, 208)
  for _, f in ipairs{ { 20, 256, 60, 26 }, { 460, 258, 64, 26 } } do lit(rough(E(f[1], f[2], f[3], f[4]), f[1]), RK, f[1], { R = 12, tex = .6 }) end
  -- near giant dark stalactites with perspective (large, hanging from the ceiling at the frame edges)
  stalac(26, -2, 24, 118, 11, false, CX); stalac(70, -2, 13, 70, 12, false, CX); stalac(104, -2, 8, 40, 13, false, CX)
  stalac(456, -2, 26, 126, 14, false, CX); stalac(410, -2, 14, 76, 15, false, CX); stalac(376, -2, 8, 42, 16, false, CX)
  -- quirk: sleeping bat on a stalactite
  local bat = E(70, 82, 4, 5); lit(bat, RR("#8a7a90", "#5e5068", "#443a52", "#2e2640"), 9, { R = 3, tex = 0 })
  P(68, 84, "#ffd0d8"); P(72, 84, "#ffd0d8")
  for i = 1, 30 do local x, y = 150 + floor(H(i, 8, 8) * 180), 100 + floor(H(i, 9, 8) * 110); c:px(x, y, "#fffbe0") end
  c:sparkle(210, 150); c:sparkle(280, 120)
end)

---------------------------------------------------------------- 4 flamingo shallows
local function flamingo(x, y, s, d, pose)
  local PK = RR("#ffc8d2", "#f08aa4", "#c8587c", "#8a3a62")
  local LEG = RR("#f4a0b0", "#d86a88", "#a8466a", "#7a3058")
  local bx, by = x, y - 36 * s
  local function ptr(a, b) return { bx + d * a * s, by + b * s } end
  -- legs
  local function leg(hx, hy, kx, ky, fx, fy) local m = spline({ { hx, hy }, { kx, ky }, { fx, fy } }, max(.7, 1.1 * s), max(.6, .8 * s), nil, 8); c:rim(m, INK); fill(m, LEG.base); return m end
  if pose == "one" or pose == "preen" then
    leg(x - d * 2 * s, by + 8 * s, x - d * 3 * s, y - 16 * s, x - d * 2 * s, y)
    local m = spline({ ptr(2, 8), ptr(10, 18), ptr(3, 19) }, max(.7, 1.1 * s), max(.6, .8 * s), nil, 8); c:rim(m, INK); fill(m, LEG.base)
  else
    leg(x - d * 4 * s, by + 8 * s, x - d * 6 * s, y - 15 * s, x - d * 5 * s, y)
    leg(x + d * 3 * s, by + 8 * s, x + d * 5 * s, y - 15 * s, x + d * 4 * s, y)
    for _, fx in ipairs({ x - d * 5 * s, x + d * 4 * s }) do fill(PL({ { fx, y }, { fx + d * 7 * s, y + 1 }, { fx - d * 2 * s, y + 1 } }), LEG.shade) end
  end
  -- wing for flap pose (behind body)
  if pose == "flap" then
    local wg = PL({ ptr(-2, -6), ptr(-14, -34), ptr(-2, -50), ptr(16, -42), ptr(24, -22), ptr(14, -6) })
    c:rim(wg, INK); lit(wg, PK, 9, { R = 10, tex = .2, ink = false })
    fill(PL({ ptr(24, -22), ptr(14, -6), ptr(-2, -6), ptr(8, -16) }), "#3a2840")
  end
  -- body + tail
  local body = E(bx, by, 15 * s, 10 * s)
  body:add(PL({ ptr(-10, -6), ptr(-27, 4), ptr(-12, 9) }))
  lit(body, PK, 3 + floor(x), { R = floor(10 * s), tex = .3 })
  local wing = E(bx - d * 2 * s, by - 1 * s, 10 * s, 5 * s); fill(wing, PK.hi)
  wing:each(function(xx, yy) if not wing:has(xx, yy + 1) then P(xx, yy, PK.base) end end)
  fill(PL({ ptr(-12, 1), ptr(-26, 3), ptr(-14, 7) }), "#3a2840")
  -- neck + head
  local N = {
    stand = { { 0, 0 }, { 5, -14 }, { -1, -28 }, { 5, -42 }, { 10, -50 } },
    high = { { 0, 0 }, { 2, -18 }, { -3, -34 }, { 2, -52 }, { 6, -62 } },
    feed = { { 0, 0 }, { 10, -4 }, { 19, 8 }, { 22, 24 }, { 19, 36 } },
    preen = { { 0, 0 }, { 8, -14 }, { 0, -28 }, { -12, -24 }, { -18, -12 } },
    one = { { 0, 0 }, { 8, -10 }, { 2, -22 }, { 9, -34 }, { 14, -38 } },
    flap = { { 0, 0 }, { 6, -14 }, { 0, -30 }, { 6, -44 }, { 10, -52 } },
  }
  local npts = {}
  for i, p in ipairs(N[pose]) do npts[i] = { bx + d * (11 + p[1]) * s, by - 5 * s + p[2] * s } end
  local neck = spline(npts, 0, 0, function(t) return (2.8 - t * .9) * s end, 14)
  lit(neck, PK, 20 + floor(x), { R = 4, tex = .2 })
  local h = npts[#npts]
  local hdm = E(h[1], h[2], 3.6 * s, 3 * s); lit(hdm, PK, 21, { R = 3, tex = 0 })
  local bd = ({ stand = { d, .4 }, high = { d, .4 }, feed = { .2 * d, 1 }, preen = { -d, .6 }, one = { d, .4 }, flap = { d, .4 } })[pose]
  local bl = sqrt(bd[1] ^ 2 + bd[2] ^ 2)
  local b1 = { h[1] + bd[1] / bl * 5 * s, h[2] + bd[2] / bl * 5 * s }
  local b2 = { h[1] + bd[1] / bl * 9 * s, h[2] + bd[2] / bl * 9 * s + 3 * s }
  local bk = spline({ h, b1, b2 }, 2.6 * s, 1 * s, nil, 8); c:rim(bk, INK); fill(bk, "#f6d8c8")
  fill(spline({ b1, b2 }, 1.6 * s, 1 * s, nil, 6), "#2b1c26")
  P(h[1] + d * 1.5 * s, h[2] - 1 * s, INK); P(h[1] + d * 1.5 * s - 1, h[2] - 1 * s - 1, CREAM)
  -- ripples at feet
  c:rim(E(x, y + 1, 14 * s, 3 * s), "#ffe6e0")
end
local WSNAP = {}
local function snap() for y = 130, 269 do WSNAP[y] = {} for x = 0, 479 do WSNAP[y][x] = c:get(x, y) end end end
local function reflect(x, y, s)
  local h = floor(62 * s)
  for dy = 1, h do
    local ry = y + dy + 1
    if ry > 268 then break end
    for xx = floor(x - 30 * s), floor(x + 30 * s) do
      if xx >= 0 and xx < 480 then
        local o = c:get(xx, y + 1 - dy)
        local w = WSNAP[y + 1 - dy] and WSNAP[y + 1 - dy][xx]
        local bg = WSNAP[ry] and WSNAP[ry][xx]
        if o and w and o ~= w and bg and (xx + dy) % 2 == 0 then P(xx, ry, mix(bg, o, .55)) end
      end
    end
  end
end
pic("wonder-flamingo-shallows", function()
  sky({ "#f2a0a8", "#f6b4ae", "#f8c8b4", "#fbdcbc", "#fdecc8", "#fff4d8" }, 0, 128, 3)
  cloudp(60, 44, 70, "#ffe0d0", "#f2a8b0"); cloudp(350, 30, 90, "#ffe0d0", "#f2a8b0"); cloudp(210, 64, 50, "#fff0dc", "#f6b8b4")
  fill(E(240, 126, 38, 38):clip(R(0, 0, 479, 126)), "#fff0b8"); fill(E(240, 126, 34, 34):clip(R(0, 0, 479, 126)), "#ffe8a0"); fill(E(240, 126, 24, 24):clip(R(0, 0, 479, 126)), "#fff6c8")
  ridge(function(x) return 114 + floor(4 * sin(x / 50 + 1)) end, "#c8a0b8", 134)
  ridge(function(x) return 121 + floor(3 * sin(x / 30 + 4)) end, "#b08aa8", 134)
  for _, a in ipairs({ { 70, 128, 1.2 }, { 410, 128, 1 }, { 150, 128, .7 }, { 330, 128, .8 } }) do
    local x, y, s = a[1], a[2], a[3]
    fill(R(x - 1, y - 10 * s, x, y), "#6a4a68"); fill(E(x, y - 12 * s, 18 * s, 3 * s), "#6a4a68"); fill(E(x - 5 * s, y - 15 * s, 9 * s, 2 * s), "#6a4a68")
  end
  local wc = { "#e8a0b8", "#e496b6", "#d88ab4", "#c880b0", "#b878b0", "#a070a8" }
  for y = 130, 269 do local i = min(6, 1 + floor((y - 130) / 24)); for x = 0, 479 do P(x, y, wc[i]) end end
  for i = 0, 140 do local y = 132 + (i * 53) % 136; local x = floor(H(i, 71, 1) * 480); local l = 4 + floor(H(i, 73, 1) * 12)
    for k = 0, l do P(x + k, y, (y < 190) and "#ffd0d0" or "#d8a8d0") end end
  for y = 132, 200, 3 do local w = 4 + (y - 130) // 4; for k = -w, w do if floor(H(k, y, 3) * 3) == 0 then P(240 + k, y, "#fff0b8") end end end
  snap()
  local far = { { 40, 150, .26, 1, "stand" }, { 82, 156, .3, -1, "feed" }, { 130, 148, .24, 1, "one" }, { 190, 158, .3, 1, "stand" }, { 296, 152, .26, -1, "preen" }, { 356, 160, .3, -1, "stand" }, { 410, 150, .24, 1, "feed" }, { 452, 158, .28, -1, "one" } }
  for _, f in ipairs(far) do flamingo(f[1], f[2], f[3], f[4], f[5]); reflect(f[1], f[2], f[3]) end
  local hero = { { 66, 214, .85, 1, "preen" }, { 436, 220, .9, -1, "feed" }, { 330, 206, 1.0, -1, "flap" }, { 120, 250, 1.4, 1, "feed" }, { 380, 252, 1.4, -1, "one" }, { 250, 255, 1.7, 1, "stand" } }
  for _, f in ipairs(hero) do flamingo(f[1], f[2], f[3], f[4], f[5]); reflect(f[1], f[2], f[3]) end
  fill(E(190, 236, 12, 3), "#4cb064"); c:rim(E(190, 236, 12, 3), INK)
  lit(E(190, 232, 5, 4), RR("#d8f070", "#8ccc48", "#4e9a44", "#2e6a3c"), 7, { R = 3, tex = 0 }); P(188, 230, INK); P(192, 230, INK)
  for i = 1, 20 do c:sparkle(floor(H(i, 5, 5) * 470) + 4, 140 + floor(H(i, 6, 5) * 120)) end
end)

---------------------------------------------------------------- 5 snowcrown peak
local ICE = RR("#e8fcff", "#8ad8f0", "#4aa0d0", "#2a6aa8")
local function crystal(x, y, w, h, lean, seed)
  local tx, ty = x + lean, y - h
  local whole = PL({ { x - w, y }, { x - w + 1, y - h * .72 }, { tx, ty }, { x + w - 1, y - h * .66 }, { x + w, y }, { x, y + 3 } })
  c:rim(whole, INK)
  local lf = PL({ { x - w, y }, { x - w + 1, y - h * .72 }, { tx, ty }, { x + lean * .5, y - h * .25 }, { x, y + 3 } })
  fill(whole, ICE.shade); fill(lf, ICE.base)
  local lh = PL({ { x - w + 1, y - 2 }, { x - w + 2, y - h * .66 }, { tx - 1, ty + 3 }, { x - w * .3, y - h * .5 } }); fill(lh, ICE.hi)
  ln(tx, ty, x + lean * .5, y - h * .25, "#f2fbff", 1)
  ln(x + lean * .5, y - h * .25, x, y + 2, ICE.deep, 1)
  P(tx, ty, "#fffbe8")
end
pic("lair-snowcrown-peak", function()
  GX.bands(c, 0, 200, { "#3a3a78", "#6a54a0", "#b068a0", "#f08a8c", "#ffb08a", "#ffd8a0" }, 5, .15)
  stars(0, 70, 36, 3, { "#fff1cf", "#ffd8e8" })
  halo(240, 80, 150, 90, .13, 3, "#ffe0b0"); halo(240, 80, 100, 60, .15, 4, "#ffe0b0")
  layer({ { 60, 130, .8 }, { 130, 120, 1.1 }, { 390, 118, 1.0 }, { 450, 136, .8 } }, 190, { hi = "#f2d8e8", base = "#b49cc8", shade = "#8474ac", deep = "#5c5090" }, 11, .4, 240, "#f0b8c0")
  local SN = RR("#fff1ee", "#d8dcf0", "#9a9cd0", "#5e58a4")
  local peak = rough(PL({ { 20, 246 }, { 70, 214 }, { 100, 196 }, { 120, 172 }, { 152, 160 }, { 170, 130 }, { 196, 118 }, { 210, 92 }, { 228, 76 }, { 240, 68 }, { 258, 78 }, { 270, 96 }, { 292, 108 }, { 306, 138 }, { 330, 150 }, { 352, 180 }, { 384, 196 }, { 410, 222 }, { 466, 246 } }), 31)
  litL(peak, SN, 32, { R = 40, tex = .5, sc = 4 })
  -- rock bands and couloirs, right face in shadow
  peak:each(function(x, y)
    local n = GX.vn(x, y * 1.7, 7, 33)
    if y > 110 and n > .66 then shadeTo(x, y, "#6a5a8a", .6) end
    local ridgeX = 238 + (y - 66) * .12
    if x > ridgeX then shadeTo(x, y, "#5a50a0", .5) end
    if x > ridgeX and (x + y) % 2 == 0 and n > .5 then shadeTo(x, y, "#3a3478", .35) end
  end)
  for k = 0, 90 do local y = 70 + k * 1.8; P(floor(238 + (y - 66) * .12), floor(y), "#ffe8e0") end
  -- crown of ice crystals
  for _, cr in ipairs{ { 214, 82, 7, 38, -4 }, { 266, 86, 6, 32, 5 }, { 226, 74, 8, 52, -2 }, { 254, 76, 8, 48, 3 }, { 240, 70, 9, 70, 0 } } do crystal(cr[1], cr[2], cr[3], cr[4], cr[5], 1) end
  glow(240, 20, 40, "#c8f4ff", .3)
  -- aurora-ish gold light shafts on the left face
  for k = 0, 5 do ln(176 + k * 6, 130 + k * 5, 150 + k * 6, 200 + k * 4, "#fff4d0", 1) end
  -- glacier tongue and lake
  GX.ground(c, function(x) return 226 + floor((GX.vn(x, 0, 24, 4) - .5) * 8) end, RR("#fff1ee", "#d8dcf0", "#a0a4d8", "#6a64b0"), 12, { top = .85, fall = .5, tex = .3 })
  for _, q in ipairs{ { 20, 224, 56 }, { 60, 228, 44 }, { 110, 222, 50 }, { 372, 224, 54 }, { 418, 228, 62 }, { 462, 224, 46 }, { 150, 230, 30 } } do
    pine(q[1], q[2], q[3], { hi = "#6a9a90", base = "#3a7270", shade = "#2a5266", deep = "#1e3850" }, GX.ramp6(SN), q[1])
  end
  local lake = rough(E(240, 256, 150, 16), 41); c:rim(lake, INK)
  lake:each(function(x, y) local t = (y - 240) / 32; P(x, y, t < .3 and "#8ad8f0" or (t < .6 and "#5ab8e0" or "#3a8cc8")) end)
  for k = 0, 40 do local x, y = 100 + floor(H(k, 3, 3) * 280), 244 + floor(H(k, 4, 3) * 24); if lake:has(x, y) then P(x, y, "#e8fcff"); P(x + 1, y, "#e8fcff") end end
  -- crown reflection shards
  for k = -3, 3 do local x = 240 + k * 7; for y = 244, 244 + 18 - abs(k) * 3 do if lake:has(x, y) and y % 2 == 0 then P(x, y, "#c8f0ff") end end end
  -- lair mouth with glowing eyes at the foot of the peak
  local cv = rough(PL({ { 214, 232 }, { 214, 218 }, { 224, 204 }, { 240, 198 }, { 256, 204 }, { 266, 218 }, { 266, 232 } }), 44); c:rim(cv, INK)
  cv:each(function(x, y) P(x, y, y > 222 and "#2a1c44" or "#1e1438") end)
  eyeL(230, 216, 3, 2, { hi = "#e8ffff", base = "#6ae0ff", shade = "#2a9ad0", deep = "#1a5a98" }); eyeL(250, 216, 3, 2, { hi = "#e8ffff", base = "#6ae0ff", shade = "#2a9ad0", deep = "#1a5a98" })
  for k = 0, 5 do local x = 217 + k * 9; for y = 199 + (k % 2) * 3, 206 + (k % 3) * 3 do if cv:has(x, y) or true then P(x, y, "#e8fcff") end end end
  -- quirk: snowman with a red gnome hat
  local sx, sy = 96, 250
  litL(E(sx, sy, 7, 6), SN, 3, { R = 4, tex = 0 }); litL(E(sx, sy - 10, 5, 5), SN, 4, { R = 3, tex = 0 })
  local hat = PL({ { sx - 4, sy - 13 }, { sx, sy - 24 }, { sx + 4, sy - 13 } }); c:rim(hat, INK); fill(hat, "#e0443a")
  P(sx - 1, sy - 11, INK); P(sx + 1, sy - 11, INK); P(sx + 2, sy - 10, "#f09030"); P(sx + 3, sy - 10, "#f09030")
  for i = 1, 70 do local x, y = floor(H(i, 9, 2) * 478), floor(H(i, 9, 3) * 260); P(x, y, "#fff1ee") end
end)

---------------------------------------------------------------- 6 temple of the tiger moth
local function mir(pts) local t = {} for i, p in ipairs(pts) do t[i] = { 480 - p[1], p[2] } end return t end
pic("lair-temple-of-the-tiger-moth", function()
  GX.bands(c, 0, 270, { "#0e2a3c", "#143a48", "#1a4a50", "#2a6058", "#3a7a58", "#5a9a58" }, 7, .15)
  halo(240, 60, 150, 100, .14, 3, "#ffe8b0")
  fill(E(240, 70, 46, 46), "#ffe8b0"); fill(E(240, 70, 42, 42), "#fff3cc")
  for i = 0, 10 do local x = i * 46 + 8; flat(R(x, 0, x + 6, 200), RR("#3a7a58", "#245a48", "#183e38", "#102a2a"), i, { sc = 2 }) end
  for y = 0, 200 do for x = 0, 479 do if ((x + y * .5) // 22) % 5 == 0 then shadeTo(x, y, "#ffe8a0", .1) end end end
  GX.ground(c, function(x) return 236 + floor(3 * sin(x / 22)) end, RR("#8ad060", "#4a9a48", "#2e6a40", "#1e4a38"), 4, { top = .8, fall = .5 })
  local ST = RR("#ecd8a8", "#b8a47a", "#7c7068", "#4a4458")
  local tiers = { { 60, 420, 214, 242 }, { 96, 384, 186, 214 }, { 132, 348, 160, 186 }, { 168, 312, 138, 160 } }
  for k, t in ipairs(tiers) do
    flat(R(t[1], t[3], t[2], t[4]), ST, k, { sc = 3 })
    fill(R(t[1], t[3], t[2], t[3] + 1), ST.hi)
    -- carved panels: squares with a spiral glyph and glowing slits
    for x = t[1] + 10, t[2] - 14, 22 do
      fill(R(x, t[3] + 6, x + 12, t[4] - 5), ST.shade); fill(R(x + 1, t[3] + 7, x + 11, t[4] - 6), ST.deep)
      ln(x + 3, t[3] + 9, x + 9, t[3] + 9, "#ffb84a", 1); ln(x + 9, t[3] + 9, x + 9, t[4] - 9, "#ffb84a", 1); ln(x + 3, t[3] + 12, x + 3, t[4] - 9, "#ffb84a", 1); ln(x + 3, t[4] - 9, x + 6, t[4] - 9, "#ffb84a", 1)
    end
  end
  for y = 138, 242, 4 do fill(R(226, y, 254, y), ST.hi); fill(R(226, y + 1, 254, y + 1), ST.shade) end
  fill(R(225, 138, 225, 242), INK); fill(R(255, 138, 255, 242), INK)
  -- shrine on top
  flat(R(212, 112, 268, 138), ST, 9, { sc = 3 })
  local roof = PL({ { 204, 112 }, { 276, 112 }, { 264, 100 }, { 216, 100 } }); flat(roof, RR("#9ed070", "#5aa050", "#3a7a48", "#245a3c"), 8)
  local door = E(240, 130, 8, 9):add(R(232, 130, 248, 138)):clip(R(232, 118, 248, 138)); c:rim(door, INK); fill(door, "#ffcf6a"); fill(E(240, 134, 4, 6):clip(door), "#fff0b8")
  -- torches
  for _, tx in ipairs{ 70, 410, 144, 336 } do
    local ty = tx < 100 or tx > 380 and 214 or 186
    if tx == 144 or tx == 336 then ty = 160 else ty = 214 end
    fill(R(tx, ty - 10, tx + 2, ty), "#5a3a40")
    fill(PL({ { tx - 3, ty - 10 }, { tx + 5, ty - 10 }, { tx + 1, ty - 24 } }), "#ff8a30"); fill(PL({ { tx - 1, ty - 10 }, { tx + 3, ty - 10 }, { tx + 1, ty - 18 } }), "#ffe07a")
    glow(tx + 1, ty - 14, 22, "#ffb860", .3)
  end
  -- the tiger moth: forewings dark brown with cream tiger bands, hindwings flame orange with black eye-spots
  local WB = RR("#7a4a38", "#4a2c28", "#2e1c24", "#1e1220")
  local function wing(pts, kind, seed, sx)
    local m = rough(PL(pts), seed); c:rim(m, INK)
    local bx, by = sx and 236 or 244, 104
    m:each(function(x, y)
      local dx, dy = (x - bx) * (sx and -1 or 1), y - by
      local dist = sqrt(dx * dx + dy * dy)
      local col
      if kind == "fore" then
        local band = (dx * .55 + dy * .85 + (GX.vn(x, y, 5, seed) - .5) * 7) / 9
        col = (floor(band) % 3 == 0) and "#fff1cf" or ((floor(band) % 3 == 1) and "#6a3e34" or "#4a2c28")
        if (floor(band) % 3 == 0) and dist < 24 then col = "#f6d49a" end
        if not m:has(x - 2, y - 1) or not m:has(x - 1, y - 2) then col = "#c89a78" end
      else
        local t = min(1, dist / 78)
        col = t < .3 and "#ffc060" or (t < .6 and "#ff8a30" or (t < .85 and "#e8502c" or "#c03030"))
        if not m:has(x - 2, y - 1) or not m:has(x - 1, y - 2) then col = "#ffd890" end
        if not m:has(x + 3, y + 2) then col = "#7a2a30" end
      end
      P(x, y, col)
    end)
    if kind == "hind" then
      for _, sp in ipairs(sx and mir{ { 292, 150 }, { 312, 136 }, { 330, 156 }, { 300, 164 } } or { { 292, 150 }, { 312, 136 }, { 330, 156 }, { 300, 164 } }) do
        fill(E(sp[1], sp[2], 6, 6):clip(m), INK); fill(E(sp[1], sp[2], 3, 3):clip(m), "#5ab0ff"); P(sp[1] - 1, sp[2] - 1, "#d8f4ff")
      end
    end
    -- veins
    local tipx = bx + (sx and -1 or 1) * 90
    for k = 0, 4 do ln(bx, by + k * 6, tipx, 40 + k * 28, kind == "fore" and "#2e1c24" or "#a83a2c", 1) end
    m:each(function(x, y) end)
    return m
  end
  local FW = { { 246, 104 }, { 270, 78 }, { 310, 48 }, { 352, 30 }, { 374, 40 }, { 380, 64 }, { 366, 92 }, { 334, 112 }, { 290, 122 }, { 258, 118 } }
  local HW = { { 246, 114 }, { 290, 116 }, { 336, 124 }, { 366, 144 }, { 360, 170 }, { 330, 182 }, { 296, 172 }, { 266, 150 } }
  wing(mir(HW), "hind", 21, true); wing(HW, "hind", 22, false)
  wing(mir(FW), "fore", 23, true); wing(FW, "fore", 24, false)
  -- fuzzy body
  local ab = limb({ { 240, 118 }, { 240, 132 }, { 240, 148 } }, 8, 5, 8)
  c:rim(ab, INK); lit(ab, RR("#ffe4b0", "#f0a860", "#b4683c", "#6a3a34"), 5, { R = 5, tex = .5, ink = false })
  for k = 0, 3 do local yy = 124 + k * 7; ln(233, yy, 247, yy, "#2e1c24", 1) end
  local th = E(240, 108, 11, 12); lit(th, RR("#fff1cf", "#f0b878", "#b4683c", "#6a3a34"), 6, { R = 7, tex = .6 })
  local hd = E(240, 90, 8, 7); lit(hd, RR("#ffe4b0", "#e8a060", "#a86040", "#6a3a34"), 7, { R = 4, tex = .4 })
  for _, sx in ipairs{ -1, 1 } do
    fill(E(240 + sx * 5, 89, 3, 3), INK); P(240 + sx * 5 - 1, 88, "#ffe8a0")
    local an = limb({ { 240 + sx * 3, 84 }, { 240 + sx * 10, 70 }, { 240 + sx * 18, 62 }, { 240 + sx * 24, 64 } }, 1, .6, 8); fill(an, "#2e1c24")
    for k = 0, 6 do P(240 + sx * (8 + k * 2.3), 74 - k * 1.3 + 5, "#2e1c24") end
  end
  -- mossy vines and foreground foliage
  for i = 1, 16 do local x = floor(H(i, 1, 3) * 470); local len = 14 + floor(H(i, 2, 3) * 40); for y = 0, len do P(x + floor(sin(y / 6 + i)), y, y % 7 == 6 and "#9ad45a" or "#3f8a48") end end
  GX.foliage(c, 40, 244, 90, 24, RR("#6cc058", "#368a48", "#245e3c", "#173e30"), 5); GX.foliage(c, 440, 250, 100, 22, RR("#6cc058", "#368a48", "#245e3c", "#173e30"), 6)
  for i = 1, 16 do tuft(floor(H(i, 6, 6) * 470) + 4, 250 + floor(H(i, 7, 6) * 16), GRASS) end
  -- quirk: tiny snail on the second step
  fill(E(214, 183, 4, 3), "#f0c070"); c:rim(E(214, 183, 4, 3), INK); fill(E(210, 185, 4, 1), "#d89a78"); P(207, 182, INK)
  for i = 1, 26 do local x, y = 40 + floor(H(i, 8, 8) * 400), 70 + floor(H(i, 9, 8) * 150); c:sparkle(x, y); P(x, y, "#ffe49a") end
end)

---------------------------------------------------------------- 7 tomb of the sand scarab
pic("lair-tomb-of-the-sand-scarab", function()
  GX.bands(c, 0, 170, { "#4a2e78", "#8a4a8c", "#d0688c", "#ff8a6c", "#ffb868", "#ffe090" }, 8, .12)
  halo(110, 150, 140, 70, .2, 3, "#ffe0a0")
  fill(E(110, 152, 40, 40), "#ffb868"); fill(E(110, 152, 36, 36), "#ffd88a"); fill(E(110, 152, 33, 33), "#fff0b8")
  stars(0, 70, 22, 5, { "#ffe8c8" })
  local DN = RR("#ffe0a0", "#e8a868", "#b0684c", "#6a3a48")
  ridge(function(x) return 150 + floor(10 * sin(x / 70) + 4 * sin(x / 23)) end, "#a8587a", 270)
  -- sandstone cliff and tomb facade
  local cliff = rough(PL({ { 170, 200 }, { 176, 118 }, { 200, 96 }, { 280, 92 }, { 330, 104 }, { 360, 130 }, { 380, 200 } }), 51)
  litL(cliff, RR("#f6c890", "#d49058", "#9a5a4a", "#5a3040"), 52, { R = 24, tex = .6, sc = 3 })
  cliff:each(function(x, y) if (y % 9 == 0) and H(x // 4, y, 53) > .3 then shadeTo(x, y, "#5a3040", .35) end end)
  local fac = R(204, 112, 332, 204); flat(fac, RR("#ffdca0", "#e0a468", "#a8685a", "#643848"), 55, { sc = 3 })
  fill(R(200, 108, 336, 114), "#fff0c0"); fill(R(200, 115, 336, 117), "#a8685a")
  for _, px_ in ipairs{ 214, 252, 292, 322 } do  -- lotus pillars
    local pm = R(px_, 118, px_ + 8, 204); litL(pm, RR("#ffe8b0", "#e8b078", "#a8685a", "#643848"), px_, { R = 4, tex = .3 })
    fill(R(px_ - 2, 118, px_ + 10, 122), "#a8685a"); fill(R(px_ - 2, 202, px_ + 10, 205), "#a8685a")
  end
  local door = R(262, 150, 284, 204); c:rim(door, INK); fill(door, "#1a1020"); fill(R(266, 190, 280, 204), "#ffcf6a"); fill(R(270, 196, 276, 204), "#fff0b8")
  for y = 150, 204 do if y % 3 == 0 then P(262, y, "#a8685a") end end
  -- golden scarab relief over the door
  fill(E(273, 134, 10, 7), "#f2b84a"); c:rim(E(273, 134, 10, 7), INK); ln(273, 127, 273, 141, "#9a5a30", 1)
  fill(E(273, 125, 4, 3), "#f2b84a"); ln(262, 134, 258, 138, "#f2b84a", 1); ln(284, 134, 288, 138, "#f2b84a", 1)
  P(270, 132, "#fff0b8"); P(269, 131, "#fff0b8")
  for k = 0, 8 do fill(R(210 + k * 14, 124, 214 + k * 14, 126), "#b0603c") end
  -- obelisks
  local function obelisk(x, by, w, h, seed)
    local m = PL({ { x - w, by }, { x - w + 2, by - h }, { x, by - h - 8 }, { x + w - 2, by - h }, { x + w, by } })
    litL(m, RR("#ffd8a0", "#d48e60", "#98605a", "#5a3448"), seed, { R = 6, tex = .3 })
    for k = 0, floor(h / 8) - 1 do fill(R(x - 2, by - 8 - k * 8, x + 1, by - 6 - k * 8), "#5a3448") end
  end
  obelisk(168, 226, 8, 70, 3); obelisk(356, 224, 8, 62, 4)
  GX.ground(c, function(x) return 220 + floor(6 * sin(x / 60) + 3 * sin(x / 14)) end, DN, 5, { top = .9, fall = .7, tex = .35 })
  for i = 0, 60 do local x, y = floor(H(i, 1, 2) * 480), 226 + floor(H(i, 2, 2) * 44); for k = 0, 5 do P(x + k, y - floor(k / 3), "#ffe0a0") end end
  -- the giant scarab pushing a golden sun-ball
  local bx, gy = 170, 258
  local function sp(...) local t = { ... } local q = {} for i = 1, #t, 2 do q[#q + 1] = { bx + t[i], gy + t[i + 1] } end return q end
  local LG = RR("#7a98a8", "#3a5a78", "#26385a", "#1a2440")
  local legs = limb(sp(-30, -18, -48, -10, -50, 0), 3, 1.6):add(limb(sp(-10, -12, -20, -4, -22, 0), 3, 1.6)):add(limb(sp(8, -12, 10, -4, 14, 0), 3, 1.6))
  legs:add(limb(sp(38, -16, 56, -28, 70, -30), 3, 2))
  local ballM = E(bx + 108, gy - 36, 34, 34)
  local ball = lit(ballM, RR("#fff0a0", "#f2b84a", "#c0742c", "#7a4030"), 9, { R = 30, tex = .25 })
  for k = 1, 3 do ln(bx + 80, gy - 52 + k * 14, bx + 138, gy - 52 + k * 14 - 6, "#c0742c", 1) end
  c:rim(legs, INK); fill(legs, LG.base)
  legs:each(function(x, y) if not legs:has(x, y - 1) then P(x, y, LG.hi) elseif not legs:has(x, y + 1) then P(x, y, LG.deep) end end)
  for k = 0, 2 do P(bx - 49 + k, gy - 6 - k * 2, "#cfd8e0") end
  local dome = E(bx, gy - 32, 44, 28):clip(R(bx - 60, gy - 70, bx + 60, gy - 14)):add(R(bx - 38, gy - 20, bx + 40, gy - 14))
  local SH = RR("#a8f4d8", "#2ea8b0", "#1a6a8c", "#102e5a")
  lit(dome, SH, 12, { R = 26, tex = .25 })
  dome:each(function(x, y) local r = ((x - bx) / 44) ^ 2 + ((y - gy + 32) / 28) ^ 2; if floor(r * 9) % 2 == 0 and r > .15 and (x + y) % 2 == 0 then shadeTo(x, y, "#102e5a", .45) end end)
  ln(bx - 40, gy - 24, bx + 36, gy - 54, "#102e5a", 1)
  dome:each(function(x, y) if H(x // 3, y // 3, 12) > .93 then P(x, y, "#ffe090") end end)
  local pron = E(bx + 36, gy - 26, 12, 14); lit(pron, RR("#c8fff0", "#38b4a8", "#1e7a90", "#123a68"), 13, { R = 6, tex = .3 })
  local hd = E(bx + 52, gy - 16, 9, 8); lit(hd, RR("#9ac8d8", "#386a88", "#26385a", "#1a2440"), 14, { R = 4, tex = .2 })
  fill(PL({ { bx + 58, gy - 22 }, { bx + 68, gy - 18 }, { bx + 60, gy - 14 } }), "#cfd8e0"); P(bx + 56, gy - 19, "#ffe090")
  fill(PL({ { bx + 58, gy - 12 }, { bx + 66, gy - 10 }, { bx + 58, gy - 9 } }), "#cfd8e0")
  for k = 0, 2 do fill(E(bx + 54 + k * 3, gy - 27 - k * 2, 2, 2), "#3a5a78") end
  -- near legs over the body, long hind leg with spurs
  local nl = limb(sp(-24, -20, -40, -8, -38, 0), 3, 1.6):add(limb(sp(-2, -14, -6, -5, -2, 0), 3, 1.6)):add(limb(sp(22, -14, 28, -5, 34, 0), 3, 1.6))
  c:rim(nl, INK); fill(nl, LG.base); nl:each(function(x, y) if not nl:has(x, y - 1) then P(x, y, LG.hi) end end)
  for k = 1, 8 do fill(E(bx - 70 + k * 5, gy + 1, 3, 1), "#c8885a") end
  -- drag trail and dust puffs
  for i = 0, 12 do dust(bx - 70 - i * 10, gy + 2, 10, 2, "#e8a868", i) end
  dust(bx + 76, gy + 1, 22, 3, "#e8a868", 5)
  -- quirk: lizard on the obelisk base
  fill(E(176, 224, 5, 2), "#6ac078"); c:rim(E(176, 224, 5, 2), INK); ln(181, 224, 186, 222, "#6ac078", 1); P(172, 223, INK)
  c:sparkle(110, 120); c:sparkle(380, 80)
end)

---------------------------------------------------------------- 8 jade dragonfly
local JD = RR("#d8ffd0", "#5ad8a0", "#2a9a84", "#14606c")
pic("lair-of-the-jade-dragon-fly", function()
  -- pond seen from above
  for y = 0, 269 do for x = 0, 479 do
    local n = GX.vn(x * .6, y, 14, 3) * .6 + GX.vn(x, y, 5, 5) * .4
    local cols = { "#0e5058", "#146a68", "#1c8478", "#2a9a84", "#46b494" }
    P(x, y, cols[max(1, min(5, 1 + floor((n + (y - 135) * .0006) * 5)))])
  end end
  for i = 0, 120 do local x, y = floor(H(i, 1, 9) * 470), floor(H(i, 2, 9) * 265); for k = 0, 3 + floor(H(i, 3, 9) * 6) do P(x + k, y, (i % 3 == 0) and "#8ae8c0" or "#0e4048") end end
  for _, q in ipairs{ { 90, 70, 36, 12 }, { 380, 190, 44, 16 } } do
    local rg = E(q[1], q[2], q[3], q[4]):copy():cut(E(q[1], q[2], q[3] - 2, q[4] - 1)); rg:each(function(x, y) if (x + y) % 2 == 0 then P(x, y, "#9ef0d0") end end)
  end
  -- lily pads with notch
  local PAD = RR("#bef08a", "#58b860", "#2e8450", "#1a5a40")
  local pads = { { 60, 200, 30 }, { 120, 238, 24 }, { 420, 58, 28 }, { 360, 28, 20 }, { 40, 40, 22 }, { 440, 140, 24 }, { 150, 150, 18 }, { 330, 236, 22 }, { 220, 40, 16 } }
  for i, pd in ipairs(pads) do
    local m = E(pd[1], pd[2], pd[3], floor(pd[3] * .75)):cut(PL({ { pd[1], pd[2] }, { pd[1] + pd[3] + 4, pd[2] - 3 }, { pd[1] + pd[3] + 4, pd[2] + 5 } }))
    lit(m, PAD, i, { R = 8, tex = .3 })
    for k = 0, 5 do local a = k * 1.05 + i; ln(pd[1], pd[2], pd[1] + cos(a) * pd[3] * .8, pd[2] + sin(a) * pd[3] * .6, PAD.shade, 1) end
  end
  -- pink lotus blooms
  local function lotus(x, y, r)
    local PT = RR("#fff1f0", "#ffa8c0", "#e0689a", "#9a3a78")
    for k = 0, 7 do local a = k * .785; local m = E(x + cos(a) * r * .55, y + sin(a) * r * .42, r * .5, r * .3); lit(m, PT, k + x, { R = 3, tex = 0 }) end
    for k = 0, 4 do local a = k * 1.26 + .4; lit(E(x + cos(a) * r * .28, y + sin(a) * r * .2, r * .34, r * .22), PT, k + y, { R = 3, tex = 0 }) end
    fill(E(x, y, r * .2, r * .15), "#ffd860"); P(x, y, "#fff0b8")
  end
  lotus(70, 120, 22); lotus(410, 100, 24); lotus(300, 250, 18); lotus(180, 36, 16)
  -- jade stepping stones
  for i, q in ipairs{ { 36, 120, 10 }, { 450, 220, 12 }, { 270, 20, 9 }, { 100, 260, 10 } } do lit(E(q[1], q[2], q[3], floor(q[3] * .7)), JD, i, { R = 5, tex = .3 }) end
  -- dragonfly geometry (top view): shadow first
  local function wingPts(fore)
    if fore then return { { 246, 118 }, { 290, 98 }, { 336, 82 }, { 376, 86 }, { 384, 98 }, { 360, 112 }, { 320, 124 }, { 270, 128 } } end
    return { { 246, 130 }, { 290, 132 }, { 336, 142 }, { 372, 158 }, { 372, 172 }, { 340, 172 }, { 300, 162 }, { 262, 146 } }
  end
  local ab = limb({ { 240, 138 }, { 240, 170 }, { 240, 206 }, { 240, 244 } }, 7, 2.2, 10)
  local th = E(240, 126, 13, 15); local hd = E(240, 102, 11, 9)
  local wm = mk()
  for _, f in ipairs{ true, false } do wm:add(PL(wingPts(f))); wm:add(PL(mir(wingPts(f)))) end
  local shadow = wm:copy():add(ab):add(th):add(hd):shift(16, 22)
  shadow:each(function(x, y) if (x + y) % 2 == 0 or GX.vn(x, y, 3, 4) > .5 then shadeTo(x, y, "#08303a", .6) end end)
  -- wings
  local function wingDraw(pts, seedv, left)
    local m = rough(PL(pts), seedv)
    c:rim(m, "#1a5a5c")
    m:each(function(x, y)
      local o = c:get(x, y)
      local dx = abs(x - 240)
      local base = mix(o, "#d8fff0", .55)
      if (x + y) % 2 == 0 then base = mix(o, "#e8fff4", .75) end
      P(x, y, base)
    end)
    -- longitudinal veins fanning out and cross veins
    for k = 0, 5 do
      local ty = pts[3][2] + (pts[5][2] - pts[3][2]) * k / 5
      ln(left and 480 - pts[1][1] or pts[1][1], pts[1][2], left and 480 - pts[4][1] or pts[4][1], ty + (k - 2) * 3, "#2a8a7c", 1)
    end
    for k = 0, 9 do local fx = 246 + 12 * k; local xx = left and 480 - fx or fx; for y = pts[3][2] - 6, pts[5][2] + 10 do if m:has(xx, y) and (y + k) % 4 < 2 then P(xx, y, "#2a8a7c") end end end
    local tipx = left and 480 - pts[5][1] + 8 or pts[5][1] - 8
    fill(R(tipx - 3, pts[4][2] + 2, tipx + 3, pts[4][2] + 5):clip(m), "#8a4a3c")
  end
  local fw, hw = wingPts(true), wingPts(false)
  wingDraw(mir(hw), 11, true); wingDraw(hw, 12, false); wingDraw(mir(fw), 13, true); wingDraw(fw, 14, false)
  -- body
  c:rim(ab, INK); lit(ab, JD, 3, { R = 5, tex = .25, ink = false })
  for k = 0, 10 do local yy = 148 + k * 9; local hw_ = max(1, floor(6.5 - k * .45)); fill(R(240 - hw_, yy, 240 + hw_, yy), "#f2b84a"); P(240 - hw_, yy, JD.deep); P(240 + hw_, yy, JD.deep) end
  ln(240, 140, 240, 242, JD.deep, 1)
  lit(th, JD, 4, { R = 7, tex = .25 })
  ln(232, 114, 236, 138, "#f2b84a", 1); ln(248, 114, 244, 138, "#f2b84a", 1); ln(240, 112, 240, 138, JD.deep, 1)
  lit(hd, RR("#c8ffe8", "#48c8a0", "#2a8a84", "#14505c"), 5, { R = 5, tex = .2 })
  local EY = RR("#d8ffff", "#38b8d8", "#1e70a8", "#12407c")
  for _, sx in ipairs{ -1, 1 } do
    local e = E(240 + sx * 7, 98, 7, 8); lit(e, EY, 7 + sx, { R = 5, tex = .2 })
    P(240 + sx * 7 - 2, 95, "#f2fbff"); P(240 + sx * 7 - 1, 95, "#f2fbff")
    for k = 0, 4 do P(240 + sx * (3 + k * 2), 100 + k % 2, EY.deep) end
  end
  fill(R(237, 106, 243, 107), "#f2b84a")
  -- tucked legs
  for _, sx in ipairs{ -1, 1 } do for k = 0, 2 do ln(240 + sx * 6, 120 + k * 5, 240 + sx * (14 + k * 2), 124 + k * 8, INK, 1) end end
  -- quirk: frog on a pad looking up
  local fx, fy = 150, 152
  lit(E(fx, fy, 7, 5), RR("#d8f070", "#8ccc48", "#4e9a44", "#2e6a3c"), 7, { R = 3, tex = 0 }); fill(E(fx - 4, fy - 4, 2, 2), "#ffe49a"); fill(E(fx + 4, fy - 4, 2, 2), "#ffe49a"); P(fx - 4, fy - 4, INK); P(fx + 4, fy - 4, INK)
  for i = 1, 24 do c:sparkle(floor(H(i, 5, 5) * 470) + 4, floor(H(i, 6, 5) * 250)) end
end)

---------------------------------------------------------------- 9 dragonlizard den
local function scales(m, cw, ch, seed, tintcol, strength)
  vor(m, cw, ch, seed, function(x, y, qx, qy, id, d1, gap)
    local o = c:get(x, y); if not o then return end
    if gap < 1.1 then P(x, y, mix(o, "#1a1220", .55))
    elseif x < qx - cw * .15 and y < qy - ch * .15 and gap < 3 then P(x, y, mix(o, "#ffffd0", .28))
    else P(x, y, mix(o, tintcol, (id - .5) * (strength or .3) + .05)) end
  end)
end
pic("lair-dragonlizard-den", function()
  -- cave interior
  GX.bands(c, 0, 270, { "#2a1a38", "#34223e", "#3e2a44", "#46304a" }, 3, .2)
  for y = 0, 269 do for x = 0, 479 do if H(x // 3, y // 3, 4) > .92 then P(x, y, "#563c58") elseif H(x // 2, y // 2, 5) < .07 then P(x, y, "#20142c") end end end
  -- opening to dusk valley on the left
  local op = rough(E(86, 130, 82, 112):clip(R(0, 0, 200, 262)), 8)
  GX.bands(c, 0, 270, { "#6a4a8c", "#c8688c", "#ff8a6c", "#ffc068", "#ffe090" }, 9, .1)
  local OP = mk(); op:each(function(x, y) end)
  -- re-darken everything outside the opening
  local keep = {}
  op:each(function(x, y) keep[x * 1000 + y] = c:get(x, y) end)
  GX.bands(c, 0, 270, { "#2a1a38", "#34223e", "#3e2a44", "#46304a" }, 3, .2)
  for y = 0, 269 do for x = 0, 479 do if H(x // 3, y // 3, 4) > .92 then P(x, y, "#563c58") elseif H(x // 2, y // 2, 5) < .07 then P(x, y, "#20142c") end end end
  op:each(function(x, y) P(x, y, keep[x * 1000 + y]) end)
  op:each(function(x, y) if y > 150 then local t = (y - 150) / 112; P(x, y, t < .3 and "#e8a068" or (t < .6 and "#b06a5a" or "#6a3a4c")) end end)
  fill(E(70, 150, 22, 22):clip(op), "#fff0b8"); fill(E(70, 150, 18, 18):clip(op), "#fff8d0")
  c:rim(op, INK)
  layerClip = nil
  for k = 0, 3 do ln(30 + k * 40, 168 + (k % 2) * 8, 54 + k * 40, 160 + (k % 2) * 8, "#b06a5a", 2) end
  -- light shaft from opening across the floor
  PL({ { 20, 160 }, { 150, 120 }, { 330, 270 }, { 100, 270 } }):each(function(x, y) if (x + y) % 3 == 0 then shadeTo(x, y, "#ffd890", .18) end end)
  -- stalagmite columns / ceiling teeth
  for _, s in ipairs{ { 200, 0, 14, 60 }, { 240, 0, 9, 36 }, { 290, 0, 12, 50 }, { 340, 0, 10, 30 } } do
    local m = mk(); for yy = 0, s[4] do local hw = s[3] * (1 - yy / s[4]) ^ .8 + .5; for xx = floor(s[1] - hw), floor(s[1] + hw) do m:set(xx, yy) end end
    litL(m, RR("#8a6a88", "#5a4268", "#3a2a50", "#22183a"), s[1], { R = 6, tex = .5 })
  end
  -- the dragonlizard: head in profile facing the light
  local function Wp(pts) local t = {} for i, p in ipairs(pts) do t[i] = { p[1], p[2] } end return PL(t) end
  local upper = Wp({ { 172, 150 }, { 176, 138 }, { 190, 126 }, { 214, 116 }, { 240, 104 }, { 262, 90 }, { 290, 82 }, { 330, 80 }, { 370, 92 }, { 406, 118 }, { 430, 160 }, { 436, 196 }, { 392, 196 }, { 340, 188 }, { 290, 176 }, { 240, 168 }, { 200, 160 } })
  local lower = Wp({ { 178, 172 }, { 200, 170 }, { 240, 180 }, { 296, 192 }, { 350, 202 }, { 440, 214 }, { 470, 270 }, { 330, 270 }, { 296, 238 }, { 240, 214 }, { 200, 196 }, { 180, 184 } })
  local neck = Wp({ { 392, 150 }, { 440, 176 }, { 470, 214 }, { 479, 270 }, { 420, 270 }, { 410, 220 }, { 380, 190 } })
  local ridgeS = {}
  local whole = upper:copy():add(lower):add(neck)
  -- frill spikes and horns (behind)
  local horns = limb({ { 300, 84 }, { 310, 58 }, { 336, 40 }, { 352, 38 } }, 6, 1.5, 10):add(limb({ { 350, 90 }, { 366, 66 }, { 392, 54 }, { 408, 56 } }, 7, 1.5, 10)):add(limb({ { 252, 96 }, { 252, 78 }, { 262, 64 } }, 4, 1.2, 8))
  for k = 0, 4 do horns:add(PL({ { 388 + k * 12, 118 + k * 18 }, { 388 + k * 12 + 18, 100 + k * 18 }, { 400 + k * 12, 132 + k * 18 } })) end
  c:rim(horns, INK)
  litL(horns, RR("#fff0c8", "#e8a860", "#b06a44", "#6a3a40"), 9, { R = 4, tex = .3, ink = false })
  c:rim(whole, INK)
  local SK = RR("#d8f080", "#6aa848", "#3e7a48", "#1e4a3c")
  litL(neck, SK, 21, { R = 30, tex = .4, ink = false, amb = .1 })
  litL(upper, SK, 22, { R = 22, tex = .35, ink = false, amb = .2 })
  litL(lower, RR("#fff0b0", "#c8c868", "#6a9a58", "#2e5a44"), 23, { R = 22, tex = .35, ink = false, amb = .15 })
  scales(whole, 7, 6, 31, "#243a48", .5)
  -- belly plates on throat
  for k = 0, 12 do local yy = 200 + k * 5; ln(250 + k * 14, yy + 6 + k * 3, 290 + k * 14, yy + 10 + k * 3, "#8a9a50", 1) end
  -- mouth interior and teeth along the gap
  local mouth = Wp({ { 178, 158 }, { 240, 170 }, { 296, 182 }, { 350, 194 }, { 340, 200 }, { 296, 190 }, { 240, 178 }, { 200, 170 } })
  fill(mouth, "#3a1424"); fill(Wp({ { 236, 174 }, { 296, 186 }, { 280, 190 }, { 240, 182 } }), "#c8586a")
  for k = 0, 9 do local tx = 190 + k * 15; local ty = 158 + floor(k * 3.7); fill(PL({ { tx, ty }, { tx + 6, ty + 2 }, { tx + 3, ty + 9 } }), "#fff1cf"); P(tx + 3, ty + 8, "#c8b498") end
  for k = 0, 8 do local tx = 196 + k * 15; local ty = 172 + floor(k * 3.4); fill(PL({ { tx, ty }, { tx + 5, ty - 1 }, { tx + 3, ty - 8 } }), "#fff1cf") end
  -- brow ridge, eye, nostril
  local brow = limb({ { 232, 112 }, { 256, 106 }, { 282, 100 } }, 5, 3, 8); litL(brow, SK, 24, { R = 3, tex = .3, ink = false }); c:rim(brow, INK)
  local eye = E(262, 120, 11, 9); c:rim(eye, INK)
  eye:each(function(x, y) local t = ((x - 262) / 11) ^ 2 + ((y - 120) / 9) ^ 2; P(x, y, t < .5 and "#ffe04a" or (t < .8 and "#f09a30" or "#c8602c")) end)
  fill(R(261, 111, 263, 129):clip(eye), INK); P(258, 114, "#fffbe0"); P(259, 114, "#fffbe0")
  glow(262, 120, 28, "#ffc040", .22)
  fill(E(198, 138, 3, 2), "#241a30"); P(197, 137, "#6a4a5a")
  for k, q in ipairs{ { 196, 128, 4 }, { 188, 116, 5 }, { 176, 102, 6 }, { 160, 90, 5 } } do fill(E(q[1], q[2], q[3], q[3]), "#8a7a8c"); P(q[1] - 1, q[2] - 1, "#d8c8d0") end
  -- hoard
  local hm = mk(); for x = 0, 479 do local top = 238 + floor(6 * sin(x / 40) + 4 * sin(x / 13 + 2)) - floor(14 * max(0, 1 - abs(x - 120) / 110)); for y = top, 269 do hm:set(x, y) end end
  litL(hm, RR("#fff0a0", "#f2b84a", "#c0742c", "#6a3a38"), 3, { R = 14, tex = .6, sc = 2, ink = false })
  for i = 0, 90 do local x, y = floor(H(i, 1, 6) * 470) + 4, 240 + floor(H(i, 2, 6) * 28)
    if hm:has(x, y) then fill(E(x, y, 4, 2), "#f2b84a"); c:rim(E(x, y, 4, 2), "#7a4a30"); P(x - 2, y - 1, "#fff0b8") end end
  litL(E(60, 244, 8, 6), RR("#ffd0e0", "#e8487a", "#a02a62", "#5a1a48"), 4, { R = 4, tex = 0 })
  litL(E(420, 246, 9, 7), RR("#d8ffff", "#48c8e0", "#2a8ac0", "#1a4a90"), 5, { R = 4, tex = 0 })
  -- bones and a crooked sword as small props
  ln(300, 252, 330, 262, "#f0e0c8", 2); fill(E(298, 251, 3, 3), "#f0e0c8"); fill(E(332, 263, 3, 3), "#f0e0c8")
  -- smoke from nostril
  for i, q in ipairs{ { 190, 124, 4 }, { 182, 112, 5 }, { 174, 98, 6 } } do end
  for i = 1, 40 do local x, y = floor(H(i, 8, 8) * 470), floor(H(i, 9, 8) * 250); if H(i, 2, 2) > .5 then P(x, y, "#ffe49a") end end
  c:sparkle(90, 230); c:sparkle(380, 240)
end)

---------------------------------------------------------------- 10 oasis that moves
local function palm(x, y, h, lean, seed)
  local tr = limb({ { x, y }, { x + lean * .4, y - h * .5 }, { x + lean, y - h } }, 3, 1.8, 10)
  c:rim(tr, INK); lit(tr, RR("#d8a874", "#946648", "#5e3e3c", "#3a2634"), seed, { R = 3, tex = .5, ink = false })
  for k = 0, 8 do local yy = y - 4 - k * (h / 10); if k % 1 == 0 then local xx = x + lean * ((y - yy) / h) * (1 - 0 ) ; ln(xx - 2, yy, xx + 2, yy, "#5e3e3c", 1) end end
  local tx, ty = x + lean, y - h
  for k = 0, 7 do
    local a = -pi + k * pi / 7 + (k % 2) * .12
    local len = h * .62
    local fr = limb({ { tx, ty }, { tx + cos(a) * len * .5, ty + sin(a) * len * .5 - 8 }, { tx + cos(a) * len, ty + sin(a) * len * .7 + 7 } }, 2.4, .8, 10)
    c:rim(fr, INK); lit(fr, RR("#c8f070", "#58b048", "#2e7a44", "#1e4a38"), seed + k, { R = 2, tex = .3, ink = false })
  end
  fill(E(tx - 2, ty + 3, 3, 3), "#a86a3c"); fill(E(tx + 3, ty + 4, 3, 3), "#a86a3c")
end
pic("wonder-the-oasis-that-moves", function()
  GX.bands(c, 0, 170, { "#6a8ce0", "#8ca8e8", "#e8b0b0", "#ffc890", "#ffdc9c", "#fff0b8" }, 6, .12)
  cloudp(80, 40, 60, "#fff0e0", "#f0b8b0"); cloudp(400, 56, 70, "#fff0e0", "#f0b8b0"); cloudp(250, 24, 40, "#fff0e0", "#f0b8b0")
  fill(E(70, 150, 30, 30):clip(R(0, 0, 479, 156)), "#fff6c8")
  layer({ { 100, 140, .5 }, { 350, 144, .4 } }, 160, { hi = "#f8d8b8", base = "#e0a890", shade = "#b87c80", deep = "#8a5870" }, 7, .4, 200, "#f0c8a8")
  local DN = RR("#ffe4a8", "#f0b878", "#c07a58", "#744050")
  GX.ground(c, function(x) return 174 + floor(8 * sin(x / 52) + 3 * sin(x / 17)) end, DN, 5, { top = .9, fall = .6, tex = .3 })
  for i = 0, 90 do local x, y = floor(H(i, 1, 2) * 480), 180 + floor(H(i, 2, 2) * 90); for k = 0, 4 do P(x + k, y - floor(k / 3), "#ffe4b0") end end
  local gy = 238
  -- far legs
  local SKN = RR("#d8c890", "#a8946a", "#6e5a58", "#44343c")
  local function leg(x0, w, far)
    local m = PL({ { x0, 190 }, { x0 + w, 190 }, { x0 + w + 4, gy - 4 }, { x0 + w + 8, gy + 8 }, { x0 - 8, gy + 8 }, { x0 - 4, gy - 4 } })
    litL(m, far and RR(SKN.shade, SKN.shade, SKN.deep, SKN.deep) or SKN, x0, { R = 8, tex = .5, sc = 3 })
    vor(m, 5, 4, 77 + x0, function(x, y, qx, qy, id, d1, gap) if gap < 1 then shadeTo(x, y, "#2e2030", .5) end end)
    for k = 0, 2 do fill(R(x0 - 6 + k * 6, gy + 5, x0 - 3 + k * 6, gy + 8), "#e8d8b0") end
  end
  leg(168, 38, true); leg(318, 40, true)
  -- tail and head
  local tail = limb({ { 380, 200 }, { 404, 206 }, { 420, 218 } }, 6, 2, 8); c:rim(tail, INK); lit(tail, SKN, 9, { R = 3, tex = .4, ink = false })
  local neck = limb({ { 130, 196 }, { 104, 186 }, { 78, 190 } }, 14, 11, 10)
  local head = E(62, 192, 20, 15):add(PL({ { 70, 186 }, { 44, 196 }, { 46, 208 }, { 70, 206 } }))
  local hh = neck:copy():add(head)
  litL(hh, SKN, 11, { R = 10, tex = .5, sc = 3 })
  vor(hh, 5, 4, 12, function(x, y, qx, qy, id, d1, gap) if gap < 1 then shadeTo(x, y, "#2e2030", .45) end end)
  fill(PL({ { 44, 198 }, { 62, 202 }, { 62, 204 }, { 44, 204 } }), "#6e5a58")
  P(46, 198, INK); fill(E(60, 184, 5, 4), "#ffe49a"); fill(E(60, 184, 2, 3), INK); P(58, 183, "#fffbe0")
  ln(48, 180, 70, 178, "#6e5a58", 2)
  -- the shell: big patterned dome
  local shell = rough(E(250, 192, 150, 100):clip(R(90, 72, 410, 212)), 21)
  local SHELLR = RR("#f6c880", "#c8884a", "#8a5048", "#4a2c40")
  litL(shell, SHELLR, 22, { R = 56, tex = .2, sc = 5 })
  local pal = { "#d8603a", "#2aa09a", "#f2b84a", "#8a4a8c", "#e8884a" }
  vor(shell, 36, 28, 41, function(x, y, qx, qy, id, d1, gap)
    local o = c:get(x, y); if not o then return end
    local col = pal[1 + floor(id * 5) % 5]
    local ring = floor(d1 / 4) % 3
    if gap < 1.5 then P(x, y, mix(o, "#2e1c26", .72))
    elseif x < qx and y < qy and gap < 3 then P(x, y, mix(o, "#fff1cf", .4))
    elseif ring == 0 then P(x, y, mix(o, col, .62))
    elseif ring == 1 then P(x, y, mix(o, "#fff1cf", .22))
    else P(x, y, mix(o, col, .3)) end
  end)
  -- marginal scutes along the shell hem
  for k = 0, 19 do local xx = 112 + k * 14; local m = R(xx, 200, xx + 12, 212); m:clip(shell); c:rim(m, INK); fill(m, k % 2 == 0 and "#c8884a" or "#a8663e"); fill(R(xx, 200, xx + 12, 201), "#f6c880"); fill(R(xx, 210, xx + 12, 212), "#6a3a44") end
  c:rim(shell, INK)
  -- oasis on the shell crown
  local pond = rough(E(250, 78, 44, 6), 44); c:rim(pond, INK)
  pond:each(function(x, y) P(x, y, y < 78 and "#48b8d8" or "#2a8ac0"); if (x * 3 + y) % 7 == 0 then P(x, y, "#a8ecff") end end)
  for k = 0, 11 do local gx = 204 + k * 8; GX.tuft(c, gx, 82, RR("#bef08a", "#58b860", "#2e8450", "#1a5a40")) end
  palm(226, 80, 56, -12, 31); palm(276, 78, 70, 10, 32); palm(250, 74, 36, 3, 33)
  fill(R(244, 86, 256, 92), "#e8b078"); c:rim(R(244, 86, 256, 92), INK) -- tiny tent
  fill(PL({ { 242, 86 }, { 250, 76 }, { 258, 86 } }), "#e0443a"); c:rim(PL({ { 242, 86 }, { 250, 76 }, { 258, 86 } }), INK)
  -- near legs
  leg(130, 42, false); leg(284, 44, false)
  -- footprints and dust trail behind
  for i = 0, 8 do fill(E(430 + i * 5 - 20, 252 + (i % 2) * 6, 5, 2), "#a8663e"); dust(420 + i * 7, 246, 10, 3, "#f0c890", i) end
  for i = 0, 6 do fill(E(30 + i * 14, 256 + (i % 2) * 5, 5, 2), "#a8663e") end
  -- quirk: meerkat on the shell with a tiny water jug
  local mx, my = 150, 134
  litL(E(mx, my + 8, 4, 7), RR("#f8dcb0", "#d8a870", "#946048", "#5e3a3c"), 5, { R = 3, tex = 0 }); litL(E(mx, my, 3, 3), RR("#f8dcb0", "#d8a870", "#946048", "#5e3a3c"), 6, { R = 2, tex = 0 }); P(mx - 1, my, INK); P(mx + 1, my, INK)
  c:sparkle(300, 60); c:sparkle(120, 90)
end)

---------------------------------------------------------------- 11 labyrinth isle
local seedv = 12345
local function rnd() seedv = (seedv * 1103515245 + 12345) % 2147483648; return seedv / 2147483648 end
pic("wonder-the-labyrinth-isle", function()
  GX.bands(c, 0, 66, { "#7cb0e8", "#a0c8ee", "#c8e0f0", "#f4eed0" }, 4, .1)
  cloudp(90, 24, 60, "#fffaf0", "#cfe0ec"); cloudp(380, 34, 80, "#fffaf0", "#cfe0ec")
  -- sea
  for y = 62, 269 do for x = 0, 479 do local t = (y - 62) / 208; local n = GX.vn(x, y * 2, 12, 5); local cols = { "#6ad0d8", "#48b8d0", "#38a0c8", "#2a88b8", "#2070a8" }; P(x, y, cols[max(1, min(5, 1 + floor((t * .8 + (n - .5) * .3) * 5)))]) end end
  for i = 0, 150 do local x, y = floor(H(i, 1, 4) * 470), 66 + floor(H(i, 2, 4) * 200); for k = 0, 4 + floor(H(i, 3, 4) * 6) do P(x + k, y, "#c8f4f0") end end
  -- far sail and sea stack
  fill(PL({ { 390, 62 }, { 390, 50 }, { 402, 62 } }), "#fff1cf"); fill(R(388, 62, 404, 63), "#6a4a48")
  -- island: beach ring + grass
  local iso = rough(E(240, 168, 232, 104), 9)
  lit(iso, RR("#fff0c0", "#f0d090", "#c89a6a", "#8a6a58"), 2, { R = 30, tex = .3 })
  local grass = rough(E(240, 166, 216, 94), 10)
  c:rim(grass, "#c89a6a")
  grass:each(function(x, y) local n = GX.vn(x, y, 6, 3); P(x, y, n > .6 and "#7cc858" or (n < .3 and "#4e9c48" or "#62b050")) end)
  for i = 0, 40 do local x = floor(H(i, 3, 3) * 470); local y = 130 + floor(H(i, 4, 3) * 130); if grass:has(x, y) then GX.flower(c, x, y, ({ "#ff8aa8", "#ffe07a", "#fff1cf" })[1 + i % 3]) end end
  -- maze
  local cols, rows, px, py, wx, wy, hh = 22, 12, 18, 13, 4, 3, 5
  local x0, y0 = 40, 92
  local inside = {}
  for j = 0, rows - 1 do inside[j] = {} for i = 0, cols - 1 do
    local u, v = (i + .5 - cols / 2) / (cols / 2), (j + .5 - rows / 2) / (rows / 2)
    inside[j][i] = (u * u + v * v) <= 1.02
  end end
  local vis, passV, passH = {}, {}, {}  -- passV[j][i]: opening between (i-1,j) and (i,j); passH[j][i]: between (i,j-1),(i,j)
  for j = 0, rows do vis[j] = {} passV[j] = {} passH[j] = {} end
  local function ins(i, j) return i >= 0 and j >= 0 and i < cols and j < rows and inside[j][i] end
  seedv = 777
  local sx_, sy_ = 11, 6
  local stack = { { sx_, sy_ } }; vis[sy_][sx_] = true
  while #stack > 0 do
    local cur = stack[#stack]; local i, j = cur[1], cur[2]
    local opts = {}
    for _, dd in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do local ni, nj = i + dd[1], j + dd[2]; if ins(ni, nj) and not vis[nj][ni] then opts[#opts + 1] = { ni, nj, dd } end end
    if #opts == 0 then stack[#stack] = nil else
      local o = opts[1 + floor(rnd() * #opts)]
      if o[3][1] == 1 then passV[j][i + 1] = true elseif o[3][1] == -1 then passV[j][i] = true elseif o[3][2] == 1 then passH[j + 1][i] = true else passH[j][i] = true end
      vis[o[2]][o[1]] = true; stack[#stack + 1] = { o[1], o[2] }
    end
  end
  -- extra openings for loops and an open plaza in the centre
  for k = 1, 22 do local i, j = 1 + floor(rnd() * (cols - 2)), 1 + floor(rnd() * (rows - 2)); if ins(i, j) and ins(i - 1, j) then passV[j][i] = true end end
  for j = 5, 6 do for i = 9, 12 do passV[j][i] = true end end
  for i = 9, 12 do passH[6][i] = true end
  -- entrance at the bottom
  local ei = 11; while not ins(ei, rows - 1) do ei = ei + 1 end
  passH[rows][ei] = true
  -- floor paths (sand) with speckle
  for j = 0, rows - 1 do for i = 0, cols - 1 do if inside[j][i] then
    local rx0, ry0 = x0 + i * px + wx, y0 + j * py + wy
    local rx1, ry1 = x0 + (i + 1) * px - 1, y0 + (j + 1) * py - 1
    for yy = ry0, ry1 do for xx = rx0, rx1 do P(xx, yy, (H(xx, yy, 5) > .86) and "#d8b078" or "#f4dc9c") end end
    if passV[j][i] then for yy = ry0, ry1 do for xx = rx0 - wx, rx0 - 1 do P(xx, yy, "#f4dc9c") end end end
    if passH[j][i] then for yy = ry0 - wy, ry0 - 1 do for xx = rx0, rx1 do P(xx, yy, "#f4dc9c") end end end
  end end end
  -- hedge walls, drawn back to front
  local walls = {}
  for j = 0, rows do for i = 0, cols do
    -- horizontal wall above row j at column i
    local a, b = ins(i, j - 1), ins(i, j)
    if (a or b) and not passH[j][i] then walls[#walls + 1] = { x0 + i * px, y0 + j * py, x0 + (i + 1) * px + wx - 1, y0 + j * py + wy - 1, 1 } end
    local l, r = ins(i - 1, j), ins(i, j)
    if (l or r) and not passV[j][i] and j < rows then walls[#walls + 1] = { x0 + i * px, y0 + j * py, x0 + i * px + wx - 1, y0 + (j + 1) * py + wy - 1, 0 } end
  end end
  table.sort(walls, function(a, b) if a[4] ~= b[4] then return a[4] < b[4] end return a[5] < b[5] end)
  local HG = RR("#bef06a", "#58b048", "#2e7a44", "#1a4a38")
  for _, w in ipairs(walls) do
    local X0, Y0, X1, Y1 = w[1], w[2], w[3], w[4]
    -- front (south) face
    for yy = Y1 - hh + 1, Y1 do for xx = X0, X1 do local n = H(xx, yy, 8); P(xx, yy, n > .75 and HG.base or (yy == Y1 and HG.deep or HG.shade)) end end
    -- top face lifted by hh
    for yy = Y0 - hh, Y1 - hh do for xx = X0, X1 do
      local n = GX.vn(xx, yy, 2.5, 6); local col = n > .62 and HG.hi or (n < .3 and HG.base or "#78c858")
      if yy == Y0 - hh then col = HG.hi end
      P(xx, yy, col)
    end end
    P(X0, Y0 - hh, HG.deep); P(X1, Y0 - hh, HG.base)
  end
  -- centre: fountain plaza with gold gnome statue (non-player)
  local cx, cy = x0 + 11 * px + wx, y0 + 6 * py + 4
  litL(E(cx, cy + 6, 22, 8), RR("#e8e8e0", "#a8a8b8", "#686880", "#444458"), 3, { R = 6, tex = .3 })
  fill(E(cx, cy + 5, 18, 5), "#48b8d8"); fill(E(cx, cy + 4, 12, 3), "#a8ecff")
  litL(R(cx - 4, cy - 14, cx + 4, cy + 4), RR("#e8e8e0", "#a8a8b8", "#686880", "#444458"), 4, { R = 3, tex = 0 })
  litL(E(cx, cy - 22, 5, 7), RR("#fff0a0", "#f2b84a", "#c0742c", "#7a4030"), 5, { R = 4, tex = 0 })
  local hat = PL({ { cx - 5, cy - 26 }, { cx, cy - 40 }, { cx + 5, cy - 26 } }); c:rim(hat, INK); fill(hat, "#f2b84a"); P(cx - 1, cy - 34, "#fff0b8")
  c:sparkle(cx, cy - 46)
  -- entrance dock and little boat
  fill(R(ei * px + x0 + wx - 4, y0 + rows * py + 2, ei * px + x0 + wx + 14, 268), "#9a6a48")
  for k = 0, 8 do ln(ei * px + x0 + wx - 4, 250 + k * 2, ei * px + x0 + wx + 14, 250 + k * 2, "#6a4a3c", 1) end
  -- quirk: lost goat wandering a path
  local gx_, gy_ = x0 + 5 * px + 8, y0 + 8 * py + 8
  litL(E(gx_, gy_ + 1, 5, 3), RR("#fff6e8", "#e0d4c8", "#a89aa4", "#6a5a6e"), 3, { R = 3, tex = 0 }); fill(E(gx_ + 5, gy_ - 2, 2, 2), "#e0d4c8"); P(gx_ + 6, gy_ - 5, INK); P(gx_ + 4, gy_ - 5, INK); fill(R(gx_ - 3, gy_ + 3, gx_ - 3, gy_ + 5), INK); fill(R(gx_ + 3, gy_ + 3, gx_ + 3, gy_ + 5), INK)
  for i = 1, 20 do c:sparkle(floor(H(i, 5, 5) * 470) + 4, 72 + floor(H(i, 6, 5) * 190)) end
end)

---------------------------------------------------------------- 12 tea garden slopes
pic("wonder-tea-garden-slopes", function()
  GX.bands(c, 0, 150, { "#8ed0d8", "#b8e4d0", "#e8f0c0", "#fff0b8", "#ffe0a0" }, 3, .12)
  cloudp(80, 28, 70, "#fffaf0", "#d8ecdc"); cloudp(250, 18, 56, "#fffaf0", "#d8ecdc"); cloudp(430, 40, 60, "#fffaf0", "#d8ecdc")
  fill(E(110, 112, 22, 22), "#fff6c8")
  layer({ { 40, 90, .7 }, { 200, 100, .6 }, { 420, 86, .8 } }, 140, { hi = "#c8ecd0", base = "#98d0b0", shade = "#70b49c", deep = "#4a9488" }, 5, .5, 200, "#e8f4d0")
  layer({ { 120, 110, .5 }, { 360, 112, .4 }, { 470, 100, .6 } }, 140, { hi = "#a8dc98", base = "#6cb878", shade = "#4a9a6c", deep = "#307a60" }, 8, .3, 200, "#d8ecb8")
  local function hillTop(x) return 112 + floor(34 * ((x - 330) / 330) ^ 2 + 4 * sin(x / 30)) end
  -- hilltop grass
  for x = 0, 479 do for y = hillTop(x) - 4, 270 do local n = GX.vn(x, y, 6, 4); P(x, y, n > .6 and "#9ad45a" or (n < .3 and "#5fae48" or "#78c452")) end end
  local spacing = { 26, 34, 24, 38, 30, 42, 50 }
  local TYPES = {
    { RR("#9ad45a", "#4aa048", "#2e7a44", "#1e5438"), "#4aa048" },
    { RR("#d8f080", "#8ccc48", "#5a9a44", "#3a6a3c"), "#8ccc48" },
    { RR("#a8dc68", "#4e9a48", "#2e6e44", "#1e4a38"), "#ff9ab8" },
    { RR("#e8b078", "#b87a4e", "#7a4a40", "#4a2c3c"), "#8ccc48" },
    { RR("#88c8a0", "#3e8a68", "#2a6458", "#1a4448"), "#c8f0e8" },
    { RR("#b8e070", "#62a848", "#3a7a44", "#244e38"), "#ffe07a" },
    { RR("#9ad45a", "#4aa048", "#2e7a44", "#1e5438"), "#4aa048" },
  }
  local base = hillTop(0)
  local edges = {}
  local acc = {}
  for k = 1, 7 do edges[k] = {} end
  for x = 0, 479 do
    local y = hillTop(x) + 12
    for k = 1, 7 do
      local sp = spacing[k] + floor(5 * sin(x / (24 + k * 7) + k * 1.7))
      edges[k][x] = y; y = y + sp
    end
  end
  local WALL = RR("#e8d4a8", "#b49a7a", "#7c6a6a", "#4a3c4c")
  for k = 1, 7 do
    local T = TYPES[k]; local R6t = GX.ramp6(T[1])
    for x = 0, 479 do
      local yt = edges[k][x]; local yn = (k < 7) and edges[k + 1][x] or 270
      local surf = floor((yn - yt) * .62)
      for y = yt, min(269, yn - 1) do
        if y - yt < surf then
          local v = .55 + (GX.vn(x, y, 4, k) - .5) * .5 - (y - yt) / max(1, surf) * .15
          if y == yt then v = .95 end
          P(x, y, R6t[GX.idx(v)])
        else
          local bw = (floor((y - yt) / 4) % 2 == 0) and 0 or 5
          local brick = ((x + bw) % 10 == 0) or ((y - yt) % 4 == 3)
          local col = brick and WALL.shade or WALL.base
          if y - yt == surf then col = WALL.hi end
          if y == yn - 1 then col = WALL.deep end
          if GX.vn(x, y, 3, k + 9) > .75 and not brick then col = WALL.hi end
          P(x, y, col)
        end
      end
    end
    -- bush rows
    local rowsN = (k == 4) and 0 or 2
    for r = 1, rowsN do
      for xx = (r % 2) * 5, 479, 10 do
        local yt = edges[k][min(479, xx)]; local yn = (k < 7) and edges[k + 1][min(479, xx)] or 270
        local surf = floor((yn - yt) * .62)
        local by = yt + floor(surf * r / (rowsN + .6)) + 2
        if by < yt + surf - 1 and by < 266 then
          local m = E(xx, by, 6, 3 + (k > 4 and 1 or 0))
          lit(m, T[1], xx + k, { R = 3, tex = .4, ink = false, sc = 2 })
          m:each(function(x, y) if not m:has(x, y + 1) then P(x, y, T[1].deep) end end)
          if H(xx, k, r) > .45 then P(xx - 2, by - 2, T[2]); P(xx + 1, by - 1, T[2]) end
        end
      end
    end
    if k == 4 then for xx = 3, 479, 6 do local yt = edges[k][xx]; local yn = edges[k + 1][xx]; for y = yt + 2, yt + floor((yn - yt) * .62) - 2, 5 do P(xx, y, "#8ccc48"); P(xx + 1, y - 1, "#8ccc48") end end end
    -- mist between tiers
    if k == 2 or k == 5 then
      for x = 0, 479 do for y = edges[k][x] - 6, edges[k][x] + 4 do if (x + y) % 2 == 0 and GX.vn(x, y, 12, 3 + k) > .5 then shadeTo(x, y, "#fffaf0", .5) end end end
    end
  end
  -- switchback stone path to the teapot
  local path = limb({ { 110, 270 }, { 150, 236 }, { 96, 206 }, { 170, 176 }, { 120, 156 }, { 220, 140 }, { 290, 130 } }, 5, 3, 14)
  c:rim(path, "#7c6a6a"); path:each(function(x, y) P(x, y, ((x // 3 + y // 2) % 2 == 0) and "#f4e4b8" or "#d8c498") end)
  -- giant teapot house
  local tx, ty = 346, 96
  local TP = RR("#ffb09a", "#e0584a", "#a83a48", "#6a2440")
  fill(E(tx, ty + 34, 62, 6), "#3e6a3c")
  local spout = limb({ { tx - 40, ty + 14 }, { tx - 64, ty + 4 }, { tx - 74, ty - 22 }, { tx - 86, ty - 34 } }, 11, 5, 14)
  local handle = E(tx + 56, ty + 8, 22, 26):cut(E(tx + 56, ty + 8, 13, 18)):cut(R(tx - 10, ty - 40, tx + 36, ty + 50))
  local body = E(tx, ty + 6, 56, 38)
  local lid = E(tx, ty - 28, 26, 8)
  local dome = E(tx, ty - 34, 18, 12):clip(R(tx - 30, ty - 50, tx + 30, ty - 30))
  local all = spout:copy():add(handle):add(body):add(lid):add(dome)
  c:rim(all, INK)
  lit(handle, TP, 3, { R = 5, tex = .2, ink = false }); lit(spout, TP, 4, { R = 6, tex = .2, ink = false })
  lit(body, TP, 5, { R = 34, tex = .2, ink = false })
  lit(dome, RR("#fff1cf", "#f0d090", "#c09068", "#7a5058"), 6, { R = 8, tex = .2, ink = false })
  lit(lid, TP, 7, { R = 5, tex = .2, ink = false })
  lit(E(tx, ty - 47, 5, 5), RR("#fff0a0", "#f2b84a", "#c0742c", "#7a4030"), 8, { R = 3, tex = 0 })
  -- cream pattern band with gold blossoms
  body:each(function(x, y) local yy = y - (ty - 6); if yy >= 0 and yy <= 9 then local o = c:get(x, y); P(x, y, (yy == 0 or yy == 9) and "#f2b84a" or mix(o, "#fff1cf", .78)) end end)
  for k = -5, 5 do local bx = tx + k * 10 - (k % 2) * 0; local o = body:has(bx, ty - 1); if o then fill(E(bx, ty - 1, 2, 2), "#e0584a"); P(bx, ty - 1, "#f2b84a"); P(bx - 2, ty - 1, "#6aa848"); P(bx + 2, ty - 1, "#6aa848") end end
  -- door, windows, spout opening
  local door = E(tx, ty + 24, 9, 10):add(R(tx - 9, ty + 24, tx + 9, ty + 34)); c:rim(door, INK); fill(door, "#3a1c30"); fill(E(tx, ty + 28, 5, 6), "#ffcf6a")
  for _, wx_ in ipairs{ -32, 32 } do local w = E(tx + wx_, ty + 14, 5, 5); c:rim(w, INK); fill(w, "#ffe49a"); P(tx + wx_ - 2, ty + 12, "#fff6d8"); ln(tx + wx_ - 5, ty + 14, tx + wx_ + 5, ty + 14, "#a83a48", 1) end
  fill(E(tx - 86, ty - 35, 5, 2), "#3a1c30")
  -- steam
  for i, q in ipairs{ { -88, -46, 6 }, { -80, -62, 8 }, { -92, -80, 9 }, { -82, -98, 10 } } do
    local m = rough(E(tx + q[1], ty + q[2], q[3], q[3] - 1), 60 + i); fill(m, "#fff6e4"); fill(m:copy():shift(1, 2):cut(m), "#e8d8cc")
    m:each(function(x, y) if not m:has(x - 1, y - 1) then P(x, y, "#ffffee") end end)
  end
  for i, q in ipairs{ { 4, -62, 5 }, { -2, -76, 7 }, { 6, -92, 7 } } do fill(rough(E(tx + q[1], ty + q[2], q[3], q[3] - 1), 70 + i), "#fff6e4") end
  -- tiny pickers (non-player gnomes) with baskets
  for _, g in ipairs{ { 60, 210 }, { 220, 182 }, { 400, 232 }, { 300, 196 } } do
    local gx_, gy_ = g[1], g[2]
    fill(R(gx_ - 2, gy_ - 6, gx_ + 2, gy_), "#e8884a"); fill(R(gx_ - 1, gy_ - 9, gx_ + 1, gy_ - 7), "#f8d0a8")
    fill(PL({ { gx_ - 3, gy_ - 8 }, { gx_, gy_ - 15 }, { gx_ + 3, gy_ - 8 } }), "#d8483a"); fill(R(gx_ + 3, gy_ - 4, gx_ + 6, gy_ - 1), "#c8884a")
  end
  -- quirk: cat napping on the wall
  local cx_, cy_ = 150, 238
  litL(E(cx_, cy_, 7, 4), RR("#ffd8a0", "#e89a4a", "#a8603c", "#5e3a3c"), 3, { R = 3, tex = 0 }); litL(E(cx_ - 6, cy_ - 1, 3, 3), RR("#ffd8a0", "#e89a4a", "#a8603c", "#5e3a3c"), 4, { R = 2, tex = 0 })
  P(cx_ - 7, cy_ - 4, "#e89a4a"); P(cx_ - 5, cy_ - 4, "#e89a4a"); ln(cx_ + 7, cy_, cx_ + 12, cy_ - 2, "#e89a4a", 1)
  for i = 1, 14 do c:sparkle(floor(H(i, 5, 5) * 470) + 4, floor(H(i, 6, 5) * 120) + 10) end
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
