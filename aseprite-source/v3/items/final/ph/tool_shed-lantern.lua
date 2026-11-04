-- tool_shed-lantern (lean D3o_6)
local NAME = "tool_shed-lantern"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, ceil, abs, max, min, sin, cos, sqrt = math.floor, math.ceil, math.abs, math.max, math.min, math.sin, math.cos, math.sqrt
local WOOD  = { "#3c2318", "#5e3822", "#82522f", "#a8703e", "#c8914f", "#e3b574" }
local WOODD = { "#24140e", "#3a2116", "#523020", "#6c412a", "#875636", "#a26b42" }
local DOOR  = { "#2a1712", "#46261b", "#623623", "#7e4a2c", "#9a6238", "#b87a46" }
local SLATE = { "#2f3144", "#464a63", "#5f647f", "#7d829b", "#a0a5b9", "#c4c8d6" }
local PINK  = { "#5c1f3d", "#8a2f56", "#bb4574", "#e0689a", "#f28fb8", "#ffc0d8" }
local BLUE  = { "#2c4170", "#3f5e9a", "#5b82bf", "#82a8dc", "#a9caf0", "#d4e8fa" }
local MOSS  = { "#1f3a24", "#2f5a30", "#437a38", "#62a044", "#8cc45a", "#b8dd7a" }
local STONE = { "#3b3a46", "#55546a", "#74728a", "#9694a8", "#b8b6c6", "#d8d6e2" }
local RED   = { "#5a1420", "#8c1f2b", "#c1343a", "#e0524a", "#f27d63", "#ffb08a" }
local WH    = { "#8e93aa", "#b9bdd0", "#dfe2ee", "#f4f5fb", "#fff9f2" }
local MET   = { "#2e3444", "#4b5568", "#7686a0", "#a9b8c9", "#dfe8ef" }
local BRICK = { "#4a1f24", "#74302d", "#a14a3a", "#c4684a", "#e08a62" }
local GLASS = { "#2a3f6b", "#4e7bb5", "#8fc0e8", "#d6f0ff" }
local LAMP  = { "#b8651c", "#e8962a", "#ffc94a", "#ffe98a", "#fff8cf" }
local GOLD, INK = "#f2c14e", "#2b1c26"
local function cl(t, n) return max(1, min(n, floor(t + 0.5))) end
local function px(x, y, h) x = floor(x + 0.5) y = floor(y + 0.5) if x >= 0 and x < 64 and y >= 0 and y < 64 then c:px(x, y, h) end end
local function rect(x0, y0, x1, y1, h) for y = y0, y1 do for x = x0, x1 do px(x, y, h) end end end
local function scan(pts, f)
  local ymin, ymax = 1e9, -1e9
  for _, p in ipairs(pts) do ymin = min(ymin, p[2]) ymax = max(ymax, p[2]) end
  for y = floor(ymin), ceil(ymax) - 1 do
    local sy, xs = y + 0.5, {}
    for i = 1, #pts do
      local a, b = pts[i], pts[i % #pts + 1]
      if (a[2] <= sy and b[2] > sy) or (b[2] <= sy and a[2] > sy) then
        xs[#xs + 1] = a[1] + (sy - a[2]) * (b[1] - a[1]) / (b[2] - a[2])
      end
    end
    table.sort(xs)
    for i = 1, #xs - 1, 2 do for x = ceil(xs[i] - 0.5), ceil(xs[i + 1] - 0.5) - 1 do f(x, y) end end
  end
end
local function ell(cx, cy, rx, ry, f)
  for y = floor(cy - ry), ceil(cy + ry) do for x = floor(cx - rx), ceil(cx + rx) do
    local dx, dy = (x + 0.5 - cx) / rx, (y + 0.5 - cy) / ry
    if dx * dx + dy * dy <= 1 then f(x, y, dx, dy) end
  end end
end
local function line(x0, y0, x1, y1, h, w)
  local n = max(abs(x1 - x0), abs(y1 - y0))
  for i = 0, n do local t = n == 0 and 0 or i / n
    local x, y = x0 + (x1 - x0) * t, y0 + (y1 - y0) * t
    px(x, y, h) if w and w > 1 then px(x + 1, y, h) end end
end
-- vertical plank colour at (x,y) in box
local function woodpx(x, y, x0, y0, x1, y1, R, pw, adj)
  local i, u = floor((x - x0) / pw), (x - x0) % pw
  local t = (i % 2 == 0) and 4 or 3
  if (y - y0) / (y1 - y0 + 1) > 0.78 then t = t - 1 end
  if (x - x0) > (x1 - x0) * 0.8 then t = t - 1 end
  if u == 0 then t = t + 1 elseif u == pw - 1 then t = 2 end
  local h = X.hash(x, y, i + 7)
  if u > 0 and u < pw - 1 then
    if h > 0.92 then t = t - 1 elseif h < 0.04 then t = t + 1 end
    if u == 2 and (y + i * 3) % 9 < 3 then t = t - 1 end
  end
  if adj then t = t + adj(x, y) end
  return R[cl(t, 6)]
end
local function wood(x0, y0, x1, y1, R, pw, adj)
  for y = y0, y1 do for x = x0, x1 do px(x, y, woodpx(x, y, x0, y0, x1, y1, R, pw, adj)) end end
end
local function clap(x0, y0, x1, y1, R, rh)
  for y = y0, y1 do for x = x0, x1 do
    local u = (y - y0) % rh
    local t = 4
    if u == 0 then t = 5 elseif u == rh - 1 then t = 2 elseif u == rh - 2 then t = 3 end
    if (x - x0) > (x1 - x0) * 0.78 then t = t - 1 end
    if X.hash(x, y, 3) > 0.94 then t = t - 1 end
    if (x * 5 + floor((y - y0) / rh) * 11) % 17 == 0 and u > 0 then t = t - 1 end
    px(x, y, R[cl(t, 6)])
  end end
end
local function shingle(pts, R, rh, y0, mx)
  scan(pts, function(x, y)
    local r, u = floor((y - y0) / rh), (y - y0) % rh
    local sx = (x + (r % 2) * 3) % 6
    local t = 3
    if u == 0 then t = 4 elseif u == rh - 1 then t = 2 end
    if sx == 0 and u > 0 then t = 2 end
    if x < mx - 9 then t = t + 1 elseif x > mx + 9 then t = t - 1 end
    if X.hash(x, y, 5) > 0.93 then t = t + 1 end
    px(x, y, R[cl(t, 6)])
  end)
end
local function door(x0, y0, x1, y1, R, xb)
  wood(x0, y0, x1, y1, R, floor((x1 - x0 + 1) / 2))
  rect(x0, y0, x1, y0, R[1]) rect(x0, y0, x0, y1, R[1]) rect(x1, y0, x1, y1, R[1])
  local mx = floor((x0 + x1) / 2) rect(mx, y0, mx, y1, R[1])
  if xb then
    line(x0 + 1, y0 + 1, x1 - 1, y1 - 1, R[1]) line(x1 - 1, y0 + 1, x0 + 1, y1 - 1, R[1])
    line(x0 + 2, y0 + 1, x1 - 1, y1 - 2, R[5]) line(x1 - 2, y0 + 1, x0 + 1, y1 - 2, R[5])
  end
end
local function shovel(x, y, h)
  for i = 0, h - 8 do px(x, y + i, WOOD[5]) px(x + 1, y + i, WOOD[3]) px(x + 2, y + i, WOOD[2]) end
  px(x - 1, y, WOOD[4]) px(x, y, WOOD[5]) px(x + 2, y, WOOD[3])
  local ws = { 3, 5, 5, 5, 3, 1 }
  for j = 1, 6 do local w = ws[j]
    for k = 0, w - 1 do
      local t = (k == 0 and 4) or (k == w - 1 and 2) or 3
      if j == 1 then t = 5 end
      px(x + 1 - floor(w / 2) + k, y + h - 8 + j, MET[t])
    end
  end
end
local function rake(x, y, h)
  for i = 0, h - 5 do px(x, y + i, WOOD[5]) px(x + 1, y + i, WOOD[3]) px(x + 2, y + i, WOOD[2]) end
  for k = -2, 4 do px(x + k, y + h - 4, k < 0 and MET[4] or MET[3]) end
  px(x + 4, y + h - 4, MET[2])
  for _, k in ipairs{ -2, 0, 2, 4 } do px(x + k, y + h - 3, MET[3]) px(x + k, y + h - 2, MET[2]) end
end
local function glassbox(x0, y0, x1, y1)
  for y = y0, y1 do for x = x0, x1 do
    local t = (x - x0) / max(1, x1 - x0) + (y - y0) / max(1, y1 - y0)
    px(x, y, GLASS[cl(4 - t * 1.6, 4)])
  end end
end
c:groundShadow(32, 57, 28, 3)
local function glow(x, y) local d = sqrt((x - 24) ^ 2 + ((y - 41) * 1.1) ^ 2) if d < 5 then return 2 elseif d < 10 then return 1 elseif d < 15 then return 0 end return -1 end
wood(12, 30, 52, 56, WOODD, 5, glow)
-- crate
wood(13, 47, 20, 56, WOOD, 4, glow) rect(13, 47, 20, 47, WOOD[1]) rect(13, 56, 20, 56, WOOD[1]) rect(13, 47, 13, 56, WOOD[1]) rect(20, 47, 20, 56, WOOD[1])
line(14, 48, 19, 55, WOOD[2]) 
-- door
door(32, 40, 44, 56, DOOR, true) px(34, 49, GOLD) px(34, 50, GOLD)
-- roof
shingle({ { 15, 14 }, { 49, 14 }, { 58, 30 }, { 6, 30 } }, SLATE, 3, 14, 32)
rect(15, 14, 49, 14, SLATE[5]) line(15, 15, 7, 29, SLATE[5]) line(49, 15, 57, 29, SLATE[1])
rect(6, 30, 58, 30, SLATE[2]) rect(6, 31, 58, 31, SLATE[1])
rect(8, 32, 56, 33, WOOD[3]) rect(8, 32, 56, 32, WOOD[5]) rect(8, 33, 56, 33, WOOD[1])
-- posts
wood(9, 34, 12, 56, WOOD, 4) wood(52, 34, 55, 56, WOOD, 4)
rect(9, 34, 12, 34, WOOD[1]) rect(52, 34, 55, 34, WOOD[1]) rect(13, 34, 13, 38, WOOD[2]) rect(51, 34, 51, 38, WOOD[2])
-- big lantern
line(24, 34, 24, 36, MET[3]) px(23, 35, MET[2]) px(25, 35, MET[2])
rect(21, 37, 27, 37, MET[1]) rect(22, 36, 26, 36, MET[2]) px(24, 35, MET[4])
for y = 38, 46 do for x = 21, 27 do
  local edge = (x == 21 or x == 27)
  if edge then px(x, y, MET[x == 21 and 3 or 1]) else
    local d = abs(x - 24) + abs(y - 42) * 0.5
    px(x, y, LAMP[cl(5 - d * 0.9, 5)]) end end end
px(24, 38, MET[1]) px(24, 46, MET[1]) rect(21, 47, 27, 47, MET[1]) rect(22, 48, 26, 48, MET[2])
px(22, 39, "#fff9f2") px(22, 40, LAMP[5])
-- moth (quirk)
px(36, 36, "#e8e0f0") px(37, 36, "#e8e0f0") px(38, 36, "#b9b0cc") px(35, 37, "#b9b0cc") px(36, 37, "#2b1c26")
px(33, 37, LAMP[5]) 
G.save(c, NAME)
