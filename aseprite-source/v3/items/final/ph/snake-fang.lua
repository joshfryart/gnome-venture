-- snake-fang (lean E2_07)
local NAME = "snake-fang"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(c, m, ramp, R, name, amb, wrap)
  local n = X.pillow(m, R)
  local tok = { r = { name = name } }
  X.tone(c, m, X.light(n, { amb = amb or 0.08, wrap = wrap or 0.25 }), ramp, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.87 }, tok = tok })
  return n, tok
end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
-- quirk: a bead of green venom swelling at the tip
c:groundShadow(32, 58, 12, 2)
local IV = { "#7a6244", "#a48a62", "#c8b088", "#e2cfa6", "#f2e4c4", "#fbf3dc" }
local fm, fn, FT = G.tube({ {30,14}, {27,28}, {33,44}, {36,54} }, function(t) return 7.6 * (1 - t) ^ 0.8 + 0.45 end)
local ftok = { r = { name = "fang" } }
local idx = X.tone(c, fm, X.light(fn, { amb = 0.08, wrap = 0.22 }), IV, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.87 }, tok = ftok })
-- venom groove on the front face
fm:each(function(x, y) local k = K(x, y) local t = FT[k]
  if t > 0.25 and t < 0.92 and idx[k] >= 3 and idx[k] <= 4 then
    local gx = 30.2 - 3 * sin(t * 2.2)
    if abs(x - (gx + 3 * t * 4)) < 0.6 then c:put(x, y, "#4aa860", ftok) end
  end end)
-- spec
fm:each(function(x, y) local k = K(x, y) if FT[k] > 0.2 and FT[k] < 0.6 and idx[k] >= 6 then c:put(x, y, "#fffbea", ftok) end end)
-- gum root: pink swollen base
local gum = c:ellipse(30, 11, 10, 6):add(c:rect(21, 9, 39, 14))
shade(c, gum, { "#5a1f3c", "#862a4a", "#b03e58", "#cc5a68", "#e07e80", "#f2a4a0" }, 6, "gum", 0.1, 0.25)
for x = 22, 38 do if gum:has(x, 16) then c:put(x, 16, "#5a1f3c") end end
c:put(26, 8, "#f8c8c0") c:put(27, 8, "#f8c8c0")
-- venom drop
local d = c:ellipse(37, 58, 2, 2):add(c:poly({{37,53},{35,56},{39,56}}))
shade(c, d, { "#1f6a3c", "#2f8a4a", "#4aa860", "#7ac878", "#aee89a", "#d8f8c0" }, 2, "drop", 0.1, 0.2)
c:put(36, 57, "#f0fff0")
G.save(c, NAME)
