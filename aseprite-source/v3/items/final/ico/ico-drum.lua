-- ico-drum (final pass, Opus single pass). Bold icon: a red lacquered tom drum seen slightly from above, with two
-- slim birch drumsticks crossed over the head. Shell: per-pixel vertical-cylinder light, 6-tone red lacquer, one
-- vertical specular streak + cream glint, cool bounce on the right. Wooden hoops top and bottom with bevel rows and
-- grain flecks, AO where hoop meets shell. Cream hide head with a darker worn patch where it gets hit and a dark
-- ring under the hoop. Gold tension cord zigzags hoop to hoop with a twist (alternating tones) and knot nubs.
-- Sticks: 3 px cylinders with grain line, bead tips, contact shadow on the head.
-- quirk: one cord end has come loose and dangles with a frayed tassel.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/../_helpers/_aA3_5.lua")
local HP, X, K = T.HP, T.X, T.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = T.new("ico-drum")
local RED  = { "#4e1830", "#7e2034", "#b02c36", "#d8443a", "#f0704a", "#ffb07a" }
local HOOP = { "#3e2420", "#64382a", "#8e5634", "#b8783e", "#dca05a", "#f6d08a" }
local HIDE = { "#8a6458", "#b89478", "#d8b894", "#ecd4ae", "#f8e8c6", "#fff4d6" }
local CORD = { "#7a4420", "#c27e2a", "#f0bc4a", "#ffe490" }
local STK  = { "#4a2a24", "#7a4228", "#a8602e", "#cc843c", "#e8aa58", "#fbd488" }
local tk = function(n) return { r = { name = n } } end

local CX, RX, RY = 32, 17, 5.5
local YT, YB = 26, 47                      -- top and bottom rim ellipse centres
local function ef(x) local u = (x - CX) / (RX + 0.4) return u, RY * sqrt(max(0, 1 - u * u)) end

c:groundShadow(CX + 1, YB + RY + 1.5, RX + 3, 2)

-- masks
local shell, hoopT, hoopB, rimTop = HP.mask(), HP.mask(), HP.mask(), HP.mask()
for x = CX - RX, CX + RX do
  local u, e = ef(x)
  local ytf, ybf = floor(YT + e + 0.5), floor(YB + e + 0.5)
  for y = ytf + 1, ytf + 3 do hoopT:set(x, y) end
  for y = ytf + 4, ybf - 3 do shell:set(x, y) end
  for y = ybf - 2, ybf do hoopB:set(x, y) end
  for y = floor(YT - e + 0.5), ytf do rimTop:set(x, y) end
end
local head = c:ellipse(CX, YT, RX - 1.5, RY - 1.2)

-- vertical-cylinder normals; band = bevel tilt per row (top row faces up, bottom row faces down)
local function cylN(m, rowTilt)
  local n = {}
  m:each(function(x, y) local u = ef(x)
    local ny = rowTilt and rowTilt(x, y) or 0
    n[K(x, y)] = { T.norm(u * 0.95, ny, sqrt(max(0.04, 1 - u * u))) } end)
  return n
end
local CC = { 0.18, 0.34, 0.52, 0.72, 0.9 }

-- shell
local sb = {}
X.ao(sb, shell, hoopT, 1, -1) X.ao(sb, shell, hoopB, 1, -1)
local sn = cylN(shell)
local sidx = T.shade(c, shell, sn, RED, { amb = 0.05, wrap = 0.15, bias = sb, tok = tk("shell"), cuts = CC })
-- lacquer specular: vertical streak on the lit third, one cream glint near the top
shell:each(function(x, y) if x == CX - 10 and (y > 33 and y < 46) then c:put(x, y, RED[6]) end
  if x == CX - 9 and (y > 35 and y < 43) then c:put(x, y, RED[5]) end end)
c:put(CX - 10, 32, T.CREAM) c:put(CX - 10, 33, T.CREAM)
-- cool bounce up the right edge
shell:each(function(x, y) if x == CX + RX and y > 33 and y < 48 then c:put(x, y, "#7a3a6e") end end)

-- hoops (wood): bevel rows + grain flecks
local function hoop(m, name, which)
  local yTop = {}
  m:each(function(x, y) yTop[x] = min(yTop[x] or 99, y) end)
  local n = cylN(m, function(x, y) local r = y - yTop[x] return r == 0 and -0.55 or (r == 2 and 0.5 or 0) end)
  local idx = T.shade(c, m, n, HOOP, { amb = 0.06, wrap = 0.2, tok = tk(name), cuts = CC })
  m:each(function(x, y) if y - yTop[x] == 1 and T.X.hash(x, which, 7) > 0.72 and (idx[K(x, y)] or 1) >= 3 then
    T.step(c, idx, HOOP, x, y, -1, tk(name)) end end)
  return idx
end
hoop(hoopB, "hoopB", 2)
-- top: back rim ring visible around the head, then the front band
local rring = rimTop:copy():cut(head)
local rn = {}
rring:each(function(x, y) rn[K(x, y)] = { T.norm((x - CX) / RX * 0.5, (y < YT) and 0.55 or -0.4, 0.8) } end)
T.shade(c, rring, rn, HOOP, { amb = 0.08, wrap = 0.2, tok = tk("rim"), cuts = CC })
hoop(hoopT, "hoopT", 1)

