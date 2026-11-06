-- stuffed-peppers-goat (lean E2_15)
-- One big red bell-pepper half baked as a boat: glossy red shell, green stem at the left end, mound of cream goat cheese
-- browned in patches, thyme sprig and chilli flakes, steam rising.
-- quirk: a drip of melted cheese runs down the front of the shell.
local NAME = "stuffed-peppers-goat"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt, atan2 = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan2 or math.atan
local function clamp(v,a,b) return max(a,min(b,v)) end

local RED = { "#4a1220", "#7a1a28", "#a82a2e", "#d04a32", "#ec7040", "#ffa468" }
local CHS = { "#9a8a78", "#c8bca4", "#e8dfc6", "#f6efdc", "#fffaee" }
local GRN = { "#1c3d2a", "#2a5e36", "#3f8a3e", "#68b04a", "#9ad45e", "#c8ee8c" }
c:groundShadow(34, 53, 25, 3)
local function ell(cx, cy, rx, ry, fn)
  for y = floor(cy - ry) - 1, floor(cy + ry) + 1 do for x = floor(cx - rx) - 1, floor(cx + rx) + 1 do
    local nx, ny = (x - cx) / rx, (y - cy) / ry
    local d = nx * nx + ny * ny
    if d <= 1 then fn(x, y, nx, ny, sqrt(max(0, 1 - d))) end
  end end
end
local bodyM = {}
ell(33, 36, 25, 15, function(x, y, nx, ny, nz)
  bodyM[x * 100 + y] = true
  local l = -0.45 * nx - 0.55 * ny + 0.7 * nz
  local i = clamp(floor((l + 0.15) * 4.6) + 1, 1, 6)
  c:put(x, y, RED[i])
end)
-- lobe creases on the shell front
for _, off in ipairs{ -13, 0, 13 } do
  for y = 42, 51 do
    local t = (y - 36) / 15
    local x = floor(33 + off * 1.5 * sqrt(max(0, 1 - t * t)) * 0.7 + 0.5)
    if bodyM[x * 100 + y] then c:put(x, y, RED[2]); if bodyM[(x + 1) * 100 + y] then c:put(x + 1, y, RED[4]) end end
  end
end
-- glossy specs
for _, p in ipairs{ {15,43},{16,44},{17,45},{25,48},{26,48},{44,45} } do c:put(p[1], p[2], RED[6]) end
c:put(14, 42, "#fff0d8"); c:put(15, 42, "#ffd9b0"); c:put(24, 47, "#ffd9b0")
-- inner flesh ring
ell(33, 32.5, 21, 10, function(x, y) c:put(x, y, "#ffb870") end)
ell(33, 33.5, 21, 10, function(x, y) c:put(x, y, "#e8803c") end)
-- cheese mound
ell(33, 32, 20, 9.5, function(x, y, nx, ny, nz)
  local l = -0.4 * nx - 0.7 * ny + 0.6 * nz
  local i = clamp(floor((l + 0.1) * 4.6) + 1, 1, 5)
  c:put(x, y, CHS[i])
end)
ell(26, 28, 8, 4.5, function(x, y, nx, ny, nz) local l = -0.5 * nx - 0.7 * ny + 0.6 * nz c:put(x, y, CHS[clamp(floor((l + 0.2) * 4) + 2, 2, 5)]) end)
ell(40, 28, 9, 4.5, function(x, y, nx, ny, nz) local l = -0.5 * nx - 0.7 * ny + 0.6 * nz c:put(x, y, CHS[clamp(floor((l + 0.2) * 4) + 2, 2, 5)]) end)
-- browned patches
local function brown(cx, cy, rx, ry, seed)
  ell(cx, cy, rx, ry, function(x, y, nx, ny)
    local h = X.hash(x, y, seed)
    c:put(x, y, (nx * nx + ny * ny > 0.5 or h > 0.8) and "#d89a48" or "#b47432")
  end)
end
brown(28, 27, 4, 2, 5); brown(41, 29, 5, 2.5, 6); brown(34, 33, 3, 1.5, 7); brown(20, 33, 2, 1.2, 8)
for _, p in ipairs{ {25,26},{39,27},{42,30} } do c:put(p[1], p[2], "#f0c46c") end
-- chilli flakes
for _, p in ipairs{ {24,31},{36,26},{31,35},{45,32},{19,31} } do c:put(p[1], p[2], "#c8322a") end
-- thyme sprig
local TH = { "#2a5e36", "#4f9a46", "#8cc860" }
for _, p in ipairs{ {29,30},{30,29},{31,28},{32,27},{33,27},{34,26} } do c:put(p[1], p[2], TH[1]) end
for _, p in ipairs{ {30,28},{32,26},{34,28},{33,29},{35,25},{31,30},{28,29} } do c:put(p[1], p[2], TH[2]); c:put(p[1] + 1, p[2], TH[3]) end
-- stem + calyx at the left end
local sm, sn = G.tube({ {13,31}, {8,26}, {7,20}, {10,15} }, function(t) return 2.3 - 0.5 * t end)
G.toneN(c, sm, sn, GRN, { tok = { r = { name = "stem" } }, amb = 0.12, wrap = 0.3 })
ell(11, 33, 4.2, 4, function(x, y, nx, ny, nz) local l = -0.5 * nx - 0.6 * ny + 0.6 * nz c:put(x, y, GRN[clamp(floor((l + 0.1) * 4.5) + 1, 1, 6)]) end)
c:put(8, 30, GRN[6]); c:put(9, 31, GRN[5])
-- cheese drip down the shell front
for y = 42, 46 do c:put(41, y, CHS[3]); c:put(42, y, CHS[2]) end
c:put(40, 47, CHS[3]); c:put(41, 47, CHS[4]); c:put(42, 47, CHS[3]); c:put(43, 47, CHS[2]); c:put(41, 48, CHS[2]); c:put(42, 48, CHS[1])
c:put(41, 43, CHS[5])
-- steam
local ST = { "#f6f0f8", "#d8d0e4" }
local function wisp(x0, y0, ph)
  for i = 0, 12 do
    local x = floor(x0 + sin(i * 0.7 + ph) * 2.2 + 0.5)
    c:put(x, y0 - i, ST[1]); c:put(x + 1, y0 - i, ST[2])
  end
end
wisp(27, 21, 0); wisp(39, 20, 2); wisp(49, 23, 4)
G.save(c, NAME)
