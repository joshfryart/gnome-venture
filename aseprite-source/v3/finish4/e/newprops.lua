--------------------------------------------------------------------------- finish4 props
-- tall trunk + layered canopy of separately lit clumps (back clumps darker, lit clumps in front/upper-left)
function P.tree(x, by, o)
  local h = o.h or 60
  local rw = o.rw or floor(h * .42)
  local rh = o.rh or floor(h * .3)
  local TR, RR = o.TR or C.BARK, o.R or C.GREEN
  local seed = o.seed or x
  local cy = by - h + rh
  SH(x + rw * .4, by, max(9, floor(rw * .6)))
  local tw = o.tw or 2
  local top = cy + floor(rh * .1)
  local tm = mk()
  for y = top, by do
    local t = (y - top) / max(1, by - top)
    local half = tw + .5 + t * 1.4 + ((y > by - 5) and (y - (by - 5)) * 1.0 or 0)
    local wob = floor((GX.vn(0, y, 11, seed) - .5) * 3)
    for xx = floor(x - half + wob), floor(x + half + wob) do tm:set(xx, y) end
  end
  tm:add(LN({ { x, cy + rh * .6 }, { x - rw * .5, cy - rh * .1 } }, 2))
  tm:add(LN({ { x, cy + rh * .5 }, { x + rw * .55, cy - rh * .05 } }, 2))
  L(tm, TR, seed, { R = 4, nr = true, tex = .35, sc = 3, rimlight = true,
    fn = function(xx, yy) return (((xx - x) % 3 == 0) and -.14 or 0) + ((H(xx, yy // 3, seed) < .08) and -.2 or 0) end })
  if o.marks then for yy = top + 8, by - 3, 5 do for k = 0, 1 do c:px(x - 1 + k * 2 + (yy % 3), yy, C.BIRCH.deep) end end end
  -- clumps
  local cl = {}
  local N = max(7, floor(rw / 3.6))
  for i = 1, N do
    local a = H(i, seed, 1) * 6.283
    local rr = sqrt(H(i, seed, 2)) * .8
    cl[#cl + 1] = { x = x + cos(a) * rw * rr * .9, y = cy + sin(a) * rh * rr * .85 + rh * .08, r = floor(rh * .52 + H(i, seed, 3) * rh * .3) }
  end
  cl[#cl + 1] = { x = x - rw * .55, y = cy + rh * .15, r = floor(rh * .6) }
  cl[#cl + 1] = { x = x + rw * .55, y = cy + rh * .2, r = floor(rh * .55) }
  cl[#cl + 1] = { x = x - rw * .15, y = cy - rh * .35, r = floor(rh * .75) }
  table.sort(cl, function(a, b) return a.y < b.y end)
  for i, k in ipairs(cl) do
    local f = (i - 1) / max(1, #cl - 1)         -- 0 back .. 1 front
    local m = mk(); E(m, floor(k.x), floor(k.y), k.r + 1, k.r)
    m = GX.rough(m, seed + i, 1)
    local dim = .45 * (1 - f)
    local Rd = { hi = mix6 and 0 or GX.mix(RR.hi, RR.shade, dim), base = GX.mix(RR.base, RR.shade, dim), shade = GX.mix(RR.shade, RR.deep, dim), deep = RR.deep }
    GX.lit(c, m, GX.ramp6(Rd), { R = k.r + 2, tex = .55, sc = 3, seed = seed + i, amb = .2 + .1 * f, rimlight = true,
      fn = function(xx, yy) return (H(xx // 2, yy // 2, seed + i) - .5) * .25 end })
    -- lit leaf dabs on the upper-left
    for j = 1, 3 do
      local lx = floor(k.x - k.r * .5 + H(j, i, seed) * k.r * .6)
      local ly = floor(k.y - k.r * .55 + H(j, i, seed + 4) * k.r * .5)
      if m:has(lx, ly) and m:has(lx + 3, ly + 1) then
        c:px(lx, ly, RR.hi); c:px(lx + 1, ly, RR.hi); c:px(lx + 2, ly, RR.hi); c:px(lx + 1, ly + 1, RR.base); c:px(lx - 1, ly + 1, RR.base)
      end
    end
    if o.fruit and i % 3 == 0 then c:px(floor(k.x) + 2, floor(k.y) + 2, C.RED.base); c:px(floor(k.x) + 3, floor(k.y) + 2, C.RED.hi) end
  end
end

local function onion(cx, by, Rr, hgt, Rm, seed, o)
  o = o or {}
  local m = mk()
  for y = by - hgt, by do
    local t = (by - y) / hgt
    local w
    if t < .28 then w = Rr * (.8 + .2 * sin(t / .28 * pi / 2))
    else local u = (t - .28) / .72; w = Rr * (1 - u ^ 1.6) ^ .72 end
    if t > .86 then w = w * (1 - ((t - .86) / .14) ^ 1.2 * .3) end
    for xx = floor(cx - w), floor(cx + w) do m:set(xx, y) end
  end
  L(m, Rm, seed, { R = Rr, nr = true, tex = .2, rimlight = true, amb = .22,
    fn = function(xx, yy) return (((xx - cx + 200) % 7 == 0) and -.1 or 0) + (o.fn and o.fn(xx, yy) or 0) end })
  return by - hgt
end
function P.palace(x, by, o)
  local WHT = rp("#fffaf0", "#f4eadc", "#b8a6cc", "#6e5a92")
  local SAND = rp("#fff0d0", "#e8cc9c", "#b8946c", "#7a5a56")
  local DOOR = rp("#6e5a82", "#4a3a64", "#2e2448", "#1c1630")
  SH(x + 30, by, 100)
  -- plinth
  L(R(mk(), x - 82, by - 8, x + 82, by), SAND, x, { R = 5, nr = true, rimlight = true, fn = function(xx, yy) return ((xx // 6) % 2 == 0 and yy == by - 4) and -.12 or 0 end })
  L(R(mk(), x - 56, by - 11, x + 56, by - 8), SAND, x + 1, { R = 2, nr = true, rimlight = true })
  -- hall
  local hy = by - 11
  L(R(mk(), x - 48, hy - 28, x + 48, hy), WHT, x, { R = 12, nr = true, rimlight = true, tex = .2 })
  for k = -2, 2 do
    local ax, w, hh = x + k * 18, (k == 0) and 9 or 6, (k == 0) and 24 or 16
    if k == 0 then ax = x end
    local m = c:poly{ { ax - w, hy }, { ax - w, hy - hh * .6 }, { ax, hy - hh }, { ax + w, hy - hh * .6 }, { ax + w, hy } }
    c:rim(m, INK); L(m, DOOR, ax, { R = 4, nr = true, ink = false, tex = .1, amb = .1 })
    c:fillMask(c:poly{ { ax - w - 1, hy - hh * .6 }, { ax, hy - hh - 2 }, { ax - 1, hy - hh - 1 } }, WHT.shade)
  end
  L(R(mk(), x - 50, hy - 31, x + 50, hy - 28), C.GOLD, x, { R = 2, nr = true, rimlight = true })
  -- wing chhatris
  for _, s in ipairs{ -1, 1 } do
    local cx = x + s * 38
    L(R(mk(), cx - 4, hy - 38, cx - 3, hy - 31), WHT, cx, { R = 1, nr = true }); L(R(mk(), cx + 3, hy - 38, cx + 4, hy - 31), WHT, cx + 1, { R = 1, nr = true })
    local t = onion(cx, hy - 37, 7, 13, WHT, cx)
    c:px(cx, t - 1, C.GOLD.hi); c:px(cx, t - 2, C.GOLD.base)
  end
  -- drum + big dome
  local dy = hy - 31
  L(R(mk(), x - 22, dy - 14, x + 22, dy), WHT, x, { R = 10, nr = true, rimlight = true })
  for k = -2, 2 do c:fillMask(R(mk(), x + k * 8 - 1, dy - 10, x + k * 8 + 1, dy - 4), DOOR.base); c:px(x + k * 8 - 1, dy - 10, DOOR.hi) end
  L(R(mk(), x - 24, dy - 17, x + 24, dy - 14), C.GOLD, x, { R = 2, nr = true, rimlight = true })
  local top = onion(x, dy - 17, 26, 42, WHT, x + 3)
  -- gold finial: stacked balls, spike, crescent
  for k = 0, 11 do c:px(x, top - k, INK); c:px(x + 1, top - k, INK) end
  for k = 1, 10 do c:px(x, top - k, C.GOLD.base) end
  for _, yy in ipairs{ top - 3, top - 7 } do L(E(mk(), x, yy, 2, 2), C.GOLD, x, { R = 2, nr = true }) end
  c:px(x - 2, top - 11, C.GOLD.hi); c:px(x + 2, top - 11, C.GOLD.base); c:px(x - 2, top - 12, C.GOLD.base); c:px(x + 2, top - 12, C.GOLD.shade); c:px(x, top - 13, C.GOLD.hi); c:px(x, top - 12, C.GOLD.hi)
  -- minarets
  for _, s in ipairs{ -1, 1 } do
    local mx = x + s * 84
    local mh = 80
    L(R(mk(), mx - 8, by - 11, mx + 8, by - 8), SAND, mx, { R = 2, nr = true, rimlight = true })
    local body = c:poly{ { mx - 6, by - 10 }, { mx - 4, by - 10 - mh }, { mx + 4, by - 10 - mh }, { mx + 6, by - 10 } }
    L(body, WHT, mx, { R = 6, nr = true, rimlight = true, fn = function(xx, yy) return (((by - yy) // 8) % 2 == 0) and 0 or -.12 end })
    for _, gy in ipairs{ 28, 54, mh } do
      local yy = by - 10 - gy
      L(R(mk(), mx - 8, yy, mx + 8, yy + 3), C.GOLD, mx + gy, { R = 2, nr = true, rimlight = true })
      c:px(mx - 8, yy + 4, INK); c:px(mx + 8, yy + 4, INK)
    end
    for _, gy in ipairs{ 12, 40, 66 } do c:fillMask(R(mk(), mx - 1, by - 10 - gy - 6, mx, by - 10 - gy), DOOR.base) end
    local ty = by - 10 - mh - 1
    for _, px_ in ipairs{ mx - 5, mx + 4 } do L(R(mk(), px_, ty - 8, px_ + 1, ty), WHT, px_, { R = 1, nr = true }) end
    local t = onion(mx, ty - 8, 6, 13, WHT, mx + 5)
    c:px(mx, t - 1, INK); c:px(mx, t - 2, C.GOLD.hi); c:px(mx, t - 3, C.GOLD.base); c:px(mx - 1, t - 3, C.GOLD.base); c:px(mx + 1, t - 3, C.GOLD.shade)
  end
end

function P.monolith(x, by, o)
  local base = { { -102, 3 }, { -99, -9 }, { -94, -22 }, { -84, -36 }, { -68, -47 }, { -44, -54 }, { -16, -58 }, { 12, -59 }, { 40, -56 }, { 66, -48 }, { 84, -37 }, { 94, -24 }, { 99, -10 }, { 103, 3 } }
  local pts = {}
  for i, p in ipairs(base) do pts[#pts + 1] = { x + p[1] + floor((GX.vn(i * 7, 0, 2, 5) - .5) * 3), by + p[2] + floor((GX.vn(i * 3, 9, 2, 6) - .5) * 4) } end
  local m = c:poly(pts)
  local U = o.R or rp("#ffa468", "#e0603a", "#a63a40", "#5c2846")
  SH(x + 20, by + 1, 110)
  L(m, U, 17, { R = 30, tex = .22, sc = 4, amb = .3, nr = true, rimlight = true,
    fn = function(xx, yy)
      local v = -(xx - x + 14) / 200 * 1.0
      local sb = (by - yy + floor(3 * sin(xx / 21) + 2 * sin(xx / 7))) // 6
      local line = ((by - yy + floor(3 * sin(xx / 21) + 2 * sin(xx / 7))) % 6 == 0) and -.2 or 0
      v = v + line + ((sb % 3 == 0) and .08 or ((sb % 3 == 1) and -.05 or 0))
      local fl = GX.vn(xx, yy * .16, 3.2, 8)
      if fl < .3 and yy > by - 46 then v = v - .22 end
      return v
    end })
  -- cave overhangs + water stains
  for _, p in ipairs{ { -64, -10, 9, 4 }, { -22, -5, 6, 3 }, { 46, -9, 8, 4 } } do
    local cm = E(mk(), x + p[1], by + p[2], p[3], p[4]); cm:clip(m)
    c:rim(cm, INK); c:fillMask(cm, U.deep)
    for _, q in ipairs(cm:copy():cut(cm:shift(0, 1)):shift(0, 0).s and {} or {}) do end
  end
  for k = 1, 7 do
    local sx = x - 80 + k * 22 + floor((H(k, 3, 3) - .5) * 8)
    local len = 14 + floor(H(k, 5, 3) * 16)
    local topy = by - 54 + floor(abs(sx - x + 10) * .22)
    for yy = topy + 3, topy + len do if m:has(sx, yy) then c:px(sx, yy, U.deep) end end
  end
  -- lit upper-left ridge + glints
  for xx = x - 70, x - 14 do local yy = by - 55 + floor((x - 14 - xx) * .16) - floor(abs(xx - x + 40) * .02); if m:has(xx, yy + 1) and H(xx, 1, 2) > .25 then c:px(xx, yy + 1, U.hi) end end
  -- scree + scrub at the foot
  for k = 0, 30 do
    local sx = x - 100 + floor(H(k, 2, 9) * 205)
    local sy = by + floor(H(k, 3, 9) * 3)
    c:fillMask(E(mk(), sx, sy, 3 + k % 3, 2), GX.mix(t_g or "#e6a070", U.shade, .35)); c:px(sx - 1, sy - 1, U.hi)
  end
  for _, sx in ipairs{ x - 88, x - 40, x + 6, x + 60, x + 96 } do
    L(E(mk(), sx, by + 1, 5, 3), rp("#d0d88c", "#8ca860", "#5c8450", "#3c5c46"), sx, { R = 4, nr = true, rimlight = true })
    c:px(sx - 1, by - 3, "#d0d88c"); c:px(sx + 2, by - 2, "#d0d88c")
  end
end

function P.mesa2(x, by, o)
  local w, h = o.w or 100, o.h or 64
  local tiers = o.tiers or {
    { .96, .27, rp("#d89070", "#b05a44", "#7c3a42", "#4e2a3c") },
    { .76, .25, rp("#ffc48a", "#e88a4c", "#b45a44", "#783c48") },
    { .62, .22, rp("#fff0b0", "#f0c070", "#c88a50", "#8c5a48") },
    { .70, .26, rp("#e89a72", "#c25a40", "#8a3a40", "#52283a") } }
  -- talus slopes
  local SD = rp("#fff0b8", "#f2c070", "#d08e52", "#9c5e3e")
  L(c:poly{ { x - w * .72, by + 2 }, { x - w * .42, by - h * .24 }, { x + w * .42, by - h * .24 }, { x + w * .72, by + 2 } }, SD, x, { R = 20, tex = .35, sc = 3, rimlight = true, fn = function(xx, yy) return -(xx - x) / w * .5 end })
  SH(x + 14, by, w * .6)
  local y = by - 2
  for i, t in ipairs(tiers) do
    local hw, th = w * t[1] / 2, h * t[2]
    local last = (i == #tiers)
    local lean = (i == #tiers) and 3 or 1
    local m = c:poly{ { x - hw, y }, { x - hw + lean + (last and 0 or 1), y - th }, { x + hw - lean - (last and 0 or 1), y - th }, { x + hw, y } }
    if last then m:add(R(mk(), x - hw - 3, y - th, x + hw + 3, y - th + 3)) end
    local yb, y0 = y, y - th
    L(m, t[3], 40 + i, { R = 14, tex = .3, sc = 3, nr = true, rimlight = true,
      fn = function(xx, yy)
        local fl = GX.vn(xx, yy * .2, 3, i + 3)
        return -(xx - x) / w * .55 + ((fl < .3) and -.2 or 0) + ((((yb - yy) % 5) == 0 and H(xx // 4, yy, i) > .5) and -.14 or 0) end })
    for xx = x - hw, x + hw do if m:has(xx, y0) then c:px(xx, y0, t[3].hi) end end
    c:fillMask(R(mk(), x - hw + 1, yb - 1, x + hw - 1, yb - 1):clip(m), t[3].deep)
    y = y - th
  end
  c:px(x - 20, y - 4, C.SANDST.hi)
end
