-- feast-egg-pie (lean E2_00)
local NAME = "feast-egg-pie"
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
c:groundShadow(32, 56, 25, 4)
local SIDE = { "#4a2412", "#74401e", "#9c5e2c", "#c08440", "#dca85a", "#f0c880" }
local body = c:ellipse(32, 42, 22, 12)
body:add(c:rect(10, 30, 54, 42))
body:add(c:ellipse(32, 30, 22, 12))
local st = { r = { name = "side" } }
body:each(function(x, y) local t = (y - 30) / 24 local i = t > 0.7 and 1 or (t > 0.5 and 2 or (t > 0.25 and 3 or 4))
  if x < 18 then i = min(6, i + 1) end if x > 48 then i = max(1, i - 1) end
  if X.hash(x, y, 4) > 0.9 then i = min(6, i + 1) end
  c:put(x, y, SIDE[i], st) end)
for x = 11, 53, 4 do for y = 36, 46 do if body:has(x, y) and y % 3 == 0 then c:put(x, y, SIDE[2], st) end end end
local TOP = { "#7a4414", "#a8681c", "#cc8a2c", "#e4a63e", "#f4c45c", "#fde29a" }
local top = c:ellipse(32, 30, 22, 12)
local tt = { r = { name = "top" } }
shade(top, TOP, 14, tt, 0.15, 0.3)
-- fluted crimp along the rim
for a = 0, 2 * pi, 0.34 do
  local x, y = floor(32 + 20.5 * cos(a) + .5), floor(30 + 10.5 * sin(a) + .5)
  c:put(x, y, TOP[5], tt) c:put(x, y + 1, TOP[2], tt) c:put(x + 1, y, TOP[4], tt)
end
-- lattice strips
local inner = c:ellipse(32, 30, 17, 8)
for _, pl in ipairs{ {{12,38},{30,22}}, {{20,40},{40,22}}, {{34,42},{50,24}}, {{14,24},{34,40}}, {{30,20},{48,38}} } do
  c:line(pl, 2):each(function(x, y) if inner:has(x, y) then c:put(x, y, (x + y) % 5 == 0 and TOP[6] or TOP[5], tt) c:put(x, y + 1, TOP[2], tt) end end)
end
-- egg window
local win = c:ellipse(32, 30, 10, 5)
win:each(function(x, y) c:put(x, y, "#7a4414", tt) end)
local white = c:ellipse(32, 30, 9, 4)
white:each(function(x, y) c:put(x, y, y < 30 and "#fffaf0" or "#e8e0d0", { r = { name = "white" } }) end)
local yolk = c:ellipse(31, 30, 4, 3)
local yt = { r = { name = "yolk" } }
shade(yolk, { "#a8480c", "#d86a14", "#f08c1c", "#ffa828", "#ffc84a", "#ffe88c" }, 3, yt, 0.1, 0.3)
c:put(29, 28, "#fff6c8", yt) c:put(30, 28, "#fff6c8", yt)
-- quirk: a yolk drip running down the front of the crust
local dt = { r = { name = "drip" } }
for y = 34, 41 do c:put(38, y, "#ffa828", dt) end
c:put(37, 42, "#ffa828", dt) c:put(38, 42, "#ffa828", dt) c:put(39, 42, "#ffa828", dt) c:put(38, 43, "#d86a14", dt) c:put(38, 36, "#ffe88c", dt)
G.save(c, NAME)
