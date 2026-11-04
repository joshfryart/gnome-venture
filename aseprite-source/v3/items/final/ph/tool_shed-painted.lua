-- tool_shed-painted (lean D3o_6)
local NAME = "tool_shed-painted"
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
c:groundShadow(32, 57, 27, 3)
clap(10, 34, 54, 56, BLUE, 3)
rect(10, 34, 12, 56, WH[3]) rect(10, 34, 10, 56, WH[4]) rect(52, 34, 54, 56, WH[2]) rect(54, 34, 54, 56, WH[1])
rect(10, 56, 54, 56, WH[2])
rect(10, 37, 54, 37, BLUE[1])
-- door with round top
wood(26, 44, 37, 56, DOOR, 6)
ell(31.5, 44, 6, 5, function(x, y) if y < 44 then px(x, y, woodpx(x, y, 26, 44, 37, 56, DOOR, 6)) end end)
rect(25, 44, 25, 56, WH[3]) rect(38, 44, 38, 56, WH[2]) rect(26, 56, 37, 56, STONE[3])
for x = 26, 37 do for y = 39, 43 do local dx = (x + 0.5 - 31.5) / 6.5 if y == 39 and abs(dx) < 0.55 then px(x, y, WH[4]) end end end
ell(31.5, 49, 2.6, 2.6, function(x, y, dx, dy) px(x, y, LAMP[cl(3.5 - dx - dy, 5)]) end)
px(31, 47, WH[5]) px(31, 49, DOOR[1]) px(32, 49, DOOR[1]) px(31, 50, DOOR[1])
px(35, 51, GOLD)
-- window + flower box
rect(14, 41, 22, 49, WH[3]) glassbox(15, 42, 21, 48) rect(18, 42, 18, 48, WH[3]) rect(15, 45, 21, 45, WH[3])
rect(13, 50, 23, 53, WOOD[3]) rect(13, 50, 23, 50, WOOD[5]) rect(13, 53, 23, 53, WOOD[1])
for i = 0, 5 do local fx = 14 + i * 2 px(fx, 49, MOSS[3]) px(fx + 1, 48, MOSS[4]) px(fx, 48, (i % 2 == 0) and RED[4] or GOLD) end
px(15, 47, RED[4]) px(19, 47, GOLD) px(21, 47, RED[3])
-- watering can on right
line(46, 40, 46, 43, MET[2]) px(45, 43, MET[2]) px(47, 43, MET[2])
for y = 44, 51 do for x = 43, 50 do local t = (x < 45 and 4) or (x > 48 and 2) or 3 if y == 44 then t = 5 end px(x, y, MET[t]) end end
rect(43, 52, 50, 52, MET[1]) line(51, 49, 54, 45, MET[3]) px(55, 44, MET[4]) px(55, 45, MET[3])
line(43, 45, 41, 45, MET[3]) px(41, 46, MET[3]) px(41, 47, MET[3]) px(42, 48, MET[3])
-- roof
shingle({ { 18, 15 }, { 46, 15 }, { 58, 34 }, { 6, 34 } }, PINK, 3, 15, 32)
rect(18, 15, 46, 15, PINK[6]) line(18, 16, 7, 33, PINK[6]) line(46, 16, 57, 33, PINK[1])
rect(6, 34, 58, 35, WH[3]) rect(6, 34, 58, 34, WH[5]) rect(6, 35, 58, 35, WH[2]) rect(8, 36, 56, 36, WH[1])
-- bluebird (quirk)
ell(32, 12, 3, 2, function(x, y, dx, dy) px(x, y, dy < 0 and BLUE[4] or BLUE[2]) end)
px(35, 10, BLUE[3]) px(35, 11, BLUE[3]) px(36, 11, GOLD) px(34, 11, "#2b1c26") px(29, 13, BLUE[1]) px(28, 14, BLUE[1]) px(31, 14, GOLD) px(33, 14, GOLD)
rect(31, 14, 33, 14, PINK[3]) px(31, 14, GOLD) px(33, 14, GOLD)
G.save(c, NAME)
