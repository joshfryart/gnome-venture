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
    if i % 4 == 0 then P(x, y + 1, "#a8e8e0"); P(x + 1, y, col) end
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
  local mcx, mcy = hd[1] + hd.tx * 1.5 * sc + hd.nx * 4.5 * sc, hd[2] + hd.ty * 1.5 * sc + hd.ny * 4.5 * sc
  disc(body, mcx, mcy, 9.5 * sc, 9.5 * sc)
  all[#all + 1] = { mcx, mcy, 9.5 * sc, nx = hd.nx, ny = hd.ny }
  -- beak: long thin
  local bdx, bdy = hd.tx - hd.nx * .12, hd.ty - hd.ny * .12
  local bl = sqrt(bdx * bdx + bdy * bdy); bdx, bdy = bdx / bl, bdy / bl
  local bsx, bsy = hd[1] + hd.tx * 5 * sc - hd.nx * 2.4 * sc, hd[2] + hd.ty * 5 * sc - hd.ny * 2.4 * sc
  local beak = {}
  for k = 0, 24 do
    local u = k / 24; local x, y, r = bsx + bdx * u * 19 * sc, bsy + bdy * u * 19 * sc, (4.2 - 2.3 * u) * sc
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
  local fbx, fby = f0[1] - f0.nx * f0[3] * .5 + f0.tx * 2 * sc, f0[2] - f0.ny * f0[3] * .5 + f0.ty * 2 * sc
  local fdx, fdy = -f0.nx * .75 - f0.tx * .65, -f0.ny * .75 - f0.ty * .65
  local fln = sqrt(fdx * fdx + fdy * fdy); fdx, fdy = fdx / fln, fdy / fln
  local fp = spline({ { fbx, fby }, { fbx + fdx * 8 * sc, fby + fdy * 8 * sc }, { fbx + fdx * 17 * sc, fby + fdy * 17 * sc } }, 0, 0, function(t) return sc * (3 + 3.4 * sin(t * 3.1416) ^ .6) end, 8)
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
  dolphin({ pts = { { 84, 276 }, { 118, 264 }, { 146, 250 }, { 170, 240 } }, sc = .5, seed = 91, clip = 262, refl = 262 })
  -- adult surfacing, only head and back
  dolphin({ pts = { { 316, 276 }, { 356, 262 }, { 392, 242 }, { 424, 226 }, { 446, 214 } }, sc = .95, seed = 61, clip = 238, refl = 238 })
  -- leaping dolphin, S-curve arc
  dolphin({ pts = { { 44, 176 }, { 76, 198 }, { 118, 186 }, { 162, 150 }, { 208, 116 }, { 254, 104 }, { 292, 122 }, { 316, 152 } }, sc = 1.05, seed = 51, refl = 222 })
  -- splashes: exit wake and entry
  ring(54, 224, 28, 5); ring(54, 226, 16, 3); ring(350, 226, 34, 6); ring(350, 228, 20, 4)
  drops(52, 200, 26, 22, 1); drops(340, 206, 34, 28, 2); drops(130, 214, 8, 16, 3)
  -- trail of droplets along the arc
  for i = 1, 22 do local x = 80 + floor(H(i, 5, 5) * 220); local y = 170 + floor(H(i, 6, 5) * 40) - floor(sin((x - 80) / 220 * 3.1) * 60); if y < 218 then P(x, y, i % 2 == 0 and "#d8fff0" or CREAM) end end
  -- quirk: frog on a lily pad
  local fg = E(446, 247, 6, 4); lit(fg, RR("#d8f070", "#8ccc48", "#4e9a44", "#2e6a3c"), 77, { R = 3, tex = 0 })
  P(442, 243, INK); P(450, 243, INK); P(442, 242, "#ffe49a"); P(450, 242, "#ffe49a")
  for i = 1, 30 do local x, y = floor(H(i, 7, 7) * 470), 20 + floor(H(i, 8, 7) * 150); P(x, y, "#fff2b0") end
end)
