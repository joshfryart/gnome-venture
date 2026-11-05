-- gravel-path (lean E2_01)
local NAME = "gravel-path"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, ceil = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.ceil
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
local function inter(a, b) local r = HP.mask() a:each(function(x, y) if b:has(x, y) then r:set(x, y) end end) return r end

local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local PEBS = {
  { "#2e3040", "#4c5266", "#6e7690", "#939bb0", "#b6bdd0", "#d8dde8" },
  { "#3a2c2a", "#5e4a40", "#85705a", "#a8927a", "#c9b498", "#e6d6b8" },
  { "#2a3436", "#46585a", "#69807a", "#8fa49a", "#b4c6b8", "#d6e4d4" },
}
local ROSE = { "#5a1830", "#8c2c48", "#c4506a", "#e8788a", "#f8a8b0", "#ffd8d8" }
c:groundShadow(32, 54, 26, 3.5)
local top = c:poly{ {32,16}, {58,30}, {32,44}, {6,30} }
local left = c:poly{ {6,30}, {32,44}, {32,50}, {6,36} }
local right = c:poly{ {32,44}, {58,30}, {58,36}, {32,50} }
local stok = { r = { name = "side" } }
left:each(function(x, y) c:put(x, y, (x % 9 == 0) and "#523222" or "#7a4c30", stok) end)
right:each(function(x, y) c:put(x, y, (x % 9 == 4) and "#2e1c14" or "#523222", stok) end)
local rim = top:copy() rim:cut(top:copy():shrink(2))
local inner = top:copy():shrink(2)
local rtok = { r = { name = "rim" } }
top:each(function(x, y) c:put(x, y, rim:has(x, y) and ((y < 30) and "#c88d58" or "#a06a40") or "#2c2428", rtok) end)
local pin = inner:copy():shrink(1)
local n = 0
for j = 0, 9 do for i = -1, 10 do
  local cx = 9 + i * 5.2 + (j % 2) * 2.6 + (X.hash(i, j, 1) - 0.5) * 1.4
  local cy = 18 + j * 3.3 + (X.hash(i, j, 2) - 0.5) * 1
  if pin:has(floor(cx + 0.5), floor(cy + 0.5)) then
    n = n + 1
    local quirk = (i == 6 and j == 6)
    local pm = inter(c:ellipse(cx, cy, 2.7 + X.hash(i, j, 3) * 0.5, 1.9), inner)
    local ramp = quirk and ROSE or PEBS[1 + floor(X.hash(i, j, 4) * 3)]
    local tok = { r = { name = "peb" .. n } }
    X.tone(c, pm, X.light(X.pillow(pm, 2), { amb = 0.08, wrap = 0.2 }), ramp, { cuts = CUTS, tok = tok })
    pm:each(function(x, y) if not pm:has(x + 1, y) or not pm:has(x, y + 1) then c:put(x, y, ramp[2], tok) end end)
    local gx, gy = G.specAt(pm, X.pillow(pm, 2), 20)
    if quirk then c:sparkle(floor(cx), floor(cy)) end
  end
end end
-- grass tuft at the left corner
local gt = { r = { name = "grass" } }
for i, b in ipairs{ { {10,31}, {8,24} }, { {11,31}, {11,22} }, { {12,31}, {15,24} }, { {9,31}, {5,27} } } do
  c:line(b, 1):each(function(x, y) c:put(x, y, (i % 2 == 0) and "#62ad55" or "#3f8f4c", gt) end)
  c:put(b[2][1], b[2][2], "#93cb68", gt)
end
G.save(c, NAME)
