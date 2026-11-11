---------------------------------------------------------------- W1: ramps, helpers
local NITE = {"#150f2a","#241a48","#352a68","#4a3c8c","#6e5cb4","#9a88d8"}
local INDG = {"#14143a","#232a68","#34428c","#4a62b0","#7a8ed4","#a8b8ec"}
local ORNG = {"#5a2410","#9a4416","#d4741c","#f0a030","#ffc850","#ffe890"}
local CHZ  = {"#6a4a10","#a87818","#d8a828","#f0c840","#f8de70","#fff0a8"}
local COPPER = {"#3a1a10","#7a3418","#b8602c","#d88848","#f0b070","#ffe0a8"}
local SAND = {"#97754a","#b8935e","#d0b078","#e8d09a","#f0dcaa","#f8e8bc"}
local SANDT = {"#6a502e","#8a6a34","#a8863c","#c2a04a","#d8b862","#e8cc7c"}
local PR, OVL = {}, {}
local GYK = { cottage = 205, burrow = 206, treehouse = 207, hut = 206, stone = 207, boat = 203 }
local function inn(m, x, y) return m:has(x, y) and m:has(x, y - 2) and m:has(x - 1, y) end
local function gsh(x, gy, w) c:ellipse(x, gy, w, 2):each(function(xx, yy) local cur = c:get(xx, yy); if cur and cur ~= INK then P(xx, yy, mixc(cur, "#2a1830", .3)) end end) end
local function bx(x0, y0, x1, y1, ramp)
  local m = rect(x0, y0, x1, y1); c:rim(m, INK)
  m:each(function(x, y) local t = 4
    if y == y0 then t = 6 elseif y == y0 + 1 then t = 5 elseif y >= y1 then t = 2 elseif x >= x1 - 1 then t = 3 elseif x == x0 then t = 5 end
    P(x, y, ramp[t]) end)
  return m
end
local function ball(cx, cy, r, ramp)
  local m = c:ellipse(cx, cy, r, r); c:rim(m, INK)
  m:each(function(x, y) local l = lit(x, y, cx, cy, r); P(x, y, ramp[l > .6 and 6 or (l > .15 and 5 or (l > -.4 and 4 or 3))]) end)
  return m
end
local function pole(x0, y0, x1, y1, w, ramp)
  local m = c:line({ { x0, y0 }, { x1, y1 } }, w); c:rim(m, INK)
  m:each(function(x, y)
    local cxx = (y1 ~= y0) and (x0 + (x1 - x0) * (y - y0) / (y1 - y0)) or (x0 + x1) / 2
    P(x, y, x < cxx - .5 and ramp[5] or (x > cxx + .5 and ramp[3] or ramp[4]))
  end)
  return m
end
local function leafp(cx, cy, rx, ry, ramp)
  local m = c:ellipse(cx, cy, rx, ry); c:rim(m, INK)
  m:each(function(x, y) P(x, y, (y < cy and x < cx) and ramp[5] or ((y > cy and x >= cx) and ramp[3] or ramp[4])) end)
  return m
end
local function tri(x1, y1, x2, y2, x3, y3, col, rim)
  x1, y1, x2, y2, x3, y3 = floor(x1), floor(y1), floor(x2), floor(y2), floor(x3), floor(y3)
  local m = HP.mask()
  local function sg(px, py, ax, ay, bx_, by_) return (px - bx_) * (ay - by_) - (ax - bx_) * (py - by_) end
  for y = min(y1, y2, y3), max(y1, y2, y3) do for x = min(x1, x2, x3), max(x1, x2, x3) do
    local d1, d2, d3 = sg(x, y, x1, y1, x2, y2), sg(x, y, x2, y2, x3, y3), sg(x, y, x3, y3, x1, y1)
    if not ((d1 < 0 or d2 < 0 or d3 < 0) and (d1 > 0 or d2 > 0 or d3 > 0)) then m:set(x, y) end
  end end
  if rim ~= false then c:rim(m, INK) end
  if col then c:fillMask(m, col) end
  return m
end
local function stem(x0, y0, x1, y1, ramp)
  local m = c:line({ { x0, y0 }, { x1, y1 } }, 1); c:rim(m, INK); c:fillMask(m, (ramp or GREEN)[4])
end
local function clover(cx, cy, s, ramp)
  local m = c:ellipse(cx - s, cy, s, s)
  m:add(c:ellipse(cx + s, cy, s, s)):add(c:ellipse(cx, cy - s, s, s)):add(c:ellipse(cx, cy + s, s, s))
  c:rim(m, INK)
  m:each(function(x, y) local l = lit(x, y, cx, cy, s * 2); P(x, y, ramp[l > .3 and 5 or (l > -.3 and 4 or 3)]) end)
  P(cx, cy, ramp[2]); P(cx - s, cy - s, ramp[6])
end
local function sflower(cx, cy, r, pet, ctr)
  for k = 0, 7 do local a = k * .785; ball(floor(cx + cos(a) * r * .9 + .5), floor(cy + sin(a) * r * .9 + .5), max(2, floor(r * .45)), pet) end
  ball(cx, cy, floor(r * .62), ctr)
  for k = 0, 5 do local a = k * 1.05; P(floor(cx + cos(a) * r * .3 + .5), floor(cy + sin(a) * r * .3 + .5), ctr[6]) end
end
local function bloom(cx, cy, r, pet, ctr)
  for k = 0, 11 do local a = k * .5236; ball(floor(cx + cos(a) * r + .5), floor(cy + sin(a) * r + .5), max(2, floor(r * .42)), pet) end
  ball(cx, cy, floor(r * .6), ctr)
  for k = 0, 6 do local a = k * .9; P(floor(cx + cos(a) * r * .3 + .5), floor(cy + sin(a) * r * .3 + .5), ctr[6]) end
