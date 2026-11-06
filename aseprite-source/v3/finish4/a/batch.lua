-- finish3/weak: eight redrawn WONDER/LAIR pictures with stronger focal subjects. Param name=<picture> (or all)
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

---------------------------------------------------------------- 1 pink river dolphin pools (finish4)
local PK = { "#ffe6ea", "#ffc4d2", "#f69cb8", "#dc7098", "#b24e82", "#7e3a6c" }
local GR = { "#e0b8c8", "#c08ea8", "#a4708f", "#865478", "#6a4066", "#503054" }
local FINR = RR("#d8a4bc", "#b07a9c", "#865478", "#5e3a5c")
local function bay(x, y) return ({ 0, .5, .75, .25 })[(x % 2) + 2 * (y % 2) + 1] end
local WTR = { "#8adcb4", "#62c4a0", "#46a890", "#348c84", "#287074", "#1e5864" }
local function foam(x0, x1, y) for x = x0, x1 do if (x + y) % 2 == 0 then P(x, y, "#e8fff0") else P(x, y + 1, "#b8f0e0") end end end
local function ring(x, y, rx, ry, col)
  local m = E(x, y, rx, ry):copy():cut(E(x, y, rx - 2, max(1, ry - 1)))
  m:each(function(xx, yy) if (xx + yy) % 3 ~= 0 then P(xx, yy, col or "#e8fff0") end end)
end
local function drops(cx, cy, n, spread, seed)
  for i = 1, n do
    local a = H(i, seed, 1) * 6.283; local r = H(i, seed, 2) * spread
    local x, y = cx + cos(a) * r, cy + sin(a) * r * .8
    local col = (i % 3 == 0) and "#ffffff" or ((i % 3 == 1) and "#d8fff0" or "#a8e8e0")
    if col == "#ffffff" then col = CREAM end
    P(x, y, col)
    if i % 3 == 0 then P(x, y + 1, col); P(x + 1, y, col); P(x + 1, y + 1, "#a8e8e0") end
    if i % 5 == 0 then P(x, y - 1, col) end
  end
