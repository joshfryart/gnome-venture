-- picket-fence (sonnet-medium test)
local LIB = "/home/user/gnome-venture/aseprite-source/v3/lib/"
local HP = dofile(LIB .. "hp.lua")
local X = dofile(LIB .. "hpx.lua").init(HP)
local K = X.K
local OUT = app.params.out or "./"
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function ell(cx, cy, rx, ry)
  local m = HP.mask()
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    if ((x + 0.5 - cx) / rx) ^ 2 + ((y + 0.5 - cy) / ry) ^ 2 <= 1 then m:set(x, y) end end end
  return m
end
local function tn(c, m, ramp, R, o)
  o = o or {}
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias })
  return n, v
end
local function tnN(c, m, n, ramp, o)
  o = o or {}
  local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  X.tone(c, m, v, ramp, { cuts = o.cuts or CUTS, bias = o.bias })
  return v
end
local function fin(c, name)
  c:finish{ outline = true }
  HP.report(c) HP.assertClean(c)
  c:save{ aseprite = OUT .. name .. ".aseprite", png = OUT .. name .. ".png", scale = 1 }
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "picket-fence" }
local WD = { "#3e2a30", "#5e3e3a", "#80583e", "#a47646", "#c89a58", "#e8c070" }
local PA = { "#6c6488", "#9b93b4", "#c8c2d6", "#e6e0e8", "#f6f0ea", "#fffaf0" }
local GR = { "#1b3b3c", "#255644", "#32764b", "#4b9650", "#70b45a", "#9ccd6c" }
c:groundShadow(30, 55, 26, 2)
-- rails (behind)
local rails = HP.mask()
for _, y in ipairs{ 23, 41 } do rails:add(c:rect(5, y, 55, y + 5)) end
local rn = {}
rails:each(function(x, y) local yy = (y - ((y < 33) and 23 or 41)) / 5 - 0.5 rn[K(x, y)] = { 0, yy * 1.6, sqrt(max(0.05, 1 - (yy * 1.6) ^ 2)) } end)
local rb = {}
rails:each(function(x, y) if X.hash(floor(x / 3), y, 7) > 0.8 then rb[K(x, y)] = -1 end end)
tnN(c, rails, rn, WD, { bias = rb })
-- pickets
local tips = { 10, 11, 9, 10 }
local pk = HP.mask()
local pickets = {}
for i = 0, 3 do
  local x0 = 8 + i * 12
  local cx = x0 + 4
  local m = HP.mask()
  local ty = tips[i + 1]
  for y = ty, 54 do
    local hw = (y < ty + 7) and (0.6 + (y - ty) / 7 * 3.9) or 4.5
    for x = floor(cx - hw + 0.5), floor(cx + hw - 0.5) do m:set(x, y) end
  end
  pickets[i + 1] = { m = m, cx = cx, ty = ty }
  pk:add(m)
  local n = {}
  m:each(function(x, y)
    local nx = max(-0.9, min(0.9, (x + 0.5 - cx - 0.5) / 4.8))
    local ny = (y < ty + 7) and -0.35 or 0
    n[K(x, y)] = { nx * 0.8, ny, sqrt(max(0.05, 1 - (nx * 0.8) ^ 2 - ny * ny)) }
  end)
  local bias = {}
  m:each(function(x, y)
    if X.hash(x, floor(y / 6), 3 + i) > 0.82 and x ~= x0 then bias[K(x, y)] = -1 end
    if y > 47 then bias[K(x, y)] = -1 end
  end)
  tnN(c, m, n, PA, { amb = 0.2, wrap = 0.2, bias = bias })
  -- top bevel highlight
  for y = ty, ty + 6 do local hw = 0.6 + (y - ty) / 7 * 3.9 c:px(floor(cx - hw + 0.5), y, PA[6]) end
  -- nails
  for _, ny2 in ipairs{ 25, 43 } do c:px(cx, ny2, PA[1]) c:px(cx - 1, ny2 - 1, PA[6]) end
end
-- rail AO next to pickets
rails:each(function(x, y) if not pk:has(x, y) and pk:has(x - 1, y) then c:px(x, y, WD[1]) end
  if not pk:has(x, y) and pk:has(x - 2, y) and not pk:has(x - 1, y) then c:px(x, y, WD[2]) end end)
-- peeling paint patches show wood
for _, p in ipairs{ {13,36,2.5,3.5}, {38,19,2,3}, {48,48,2.5,2} } do
  local m = ell(p[1], p[2], p[3], p[4]):clip(pk)
  m:each(function(x, y) c:px(x, y, m:has(x, y + 1) and WD[4] or WD[2]) end)
  m:each(function(x, y) if not m:has(x - 1, y) then c:px(x, y, WD[5]) end end)
end
-- snail on picket 2 (quirk)
local SH = { "#5a2a2a", "#8a4030", "#b8603c", "#dc8a48", "#f0b060", "#fcd890" }
local SB = { "#5a4a58", "#8a7a78", "#b8a890", "#d8c8a8", "#f0e4c8" }
local body = ell(24.5, 40, 4.6, 1.6)
body:add(ell(21, 37.5, 1.3, 2.4))
tn(c, body, { SB[1], SB[2], SB[3], SB[4], SB[5], SB[5] }, 2, {})
local shell = ell(26, 35, 3.8, 3.8)
local sn = X.pillow(shell, 4)
local sv = X.light(sn, { amb = 0.1, wrap = 0.3 })
local sbias = {}
shell:each(function(x, y)
  local d = sqrt((x + 0.5 - 26) ^ 2 + (y + 0.5 - 35) ^ 2)
  local a = math.atan(y + 0.5 - 35, x + 0.5 - 26)
  if floor(d * 1.1 + a / (2 * pi) * 1.5) % 2 == 0 and d > 0.5 then sbias[K(x, y)] = -1 end
end)
X.tone(c, shell, sv, SH, { cuts = CUTS, bias = sbias })
c:px(24, 33, SH[6]) c:px(25, 32, SH[6])
-- eyestalks
c:px(20, 35, SB[2]) c:px(20, 34, SB[3]) c:px(22, 35, SB[2]) c:px(22, 34, SB[3])
c:px(20, 33, "#2b1c26") c:px(22, 33, "#2b1c26")
-- slime trail
for _, p in ipairs{ {24,43},{24,45},{25,47},{24,49},{25,50} } do c:px(p[1], p[2], "#b8e0ec") end
-- grass tufts at base
for i = 0, 15 do
  local x = 5 + i * 3.4
  local h = 2 + floor(X.hash(i, 1, 4) * 3)
  for k = 0, h do c:px(floor(x), 55 - k, GR[2 + (k % 3) + (i % 2)]) end
  c:px(floor(x) + 1, 55, GR[2]) c:px(floor(x) + 1, 56, GR[1])
end
for x = 5, 56 do c:px(x, 56, (x % 5 == 0) and GR[2] or GR[1]) end
fin(c, "picket-fence")
