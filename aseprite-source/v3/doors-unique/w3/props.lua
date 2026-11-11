-- ===================== w3: ramps, prop library, overlays
local PR, OV, H, LB = {}, {}, {}, {}
local pi = math.pi
local R = { TIMB=TIMB, OAK=OAK, CREAM=CREAM, ROSE=ROSE, GREEN=GREEN, LEAF=LEAF, SBLUE=SBLUE, BARN=BARN, GOLD=GOLD, STONE=STONE, TEAL=TEAL, VIOLET=VIOLET, PINK=PINK, DIRT=DIRT, IRON=IRON, BLUEW=BLUEW, REDW=REDW, VIO=VIO, MOSSR=MOSSR, THATCH=THATCH,
  YEL   = {"#6a4a14","#a07a22","#d4a63a","#f0c85a","#f8e08a","#fff2bc"},
  ORG   = {"#4a1e12","#7e3418","#b8501e","#e07a30","#f4a04e","#fccc8a"},
  PLUM  = {"#241230","#3e2250","#603a74","#865a98","#ac82bc","#d4b0e0"},
  MINT  = {"#1e3c3a","#2e5e54","#468070","#68a48a","#98c8a8","#c8e8c4"},
  NAVY  = {"#141c38","#1f2f5a","#2e4a84","#4468a8","#6a8cc8","#9ab6e4"},
  CORAL = {"#4a1a2a","#7c2c3c","#b8465a","#e0707a","#f4a0a0","#fcd0cc"},
  PASTEL= {"#7a3a58","#a85a7c","#d482a4","#f0a8c4","#f8c8dc","#fde4ee"},
  PEACH = {"#6a3a2a","#a45c3c","#d88a5a","#f0b080","#f8d0a0","#fce8c8"},
  LAV   = {"#3e3468","#5c4e92","#8478b8","#a89cd4","#c8bee8","#e4def6"},
  NIGHT = {"#140e20","#221838","#342856","#4c3c78","#6a5a9a","#9484bc"},
  SAGE  = {"#2c4234","#44624a","#648464","#88a880","#b0c8a0","#d4e4c0"},
}
local function bx(x0, y0, x1, y1, r, band)
  local m = rect(x0, y0, x1, y1); c:rim(m, INK)
  m:each(function(x, y)
    local t = 4
    if y == y0 or x == x0 then t = 5 elseif y == y1 or x == x1 then t = 3 end
    if band and (x - x0) % band == 0 and x > x0 then t = 3 end
    P(x, y, r[t])
  end)
  return m
end
local function ball(cx, cy, rx, ry, r)
  local m = c:ellipse(cx, cy, rx, ry); c:rim(m, INK)
  m:each(function(x, y) local l = lit(x, y, cx, cy, max(rx, ry)); P(x, y, r[l > .6 and 5 or (l > .1 and 4 or (l > -.5 and 3 or 2))]) end)
  return m
end
local function ln(pts, w, r, t)   -- inked line with a flat ramp colour
  local m = c:line(pts, w); c:rim(m, INK); c:fillMask(m, r[t or 4]); return m
end
local function pxs(list, col) for _, q in ipairs(list) do P(q[1], q[2], col) end end

---------------------------------------------------------------- ground props (y = baseline)
function PR.bench(x, y, cush)
  bx(x + 2, y - 8, x + 4, y, TIMB); bx(x + 25, y - 8, x + 27, y, TIMB)
  bx(x + 3, y - 20, x + 26, y - 17, TIMB); bx(x + 4, y - 17, x + 5, y - 11, TIMB); bx(x + 24, y - 17, x + 25, y - 11, TIMB)
  bx(x, y - 11, x + 29, y - 8, OAK)
  bx(x + 7, y - 14, x + 22, y - 11, cush or R.CORAL)
end
function PR.barrel(x, y, fill)
  local m = rect(x - 8, y - 17, x + 8, y); m:cut(rect(x - 8, y - 17, x - 8, y - 17)); m:cut(rect(x + 8, y - 17, x + 8, y - 17)); c:rim(m, INK)
  m:each(function(xx, yy)
    local t = (xx < x - 4) and 5 or ((xx > x + 3) and 3 or 4)
    if xx > x + 6 then t = 2 end
    if (xx - x + 8) % 5 == 0 then t = t - 1 end
    if yy == y - 17 then t = 6 end
    P(xx, yy, OAK[max(1, t)])
  end)
  for _, yy in ipairs{ y - 13, y - 4 } do for xx = x - 8, x + 8 do P(xx, yy, IRON[3]); P(xx, yy + 1, IRON[5]) end end
  if fill == "apples" then
    for _, q in ipairs{ { -4, -19 }, { 2, -20 }, { 5, -17 }, { -1, -17 } } do ball(x + q[1], y + q[2], 3, 3, R.REDW) end
  elseif fill == "green" then
    for i = -7, 7 do local h = 3 + floor(hash(i, 1, 8) * 5); for k = 0, h do P(x + i, y - 18 - k, GREEN[(k > h - 2) and 5 or 3]) end end
  end
end
function PR.crates(x, y)
  for _, q in ipairs{ { x, y, 12 }, { x + 14, y, 10 }, { x + 2, y - 11, 11 } } do
    local s = q[3]; bx(q[1], q[2] - s, q[1] + s, q[2], TIMB)
    for k = 1, s - 2 do P(q[1] + k, q[2] - s + k, TIMB[2]); P(q[1] + s - k, q[2] - s + k, TIMB[2]) end
  end
