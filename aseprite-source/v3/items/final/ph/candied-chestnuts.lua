-- candied-chestnuts (lean P1pilot)
local NAME = "candied-chestnuts"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function ball(m, R, ramp, nm, o) local n = X.pillow(m, R) o = o or {} o.tok = { r = { name = nm } } if not o.cuts then o.cuts = {0.2,0.38,0.55,0.72,0.86} end G.toneN(c, m, n, ramp, o) return n end
local GLZ = { "#5a2410", "#8a3c14", "#b8601c", "#dc8a2a", "#f4b648", "#ffe08a" }
local CUP = { "#7a6a9a", "#a898c0", "#cfc4dc", "#ece6f0", "#fffaf6" }
local RIB = { "#6a1630", "#a02448", "#d4466a" }
c:groundShadow(32, 56, 22, 3)
-- fluted paper cup
local cup = HP.mask()
for y = 36, 54 do local t = (y - 36) / 18; local h = 20 - 8 * t
  for x = floor(32 - h + 0.5), floor(32 + h - 0.5) do cup:set(x, y) end end
G.toneN(c, cup, X.pillow(cup, 14), CUP, { tok = { r = { name = "cup" } }, cuts = {0.2,0.4,0.6,0.8}, amb = 0.1, wrap = 0.25 })
cup:each(function(x, y) if (x % 4 == 0) and y > 38 then c:put(x, y, CUP[2], { r = { name = "cup" } }) elseif (x % 4 == 3) and y > 38 and y < 53 then c:put(x, y, CUP[5], { r = { name = "cup" } }) end end)
-- scalloped rim
for x = 12, 52 do if cup:has(x, 36) and x % 4 < 2 then c:put(x, 35, CUP[4], { r = { name = "cup" } }) end end
-- ribbon + bow
for x = 13, 51 do for y = 44, 46 do if cup:has(x, y) then c:put(x, y, y == 44 and RIB[3] or (y == 45 and RIB[2] or RIB[1]), { r = { name = "rib" } }) end end end
for _, p in ipairs{ {28,43},{29,43},{30,44},{31,44},{34,44},{35,44},{36,43},{37,43},{27,44},{38,44},{27,45},{38,45},{28,46},{37,46} } do c:put(p[1], p[2], RIB[2], { r = { name = "bow" } }) end
for _, p in ipairs{ {32,44},{32,45},{33,45},{32,46} } do c:put(p[1], p[2], RIB[3], { r = { name = "bow" } }) end
for _, p in ipairs{ {31,47},{31,48},{34,47},{35,48} } do c:put(p[1], p[2], RIB[1], { r = { name = "bow" } }) end
-- three glazed marrons
local nuts = { {20, 31, 8, 7}, {44, 31, 8, 7}, {32, 24, 9, 8} }
for i, s in ipairs(nuts) do
  local m = c:ellipse(s[1], s[2], s[3], s[4])
  if i < 3 then m:cut(c:rect(0, 37, 63, 63)) end
  local n = ball(m, 8, GLZ, "n" .. i, { amb = 0.05, wrap = 0.2 })
  -- crackle seams in the caramel
  m:shrink(1):each(function(x, y) if (x * 3 + y * 5 + i) % 11 == 0 and X.hash(x, y, i) > 0.3 then c:put(x, y, GLZ[2], { r = { name = "n" .. i } }) end end)
  local bx, by = G.specAt(m, n, 28)
  if bx then c:put(bx, by, "#fffbe8", { r = { name = "n" .. i } }) c:put(bx + 1, by, "#fff4c0", { r = { name = "n" .. i } }) c:put(bx, by + 1, "#fff4c0", { r = { name = "n" .. i } }) end
end
-- bitten top nut: pale cream interior
for _, p in ipairs{ {35,19},{36,19},{37,19},{38,20},{36,20},{37,20},{38,21},{37,21},{39,22} } do c:put(p[1], p[2], p[2] < 20 and "#fff2cc" or "#f2d08c", { r = { name = "n3" } }) end
-- sugar crystals
for _, p in ipairs{ {10,24},{54,22},{26,13},{47,15} } do c:put(p[1],p[2],"#fff4c0") c:put(p[1]+1,p[2],"#f4b648") c:put(p[1]-1,p[2],"#f4b648") c:put(p[1],p[2]-1,"#f4b648") c:put(p[1],p[2]+1,"#f4b648") end
G.save(c, NAME)