end
local function bunting(x1, y1, x2, y2, cols)
  local n = 6
  local function ry(x) local t = (x - x1) / (x2 - x1); return floor(y1 + (y2 - y1) * t + sin(t * 3.14159) * 6) end
  for x = x1, x2 do P(x, ry(x) + 1, INK); P(x, ry(x), DIRT[5]) end
  for i = 0, n do
    local fx = floor(x1 + (x2 - x1) * (i + .5) / (n + 1)); local fy = ry(fx) + 2
    tri(fx - 3, fy, fx + 3, fy, fx, fy + 8, cols[i % #cols + 1])
  end
end
local function lamp(cx, cy, style, col)
  col = col or REDW
  local ax = cx + 12
  c:fillMask(rect(ax - 1, cy - 22, ax + 1, cy - 8), INK); c:fillMask(rect(ax, cy - 21, ax, cy - 9), IRON[4])
  for x = cx, ax do P(x, cy - 17, INK); P(x, cy - 16, IRON[4]) end
  for y = cy - 15, cy - 9 do P(cx, y, (y % 2 == 0) and IRON[3] or IRON[5]) end
  if style == "paper" then
    S.glow(cx, cy + 2, 26, "#ffb070", .5)
    local m = c:ellipse(cx, cy, 6, 8); c:rim(m, INK)
    m:each(function(x, y) local l = lit(x, y, cx, cy, 8); P(x, y, col[l > .4 and 6 or (l > -.2 and 5 or 4)]) end)
    for dy = -6, 6, 4 do for x = cx - 6, cx + 6 do if m:has(x, cy + dy) then P(x, cy + dy, col[2]) end end end
    c:fillMask(rect(cx - 2, cy - 10, cx + 2, cy - 8), INK); P(cx - 3, cy - 3, "#fff6cc"); P(cx - 3, cy - 2, "#fff6cc")
    P(cx, cy + 9, INK); P(cx, cy + 10, col[5]); P(cx, cy + 11, col[5]); P(cx, cy + 12, INK)
  elseif style == "orb" then
    S.glow(cx, cy + 2, 26, "#c8a0ff", .5)
    ball(cx, cy, 6, VIO); c:fillMask(c:ellipse(cx, cy, 3, 3), "#f4ecff"); P(cx - 2, cy - 2, "#ffffe8")
    c:fillMask(rect(cx - 4, cy + 6, cx + 4, cy + 7), INK); c:fillMask(rect(cx - 3, cy + 6, cx + 3, cy + 6), IRON[4])
    c:fillMask(rect(cx - 2, cy - 10, cx + 2, cy - 8), INK)
  else   -- jar of fireflies
    S.glow(cx, cy + 2, 26, "#d8ff90", .5)
    local m = rect(cx - 4, cy - 6, cx + 4, cy + 7); c:rim(m, INK)
    m:each(function(x, y) P(x, y, (x < cx - 1) and "#f4ffd0" or ((x > cx + 2) and "#a8d870" or "#d8f890")) end)
    for _, q in ipairs{ { -2, -3 }, { 2, 0 }, { -1, 3 }, { 3, -4 } } do P(cx + q[1], cy + q[2], "#fffbe0"); P(cx + q[1] + 1, cy + q[2], "#f4d848") end
    c:fillMask(rect(cx - 5, cy - 9, cx + 5, cy - 7), INK); c:fillMask(rect(cx - 4, cy - 8, cx + 4, cy - 8), IRON[5])
  end
end

---------------------------------------------------------------- door shapes / finishing
local function DP(p, d)
  local o = {}
  for k, v in pairs(d) do o[k] = v end
  o.shape = p.shape or o.shape; o.frame = p.frame or o.frame; o.wood = p.wood or o.wood
  if p.fw then o.f = p.fw end
  if p.straps ~= nil then o.straps = p.straps and (d.straps or { 150, 186 }) or nil end
  if p.woven ~= nil then o.woven = p.woven end
  if p.blocks ~= nil then o.blocks = p.blocks end
  if p.hw then local cx = (d.x0 + d.x1 + 1) / 2; o.x0 = floor(cx - p.hw); o.x1 = floor(cx + p.hw) - 1 end
  if p.dx0 then o.x0 = p.dx0; o.x1 = p.dx1 end
  if p.dy0 then o.y0 = p.dy0 end
  if p.kx then o.kx = p.kx end
  if p.ky then o.ky = p.ky end
  if p.seed then o.seed = p.seed end
  if p.ov then o.ovl = function(m) local ok, err = pcall(OVL[p.ov], m, p); if not ok then print("OVL ERR " .. p.slug .. ": " .. tostring(err)) end end end
  return o
end
local function FIN(p, DM, ldef)
  local gyk = GYK[p.kind]
  for _, pr in ipairs(p.props or {}) do
    local f, x, gy = PR[pr[1]], pr[2], gyk
    if p.kind == "boat" and x > 345 then gy = 200 end
    if f then local ok, err = pcall(f, x, gy, pr[3]); if not ok then print("PROP ERR " .. p.slug .. " " .. pr[1] .. ": " .. tostring(err)) end
    else print("PROP MISSING " .. pr[1]) end
  end
  local st = p.lant or ((ldef and ldef.post) and "post" or "hang")
  if st == "hang" then lantern(300, 120, ldef) elseif st == "post" then lantern(300, 120, { post = { TIMB, 206 } }) else lamp(300, 120, st, p.lcol) end
end
