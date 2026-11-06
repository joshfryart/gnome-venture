-- reef-fish (final, Sonnet high, D12-1). A slim clownfish swimming left, body bent in a gentle S so the tail kicks up:
-- cylinder-lit orange body, three white bands that follow the curve with fine dark edge lines, a long dorsal fin with a
-- spiny front and soft rear, pectoral and anal fins and a round fanned tail all with ray lines and a dark-red margin,
-- gold-ringed eye, gill arc, lit lip, cool violet bounce on the belly.
-- quirk: the fish carries a little pearl in its lips like a shiny snack.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_1.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new("reef-fish")
local ORG = { "#6a2236", "#a8341f", "#d84e1e", "#f2701c", "#fb9a34", "#ffc870" }
local FIN = { "#7a2a24", "#b8401c", "#e0601c", "#f58c28", "#ffb04c", "#ffdc90" }
local WHT = { "#6a6e98", "#9aa0c4", "#c8cee4", "#e8ecf4", "#f8f6f0", "#fffaf0" }
local PRL = { "#6a7090", "#9aa4c0", "#c8d0e4", "#e8ecf6", "#f8f8fc", "#fffaf0" }
local EDGE, MARGIN, COOL = "#3a1a2c", "#7a2420", "#b0404c"
local P = { { 12, 38 }, { 23, 43 }, { 35, 38 }, { 46, 31 } }
local function wfn(t)
  local w = 7.0 * sin(pi * min(1, t ^ 0.82)) ^ 0.7
  if t < 0.06 then w = max(w, 1.6 + t * 20) end
  return max(w, 1.9)
end
local body, bn, BT, BS, samples = G.tube(P, wfn, 200)
local function at(t) local x, y = G.bez(P, t) local x2, y2 = G.bez(P, min(1, t + 0.01)) local x1, y1 = G.bez(P, max(0, t - 0.01))
  local tx, ty = x2 - x1, y2 - y1 local l = sqrt(tx * tx + ty * ty) tx, ty = tx / l, ty / l
  local px, py = -ty, tx if px + py < 0 then px, py = -px, -py end
  return x, y, tx, ty, px, py end

-- tail fan (behind body)
local ex, ey, etx, ety = at(1)
local tail = HP.mask()
for y = floor(ey) - 16, floor(ey) + 16 do for x = floor(ex) - 4, floor(ex) + 17 do
  local dx, dy = x - ex, y - ey
  local al, pp = dx * etx + dy * ety, -dx * ety + dy * etx
  if al >= -1.5 and al <= 14 then
    local h = al <= 9 and (1.6 + 0.66 * max(0, al)) or (1.6 + 0.66 * 9) * sqrt(max(0, 1 - ((al - 9) / 5.2) ^ 2))
    if abs(pp) <= h then tail:set(x, y) end
  end
end end
tail:cut(body)
local tn = X.pillow(tail, 3.2, 0.8)
local tidx = A.shade(c, tail, tn, FIN, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.88 }, amb = 0.12, wrap = 0.35 })
-- tail rays + margin
tail:each(function(x, y) local k = K(x, y)
  local dx, dy = x - ex, y - ey
  local al, pp = dx * etx + dy * ety, -dx * ety + dy * etx
  if al > 2 then
    local a = atan(pp, al)
    local f = (a * 9.0) % 1
    if f < 0.2 then c:px(x, y, FIN[max(1, (tidx[k] or 3) - 1)]) end
  end
end)
tail:edge():each(function(x, y) end)
tail:each(function(x, y) if not tail:has(x + 1, y) or not tail:has(x, y + 1) or not tail:has(x - 1, y) or not tail:has(x, y - 1) then
  local dx, dy = x - ex, y - ey if dx * etx + dy * ety > 3 then c:px(x, y, MARGIN) end end end)

