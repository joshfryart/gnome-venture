-- stirrup-hoe (lean P1b_O13)
local NAME = "stirrup-hoe"
local G = dofile("/home/user/gnome-venture/aseprite-source/v3/items/batch2/_bbg.lua")
local HP, X, K = G.HP, G.X, G.K
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = NAME }
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local function T(nm) return { r = { name = nm } } end
local WOOD = { "#2e1a14", "#4c2c1e", "#6e4428", "#946238", "#b88450", "#dcaa72" }
local ST = { "#1e2438", "#364060", "#566488", "#7e90b0", "#a8bad4", "#e8f4ff" }
c:groundShadow(24, 57, 20, 3)
-- handle: gently bowed diagonal pole
local hm, hn, Ht = G.tube({ {6, 56}, {13, 47}, {20, 38}, {27, 29} }, function(t) return 1.9 end)
G.toneN(c, hm, hn, WOOD, { tok = T("handle"), cuts = {0.2,0.38,0.55,0.72,0.88}, amb = 0.1, wrap = 0.25 })
hm:each(function(x, y) local t = Ht[K(x, y)] if X.hash(x, y, 4) > 0.82 then c:put(x, y, WOOD[2], T("handle")) end
  if X.hash(x, y, 7) > 0.9 then c:put(x, y, WOOD[5], T("handle")) end end)
-- red cloth wrap with a fluttering tail (quirk)
for _, p in ipairs{ {11,50},{12,49},{13,48},{14,47},{15,46},{10,51} } do
  for _, d in ipairs{ {0,0},{1,0},{0,1} } do local x, y = p[1] + d[1], p[2] + d[2] if hm:has(x, y) then c:put(x, y, (p[1] % 2 == 0) and "#d83a3a" or "#9a1e2e", T("wrap")) end end end
for _, p in ipairs{ {16,48},{17,49},{18,49},{19,50},{19,51} } do c:put(p[1], p[2], "#d83a3a", T("wrap")) end
c:put(17, 48, "#ff8a7a", T("wrap")) c:put(20, 51, "#9a1e2e", T("wrap"))
-- neck rising to the head
local nm, nn = G.tube({ {27, 29}, {29, 26}, {31, 24}, {33, 22} }, function(t) return 2.2 end)
G.toneN(c, nm, nn, ST, { tok = T("neck"), cuts = {0.2,0.38,0.55,0.72,0.88}, amb = 0.1, wrap = 0.3 })
-- ferrule band
for _, p in ipairs{ {25,31},{26,31},{27,31},{28,31},{25,32},{26,32} } do end
local fer = G.tube({ {24, 32}, {25, 31}, {26, 30}, {27, 29} }, function(t) return 2.8 end)
fer:each(function(x, y) c:put(x, y, ((x + y) % 2 == 0) and ST[2] or ST[3], T("fer")) end)
-- stirrup head: flat loop with a sharp bottom edge
local M = HP.mask()
M:add(c:rect(30, 8, 56, 24))
M:cut(c:rect(36, 13, 50, 19))
local sh1, sh2 = M:shift(1, 1), M:shift(-1, -1)
local sh1b, sh2b = M:shift(2, 2), M:shift(-2, -2)
M:each(function(x, y)
  local col = ST[4]
  if not sh2:has(x, y) then col = ST[2]
  elseif not sh2b:has(x, y) then col = ST[3] end
  if not sh1b:has(x, y) then col = ST[5] end
  if not sh1:has(x, y) then col = ST[6] end
  c:put(x, y, col, T("head"))
end)
-- mid-tone streak and bolt
for x = 32, 54 do if X.hash(x, 0, 3) > 0.45 and M:has(x, 10) then c:put(x, 10, ST[5], T("head")) end end
c:fillMask(c:rect(31, 24, 52, 24), ST[1])
for x = 32, 50 do c:put(x, 23, ST[6], T("head")) end
c:put(33, 11, ST[6], T("head")) c:put(33, 10, ST[6], T("head")) c:put(32, 11, ST[5], T("head"))
-- rivets
for _, p in ipairs{ {32,21},{54,21},{54,11} } do c:put(p[1], p[2], ST[1], T("rv")) c:put(p[1] - 1, p[2] - 1, ST[6], T("rv")) end
-- dirt clod stuck on the edge
for _, p in ipairs{ {45,26},{46,26},{47,26},{44,27},{45,27},{46,27},{47,27},{48,27},{46,28} } do c:put(p[1], p[2], (p[2] == 27 or p[1] == 47) and "#5e3a2a" or "#86583a", T("clod")) end
c:put(45, 26, "#ae7e4a", T("clod")) c:put(48, 28, "#3a2420", T("clod"))
G.save(c, NAME)
