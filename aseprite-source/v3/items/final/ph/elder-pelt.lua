-- elder-pelt (lean P1b_O0)
-- quirk: a bone bead and a red bead braided into the hide at one ear. Silver-grey old-wolf pelt, fur-side up, white blaze, ragged fringe.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "elder-pelt" }
local pi, sin, cos, floor, max, min, abs = math.pi, math.sin, math.cos, math.floor, math.max, math.min, math.abs
local FUR = { "#34324a", "#55536f", "#797792", "#a2a0b8", "#cdcbda", "#f1eff5" }
local BLAZE = { "#7c7a96", "#a7a5be", "#d2d0e0", "#f4f2f8", "#fdfbff" }
local pelt = HP.mask()
local function add(cx, cy, rx, ry, a) local m = G.oval(cx, cy, rx, ry, a or 0, 1) pelt:add(m) end
add(32, 33, 13, 17)         -- body
add(32, 14, 6.5, 6)         -- head
add(25.5, 8.5, 2.6, 3.4, -0.3) add(38.5, 8.5, 2.6, 3.4, 0.3) -- ears
add(32, 7, 3, 2.5)          -- snout bridge
add(17, 20, 4.5, 8, 0.6) add(47, 20, 4.5, 8, -0.6)      -- fore legs
add(17, 46, 4.5, 9, -0.55) add(47, 46, 4.5, 9, 0.55)    -- hind legs
local tm = G.tube({ {32,48}, {31,54}, {36,58}, {41,55} }, function(t) return 4.4 * (1 - t * 0.55) end)
pelt:add(tm)
-- ragged edge
local ragged = HP.mask()
pelt:each(function(x, y)
  local nb = (pelt:has(x - 1, y) and 1 or 0) + (pelt:has(x + 1, y) and 1 or 0) + (pelt:has(x, y - 1) and 1 or 0) + (pelt:has(x, y + 1) and 1 or 0)
  if nb < 4 and X.hash(x, y, 21) < 0.3 then else ragged:set(x, y) end
end)
pelt = ragged
pelt:copy():grow(1):each(function(x, y)
  if not pelt:has(x, y) and X.hash(x, y, 22) > 0.8 and y > 12 then pelt:set(x, y) end
end)
local n = X.pillow(pelt, 9)
local bias = {}
pelt:each(function(x, y) local k = K(x, y)
  -- fur tufts: short diagonal strokes
  local f = (x + y * 0.7) % 4
  if f < 0.8 and X.hash(x, y, 5) > 0.35 then bias[k] = (bias[k] or 0) - 1 end
  if (x - y * 0.7) % 5 < 0.8 and X.hash(x, y, 6) > 0.6 then bias[k] = (bias[k] or 0) + 1 end
  -- darker saddle
  if abs(x - 32) < 5 and y > 20 and y < 44 and X.hash(x, y, 7) > 0.2 then bias[k] = (bias[k] or 0) - 1 end
end)
G.toneN(c, pelt, n, FUR, { bias = bias, amb = 0.1, wrap = 0.3, tok = { r = { name = "fur" } } })
-- white blaze on head/muzzle
local blaze = G.oval(32, 12.5, 2.5, 6.5, 0, 1)
blaze:each(function(x, y) if pelt:has(x, y) then c:px(x, y, BLAZE[(X.hash(x, y, 2) > 0.5) and 3 or 4]) end end)
-- eyes shut (age) and nose
c:px(29, 12, FUR[1]) c:px(30, 12, FUR[1]) c:px(34, 12, FUR[1]) c:px(35, 12, FUR[1])
c:px(32, 5, FUR[1]) c:px(31, 5, FUR[1]) c:px(33, 5, FUR[1])
-- ear inners
c:px(25, 9, FUR[2]) c:px(26, 9, FUR[2]) c:px(38, 9, FUR[2]) c:px(39, 9, FUR[2])
-- tail tip pale
for _, p in ipairs{ {40,55}, {41,55}, {41,56}, {40,56} } do if pelt:has(p[1], p[2]) then c:px(p[1], p[2], FUR[6]) end end
-- bone + red bead braid hanging off the left ear
c:line({ {23,11}, {22,14}, {23,17} }, 1):each(function(x, y) c:px(x, y, "#7a5530") end)
c:fillMask(c:rect(21, 15, 23, 16), "#f0e3c0") c:px(21, 15, "#fffaf0") c:px(23, 16, "#b8a47a")
c:fillMask(c:rect(22, 19, 24, 20), "#d83a3a") c:px(22, 19, "#ff9a8c") c:px(24, 20, "#8c1c2a")
-- belly-edge shade glints
pelt:copy():cut(pelt:copy():shrink(1)):each(function(x, y) if x > 36 and y > 24 then c:px(x, y, FUR[2]) end end)
G.save(c, "elder-pelt")