-- dorsal fin (behind body): spiny front, soft taller rear
local up, dn = {}, {}
for i = 0, 28 do
  local t = 0.14 + i / 28 * 0.66
  local x, y, tx, ty, px, py = at(t)
  local w = wfn(t)
  local hf = 3.6 + 3.0 * sin(pi * min(1, (t - 0.12) / 0.7)) ^ 0.8
  if t > 0.5 then hf = hf * (1 - (t - 0.5) * 0.25) end
  up[#up + 1] = { floor(x - px * (w + hf) + .5), floor(y - py * (w + hf) + .5) }
  dn[#dn + 1] = { floor(x - px * (w - 1.5) + .5), floor(y - py * (w - 1.5) + .5) }
end
local poly = {}
for i = 1, #dn do poly[#poly + 1] = dn[i] end
for i = #up, 1, -1 do poly[#poly + 1] = up[i] end
local dors = c:poly(poly)
dors:cut(body)
local dn2 = X.pillow(dors, 2.6, 0.8)
local didx = A.shade(c, dors, dn2, FIN, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.88 }, amb = 0.12, wrap = 0.35 })
for i = 2, #up, 3 do
  local u, d = up[i], dn[i]
  local ln = HP.mask() A.lineMask(ln, d[1], d[2], u[1], u[2]) ln:clip(dors)
  ln:each(function(x, y) c:px(x, y, FIN[max(1, (didx[K(x, y)] or 3) - 1)]) end)
end
dors:each(function(x, y) if body:has(x, y) then return end end)
-- clip rays to the fin
dors:each(function(x, y) end)
-- anal / ventral fin (behind body)
local anal = HP.mask()
do
  local pts = {}
  for i = 0, 8 do
    local t = 0.5 + i / 8 * 0.3
    local x, y, tx, ty, px, py = at(t)
    local w = wfn(t)
    local hf = 2.6 * sin(pi * i / 8) ^ 0.6 + 0.6
    pts[#pts + 1] = { floor(x + px * (w + hf) + .5), floor(y + py * (w + hf) + .5) }
  end
  local x, y, tx, ty, px, py = at(0.8) pts[#pts + 1] = { floor(x + px * (wfn(0.8) - 1) + .5), floor(y + py * (wfn(0.8) - 1) + .5) }
  x, y, tx, ty, px, py = at(0.5) table.insert(pts, 1, { floor(x + px * (wfn(0.5) - 1) + .5), floor(y + py * (wfn(0.5) - 1) + .5) })
  anal:add(c:poly(pts))
end
anal:cut(body)
A.shade(c, anal, X.pillow(anal, 2.2, 0.8), FIN, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.88 }, amb = 0.1, wrap = 0.3 })
anal:each(function(x, y) if not anal:has(x, y + 1) then c:px(x, y, MARGIN) end end)

-- body
local bias = {}
local bidx = A.shade(c, body, bn, ORG, { cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 }, amb = 0.1, wrap = 0.28 })
-- cool bounce on the belly edge
body:each(function(x, y) local k = K(x, y) if BS[k] > 0.8 and BT[k] > 0.1 and BT[k] < 0.9 then c:px(x, y, COOL) end end)
-- white bands with dark edge lines
local bands = { { 0.225, 0.28 }, { 0.465, 0.54 }, { 0.78, 0.83 } }
local function inband(k) for _, b in ipairs(bands) do if BT[k] >= b[1] and BT[k] <= b[2] then return true end end return false end
body:each(function(x, y) local k = K(x, y)
  if inband(k) then
    local i = bidx[k] or 3
    c:px(x, y, WHT[max(1, min(6, i))])
  end
end)
body:each(function(x, y) local k = K(x, y)
  if not inband(k) then
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do
      local k2 = K(x + d[1], y + d[2])
      if body:has(x + d[1], y + d[2]) and inband(k2) then c:px(x, y, EDGE) break end
    end
  end
end)
-- spec streak along the back
do
  local sx, sy = G.specAt(body, bn, 18)
  if sx then c:px(sx, sy, "#fff0c0") c:px(sx + 1, sy, "#ffe0a0") c:px(sx + 2, sy + 0, "#ffd890") end
