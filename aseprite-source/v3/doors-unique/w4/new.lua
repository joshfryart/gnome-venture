local DX0, DX1, DY0, DY1 = 218, 261, 136, 204
local BLUEW = {"#1f2a52","#2f4a8c","#3f6cb4","#5a8fd0","#82b4e4","#b4d6f4"}
local REDW  = {"#4a1426","#7a2230","#b0343a","#d4503f","#ec7a58","#f8a888"}
local VIO   = {"#2c2048","#443272","#6450a0","#8268c4","#a48ae0","#c8b4f4"}
local MOSSR = {"#1f3a34","#2c5444","#3e6e4e","#5a8c5a","#86b06a","#b4d482"}
local function lit(x, y, cx, cy, k) return -((x - cx) * .55 + (y - cy) * .8) / k end   -- >0 = upper-left lit
local function discPaint(cx, cy, r, ramp, rim)
  local m = c:ellipse(cx, cy, r, r); if rim ~= false then c:rim(m, INK) end
  m:each(function(x, y) local l = lit(x, y, cx, cy, r); P(x, y, ramp[l > .6 and 5 or (l > .1 and 4 or (l > -.5 and 3 or 2))]) end)
  return m
end
-- ===== clementine-moss (snail): goggles, headband, spiral door
local function headband()
  local m = rect(8, 124, 470, 130); c:rim(m, INK)
  m:each(function(x, y) local t = (y == 124) and 5 or ((y >= 129) and 2 or 4); if y == 126 and x % 6 < 3 then t = 3 end; P(x, y, BLUEW[t]) end)
end
local function goggle(cx, cy)
  S.glow(cx, cy, 32, "#ffd070", .45)
  local ring = c:ellipse(cx, cy, 18, 18); c:rim(ring, INK)
  ring:each(function(x, y) local l = lit(x, y, cx, cy, 18); P(x, y, GOLD[l > .5 and 6 or (l > 0 and 5 or (l > -.5 and 4 or 3))]) end)
  local gm = c:ellipse(cx, cy, 13, 13); c:rim(gm, INK)
  gm:each(function(x, y) local l = lit(x, y, cx, cy, 13); P(x, y, l > .2 and "#ffe9a0" or (l > -.4 and "#ffd070" or "#f0a848")) end)
  for k = 0, 6 do P(cx - 9 + k, cy - 6 - floor(k * .5 * (1 - k / 14)), "#fff8dc") end
  P(cx - 8, cy - 3, "#fff8dc"); P(cx + 5, cy + 6, "#fff2b0")
  for _, a in ipairs{ 0, 1.57, 3.14, 4.71 } do local bx, by = floor(cx + cos(a + .78) * 15.5 + .5), floor(cy + sin(a + .78) * 15.5 + .5); P(bx, by, GOLD[2]); P(bx - 1, by - 1, GOLD[6]) end
