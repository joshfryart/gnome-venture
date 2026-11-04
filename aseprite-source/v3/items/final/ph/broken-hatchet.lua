-- broken-hatchet (aB11_5, Opus single pass). Upright hatchet: slim hickory haft with a swelled fawn-foot end,
-- bearded steel head facing left (flat cheek, bright ground bevel along the bit, poll to the right), haft end
-- grain + wedge showing above the eye. Material: per-pixel lit 6-tone steel and wood, grain lanes, AO under the head.
-- broken: a bite chipped out of the bit with a crack running back toward the eye, the chip flying off, and the haft
-- split low down with a splinter peeling away.
-- quirk: a red thread lanyard tied through the haft's hole, loop swinging.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB11_5.lua")
local HP, X, c = A.new("broken-hatchet")
local K = A.K
local W, S = A.ASH, A.STEEL
local floor, max, min, abs = math.floor, math.max, math.min, math.abs

-- head mask first (for haft AO)
local head = c:poly{ {37,12},{37,21},{30,22},{24,23},{19,26},{15,30},{12,28},{11,22},{11,16},{12,11},{15,7},{19,9},{24,11},{30,11} }
head:cut(c:poly{ {9,17},{14,19},{9,22} })      -- the bite out of the bit

-- haft
local hp = { {36,56}, {35,44}, {33,28}, {31,9} }
local function hw(t)
  if t < 0.1 then return 2.8 - t * 9 end
  return 1.75 - t * 0.25
end
local hm, hn, hT, hS, hsm = A.tubeGeo(hp, hw)
local bias = {}
X.ao(bias, hm, head, 2, -1)
local hidx = A.shade(c, hm, hn, W, { bias = bias })
local L = A.blen(hsm)
A.grain(c, hm, hT, hS, hidx, W, { -0.4, 0.15, 0.6 }, L, 3)
-- lanyard hole near the foot
A.set(c, hidx, W, 35, 52, 1) A.set(c, hidx, W, 35, 53, 1) A.set(c, hidx, W, 34, 52, 2)
-- split in the haft + peeling splinter
A.crack(c, { {35,47},{35,44},{34,41},{34,38} }, hidx, W)
local spl = c:line({ {37,44},{38,42},{39,40},{40,39} }, 1)
spl:each(function(x, y) c:put(x, y, (y < 42) and W[6] or W[5]) end)
c:put(37, 45, W[3]) c:put(36, 44, W[2])

-- head: flat cheek, ground bevel band along the bit, rounded top/bottom
local n = X.pillow(head, 1.6)
local xmin = {}
head:each(function(x, y) if not xmin[y] or x < xmin[y] then xmin[y] = x end end)
local bev = {}
head:each(function(x, y) local d = x - xmin[y]
  if x < 27 and d <= 3 then n[K(x, y)] = { -0.62, -0.25, 0.74 } bev[K(x, y)] = d end end)
local sb = {}
head:each(function(x, y) if x >= 34 then sb[K(x, y)] = -1 elseif x >= 16 and y >= 15 then sb[K(x, y)] = -1 end end)        -- poll steps back
local idx = A.shade(c, head, n, S, { bias = sb })
-- bevel edge line (brightest) and ridge (darker step) where the bevel meets the cheek
head:each(function(x, y) local d = bev[K(x, y)]
  if d == 0 then A.set(c, idx, S, x, y, 6)
  elseif d == nil and x < 27 and x - xmin[y] == 4 then A.bump(c, idx, S, x, y, -1) end end)
-- eye: haft wedge in the poll seam, poll seam line
for y = 12, 21 do A.bump(c, idx, S, 33, y, -1) end
-- specular streak along the cheek + sparkle on the edge
for _, p in ipairs{ {25,13},{24,14},{23,15},{22,16} } do A.set(c, idx, S, p[1], p[2], 6) end
c:put(12, 13, A.CREAM)
-- crack from the bite toward the eye
A.crack(c, { {14,19},{17,18},{20,19},{23,18},{25,19} }, idx, S)
-- haft end grain above the eye, with wedge
for x = 29, 33 do if hm:has(x, 9) then c:put(x, 9, W[6]) end if hm:has(x, 10) then c:put(x, 10, W[5]) end end
c:put(31, 9, W[2]) c:put(31, 10, W[1])
-- AO row on the haft right under the head
for x = 28, 35 do if hm:has(x, 23) then c:put(x, 23, W[1]) end end

-- flying chip from the bit (left, slightly below the bite)
local cm, cidx = A.chip(c, { {3,20},{7,22},{5,25} }, S)
c:put(4, 21, S[6])

-- quirk: red thread lanyard through the hole, loop swinging to the right (twisted: 2 tones alternate)
local th = c:line({ {36,52},{39,52},{41,54},{41,57},{39,58},{37,57} }, 1)
local i = 0
for _, p in ipairs{ {36,52},{37,52},{38,52},{39,52},{40,53},{41,54},{41,55},{41,56},{41,57},{40,58},{39,58},{38,57},{37,57} } do
  i = i + 1
  if not hm:has(p[1], p[2]) then c:put(p[1], p[2], (i % 2 == 0) and A.EMBER[5] or A.EMBER[3]) end
end
A.fin(c)