end

-- gill arc
do
  for i = 0, 10 do
    local s = -0.7 + i * 0.13
    local t = 0.185
    local x, y, tx, ty, px, py = at(t)
    local w = wfn(t)
    local xx, yy = floor(x + px * s * w + .5 - tx * (s * s * 1.4)), floor(y + py * s * w + .5 - ty * (s * s * 1.4))
    if body:has(xx, yy) and not inband(K(xx, yy)) then c:px(xx, yy, ORG[2]) end
  end
end
-- pectoral fin (over the body)
do
  local x, y, tx, ty, px, py = at(0.34)
  local fx, fy = x + px * 1.2, y + py * 1.2
  local pm = HP.mask()
  local ang = atan(ty, tx) + 0.5
  local ca, sa = cos(ang), sin(ang)
  for yy = floor(fy) - 7, floor(fy) + 7 do for xx = floor(fx) - 8, floor(fx) + 8 do
    local dx, dy = xx - fx, yy - fy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if u >= -1.5 and u <= 6.6 then
      local h = 0.5 + 0.65 * (u + 1.5) * (1 - (u + 1.5) / 11)
      if abs(v) <= h * 1.6 then pm:set(xx, yy) end
    end
  end end
  local pi_ = A.shade(c, pm, X.pillow(pm, 2, 0.8), FIN, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.88 }, amb = 0.12, wrap = 0.3 })
  pm:each(function(xx, yy) if not pm:has(xx + 1, yy) or not pm:has(xx, yy + 1) then c:px(xx, yy, MARGIN) end end)
  local rm = pm
  for r = -1, 1 do A.pline(c, { { floor(fx + .5), floor(fy + .5) }, { floor(fx + ca * 6 - sa * r * 2.2 + .5), floor(fy + sa * 6 + ca * r * 2.2 + .5) } }, FIN[2]) end
  pm:each(function(xx, yy) if not pm:has(xx + 1, yy) or not pm:has(xx, yy + 1) then c:px(xx, yy, MARGIN) end end)
  -- contact shadow of the fin on the body
  pm:shift(1, 1):each(function(xx, yy) if body:has(xx, yy) and not pm:has(xx, yy) and not inband(K(xx, yy)) then c:px(xx, yy, ORG[2]) end end)
end

-- eye: gold ring, ink pill, glint
do
  local x, y = at(0.1)
  local ex0, ey0 = floor(x - 0.3), floor(y - 3.0)
  for dy = -1, 3 do for dx = -1, 2 do
    local corner = (dx == -1 or dx == 2) and (dy == -1 or dy == 3)
    if not corner then c:px(ex0 + dx, ey0 + dy, "#ffd878") end
  end end
  c:eyeSmall(ex0, ey0)
end
-- mouth + lit lip
do
  local x, y = at(0.0)
  c:px(floor(x + 0.5), floor(y + 1.5), EDGE) c:px(floor(x + 1.5), floor(y + 2.5), EDGE)
  c:px(floor(x + 0.5), floor(y + 0.5), ORG[6])
end

-- quirk: a pearl held in the lips
do
  local x, y = at(0.0)
  local px0, py0 = floor(x - 3.2), floor(y + 1.8)
  local pm = c:ellipse(px0, py0, 2.0, 2.0)
  local pn = X.sphere(px0 - 0.3, py0 - 0.3, 2.0, pm)
  A.shade(c, pm, pn, PRL, { cuts = { 0.2, 0.4, 0.58, 0.74, 0.9 }, amb = 0.06, wrap = 0.2 })
  c:px(px0 - 1, py0 - 1, "#ffffff" == "x" and "" or "#fffaf0")
  pm:each(function(xx, yy) if body:has(xx + 1, yy) or body:has(xx, yy + 1) then c:px(xx, yy, PRL[2]) end end)
end
A.save(c, "reef-fish")