end
function PR.pot(x, y, col)
  local m = rect(x - 5, y - 8, x + 5, y); m:cut(rect(x - 5, y, x - 4, y)); c:rim(m, INK)
  m:each(function(xx, yy) P(xx, yy, R.ORG[(xx < x - 2) and 5 or ((xx > x + 2) and 3 or 4)]) end)
  for xx = x - 6, x + 6 do P(xx, y - 9, INK) end
  c:fillMask(rect(x - 6, y - 10, x + 6, y - 8), R.ORG[5]); for xx = x - 7, x + 7 do P(xx, y - 11, INK) end
  for yy = y - 20, y - 11 do P(x, yy, GREEN[4]) end
  for k = 0, 3 do P(x - 2 - k, y - 14 - k // 2, GREEN[5]); P(x + 2 + k, y - 16 - k // 2, GREEN[5]) end
  ball(x, y - 21, 4, 4, { "#5a2a44", "#8a3a5c", col, col, "#fff2dc", "#fff8f0" }); P(x, y - 21, "#ffd24a")
end
function PR.sunflower(x, y, h)
  for yy = y - h, y do P(x, yy, INK); P(x + 1, yy, GREEN[3]) end
  for k = 0, 5 do P(x - 2 - k, y - h // 2 - k // 2, GREEN[5]); P(x - 2 - k, y - h // 2 - k // 2 + 1, GREEN[3]) end
  for i = 0, 11 do local a = i * pi / 6; P(floor(x + 1 + cos(a) * 8 + .5), floor(y - h + sin(a) * 8 + .5), INK) end
  ball(x + 1, y - h, 7, 7, GOLD)
  ball(x + 1, y - h, 3, 3, { "#2a1810", "#3c2418", "#4a2e1c", "#5a3a22", "#7a5030", "#8a6038" })
  P(x - 3, y - h - 5, "#fff2a0")
end
function PR.pumpkin(x, y, r)
  local m = ball(x, y - r + 1, r, r - 1, R.ORG)
  for _, dx in ipairs{ -r // 2, 0, r // 2 } do for yy = y - 2 * r + 3, y - 1 do if m:has(x + dx, yy) then P(x + dx, yy, R.ORG[2]) end end end
  c:fillMask(rect(x - 1, y - 2 * r, x + 1, y - 2 * r + 2), INK); P(x, y - 2 * r + 1, GREEN[3])
end
function PR.wheelbarrow(x, y, load)
  for _, q in ipairs{ { 4, 6 }, { 14, 3 } } do end
  ln({ { x + 22, y - 12 }, { x + 36, y - 20 } }, 2, TIMB, 4)
  ln({ { x + 16, y - 6 }, { x + 18, y } }, 2, TIMB, 3)
  local tm = rect(x, y - 12, x + 22, y - 6); for k = 0, 2 do tm:cut(rect(x + k * 0, y - 6 + 0, x, y - 6)) end
  c:rim(tm, INK)
  tm:each(function(xx, yy) local t = (yy == y - 12) and 5 or ((yy >= y - 7) and 2 or 3); if xx < x + 3 then t = t + 1 end; P(xx, yy, R.TEAL[min(6, t + 1)]) end)
  ball(x + 4, y - 4, 5, 5, IRON); P(x + 4, y - 4, GOLD[5])
  if load == "pumpkins" then PR.pumpkin(x + 6, y - 11, 4); PR.pumpkin(x + 15, y - 11, 4) end
  if load == "soil" then for xx = x + 1, x + 21 do local h = 2 + floor(hash(xx, 1, 3) * 3); for k = 0, h do P(xx, y - 13 - k, DIRT[2 + k % 3]) end end end
end
function PR.shovel(x, y)
  ln({ { x, y - 2 }, { x + 10, y - 44 } }, 2, TIMB, 4)
  c:fillMask(rect(x + 8, y - 49, x + 14, y - 46), INK); P(x + 10, y - 47, TIMB[5]); P(x + 12, y - 47, TIMB[5])
  local bl = c:ellipse(x - 1, y - 6, 4, 6); bl:cut(rect(x - 6, y - 14, x + 4, y - 11)); c:rim(bl, INK)
  bl:each(function(xx, yy) P(xx, yy, IRON[(xx < x - 1) and 5 or 3]) end)
  P(x - 2, y - 9, IRON[6])
end
function PR.vegrows(x0, x1, y, kind)
  local pm = rect(x0, y, x1, y + 14); c:rim(pm, INK)
  pm:each(function(xx, yy) local t = ((yy - y) % 5 < 2) and 3 or 2; if (yy - y) % 5 == 0 then t = 4 end; P(xx, yy, DIRT[t]) end)
  for yy = y + 3, y + 12, 5 do
    for xx = x0 + 4, x1 - 4, 8 do
      if kind == "carrot" then
        P(xx, yy, "#e8843c"); P(xx + 1, yy, "#f4a04e"); P(xx, yy + 1, "#c0602c")
        for k = 1, 5 do P(xx + (k % 3) - 1 + (k > 3 and 1 or 0), yy - k, GREEN[3 + k % 3]) end
      else
        ball(xx + 1, yy - 1, 4, 3, GREEN); P(xx - 1, yy - 2, GREEN[6]); P(xx + 1, yy - 1, GREEN[2])
      end
    end
  end
end
function PR.logs(x, y)
  for _, q in ipairs{ { 6, 6 }, { 17, 6 }, { 28, 6 }, { 11, 16 }, { 22, 16 } } do
    local cx, cy = x + q[1], y - q[2]
    ball(cx, cy, 5, 5, TIMB); ball(cx, cy, 3, 3, { OAK[3], OAK[4], OAK[5], OAK[5], OAK[6], OAK[6] }); P(cx, cy, OAK[3]); P(cx + 1, cy, OAK[3])
  end
end
function PR.mailbox(x, y, col)
  bx(x, y - 22, x + 2, y, TIMB)
  bx(x - 6, y - 32, x + 9, y - 22, col); for xx = x - 5, x + 8 do P(xx, y - 33, INK) end
  bx(x + 9, y - 36, x + 11, y - 28, R.CORAL)
end
function PR.pinwheel(x, y, h, cols)
  for yy = y - h, y do P(x, yy, INK); P(x + 1, yy, TIMB[4]) end
  local hy = y - h
  local q = { { 1, -1 }, { 1, 1 }, { -1, 1 }, { -1, -1 } }
  for i, d in ipairs(q) do
    for a = 1, 6 do for b = 0, a - 1 do
      local px, py = x + d[1] * a, hy + d[2] * b * (i % 2 == 1 and 1 or 1)
      if i % 2 == 0 then px, py = x + d[1] * b, hy + d[2] * a end
      P(px, py, cols[i]); if b == a - 1 then P(px, py, INK) end
    end end
  end
  P(x, hy, GOLD[5]); P(x + 1, hy, GOLD[3])
end
function PR.signpost(x, y)
  bx(x, y - 44, x + 3, y, TIMB)
  local b1 = bx(x - 15, y - 42, x + 3, y - 34, OAK); P(x - 16, y - 38, INK); P(x - 15, y - 38, OAK[4])
  local b2 = bx(x + 1, y - 30, x + 19, y - 22, OAK); P(x + 20, y - 26, INK); P(x + 19, y - 26, OAK[4])
end
function PR.skep(x, y)
  bx(x - 11, y - 2, x + 11, y, TIMB)
  local m = c:ellipse(x, y - 10, 9, 10):clip(rect(x - 10, y - 21, x + 10, y - 3)); c:rim(m, INK)
  m:each(function(xx, yy)
    local t = (xx < x - 3) and 5 or ((xx > x + 3) and 3 or 4)
    if (yy - y) % 4 == 0 then t = t - 1 end
    P(xx, yy, R.YEL[max(1, t)])
  end)
  c:fillMask(rect(x - 2, y - 7, x + 2, y - 3), INK); P(x - 1, y - 7, "#2a1810")
  P(x, y - 21, INK)
end
function PR.broom(x, y)
  ln({ { x + 9, y - 40 }, { x, y - 6 } }, 2, TIMB, 4)
  local m = rect(x - 5, y - 8, x + 5, y); c:rim(m, INK)
  m:each(function(xx, yy) P(xx, yy, R.YEL[((xx + yy) % 3 == 0) and 3 or 4]) end)
  for xx = x - 5, x + 5 do P(xx, y - 8, ((xx % 2) == 0) and IRON[4] or IRON[3]) end
end
function PR.yarnbasket(x, y)
  ln({ { x - 4, y - 14 }, { x + 7, y - 30 } }, 1, IRON, 5); ln({ { x + 5, y - 14 }, { x - 4, y - 30 } }, 1, IRON, 5)
  P(x + 7, y - 31, GOLD[5]); P(x - 4, y - 31, GOLD[5])
  ball(x - 5, y - 13, 5, 5, R.CORAL); ball(x + 5, y - 14, 5, 5, TEAL); ball(x, y - 18, 4, 4, R.LAV)
  for k = 0, 8 do P(x - 5 + k, y - 12 + (k % 3), R.CORAL[2]) end
  local m = rect(x - 10, y - 9, x + 10, y); m:cut(rect(x - 10, y, x - 10, y)); c:rim(m, INK)
  m:each(function(xx, yy) local a, b = floor(xx / 3), floor(yy / 3); local t = ((a + b) % 2 == 0) and 4 or 3; if yy == y - 9 then t = 6 end; if yy >= y - 1 then t = 2 end; P(xx, yy, DIRT[t]) end)
  for xx = x - 11, x + 11 do P(xx, y - 10, INK) end; for xx = x - 10, x + 10 do P(xx, y - 9, DIRT[6]) end
end
function PR.telescope(x, y)
  ln({ { x, y - 22 }, { x - 9, y } }, 2, TIMB, 4); ln({ { x, y - 22 }, { x + 9, y } }, 2, TIMB, 3); ln({ { x, y - 22 }, { x, y } }, 1, TIMB, 4)
  local t = c:line({ { x - 12, y - 14 }, { x + 14, y - 32 } }, 6); c:rim(t, INK)
  t:each(function(xx, yy) local d = (xx * .8 + yy * .6); P(xx, yy, GOLD[(yy < (y - 14) - (xx - x + 12) * .69 - 1) and 5 or ((yy > (y - 14) - (xx - x + 12) * .69 + 2) and 3 or 4)]) end)
  for _, k in ipairs{ 6, 12, 19 } do local bx0, by0 = x - 12 + k, floor(y - 14 - k * .69); for d = -3, 3 do P(bx0 + (d > 0 and 0 or 0), by0 + d, IRON[3]) end end
  ball(x + 15, y - 33, 3, 3, { "#2a4a6a", "#4a7a9a", "#78bccc", "#a8dce0", "#d4f0f4", "#fff" })
end
function PR.buoy(x, y, a, b)
  bx(x, y - 24, x + 2, y, TIMB)
  local lr = c:ellipse(x + 1, y - 18, 8, 8); lr:cut(c:ellipse(x + 1, y - 18, 3, 3)); c:rim(lr, INK)
  lr:each(function(xx, yy) local k = floor((math.atan(yy - y + 18, xx - x - 1) + pi) / .7854); P(xx, yy, (k % 2 == 0) and a or b) end)
  P(x - 4, y - 24, "#ffffffaa" and "#fff2dc")
end
function PR.coil(x, y)
  local m = c:ellipse(x, y - 4, 11, 5); c:rim(m, INK)
  m:each(function(xx, yy) local d = sqrt(((xx - x) / 11) ^ 2 + ((yy - y + 4) / 5) ^ 2); local t = (floor(d * 5) % 2 == 0) and 5 or 3; if yy < y - 5 then t = min(6, t + 1) end; P(xx, yy, CREAM[t]) end)
  c:fillMask(c:ellipse(x, y - 4, 3, 1), INK)
end
function PR.oar(x, y, col)
  ln({ { x, y }, { x + 6, y - 36 } }, 2, TIMB, 4)
  local bl = c:line({ { x + 6, y - 36 }, { x + 9, y - 56 } }, 6); c:rim(bl, INK)
  bl:each(function(xx, yy) P(xx, yy, col[(xx < x + 7 + (y - 36 - yy) * -.15) and 5 or 3]) end)
  for yy = y - 52, y - 40, 2 do P(x + 8 + floor((y - 36 - yy) * -.15), yy, col[6]) end
end
function PR.lobsterpot(x, y)
  local m = c:ellipse(x, y - 8, 11, 8):clip(rect(x - 12, y - 17, x + 12, y - 1)); c:rim(m, INK)
  m:each(function(xx, yy) local t = (yy < y - 12) and 5 or 3; if ((xx + yy) % 4 == 0) or ((xx - yy) % 4 == 0) then P(xx, yy, DIRT[6]) else P(xx, yy, DIRT[t - 1]) end end)
  c:fillMask(rect(x - 3, y - 7, x + 3, y - 1), INK); P(x - 4, y - 8, DIRT[6])
  P(x, y - 17, INK); for k = 1, 5 do P(x + k, y - 18 - k // 2, "#c8a060") end
  ball(x + 7, y - 24, 2, 2, { "#7a2230", "#b0343a", "#e8493b", "#e8493b", "#ff9a8a", "#fff" })
end
function PR.fishingrod(x, y)
  local rod = c:line({ { x, y }, { x + 6, y - 28 }, { x + 18, y - 54 } }, 2); c:rim(rod, INK); c:fillMask(rod, TIMB[5])
  ball(x + 5, y - 22, 3, 3, IRON)
  for yy = y - 52, y - 24 do P(x + 20 + (y - 52 - yy) // 9, yy, "#e6f2ff") end
  ball(x + 17, y - 22, 3, 3, { "#7a2230", "#b0343a", "#e8493b", "#e8493b", "#ff9a8a", "#fff" })
end
function PR.berrybush(x, y, col)
  for _, q in ipairs{ { -8, 0, 7 }, { 8, 1, 7 }, { 0, -5, 8 } } do ball(x + q[1], y + q[2] - 6, q[3], q[3] - 1, GREEN) end
  for _, q in ipairs{ { -9, -8 }, { -2, -12 }, { 6, -9 }, { 11, -4 }, { -5, -3 }, { 2, -5 } } do ball(x + q[1], y + q[2], 2, 2, { "#2a1030", col[1], col[2], col[2], col[3], "#fff" }) end
end
function PR.bookstack(x, y, cols)
  local h = 0
  for i, cc in ipairs(cols) do
    local w = 22 - i * 3 + (i % 2) * 2
    bx(x - 11 + (i % 2) * 2, y - h - 6, x - 11 + (i % 2) * 2 + w, y - h, cc)
    for xx = x - 8 + (i % 2) * 2, x - 8 + (i % 2) * 2 + w - 6, w - 6 do P(xx, y - h - 3, GOLD[5]) end
    h = h + 6
  end
end
function PR.stool(x, y, kettle)
  bx(x - 8, y - 11, x + 8, y - 8, OAK); bx(x - 6, y - 8, x - 4, y, TIMB); bx(x + 4, y - 8, x + 6, y, TIMB)
  if kettle then
    ln({ { x + 5, y - 17 }, { x + 11, y - 22 } }, 2, kettle, 4)
    ball(x, y - 17, 7, 6, kettle); c:fillMask(rect(x - 2, y - 24, x + 2, y - 23), INK); P(x, y - 24, kettle[5])
    local h = c:line({ { x - 5, y - 21 }, { x - 1, y - 28 }, { x + 4, y - 22 } }, 1); c:rim(h, INK); c:fillMask(h, IRON[4])
    P(x - 4, y - 19, kettle[6]); P(x - 3, y - 20, kettle[6])
  end
end
function PR.spool(x, y, col, h)
  for _, q in ipairs{ { y - h, y - h + 3 }, { y - 3, y } } do bx(x - 9, q[1], x + 9, q[2], OAK) end
  local m = rect(x - 7, y - h + 4, x + 7, y - 4); c:rim(m, INK)
  m:each(function(xx, yy) local t = (xx < x - 2) and 5 or ((xx > x + 3) and 3 or 4); if (yy % 2) == 0 then t = t - 1 end; P(xx, yy, col[max(1, t)]) end)
  for k = 0, 24 do P(x + 9 + k, y - 1 + floor(sin(k / 3) * 1.5 + .5), col[4]); P(x + 9 + k, y, col[2]) end
end
function PR.thimblePot(x, y)
  local m = c:ellipse(x, y - 14, 9, 8):clip(rect(x - 10, y - 24, x + 10, y - 12)); m:add(rect(x - 9, y - 14, x + 9, y)); c:rim(m, INK)
  m:each(function(xx, yy)
    local t = (xx < x - 3) and 5 or ((xx > x + 4) and 3 or 4); if xx > x + 7 then t = 2 end
    if ((xx + (yy // 3) * 2) % 4 == 0) and yy % 3 == 0 then t = t - 1 end
    P(xx, yy, IRON[max(1, min(6, t + 1))])
  end)
  for xx = x - 10, x + 10 do P(xx, y - 3, INK); P(xx, y - 2, IRON[5]) end
  for k = 0, 4 do P(x - 3 + k * 2, y - 24 - (k % 2), GREEN[4]); P(x - 3 + k * 2, y - 25 - (k % 2), GREEN[5]) end
  ball(x - 1, y - 28, 3, 3, { "#7a3a58", "#c46890", "#f0a8c4", "#f0a8c4", "#fde4ee", "#fff" })
end
function PR.breadrack(x, y)
  bx(x - 17, y - 14, x + 17, y - 11, OAK); bx(x - 15, y - 11, x - 12, y, TIMB); bx(x + 12, y - 11, x + 15, y, TIMB)
  for _, q in ipairs{ { -11, 7, 3 }, { -3, 8, 3 }, { 5, 6, 3 } } do ball(x + q[1], y - 14 - q[3], q[2], q[3] + 1, R.ORG); P(x + q[1] - 2, y - 16 - q[3], R.ORG[6]); P(x + q[1] + 1, y - 14 - q[3], R.ORG[2]); P(x + q[1] - 1, y - 14 - q[3], R.ORG[2]) end
  ball(x + 13, y - 18, 5, 4, R.PEACH); for k = -4, 4, 2 do P(x + 13 + k, y - 18, R.PEACH[2]) end
end
function PR.crystal(x, y)
  for _, q in ipairs{ { -9, 8, 22 }, { 0, 10, 30 }, { 10, 7, 18 } } do
    local cx, w, h = x + q[1], q[2] // 2, q[3]
    local m = HP.mask()
    for dy = 0, h - 1 do local hw = (dy < 8) and floor(w * dy / 8 + .5) or w; for xx = cx - hw, cx + hw do m:set(xx, y - h + dy + 1) end end
    c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, R.LAV[(xx < cx - 1) and 5 or ((xx > cx + 1) and 3 or 4)]) end)
    P(cx - 1, y - h + 5, R.LAV[6]); P(cx - 1, y - h + 6, R.LAV[6])
  end
end
function PR.candlestack(x, y)
  bx(x - 7, y - 10, x + 7, y, TIMB)
  for _, q in ipairs{ { -4, 10 }, { 1, 14 }, { 5, 8 } } do
    local m = bx(x + q[1] - 1, y - 10 - q[2], x + q[1] + 1, y - 11, CREAM)
    P(x + q[1], y - 12 - q[2], "#ffe08a"); P(x + q[1], y - 13 - q[2], "#fff6cc"); P(x + q[1], y - 14 - q[2], "#ffd24a")
    P(x + q[1] + 2, y - 10 - q[2] // 2, CREAM[5]); P(x + q[1] + 2, y - 9 - q[2] // 2, CREAM[5])
  end
  S.glow(x, y - 20, 14, "#ffd070", .3)
end
function PR.easel(x, y)
  ln({ { x, y - 46 }, { x - 12, y } }, 2, TIMB, 4); ln({ { x, y - 46 }, { x + 12, y } }, 2, TIMB, 3); ln({ { x, y - 40 }, { x, y - 6 } }, 1, TIMB, 4)
  bx(x - 13, y - 14, x + 13, y - 12, TIMB)
  local cv = bx(x - 12, y - 44, x + 12, y - 18, CREAM)
  for _, q in ipairs{ { -8, -38, 6, "#e8493b" }, { -1, -34, 7, "#3f8c8c" }, { 5, -30, 5, "#ffd24a" }, { -9, -27, 5, "#7a5ac8" }, { 3, -41, 4, "#f0809c" } } do
    for k = 0, q[3] do P(x + q[1] + k, y + q[2] + floor(sin(k) * 2) + k // 3, q[4]); P(x + q[1] + k, y + q[2] + 1 + floor(sin(k) * 2) + k // 3, q[4]) end
  end
  ball(x + 19, y - 4, 4, 2, R.CREAM); P(x + 17, y - 5, "#e8493b"); P(x + 20, y - 5, "#3f8c8c")
end
function PR.cairn(x, y, n)
  local ws = { 14, 11, 8, 5 }; local yy = y
  for i = 1, n do
    local w = ws[i]; ball(x, yy - 3, w // 2 + 1, 3, STONE); P(x - 2, yy - 5, STONE[6]); yy = yy - 5
  end
end
function PR.fence(x0, x1, y)
  for xx = x0, x1, 7 do
    local m = rect(xx, y - 14, xx + 3, y); m:cut(rect(xx, y - 14, xx, y - 14)); m:cut(rect(xx + 3, y - 14, xx + 3, y - 14)); c:rim(m, INK)
    m:each(function(x2, y2) P(x2, y2, (x2 == xx) and CREAM[6] or CREAM[4]) end); P(xx + 1, y - 15, INK); P(xx + 2, y - 15, INK)
  end
  for _, yy in ipairs{ y - 10, y - 4 } do for xx = x0, x1 + 3 do P(xx, yy, INK); P(xx, yy + 1, CREAM[3]) end end
end
function PR.seedsack(x, y)
  local m = c:ellipse(x, y - 9, 10, 9):clip(rect(x - 11, y - 18, x + 11, y)); m:add(rect(x - 10, y - 9, x + 10, y)); c:rim(m, INK)
  m:each(function(xx, yy) P(xx, yy, R.PEACH[(xx < x - 3) and 5 or ((xx > x + 4) and 3 or 4)]) end)
  for xx = x - 4, x + 4 do P(xx, y - 18, INK) end; c:fillMask(rect(x - 3, y - 19, x + 3, y - 17), R.PEACH[3]); for xx = x - 4, x + 4 do P(xx, y - 17, CORALX or R.CORAL[4]) end
  for _, q in ipairs{ { 14, -1 }, { 17, 0 }, { 13, 1 }, { 19, -1 }, { 16, 1 } } do P(x + q[1], y + q[2] - 1, "#4a3022"); P(x + q[1] + 1, y + q[2] - 1, "#946a38") end
  P(x - 2, y - 7, R.CORAL[2]); P(x - 1, y - 7, R.CORAL[2]); P(x, y - 7, R.CORAL[2])
end
function PR.tomatoes(x, y)
  bx(x - 1, y - 40, x + 1, y, TIMB)
  for yy = y - 38, y - 4, 8 do for k = 0, 6 do P(x - 3 - k, yy + k // 3, GREEN[4]); P(x + 3 + k, yy + 2 + k // 3, GREEN[4]); P(x - 3 - k, yy + 1 + k // 3, GREEN[3]); P(x + 3 + k, yy + 3 + k // 3, GREEN[3]) end end
  for _, q in ipairs{ { -8, -12 }, { 8, -22 }, { -9, -28 }, { 7, -6 }, { -7, -3 } } do ball(x + q[1], y + q[2], 3, 3, R.REDW) end
end
function PR.grapevine(x, y)
  bx(x - 2, y - 56, x, y, TIMB); bx(x - 14, y - 54, x + 12, y - 51, TIMB)
  for yy = y - 2, y - 54, -1 do local vx = floor(x - 1 + 5 * sin(yy / 6)); P(vx - 1, yy, INK); P(vx + 1, yy, INK); P(vx, yy, GREEN[(yy % 4 < 2) and 5 or 4]) end
  for _, q in ipairs{ { -8, -44 }, { 7, -34 }, { -7, -22 } } do
    ball(x + q[1] + 6, y + q[2] - 4, 5, 3, LEAF)
    for row = 0, 3 do for k = 0, 3 - row do ball(x + q[1] + k * 4 + row * 2 - 6, y + q[2] + row * 4 + 6, 2, 2, R.VIO) end end
  end
end
function PR.quillink(x, y)
  local q = c:line({ { x - 2, y - 18 }, { x + 4, y - 48 }, { x + 16, y - 66 } }, 1); c:rim(q, INK); c:fillMask(q, CREAM[5])
  local vane = c:ellipse(x + 8, y - 48, 5, 14); vane:cut(rect(x - 2, y - 36, x + 6, y - 30)); c:rim(vane, INK)
  vane:each(function(xx, yy) P(xx, yy, ((xx + yy) % 5 == 0) and R.PEACH[3] or ((xx < x + 8) and R.PEACH[5] or R.PEACH[4])) end)
  ln({ { x - 1, y - 18 }, { x + 11, y - 60 } }, 1, CREAM, 3)
  local pot = c:ellipse(x - 2, y - 7, 11, 7):clip(rect(x - 14, y - 14, x + 10, y)); c:rim(pot, INK)
  pot:each(function(xx, yy) P(xx, yy, R.NAVY[(xx < x - 5) and 5 or ((xx > x + 3) and 2 or 3)]) end)
  c:fillMask(rect(x - 6, y - 15, x + 2, y - 12), INK); c:fillMask(rect(x - 5, y - 14, x + 1, y - 13), "#2a2a5a"); P(x - 4, y - 14, "#8aa0e0")
end
function PR.cactus(x, y, h)
  local m = rect(x - 4, y - h, x + 4, y); m:cut(rect(x - 4, y - h, x - 4, y - h)); m:cut(rect(x + 4, y - h, x + 4, y - h))
  for _, a in ipairs{ { -12, -h // 2, -4, -h // 2 + 8 }, { 4, -h // 2 - 6, 12, -h // 2 + 8 } } do end
  local arm1 = rect(x - 12, y - h // 2 - 2, x - 5, y - h // 2 + 2); arm1:add(rect(x - 12, y - h // 2 - 12, x - 9, y - h // 2 + 2))
  local arm2 = rect(x + 5, y - h // 2 - 8, x + 12, y - h // 2 - 4); arm2:add(rect(x + 9, y - h // 2 - 16, x + 12, y - h // 2 - 4))
  local all = HP.mask(); all:add(m):add(arm1):add(arm2); c:rim(all, INK)
  all:each(function(xx, yy) local t = (xx < x - 1 and xx > x - 4) and 5 or ((xx > x + 1 and xx < x + 5) and 3 or 4); if (xx - x) % 4 == 0 then t = 3 end; P(xx, yy, R.SAGE[min(6, t + 1)]) end)
  for yy = y - h + 3, y - 3, 6 do P(x - 2, yy, "#fff2dc"); P(x + 2, yy + 2, "#fff2dc") end
  ball(x, y - h - 2, 2, 2, { "#7a3a58", "#c46890", "#f0809c", "#f0809c", "#fde4ee", "#fff" })
end
function PR.stakes() end

---------------------------------------------------------------- wall / hanging props
function PR.bunting(x0, x1, y, cols, sag)
  sag = sag or 8
  local pts = {}
  for x = x0, x1 do local t = (x - x0) / (x1 - x0); local yy = floor(y + sag * (1 - (2 * t - 1) ^ 2) + .5); P(x, yy, INK); pts[x] = yy end
  local i = 0
  for x = x0 + 4, x1 - 6, 9 do
    i = i + 1; local cc = cols[i % #cols + 1]; local y0 = pts[x] + 1
    for k = 0, 6 do for xx = x + floor(k * .45), x + 6 - floor(k * .45) do P(xx, y0 + k, (xx == x + floor(k * .45) and k < 5) and R.CREAM[6] or cc) end end
    for k = 0, 6 do P(x + floor(k * .45) - 1, y0 + k, INK); P(x + 7 - floor(k * .45), y0 + k, INK) end
    for xx = x + 3, x + 3 do P(xx, y0 + 7, INK) end
  end
end
function PR.lights(x0, x1, y, sag, col)
  for x = x0, x1 do local t = (x - x0) / (x1 - x0); P(x, floor(y + sag * (1 - (2 * t - 1) ^ 2) + .5), INK) end
  local i = 0
  for x = x0 + 5, x1 - 4, 10 do
    i = i + 1; local t = (x - x0) / (x1 - x0); local yy = floor(y + sag * (1 - (2 * t - 1) ^ 2) + .5)
    S.glow(x, yy + 5, 9, col[i % #col + 1], .35)
    c:fillMask(rect(x - 1, yy + 1, x + 1, yy + 2), INK); ball(x, yy + 5, 2, 3, { "#6a2010", col[1], col[i % #col + 1], col[i % #col + 1], "#fff0c0", "#fff" })
  end
end
function PR.mobile(x, y)
  bx(x - 16, y, x + 16, y + 2, TIMB); for yy = y - 7, y - 1 do P(x, yy, INK) end
  for _, q in ipairs{ { -12, 12, 0 }, { 0, 20, 1 }, { 12, 14, 2 } } do
    for yy = y + 3, y + q[2] do P(x + q[1], yy, INK) end
    local cx, cy = x + q[1], y + q[2] + 5
    if q[3] == 0 then
      local m = c:ellipse(cx, cy, 5, 5); m:cut(c:ellipse(cx + 3, cy - 2, 4, 4)); c:rim(m, INK); c:fillMask(m, "#ffe08a"); P(cx - 4, cy, "#fff6cc")
    elseif q[3] == 1 then
      local m = rect(cx - 1, cy - 6, cx + 1, cy + 6); m:add(rect(cx - 6, cy - 1, cx + 6, cy + 1)); m:add(c:ellipse(cx, cy, 3, 3)); c:rim(m, INK); c:fillMask(m, "#ffd24a"); P(cx, cy, "#fff6cc")
    else
      ball(cx, cy, 4, 4, R.LAV); P(cx - 1, cy - 2, "#fff")
    end
  end
end
function PR.bell(x, y)
  bx(x, y - 10, x + 3, y + 10, TIMB); bx(x - 14, y - 10, x + 2, y - 7, TIMB)
  for yy = y - 6, y - 3 do P(x - 10, yy, INK) end
  local b = c:ellipse(x - 10, y + 1, 6, 6):clip(rect(x - 17, y - 5, x - 3, y + 3)); b:add(rect(x - 16, y + 3, x - 4, y + 6)); c:rim(b, INK)
  b:each(function(xx, yy) P(xx, yy, GOLD[(xx < x - 11) and 6 or ((xx > x - 8) and 3 or 4)]) end)
  P(x - 10, y + 8, INK); P(x - 10, y + 9, GOLD[4]); P(x - 9, y + 9, INK); P(x - 11, y + 9, INK)
end
function PR.wreath(x, y, col)
  local r = c:ellipse(x, y, 12, 12); r:cut(c:ellipse(x, y, 6, 6)); c:rim(r, INK)
  r:each(function(xx, yy) P(xx, yy, GREEN[2 + floor(hash(xx, yy, 7) * 4)]) end)
  for i = 0, 7 do local a = i * pi / 4 + .4; ball(floor(x + cos(a) * 9 + .5), floor(y + sin(a) * 9 + .5), 2, 2, { "#5a2a44", col[1], col[2], col[2], col[3], "#fff" }) end
  for k = 0, 3 do P(x - 3 - k, y + 12 + k // 2, "#e8493b"); P(x + 3 + k, y + 12 + k // 2, "#e8493b") end
  P(x, y + 12, INK); P(x - 1, y + 12, "#e8493b"); P(x + 1, y + 12, "#e8493b")
end
function PR.hangpots(x, y)
  for _, dx in ipairs{ -8, 8 } do for yy = y - 12, y do P(x + dx, yy, INK) end end
  for k = 0, 8 do P(x - 8 + k * 2, y - 12 - 0, INK) end
  P(x, y - 20, INK); for yy = y - 20, y - 12 do P(x, yy, IRON[4]) end
  bx(x - 12, y, x + 12, y + 8, R.ORG)
  for xx = x - 11, x + 11 do local h = 3 + floor(hash(xx, 2, 6) * 5); for k = 1, h do P(xx, y - k, GREEN[(k > h - 2) and 5 or 3]) end end
  for xx = x - 10, x + 10, 6 do P(xx, y + 9, GREEN[4]); P(xx, y + 10, GREEN[4]); P(xx + 1, y + 11, GREEN[3]); P(xx + 2, y + 12, GREEN[3]) end
  for _, q in ipairs{ { -7, -4 }, { 1, -7 }, { 8, -5 } } do ball(x + q[1], y + q[2], 2, 2, R.LAV) end
end
function PR.chilis(x, y, col)
  for yy = y, y + 4 do P(x, yy, INK) end; P(x - 1, y - 1, INK); P(x, y - 2, INK); P(x + 1, y - 1, INK)
  for i = 0, 5 do
    local yy = y + 5 + i * 6; local s = (i % 2 == 0) and -1 or 1
    P(x, yy, "#6aa838"); P(x, yy + 1, INK)
    for k = 0, 5 do P(x + s * 2 + s * (k // 3), yy + 1 + k, INK); P(x + s * 1 + s * (k // 3), yy + 1 + k, col[(k < 2) and 2 or 1]) end
    P(x + s, yy + 2, col[3])
  end
end
function PR.shelfjars(x, y)
  bx(x - 18, y, x + 18, y + 3, TIMB); bx(x - 14, y + 3, x - 12, y + 8, TIMB); bx(x + 12, y + 3, x + 14, y + 8, TIMB)
  for i, q in ipairs{ -12, -2, 8 } do
    local m = rect(q, y - 11, q + 8, y - 1); c:rim(m, INK)
    m:each(function(xx, yy) P(xx, yy, (yy < y - 8) and "#ffd24a" or ((xx < q + 3) and "#f8c050" or "#e08830")) end)
    c:fillMask(rect(q - 1, y - 14, q + 9, y - 12), INK); c:fillMask(rect(q, y - 13, q + 8, y - 13), R.YEL[5]); P(q + 1, y - 8, "#fff2a0"); P(q + 1, y - 7, "#fff2a0")
  end
end
function PR.net(x, y)
  local m = HP.mask()
  for yy = 0, 28 do local hw = 16 - floor(yy * .5); for xx = x - hw, x + hw do m:set(xx, y + yy) end end
  c:rim(m, INK)
  m:each(function(xx, yy) if ((xx + yy) % 5 == 0) or ((xx - yy) % 5 == 0) then P(xx, yy, DIRT[5]) else P(xx, yy, DIRT[2]) end end)
  for k = -14, 14, 7 do ball(x + k, y - 1, 2, 2, { "#7a3418", "#c0602c", "#e8843c", "#e8843c", "#fcd098", "#fff" }) end
  for xx = x - 17, x + 17 do P(xx, y - 3, INK); P(xx, y - 2, DIRT[4]) end
end
function PR.scrollrack(x, y)
  bx(x - 20, y + 10, x + 20, y + 13, TIMB)
  for i, q in ipairs{ -14, -4, 6, 14 } do
    local m = bx(q - 3, y - 6 + (i % 2) * 3, q + 3, y + 9, CREAM)
    P(q, y - 6 + (i % 2) * 3, CREAM[6]); for xx = q - 3, q + 3 do P(xx, y + 2, R.CORAL[3]) end
    P(q - 1, y + 5, R.PEACH[2]); P(q + 1, y + 6, R.PEACH[2])
  end
end
function PR.chimney(x, y, h)
  bx(x - 5, y, x + 5, y + h, R.CORAL); for xx = x - 7, x + 7 do P(xx, y - 1, INK) end; c:fillMask(rect(x - 7, y - 3, x + 7, y - 2), INK); c:fillMask(rect(x - 6, y - 3, x + 6, y - 2), IRON[4])
  for k, p in ipairs{ { 2, -10, 4 }, { 7, -20, 5 }, { 15, -31, 6 } } do ball(x + p[1], y + p[2], p[3], p[3] - 1, CREAM) end
end
function PR.bunting2() end

---------------------------------------------------------------- lamp bodies
function LB.paper(col) return function(cx, cy)
  c:fillMask(rect(cx - 2, cy - 11, cx + 2, cy - 9), INK)
  ball(cx, cy, 7, 8, col); for _, d in ipairs{ -4, 0, 4 } do for yy = cy - 6, cy + 6 do if (d == 0) or (abs(yy - cy) < 6 - abs(d) * .5) then P(cx + d, yy, col[2]) end end end
  c:fillMask(rect(cx - 3, cy - 8, cx + 3, cy - 7), INK); c:fillMask(rect(cx - 3, cy + 7, cx + 3, cy + 8), INK)
  c:fillMask(rect(cx - 2, cy - 4, cx + 1, cy + 2), "#ffe08a"); P(cx - 2, cy - 4, "#fff6cc")
  for yy = cy + 9, cy + 13 do P(cx, yy, INK) end; P(cx - 1, cy + 14, INK); P(cx, cy + 14, col[5]); P(cx + 1, cy + 14, INK)
end end
function LB.jar(cx, cy)
  c:fillMask(rect(cx - 2, cy - 11, cx + 2, cy - 9), INK)
  c:fillMask(rect(cx - 5, cy - 8, cx + 5, cy + 7), INK); c:fillMask(rect(cx - 4, cy - 7, cx + 4, cy + 6), "#d4f0f4")
  c:fillMask(rect(cx - 3, cy - 5, cx + 3, cy + 4), "#ffe08a"); c:fillMask(c:ellipse(cx, cy, 2, 2), "#fff6cc")
  for xx = cx - 4, cx + 4 do P(xx, cy - 7, IRON[4]); P(xx, cy - 6, IRON[3]) end; P(cx - 4, cy - 3, "#fff"); P(cx - 4, cy - 2, "#fff")
  P(cx + 3, cy + 5, "#e8a840"); P(cx, cy + 7, INK)
end
function LB.star(cx, cy)
  local m = rect(cx - 2, cy - 8, cx + 2, cy + 8); m:add(rect(cx - 8, cy - 2, cx + 8, cy + 2)); m:add(c:ellipse(cx, cy, 5, 5))
  c:rim(m, INK); m:each(function(x, y) P(x, y, ((x + y) < cx + cy) and "#fff6cc" or "#ffd24a") end); c:fillMask(c:ellipse(cx, cy, 2, 2), "#fff")
  for yy = cy - 11, cy - 9 do P(cx, yy, INK) end
end

---------------------------------------------------------------- door overlays (centre cx,cy)
function OV.crocus(cx, cy)
  for y = cy + 2, cy + 22 do P(cx, y, INK); P(cx + 1, y, GREEN[4]) end
  for k = 0, 8 do P(cx - 2 - k, cy + 20 - k, GREEN[5]); P(cx - 2 - k, cy + 21 - k, GREEN[3]); P(cx + 3 + k, cy + 17 - k, GREEN[5]); P(cx + 3 + k, cy + 18 - k, GREEN[3]) end
  ball(cx - 6, cy - 2, 4, 8, R.VIO); ball(cx + 8, cy - 2, 4, 8, R.VIO); ball(cx + 1, cy - 6, 5, 10, R.VIO)
  P(cx + 1, cy - 14, R.VIO[6]); pxs({ { cx - 1, cy + 4 }, { cx + 1, cy + 4 }, { cx + 3, cy + 4 } }, "#ffd24a"); P(cx + 1, cy + 3, "#ff9a30")
end
function OV.apple(cx, cy)
  ln({ { cx + 1, cy - 8 }, { cx + 3, cy - 14 } }, 2, TIMB, 4); ball(cx + 8, cy - 12, 6, 3, LEAF)
  ball(cx, cy + 1, 11, 10, R.REDW); P(cx - 4, cy - 4, R.REDW[6]); P(cx - 5, cy - 3, R.REDW[6]); P(cx - 5, cy - 2, R.REDW[6]); P(cx, cy - 8, R.REDW[2]); P(cx + 1, cy - 8, R.REDW[2])
end
function OV.lilypad(cx, cy)
  ball(cx, cy + 2, 13, 11, LEAF)
  for k = 0, 13 do P(cx + k, cy + 2 - floor(k * .45), INK) end
  for k = 0, 12 do P(cx + k, cy + 3 - floor(k * .45), R.GREEN[1]) end
  for i = 0, 4 do local a = i * 1.2566; ball(floor(cx - 3 + cos(a) * 4 + .5), floor(cy - 1 + sin(a) * 4 + .5), 2, 2, R.PASTEL) end
  P(cx - 3, cy - 1, "#ffd24a"); P(cx - 2, cy - 1, "#ffd24a")
end
function OV.cross()
  for _, y in ipairs{ 150, 186 } do bx(220, y, 259, y + 4, TIMB) end
  local d = c:line({ { 223, 191 }, { 256, 147 } }, 4); c:rim(d, INK); d:each(function(x, y) P(x, y, TIMB[((x + y) % 7 < 2) and 3 or 4]) end)
  for _, q in ipairs{ { 224, 152 }, { 255, 152 }, { 224, 188 }, { 255, 188 } } do P(q[1], q[2], GOLD[5]) end
end
function OV.petals(cx, cy)
  for i = 0, 7 do local a = i * pi / 4; ball(floor(cx + cos(a) * 10 + .5), floor(cy + sin(a) * 10 + .5), 4, 4, R.PASTEL) end
  ball(cx, cy, 5, 5, GOLD); pxs({ { cx - 2, cy - 1 }, { cx + 1, cy + 2 }, { cx + 2, cy - 2 } }, GOLD[2])
end
function OV.sun(cx, cy)
  for i = 0, 11 do local a = i * pi / 6; for r = 11, 16 do P(floor(cx + cos(a) * r + .5), floor(cy + sin(a) * r + .5), (r < 15) and GOLD[5] or GOLD[3]) end end
  ball(cx, cy, 9, 9, GOLD); P(cx - 4, cy - 4, GOLD[6]); P(cx - 3, cy - 5, GOLD[6])
end
function OV.wheel(cx, cy)
  for i = 0, 7 do local a = i * pi / 4; ln({ { cx, cy }, { floor(cx + cos(a) * 15 + .5), floor(cy + sin(a) * 15 + .5) } }, 1, GOLD, 4) end
  local r = c:ellipse(cx, cy, 12, 12); r:cut(c:ellipse(cx, cy, 8, 8)); c:rim(r, INK); r:each(function(x, y) local l = lit(x, y, cx, cy, 12); P(x, y, GOLD[l > .3 and 5 or (l > -.4 and 4 or 3)]) end)
  for i = 0, 7 do local a = i * pi / 4; ball(floor(cx + cos(a) * 15 + .5), floor(cy + sin(a) * 15 + .5), 2, 2, GOLD) end
  ball(cx, cy, 3, 3, GOLD)
end
function OV.batwing(cx, cy)
  for _, s in ipairs{ -1, 1 } do
    local m = HP.mask()
    for dx = 2, 18 do
      local top = cy - 6 - floor(dx * .55)
      local bot = cy + 6 - floor(dx * .15) + floor(3 * abs(sin(dx * pi / 6.2)))
      for y = top, bot do m:set(cx + s * dx, y) end
    end
    c:rim(m, INK); m:each(function(x, y) P(x, y, R.LAV[(y < cy - 4 - abs(x - cx) * .4) and 5 or ((y > cy + 6) and 3 or 4)]) end)
    for k = 4, 16, 4 do for y = cy - 4 - floor(k * .4), cy + 4 do P(cx + s * k, y, R.LAV[3]) end end
  end
  ball(cx, cy, 4, 8, R.NIGHT); P(cx - 2, cy - 9, R.NIGHT[5]); P(cx + 2, cy - 9, R.NIGHT[5]); P(cx - 1, cy - 3, "#ffd24a"); P(cx + 1, cy - 3, "#ffd24a")
end
function OV.leaf(cx, cy)
  ball(cx, cy, 11, 17, LEAF)
  for y = cy - 16, cy + 18 do P(cx, y, LEAF[6]) end
  for k = 1, 5 do for d = 1, 6 do P(cx - d, cy - 14 + k * 5 + d // 2 - 5 + 5, LEAF[2]); P(cx + d, cy - 14 + k * 5 + d // 2 - 5 + 5, LEAF[2]) end end
end
function OV.ripple(cx, cy)
  for _, r in ipairs{ 5, 10, 15 } do
    for i = 0, 79 do local a = i * pi / 40; local x, y = floor(cx + cos(a) * r + .5), floor(cy + sin(a) * r * .55 + .5); P(x + 1, y + 1, R.BLUEW[2]); P(x, y, R.BLUEW[6]) end
  end
  for i = 0, 79 do local a = i * pi / 40; P(floor(cx + cos(a) * 5 + .5), floor(cy + sin(a) * 2.75 + .5), "#fff") end
  P(cx, cy, "#b4d6f4")
end
function OV.hex(cx, cy)
  for _, q in ipairs{ { 0, 0, 1 }, { -12, 0, 0 }, { 12, 0, 0 }, { -6, -10, 0 }, { 6, -10, 0 }, { -6, 10, 0 }, { 6, 10, 0 } } do
    local x, y = cx + q[1], cy + q[2]
    local m = rect(x - 4, y - 5, x + 4, y + 5); m:cut(rect(x - 4, y - 5, x - 3, y - 4)); m:cut(rect(x + 3, y - 5, x + 4, y - 4)); m:cut(rect(x - 4, y + 4, x - 3, y + 5)); m:cut(rect(x + 3, y + 4, x + 4, y + 5))
    c:rim(m, INK); m:each(function(xx, yy) local l = (xx < x and yy < y) and 5 or ((xx > x and yy > y) and 3 or 4); P(xx, yy, (q[3] == 1) and R.ORG[l] or GOLD[l]) end)
  end
end
function OV.feather(cx, cy)
  local sp = {}
  for i = 0, 40 do local t = i / 40; sp[i] = { floor(cx - 7 + 12 * t + sin(t * 3) * 2 + .5), floor(cy + 24 - 46 * t + .5) } end
  for i = 6, 38 do local p = sp[i]; local len = floor(9 * (1 - abs(i / 40 - .5) * 1.3)); for k = 1, len do P(p[1] - k, p[2] + k // 2, (k > len - 2) and R.LAV[6] or R.LAV[4]); P(p[1] + k, p[2] + k // 2, (k > len - 2) and R.LAV[5] or R.LAV[3]) end end
  for i = 0, 40 do P(sp[i][1], sp[i][2], INK); P(sp[i][1] + 1, sp[i][2], "#fff2dc") end
end
function OV.scroll(cx, cy)
  bx(cx - 10, cy - 12, cx + 10, cy + 12, CREAM)
  bx(cx - 13, cy - 16, cx + 13, cy - 12, R.PEACH); bx(cx - 13, cy + 12, cx + 13, cy + 16, R.PEACH)
  for i = 0, 4 do for x = cx - 7, cx + 7 - (i % 3) * 2 do if hash(x, i, 4) > .25 then P(x, cy - 8 + i * 4, "#8a6a5a") end end end
  ball(cx + 6, cy + 7, 3, 3, R.CORAL)
end
function OV.dots(cx, cy, cols)
  cols = cols or { "#ffd24a", "#fff2dc", "#8fc0f0" }
  for i, q in ipairs{ { 228, 150, 4 }, { 250, 148, 3 }, { 236, 168, 5 }, { 253, 172, 3 }, { 229, 188, 3 }, { 246, 190, 4 }, { 224, 168, 2 }, { 247, 160, 2 } } do
    local m = c:ellipse(q[1], q[2], q[3], q[3]); c:fillMask(m, cols[i % #cols + 1]); P(q[1] - 1, q[2] - 1, "#fff")
  end
end
function OV.poppy(cx, cy)
  for k = 0, 24 do P(cx + floor(sin(k / 5) * 2), cy + 4 + k, INK); P(cx + 1 + floor(sin(k / 5) * 2), cy + 4 + k, GREEN[4]) end
  for k = 0, 7 do P(cx - 2 - k, cy + 18 - k // 2, GREEN[5]); P(cx + 4 + k, cy + 14 - k // 2, GREEN[5]) end
  for _, d in ipairs{ { -5, -2 }, { 6, -2 }, { 0, -8 }, { 0, 4 } } do ball(cx + d[1], cy + d[2], 5, 5, R.REDW) end
  ball(cx, cy - 2, 3, 3, { "#140e10", "#2a1820", "#3a2430", "#3a2430", "#5a3a48", "#7a5a68" })
end
function OV.lattice(cx, cy)
  local m = c:ellipse(cx, cy, 22, 28)
  m:each(function(x, y) if ((x + y) % 9 < 2) or ((x - y) % 9 < 2) then P(x, y, ((x + y) % 9 == 0 or (x - y) % 9 == 0) and "#f8d890" or "#c88a44") end end)
  for i = 0, 40 do local a = i * pi / 20; P(floor(cx + cos(a) * 22 + .5), floor(cy + sin(a) * 28 + .5), "#f4c878") end
  for _, q in ipairs{ { cx, cy }, { cx - 9, cy }, { cx + 9, cy }, { cx, cy - 10 }, { cx, cy + 10 } } do P(q[1], q[2], "#6a2a1a") end
end
function OV.grapes(cx, cy)
  ln({ { cx, cy - 14 }, { cx + 1, cy - 8 } }, 2, TIMB, 4); ball(cx + 9, cy - 12, 7, 3, LEAF); ball(cx - 8, cy - 11, 6, 3, LEAF)
  for row = 0, 5 do for k = 0, 5 - row do ball(cx - (5 - row) * 2 + k * 4 + 1, cy - 6 + row * 5, 3, 3, R.VIO) end end
  for _, q in ipairs{ { cx - 3, cy - 6 }, { cx + 3, cy - 1 } } do P(q[1], q[2], R.VIO[6]) end
end
function OV.button(cx, cy)
  ball(cx, cy, 13, 13, CREAM)
  for i = 0, 63 do local a = i * pi / 32; P(floor(cx + cos(a) * 9 + .5), floor(cy + sin(a) * 9 + .5), CREAM[3]) end
  for _, d in ipairs{ { -3, -3 }, { 2, -3 }, { -3, 2 }, { 2, 2 } } do c:fillMask(rect(cx + d[1], cy + d[2], cx + d[1] + 1, cy + d[2] + 1), INK) end
  for k = 0, 4 do P(cx - 3 + k, cy - 3 + k, "#e8493b"); P(cx + 2 - k, cy - 3 + k, "#e8493b"); P(cx - 2 + k, cy - 3 + k, "#e8493b") end
end
function OV.moon(cx, cy) moonstars() end
