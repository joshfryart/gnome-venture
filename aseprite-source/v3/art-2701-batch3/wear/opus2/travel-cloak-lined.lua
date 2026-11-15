-- travel-cloak-lined: Lined rank of the Travel Cloak (Opus second pass, batch3). 64x64.
-- Base: the finished Opus art-2701-opus/wear/travel-cloak.png (read only; it replaces the
-- game ph/travel-cloak.png). Same moss wool cloak on its peg, same drape and V.
-- Lined = a curly fleece ruff rings the neck hole (the old tan lining roll, grown into
-- sheepskin), and both front edges turn back as fleece facings that widen to the hem.
-- quirk kept from base: orange autumn leaf caught on the hem.
local O = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_o2.lua")
local img = O.load(O.ROOT .. "/aseprite-source/v3/art-2701-opus/wear/travel-cloak.png")
local GREEN = { ["#86b464"]=1, ["#5e9452"]=1, ["#45784b"]=1, ["#335f43"]=1, ["#264a3c"]=1, ["#e6bd7e"]=1, ["#b07a46"]=1 }

-- 1. neck ruff: every cloak pixel within 3 px of the dark neck hole (corners cut), plus
--    a few tufts at 4 px so the outer edge is shaggy
local hole = {}
for y = 19, 22 do for x = 26, 35 do if O.get(img, x, y) == "#1c3530" then hole[#hole+1] = { x, y } end end end
local ruff = {}
for y = 15, 23 do for x = 21, 40 do
  local h = O.get(img, x, y)
  if h and GREEN[h] or h == "#3e2420" or h == "#cf9b5c" then
    for _, p in ipairs(hole) do
      local ax, ay = math.abs(p[1] - x), math.abs(p[2] - y)
      local d = math.max(ax, ay)
      if (d <= 3 and ax + ay <= 4) or (d == 4 and ax + ay <= 5 and (x * 7 + y * 3) % 3 == 0) then ruff[y * 64 + x] = true break end
    end
  end
end end
O.wool(img, ruff, { shadeFrom = 34, phase = 1 })
-- keep the hole's dark rim on its lower side (the inside of the hood)
for _, p in ipairs(hole) do if p[2] == 22 then O.px(img, p[1], p[2], "#1c3530") end end

-- 2. fleece facings down both front edges, widening toward the hem
local face = {}
for y = 29, 56 do
  local lx, rx
  for x = 24, 38 do
    local h = O.get(img, x, y)
    if h == "#e6bd7e" and not lx then lx = x end
    if h == "#b07a46" then rx = x end
  end
  if lx and rx then
    local w = (y < 37) and 1 or (y < 49) and 2 or 3
    for x = lx - w + 1, lx do face[y * 64 + x] = true end
    for x = rx, rx + w - 1 do face[y * 64 + x] = true end
  end
end
-- the turned-back corners at the hem
for _, p in ipairs({ { 24, 57 }, { 25, 57 }, { 26, 57 }, { 35, 57 }, { 36, 57 } }) do
  if O.isBody(img, p[1], p[2]) then face[p[2] * 64 + p[1]] = true end
end
O.wool(img, face, { shadeFrom = 33, phase = 2 })
-- a dark fold line where each facing turns back under the green wool
for y = 29, 56 do
  for x = 14, 50 do
    if face[y * 64 + x] and not face[y * 64 + x - 1] and x < 31 and O.isBody(img, x - 1, y) then O.px(img, x - 1, y, "#264a3c") end
    if face[y * 64 + x] and not face[y * 64 + x + 1] and x > 31 and O.isBody(img, x + 1, y) then O.px(img, x + 1, y, "#1c3530") end
  end
end
O.reink(img)
O.save(img, "travel-cloak-lined")
