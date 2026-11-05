-- tide-bucket (lean P1b_O16)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local function pick(r, v, cuts) cuts = cuts or {.22,.4,.56,.72,.86} local i = 1 for _, t in ipairs(cuts) do if v > t then i = i + 1 end end return r[min(i, #r)] end

local c = HP.canvas{ w=64, h=64, scale=1, name="tide-bucket" }
local WOOD = { "#2f2018", "#533726", "#7a5234", "#a07446", "#c49a5e", "#e2c284" }
local BAND = { "#124a5a", "#1c7a86", "#2fb0b0", "#7ae0d0" }
local WAT  = { "#1c5f9a", "#2f8ad0", "#5cb8ee", "#a8e6fa", "#fffaf0" }
local ROPE = { "#6a4a22", "#a67a3a", "#d8b060", "#f2d890" }
c:groundShadow(32, 58, 17, 2)
local function hw(y) return 17 - (y - 22) * 0.12 end
local bk = HP.mask()
for y = 22, 56 do for x = floor(32 - hw(y)), floor(32 + hw(y)) do bk:set(x, y) end end
-- handle (behind)
local hm, hn = G.tube({ {16,24}, {14,3}, {50,3}, {48,24} }, function() return 1.7 end)
local hv = X.light(hn, { amb = 0.1, wrap = 0.3 })
hm:each(function(x, y) if not bk:has(x, y) then c:px(x, y, pick(ROPE, hv[K(x, y)] + (((x + y) % 3 == 0) and -0.18 or 0))) end end)
bk:each(function(x, y)
  local d = (x - 32 + hw(y)) / (2 * hw(y))
  local stave = floor((x - 15) / 4)
  local v = 0.88 - d * 0.78 + ((stave % 2 == 0) and 0.07 or -0.05) + (X.hash(x, y, 5) - 0.5) * 0.12
  if (x - 15) % 4 == 3 then v = v - 0.28 end
  c:px(x, y, pick(WOOD, v))
end)
for _, by in ipairs{ {30, 33}, {47, 50} } do
  for y = by[1], by[2] do
    local h = hw(y)
    for x = floor(32 - h), floor(32 + h) do
      local d = (x - 32 + h) / (2 * h)
      local r = (y == by[1]) and 4 or ((y == by[2]) and 1 or (d < 0.4 and 3 or 2))
      c:px(x, y, BAND[r])
    end
  end
end
-- water on top
local wm = HP.mask()
for y = 18, 26 do for x = 16, 48 do
  local edge = 22 + 2.6 * sin((x - 16) / 32 * pi * 3)
  if y >= edge - 4 and y <= 26 and abs(x - 32) <= hw(24) + 0.5 then wm:set(x, y) end end end
wm:each(function(x, y)
  local v = 0.85 - (y - 18) * 0.07 - (x - 16) * 0.006
  c:px(x, y, pick(WAT, v))
end)
for _, p in ipairs{ {22,20}, {23,20}, {30,19}, {38,21}, {39,21}, {27,22} } do c:px(p[1], p[2], WAT[5]) end
-- rim
for x = 15, 49 do if bk:has(x, 27) or wm:has(x, 27) then c:px(x, 27, WOOD[5]) end end
-- starfish on front
local sf = HP.mask()
for i = 0, 4 do
  local a = -pi / 2 + i * 2 * pi / 5
  local ex, ey = 32 + cos(a) * 6.5, 40 + sin(a) * 6.5
  for s = 0, 1, 0.05 do
    local px, py = 32 + (ex - 32) * s, 40 + (ey - 40) * s
    local r = 1.9 * (1 - s) + 0.5
    for dy = -2, 2 do for dx = -2, 2 do if dx * dx + dy * dy <= r * r then sf:set(floor(px + dx + 0.5), floor(py + dy + 0.5)) end end end
  end
end
sf:each(function(x, y) c:px(x, y, (x + y < 72) and "#ff9a4a" or "#d85a2c") end)
sf:edge():each(function(x, y) if bk:has(x, y) and not sf:has(x, y) then c:px(x, y, "#8a2e1c") end end)
c:px(31, 38, "#ffe0a0") c:px(32, 40, "#ffe0a0") c:px(33, 42, "#ffe0a0")
-- seaweed over rim (quirk)
c:fillMask(c:line({ {44,24}, {46,28}, {45,32}, {47,36} }, 1), "#2f8a4a")
c:fillMask(c:line({ {45,24}, {47,28}, {46,32} }, 1), "#6cc060")
G.save(c, "tide-bucket")
