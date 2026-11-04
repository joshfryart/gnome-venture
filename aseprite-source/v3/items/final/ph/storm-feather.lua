-- storm-feather (lean D2o_15)
-- Slim diagonal feather, slate-to-sky storm-blue vane with barb ridges, a split notch and a pale quill;
-- quirk: a yellow lightning bolt crackles across the vane and a tiny spark pops off the tip.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "storm-feather" }
local function shade(m, R, ramp, o) o = o or {}
  local n = X.pillow(m, R)
  local v = X.light(n, { amb = o.amb or 0.08, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias, o.tok)
  return n, v
end
local function inter(a, b) local m = HP.mask() a:each(function(x, y) if b:has(x, y) then m:set(x, y) end end) return m end
local STORM = { "#1f2a4a", "#33477a", "#4f6fae", "#7f9fd6", "#b4cdf0", "#e4f0ff" }
local P = { {12, 54}, {18, 34}, {34, 18}, {52, 9} }
local vm, vn, T, S = G.tube(P, function(t)
  if t < 0.12 then return 0.9 end
  local u = (t - 0.12) / 0.88
  return 0.9 + 7.2 * sin(pi * min(1, u * 0.95 + 0.04)) ^ 0.7 * (1 - u * 0.25) end)
-- notch cut from the lower-right vane edge
vm:cut(HP.mask():add(c:poly{ {30, 36}, {40, 31}, {34, 28} }))
local v = X.light(vn, { amb = 0.1, wrap = 0.3 })
G.tone(c, vm, v, STORM, { 0.2, 0.38, 0.55, 0.72, 0.88 })
-- barbs: diagonal ridges leaning toward the tip
vm:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
  if t > 0.14 and abs(s) > 0.2 then
    local d = (t * 60 - abs(s) * 5) % 3.2
    if d < 0.8 then c:px(x, y, s < 0 and STORM[5] or STORM[2]) end
  end end)
-- rachis (quill) pale
local rm, rn = G.tube(P, function(t) return t < 0.12 and 1.2 or 0.7 * (1 - t) + 0.5 end)
G.tone(c, rm, X.light(rn, { amb = 0.2, wrap = 0.3 }), { "#b9a77f", "#d8c9a0", "#efe3c0", "#fff6dc" }, { 0.3, 0.55, 0.8 })
-- lightning bolt
local bolt = { {22, 44}, {29, 38}, {26, 35}, {35, 28}, {32, 25}, {41, 18} }
G.line(c, bolt, "#fff1a0")
for i = 1, #bolt - 1 do c:px(bolt[i][1] + 1, bolt[i][2], "#ffd23a") end
c:px(41, 18, "#ffffe0") c:px(26, 35, "#ffffe0")
c:px(46, 14, "#fff1a0") c:px(47, 12, "#ffd23a") c:px(48, 15, "#ffd23a")
G.fin(c, "storm-feather")
