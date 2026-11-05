-- feast-dunewhisper-pilaf (lean E2_00)
local NAME = "feast-dunewhisper-pilaf"
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
c:groundShadow(32, 57, 23, 3)
local TEAL = { "#14323f", "#1d4f5c", "#2a7480", "#3f98a0", "#6cbfb8", "#a8e0d0" }
local body = c:poly{{9,38},{55,38},{51,50},{44,56},{20,56},{13,50}}
local bt = { r = { name = "bowl" } }
shade(body, TEAL, 10, bt, 0.1, 0.2)
for x = 14, 50 do local ph = (x // 3) % 2
  c:put(x, 46 + ph, "#e8b84a", bt) c:put(x, 47 + ph, "#a8782c", bt)
  if ph == 0 and x % 6 == 0 then c:put(x, 45, "#fbe8a0", bt) end
end
local ring = c:ellipse(32, 38, 23, 4)
local rt = { r = { name = "rim" } }
shade(ring, { "#a8782c", "#d0a040", "#e8b84a", "#ecc860", "#fbe8a0", "#fff4c8" }, 4, rt, 0.2, 0.3)
-- dune mound
local RICE = { "#8a5a1c", "#b88428", "#dca83c", "#f0c860", "#fadc8c", "#fff0b8" }
local mound = c:poly{{11,39},{20,33},{27,25},{33,16},{37,21},{46,29},{53,39}}
local mt = { r = { name = "rice" } }
local ma = X.pillow(mound, 12)
mound:each(function(x, y) local k = K(x, y)
  local crest = 33 + (y - 16) * 0.08
  local lit = x < crest
  local i = lit and (x < 24 and 5 or 4) or (y > 31 and 2 or 3)
  if lit and y > 34 then i = 4 end
  if not lit and x > 47 then i = 2 end
  local h = X.hash(x, y, 9)
  if h > 0.84 then i = min(6, i + 1) elseif h < 0.1 then i = max(1, i - 1) end
  c:put(x, y, RICE[i], mt)
end)
-- wind ripples curving along the dune
for _, r in ipairs{ {18,36,26,34}, {22,32,28,29}, {26,27,30,24}, {38,36,46,34}, {41,30,46,32} } do
  for t = 0, 1, 0.08 do local x = floor(r[1] + (r[3] - r[1]) * t + .5) local y = floor(r[2] + (r[4] - r[2]) * t - sin(pi * t) * 1.5 + .5)
    if mound:has(x, y) then c:put(x, y, x < 33 and RICE[2] or RICE[1], mt) if x < 33 then c:put(x, y - 1, RICE[6], mt) end end end
end
for y = 17, 38 do local x = floor(33 + (y - 16) * 0.08 + .5) if mound:has(x, y) and y % 3 ~= 0 then c:put(x, y, "#fff6d0", mt) end end
-- garnish
local G1 = { r = { name = "garnish" } }
for _, p in ipairs{ {22,34},{29,30},{30,25},{25,37},{41,34},{44,37},{36,33},{31,35} } do c:put(p[1], p[2], "#6a9a3a", G1) c:put(p[1] + 1, p[2], "#9cc85a", G1) end
for _, p in ipairs{ {20,38},{35,27},{40,31},{28,33},{47,36} } do c:put(p[1], p[2], "#7a3a28", G1) c:put(p[1], p[2] - 1, "#b46848", G1) end
for _, p in ipairs{ {33,24},{34,25},{24,31},{25,32} } do c:put(p[1], p[2], "#e8641c", G1) end
-- front lip of bowl over the rice
ring:each(function(x, y) if y >= 39 then c:put(x, y, y >= 40 and "#d0a040" or "#fbe8a0", rt) end end)
for x = 12, 52 do if ring:has(x, 42) then c:put(x, 42, "#a8782c", rt) end end
-- quirk: curling steam
local sm = c:line({{36,13},{39,10},{36,7},{39,4}}, 1)
sm:each(function(x, y) c:put(x, y, "#f4ecdc", { r = { name = "steam" } }) end)
c:put(38, 9, "#c8bcd8", { r = { name = "steam" } })
G.save(c, NAME)
