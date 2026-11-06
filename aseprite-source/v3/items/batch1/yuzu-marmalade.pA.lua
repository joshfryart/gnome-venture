-- yuzu-marmalade pass A. Slim straight-sided glass jar (22 px), green gingham cap pinched by twisted twine,
-- translucent amber marmalade with peel shreds, empty glass headspace, small paper label with a yuzu.
-- quirk: a glossy drip of marmalade escaping from under the cloth down the glass.
local H = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_h.lua")
local HP, X, c, P = H.new("yuzu-marmalade.pA")
local K, floor, max, min = H.K, math.floor, math.max, math.min
local function put(x, y, h) c:put(x, y, h) end

local GLASS = { "#3d6f8a", "#5f97ad", "#8cc0cc", "#b7e0e0", "#d9f3ee", "#f2fff9" }
local MARM  = { "#7a2c16", "#ad4a1a", "#d8721c", "#f09a20", "#ffbf38", "#ffe27a" }
local CLOTH = { "#a59a86", "#c9bea4", "#e2d8bd", "#f1e9cf", "#fbf5e1", "#fffbee" }
local GING  = { "#24544a", "#2f6e4f", "#3f9150", "#5aa957", "#7cc35a", "#a8d873" }
local TWINE = { "#5a3424", "#86552f", "#b07c45", "#d4a868" }

c:groundShadow(32, 59, 13, 2)
-- jar: neck 26..37, shoulder 23..28, body 21..42 to 57
local jar = c:rrect(21, 26, 42, 57, 3):add(c:rect(25, 21, 38, 27)):add(c:rrect(23, 24, 40, 30, 3))
local function vlight(x, x0, x1) local t = ((x - x0) / (x1 - x0)) * 2 - 1 return t end
jar:each(function(x, y)
  local t = vlight(x, 21, 42)
  local i = (t < -0.75) and 5 or (t < -0.2) and 4 or (t < 0.45) and 3 or (t < 0.8) and 2 or 1
  put(x, y, GLASS[i])
end)
-- marmalade fill (inset 2, top y36)
local fill = c:rrect(23, 36, 40, 55, 2)
fill:each(function(x, y)
  local t = vlight(x, 23, 40)
  local i = (t < -0.7) and 4 or (t < -0.1) and 5 or (t < 0.4) and 4 or (t < 0.75) and 3 or 2
  if t > 0.25 and t < 0.6 and y > 40 and y < 52 then i = i + 1 end      -- light glowing through (subsurface)
  if y == 36 then i = 6 end                                              -- meniscus catches light
  if y == 37 then i = max(2, i - 1) end
  if y >= 54 then i = max(1, i - 1) end
  put(x, y, MARM[min(6, i)])
end)
put(23, 36, MARM[4]) put(40, 36, MARM[3]) put(23, 35, MARM[5]) put(40, 35, MARM[4])
-- peel shreds (pale strip, dark underside)
for _, s in ipairs{ {25,40,1}, {33,39,-1}, {29,44,1}, {36,46,1}, {26,50,-1}, {33,52,1}, {38,41,-1} } do
  local x, y, d = s[1], s[2], s[3]
  for i = 0, 2 do
    local px, py = x + i, y + (d > 0 and floor(i / 2) or -floor(i / 2))
    if fill:has(px, py) then put(px, py, MARM[6]) end
    if fill:has(px, py + 1) then put(px, py + 1, MARM[2]) end
  end
end
-- glass base: thick bottom, pale
for x = 22, 41 do put(x, 56, GLASS[x < 30 and 5 or 3]) end
for x = 23, 40 do put(x, 57, GLASS[x < 28 and 3 or 2]) end
-- glass speculars: tall broken streak on the left, short one right
for y = 30, 53 do if y ~= 42 and y ~= 43 then put(23, y, GLASS[6]) end end
for y = 31, 38 do put(24, y, GLASS[5]) end
for y = 44, 49 do put(39, y, "#ffe9b8") end
-- label
local lab = c:rrect(26, 43, 37, 51, 2)
lab:each(function(x, y)
  local i = 4
  if x == 26 or y == 43 then i = 5 end
  if x == 37 or y == 51 then i = 2 end
  put(x, y, CLOTH[i])
end)
local yu = c:ellipse(31, 47, 2.5, 2.5)
yu:each(function(x, y) put(x, y, (x + y < 77) and "#ffe066" or (x + y < 80) and "#f5c02e" or "#d98a22") end)
put(30, 46, "#fff6b0") put(33, 44, GING[4]) put(34, 44, GING[3]) put(34, 43, GING[4])
-- cloth cap: puff above the twine, skirt below
local puff = c:rrect(23, 12, 40, 21, 4)
local skirt = c:poly{ {25,22},{38,22},{43,29},{20,29} }
-- pinked edge: zig-zag bottom
for x = 20, 43 do if (x % 3) == 1 then skirt:set(x, 30) end end
local cap = puff:copy():add(skirt)
local cn = X.pillow(cap, 3)
local cv = X.light(cn, { amb = 0.1, wrap = 0.3 })
cap:each(function(x, y)
  local i = floor(cv[K(x, y)] * 5.99) + 1
  if y >= 22 and ((x - 31) * 2 + (y - 22) * 0) % 7 == 0 then i = max(1, i - 1) end   -- fold lines
  local sx, sy = floor((x - 20) / 3) % 2 == 0, floor((y - 12) / 3) % 2 == 0
  local col
  if sx and sy then col = GING[max(1, i - 1)] elseif sx or sy then col = GING[min(6, i + 1)] else col = CLOTH[min(6, i)] end
  put(x, y, col)
end)
-- twine (twisted) pinching the neck
for x = 24, 39 do
  put(x, 21, TWINE[(x % 2 == 0) and 4 or 3]) put(x, 22, TWINE[(x % 2 == 0) and 2 or 3])
end
-- bow + dangling ends
c:paint({ "ab.", "bcb", ".b." }, 36, 20, { a = TWINE[4], b = TWINE[3], c = TWINE[1] })
for _, p in ipairs{ {39,23},{40,24},{40,25},{41,26},{41,27},{42,28},{42,29} } do put(p[1], p[2], TWINE[3]) end
for _, p in ipairs{ {37,23},{37,24},{38,25},{38,26},{38,27},{39,28} } do put(p[1], p[2], TWINE[2]) end
put(43, 30, TWINE[4]) put(39, 29, TWINE[4])
-- quirk: drip down the glass from under the skirt
for y = 31, 35 do put(28, y, MARM[4]) end
put(28, 31, MARM[5]) put(27, 34, MARM[4]) put(27, 35, MARM[5]) put(28, 36, MARM[3]) put(27, 36, MARM[3])
H.fin(c)
