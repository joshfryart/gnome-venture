-- sundial (lean P1b_O15)
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local H = X.hash
local NAME = "sundial"
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local ST = { "#4a4560", "#6a6580", "#8a869c", "#aaa6b4", "#cac6cc", "#ebe6e0" }
local BR = { "#4a2f1f", "#7a4e24", "#a9732c", "#d29a3a", "#efc45a", "#fff0a0" }
local PAT = { "#2d4a44", "#41685a", "#5c8a6a", "#86ad7c", "#b3cf8c" }
local MOSS = { "#1f3b2c", "#2f5a34", "#4b8040", "#76a84c" }
c:groundShadow(32, 56, 22, 3)
-- pedestal
local ped = HP.mask()
for y = 34, 49 do
  local hw
  if y <= 36 then hw = 9 - (36 - y) * 0 elseif y <= 38 then hw = 6 elseif y <= 43 then hw = 5.5
  else hw = 5.5 + (y - 43) * 0.9 end
  for x = floor(32 - hw + 0.5), floor(32 + hw - 0.5) do ped:set(x, y) end
end
local pn = X.pillow(ped, 8)
local bias = {}
ped:each(function(x, y) if y >= 34 and y <= 36 then bias[K(x, y)] = 1 end if (x == 29 or x == 35) and y >= 39 and y <= 44 then bias[K(x, y)] = -1 end end)
G.toneN(c, ped, pn, ST, { amb = 0.12, wrap = 0.2, bias = bias })
for x = 24, 40 do if ped:has(x, 37) then c:put(x, 37, ST[2]) end end
local plinth = c:rect(18, 50, 46, 54)
local plm = X.pillow(plinth, 4, 0.6)
G.toneN(c, plinth, plm, ST, { amb = 0.2, wrap = 0.3 })
for x = 18, 46 do c:put(x, 50, ST[5]) c:put(x, 54, ST[1]) end
-- dial plate
local topM, tn = G.oval(32, 26, 24, 9, 0, 3)
local sideM = G.oval(32, 30, 24, 9, 0, 3)
sideM:cut(topM)
sideM:each(function(x, y) local i = 4 - floor((x - 8) / 13) c:put(x, y, BR[max(1, min(4, i))]) end)
sideM:each(function(x, y) if y == 31 or y == 32 then c:put(x, y, BR[max(1, min(3, 3 - floor((x - 8) / 20)))]) end end)
G.toneN(c, topM, tn, BR, { amb = 0.2, wrap = 0.4, cuts = { 0.3, 0.5, 0.65, 0.8, 0.92 } })
local face = topM:copy():shrink(2)
local fv = {}
face:each(function(x, y) local k = K(x, y) local i = 3 + floor((32 - x) / 14 + 0.5) c:put(x, y, PAT[max(2, min(4, i))]) if H(x, y, 3) > 0.9 then c:put(x, y, PAT[1]) end end)
-- hour ticks
for i = 0, 12 do
  local a = i * pi / 6
  for _, r in ipairs{ 16.5, 18 } do
    local x, y = floor(32 + cos(a) * r + 0.5), floor(26 + sin(a) * r * 0.37 + 0.5)
    if face:has(x, y) then c:put(x, y, BR[1]) end
  end
end
-- gnomon shadow on the dial
local sh = c:poly{ {35, 26}, {37, 26}, {51, 30}, {48, 30} }
sh:each(function(x, y) if face:has(x, y) then c:put(x, y, PAT[1]) end end)
-- gnomon fin
local fin = c:poly{ {28, 26}, {36, 26}, {33, 8}, {32, 8} }
fin:each(function(x, y)
  local rel = (y - 8) / 18
  if x <= 32 + rel * -0.0 + (rel * 1.5 - 1.2) then c:put(x, y, rel < 0.15 and BR[6] or BR[5]) else c:put(x, y, rel < 0.5 and BR[3] or BR[2]) end
end)
for y = 8, 26 do c:put(32, y, BR[4]) end
for x = 29, 35 do c:put(x, 26, BR[1]) end
c:put(32, 8, BR[6]) c:put(32, 9, BR[6])
-- moss on the plinth and shaft
for _, p in ipairs{ {19,50},{20,50},{21,50},{22,50},{19,51},{20,51},{21,52},{19,53},{20,53},{26,47},{27,47},{26,48},{27,48},{28,49},{26,49},{43,50},{44,50},{44,51} } do
  c:put(p[1], p[2], MOSS[H(p[1], p[2], 4) > 0.5 and 3 or 2])
end
c:put(20, 49, MOSS[4]) c:put(21, 49, MOSS[3])
-- quirk: ladybug on the dial
for _, p in ipairs{ {21,25},{22,25},{23,25},{21,26},{22,26},{23,26} } do c:put(p[1], p[2], "#d03a3a") end
c:put(22, 26, "#2b1c26") c:put(23, 25, "#ff8a6a") c:put(20, 26, "#2b1c26")
G.save(c, NAME)
