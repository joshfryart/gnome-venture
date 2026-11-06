-- feast-orchard-crumble (Opus single pass, aB30_4). A round cream-glazed pie dish with flared walls and a cobalt band,
-- heaped with a lumpy golden oat crumble; a spoonful has been scooped from the front right, showing glossy red apple-
-- and-bramble filling with pale apple slices, and a silver spoon stands in the scoop.
-- Material: per-pixel cylinder light on the glazed wall (6 tones) with a curved painted band, beveled rim lip, pillow-lit
-- crumble with toasted crumbs and oat flakes, AO inside the scoop, bevelled spoon with a specular streak.
-- quirk: fruit juice has bubbled over the rim and runs down the dish in one glossy drip.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB30_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min = math.floor, math.sqrt, math.max, math.min
local NAME = "feast-orchard-crumble"
local c = A.new2(NAME)
local CER  = { "#6a5a6a", "#9a8a92", "#c4b6aa", "#e2d6c0", "#f4ecd8", "#fffaee" }
local CRUM = { "#6a3a1e", "#9a5a2a", "#c4843e", "#e0a856", "#f2c878", "#fbe4a8" }
local FIL  = { "#4a1424", "#7a1e30", "#a8303c", "#cc4a4a", "#e6767a", "#ffb0a8" }
local MET  = { "#3a3c56", "#5a5c78", "#8486a0", "#aaaabc", "#d0d0dc", "#f2f2f6" }
local CX, CY, RX, RY = 32, 30, 21, 7.5

c:groundShadow(32, 50, 21, 2)
-- dish wall
local wall = HP.poly({ { CX - RX, CY }, { CX + RX, CY }, { CX + RX - 3, 44 }, { CX - RX + 3, 44 } }):add(A.ell(CX, 44, RX - 3, 3.5))
local outer = A.ell(CX, CY, RX, RY)
local wb = {}
wall:each(function(x, y) if y >= 46 then wb[K(x, y)] = -1 end end)
local widx = A.shadeN(c, wall, A.vn(wall, CX - RX, CX + RX, 0.15), CER, { bias = wb, wrap = 0.3 })
-- cobalt band following the front curve
local function front(x) local u = (x - CX) / RX return CY + RY * sqrt(max(0, 1 - u * u)) end
wall:each(function(x, y)
  local d = y - front(x)
  local i = widx[K(x, y)] or 3
  if d >= 3.5 and d < 5.5 then c:put(x, y, i >= 4 and "#5a7ed0" or (i >= 2 and "#3a56a6" or "#283c78")) end
  if d >= 6.5 and d < 7.5 then c:put(x, y, i >= 4 and "#7a96d8" or "#3a56a6") end
end)
for y = 34, 44 do c:put(CX - RX + 4 + floor((y - 34) * 0.25), y, CER[6]) end
-- rim lip
local inner = A.ell(CX, CY + 0.4, RX - 2.5, RY - 1.8)
A.pil(c, outer:copy():cut(inner), CER, 1, { wrap = 0.3 })
-- crumble heap
local heap = inner:copy():add(A.ell(CX, CY - 2, RX - 5, RY - 2.5))
for i = 0, 9 do
  local x = CX - 13 + i * 3 + (i % 2)
  heap:add(A.ell(x, CY - 3 - (i % 3) * 0.8 + (math.abs(x - CX) > 10 and 1.5 or 0), 2.2, 1.8))
end
local scoop = A.ell(CX + 8, CY + 1.2, 5.5, 2.8)
local hb = {}
heap:each(function(x, y) local h = A.hash(x, y, 5)
  if h > 0.78 then hb[K(x, y)] = -1 elseif h < 0.1 then hb[K(x, y)] = 1 end end)
A.cast(hb, heap, A.ell(CX + 8, CY - 1, 5.5, 2), 0, 2, -1)
local hidx = A.shadeN(c, heap, X.pillow(heap, 2.6), CRUM, { bias = hb, wrap = 0.25 })
heap:each(function(x, y) local h = A.hash(x, y, 9)
  if h > 0.965 and (hidx[K(x, y)] or 1) >= 4 then c:put(x, y, "#fff2d0")       -- oat flake
  elseif h < 0.035 then c:put(x, y, "#5a2e1a") end end)                         -- toasted crumb
-- juice bubbling at the edge
for _, p in ipairs{ { 14, 32 }, { 15, 33 }, { 47, 32 }, { 21, 34 } } do c:put(p[1], p[2], FIL[3]) end
c:put(14, 31, FIL[5])
-- scooped hole: filling with AO under the crumble lip
local fb = {}
scoop:each(function(x, y) if y <= CY then fb[K(x, y)] = -2 elseif y <= CY + 1 then fb[K(x, y)] = -1 end end)
A.shadeN(c, scoop, X.pillow(scoop, 2), FIL, { bias = fb })
A.dots(c, { { CX + 4, CY + 2 }, { CX + 5, CY + 3 }, { CX + 6, CY + 3 }, { CX + 7, CY + 3 } }, "#f2d890")
A.dots(c, { { CX + 5, CY + 2 }, { CX + 6, CY + 2 } }, "#c89848")
A.dots(c, { { CX + 11, CY + 1 }, { CX + 12, CY + 2 } }, "#f2d890")
c:put(CX + 9, CY + 2, "#ffe0d8")
-- spoon standing in the scoop
local sm, sT, sS = A.cyl(c, CX + 9, CY + 1, CX + 22, CY - 18, function(t) return t > 0.88 and 1.7 or 1.05 end, MET, { wrap = 0.3 })
sm:each(function(x, y) local k = K(x, y) if sS[k] < -0.3 and sT[k] > 0.15 and sT[k] < 0.8 then c:put(x, y, MET[6]) end end)
A.dots(c, { { CX + 9, CY + 1 }, { CX + 10, CY + 1 }, { CX + 10, CY } }, FIL[2])
c:put(CX + 11, CY - 1, FIL[4])
-- quirk: juice drip over the front rim
local fx = CX - 9
local fy = floor(front(fx))
local drip = HP.rect(fx, fy - 2, fx + 1, fy + 3):add(A.ell(fx + 0.5, fy + 5, 1.5, 1.8)):add(A.ell(fx + 0.5, fy - 2, 2.2, 1))
A.pil(c, drip, FIL, 1.2)
c:put(fx, fy + 5, "#ffe0d8") c:put(fx, fy, FIL[6])
A.save2(c, NAME)
