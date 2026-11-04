-- stained-glass-arbor (lean D2o_12)
-- Wooden garden arch glazed with a sunburst fan of coloured panes over a gridded lower window; bluebird perched on top.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local sin, cos, pi, abs, floor, max, min, sqrt, atan2 = math.sin, math.cos, math.pi, math.abs, math.floor, math.max, math.min, math.sqrt, math.atan
local function solid(c, m, ramp, R, amb) local n = X.pillow(m, R) local idx = G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp) return n, idx end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "stained-glass-arbor" }
local WOOD = { "#3a2218", "#5a3624", "#7d4d30", "#a2693c", "#c58a52", "#e3b072" }
local GL = {
  { "#7a1a30", "#c63b45", "#ee7a6a" }, { "#8a4a10", "#e0901e", "#fbd060" }, { "#1f5a34", "#3f9a4c", "#8fd070" },
  { "#1d3f80", "#3f78d0", "#8fc0f4" }, { "#4a2478", "#8a52c0", "#c8a0ec" } }
local LEAD = "#2b1c26"
c:groundShadow(32, 57, 23, 3)
local CY = 28
local below = c:rect(0, CY + 1, 63, 63)
local outer = c:ellipse(32, CY, 22, 19):cut(below)
local inner = c:ellipse(32, CY, 16, 14):cut(below)
local glass = inner:copy():add(c:rect(16, CY + 1, 48, 47))
glass:each(function(x, y)
  local id, lead = 0, false
  if y <= CY then
    local dx, dy = x - 32, CY - y
    local a = atan2(dy, dx) if a < 0 then a = 0 end
    local k = min(4, floor(a / (pi / 5)))
    id = 10 + k
    local r = sqrt(dx * dx + dy * dy)
    if abs(a - k * pi / 5) * r < 0.75 and r > 2 and k > 0 then lead = true end
    if abs(a - (k + 1) * pi / 5) * r < 0.75 and r > 2 and k < 4 then lead = true end
    if abs(r - 8.5) < 0.6 then lead = true end
  else
    local col = min(3, floor((x - 16) / 8))
    id = col * 2 + (y < 38 and 0 or 1)
    if (x - 16) % 8 == 0 and x > 16 and x < 48 then lead = true end
    if y == 38 or y == CY + 1 then lead = true end
  end
  if lead then c:px(x, y, LEAD) return end
  local g = GL[(id * 3) % 5 + 1]
  local hex = g[2]
  if (x + y) % 9 < 2 then hex = g[3] elseif (x - y) % 11 == 0 then hex = g[1] end
  c:px(x, y, hex)
end)
glass:edge():each(function(x, y) c:px(x, y, LEAD) end)
-- frame
local ring = outer:copy():cut(inner)
local postL, postR = c:rect(10, 26, 15, 57), c:rect(49, 26, 54, 57)
local rail = c:rect(16, 48, 48, 51)
local frame = ring:copy():add(postL):add(postR):add(rail)
solid(c, frame, WOOD, 3.2)
for y = 30, 55, 3 do for _, x in ipairs{ 12, 13, 51, 52 } do if X.hash(x, y, 7) > 0.4 then c:px(x, y, WOOD[2]) end end end
for x = 20, 44, 5 do c:px(x, 50, WOOD[2]) c:px(x + 1, 49, WOOD[5]) end
-- vine on left post
G.line(c, { {12, 56}, {14, 50}, {11, 45}, {14, 40}, {11, 35}, {14, 30} }, "#3f9a4c")
for _, p in ipairs{ {15, 47}, {10, 42}, {15, 37}, {10, 32}, {15, 52} } do c:px(p[1], p[2], "#8fd070") c:px(p[1] + (p[1] > 12 and 1 or -1), p[2] + 1, "#255644") end
-- quirk: bluebird on top
for x = 31, 33 do c:px(x, 5, "#4a78c8") end
for x = 30, 34 do c:px(x, 6, "#4a78c8") end
for x = 28, 35 do c:px(x, 7, "#3a5ca8") end
c:px(31, 6, "#8fb4e8") c:px(32, 6, "#8fb4e8") c:px(35, 6, "#f0b040") c:px(33, 5, "#2b1c26") c:px(31, 8, "#e0902a") c:px(33, 8, "#e0902a")
G.fin(c, "stained-glass-arbor")
