-- soursop (lean D2o_3)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "soursop" }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function shade(m, R, ramp, o) o = o or {}
  local n = X.pillow(m, R) local v = X.light(n, { amb = o.amb or 0.1, wrap = o.wrap or 0.25 })
  G.tone(c, m, v, ramp, o.cuts, o.bias) return v, n end
local function fill(m, hex) c:fillMask(m, hex) end
-- lopsided egg-shaped fruit with soft curved spines, short stem + leaf, a cut window showing white flesh + black seeds
local FR = { "#1d3f22", "#2d5f2c", "#438337", "#62a443", "#8cc455", "#bddf80" }
local stem = G.tube({ {37,17}, {37,11}, {40,8}, {44,8} }, function(t) return 1.6 end)
shade(stem, 2, { "#4a3a22", "#6b5a30", "#8f8445", "#b4ab62" }, { cuts = { 0.3, 0.55, 0.8 } })
local lf = G.rell(49, 11, 0.9, -0.35, 7, 3.2)
shade(lf, 3, { "#1f4a2a", "#2f6b34", "#4b9040", "#7cbc58", "#a6d878", "#c8eca0" })
for i = 0, 8 do c:px(44 + i, 12 - floor(i * 0.35), "#c8eca0") end
local body = G.rell(30, 35, 0.5, 0.866, 20, 15) body:add(c:ellipse(40, 42, 9, 9))
body:add(c:ellipse(22, 27, 7, 6))
-- edge spines
local bb = body:copy()
for y = 8, 62 do for x = 6, 58 do
  if not body:has(x, y) and (x * 3 + y * 5) % 7 == 0 and (body:has(x - 1, y) or body:has(x + 1, y) or body:has(x, y - 1) or body:has(x, y + 1)) then bb:set(x, y) end
end end
local v = shade(body, 14, FR)
bb:each(function(x, y) if not body:has(x, y) then c:px(x, y, FR[2]) end end)
-- surface spines: staggered grid of tiny hooked cones
body:copy():shrink(2):each(function(x, y)
  local row = floor(y / 4)
  if (y % 4 == 1) and ((x + (row % 2) * 3) % 6 == 0) then
    local lit = v[K(x, y)] or 0.5
    c:px(x, y, lit > 0.55 and FR[6] or FR[5]) c:px(x + 1, y, FR[2]) c:px(x, y + 1, FR[1]) c:px(x + 1, y + 1, FR[1])
  end end)
-- cut window
local win = c:ellipse(40, 43, 6, 5) local rim = win:copy():grow(1):cut(win)
fill(rim, FR[2]) fill(win, "#f3eee6")
fill(c:ellipse(40, 45, 5, 3):cut(c:ellipse(40, 41, 5, 3)), "#d6cfd8")
for x = 36, 44 do c:px(x, 47, "#a89cb0") end
c:px(38, 41, "#3a2a2c") c:px(39, 41, "#3a2a2c") c:px(42, 44, "#3a2a2c") c:px(43, 44, "#3a2a2c") c:px(39, 45, "#5a4a46")
c:px(37, 40, "#fffaf0") c:px(38, 40, "#fffaf0")
-- specular
c:px(20, 29, "#e8f6c0") c:px(21, 29, "#e8f6c0") c:px(20, 30, "#e8f6c0")
G.fin(c, "soursop")
