---------------------------------------------------------------- W1: door overlays (painted on the door leaf before the knob)
OVL.stripes = function(m)   -- abuela: poncho weave
  local pal = { REDW[4], GOLD[5], TEAL[4], CREAM[5], REDW[4], BLUEW[4] }
  m:each(function(x, y)
    if not inn(m, x, y) then return end
    local k = ((y - 136) // 7) % 6; local col = pal[k + 1]
    if (y - 136) % 7 == 0 then col = mixc(col, "#fff0c0", .3) end
    P(x, y, col)
  end)
  for yy = 150, 196, 14 do for xx = 223, 259, 8 do if m:has(xx, yy) then
    for _, d in ipairs{ { 0, 0 }, { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do P(xx + d[1], yy + d[2], CREAM[6]) end; P(xx, yy, REDW[3]) end end end
end
OVL.spell = function(m)   -- bram: pentagram ring
  local cx, cy = 240, 170
  for a = 0, 6.283, .02 do P(floor(cx + cos(a) * 15 + .5), floor(cy + sin(a) * 15 + .5), GOLD[5]) end
  for a = 0, 6.283, .03 do P(floor(cx + cos(a) * 18 + .5), floor(cy + sin(a) * 18 + .5), (floor(a * 10) % 2 == 0) and VIO[6] or VIO[2]) end
  local pts = {}; for k = 0, 4 do local a = -1.5708 + k * 1.2566; pts[k + 1] = { floor(cx + cos(a) * 15 + .5), floor(cy + sin(a) * 15 + .5) } end
  for _, pr in ipairs{ { 1, 3 }, { 3, 5 }, { 5, 2 }, { 2, 4 }, { 4, 1 } } do c:fillMask(c:line({ pts[pr[1]], pts[pr[2]] }, 1), CREAM[6]) end
  for _, q in ipairs{ { 226, 146 }, { 254, 148 }, { 224, 196 }, { 256, 194 } } do P(q[1], q[2], GOLD[6]); P(q[1] - 1, q[2], GOLD[5]); P(q[1] + 1, q[2], GOLD[5]); P(q[1], q[2] - 1, GOLD[5]); P(q[1], q[2] + 1, GOLD[5]) end
end
OVL.studs = function(m)   -- burdock: peephole and brass studs
  for yy = 164, 198, 9 do for xx = 224, 258, 9 do if m:has(xx, yy) and not (xx > 232 and xx < 248 and yy < 168) then
    c:fillMask(rect(xx, yy, xx + 1, yy + 1), INK); P(xx, yy, GOLD[6]); P(xx + 1, yy + 1, GOLD[3]) end end end
  ball(240, 152, 7, IRON); c:fillMask(c:ellipse(240, 152, 4, 4), INK); c:fillMask(c:ellipse(240, 152, 3, 3), "#3a2a4c"); P(238, 150, "#a8c8f0"); P(239, 150, "#a8c8f0")
  for a = 0, 6.283, .8 do P(floor(240 + cos(a) * 6.5 + .5), floor(152 + sin(a) * 6.5 + .5), GOLD[5]) end
end
OVL.clover = function(m)
  clover(240, 164, 7, LEAF)
  stem(240, 172, 238, 198, GREEN); stem(238, 188, 232, 184, GREEN)
  for _, q in ipairs{ { 226, 150 }, { 254, 152 }, { 228, 192 }, { 252, 190 } } do clover(q[1], q[2], 2, GREEN) end
end
OVL.dutch = function(m)
  for x = 218, 261 do if m:has(x, 171) then P(x, 169, INK); P(x, 170, GOLD[5]); P(x, 171, GOLD[3]); P(x, 172, INK) end end
  local cx, cy = 240, 153
  local g = c:ellipse(cx, cy, 10, 10); c:rim(g, GOLD[2])
  g:each(function(x, y) P(x, y, (y < cy - 2) and SBLUE[6] or ((y < cy + 3) and SBLUE[5] or SBLUE[4])) end)
  for k = 0, 6 do P(cx - 7 + k, cy - 3 - k // 2, "#e8f4f8") end
  for a = 0, 6.283, .1 do P(floor(cx + cos(a) * 11 + .5), floor(cy + sin(a) * 11 + .5), GOLD[5]) end
  for x = cx - 9, cx + 9 do P(x, cy, GOLD[3]) end; for y = cy - 9, cy + 9 do P(cx, y, GOLD[3]) end
  for yy = 176, 198, 8 do for x = 222, 258, 12 do if m:has(x, yy) then P(x, yy, ORNG[5]); P(x + 1, yy, ORNG[3]) end end end
end
OVL.sun = function(m)
  for a = 0, 6.283, .3927 do
    local x0, y0, x1, y1 = floor(240 + cos(a) * 15 + .5), floor(166 + sin(a) * 15 + .5), floor(240 + cos(a) * 22 + .5), floor(166 + sin(a) * 22 + .5)
    local l = c:line({ { x0, y0 }, { x1, y1 } }, 1); c:fillMask(l:clip(m), GOLD[6])
  end
  sflower(240, 166, 11, GOLD, OAK)
end
OVL.bamboo = function(m)
  m:each(function(x, y)
    if not inn(m, x, y) then return end
    local k = (x - 218) % 6
    local t = (k == 0) and 6 or ((k == 5) and 2 or ((k == 4) and 3 or 5))
    if (y - 136 + ((x - 218) // 6 % 2) * 7) % 14 == 0 then t = 2 end
    P(x, y, LEAF[t])
  end)
  for _, yy in ipairs{ 160, 186 } do for x = 214, 266 do if m:has(x, yy) then P(x, yy, DIRT[5]); P(x, yy + 1, DIRT[3]) end end end
end
OVL.splat = function(m)   -- indigo: paint on a scarf-mustard stripe
  for _, s in ipairs{ { 218, 168, 262, 172, GOLD[4] }, { 226, 144, 232, 200, "#e8798c" }, { 246, 150, 256, 196, "#7fd0c4" }, { 236, 176, 252, 181, REDW[4] } } do
    local sm = rect(s[1], s[2], s[3], s[4]); c:fillMask(sm:clip(m), s[5])
  end
  for i = 1, 16 do local x, y = 220 + floor(hash(i, 1, 8) * 40), 140 + floor(hash(i, 2, 8) * 60)
    if m:has(x, y) then local cc = ({ "#ffd24a", "#f5a0c0", "#a8f0b8", "#fff6cc" })[i % 4 + 1]; c:fillMask(rect(x, y, x + 1, y + 1), cc) end end
end
OVL.teapot = function(m)
  local cx, cy = 240, 174
  local sp = c:line({ { cx + 8, cy - 3 }, { cx + 17, cy - 12 } }, 2); c:rim(sp, INK); c:fillMask(sp:clip(m), CREAM[5])
  local hd = c:ellipse(cx - 11, cy - 2, 5, 7); hd:cut(c:ellipse(cx - 11, cy - 2, 2, 4)); c:rim(hd, INK); c:fillMask(hd, CREAM[4])
  ball(cx, cy, 11, CREAM)
  bx(cx - 5, cy - 15, cx + 5, cy - 11, CREAM); ball(cx, cy - 18, 2, CREAM)
  for yy = cy - 3, cy + 3, 3 do for xx = cx - 6, cx + 6, 3 do P(xx, yy, ORNG[4]) end end
  for k = 0, 9 do local sx = 252 + floor(sin(k / 2) * 2); if m:has(sx, 150 - k) then P(sx, 152 - k, CREAM[5]) end end
end
OVL.patch = function(m)
  local cols = { LEAF[4], OAK[4], MOSSR[3], GOLD[4], CREAM[5], GREEN[3], ROSE[4], TEAL[4] }
  m:each(function(x, y)
    if not inn(m, x, y) then return end
    local gx, gy = (x - 218) // 11, (y - 136) // 11
    local col = cols[floor(hash(gx, gy, 5) * #cols) + 1]
    local ex, ey = (x - 218) % 11, (y - 136) % 11
    if ex == 0 or ey == 0 then col = ((x + y) % 2 == 0) and CREAM[6] or OAK[2]
    elseif ex == 1 or ey == 1 then col = mixc(col, "#fff0c0", .25) end
    P(x, y, col)
  end)
end
OVL.bloom = function(m) bloom(240, 168, 15, ORNG, OAK) end
OVL.shell = function(m)
  m:each(function(x, y)
    if not inn(m, x, y) then return end
    local row = (y - 134) // 10; local ox = (row % 2) * 6
    local ex, ey = (x - 214 + ox) % 12, (y - 134) % 10
    local col = LEAF[4]
    if ex == 0 or ey == 0 then col = TIMB[2] elseif ex == 1 or ey == 1 then col = LEAF[6] elseif ex >= 10 or ey >= 8 then col = LEAF[3] end
    if hash(x // 3, y // 3, 6) > .8 then col = mixc(col, "#2c5a30", .2) end
    P(x, y, col)
  end)
end
OVL.dots = function(m)
  m:each(function(x, y)
    if not inn(m, x, y) then return end
    local row = (y - 136) // 7; local xx = (x - 218 + (row % 2) * 4) % 8; local yy = (y - 136) % 7
    if xx >= 2 and xx <= 4 and yy >= 2 and yy <= 4 and not (xx == 2 and yy == 2) then P(x, y, (yy == 4 or xx == 4) and CREAM[4] or CREAM[6]) end
  end)
  tri(240, 142, 230, 137, 230, 147, CREAM[5]); tri(240, 142, 250, 137, 250, 147, CREAM[4]); ball(240, 142, 2, CREAM)
end
OVL.batik = function(m)
  m:each(function(x, y)
    if not inn(m, x, y) then return end
    local d1, d2 = (x + y) % 14, (x - y) % 14
    if d1 == 0 or d2 == 0 then P(x, y, GOLD[5]) end
  end)
  for _, q in ipairs{ { 231, 150 }, { 249, 150 }, { 240, 170 }, { 231, 190 }, { 249, 190 } } do
    for a = 0, 6.283, .25 do local x, y = floor(q[1] + cos(a) * 5 + .5), floor(q[2] + sin(a) * 5 + .5); if m:has(x, y) then P(x, y, ORNG[4]) end end
    if m:has(q[1], q[2]) then c:fillMask(rect(q[1] - 1, q[2] - 1, q[1] + 1, q[2] + 1), CREAM[5]); P(q[1], q[2], ORNG[3]) end
  end
end
OVL.cheese = function(m)
  for _, h in ipairs{ { 232, 158, 4 }, { 250, 150, 3 }, { 249, 172, 5 }, { 233, 184, 4 }, { 248, 196, 3 }, { 240, 143, 2 } } do
    local hm = c:ellipse(h[1], h[2], h[3], h[3]):clip(m)
    c:fillMask(hm, CHZ[2]); c:fillMask(hm:clip(rect(h[1] - 9, h[2] - 9, h[1] + 9, h[2] - h[3] + 1)), CHZ[1])
    P(h[1] - h[3] + 1, h[2] + h[3] - 1, CHZ[6])
  end
end
OVL.quill = function(m)
  local f = c:line({ { 252, 197 }, { 232, 148 } }, 7); c:rim(f, INK)
  f:each(function(x, y) P(x, y, ((x + y) % 4 == 0) and CREAM[4] or ((x < 242) and CREAM[6] or CREAM[5])) end)
  c:fillMask(c:line({ { 252, 200 }, { 230, 146 } }, 1), INDG[3])
  tri(228, 148, 233, 140, 236, 150, ROSE[5])
  for i = 1, 7 do local x, y = 222 + floor(hash(i, 1, 4) * 36), 176 + floor(hash(i, 2, 4) * 24); if m:has(x, y) and (x < 238 or y > 192) then P(x, y, INDG[3]); P(x + 1, y, INDG[3]) end end
  for k = 0, 16 do if m:has(224 + k * 2, 200 + floor(sin(k) * 2)) then P(224 + k * 2, 200 + floor(sin(k) * 2), GOLD[5]) end end
end
OVL.enso = function(m)
  local cx, cy = 240, 168
  for a = .6, 6.2, .012 do
    local w = 3 - (a - .6) * .35
    for r = 12, 12 + max(1, floor(w + .5)) do local x, y = floor(cx + cos(a) * r + .5), floor(cy + sin(a) * r + .5); if m:has(x, y) then P(x, y, (r == 12 and a > 3) and IRON[3] or INK) end end
    if a > 5 and floor(a * 100) % 3 == 0 then P(floor(cx + cos(a) * 14 + .5), floor(cy + sin(a) * 14 + .5), CREAM[5]) end
  end
  for _, q in ipairs{ { 258, 154 }, { 255, 150 }, { 224, 190 } } do if m:has(q[1], q[2]) then P(q[1], q[2], INK); P(q[1] + 1, q[2], INK) end end
  local hk = rect(250, 190, 256, 197); c:fillMask(hk:clip(m), REDW[4]); c:fillMask(rect(251, 192, 255, 192):clip(m), CREAM[5]); c:fillMask(rect(253, 191, 253, 195):clip(m), CREAM[5])
end
OVL.wings = function(m)
  for _, sd in ipairs{ -1, 1 } do
    for _, w in ipairs{ { 11, 152, 11, 5 }, { 9, 168, 8, 4 } } do
      local wm = c:ellipse(240 + sd * w[1], w[2], w[3], w[4]):clip(m)
      wm:each(function(x, y) P(x, y, (y < w[2]) and SBLUE[6] or SBLUE[5]) end)
      for k = -2, 2 do local l = c:line({ { 240 + sd * 2, w[2] + k }, { 240 + sd * (w[1] + w[3]), w[2] + k * 2 } }, 1); c:fillMask(l:clip(wm), SBLUE[3]) end
    end
  end
  ball(240, 166, 3, VIO); c:fillMask(rect(239, 156, 241, 176), VIO[3]); P(240, 156, VIO[6])
  for _, q in ipairs{ { 224, 192 }, { 256, 190 }, { 230, 142 } } do P(q[1], q[2], PINK[6]); P(q[1] + 1, q[2], PINK[5]); P(q[1], q[2] + 1, PINK[5]) end
end
OVL.berries = function(m)
  for _, y0 in ipairs{ 150, 178 } do
    for x = 218, 261 do local y = floor(y0 + sin(x / 5 + y0) * 4); if m:has(x, y) then P(x, y, LEAF[5]); P(x, y + 1, LEAF[3]) end end
  end
  for _, q in ipairs{ { 226, 152 }, { 244, 148 }, { 255, 180 }, { 232, 178 }, { 242, 196 } } do
    for _, d in ipairs{ { 0, 0 }, { 3, 2 }, { -2, 3 }, { 2, -2 } } do
      local bxx, byy = q[1] + d[1], q[2] + d[2]
      if m:has(bxx, byy) and m:has(bxx + 2, byy + 2) then c:fillMask(rect(bxx, byy, bxx + 2, byy + 2), BLUEW[3]); P(bxx, byy, BLUEW[6]); P(bxx + 2, byy + 2, BLUEW[1]) end
    end
    if m:has(q[1] + 4, q[2] - 3) then leafp(q[1] + 5, q[2] - 3, 3, 1, LEAF) end
  end
end
OVL.night = function(m)
  S.glow(240, 168, 20, "#9a88d8", .18)
  local pts = { { 240, 142 }, { 242, 168 }, { 240, 198 } }
  for i = 1, 9 do
    local y = 146 + i * 5; local l = 11 - abs(i - 5) * 1.6
    local lk = c:line({ { 241, y }, { floor(241 + l), y - 4 } }, 1); c:fillMask(lk:clip(m), NITE[6])
    local rk = c:line({ { 240, y }, { floor(240 - l), y - 4 } }, 1); c:fillMask(rk:clip(m), NITE[5])
  end
  for yy = 142, 200 do P(240, yy, CREAM[6]) end
  for _, q in ipairs{ { 226, 150 }, { 254, 160 }, { 228, 184 }, { 255, 192 } } do P(q[1], q[2], "#ffd24a"); P(q[1] - 1, q[2], "#9a88d8"); P(q[1] + 1, q[2], "#9a88d8"); P(q[1], q[2] - 1, "#9a88d8"); P(q[1], q[2] + 1, "#9a88d8") end
end
