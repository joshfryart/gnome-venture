-- feast-isles-ackee-pot (lean E2_00)
local NAME = "feast-isles-ackee-pot"
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
c:groundShadow(32, 57, 25, 3)
local CLAY = { "#3c1a1a", "#6a2c24", "#9a4630", "#c46a3a", "#e8905a", "#f8b880" }
local pot = c:ellipse(22, 44, 16, 12)
pot:cut(c:rect(0, 0, 63, 34))
local pt = { r = { name = "pot" } }
shade(pot, CLAY, 12, pt, 0.1, 0.2)
for x = 9, 35 do local yy = 45 + floor(2 * sin((x - 9) / 26 * pi)) c:put(x, yy, "#f4e4b8", pt) c:put(x, yy + 1, "#a8783c", pt) if x % 3 == 0 then c:put(x, yy - 1, "#6a2c24", pt) end end
for _, h in ipairs{ {5, 41}, {39, 41} } do
  local o = c:ellipse(h[1], h[2], 3, 3) o:cut(c:ellipse(h[1], h[2], 1, 1))
  shade(o, CLAY, 2, pt, 0.1, 0.2)
end
local rim = c:ellipse(22, 34, 15, 4)
shade(rim, CLAY, 4, pt, 0.2, 0.3)
-- ackee heap
local Y = { "#7a4a14", "#b07a1e", "#d9a62a", "#f0c640", "#ffdf6a", "#fff0a0" }
local yt = { r = { name = "ackee" } }
local lumps = { {11,33,5,3},{17,30,5,4},{24,29,5,4},{31,31,5,4},{36,34,4,3},{14,35,5,3},{22,34,5,3},{29,35,5,3},{20,26,4,3},{27,25,4,3}, {23,31,4,3} }
for i, l in ipairs(lumps) do
  local m = c:ellipse(l[1], l[2], l[3], l[4])
  shade(m, Y, 3.5, yt, 0.1, 0.25)
  c:put(l[1] - 1, l[2] - 1, "#fffbd0", yt)
  c:put(l[1] + 1, l[2] + l[4] - 1, Y[2], yt)
end
for _, p in ipairs{ {19,31},{26,28},{33,33},{14,34},{24,34},{28,36},{21,26} } do c:put(p[1], p[2], "#d8352c", yt) c:put(p[1] + 1, p[2], "#a82220", yt) end
for _, p in ipairs{ {16,30},{29,32},{12,32},{30,26} } do c:put(p[1], p[2], "#6aa83a", yt) c:put(p[1] + 1, p[2] + 1, "#3f7a2c", yt) end
for _, p in ipairs{ {22,28},{34,35},{17,33} } do c:put(p[1], p[2], "#fff6e8", yt) c:put(p[1] + 1, p[2], "#e8d8c0", yt) end
-- split ackee pod
local RED = { "#4a1218", "#7a1c24", "#aa2c30", "#d04838", "#ec7048", "#f8a060" }
local pod = c:ellipse(49, 47, 8, 10)
pod:cut(c:rect(0, 0, 63, 38))
local rt = { r = { name = "pod" } }
shade(pod, RED, 9, rt, 0.1, 0.2)
local lip = c:ellipse(49, 38, 8, 4)
shade(lip, RED, 3, rt, 0.2, 0.3)
local mouth = c:ellipse(49, 38, 6, 2.6)
mouth:each(function(x, y) c:put(x, y, "#f6e8b0", rt) end)
c:put(44, 38, "#ffe8a0", rt)
for _, a in ipairs{ {46,37},{50,36},{53,38} } do
  local m = c:ellipse(a[1], a[2], 2.6, 2.2)
  shade(m, Y, 2.5, yt, 0.1, 0.25)
  c:put(a[1] - 1, a[2] - 1, "#fffbd0", yt)
  c:put(a[1] - 1, a[2] + 1, "#201418", yt) c:put(a[1], a[2] + 1, "#3a2a2e", yt)
end
c:put(48, 52, RED[6], rt) c:put(47, 51, RED[6], rt)
-- quirk: wisp of steam
for _, p in ipairs{ {18,20},{19,18},{18,16},{19,14} } do c:put(p[1], p[2], "#f4ecdc", { r = { name = "steam" } }) end
G.save(c, NAME)
