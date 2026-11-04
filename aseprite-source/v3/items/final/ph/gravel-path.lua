-- gravel-path (lean W2_5)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "gravel-path" }
local floor, abs = math.floor, math.abs
local WOOD = { "#4a2c1e", "#6e4428", "#8f5d34", "#b07c46", "#cc9a5e", "#e3b97a" }
c:groundShadow(32, 50, 24, 3)
local top = c:poly{ {8,31},{32,18},{56,31},{32,44} }
local lf = c:poly{ {8,31},{32,44},{32,50},{8,37} }
local rf = c:poly{ {32,44},{56,31},{56,37},{32,50} }
c:fillMask(lf, WOOD[2]) c:fillMask(rf, WOOD[1])
lf:each(function(x, y) if (y + floor(x / 2)) % 4 == 0 then c:px(x, y, WOOD[3]) end end)
rf:each(function(x, y) if (y - floor(x / 2)) % 4 == 0 then c:px(x, y, WOOD[2]) end end)
c:fillMask(top, WOOD[4])
local inner = top:copy():shrink(3)
top:copy():cut(inner):each(function(x, y) c:px(x, y, (x + y) % 5 == 0 and WOOD[5] or (x < 30 and WOOD[4] or WOOD[3])) end)
-- gravel bed
local bed = { "#2f2c34", "#4a4650", "#6b6670", "#908a90", "#b8b0a8", "#d8cfc0" }
local warm = { "#5a4636", "#7c624a", "#a08460" }
inner:each(function(x, y) c:px(x, y, X.hash(x, y, 2) > 0.6 and bed[1] or bed[2]) end)
for gy = 0, 12 do for gx = 0, 22 do
  local px = 11 + gx * 2.2 + X.hash(gx, gy, 5) * 2 + (gy % 2) * 1.1
  local py = 21 + gy * 1.9 + X.hash(gx, gy, 6) * 1.5
  local x, y = floor(px), floor(py)
  if inner:has(x, y) and inner:has(x + 1, y + 1) and X.hash(gx, gy, 7) > 0.22 then
    local r = X.hash(gx, gy, 8)
    local pal = r > 0.78 and warm or { bed[3], bed[4], bed[5] }
    local hi = r > 0.78 and 3 or 3
    c:px(x, y, pal[2]) c:px(x + 1, y, pal[2]) c:px(x, y + 1, pal[1] or bed[2]) c:px(x + 1, y + 1, bed[1])
    if r > 0.4 then c:px(x, y, pal[hi]) end
  end
end end
-- quirk: a single stubborn seedling pushing up between stones
c:px(40, 29, "#4b9650") c:px(41, 29, "#70b45a") c:px(39, 28, "#70b45a") c:px(42, 28, "#9ccd6c") c:px(40, 30, "#255644") c:px(41, 30, "#32764b")
-- glints on stones
for _, p in ipairs{ {20,32},{27,26},{46,32},{34,37} } do c:px(p[1], p[2], bed[6]) end
G.fin(c, "gravel-path")
