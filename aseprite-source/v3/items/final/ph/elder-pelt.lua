-- elder-pelt (lean E2_00)
local NAME = "elder-pelt"
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
c:groundShadow(32, 54, 18, 3)
local RAMP = { "#34334a", "#56566f", "#7d7e98", "#a4a6bc", "#cbcddc", "#eef0f8" }
local m = c:ellipse(32, 31, 12, 15)
m:add(c:line({{26,21},{15,16}}, 5)) m:add(c:line({{38,21},{49,16}}, 5))
m:add(c:line({{26,41},{14,46}}, 5)) m:add(c:line({{38,41},{50,46}}, 5))
m:add(c:line({{32,18},{32,10}}, 8)) m:add(c:ellipse(32,9,5,4))
m:add(c:ellipse(26,5,2,2)) m:add(c:ellipse(38,5,2,2))
m:add(c:line({{32,44},{33,52},{35,57}}, 5))
local tok = { r = { name = "pelt" } }
local idx = shade(m, RAMP, 7, tok, 0.12, 0.3)
m:each(function(x, y) local k = K(x, y) local i = idx[k]
  local h = X.hash(x, y, 7)
  if h > 0.82 and i >= 2 and i <= 5 then c:put(x, y, RAMP[i + 1], tok) if m:has(x, y + 1) then c:put(x, y + 1, RAMP[max(1, i - 1)], tok) end end
  if h < 0.07 and i >= 3 then c:put(x, y, RAMP[i - 1], tok) end
end)
m:edge():each(function(x, y) if X.hash(x, y, 3) > 0.6 then c:put(x, y, RAMP[2], tok) end end)
for y = 15, 44 do if y % 2 == 0 then c:put(32, y, RAMP[2], tok) c:put(31 + (y % 4 == 0 and 2 or 0), y, RAMP[3], tok) end end
-- eyes shut, nose
c:put(30, 9, "#2b1c26", tok) c:put(34, 9, "#2b1c26", tok) c:put(32, 12, "#6a4a58", tok) c:put(31, 12, "#6a4a58", tok)
-- tail tip dark
for _, p in ipairs{ {35,56},{34,56},{35,55},{35,57} } do if m:has(p[1], p[2]) then c:put(p[1], p[2], RAMP[1], tok) end end
-- quirk: mended tear with red thread stitches
for i = 0, 6 do c:put(37 + floor(i * 0.7), 26 + i, "#2f2a3c", tok) end
for _, p in ipairs{ {36,27},{37,29},{39,31},{40,33} } do c:put(p[1], p[2], "#d8453a", tok) c:put(p[1] + 3, p[2] - 1, "#d8453a", tok) end
G.save(c, NAME)
