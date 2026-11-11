---------------------------------------------------------------- W1: prop library (x = centre, gy = ground line)
PR.can = function(x, gy) can(x, gy) end
PR.acorn = function(x, gy) acorn(x, gy) end
PR.chimes = function(x) chimes(x) end
PR.mushroom = function(x, gy, col) mushroom(x, gy + 1, 2, col or "#e8493b"); mushroom(x + 7, gy + 3, 1, col or "#e8493b") end

PR.clothesline = function()
  local cols = { { REDW, CREAM }, { TEAL, GOLD }, { BLUEW, ROSE } }
  local function ly(x) return 94 + floor((x - 146) * .08 + sin((x - 146) / 66 * 3.14) * 4) end
  for x = 148, 214 do P(x, ly(x) + 1, INK); P(x, ly(x), CREAM[4]) end
  for i, x in ipairs{ 154, 172, 192 } do
    local y = ly(x) + 2; local cl = cols[i]
    local m = rect(x, y, x + 11, y + 14 + (i % 2) * 3); c:rim(m, INK)
    m:each(function(xx, yy) local k = ((yy - y) // 3) % 2; P(xx, yy, k == 0 and cl[1][4] or cl[2][5]); if yy == y then P(xx, yy, cl[1][6]) end; if xx >= x + 10 then P(xx, yy, cl[1][3]) end end)
    P(x + 1, y - 1, INK); P(x + 9, y - 1, INK)
  end
end
PR.yarn = function(x, gy)
  gsh(x, gy, 15)
  ball(x - 7, gy - 5, 5, REDW); ball(x + 6, gy - 5, 5, TEAL); ball(x - 1, gy - 14, 5, GOLD)
  for k = -3, 3 do P(x - 7 + k, gy - 5 + k // 2, REDW[2]) end
  for k = -3, 3 do P(x + 6 + k, gy - 6 - k // 2, TEAL[2]) end
  local n = c:line({ { x + 3, gy - 15 }, { x + 16, gy - 32 } }, 1); c:rim(n, INK); c:fillMask(n, GOLD[5])
  P(x + 17, gy - 33, ROSE[5]); P(x + 16, gy - 33, INK)
  for k = 0, 9 do P(x + 4 + floor(sin(k / 2) * 2) + k, gy - 5 + k // 2, REDW[4]) end
end
PR.hatpeg = function(x)
  local y = 150
  c:fillMask(rect(x + 2, y, x + 4, y + 3), INK); P(x + 3, y + 1, TIMB[5])
  local dome = c:ellipse(x + 3, y - 5, 5, 4); dome:cut(rect(x - 4, y - 3, x + 10, y + 3)); c:rim(dome, INK)
  dome:each(function(xx, yy) P(xx, yy, (xx < x + 3) and OAK[5] or OAK[3]) end)
  local br = rect(x - 4, y - 3, x + 10, y - 2); c:rim(br, INK); c:fillMask(br, OAK[4])
  for xx = x - 2, x + 8 do P(xx, y - 4, REDW[4]) end
  P(x + 11, y - 9, ROSE[5]); P(x + 10, y - 9, REDW[5]); P(x + 9, y - 8, INK)
end

PR.books = function(x, gy)
  gsh(x, gy, 14)
  local sp = { { VIO, 18, 6 }, { REDW, 15, 5 }, { TEAL, 16, 5 }, { GOLD, 12, 4 } }
  local y = gy
  for i, s in ipairs(sp) do
    local ox = ((i % 2) * 2 - 1) * 2
    local x0, x1 = x - s[2] // 2 + ox, x + s[2] // 2 + ox
    local m = rect(x0, y - s[3], x1, y - 1); c:rim(m, INK)
    m:each(function(xx, yy) local t = 4; if yy == y - s[3] then t = 6 elseif yy >= y - 2 then t = 3 elseif xx == x0 then t = 5 end; P(xx, yy, s[1][t]) end)
    for xx = x1 - 3, x1 do for yy = y - s[3] + 1, y - 2 do P(xx, yy, CREAM[5]) end end
    P(x0 + 2, y - 3, GOLD[5])
    y = y - s[3]
  end
  c:fillMask(rect(x - 1, y - 9, x + 1, y - 1), INK); c:fillMask(rect(x, y - 8, x, y - 2), CREAM[5])
  S.glow(x, y - 12, 11, "#ffd070", .4); P(x, y - 11, "#ffd24a"); P(x, y - 10, "#fff6cc")
end
PR.cauldron = function(x, gy)
  gsh(x, gy, 17)
  for _, lx in ipairs{ x - 9, x + 7 } do c:fillMask(rect(lx - 1, gy - 5, lx + 2, gy), INK); P(lx, gy - 4, IRON[4]) end
  S.glow(x, gy - 16, 24, "#a8ff80", .25)
  local b = c:ellipse(x, gy - 11, 13, 10):clip(rect(x - 14, gy - 22, x + 14, gy - 3)); c:rim(b, INK)
  b:each(function(xx, yy) local l = lit(xx, yy, x, gy - 11, 12); P(xx, yy, IRON[l > .5 and 5 or (l > 0 and 4 or (l > -.5 and 3 or 2))]) end)
  c:fillMask(rect(x - 14, gy - 22, x + 14, gy - 20), INK); c:fillMask(rect(x - 13, gy - 21, x + 13, gy - 21), IRON[5])
  c:fillMask(c:ellipse(x, gy - 22, 11, 2), "#8cf060"); c:fillMask(c:ellipse(x - 2, gy - 22, 6, 1), "#c8ffa0")
  ball(x - 4, gy - 28, 3, GREEN); ball(x + 5, gy - 31, 2, GREEN); ball(x + 1, gy - 36, 2, LEAF)
  P(x - 5, gy - 29, "#e8ffd0")
end
PR.shovel = function(x, gy)
  pole(x + 1, gy - 13, x + 9, gy - 48, 2, TIMB)
  c:fillMask(rect(x + 6, gy - 52, x + 14, gy - 49), INK); c:fillMask(rect(x + 7, gy - 51, x + 13, gy - 50), TIMB[5])
  local bl = c:ellipse(x, gy - 7, 5, 7); c:rim(bl, INK)
  bl:each(function(xx, yy) P(xx, yy, (xx < x) and IRON[5] or IRON[3]) end); P(x - 2, gy - 11, IRON[6]); P(x, gy - 1, INK)
end
PR.dirtmound = function(x, gy)
  local m = c:ellipse(x, gy, 15, 8):clip(rect(x - 16, gy - 9, x + 16, gy + 1)); c:rim(m, INK)
  m:each(function(xx, yy) local l = lit(xx, yy, x, gy, 10); local t = l > .5 and 5 or (l > 0 and 4 or 3); if hash(xx, yy, 3) > .9 then t = t - 1 end; P(xx, yy, OAK[t]) end)
  for _, q in ipairs{ { -5, -3 }, { 4, -5 }, { 9, -1 } } do P(x + q[1], gy + q[2], STONE[5]); P(x + q[1] + 1, gy + q[2], STONE[3]) end
  c:fillMask(rect(x + 8, gy - 14, x + 8, gy - 8), TIMB[4]); tri(x + 9, gy - 14, x + 15, gy - 12, x + 9, gy - 10, REDW[4])
end
PR.wheelbarrow = function(x, gy)
  gsh(x, gy, 18)
  local lines = c:line({ { x + 10, gy - 12 }, { x + 27, gy - 7 } }, 1); c:rim(lines, INK); c:fillMask(lines, TIMB[4])
  c:fillMask(rect(x + 6, gy - 7, x + 8, gy - 1), INK); P(x + 7, gy - 4, TIMB[4])
  local m = HP.mask()
  for yy = gy - 17, gy - 7 do local ins = (yy - (gy - 17)) // 3; for xx = x - 14 + ins, x + 14 - ins do m:set(xx, yy) end end
  c:rim(m, INK); m:each(function(xx, yy) local t = 4; if yy == gy - 17 then t = 6 elseif yy >= gy - 9 then t = 3 elseif xx < x - 8 then t = 5 end; P(xx, yy, REDW[t]) end)
  local d = c:ellipse(x, gy - 18, 12, 4):clip(rect(x - 13, gy - 23, x + 13, gy - 17)); c:rim(d, INK); d:each(function(xx, yy) P(xx, yy, OAK[(xx + yy) % 5 == 0 and 5 or 3]) end)
  ball(x - 10, gy - 5, 5, IRON); c:fillMask(c:ellipse(x - 10, gy - 5, 1, 1), GOLD[4])
end

PR.clovers = function(x, gy)
  gsh(x, gy + 2, 17)
  for _, q in ipairs{ { -14, -3, 2 }, { 12, -4, 2 }, { 3, -2, 2 }, { -3, -11, 3 }, { 9, -14, 2 } } do
    if q[2] < -6 then stem(x + q[1], gy + q[2] + 3, x + q[1] + 1, gy, GREEN) end
    clover(x + q[1], gy + q[2], q[3], GREEN)
  end
  for _, q in ipairs{ { -8, -2 }, { 17, -1 } } do P(x + q[1], gy + q[2], CREAM[6]); P(x + q[1] + 1, gy + q[2], ROSE[5]) end
end
PR.thornvine = function(x)
  for y = 206, 116, -1 do
    local vx = floor(x + 5 * sin(y / 9) + .5)
    P(vx - 1, y, INK); P(vx + 1, y, INK); P(vx, y, GREEN[(y % 4 < 2) and 3 or 2])
    if y % 7 == 0 then P(vx + 2, y, IRON[5]); P(vx + 3, y - 1, IRON[6]); P(vx - 2, y - 3, IRON[5]); P(vx - 3, y - 4, IRON[6]) end
    if y % 19 == 0 then ball(vx + 4, y, 2, REDW); P(vx + 3, y - 1, "#ffc8b0") end
  end
end
PR.whistle = function(x)
  for y = 108, 118 do P(x, y, DIRT[4]) end
  P(x - 1, 107, INK); P(x, 106, INK); P(x + 1, 107, INK)
  local m = rect(x - 2, 119, x + 2, 140); c:rim(m, INK)
  m:each(function(xx, yy) P(xx, yy, (xx == x - 2) and IRON[6] or ((xx == x + 2) and IRON[3] or IRON[5])) end)
  for yy = 128, 138, 3 do P(x, yy, INK) end
  c:fillMask(rect(x - 2, 119, x + 2, 121), GOLD[4]); P(x - 2, 119, GOLD[6])
  tri(x + 3, 112, x + 9, 108, x + 8, 116, REDW[4]); tri(x - 3, 112, x - 9, 108, x - 8, 116, REDW[5])
end

PR.buoys = function(x)
  for xx = x - 12, x + 12 do P(xx, 99, INK); P(xx, 100, DIRT[4]) end
  for _, q in ipairs{ { -8, 112, 5, REDW }, { 6, 118, 5, ORNG }, { 15, 108, 4, REDW } } do
    local cx, cy, r = x + q[1], q[2], q[3]
    for yy = 101, cy - r do P(cx, yy, DIRT[4]) end
    local m = ball(cx, cy, r, q[4])
    for xx = cx - r, cx + r do if m:has(xx, cy) or m:has(xx, cy + 1) then P(xx, cy, CREAM[5]); P(xx, cy + 1, CREAM[4]) end end
  end
end
PR.mpot = function(x, gy)
  gsh(x, gy, 10)
  for _, q in ipairs{ { -4, 22 }, { 3, 28 }, { 8, 18 } } do stem(x + q[1], gy - 10, x + q[1], gy - q[2] + 3, GREEN) end
  local pot = HP.mask(); for yy = gy - 10, gy do local ins = (yy - (gy - 10)) // 4; for xx = x - 7 + ins, x + 7 - ins do pot:set(xx, yy) end end
  c:rim(pot, INK); pot:each(function(xx, yy) P(xx, yy, (xx < x - 2) and BARN[5] or ((xx > x + 3) and BARN[3] or BARN[4])) end)
  c:fillMask(rect(x - 8, gy - 12, x + 8, gy - 10), INK); c:fillMask(rect(x - 7, gy - 12, x + 7, gy - 11), BARN[5])
  for _, q in ipairs{ { -4, 22 }, { 3, 28 }, { 8, 18 } } do bloom(x + q[1], gy - q[2], 3, ORNG, ORNG) end
end
PR.sunflowers = function(x, gy)
  gsh(x + 7, gy, 17)
  for _, s in ipairs{ { 0, 62, 8 }, { 15, 48, 7 } } do
    local sx, h, r = x + s[1], s[2], s[3]
    stem(sx, gy - h, sx, gy, GREEN)
    leafp(sx - 6, gy - h // 2, 5, 2, LEAF); leafp(sx + 6, gy - h // 3, 5, 2, LEAF)
    sflower(sx, gy - h, r, GOLD, OAK)
  end
end
PR.bamboo = function(x, gy)
  gsh(x + 8, gy, 17)
  for _, s in ipairs{ { 0, 76 }, { 8, 58 }, { 16, 86 } } do
    local sx, h = x + s[1], s[2]
    local m = rect(sx, gy - h, sx + 3, gy); c:rim(m, INK)
    m:each(function(xx, yy) local t = (xx == sx) and LEAF[6] or ((xx == sx + 3) and LEAF[3] or LEAF[5]); if (gy - yy) % 14 == 0 then t = LEAF[2] end; P(xx, yy, t) end)
    leafp(sx - 6, gy - h + 6, 6, 2, GREEN); leafp(sx + 9, gy - h + 14, 6, 2, GREEN); leafp(sx + 1, gy - h - 4, 2, 5, GREEN)
  end
end
PR.pinwheel = function(x, gy)
  gsh(x, gy, 8)
  local cx, cy = x, gy - 42
  pole(x, cy, x, gy, 1, TIMB)
  local cols = { REDW[4], GOLD[5], TEAL[5], ROSE[5] }
  tri(cx, cy, cx + 11, cy - 1, cx + 11, cy - 11, cols[1]); tri(cx, cy, cx + 1, cy + 11, cx + 11, cy + 11, cols[2])
  tri(cx, cy, cx - 11, cy + 1, cx - 11, cy + 11, cols[3]); tri(cx, cy, cx - 1, cy - 11, cx - 11, cy - 11, cols[4])
  ball(cx, cy, 2, GOLD)
end

PR.easel = function(x, gy)
  gsh(x, gy, 16)
  pole(x, gy - 62, x - 15, gy, 2, TIMB); pole(x, gy - 62, x + 15, gy, 2, TIMB); pole(x + 1, gy - 56, x + 5, gy, 1, TIMB)
  local cv = rect(x - 12, gy - 54, x + 12, gy - 24); c:rim(cv, INK)
  cv:each(function(xx, yy) P(xx, yy, (yy < gy - 40) and "#a8c8ec" or "#8ec47a") end)
  c:fillMask(c:ellipse(x - 5, gy - 46, 4, 4), "#ffd24a"); c:fillMask(rect(x - 12, gy - 40, x + 12, gy - 40), "#6aa458")
  c:fillMask(c:ellipse(x + 5, gy - 33, 8, 3), "#e8798c"); c:fillMask(rect(x + 4, gy - 38, x + 8, gy - 34), "#c84a5c")
  c:fillMask(rect(x - 11, gy - 53, x + 11, gy - 53), CREAM[6])
  bx(x - 14, gy - 24, x + 14, gy - 22, TIMB)
end
PR.paintpots = function(x, gy)
  gsh(x, gy, 17)
  for i, pc in ipairs{ BLUEW, REDW, GOLD } do
    local px = x - 14 + (i - 1) * 12
    bx(px, gy - 10, px + 8, gy - 1, CREAM)
    c:fillMask(rect(px + 1, gy - 9, px + 7, gy - 7), pc[4]); c:fillMask(rect(px + 1, gy - 9, px + 3, gy - 9), pc[6])
    c:fillMask(rect(px - 1, gy - 12, px + 9, gy - 11), INK); c:fillMask(rect(px, gy - 12, px + 8, gy - 12), pc[5])
  end
  local br = c:line({ { x - 12, gy - 12 }, { x - 15, gy - 24 } }, 1); c:rim(br, INK); c:fillMask(br, TIMB[5]); P(x - 15, gy - 25, REDW[4])
  P(x - 16, gy - 26, INK)
end

PR.kettle = function(x, gy)
  gsh(x, gy, 17)
  bx(x - 13, gy - 4, x + 13, gy - 1, STONE)
  local sp = c:line({ { x + 8, gy - 16 }, { x + 19, gy - 28 } }, 2); c:rim(sp, INK); c:fillMask(sp, COPPER[4])
  local hd = c:ellipse(x - 12, gy - 18, 6, 8); hd:cut(c:ellipse(x - 12, gy - 18, 3, 5)); c:rim(hd, INK); c:fillMask(hd, COPPER[3])
  ball(x, gy - 16, 11, COPPER)
  bx(x - 5, gy - 30, x + 5, gy - 26, COPPER); ball(x, gy - 33, 2, COPPER)
  for k = 0, 10 do local sx = x + 21 + floor(sin(k / 2) * 2); P(sx, gy - 30 - k, CREAM[5]); P(sx + 1, gy - 30 - k, CREAM[3]) end
end
PR.teachest = function(x, gy)
  gsh(x, gy, 17)
  local m = bx(x - 13, gy - 16, x + 13, gy - 1, TIMB)
  for yy = gy - 12, gy - 3, 4 do for xx = x - 12, x + 12 do P(xx, yy, TIMB[2]) end end
  c:fillMask(rect(x - 6, gy - 13, x + 6, gy - 5), CREAM[5]); c:fillMask(rect(x - 6, gy - 13, x + 6, gy - 13), CREAM[6]); leafp(x, gy - 9, 3, 2, GREEN)
  bx(x - 14, gy - 20, x + 14, gy - 16, OAK)
  for _, q in ipairs{ { -8, -22 }, { -3, -23 }, { 5, -22 }, { 9, -21 } } do P(x + q[1], gy + q[2], LEAF[4]); P(x + q[1] + 1, gy + q[2] + 1, GREEN[3]) end
end
PR.mugrack = function(x)
  local y = 144
  local m = rect(x - 14, y, x + 14, y + 2); c:rim(m, INK); c:fillMask(m, TIMB[4]); c:fillMask(rect(x - 14, y, x + 14, y), TIMB[6])
  for i, mc in ipairs{ REDW, GOLD, BLUEW } do
    local mx = x - 9 + (i - 1) * 9
    P(mx, y + 3, IRON[5])
    local mm = rect(mx - 3, y + 4, mx + 3, y + 11); c:rim(mm, INK)
    mm:each(function(xx, yy) P(xx, yy, (xx == mx - 3) and mc[6] or ((xx >= mx + 2) and mc[3] or mc[4])) end)
    P(mx + 4, y + 6, INK); P(mx + 5, y + 6, INK); P(mx + 5, y + 7, INK); P(mx + 5, y + 8, INK); P(mx + 4, y + 9, INK)
  end
end

PR.fiddle = function(x)
  local cy = 150
  P(x, 118, INK); P(x - 1, 119, INK); P(x + 1, 119, INK)
  local m = c:ellipse(x, cy - 5, 6, 5); m:add(c:ellipse(x, cy + 5, 7, 6)); m:cut(rect(x - 3, cy - 1, x + 3, cy + 1)); m:add(rect(x - 3, cy - 2, x + 3, cy + 2))
  c:rim(m, INK); m:each(function(xx, yy) P(xx, yy, ((xx + yy) % 7 == 0) and ORNG[2] or ((xx < x) and ORNG[4] or ORNG[3])) end)
  local fb = rect(x - 1, 124, x + 1, cy - 4); c:rim(fb, INK); c:fillMask(fb, IRON[2])
  ball(x, 122, 2, ORNG)
  P(x - 3, cy + 3, INK); P(x + 3, cy + 3, INK); P(x - 3, cy + 4, INK); P(x + 3, cy + 4, INK)
  c:fillMask(rect(x - 4, cy + 10, x + 4, cy + 10), INK); c:fillMask(rect(x, cy - 7, x, cy + 10), CREAM[4])
  local bw = c:line({ { x + 10, 160 }, { x + 18, 134 } }, 1); c:rim(bw, INK); c:fillMask(bw, CREAM[5])
end
PR.fernpot = function(x, gy)
  gsh(x, gy, 14)
  local pot = HP.mask(); for yy = gy - 10, gy do local ins = (yy - (gy - 10)) // 4; for xx = x - 7 + ins, x + 7 - ins do pot:set(xx, yy) end end
  c:rim(pot, INK); pot:each(function(xx, yy) P(xx, yy, (xx < x - 2) and BARN[5] or ((xx > x + 3) and BARN[3] or BARN[4])) end)
  c:fillMask(rect(x - 8, gy - 12, x + 8, gy - 10), INK); c:fillMask(rect(x - 7, gy - 12, x + 7, gy - 11), BARN[5])
  for _, a in ipairs{ { -16, 18 }, { -9, 30 }, { 0, 36 }, { 9, 30 }, { 16, 18 } } do
    local m = c:line({ { x, gy - 12 }, { x + a[1] * .6, gy - 12 - a[2] * .9 }, { x + a[1] * 1.3, gy - 12 - a[2] * .55 } }, 1)
    c:rim(m, INK); c:fillMask(m, LEAF[(a[1] < 0) and 5 or 4])
    for t = 1, 5 do local px, py = x + a[1] * (.15 + t * .2), gy - 12 - a[2] * (.9 - ((t % 3) * .08) - t * .05); P(floor(px), floor(py) - 1, LEAF[6]); P(floor(px), floor(py) + 1, GREEN[3]) end
  end
end
PR.musicstand = function(x, gy)
  gsh(x, gy, 14)
  pole(x - 11, gy, x, gy - 30, 1, IRON); pole(x + 11, gy, x, gy - 30, 1, IRON); pole(x, gy - 40, x, gy - 3, 1, IRON)
  local bd = rect(x - 13, gy - 58, x + 13, gy - 36); c:rim(bd, INK); c:fillMask(bd, TIMB[4]); c:fillMask(rect(x - 13, gy - 58, x + 13, gy - 58), TIMB[6])
  local sh = rect(x - 10, gy - 55, x + 10, gy - 39); c:fillMask(sh, CREAM[5])
  for k = 0, 3 do for xx = x - 9, x + 9 do P(xx, gy - 52 + k * 3, IRON[3]) end end
  for i, q in ipairs{ { -7, 2 }, { -2, 0 }, { 3, 3 }, { 7, 1 } } do local nx, ny = x + q[1], gy - 52 + q[2] * 1 + 1; P(nx, ny, INK); P(nx + 1, ny, INK); P(nx + 1, ny - 1, INK); P(nx + 1, ny - 2, INK); P(nx + 1, ny - 3, INK) end
end

PR.umbrella = function(x, gy)
  gsh(x, gy, 10)
  local top = gy - 50
  pole(x, gy - 30, x, gy - 3, 1, TIMB); P(x + 1, gy - 1, INK); P(x + 2, gy - 1, INK); P(x + 2, gy - 2, INK)
  local m = c:ellipse(x, gy - 32, 22, 17):clip(rect(x - 23, top - 1, x + 23, gy - 30)); c:rim(m, INK)
  m:each(function(xx, yy) local l = lit(xx, yy, x, gy - 32, 20); local t = l > .45 and 6 or (l > 0 and 5 or (l > -.4 and 4 or 3)); if (xx - x) % 8 == 0 then t = max(2, t - 2) end; P(xx, yy, PINK[t]) end)
  for k = -2, 2 do local ex = x + k * 8 + 4; P(ex, gy - 29, INK); P(ex, gy - 30, PINK[2]) end
  c:fillMask(rect(x - 1, top - 3, x + 1, top - 1), INK); P(x, top - 2, GOLD[5])
end
PR.puddle = function(x, gy)
  local yy0 = gy + 12
  local m = c:ellipse(x, yy0, 22, 5); c:rim(m, INK)
  m:each(function(xx, yy) P(xx, yy, ((yy < yy0 - 1) and SBLUE[5]) or SBLUE[4]) end)
  for k = 0, 8 do P(x - 12 + k, yy0 - 2, "#e8f4f8") end; for k = 0, 4 do P(x + 4 + k, yy0, "#e8f4f8") end
  for k = 0, 5 do P(x + 8 + k, yy0 + 2, SBLUE[3]) end; P(x - 9, yy0 + 1, SBLUE[6]); P(x - 3, yy0 + 1, SBLUE[6])
end
PR.barrel = function(x, gy)
  gsh(x, gy, 14)
  local m = rect(x - 10, gy - 26, x + 10, gy - 1); c:rim(m, INK)
  m:each(function(xx, yy) local t = ((xx - x) % 5 == 0) and 3 or 4; if xx < x - 6 then t = 5 elseif xx > x + 6 then t = 3 end; P(xx, yy, TIMB[t]) end)
  for _, by in ipairs{ gy - 22, gy - 5 } do for xx = x - 10, x + 10 do P(xx, by, IRON[4]); P(xx, by + 1, IRON[2]) end end
  c:fillMask(c:ellipse(x, gy - 26, 10, 2), SBLUE[4]); c:fillMask(c:ellipse(x - 2, gy - 27, 5, 1), "#e8f4f8")
  P(x + 11, gy - 12, INK); P(x + 12, gy - 12, IRON[5]); P(x + 12, gy - 11, INK)
end

PR.ivy = function(x)
  for i, s in ipairs{ { 0, 52 }, { 7, 38 }, { 15, 64 } } do
    local vx0, h = x + s[1], s[2]
    for yy = 96, 96 + h do local vx = vx0 + floor(sin(yy / 8 + i) * 1.5 + .5); P(vx - 1, yy, INK); P(vx + 1, yy, INK); P(vx, yy, GREEN[3 + (yy % 2)]) end
    for yy = 104, 96 + h, 11 do local vx = vx0 + floor(sin(yy / 8 + i) * 1.5 + .5); leafp(vx + ((yy // 11) % 2 * 8 - 4), yy, 4, 2, LEAF) end
  end
end
PR.nettle = function(x, gy)
  gsh(x, gy, 17)
  for _, l in ipairs{ { -12, 24 }, { 11, 26 }, { -5, 34 }, { 5, 40 }, { 0, 30 } } do
    local cx = x + l[1]
    tri(cx - 4, gy, cx + 4, gy, cx + l[1] // 3, gy - l[2], GREEN[4])
    for yy = gy - l[2] + 4, gy - 2, 3 do P(cx + (yy - gy) // 6 * 0, yy, GREEN[2]); P(cx - 3, yy, GREEN[6]); P(cx + 4, yy + 1, GREEN[2]) end
  end
  for _, q in ipairs{ { -8, -12 }, { 8, -20 }, { 0, -30 } } do P(x + q[1], gy + q[2], CREAM[6]) end
end

PR.pasta = function(x, gy)
  gsh(x, gy, 20)
  for _, px in ipairs{ x - 18, x + 18 } do local m = rect(px, gy - 36, px + 2, gy - 1); c:rim(m, INK); S.obj(m, TIMB, { base = 4, lit = 0, shade = 1 }) end
  for _, by in ipairs{ gy - 34, gy - 20 } do local b = rect(x - 20, by, x + 22, by + 2); c:rim(b, INK); S.obj(b, TIMB, { base = 4, lit = 1, shade = 1 })
    for xx = x - 16, x + 18, 3 do local l = 10 + floor(hash(xx, by, 3) * 6); for k = 1, l do P(xx, by + 2 + k, (k % 5 == 0) and GOLD[4] or GOLD[5]) end; P(xx, by + 3 + l, INK); P(xx + 1, by + 3, GOLD[3]) end end
end
PR.tomatoes = function(x, gy)
  gsh(x, gy, 17)
  for _, q in ipairs{ { -8, 17 }, { 0, 18 }, { 8, 17 }, { -4, 22 }, { 4, 22 } } do ball(x + q[1], gy - q[2] + 2, 4, REDW); P(x + q[1], gy - q[2] - 2, LEAF[5]); P(x + q[1] - 1, gy - q[2] - 1, GREEN[4]) end
  bx(x - 14, gy - 16, x + 14, gy - 1, TIMB)
  for yy = gy - 11, gy - 4, 5 do for xx = x - 13, x + 13 do P(xx, yy, TIMB[2]) end end
  c:fillMask(rect(x - 5, gy - 13, x + 5, gy - 7), CREAM[5]); P(x - 2, gy - 10, REDW[4]); P(x - 1, gy - 10, REDW[4]); P(x + 1, gy - 10, REDW[4])
end
PR.garlic = function(x)
  c:fillMask(rect(x - 1, 126, x + 1, 128), INK); P(x, 127, REDW[4])
  for i = 0, 4 do
    local by = 132 + i * 8; local bxx = x + ((i % 2) * 2 - 1) * 3
    ball(bxx, by, 4, CREAM); P(bxx, by - 4, INK); P(bxx, by - 5, DIRT[4]); P(bxx - 1, by + 1, ROSE[5])
  end
  for yy = 128, 174 do P(x, yy, REDW[3]) end
  for i = 0, 4 do local by = 132 + i * 8; local bxx = x + ((i % 2) * 2 - 1) * 3; ball(bxx, by, 4, CREAM) end
  c:fillMask(rect(x - 1, 172, x + 1, 176), REDW[4])
end

PR.gong = function(x, gy)
  gsh(x, gy, 20)
  for _, px in ipairs{ x - 17, x + 17 } do local m = rect(px, gy - 52, px + 3, gy - 1); c:rim(m, INK); S.obj(m, TIMB, { base = 4, lit = 0, shade = 1 }) end
  local b = rect(x - 19, gy - 54, x + 21, gy - 51); c:rim(b, INK); S.obj(b, TIMB, { base = 4, lit = 1, shade = 1 })
  for _, hx in ipairs{ x - 7, x + 7 } do for yy = gy - 50, gy - 40 do P(hx, yy, INK) end end
  ball(x, gy - 28, 13, GOLD)
  local r2 = c:ellipse(x, gy - 28, 8, 8); for k = 0, 40 do local a = k * .157; P(floor(x + cos(a) * 8 + .5), floor(gy - 28 + sin(a) * 8 + .5), GOLD[2]) end
  ball(x, gy - 28, 3, GOLD); P(x - 1, gy - 29, GOLD[6])
  local mal = c:line({ { x + 17, gy - 3 }, { x + 26, gy - 3 } }, 1); c:rim(mal, INK); c:fillMask(mal, TIMB[4]); ball(x + 27, gy - 3, 3, REDW)
end
PR.rice = function(x, gy)
  gsh(x, gy, 17)
  local m = HP.mask(); for yy = gy - 30, gy do local ins = (yy - (gy - 30)) * -.16; for xx = floor(x - 14 - ins * 1), floor(x + 14 + ins * 1) do m:set(xx, yy) end end
  c:rim(m, INK)
  m:each(function(xx, yy) local a, b = (xx + 3) // 3, yy // 3; local t = ((a + b) % 2 == 0) and 4 or 3; if xx < x - 8 then t = t + 1 elseif xx > x + 8 then t = t - 1 end; P(xx, yy, DIRT[max(1, min(6, t))]) end)
  c:fillMask(c:ellipse(x, gy - 31, 14, 3), CREAM[5]); c:fillMask(c:ellipse(x - 2, gy - 33, 9, 2), CREAM[6])
  for k = 0, 8 do P(x - 10 + k * 3, gy - 31 + (k % 2), CREAM[4]) end
  c:fillMask(rect(x - 13, gy - 17, x + 14, gy - 15), REDW[4])
end
PR.horns = function()
  for _, sd in ipairs{ -1, 1 } do
    local pts = { { 240 + sd * 136, 76 }, { 240 + sd * 142, 62 }, { 240 + sd * 140, 50 }, { 240 + sd * 132, 44 } }
    local m = c:line(pts, 3); c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, (yy % 4 == 0) and CREAM[3] or ((sd * (xx - 240) > 139) and CREAM[4] or CREAM[5])) end)
    P(240 + sd * 132, 43, CREAM[6])
  end
end

PR.cheese = function(x, gy)
  gsh(x, gy, 17)
  for _, w in ipairs{ { 0, 0, 14 }, { 4, -10, 11 } } do
    local cx, top = x + w[1], gy + w[2] - 10
    local side = rect(cx - w[3], top, cx + w[3], top + 8); side:add(c:ellipse(cx, top + 8, w[3], 3)); c:rim(side, INK)
    side:each(function(xx, yy) P(xx, yy, (xx < cx - w[3] // 2) and CHZ[5] or ((xx > cx + w[3] // 2) and CHZ[3] or CHZ[4])) end)
    c:fillMask(c:ellipse(cx, top, w[3], 3), CHZ[6]); c:fillMask(c:ellipse(cx + 2, top, 3, 1), CHZ[3]); c:fillMask(c:ellipse(cx - 5, top + 5, 2, 1), CHZ[2])
  end
  tri(x - 3, gy - 28, x + 8, gy - 27, x + 3, gy - 20, CHZ[5]); P(x + 2, gy - 25, CHZ[2])
end
PR.broom = function(x, gy)
  pole(x + 4, gy - 16, x + 12, gy - 52, 2, TIMB)
  local m = HP.mask(); for yy = gy - 18, gy - 1 do local sp = (yy - (gy - 18)) // 3; for xx = x - 3 - sp, x + 9 + sp do m:set(xx, yy) end end
  c:rim(m, INK); m:each(function(xx, yy) P(xx, yy, THATCH[((xx + yy // 2) % 3 == 0) and 3 or ((xx < x + 3) and 5 or 4)]) end)
  c:fillMask(rect(x - 2, gy - 17, x + 8, gy - 14), REDW[4]); c:fillMask(rect(x - 2, gy - 17, x + 8, gy - 17), REDW[5])
end

PR.inkwell = function(x, gy)
  gsh(x, gy, 14)
  bx(x - 8, gy - 11, x + 8, gy - 1, TIMB)
  ball(x - 2, gy - 17, 5, INDG); c:fillMask(rect(x - 3, gy - 23, x - 1, gy - 22), INK); P(x - 2, gy - 23, OAK[5])
  local q = c:line({ { x, gy - 22 }, { x + 11, gy - 46 } }, 2); c:rim(q, INK); c:fillMask(q, CREAM[5])
  tri(x + 3, gy - 30, x + 14, gy - 50, x + 13, gy - 36, CREAM[5]); tri(x + 11, gy - 49, x + 16, gy - 54, x + 14, gy - 45, ROSE[5])
  P(x + 1, gy - 23, INDG[3])
end
PR.sapling = function(x, gy)
  gsh(x, gy, 8)
  local pot = HP.mask(); for yy = gy - 7, gy do local ins = (yy - (gy - 7)) // 4; for xx = x - 5 + ins, x + 5 - ins do pot:set(xx, yy) end end
  c:rim(pot, INK); pot:each(function(xx, yy) P(xx, yy, (xx < x - 1) and BARN[5] or BARN[3]) end)
  stem(x, gy - 8, x, gy - 20, LEAF); leafp(x - 5, gy - 18, 4, 2, LEAF); leafp(x + 5, gy - 21, 4, 2, GREEN); leafp(x, gy - 24, 2, 3, LEAF)
end

PR.bigbrush = function(x, gy)
  gsh(x, gy, 14)
  for i, q in ipairs{ { -4, 48 }, { 2, 36 }, { 7, 42 } } do
    local hx = x + q[1]; local m = rect(hx - 1, gy - q[2], hx + 1, gy - 8); c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, (xx == hx - 1) and LEAF[5] or ((xx == hx + 1) and LEAF[3] or LEAF[4])) end)
    local bt = c:ellipse(hx, gy - q[2] - 3, 2, 4); c:rim(bt, INK); c:fillMask(bt, IRON[2]); P(hx - 1, gy - q[2] - 5, IRON[5])
  end
  bx(x - 10, gy - 14, x + 10, gy - 1, SBLUE)
  for xx = x - 8, x + 8, 4 do P(xx, gy - 8, CREAM[5]); P(xx + 1, gy - 7, CREAM[5]) end
  for xx = x - 10, x + 10 do P(xx, gy - 14, CREAM[6]) end
end
PR.toro = function(x, gy)
  gsh(x, gy, 14)
  bx(x - 9, gy - 4, x + 9, gy - 1, STONE); bx(x - 3, gy - 20, x + 3, gy - 5, STONE)
  bx(x - 8, gy - 33, x + 8, gy - 20, STONE)
  S.glow(x, gy - 27, 12, "#ffd070", .35)
  c:fillMask(rect(x - 4, gy - 31, x + 4, gy - 23), INK); c:fillMask(rect(x - 3, gy - 30, x + 3, gy - 24), "#ffe08a"); c:fillMask(rect(x - 3, gy - 30, x - 2, gy - 28), "#fff6cc")
  c:fillMask(rect(x, gy - 30, x, gy - 24), INK)
  tri(x - 13, gy - 33, x + 13, gy - 33, x, gy - 45, STONE[4])
  for xx = x - 12, x + 12 do P(xx, gy - 33, STONE[5]) end
  ball(x, gy - 47, 2, STONE)
end

PR.thistles = function(x, gy)
  gsh(x + 8, gy, 17)
  for _, s in ipairs{ { 0, 48 }, { 8, 62 }, { 17, 40 } } do
    local sx, h = x + s[1], s[2]
    stem(sx, gy - h, sx, gy, GREEN)
    tri(sx - 1, gy - 6, sx - 9, gy - 16, sx - 3, gy - 14, GREEN[4]); tri(sx + 1, gy - 12, sx + 9, gy - 22, sx + 3, gy - 20, GREEN[3])
    ball(sx, gy - h, 4, VIO)
    for k = -3, 3 do P(sx + k, gy - h - 5 - (3 - abs(k)) // 2 * 1, VIO[5]) end
    for k = -4, 4, 2 do P(sx + k, gy - h - 6, VIO[6]) end
    leafp(sx, gy - h + 5, 4, 2, GREEN)
  end
end
PR.jars = function(x, gy)
  gsh(x, gy, 17)
  bx(x - 15, gy - 7, x + 15, gy - 1, TIMB)
  for i, col in ipairs{ "#ffd24a", "#f5a0c0", "#a8f0b8" } do
    local jx = x - 12 + (i - 1) * 10
    local m = rect(jx, gy - 22, jx + 7, gy - 8); c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, (yy < gy - 18) and "#e8f4f8" or ((xx < jx + 2) and "#fff6cc" or col)) end)
    c:fillMask(rect(jx - 1, gy - 25, jx + 8, gy - 23), INK); c:fillMask(rect(jx, gy - 24, jx + 7, gy - 24), IRON[5])
    P(jx + 3, gy - 14, "#fffbe0"); P(jx + 5, gy - 11, "#fffbe0")
    S.glow(jx + 4, gy - 15, 8, col, .22)
  end
end
PR.blueberry = function(x, gy)
  gsh(x, gy, 20)
  local m = c:ellipse(x - 8, gy - 12, 12, 11); m:add(c:ellipse(x + 8, gy - 12, 12, 11)):add(c:ellipse(x, gy - 18, 13, 12)); c:rim(m, INK)
  m:each(function(xx, yy) local l = lit(xx, yy, x, gy - 14, 24); local t = l > .4 and 5 or (l > -.1 and 4 or 3); if hash(xx, yy, 4) > .88 then t = t + 1 end; P(xx, yy, GREEN[min(6, t)]) end)
  for i = 1, 14 do
    local bxx, byy = x - 16 + floor(hash(i, 1, 4) * 32), gy - 28 + floor(hash(i, 2, 4) * 24)
    if m:has(bxx, byy) and m:has(bxx + 1, byy + 1) then c:fillMask(rect(bxx, byy, bxx + 1, byy + 1), BLUEW[3]); P(bxx, byy, BLUEW[5]); P(bxx + 1, byy + 1, BLUEW[1]) end
  end
end
PR.bindle = function(x, gy)
  pole(x, gy - 1, x + 7, gy - 50, 2, TIMB)
  local bl = ball(x + 9, gy - 56, 8, ROSE)
  for _, q in ipairs{ { -3, -3 }, { 3, 0 }, { -1, 4 }, { 4, -5 } } do P(x + 9 + q[1], gy - 56 + q[2], CREAM[6]); P(x + 10 + q[1], gy - 56 + q[2], CREAM[6]) end
  tri(x + 5, gy - 49, x + 13, gy - 49, x + 9, gy - 45, ROSE[3]); P(x + 9, gy - 49, ROSE[6])
end
PR.mossstump = function(x, gy)
  gsh(x, gy, 17)
  local m = rect(x - 12, gy - 14, x + 12, gy - 1); m:add(c:ellipse(x, gy - 1, 12, 3)); c:rim(m, INK)
  m:each(function(xx, yy) local t = (xx < x - 5) and 5 or ((xx > x + 5) and 3 or 4); if (xx + yy // 3) % 6 == 0 then t = t - 1 end; P(xx, yy, OAK[t]) end)
  local top = c:ellipse(x, gy - 15, 13, 5); c:rim(top, INK); top:each(function(xx, yy) P(xx, yy, GREEN[(yy < gy - 15) and 5 or 4]) end)
  for k = -10, 10, 3 do local h = 3 + floor(hash(k, 1, 6) * 5); for yy = gy - 14, gy - 14 + h do P(x + k, yy, GREEN[3]) end end
  stem(x + 1, gy - 20, x + 1, gy - 30, LEAF); leafp(x - 4, gy - 30, 4, 2, LEAF); leafp(x + 6, gy - 32, 4, 2, GREEN)
end
PR.plumes = function(x, gy)
  gsh(x, gy, 12)
  for i, q in ipairs{ { -5, -7, 56 }, { 2, 0, 66 }, { 8, 6, 50 } } do
    local x0, y0, x1, y1 = x + q[1] // 2, gy - 14, x + q[1] + q[2] // 2, gy - q[3]
    local pts = { { x0, y0 }, { (x0 + x1) // 2 + 3, (y0 + y1) // 2 }, { x1, y1 } }
    local m = c:line(pts, 4); c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, ((yy + xx) % 3 == 0) and CREAM[4] or ((xx < (x0 + x1) / 2) and CREAM[6] or CREAM[5])) end)
    local sh = c:line(pts, 1); c:fillMask(sh, IRON[5])
    P(x1, y1 - 3, VIO[5]); P(x1, y1 - 2, VIO[4])
  end
  local jar = rect(x - 8, gy - 15, x + 8, gy - 1); c:rim(jar, INK)
  jar:each(function(xx, yy) P(xx, yy, (xx < x - 3) and INDG[5] or ((xx > x + 3) and INDG[2] or INDG[3])) end)
  c:fillMask(rect(x - 9, gy - 16, x + 9, gy - 14), INK); c:fillMask(rect(x - 8, gy - 15, x + 8, gy - 15), INDG[5])
  P(x - 4, gy - 10, GOLD[5]); P(x + 2, gy - 6, GOLD[5])
end

PR.bunting = function(x, gy, a) bunting(a[1], a[2], a[3], a[4], a[5]) end
