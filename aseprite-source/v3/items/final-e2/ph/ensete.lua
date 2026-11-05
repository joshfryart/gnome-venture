-- ensete (lean E2_00)
local NAME = "ensete"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.86 }
local function shade(m, ramp, R, tok, amb, wrap)
  local n = X.pillow(m, R)
  return X.tone(c, m, X.light(n, { amb = amb or 0.08, wrap = wrap or 0.22 }), ramp, { cuts = CUTS, tok = tok }), n
end
local function hx(h) return tonumber(h:sub(2,3),16), tonumber(h:sub(4,5),16), tonumber(h:sub(6,7),16) end
local function mix(a, b, t) local r1,g1,b1 = hx(a) local r2,g2,b2 = hx(b)
  return string.format("#%02x%02x%02x", floor(r1+(r2-r1)*t+.5), floor(g1+(g2-g1)*t+.5), floor(b1+(b2-b1)*t+.5)) end
local function ramp6(base) return { mix(base,"#1c1020",.62), mix(base,"#2a1428",.36), mix(base,"#2a1428",.14), base, mix(base,"#fff2b0",.3), mix(base,"#fff8e0",.6) } end
c:groundShadow(32, 57, 15, 3)
local LEAF = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" }
local RIB, RIB2 = "#a8344a", "#e0607a"
local function paddle(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t * 0.95 + 0.05)
    return max(0.6, w * sin(pi * u ^ 0.8) ^ 0.6)
  end, { fold = 0.3 })
  local tok = { r = { name = "lf" .. ax } }
  G.toneN(c, m, n, LEAF, { tok = tok, cuts = CUTS, amb = 0.1, wrap = 0.22 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.1 and t < 0.92 then c:put(x, y, s <= 0 and RIB2 or RIB, tok) return end
    for _, vt in ipairs{ 4, 8, 12, 16, 20, 24, 28 } do
      local d = t * L - (vt + abs(s) * 4)
      if d > -0.5 and d < 0.5 and abs(s) > 0.2 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], tok) return end
    end
  end)
  return m
end
paddle(30, 31, 13, 4, 10, 27, 6.5)
local R = paddle(34, 31, 52, 4, 54, 25, 6.5)
-- furled new leaf
local fm, fn = G.tube({ {32,33}, {31,24}, {33,15}, {32,8} }, function(t) return 2.2 - 1.2 * t end)
local FL = { "#3c6a30", "#5a9040", "#82b84e", "#b0d870", "#d4ee98", "#f0fcc0" }
local ft = { r = { name = "furl" } }
X.tone(c, fm, X.light(fn, { amb = 0.1, wrap = 0.25 }), FL, { cuts = CUTS, tok = ft })
for y = 9, 30, 4 do c:put(31, y, FL[2], ft) c:put(32, y + 1, FL[2], ft) end
c:put(32, 8, "#a8344a", ft) c:put(32, 9, "#a8344a", ft)
-- swollen pseudostem
local st = c:ellipse(32, 49, 13, 9)
st:add(c:poly{{26,47},{28,30},{36,30},{38,47}})
local SR = { "#3c5a3a", "#5d8449", "#86a95a", "#b0c978", "#d3e09a", "#eef3c0" }
local tok = { r = { name = "stem" } }
local idx = shade(st, SR, 8, tok, 0.1, 0.25)
st:each(function(x, y) local k = K(x, y)
  for _, ry in ipairs{ 36, 42 } do local yy = ry + floor(abs(x - 32) * 0.18) if y == yy then c:put(x, y, SR[max(1, idx[k] - 2)], tok) end end
  if (x == 29 or x == 35 or x == 24 or x == 40) and y > 31 and y < 56 and (y % 5 ~= 0) then c:put(x, y, "#8a3040", tok) end
end)
for _, p in ipairs{ {28,29},{29,29},{30,29},{34,29},{35,29},{36,29} } do c:put(p[1], p[2], SR[2], tok) end
for _, p in ipairs{ {26,44},{27,45},{27,43} } do c:put(p[1], p[2], SR[6], tok) end
-- quirk: a dewdrop on the right leaf
local dm = c:ellipse(50, 13, 2, 2)
local DT = { r = { name = "dew" } }
dm:each(function(x, y) c:put(x, y, "#7fc4d8", DT) end)
c:put(50, 14, "#3c7a98", DT) c:put(51, 14, "#3c7a98", DT) c:put(49, 12, "#f4fdff", DT)
G.save(c, NAME)
