-- starlight-hammock (lean D2o_12)
-- Navy woven hammock slung between two posts on twisted ropes, stitched with golden stars; star tassel dangles below.
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch1/_g0.lua")
local HP, X, K = G.HP, G.X, G.K
local sin, cos, pi, abs, floor, max, min, sqrt, atan2 = math.sin, math.cos, math.pi, math.abs, math.floor, math.max, math.min, math.sqrt, math.atan
local function solid(c, m, ramp, R, amb) local n = X.pillow(m, R) local idx = G.tone(c, m, X.light(n, { amb = amb or 0.1, wrap = 0.25 }), ramp) return n, idx end
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "starlight-hammock" }
local WOOD = { "#3a2218", "#5a3624", "#7d4d30", "#a2693c", "#c58a52", "#e3b072" }
local NAVY = { "#161a44", "#232f70", "#3a52a4", "#5a80cc", "#8cb0ea", "#c8defa" }
local ROPE = { "#6b4a2b", "#9a6f3e", "#c79a5a", "#e8c98a" }
c:groundShadow(32, 57, 27, 2)
for _, r in ipairs{ {5, 9}, {54, 58} } do
  local p = c:rect(r[1], 14, r[2], 57)
  solid(c, p, WOOD, 3.2)
  for y = 18, 55, 3 do if X.hash(r[1], y, 5) > 0.45 then c:px(r[1] + 2, y, WOOD[2]) end end
  c:fillMask(c:ellipse((r[1] + r[2]) / 2, 14, 3, 2), WOOD[5])
end
local ROPEC = ROPE
local function rope(pts) G.line(c, pts, ROPE[2]) for i, p in ipairs(pts) do end end
local function topy(x) local u = (x - 31.5) / 13.5 return 22 + 16 * (1 - u * u) end
local function boty(x) local u = (x - 31.5) / 13.5 return topy(x) + 2 + 9 * max(0, 1 - u * u) ^ 0.8 end
local cloth = HP.mask()
for x = 18, 45 do for y = floor(topy(x)), floor(boty(x)) do cloth:set(x, y) end end
-- ropes (behind cloth ends)
for _, d in ipairs{ -1, 0, 1 } do
  G.line(c, { {9, 21 + d}, {18, 22 + d * 1} }, ROPE[2])
  G.line(c, { {54, 21 + d}, {45, 22 + d * 1} }, ROPE[2])
end
for x = 10, 17, 2 do c:px(x, 21, ROPE[4]) end
for x = 46, 53, 2 do c:px(x, 21, ROPE[4]) end
c:fillMask(c:ellipse(9, 21, 1.5, 2), ROPE[3]) c:fillMask(c:ellipse(54, 21, 1.5, 2), ROPE[3])
local n, idx = solid(c, cloth, NAVY, 5.5)
cloth:each(function(x, y) local k = K(x, y)
  if (x + y) % 3 == 0 and idx[k] and idx[k] > 1 then c:px(x, y, NAVY[idx[k] - 1]) end
  if (x - y) % 7 == 0 and idx[k] and idx[k] < 6 and idx[k] > 2 then c:px(x, y, NAVY[idx[k] + 1]) end
end)
local function star(x, y)
  if not (cloth:has(x - 1, y) and cloth:has(x + 1, y) and cloth:has(x, y - 1) and cloth:has(x, y + 1)) then return end
  for _, d in ipairs{ {-1, 0}, {1, 0}, {0, -1}, {0, 1} } do c:px(x + d[1], y + d[2], "#f5c842") end
  c:px(x, y, "#fff6a0")
end
star(25, 40) star(35, 44) star(31, 37) star(40, 38) star(21, 36)
-- quirk: star tassel
G.line(c, { {31, 49}, {31, 52} }, ROPE[3])
for _, d in ipairs{ {-2, 0}, {-1, 0}, {1, 0}, {2, 0}, {0, -1}, {0, 1}, {0, 2}, {-1, 1}, {1, 1} } do c:px(31 + d[1], 54 + d[2], "#f5c842") end
c:px(31, 54, "#fff6a0") c:px(31, 56, "#c9902a")
G.fin(c, "starlight-hammock")