end
local function spiral(cx, cy, R)
  local pts = {}
  for t = 0, 15.7, .04 do local r = 1.5 + t * (R - 1.5) / 15.7; pts[#pts + 1] = { floor(cx + cos(t) * r + .5), floor(cy + sin(t) * r * .9 + .5) } end
  for _, p in ipairs(pts) do P(p[1] + 1, p[2] + 1, BLUEW[1]) end
  for _, p in ipairs(pts) do P(p[1], p[2], "#f4e6c8"); P(p[1] - 1, p[2], "#e8cfa4") end
  P(cx, cy, "#fff2dc")
end
local function trail()
  for y = 205, 268 do
    local x = 232 + floor(sin(y / 8) * 6) - floor((y - 205) * .3)
    if y > 209 or (x > 203 and x < 277) then P(x, y, "#e6f2ff"); P(x + 1, y, "#9ab4e0"); if y % 5 == 0 then P(x - 1, y, "#f8fcff"); P(x, y - 1, "#f8fcff") end end
  end
end
local function can(x, y)
  c:fillMask(c:ellipse(x + 8, y + 1, 12, 2), "#58803c")
  local sp = c:line({ { x + 12, y - 8 }, { x + 21, y - 17 } }, 2); c:rim(sp, INK); c:fillMask(sp, "#3f8c8c")
  local rose = rect(x + 20, y - 21, x + 24, y - 16); c:rim(rose, INK); c:fillMask(rose, "#7fd0c4")
  local h = c:line({ { x + 3, y - 12 }, { x - 3, y - 10 }, { x - 3, y - 3 }, { x + 1, y - 2 } }, 2); c:rim(h, INK); c:fillMask(h, "#2f7a80")
  local b = rect(x, y - 12, x + 13, y); c:rim(b, INK)
  b:each(function(xx, yy) local t = (xx - x < 3) and "#7fd0c4" or ((xx - x > 9) and "#2f7a80" or "#4fa6a0"); if yy == y - 12 then t = "#a8e8dc" elseif yy >= y - 1 then t = "#2f7a80" end; P(xx, yy, t) end)
  P(x + 1, y - 9, "#fff8dc"); P(x + 5, y - 6, "#2f7a80"); P(x + 6, y - 6, "#2f7a80")   -- a stencilled dot
  P(x + 23, y - 12, "#82b4e4"); P(x + 24, y - 9, "#82b4e4")
end
local function cabbages()
  for _, q in ipairs{ { 60, 228, 8 }, { 88, 236, 7 }, { 114, 226, 8 } } do
    local cx, cy, r = q[1], q[2], q[3]
    local m = c:ellipse(cx, cy, r, r - 1); c:rim(m, INK)
    m:each(function(x, y) local l = lit(x, y, cx, cy, r); local d = sqrt((x - cx) ^ 2 + (y - cy) ^ 2); local t = l > .5 and 5 or (l > 0 and 4 or (l > -.5 and 3 or 2)); if d > r - 2.2 then t = min(6, t + 1) end; P(x, y, GREEN[t]) end)
    for a = 3.4, 5.4, .1 do P(floor(cx + cos(a) * (r - 3) + .5), floor(cy + sin(a) * (r - 4) + .5), GREEN[6]) end
    for a = .2, 2, .1 do P(floor(cx + cos(a) * (r - 4) + .5), floor(cy + sin(a) * (r - 4) + .5), GREEN[2]) end
  end
end
-- ===== bracken-spurwing (beetle): elytra door, antenna wires, pea trellis, acorn mailbox
local function elytra()
  for y = 138, 200 do if ((y - 169) / 32) ^ 2 < 1 then for _, x in ipairs{ 239, 240 } do if ((x + .5 - 240) / 31) ^ 2 + ((y + .5 - 169) / 33) ^ 2 < .9 then P(x, y, INK) end end end end
  for _, s in ipairs{ { 224, 158, 4 }, { 256, 158, 4 }, { 222, 182, 3 }, { 258, 182, 3 }, { 229, 146, 2 }, { 251, 146, 2 }, { 232, 196, 2 }, { 248, 196, 2 } } do
    local m = c:ellipse(s[1], s[2], s[3], s[3]); c:fillMask(m, INK); P(s[1] - 1, s[2] - 1, "#5a2a44")
  end
  for a = 3.5, 4.5, .06 do local x, y = floor(240 - 28 + cos(a + .6) * 7 + 0), floor(170 + sin(a + 1.0) * 24); P(235 - 20 + floor((a - 3.5) * 8), 150 + floor((a - 3.5) * 14), "#f8a888") end
end
local function antennae()
  for _, sd in ipairs{ -1, 1 } do
    local prev
    for t = 0, 1, .02 do
      local x = floor(240 + sd * (7 + 20 * t + 6 * math.sin(t * 5)) + .5)
      local y = floor(130 - 20 * t * (1 - .3 * t) + .5)
      if t > .9 then y = y + 1 end
      P(x + 1, y + 1, INK); P(x, y, IRON[5])
      prev = { x, y }
    end
    local bm = c:ellipse(prev[1], prev[2], 3, 3); c:rim(bm, INK); c:fillMask(bm, GOLD[4]); P(prev[1] - 1, prev[2] - 1, GOLD[6]); P(prev[1] + 1, prev[2] + 1, GOLD[2])
  end
end
local function trellis(x)
  local pm = rect(x, 100, x + 2, 206); c:rim(pm, INK); S.obj(pm, TIMB, { base = 4, lit = 0, shade = 1 })
  local bar = rect(x - 9, 108, x + 11, 110); c:rim(bar, INK); S.obj(bar, TIMB, { base = 4, lit = 1, shade = 1 })
  for y = 203, 104, -1 do local vx = floor(x + 1 + 5 * math.sin(y / 7)); P(vx - 1, y, INK); P(vx + 1, y, INK); P(vx, y, GREEN[(y % 4 < 2) and 5 or 4]) end
  for y = 196, 112, -14 do
    local vx = floor(x + 1 + 5 * math.sin(y / 7)); local sd = (y % 28 == 0) and 1 or -1
    local lm = c:ellipse(vx + sd * 5, y - 2, 4, 2); c:rim(lm, INK); c:fillMask(lm, LEAF[4]); P(vx + sd * 5 - 1, y - 3, LEAF[6]); P(vx + sd * 6, y - 1, LEAF[2])
  end
  for _, q in ipairs{ { x + 8, 150 }, { x - 12, 172 }, { x + 7, 190 } } do
    local pm2 = rect(q[1], q[2], q[1] + 7, q[2] + 3); pm2:cut(rect(q[1], q[2], q[1], q[2])); c:rim(pm2, INK); c:fillMask(pm2, "#a8e060")
    for k = 1, 5, 2 do P(q[1] + k, q[2] + 1, "#d4f48a"); P(q[1] + k, q[2] + 2, "#6aa838") end
  end
  for _, q in ipairs{ { x - 3, 140 }, { x + 9, 124 } } do P(q[1], q[2], "#fff2dc"); P(q[1] - 1, q[2], "#f8d8e8"); P(q[1] + 1, q[2], "#f8d8e8"); P(q[1], q[2] - 1, "#f8d8e8"); P(q[1], q[2] + 1, "#f8d8e8"); P(q[1], q[2], "#ffd24a") end
end
local function acorn(x, y)
  c:fillMask(c:ellipse(x, y, 7, 2), "#58803c")
  local n = c:ellipse(x, y - 6, 5, 6); c:rim(n, INK)
  n:each(function(xx, yy) local l = lit(xx, yy, x, y - 6, 6); P(xx, yy, l > .4 and "#f0b860" or (l > -.3 and "#d09448" or "#a06a32")) end)
  local cap = rect(x - 6, y - 13, x + 6, y - 9); cap:add(rect(x - 4, y - 15, x + 4, y - 14)); c:rim(cap, INK)
  cap:each(function(xx, yy) local t = ((xx + yy) % 3 == 0) and "#5a3c1c" or "#7a5a30"; if yy <= y - 14 or xx < x - 3 and yy < y - 11 then t = ((xx + yy) % 3 == 0) and "#7a5a30" or "#9a7440" end; P(xx, yy, t) end)
  P(x, y - 17, INK); P(x, y - 16, "#5a3c1c"); P(x - 3, y - 13, "#c8a060")
  local slot = rect(x - 3, y - 6, x + 3, y - 5); c:fillMask(slot, INK)
  local env = rect(x - 2, y - 9, x + 4, y - 6); c:rim(env, INK); c:fillMask(env, "#f8ecd0"); P(x + 1, y - 7, "#e8493b")   -- letter poking out
end
-- ===== old-twigg (stick-insect mystic): moon door, herbs, chimes, orb staff
local function moonstars()
  S.glow(240, 158, 20, "#ffd070", .3)
  local m = c:ellipse(240, 158, 10, 10); m:cut(c:ellipse(245, 155, 9, 9)); c:rim(m, INK)
  m:each(function(x, y) P(x, y, (x + y < 394) and "#fff6cc" or "#ffe08a") end)
  for _, s in ipairs{ { 226, 146 }, { 252, 148 }, { 227, 178 }, { 251, 184 }, { 234, 190 } } do
    P(s[1], s[2], "#fff6cc"); for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do P(s[1] + d[1], s[2] + d[2], "#ffd24a") end
  end
end
local function herbs(x)
  local violet = (x == 172)
  for y = 96, 104 do P(x, y, "#7a5a30") end
  P(x - 1, 95, INK); P(x, 94, INK); P(x + 1, 95, INK)
  c:fillMask(rect(x - 2, 105, x + 2, 106), INK); c:fillMask(rect(x - 1, 105, x + 1, 105), "#c8a060")
  for k = -3, 3, 2 do for y = 107, 112 do P(x + k * (y - 106) // 6, y, "#6a8a4a") end end
  for k = -3, 3, 2 do
    local fx = x + k * 2 // 1; local m = c:ellipse(fx, 117, 2, 5); c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, violet and ((xx < fx) and VIO[5] or VIO[3]) or ((xx < fx) and "#f8c050" or "#e08830")) end)
    P(fx - 1, 114, violet and VIO[6] or "#ffe08a")
  end
end
local function chimes(x)
  for y = 76, 84 do P(x, y, "#7a5a30") end
  local bar = rect(x - 9, 85, x + 9, 87); c:rim(bar, INK); S.obj(bar, TIMB, { base = 4, lit = 1, shade = 1 })
  for i, dx in ipairs{ -7, -2, 3, 8 } do
    local len = ({ 10, 15, 12, 8 })[i]
    for y = 88, 90 do P(x + dx, y, INK) end
    local tm = rect(x + dx - 1, 91, x + dx + 1, 91 + len); c:rim(tm, INK)
    tm:each(function(xx, yy) P(xx, yy, (xx == x + dx - 1) and "#a8f0e8" or ((xx == x + dx + 1) and "#2f8c94" or "#58c4c0")) end)
    P(x + dx, 92 + len, "#2f8c94")
  end
end
local function staff(x)
  S.glow(x + 8, 114, 17, "#9be8f0", .4)
  local sm = c:line({ { x, 206 }, { x + 4, 176 }, { x + 2, 150 }, { x + 9, 124 } }, 3); c:rim(sm, INK)
  sm:each(function(xx, yy) P(xx, yy, ((xx + yy // 3) % 5 == 0) and TIMB[3] or ((xx < x + 4 + (206 - yy) // 40) and TIMB[5] or TIMB[4])) end)
  local ring = c:ellipse(x + 9, 116, 6, 6); ring:cut(c:ellipse(x + 9, 116, 3, 3)); c:rim(ring, INK); c:fillMask(ring, TIMB[4])
  local orb = c:ellipse(x + 9, 116, 3, 3); c:fillMask(orb, "#9be8f0"); P(x + 8, 115, "#e8ffff"); P(x + 10, 118, "#58c4d0")
  for _, y in ipairs{ 160, 190 } do c:fillMask(rect(x + 1, y, x + 5, y + 1), "#c8a060") end   -- wrapped cord
end
