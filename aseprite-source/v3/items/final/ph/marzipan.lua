-- marzipan (lean P1b_O4)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function sh(c, m, R, ramp, o) return G.toneN(c, m, X.pillow(m, R), ramp, o) end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "marzipan" }
local CR = { "#a8742e", "#d29a42", "#eec06a", "#f9d98c", "#fdeab4", "#fff8d8" }
local TOP = { "#8a4a1c", "#b4702a", "#d89a42", "#ecb85c", "#f8d88a", "#fff0b8" }
local PK = { "#8a2a52", "#b84a72", "#e0709a", "#f6a0bc", "#ffd0dc" }
local LF = { "#1b4a30", "#2e7a3e", "#4aa848", "#7ccc58" }
c:groundShadow(32, 52, 24, 3)
local top = c:poly{ {8,26},{32,16},{57,24},{33,35} }
local lf  = c:poly{ {8,26},{33,35},{33,51},{8,42} }
local rt  = c:poly{ {33,35},{57,24},{57,40},{33,51} }
-- front faces: flat cream with grain noise
local function face(m, ramp, base, lit)
  m:each(function(x, y)
    local h = X.hash(x, y, 7)
    local i = base + (h > 0.9 and 1 or 0) - (h < 0.1 and 1 or 0)
    c:px(x, y, ramp[max(1, min(6, i))])
  end)
end
face(lf, CR, 4) face(rt, CR, 3) face(top, CR, 5)
-- toasted top: brown gradient from edges
top:each(function(x, y)
  local ex = top:copy():shrink(3)
  if not ex:has(x, y) then c:px(x, y, TOP[3 + floor(X.hash(x, y, 3) * 1.8)]) end
end)
top:copy():shrink(1):cut(top:copy():shrink(3)):each(function(x, y) if (x + y) % 4 == 0 then c:px(x, y, TOP[2]) end end)
-- dark edge under right face + AO row at base
rt:each(function(x, y) if x > 52 then c:px(x, y, CR[2]) end end)
for x = 33, 56 do c:px(x, 51 - floor((x - 33) * 11 / 24) + 0, CR[1]) end
for x = 8, 32 do c:px(x, 42 + floor((x - 8) * 9 / 24), CR[2]) end
-- crimp pinch marks along top-front edge
for i = 0, 6 do local x = 11 + i * 3 c:px(x, 27 + floor(i * 1.4), CR[1]) c:px(x + 1, 28 + floor(i * 1.4), CR[6]) end
for i = 0, 6 do local x = 36 + i * 3 c:px(x, 34 - floor(i * 1.4), CR[2]) c:px(x + 1, 35 - floor(i * 1.4), CR[6]) end
-- rose
local r = c:ellipse(32, 24, 7, 5)
G.toneN(c, r, X.pillow(r, 5), PK, { cuts = { 0.2, 0.4, 0.6, 0.8, 0.9 } })
c:px(32, 24, PK[1]) c:px(33, 24, PK[1]) c:px(33, 23, PK[2]) c:px(31, 23, PK[2]) c:px(31, 22, PK[2]) c:px(32, 22, PK[2]) c:px(30, 25, PK[2]) c:px(34, 26, PK[2])
c:px(29, 22, PK[5]) c:px(30, 21, PK[5])
-- leaves
local l1 = c:poly{ {24,26},{18,22},{14,24},{19,28} } local l2 = c:poly{ {40,26},{46,22},{50,24},{45,28} }
G.toneN(c, l1, X.pillow(l1, 3), LF) G.toneN(c, l2, X.pillow(l2, 3), LF)
-- quirk: tiny fork prints in the front face
for i = 0, 3 do c:px(16 + i * 2, 36 + i, CR[1]) c:px(16 + i * 2, 38 + i, CR[1]) end
c:px(15, 33, CR[6]) c:px(23, 33, CR[6])
G.save(c, "marzipan")