end
local function dolphin(o)
  local sc, seed, clip = o.sc, o.seed, o.clip or 999
  local smp = {}
  local KT = { { 0, 2.2 }, { .15, 4 }, { .35, 9.5 }, { .55, 15 }, { .72, 16.5 }, { .86, 12.5 }, { .94, 10.5 }, { 1, 8 } }
  local rf = function(t)
    for i = 2, #KT do if t <= KT[i][1] then local a, b = KT[i - 1], KT[i]; local u = (t - a[1]) / (b[1] - a[1]); u = u * u * (3 - 2 * u); return (a[2] + (b[2] - a[2]) * u) * sc end end
    return 8 * sc
  end
  local body = spline(o.pts, 0, 0, rf, 16, smp)
  local N = #smp
  for i = 1, N do
    local a, b = smp[max(1, i - 1)], smp[min(N, i + 1)]
    local tx, ty = b[1] - a[1], b[2] - a[2]; local l = sqrt(tx * tx + ty * ty); if l == 0 then l = 1 end
    tx, ty = tx / l, ty / l
    smp[i].tx, smp[i].ty, smp[i].nx, smp[i].ny = tx, ty, ty, -tx
  end
  local function at(t) return smp[max(1, min(N, floor(t * (N - 1)) + 1))] end
  local hd = smp[N]
  local all = {}
  for i = 1, N do all[#all + 1] = smp[i] end
  -- melon: round bulging forehead
  local mcx, mcy = hd[1] + hd.tx * 1.5 * sc + hd.nx * 5.5 * sc, hd[2] + hd.ty * 1.5 * sc + hd.ny * 5.5 * sc
  disc(body, mcx, mcy, 10.5 * sc, 10.5 * sc)
  all[#all + 1] = { mcx, mcy, 10.5 * sc, nx = hd.nx, ny = hd.ny }
  -- beak: long thin
  local bdx, bdy = hd.tx - hd.nx * .12, hd.ty - hd.ny * .12
  local bl = sqrt(bdx * bdx + bdy * bdy); bdx, bdy = bdx / bl, bdy / bl
  local bsx, bsy = hd[1] + hd.tx * 5 * sc - hd.nx * 2.4 * sc, hd[2] + hd.ty * 5 * sc - hd.ny * 2.4 * sc
  local beak = {}
  for k = 0, 34 do
    local u = k / 34; local x, y, r = bsx + bdx * u * 26 * sc, bsy + bdy * u * 26 * sc, (3.9 - 2.3 * u) * sc
    disc(body, x, y, max(.8, r), max(.8, r)); local s = { x, y, r, nx = hd.nx, ny = hd.ny }; all[#all + 1] = s; beak[#beak + 1] = s
  end
  local tip = beak[#beak]
  -- tail fluke
  local T = smp[1]
  local bx, by = -T.tx, -T.ty; local ppx, ppy = T.ty, -T.tx
  local function tp(a, b2) return { T[1] + (bx * a + ppx * b2) * sc, T[2] + (by * a + ppy * b2) * sc } end
  local fl = PL({ tp(-1, 2), tp(3, 10), tp(10, 20), tp(8, 10), tp(4, 0), tp(8, -10), tp(10, -20), tp(3, -10), tp(-1, -2) })
  -- dorsal ridge (low)
  local d1, d2, d3 = at(.38), at(.47), at(.56)
  local dr = PL({ { d1[1] + d1.nx * (d1[3] - 2), d1[2] + d1.ny * (d1[3] - 2) },
    { d2[1] + d2.nx * (d2[3] + 5.5 * sc) - d2.tx * 2, d2[2] + d2.ny * (d2[3] + 5.5 * sc) - d2.ty * 2 },
    { d3[1] + d3.nx * (d3[3] - 2), d3[2] + d3.ny * (d3[3] - 2) } })
  -- big paddle flipper
  local f0 = at(.72)
  local fbx, fby = f0[1] - f0.nx * f0[3] * .72 + f0.tx * 3 * sc, f0[2] - f0.ny * f0[3] * .72 + f0.ty * 3 * sc
  local fdx, fdy = -f0.nx * .9 - f0.tx * .5, -f0.ny * .9 - f0.ty * .5
  local fln = sqrt(fdx * fdx + fdy * fdy); fdx, fdy = fdx / fln, fdy / fln
  local fp = spline({ { fbx, fby }, { fbx + fdx * 11 * sc, fby + fdy * 11 * sc }, { fbx + fdx * 23 * sc, fby + fdy * 23 * sc } }, 0, 0, function(t) return sc * (2.6 + 3.6 * sin(t * 3.1416) ^ .6) end, 8)
  local cl = R(0, 0, 479, clip)
  if o.clip then body:clip(cl); fl:clip(cl); dr:clip(cl); fp:clip(cl) end
  -- reflection
  if o.refl then
    local W = o.refl
    local function rep(m) m:each(function(x, y) if y % 2 == 0 then local ry = floor(W + (W - y) * .5); local wob = floor(sin(y * .7) * 1.5); local oc = c:get(x + wob, ry); if oc and ry < 269 and ry > W then P(x + wob, ry, mix(oc, "#c4688e", .5)) end end end) end
    rep(body); rep(fl)
  end
  -- ink rims then fills
  c:rim(fl, INK); c:rim(dr, INK); c:rim(body, INK)
  lit(fl, FINR, seed + 4, { R = 4, tex = .1, ink = false })
  fl:each(function(x, y) if not fl:has(x - 1, y - 1) then P(x, y, FINR.hi) end end)
  body:each(function(x, y)
    local best, bd2 = nil, 1e9
    for i = 1, #all do local s = all[i]; local dx, dy = x - s[1], y - s[2]; local d2 = (dx * dx + dy * dy) / (s[3] * s[3] + .5); if d2 < bd2 then bd2 = d2; best = s end end
    local s = best; local r = max(1, s[3])
    local off = ((x - s[1]) * s.nx + (y - s[2]) * s.ny) / r; off = max(-1, min(1, off))
    local nxs, nys = s.nx * off, s.ny * off; local nz = sqrt(max(0, 1 - off * off))
    local lam = max(0, nxs * -.5 + nys * -.62 + nz * .6) / .95
    local u = (1 - lam) * .78 + .1
    local bw = max(0, min(1, (-off - .1) / .55)); u = u - .2 * bw * lam
    local dz = max(0, min(1, (off - .15) / .55))
    local ramp = PK
    if bay(x + 1, y) < dz * .9 then ramp = GR; u = u + .06 end
    local k = floor(max(0, min(.999, u)) * 6 + bay(x, y) * .9 - .35) + 1
    k = max(1, min(6, k))
    P(x, y, ramp[k])
  end)
  -- belly crease and scars
  for i = 1, 7 do
    local s = at(.3 + H(i, seed, 5) * .45)
    local side = (i % 3 == 0) and -.3 or (.15 + H(i, seed, 6) * .45)
    local px_, py_ = s[1] + s.nx * s[3] * side, s[2] + s.ny * s[3] * side
    local len = 2 + floor(H(i, seed, 7) * 4)
    for k = 0, len do if body:has(floor(px_ + s.tx * k), floor(py_ + s.ty * k + (i % 2) * k * .4)) then P(px_ + s.tx * k, py_ + s.ty * k + (i % 2) * k * .4, (i % 2 == 0) and "#ffd8e0" or "#8a4672") end end
  end
  -- dorsal ridge fill
  fill(dr, GR[3]); dr:each(function(x, y) if not dr:has(x - 1, y - 1) then P(x, y, GR[1]) elseif not dr:has(x + 1, y + 1) then P(x, y, GR[5]) end end)
  c:rim(dr:copy():cut(body), INK)
  -- mouth line, eye, blowhole
  for i = 3, #beak do local s = beak[i]; local x, y = s[1] - s.nx * s[3] * .35, s[2] - s.ny * s[3] * .35; if y <= clip then P(x, y, PK[6]) end end
  for k = 0, 4 do local s = beak[#beak - k]; if s and s[2] <= clip then P(s[1] + s.nx * s[3] * .5, s[2] + s.ny * s[3] * .5, PK[1]) end end
  local ex, ey = hd[1] + hd.tx * .5 * sc - hd.nx * .6 * sc, hd[2] + hd.ty * .5 * sc - hd.ny * .6 * sc
  if ey < clip then
    P(ex, ey, INK); P(ex + 1, ey, INK); if sc > .8 then P(ex, ey + 1, INK); P(ex + 1, ey + 1, INK); P(ex - 1, ey - 1, "#ffe6ea") end
    if sc > .8 then P(ex, ey, CREAM) end
  end
  local bh = at(.9); local bhx, bhy = bh[1] + bh.nx * bh[3] * .92, bh[2] + bh.ny * bh[3] * .92
  if bhy < clip and sc > .8 then P(bhx, bhy, PK[6]); P(bhx + 1, bhy, PK[6]) end
  -- flipper in front
  if fp then
    c:rim(fp, INK); lit(fp, FINR, seed + 8, { R = 4, tex = .1, ink = false })
    fp:each(function(x, y) if not fp:has(x - 1, y - 1) then P(x, y, FINR.hi) end end)
    -- lighter underside edge
  end
  -- waterline foam
  if o.clip then
    local x0, x1 = 999, -1
    body:each(function(x, y) if y == clip then x0 = min(x0, x); x1 = max(x1, x) end end)
    if x1 >= 0 then foam(x0 - 4, x1 + 4, clip + 1); ring((x0 + x1) / 2, clip + 3, (x1 - x0) / 2 + 12 * sc, 4 * sc + 1); ring((x0 + x1) / 2, clip + 4, (x1 - x0) / 2 + 22 * sc, 7 * sc + 1) end
  end
  return { smp = smp, hd = hd, tip = tip, T = T }
end
local function pad(x, y, rw, flower)
  local m = E(x, y, rw, max(3, rw // 3))
  lit(m, RR("#c8f48a", "#72c458", "#3f9050", "#2a6a44"), x, { R = 4, tex = .3 })
  for k = 0, rw // 3 do P(x + k + 1, y - 1 + (k > 0 and 0 or 0), WTR[3]) end
  if flower then fill(E(x - rw // 3, y - 3, 3, 2), "#fff4e0"); fill(E(x - rw // 3, y - 4, 1, 1), "#ffd04a"); P(x - rw // 3 - 3, y - 3, "#fff4e0"); P(x - rw // 3 + 3, y - 3, "#fff4e0") end
end
pic("wonder-pink-river-dolphin-pools", function()
  local TRB = RR("#c8946a", "#8c5e48", "#5e3c3c", "#3a2634")
  -- hazy forest sky
  sky({ "#e4f4b8", "#cdeaa8", "#b0dc9c", "#8cc896", "#6cb490" }, 0, 156, 3, function(x, y) return ((x - y * .5) // 30) % 5 == 0 end, "#fff6c0")
  -- far hazy trees
  for i = 0, 22 do
    local x = floor(i * 21 + H(i, 1, 9) * 10); local w = 3 + floor(H(i, 2, 9) * 3)
    for y = 20, 158 do for k = 0, w do P(x + k, y, k < 2 and "#8cc4a0" or "#6aa890") end end
    if i % 3 == 0 then GX.foliage(c, x - 6, 14 + floor(H(i, 3, 9) * 20), 28, 14, RR("#a4dc90", "#6cb878", "#4a9a6c", "#2e7a5c"), i) end
  end
  ridge(function(x) return 132 + floor(5 * sin(x / 20) + 3 * sin(x / 7)) end, "#5aa476", 160)
  for x = 0, 479 do for y = 150, 158 do local o = c:get(x, y); if o and (x + y) % 3 == 0 then P(x, y, "#b8e8b0") end end end
  -- water
  for y = 156, 269 do for x = 0, 479 do
    local t = (y - 156) / 114
    local i = max(1, min(6, 1 + floor((t + (GX.vn(x * .25, y * 1.2, 8, 4) - .5) * .22) * 6))); P(x, y, WTR[i])
  end end
  -- far tree stilts and reflections
  for i = 0, 22 do
    local x = floor(i * 21 + H(i, 1, 9) * 10); local w = 3 + floor(H(i, 2, 9) * 3)
    for y = 160, 178 do if (y % 2 == 0) then for k = 0, w do P(x + k + floor(sin(y * .8)), y, "#3a8a80") end end end
  end
  -- light shafts across canopy and water
  for y = 0, 269 do for x = 0, 479 do
    if ((x - y * .55 + 40) // 26) % 6 == 0 then local o = c:get(x, y); if o and y > 18 then P(x, y, mix(o, "#fff2b0", y > 156 and .2 or .16)) end end
  end end
  -- mid trees: brown trunks with stilt roots
  local function tree(x, yb, w, seed)
    local ytop = -2
    local m = R(x, ytop, x + w, yb)
    flat(m, TRB, seed, { sc = 2 })
    for y = 10, yb - 4, 9 do P(x + 1, y, "#4aa05a"); P(x + 2, y + 1, "#4aa05a") end
    -- stilt roots
    for s = -1, 1, 2 do
      local rt = spline({ { x + w / 2 + s * 1, yb - 26 }, { x + w / 2 + s * (w * .7), yb - 8 }, { x + w / 2 + s * (w * 1.5 + 5), yb + 6 } }, 0, 0, function(t) return max(1.2, (w * .38) * (1 - t * .6)) end, 8)
      flat(rt, TRB, seed + s, { sc = 2 })
    end
    for y = yb + 6, yb + 36 do if y % 2 == 0 then for k = -2, w + 2 do P(x + k + floor(sin(y * .6) * 1.5), y, k < w / 2 and TRB.shade or TRB.deep) end end end
    foam(x - 4, x + w + 4, yb + 6)
  end
  tree(60, 182, 12, 1); tree(150, 178, 9, 2); tree(236, 176, 8, 3); tree(330, 180, 11, 4); tree(412, 184, 13, 5)
  -- canopy
  local LEAF = RR("#b6ec6a", "#5ec04a", "#34904a", "#1e5e3c")
  for i = 0, 8 do GX.foliage(c, i * 60 + 4, 8, 44, 22, LEAF, 40 + i) end
  for i = 0, 11 do GX.foliage(c, i * 42 + 20, -2, 36, 14, RR("#d0f47a", "#78cc52", "#3f9c4c", "#2a6e40"), 70 + i) end
  for i = 1, 30 do local x = floor(H(i, 1, 3) * 478); local len = 10 + floor(H(i, 2, 3) * 44); for y = 12, 12 + len do P(x + floor(sin(y / 5 + i)), y, y % 6 == 5 and "#b6ec6a" or ((i % 4 == 0) and "#6a4a38" or "#3f9a4c")) end end
  -- near trunks both sides with buttress roots
  for _, T in ipairs({ { 0, 30, 226 }, { 446, 34, 232 } }) do
    local x, w, yb = T[1], T[2], T[3]
    flat(R(x, -2, x + w, yb), TRB, x, { sc = 3 })
    for y = 6, yb - 10, 11 do for k = 0, 5 do P(x + 4 + k + (y % 3) * 4, y + k % 2, (k % 2 == 0) and "#6cc058" or "#3f9a4c") end end
    for s = -1, 1, 2 do
      local bx0 = x + w / 2
      local rt = spline({ { bx0 + s * 4, yb - 60 }, { bx0 + s * (w * .6), yb - 20 }, { bx0 + s * (w * 1.1 + 16), yb + 8 } }, 0, 0, function(t) return 6 + t * 5 end, 10)
      flat(rt, TRB, x + s, { sc = 3 })
    end
    for y = yb + 10, yb + 34 do if y % 2 == 0 then for k = -w // 2, w + w // 2 do P(x + k + floor(sin(y * .5) * 2), y, k < w / 2 and TRB.shade or TRB.deep) end end end
    foam(x - 8, x + w + 14, yb + 10)
  end
  -- ripples and pads
  for _, p in ipairs({ { 80, 240, 3 }, { 250, 258, 2 }, { 420, 244, 3 }, { 330, 190, 1 }, { 140, 198, 2 }, { 372, 198, 2 }, { 200, 232, 2 } }) do ring(p[1], p[2], 10 + p[3] * 6, 2 + p[3]) end
  for i = 1, 70 do local x, y = floor(H(i, 1, 6) * 470), 164 + floor(H(i, 2, 6) * 104); local w = 3 + floor(H(i, 3, 6) * 9); for k = 0, w do P(x + k, y, "#a4ecc8") end end
  pad(60, 246, 15, true); pad(98, 262, 11); pad(216, 252, 13); pad(280, 262, 10, true); pad(332, 246, 11); pad(446, 252, 14, true); pad(24, 258, 9); pad(180, 200, 6); pad(370, 204, 7); pad(452, 200, 6)
  -- the dolphins
  -- calf, following the mother's wake
  dolphin({ pts = { { 150, 278 }, { 184, 266 }, { 212, 252 }, { 236, 242 } }, sc = .55, seed = 91, clip = 262, refl = 262 })
  -- adult surfacing, only head and back
  dolphin({ pts = { { 286, 278 }, { 326, 264 }, { 362, 246 }, { 394, 230 }, { 416, 216 } }, sc = 1.05, seed = 61, clip = 238, refl = 238 })
  -- leaping dolphin, S-curve arc
  dolphin({ pts = { { 100, 172 }, { 124, 188 }, { 152, 170 }, { 184, 134 }, { 216, 110 }, { 246, 112 }, { 268, 132 }, { 280, 158 } }, sc = 1.38, seed = 51, refl = 222 })
  -- splashes: exit wake and entry
  ring(96, 224, 28, 5); ring(96, 226, 16, 3); ring(306, 226, 34, 6); ring(306, 228, 20, 4)
  drops(96, 202, 40, 26, 1); drops(304, 208, 50, 32, 2); drops(190, 150, 8, 24, 3)
  -- trail of droplets along the arc
  for i = 1, 22 do local x = 110 + floor(H(i, 5, 5) * 180); local y = 190 + floor(H(i, 6, 5) * 30) - floor(sin((x - 110) / 180 * 3.1) * 80); if y < 218 then P(x, y, i % 2 == 0 and "#d8fff0" or CREAM) end end
  -- quirk: frog on a lily pad
  local fg = E(446, 247, 6, 4); lit(fg, RR("#d8f070", "#8ccc48", "#4e9a44", "#2e6a3c"), 77, { R = 3, tex = 0 })
  P(442, 243, INK); P(450, 243, INK); P(442, 242, "#ffe49a"); P(450, 242, "#ffe49a")
  for i = 1, 30 do local x, y = floor(H(i, 7, 7) * 470), 20 + floor(H(i, 8, 7) * 150); P(x, y, "#fff2b0") end
end)


---------------------------------------------------------------- 2 root wrapped temple
pic("wonder-root-wrapped-temple", function()
  sky({ "#103a34", "#14483c", "#1a5a44", "#206c4c", "#2c8452" }, 0, 270, 2, function(x, y) return ((x - y * .5) // 20) % 6 == 0 and y < 240 end, "#ffe8a0")
  for i = 0, 12 do flat(R(i * 40 + 10, 0, i * 40 + 18, 230), RR("#4a8a58", "#2e6a48", "#1e4a3c", "#143428"), i, { sc = 2 }) end
  for y = 0, 240 do for x = 0, 479 do if ((x - y * .45) // 24) % 5 == 0 then local o = c:get(x, y); if o then P(x, y, mix(o, "#ffe8a0", .15)) end end end end
  GX.ground(c, function(x) return 228 + floor(3 * sin(x / 22)) end, RR("#8ad060", "#4a9a48", "#2e6a40", "#1e4a38"), 4, { top = .8, fall = .5 })
  local ST = RR("#e4e4b8", "#aab090", "#6e7e70", "#44564e")
  local tiers = { { 110, 370, 196, 236 }, { 140, 340, 162, 196 }, { 170, 310, 130, 162 }, { 198, 282, 102, 130 }, { 222, 258, 76, 102 } }
  for k, t in ipairs(tiers) do
    local m = R(t[1], t[3], t[2], t[4]); flat(m, ST, k, { sc = 3 })
    for y = t[3] + 5, t[4] - 2, 6 do for x = t[1] + 2 + (floor(y / 6) % 2) * 6, t[2] - 2, 12 do P(x, y, ST.deep); P(x + 1, y, ST.deep) end end
    fill(R(t[1], t[3], t[2], t[3] + 1), ST.hi)
  end
  -- stairs
  local sx0, sx1 = 226, 254
  for y = 78, 196, 5 do fill(R(sx0, y, sx1, y), ST.hi); fill(R(sx0, y + 1, sx1, y + 1), ST.shade) end
  fill(R(sx0 - 1, 78, sx0 - 1, 196), INK); fill(R(sx1 + 1, 78, sx1 + 1, 196), INK)
  -- moss
  for y = 76, 236 do for x = 110, 370 do local o = c:get(x, y); if o and (o == ST.base or o == ST.hi) and GX.vn(x, y, 6, 3) > .6 then P(x, y, o == ST.hi and "#9ed070" or "#5aa050") end end end
  -- shrine on top
  flat(R(228, 56, 252, 76), ST, 9, { sc = 3 })
  local roof = PL({ { 220, 56 }, { 260, 56 }, { 250, 42 }, { 230, 42 } }); flat(roof, RR("#9ed070", "#5aa050", "#3a7a48", "#245a3c"), 8)
  fill(R(234, 62, 237, 66), INK); fill(R(243, 62, 246, 66), INK); P(235, 63, "#ffe49a"); P(244, 63, "#ffe49a"); fill(R(236, 70, 244, 71), INK)
  -- doorway with glow
  local dr = E(240, 216, 12, 14):add(R(228, 216, 252, 236)):clip(R(228, 200, 252, 236)); c:rim(dr, INK); fill(dr, "#ffcf6a"); fill(E(240, 222, 7, 10):clip(dr), "#fff0b8")
  glow(240, 226, 40, "#ffe49a", .38)
  -- roots: thick, draping and wrapping
  local RT = RR("#d8a874", "#946648", "#5e3e3c", "#3a2634")
  local function root(pts, r0, r1, seed, wob)
    local m = spline(pts, 0, 0, function(t) return r0 + (r1 - r0) * t + sin(t * 9 + seed) * (wob or 1.2) end)
    lit(m, RT, 30 + seed, { R = 6, tex = .55, sc = 3 })
  end
  -- far side drapes first (thin), then fat ones
  root({ { 150, 0 }, { 168, 60 }, { 150, 120 }, { 128, 180 }, { 100, 222 }, { 70, 250 } }, 5, 8, 1)
  root({ { 330, 0 }, { 312, 60 }, { 332, 120 }, { 352, 180 }, { 380, 222 }, { 412, 250 } }, 5, 8, 2)
  -- wrapping bands across each tier front
  root({ { 112, 214 }, { 150, 226 }, { 190, 212 }, { 230, 224 }, { 280, 212 }, { 330, 226 }, { 368, 214 } }, 4, 4, 3, .6)
  root({ { 142, 178 }, { 180, 190 }, { 222, 176 }, { 262, 186 }, { 300, 174 }, { 338, 184 } }, 4, 4, 4, .6)
  root({ { 172, 146 }, { 206, 156 }, { 240, 142 }, { 276, 154 }, { 308, 144 } }, 3.5, 3.5, 5, .6)
  -- big draping roots from the canopy over the top
  root({ { 214, 0 }, { 218, 40 }, { 204, 82 }, { 190, 130 }, { 196, 172 }, { 172, 214 }, { 150, 252 } }, 6, 10, 6)
  root({ { 268, 0 }, { 262, 40 }, { 278, 82 }, { 292, 130 }, { 286, 172 }, { 310, 214 }, { 334, 252 } }, 6, 10, 7)
  root({ { 40, 0 }, { 70, 70 }, { 104, 130 }, { 96, 196 }, { 76, 254 } }, 8, 12, 8)
  root({ { 440, 0 }, { 410, 70 }, { 376, 130 }, { 384, 196 }, { 404, 254 } }, 8, 12, 9)
  for i = 1, 22 do local x = floor(H(i, 1, 3) * 470); local len = 14 + floor(H(i, 2, 3) * 40); for y = 0, len do P(x + floor(sin(y / 6 + i)), y, y % 7 == 6 and "#9ad45a" or "#3f8a48") end end
  for i = 1, 18 do tuft(floor(H(i, 6, 6) * 470) + 4, 240 + floor(H(i, 7, 6) * 26), GRASS) end
  GX.foliage(c, 80, 6, 90, 22, RR("#6cc058", "#368a48", "#245e3c", "#173e30"), 5); GX.foliage(c, 400, 4, 100, 22, RR("#6cc058", "#368a48", "#245e3c", "#173e30"), 6)
  -- quirk: golden-eyed frog on the roof
  local fg = E(240, 40, 8, 5); lit(fg, RR("#d8f070", "#8ccc48", "#4e9a44", "#2e6a3c"), 5, { R = 4, tex = 0 })
  fill(E(235, 35, 2, 2), "#ffe49a"); fill(E(245, 35, 2, 2), "#ffe49a"); P(235, 35, INK); P(245, 35, INK)
  for i = 1, 22 do local x, y = 60 + floor(H(i, 8, 8) * 360), 110 + floor(H(i, 9, 8) * 120); c:sparkle(x, y); P(x, y, "#ffe49a") end
  -- stone lanterns flanking the door, bromeliads on the roots, ground mist
  for _, lx in ipairs({ 204, 276 }) do
    flat(R(lx - 4, 218, lx + 4, 236), ST, lx, { sc = 3 }); flat(R(lx - 6, 212, lx + 6, 218), ST, lx + 1, { sc = 3 })
    fill(R(lx - 3, 213, lx + 3, 217), "#ffcf6a"); fill(R(lx - 1, 214, lx + 1, 216), "#fff0b8"); glow(lx, 215, 12, "#ffe49a", .3)
  end
  for i = 1, 14 do local bx, by = 60 + floor(H(i, 3, 5) * 360), 120 + floor(H(i, 4, 5) * 110)
    if c:get(bx, by) and c:get(bx, by) ~= ST.base then for k = -2, 2 do P(bx + k, by - abs(k) // 1, i % 2 == 0 and "#ff8a5a" or "#ffcf6a") end; P(bx, by - 3, "#e0484e") end end
  for y = 232, 252 do for x = 0, 479 do if (x * 3 + y * 7) % 11 < 2 and GX.vn(x, y, 10, 5) > .55 then local o = c:get(x, y); if o then P(x, y, mix(o, "#e8f8d0", .35)) end end end end
end)

---------------------------------------------------------------- 3 panda bamboo grove
local WHITE = RR("#fff4e0", "#efe2d0", "#c9b8b0", "#9a8a92")
local BLACK = RR("#6a5a70", "#3d3042", "#2e2334", "#241c28")
local function bamboo(x, y0, y1, w, Rm, seed)
  c:rim(R(x, y0, x + w, y1), INK)
  for y = y0, y1 do for xx = x, x + w do
    local s = (xx - x) / w; local col = Rm.base
    if s < .3 then col = Rm.hi elseif s > .7 then col = Rm.shade end
    P(xx, y, col)
  end end
  local ny = y0 + floor(H(seed, 1, 1) * 18)
  while ny < y1 do fill(R(x - 1, ny, x + w + 1, ny + 1), INK); P(x, ny, Rm.hi); ny = ny + 22 + floor(H(ny, seed, 2) * 10) end
end
local function panda(cx, cy, s, bite)
  local function e(x, y, rx, ry, Rm, seed, ro) local m = E(cx + x * s, cy + y * s, max(1, rx * s), max(1, ry * s)); lit(m, Rm, seed, { R = ro or max(3, floor(ry * s * .6)), tex = .12 }); return m end
  local function eb(x, y, rx, ry, col) fill(E(cx + x * s, cy + y * s, max(1, rx * s), max(1, ry * s)), col) end
  c:rim(E(cx, cy + 4 * s, 44 * s, 48 * s), INK)
  e(-26, 52, 20, 13, BLACK, 31); e(26, 52, 20, 13, BLACK, 32)
  e(0, 18, 46, 48, WHITE, 33, 18)
  e(-40, 18, 11, 22, BLACK, 34); e(40, 18, 11, 22, BLACK, 35)
  for _, sx in ipairs({ -1, 1 }) do eb(sx * 26, 56, 5, 3, "#6a4a58") end
  e(-24, -42, 11, 11, BLACK, 36, 5); e(24, -42, 11, 11, BLACK, 37, 5)
  e(0, -22, 36, 31, WHITE, 38, 14)
  for _, sx in ipairs({ -1, 1 }) do
    lit(E(cx + sx * 15 * s, cy - 22 * s, max(2, 8 * s), max(3, 11 * s)), BLACK, 40 + sx, { R = 3, tex = 0 })
    eb(sx * 15, -22, 3, 4, "#fff4e0"); eb(sx * 15, -22, 2, 3, INK); P(cx + (sx * 15 - 1) * s, cy - 24 * s, CREAM)
  end
  eb(0, -10, 8, 6, "#f0e6d8"); eb(0, -14, 5, 3, INK); eb(0, -5, 2, 1, "#8a4a58")
  eb(-18, -8, 5, 3, "#f5a0a0"); eb(18, -8, 5, 3, "#f5a0a0")
  if bite then bamboo(floor(cx - 14 * s), floor(cy - 6 * s), floor(cy + 42 * s), 11, RR("#c8f08a", "#8cd25a", "#5aa048", "#3a7040"), 77) end
end
pic("wonder-panda-bamboo-grove", function()
  sky({ "#c8e8a0", "#b8e0a0", "#a4d6a0", "#8ccaa0" }, 0, 270, 4)
  local layers = { { 8, 5, "#a8d8a8", "#88c098", "#6aa688" }, { 12, 7, "#7cc08a", "#5ca878", "#3f8a68" }, { 18, 9, "#4aa060", "#368850", "#286a48" } }
  for li, L in ipairs(layers) do
    local n = ({ 11, 8, 5 })[li]
    for i = 0, n do
      local x = floor((i + H(i, li, 7) * .8) * 480 / n)
      bamboo(x, floor(H(i, li, 8) * 20) - 10, 240, L[2], RR(mix(L[3], "#ffffd0", .3), L[3], L[4], L[5]), i + li * 9)
      if H(i, li, 9) < .7 then
        for k = 1, 3 do local ly = 30 + floor(H(i, k, li) * 100); local dir = (k % 2 == 0) and 1 or -1
          for j = 0, 6 do P(x + dir * (j + 2), ly + floor(j * .5), L[3]); P(x + dir * (j + 2), ly + floor(j * .5) + 1, L[4]) end end
      end
    end
  end
  for y = 0, 230 do for x = 0, 479 do if ((x + y * .6) // 22) % 5 == 0 then local o = c:get(x, y); if o then P(x, y, mix(o, "#ffe9a0", .17)) end end end end
  GX.ground(c, function(x) return 200 + floor(3 * sin(x / 18)) end, RR("#bce86a", "#7cc048", "#4a9040", "#2e6a3c"), 6, { top = .9, fall = .55 })
  for i = 1, 30 do tuft(floor(H(i, 1, 4) * 470) + 4, 210 + floor(H(i, 2, 4) * 54), GRASS) end
  for i = 1, 30 do local x, y = floor(H(i, 5, 5) * 470), 208 + floor(H(i, 6, 5) * 56); for k = 0, 3 do P(x + k, y - floor(k / 2), "#e8d070") end end
  fill(E(240, 258, 100, 9), "#3a7a3c")
  panda(240, 158, 1.5, true)
  -- cub on a stump
  flat(R(396, 222, 428, 250), RR("#d8a070", "#a8704a", "#7a4a3c", "#523030"), 5)
  fill(R(397, 222, 427, 224), "#e8c088")
  panda(412, 196, .36, false)
  for _, p in ipairs({ { 410, 171 }, { 411, 170 }, { 412, 169 }, { 413, 170 }, { 414, 171 }, { 412, 171 } }) do P(p[1], p[2] + 3, "#5fae48") end
  P(412, 174, "#9ad45a"); P(413, 174, "#9ad45a")
  -- foreground shoots, falling leaves, butterflies, cut bamboo pile
  for _, sx in ipairs({ 40, 90, 455, 330, 30 }) do
    local h = 14 + floor(H(sx, 1, 1) * 10)
    local sp = PL({ { sx - 4, 262 }, { sx, 262 - h }, { sx + 4, 262 } }); flat(sp, RR("#e8f8a0", "#b4dc6a", "#7aac52", "#4a7a44"), sx, { sc = 2 })
    for y = 262 - h + 5, 260, 4 do P(sx - 2, y, "#7aac52"); P(sx + 2, y + 1, "#7aac52") end
  end
  for i = 1, 16 do local x, y = floor(H(i, 3, 3) * 470), 40 + floor(H(i, 4, 3) * 170)
    P(x, y, "#9ad45a"); P(x + 1, y + 1, "#5fae48"); P(x + 2, y + 1, "#9ad45a") end
  for _, b in ipairs({ { 150, 120 }, { 330, 140 } }) do
    fill(R(b[1] - 4, b[2] - 3, b[1] - 1, b[2]), "#ff9a5a"); fill(R(b[1] + 1, b[2] - 3, b[1] + 4, b[2]), "#ff9a5a")
    fill(R(b[1] - 3, b[2] + 1, b[1] - 1, b[2] + 3), "#e0605a"); fill(R(b[1] + 1, b[2] + 1, b[1] + 3, b[2] + 3), "#e0605a"); P(b[1], b[2] - 1, INK); P(b[1], b[2], INK); P(b[1], b[2] + 1, INK)
  end
  for k = 0, 2 do bamboo(300, 244 + k * 0, 252, 0, RR("#c8f08a", "#8cd25a", "#5aa048", "#3a7040"), k) end
  for k = 0, 2 do fill(R(290, 244 + k * 5, 326, 248 + k * 5), "#8cd25a"); c:rim(R(290, 244 + k * 5, 326, 248 + k * 5), INK); fill(R(290, 244 + k * 5, 326, 244 + k * 5), "#c8f08a"); fill(R(290, 248 + k * 5, 326, 248 + k * 5), "#5aa048") end
end)

---------------------------------------------------------------- 4 stone head watchers
local function head(cx, by, h, Rm, seed)
  local rx, ry = floor(h * .44), h / 2
  local cy = floor(by - ry)
  local m = E(cx, cy, rx, ry); m:cut(R(cx - rx - 2, by + 1, cx + rx + 2, by + 40))
  m:add(R(cx - rx - max(1, floor(rx * .12)), cy - floor(ry * .08), cx - rx + 3, cy + floor(ry * .32)))
  m:add(R(cx + rx - 3, cy - floor(ry * .08), cx + rx + max(1, floor(rx * .12)), cy + floor(ry * .32)))
  lit(m, Rm, seed, { R = max(4, floor(h * .2)), tex = .4, sc = 5 })
  m:each(function(x, y) if y < cy + ry * .1 and GX.vn(x, y, 5, seed + 3) > .7 and m:has(x, y - 1) and m:has(x - 1, y) then P(x, y, (x + y) % 3 == 0 and "#9ed070" or "#5aa050") end end)
  if h > 80 then local x, y = cx - floor(rx * .5), cy - floor(ry * .85); for i = 0, floor(h * .22) do P(x, y + i, Rm.deep); if i % 3 == 0 then x = x + (H(i, seed, 4) < .5 and -1 or 1) end end end
  local function Y(f) return floor(cy + ry * f) end
  local function X(f) return floor(rx * f) end
  -- helmet band
  local band = E(cx, cy, rx, ry):clip(R(cx - rx, Y(-.62), cx + rx, Y(-.4)))
  fill(band, mix(Rm.base, "#d8a070", .35)); fill(R(cx - rx, Y(-.62), cx + rx, Y(-.62)):clip(m), Rm.hi); fill(R(cx - rx, Y(-.4), cx + rx, Y(-.4)):clip(m), Rm.deep)
  local ey = Y(-.12)
  for _, sx in ipairs({ -1, 1 }) do
    local ex = cx + sx * X(.4)
    -- heavy brow
    fill(R(ex - X(.26), ey - max(2, floor(ry * .14)), ex + X(.26), ey - max(1, floor(ry * .05))), Rm.base)
    fill(R(ex - X(.26), ey - max(2, floor(ry * .14)), ex + X(.26), ey - max(2, floor(ry * .14))), Rm.hi)
    fill(R(ex - X(.26), ey - max(1, floor(ry * .05)) + 1, ex + X(.26), ey - max(1, floor(ry * .05)) + 1), Rm.deep)
    -- eye hollow
    fill(E(ex, ey + max(1, floor(ry * .03)), max(2, X(.2)), max(1, floor(ry * .07))), Rm.deep)
    if h > 60 then fill(E(ex + sx, ey + 1, max(1, X(.07)), max(1, X(.07))), INK); P(ex + sx - 1, ey, "#a89aa4") end
    -- cheek bulge
    for yy = Y(.12), Y(.3) do for xx = ex - X(.2), ex + X(.2) do if m:has(xx, yy) and (xx + yy) % 2 == 0 then P(xx, yy, Rm.hi) end end end
  end
  -- broad nose
  local nT, nB = ey, Y(.3)
  local nose = PL({ { cx - X(.1), nT }, { cx + X(.1), nT }, { cx + X(.27), nB }, { cx - X(.27), nB } })
  fill(nose, Rm.base)
  nose:each(function(x, y) if not nose:has(x - 1, y) then P(x, y, Rm.hi) elseif not nose:has(x + 1, y) then P(x, y, Rm.shade) end end)
  for _, sx in ipairs({ -1, 1 }) do fill(E(cx + sx * X(.17), nB - max(1, floor(ry * .02)), max(1, X(.08)), max(1, floor(ry * .03))), Rm.deep) end
  fill(R(cx - X(.3), nB + 1, cx + X(.3), nB + 1), Rm.deep)
  -- thick lips
  local ly = Y(.55)
  local up = E(cx, ly, X(.42), max(1, floor(ry * .08))); fill(up, Rm.hi); fill(up:copy():shift(0, 1):cut(up), Rm.base)
  fill(R(cx - X(.44), ly + max(1, floor(ry * .07)), cx + X(.44), ly + max(1, floor(ry * .07))), Rm.deep)
  local lo = E(cx, ly + max(2, floor(ry * .15)), X(.34), max(1, floor(ry * .08))); fill(lo, Rm.base); fill(lo:copy():shift(0, 1):cut(lo), Rm.shade)
  P(cx - X(.45), ly + max(1, floor(ry * .07)) + 1, Rm.deep); P(cx + X(.45), ly + max(1, floor(ry * .07)) + 1, Rm.deep)
end
pic("wonder-stone-head-watchers", function()
  sky({ "#6aa4e0", "#8cc0e8", "#b4d4ec", "#f0dcc0", "#ffd0a0", "#ffc088" }, 0, 150, 8)
  glow(110, 140, 60, "#fff0b8", .35)
  lit(E(110, 138, 16, 16), RR("#fff6c8", "#ffe07a", "#f2b84a", "#e0884a"), 3, { R = 8, tex = 0, ink = false })
  for _, cl in ipairs({ { 340, 50, 50 }, { 70, 40, 34 }, { 430, 90, 38 } }) do cloudp(cl[1], cl[2], cl[3], "#fff1d8", "#f2c0a8") end
  for y = 150, 190 do for x = 0, 479 do
    local t = (y - 150) / 40; local cols = { "#f8c898", "#7cc0d8", "#4aa0c8", "#3a84b8" }
    P(x, y, cols[max(1, min(4, 1 + floor((t + (GX.vn(x * .3, y, 6, 3) - .5) * .3) * 4)))])
  end end
  for i = 1, 40 do local x, y = 60 + floor(H(i, 1, 1) * 100), 152 + floor(H(i, 2, 1) * 36); for k = 0, 3 + floor(H(i, 3, 1) * 4) do P(x + k, y, "#fff0b8") end end
  GX.ground(c, function(x) return 186 + floor(8 * sin(x / 60 + 1) + 3 * sin(x / 17)) end, RR("#b8e870", "#74c050", "#3f9048", "#2a6a42"), 3, { top = .88, fall = .6 })
  local HZ = RR("#d0c0b8", "#a094a8", "#756a8c", "#544c74")
  for _, h in ipairs({ { 30, 200, 40 }, { 160, 196, 44 }, { 330, 196, 44 }, { 452, 200, 40 } }) do head(h[1], h[2], h[3], HZ, h[1]) end
  local MD = RR("#e0d4c8", "#b0a2ac", "#7a6e92", "#544c74")
  head(78, 238, 84, MD, 21); head(402, 238, 84, MD, 22)
  head(240, 269, 156, RR("#f0e4d4", "#bcacb4", "#867898", "#5a4e7c"), 31)
  for i = 1, 30 do local x = 10 + floor(H(i, 3, 3) * 460); if abs(x - 240) > 60 then GX.flower(c, x, 240 + floor(H(i, 4, 3) * 26), ({ "#ff8aa8", "#ffe07a", "#fff1cf", "#c88aff" })[1 + i % 4]) end end
  for i = 1, 16 do local x = floor(H(i, 7, 7) * 460) + 10; if abs(x - 240) > 70 then tuft(x, 236 + floor(H(i, 8, 7) * 30), GRASS) end end
  -- quirk: bird in a red cap on top of the great head; bowl of golden fruit at left
  local bd = E(240, 106, 7, 6); lit(bd, RR("#fff1cf", "#f2b84a", "#c07a3a", "#8a4a30"), 4, { R = 3, tex = 0 })
  fill(R(246, 104, 249, 105), "#e0484e"); P(244, 104, INK); fill(R(236, 110, 238, 112), INK)
  for i = 1, 5 do local fx = 16 + i * 8; fill(E(fx, 258, 4, 4), "#ffcf6a"); c:rim(E(fx, 258, 4, 4), INK); P(fx - 1, 257, CREAM) end
  fill(R(14, 262, 62, 265), "#8a7a8c"); c:rim(R(14, 262, 62, 265), INK)
  c:sparkle(200, 60); c:sparkle(310, 80)
  -- vines over the great head, mushrooms, butterflies, drifting motes
  for _, vx in ipairs({ 190, 214, 276, 296 }) do local len = 18 + floor(H(vx, 1, 1) * 30); for y = 0, len do P(vx + floor(sin(y / 4 + vx)), 118 + y + (vx % 3) * 4, y % 5 == 4 and "#b6ec6a" or "#3f9a4c") end end
  for _, mx in ipairs({ 150, 340, 20, 462 }) do
    fill(R(mx, 250, mx + 1, 254), "#fff1cf"); fill(E(mx + .5, 249, 3, 2), "#e0484e"); P(mx - 1, 248, CREAM); P(mx + 1, 249, CREAM)
  end
  for _, b in ipairs({ { 130, 120 }, { 360, 150 } }) do fill(R(b[1] - 3, b[2] - 2, b[1] - 1, b[2]), "#ffa8d8"); fill(R(b[1] + 1, b[2] - 2, b[1] + 3, b[2]), "#ffa8d8"); P(b[1], b[2], INK); P(b[1], b[2] - 1, INK) end
  for i = 1, 26 do P(floor(H(i, 5, 2) * 470), 100 + floor(H(i, 6, 2) * 150), "#fff0b8") end
end)

---------------------------------------------------------------- 5 the great migration
local function gnu(x, y, s, Rm, dark, big)
  local function pt(a, b) return { x + a * s, y + b * s } end
  local function PLX(list) local t = {} for i, p in ipairs(list) do t[i] = pt(p[1], p[2]) end return PL(t) end
  local rad = max(.6, .85 * s)
  local function limb(a, b, c2, dd)
    local p1, p2, p3 = pt(a, b), pt(c2, (b + dd) / 2), pt(c2 + .3, dd)
    return spline({ p1, p2, p3 }, rad, rad * .75, nil, 6)
  end
  local legs = limb(7, -6, 7, 0):add(limb(3, -6, 2, 0)):add(limb(-8, -7, -9, 0)):add(limb(-4, -7, -4, 0))
  local body = PLX({ { -13, -10 }, { -11, -14 }, { -4, -15 }, { 3, -19 }, { 8, -18 }, { 11, -13 }, { 10, -6 }, { 0, -5 }, { -10, -5 } })
  local hd = PLX({ { 8, -18 }, { 13, -14 }, { 19, -9 }, { 22, -3 }, { 18, -1 }, { 13, -5 }, { 9, -9 } })
  local full = body:copy():add(legs):add(hd)
  if s >= .8 then c:rim(full, INK) end
  if s >= 1.4 then
    lit(legs, dark, 91, { R = 3, tex = .2, ink = false })
    lit(body, Rm, 92, { R = floor(7 * s), tex = .35, ink = false })
    lit(hd, dark, 93, { R = floor(4 * s), tex = .15, ink = false })
  else
    fill(legs, dark.base); fill(body, Rm.base); fill(hd, dark.base)
    body:each(function(xx, yy) if not body:has(xx - 1, yy - 1) then P(xx, yy, Rm.hi) elseif not body:has(xx, yy + 1) then P(xx, yy, Rm.shade) end end)
  end
  -- flank stripes
  if s >= 1 then for i = -3, 2 do local sx = x + i * 3 * s; ln(sx, y - 13 * s, sx - s, y - 7 * s, Rm.shade, 1) end end
  -- dark hump mane and beard
  local mane = spline({ pt(2, -19), pt(7, -18.5), pt(12, -14), pt(16, -9) }, max(.7, 1.6 * s), max(.7, 1.1 * s), nil, 8)
  fill(mane, dark.deep)
  local beard = PLX({ { 17, -3 }, { 20, -2 }, { 17, 4 }, { 15, 0 } }); fill(beard, dark.deep)
  -- horns
  local hr = spline({ pt(14, -15), pt(12.5, -19), pt(15, -22), pt(18, -20) }, max(.6, .8 * s), max(.5, .5 * s), nil, 8)
  fill(hr, "#e8d8b0"); if s >= 1.2 then c:rim(hr, INK) end
  -- tail
  local tl = spline({ pt(-12, -11), pt(-15, -8), pt(-15.5, -3) }, max(.5, .6 * s), max(.5, .9 * s), nil, 6); fill(tl, dark.deep)
  P(x + 17 * s, y - 8 * s, "#ffe8a0")
  if s >= 2 then P(x + 17 * s + 1, y - 8 * s, INK) end
end
pic("wonder-the-great-migration", function()
  GX.bands(c, 0, 160, { "#c85a8c", "#e87a7c", "#ff9a6c", "#ffb868", "#ffd488", "#ffe8a8" }, 14, .1)
  for _, k in ipairs{ { 90, 40, 50 }, { 380, 34, 56 }, { 240, 78, 40 } } do cloudp(k[1], k[2], k[3], "#ffb890", "#d86a7c") end
  fill(E(240, 138, 48, 48), "#ffb878"); fill(E(240, 138, 43, 43), "#ffd890"); fill(E(240, 138, 40, 40), "#fff4c0")
  GX.ground(c, function(x) return 150 end, RR("#f8d08a", "#d49a58", "#9a6a48", "#5a3a40"), 15, { top = .8, fall = .55, tex = .3 })
  ridge(function(x) return 148 + floor(2 * sin(x / 20)) end, "#a8604a", 150)
  for i = 0, 70 do P(floor(H(i, 1, 1) * 480), 154 + floor(H(i, 2, 1) * 110), "#ffe0a0") end
  GX.trunk(c, 58, 64, 100, 150, RR("#9a5a40", "#6a3a38", "#4a2a34", "#2a1c2a"), 41, { noink = true })
  GX.foliage(c, 62, 96, 56, 12, RR("#a8c060", "#5a8a3c", "#3a603a", "#24402e"), 42)
  ln(430, 110, 430, 150, "#5a3a40", 3); fill(R(420, 106, 440, 110), "#5a3a40")
  local RM = RR("#a8887c", "#7a6270", "#584658", "#3c2e40")
  local DK = RR("#6a5262", "#3c2e40", "#2a2030", "#1c1624")
  local rows = { { 160, .5, 22 }, { 174, .6, 18 }, { 192, .85, 14 }, { 214, 1.15, 9 }, { 240, 1.6, 6 } }
  for ri, row in ipairs(rows) do
    local y, s, n = row[1], row[2], row[3]
    for i = 0, n do
      local x = (i * 480 / n + floor(H(i, ri, 3) * 20) - 4 + ri * 17) % 500 - 10
      if ri < 4 or x < 170 or x > 380 then
        local hz = mix(RM.base, "#e8a070", .45 - ri * .07)
        gnu(floor(x), y, s, RR(mix(RM.hi, "#e8a070", .3 - ri * .04), ri < 3 and hz or RM.base, RM.shade, RM.deep), ri < 3 and RR(hz, mix(DK.base, "#e8a070", .35), DK.shade, DK.deep) or DK)
      end
    end
  end
  for i = 0, 40 do local x, y = floor(H(i, 5, 5) * 480), 154 + floor(H(i, 6, 5) * 30); fill(E(x, y, 5, 1), "#e8a070") end
  -- foreground bull
  fill(E(250, 264, 100, 6), "#8a5a4a")
  gnu(240, 264, 4.2, RM, DK, true)
  -- quirk: bird in red gnome hat riding the bull
  local bx, by = 236, 188
  local br = E(bx, by, 6, 5); c:rim(br, INK); fill(br, "#fff0d0")
  local hat = PL({ { bx - 5, by - 3 }, { bx, by - 14 }, { bx + 5, by - 3 } }); c:rim(hat, INK); fill(hat, "#e0443a")
  P(bx + 3, by, INK); P(bx + 7, by + 1, "#f0a030"); P(bx + 8, by + 1, "#f0a030")
  fill(E(330, 262, 5, 4), "#ffd060"); c:rim(E(330, 262, 5, 4), INK); c:sparkle(330, 250)
end)

---------------------------------------------------------------- 6 lair of the grey wolf king
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
pic("lair-of-the-grey-wolf-king", function()
  GX.bands(c, 0, 190, { "#202450", "#2c3466", "#3a4880", "#50629a", "#7284ae", "#9aa4c0" }, 6, .2)
  stars(0, 110, 80, 4, { "#f0f0ff" })
  halo(250, 74, 120, 110, .1, 3, "#f4f4ff"); halo(250, 74, 92, 84, .14, 4, "#f4f4ff"); halo(250, 74, 72, 66, .2, 5, "#f4f4ff")
  local mn = rough(disc(mk(), 250, 74, 56, 56), 6)
  litL(mn, { hi = "#ffffff", base = "#f2f2fa", shade = "#d0d4ec", deep = "#aab2d8" }, 6, { R = 56, tex = .2, ink = false, rimlight = false, amb = .5 })
  for _, p in ipairs{ { 276, 60, 7 }, { 280, 96, 9 }, { 224, 98, 5 }, { 270, 40, 4 } } do disc(mk(), p[1], p[2], p[3], p[3]):each(function(x, y) P(x, y, "#d0d4ec") end) end
  layer({ { 60, 150, .6 }, { 190, 138, .8 }, { 330, 134, .7 }, { 450, 140, .7 } }, 170, { hi = "#b0b8d4", base = "#8490b8", shade = "#6874a4", deep = "#505c90" }, 11, .3, 220, "#a0a8c8")
  for _, p in ipairs{ { 20, 210, 60 }, { 52, 214, 46 }, { 100, 208, 56 }, { 380, 210, 52 }, { 420, 214, 64 }, { 460, 212, 48 }, { 340, 214, 36 }, { 140, 216, 34 } } do
    pine(p[1], p[2], p[3], { hi = "#5a8a8a", base = "#356a6c", shade = "#264a5c", deep = "#1c3246" }, GX.ramp6({ hi = "#ffffff", base = "#e4e8f4", shade = "#b0b8d8", deep = "#7c88b8" }), p[1])
  end
  GX.ground(c, function(x) return 222 + floor((GX.vn(x, 0, 30, 4) - .5) * 8) end, { hi = "#f8f8ff", base = "#d4d8f0", shade = "#9ca4d4", deep = "#6c78b4" }, 12, { top = .85, fall = .5, tex = .3 })
  -- spire with the den
  local sp = rough(PL({ { 130, 234 }, { 150, 190 }, { 166, 156 }, { 184, 124 }, { 206, 108 }, { 250, 108 }, { 268, 130 }, { 292, 172 }, { 316, 202 }, { 336, 234 } }), 51)
  local RK = { hi = "#e4e8f4", base = "#9ca4bc", shade = "#646c8c", deep = "#3e4468" }
  litL(sp, RK, 52, { R = 24, tex = .6, sc = 4 })
  sp:each(function(x, y) if y < 116 and not sp:has(x, y - 2) then P(x, y, "#ffffff") end end)
  local den = rough(PL({ { 192, 234 }, { 192, 208 }, { 206, 188 }, { 240, 182 }, { 262, 194 }, { 272, 234 } }), 54); c:rim(den, INK)
  den:each(function(x, y) P(x, y, y > 212 and "#241830" or "#1b1223") end)
  local YE = { hi = "#fffbb0", base = "#ffd23c", shade = "#e0902c", deep = "#9a5a30" }
  eyeL(220, 206, 5, 4, YE); eyeL(244, 206, 5, 4, YE)
  for k = 0, 4 do P(225 + k * 4, 217, "#f4f4ff"); P(225 + k * 4, 218, "#f4f4ff") end
  -- the wolf king: large howling silhouette, snout to the moon
  local ox, oy, sc = 226, 114, .92
  local function W(pts) local t = {} for i, p in ipairs(pts) do t[i] = { ox + p[1] * sc, oy + p[2] * sc } end return PL(t) end
  local wolf = W({ { -40, -46 }, { -22, -54 }, { -4, -54 }, { 10, -56 }, { 16, -66 }, { 19, -76 }, { 19, -86 }, { 17, -100 }, { 24, -93 }, { 30, -96 },
    { 42, -105 }, { 52, -114 }, { 59, -120 }, { 62, -116 }, { 59, -110 }, { 50, -101 }, { 41, -92 }, { 36, -82 }, { 37, -68 }, { 38, -54 }, { 36, -40 }, { 35, -24 }, { 34, -10 }, { 38, -1 }, { 20, -1 }, { 20, -12 }, { 16, -26 },
    { 4, -24 }, { -14, -24 }, { -19, -26 }, { -17, -12 }, { -12, -1 }, { -30, -1 }, { -32, -12 }, { -37, -28 }, { -44, -36 } })
  local tail = spline({ { ox - 38 * sc, oy - 42 * sc }, { ox - 52 * sc, oy - 36 * sc }, { ox - 60 * sc, oy - 22 * sc }, { ox - 58 * sc, oy - 8 * sc } }, 4 * sc, 7 * sc, function(t) return (4 + sin(t * 3.1) * 4) * sc end)
  local sil = wolf:copy():add(tail)
  c:rim(sil, "#1a1830")
  sil:each(function(x, y)
    local col = "#2c2f58"
    if not sil:has(x - 1, y - 1) or not sil:has(x - 2, y) then col = "#7884b4" elseif not sil:has(x + 1, y + 1) then col = "#1e2040" end
    if GX.vn(x, y, 3, 62) > .72 and col == "#2c2f58" then col = "#383c68" end
    P(x, y, col)
  end)
  -- howl breath
  for i, p in ipairs{ { 290, 14, 3 }, { 300, 8, 2 }, { 308, 4, 2 } } do local m = disc(mk(), p[1], p[2], p[3], p[3]); fill(m, "#f4f6ff") end
  -- banner pole and paw prints
  ln(78, 226, 78, 168, "#6e4a48", 2)
  local fl = PL({ { 80, 170 }, { 110, 174 }, { 104, 182 }, { 110, 192 }, { 80, 190 } }); litL(fl, { hi = "#c8ccdc", base = "#888ea8", shade = "#5a6084", deep = "#3a4068" }, 65, { R = 5, tex = .3 })
  for x = 84, 100 do P(x, 180, "#f5cf6a") end
  for i = 0, 7 do local x, y = 340 + i * 16, 246 + (i % 2) * 6 - floor(i * .5)
    fill(E(x, y, 2, 2), "#8c98c8"); for _, q in ipairs{ { -3, -3 }, { -1, -4 }, { 1, -4 }, { 3, -3 } } do P(x + q[1], y + q[2], "#8c98c8") end end
  for i = 1, 60 do P(floor(H(i, 7, 3) * 479), floor(H(i, 7, 4) * 262), "#f4f4ff") end
end)

---------------------------------------------------------------- 7 cenote of echoes
pic("wonder-cenote-of-echoes", function()
  sky({ "#232e34", "#2a3a40", "#32444a", "#2c3c44" }, 0, 270, 3)
  for y = 0, 269 do for x = 0, 479 do local h = H(x // 3, y // 2, 5); if h > .9 then P(x, y, "#3e5258") elseif h < .06 then P(x, y, "#1c262c") end end end
  local CX, CY = 240, 56
  local hole = rough(E(CX, CY, 112, 34), 71)
  local outer = rough(E(CX, CY, 140, 52), 72)
  local ring = outer:copy():cut(hole)
  -- sky inside the hole
  local skyc = { "#8cd0e8", "#a8dcec", "#c8ecee", "#e8f6e8" }
  hole:each(function(x, y) P(x, y, skyc[max(1, min(4, 1 + floor((y - 22) / 14)))]) end)
  cloudp(210, 50, 44, "#fffdf0", "#cfe6e8"); cloudp(300, 40, 30, "#fffdf0", "#cfe6e8")
  c:rim(hole, INK)
  -- grey rock ring with lit lip
  local RK = RR("#d8dad4", "#a4a8a4", "#6e7480", "#484e5c")
  lit(ring, RK, 73, { R = 20, tex = .7, sc = 3 })
  ring:each(function(x, y) if hole:has(x, y + 1) or hole:has(x - 1, y + 1) then P(x, y, RK.hi) end end)
  -- sparse greenery on the outer lip
  for i = 0, 14 do local a = pi + (i + .5) / 15 * pi; local x, y = CX + 138 * cos(a), CY + 50 * sin(a)
    if i % 2 == 0 then GX.foliage(c, floor(x), floor(y) + 2, 12 + (i % 3) * 3, 6, RR("#8cd05a", "#4a9a48", "#2e6e44", "#1e4a38"), 80 + i) end end
  -- hanging roots
  for i = 0, 6 do local x = 120 + i * 40 + floor(H(i, 2, 2) * 16); local len = 20 + floor(H(i, 4, 4) * 44); for y = 76, 76 + len do P(x + floor(sin(y / 7 + i)), y, y % 6 == 5 and "#9ad45a" or "#4a8a48") end end
  -- stalactites
  for _, s in ipairs{ { 40, 40, 16, 70 }, { 96, 70, 11, 40 }, { 400, 66, 12, 46 }, { 446, 36, 16, 78 }, { 150, 94, 8, 24 }, { 330, 98, 8, 22 } } do
    local m = PL({ { s[1] - s[3], s[2] }, { s[1] + s[3], s[2] }, { s[1] + 2, s[2] + s[4] }, { s[1], s[2] + s[4] + 4 } }); flat(m, RR("#b8bcb4", "#80888c", "#545c68", "#383e4c"), s[1], { sc = 3 })
  end
  -- light shaft: dithered, widening down
  local shaft = PL({ { 140, 84 }, { 340, 84 }, { 390, 226 }, { 90, 226 } })
  shaft:each(function(x, y) local t = (y - 84) / 142; local edge = min(x - (140 - t * 50), (340 + t * 50) - x)
    local o = c:get(x, y); if o then
      local a = (edge < 8) and .28 or .5
      if (x + y) % 2 == 0 then P(x, y, mix(o, "#fff4b8", a)) else P(x, y, mix(o, "#fff4b8", a * .45)) end end end)
  local core = PL({ { 176, 86 }, { 304, 86 }, { 330, 226 }, { 150, 226 } })
  core:each(function(x, y) local o = c:get(x, y); if o and (x + y) % 2 == 1 then P(x, y, mix(o, "#ffffe8", .5)) end end)
  -- pool basin
  local ledge = E(240, 232, 214, 44); lit(ledge, RK, 5, { R = 18, tex = .6 })
  local pool = E(240, 232, 190, 34)
  c:rim(pool, INK)
  pool:each(function(x, y) local dy = (y - 198) / 68; P(x, y, dy < .2 and "#1a5e78" or (dy < .45 and "#1f7a94" or (dy < .75 and "#28a0aa" or "#44c8c0"))) end)
  for k = 1, 5 do local rx, ry = 20 + k * 24, 4 + k * 5
    E(240, 226, rx, ry):copy():cut(E(240, 226, rx - 2, ry - 1)):clip(pool):each(function(x, y) if (x + k) % 3 ~= 0 then P(x, y, (k % 2 == 1) and "#d8fff0" or "#8ee8dc") end end) end
  fill(E(240, 226, 62, 12), "#e8fff0"); fill(E(240, 226, 36, 7), CREAM)
  for i = 0, 40 do local x, y = 70 + floor(H(i, 41, 1) * 340), 204 + floor(H(i, 43, 1) * 56); if pool:has(x, y) then P(x, y, "#9aeee0"); P(x + 1, y, "#9aeee0") end end
  -- stepping stones and echo stone
  for _, s in ipairs{ { 156, 242, 16, 6 }, { 200, 236, 12, 5 }, { 290, 238, 12, 5 }, { 334, 244, 16, 6 } } do lit(E(s[1], s[2], s[3], s[4]), RK, s[1], { R = 5, tex = .5 }) end
  lit(E(240, 222, 12, 8), RK, 7, { R = 6, tex = .4 }); fill(R(239, 214, 241, 220), "#ffe38a"); c:sparkle(240, 208)
  -- foreground ledges
  for _, f in ipairs{ { 20, 256, 60, 26 }, { 460, 258, 64, 26 } } do lit(rough(E(f[1], f[2], f[3], f[4]), f[1]), RK, f[1], { R = 12, tex = .6 }) end
  -- quirk: sleeping bat on a stalactite
  fill(R(96, 107, 98, 114), INK)
  local bat = E(97, 118, 4, 5); lit(bat, RR("#8a7a90", "#5e5068", "#443a52", "#2e2640"), 9, { R = 3, tex = 0 })
  P(95, 120, "#ffd0d8"); P(99, 120, "#ffd0d8")
  for i = 1, 30 do local x, y = 150 + floor(H(i, 8, 8) * 180), 100 + floor(H(i, 9, 8) * 110); c:px(x, y, "#fffbe0") end
  c:sparkle(210, 150); c:sparkle(280, 120)
end)

---------------------------------------------------------------- 8 flamingo shallows
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
  -- distant flocks: tiny, varied
  local far = { { 40, 150, .26, 1, "stand" }, { 82, 156, .3, -1, "feed" }, { 130, 148, .24, 1, "one" }, { 190, 158, .3, 1, "stand" }, { 296, 152, .26, -1, "preen" }, { 356, 160, .3, -1, "stand" }, { 410, 150, .24, 1, "feed" }, { 452, 158, .28, -1, "one" } }
  for _, f in ipairs(far) do flamingo(f[1], f[2], f[3], f[4], f[5]) end
  -- mid and heroes
  flamingo(66, 214, .85, 1, "preen")
  flamingo(436, 220, .9, -1, "feed")
  flamingo(120, 256, 1.45, 1, "feed")
  flamingo(380, 258, 1.45, -1, "one")
  flamingo(250, 264, 1.75, 1, "stand")
  flamingo(330, 206, 1.0, -1, "flap")
  -- quirk: a small crab-hatted ... a little frog on a lily pad
  fill(E(190, 236, 12, 3), "#4cb064"); c:rim(E(190, 236, 12, 3), INK)
  lit(E(190, 232, 5, 4), RR("#d8f070", "#8ccc48", "#4e9a44", "#2e6a3c"), 7, { R = 3, tex = 0 }); P(188, 230, INK); P(192, 230, INK)
  for i = 1, 20 do c:sparkle(floor(H(i, 5, 5) * 470) + 4, 140 + floor(H(i, 6, 5) * 120)) end
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