-- hide head: flat, lit; dark ring under the hoop lip; worn patch where the sticks land
local hn = {}
head:each(function(x, y) local dx, dy = (x - CX) / RX, (y - YT) / RY
  hn[K(x, y)] = { T.norm(dx * 0.35, -0.75 + dy * 0.2, 0.75) } end)
local hb = {}
X.ao(hb, head, rring, 1, -1)
local hidx = T.shade(c, head, hn, HIDE, { amb = 0.2, wrap = 0.3, bias = hb, tok = tk("head"), cuts = { 0.3, 0.5, 0.66, 0.8, 0.93 } })
local worn = c:ellipse(CX + 1, YT + 0.5, 4.5, 1.6)
worn:each(function(x, y) if head:has(x, y) and X.hash(x, y, 3) > 0.25 then T.step(c, hidx, HIDE, x, y, -1, tk("head")) end end)
-- tack heads along the front hoop band (tiny gold studs)
for _, u in ipairs{ -0.7, -0.35, 0, 0.35, 0.7 } do
  local x = floor(CX + u * RX + 0.5) local _, e = ef(x)
  c:put(x, floor(YT + e + 0.5) + 2, CORD[4])
end

-- tension cord: zigzag between hoops, twist = alternating tones, darker toward the shade side, knots at the turns
local tops, bots = {}, {}
local us = { -0.86, -0.43, 0, 0.43, 0.86 }
for i, u in ipairs(us) do local x = floor(CX + u * RX + 0.5) local _, e = ef(x)
  tops[i] = { x, floor(YT + e + 0.5) + 4 } bots[i] = { x, floor(YB + e + 0.5) - 3 } end
local function cord(a, b)
  local nS = max(abs(b[1] - a[1]), abs(b[2] - a[2]))
  for i = 0, nS do local t = i / nS
    local x, y = floor(a[1] + (b[1] - a[1]) * t + .5), floor(a[2] + (b[2] - a[2]) * t + .5)
    local u = (x - CX) / RX
    local lit = (i % 3 == 0) and 1 or 0
    local base = u < -0.2 and 3 or (u < 0.45 and 2 or 2)
    local tone = min(4, base + lit)
    if u > 0.45 then tone = (i % 3 == 0) and 3 or 2 end
    c:put(x, y, CORD[tone], tk("cord"))
    -- contact shadow on the shell just right of the cord
    if shell:has(x + 1, y) and c:get(x + 1, y) ~= CORD[1] then
      local k = K(x + 1, y) if sidx[k] and sidx[k] > 1 then c:put(x + 1, y, RED[max(1, sidx[k] - 1)]) end end
  end
end
for i = 1, #us - 1 do cord(tops[i], bots[i + 1]) cord(bots[i], tops[i + 1]) end
for i = 1, #us do
  for _, p in ipairs{ tops[i], bots[i] } do
    c:put(p[1], p[2], CORD[3], tk("cord")) c:put(p[1] + 1, p[2], CORD[2], tk("cord"))
  end
end

-- sticks: crossed over the head, bead tips up, lower ends resting on the hide
local function stick(ax, ay, bx, by, name)
  local m, n = X.cyl(ax, ay, bx, by, function(t) return 1.45 - 0.25 * t end)
  local idx = T.shade(c, m, n, STK, { amb = 0.08, wrap = 0.25, tok = tk(name), cuts = CC })
  -- grain: one darker dash pattern along the shade side of centre
  local len = sqrt((bx - ax) ^ 2 + (by - ay) ^ 2)
  for i = 3, floor(len) - 2 do local t = i / len
    if X.hash(i, ay, 11) > 0.55 then
      local x, y = floor(ax + (bx - ax) * t + 0.9), floor(ay + (by - ay) * t + 0.5)
      if m:has(x, y) then T.step(c, idx, STK, x, y, -1, tk(name)) end
    end
  end
  local bm, bn = T.oval(ax, ay, 2.4, 2.4, 0)
  T.shade(c, bm, bn, STK, { amb = 0.06, wrap = 0.2, tok = tk(name .. "b"), cuts = CC })
  c:put(floor(ax - 1), floor(ay - 1), STK[6])
  -- contact shadow on the head where the end rests
  for dx = -2, 2 do local x, y = floor(bx + dx + 0.5), floor(by + 1.5)
    if head:has(x, y) then local k = K(x, y) if hidx[k] then T.step(c, hidx, HIDE, x, y, -2, tk("head")) end end end
  return m
end
stick(45, 10, 21, 28, "stickB")
local am = stick(19, 10, 43, 28, "stickA")
-- AO where stick A crosses over B
am:grow(1):each(function(x, y) if not am:has(x, y) and y > 11 and y < 26 then
  local h = c:get(x, y) for i = 2, 6 do if h == STK[i] and abs(x - 32) < 4 then c:put(x, y, STK[i - 1]) break end end end end)

-- quirk: a loose cord end dangling from the lower-right knot, frayed into a 3-strand tassel
local kx, ky = bots[#us][1], bots[#us][2]
local dang = { { kx + 1, ky + 1 }, { kx + 2, ky + 2 }, { kx + 2, ky + 3 }, { kx + 3, ky + 4 }, { kx + 3, ky + 5 } }
for i, p in ipairs(dang) do c:put(p[1], p[2], CORD[(i % 2 == 0) and 3 or 2], tk("tassel")) end
T.map(c, { "abc", "a.c", "a..", }, kx + 2, ky + 6, { a = CORD[2], b = CORD[3], c = CORD[1] }, tk("tassel"))
T.save(c, "ico-drum", "ico")
