-- broken-tide-pail-and-scoop (aB12_4, Opus single pass). Squat red tin beach pail (tapered, rolled steel rim, cream
-- wave band, embossed foot ridge) heaped with sand, thin steel bail handle; a teal plastic scoop with a dished blade
-- and ring grip leans at its right. broken: the pail is split down the front from a bitten-out rim notch, and the
-- scoop handle is snapped through; a red paint flake flies off. quirk: a pink scallop shell on top of the sand.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, abs, max, min, sin = math.floor, math.sqrt, math.abs, math.max, math.min, math.sin
local c = A.new("broken-tide-pail-and-scoop")
local T, S, SD, TL = A.TIN, A.STEEL, A.SAND, A.TEAL
local CX = 26
c:groundShadow(33, 54, 22, 2)

-- bail handle (behind the sand)
local bm, bnn = A.tube({ { CX - 15, 31 }, { CX - 17, 10 }, { CX + 17, 10 }, { CX + 15, 31 } }, function() return 0.85 end)
A.tone(c, bm, bnn, S, { amb = 0.2 })

-- sand heap
local top, bot = 29, 50
local sand = c:ellipse(CX, top, 12, 6)
sand:clip(c:rect(0, 0, 63, top + 1))
local sn = X.sphere(CX - 1, top + 1, 12, sand)
A.tone(c, sand, sn, SD, { amb = 0.15 })
sand:each(function(x, y) if X.hash(x, y, 4) > 0.82 then A.dk(c, x, y, SD, 1) elseif X.hash(x, y, 8) > 0.9 then c:px(x, y, SD[6]) end end)

-- body
local function hw(y) return 14.5 - (y - top) * (3 / (bot - top)) end
local body = HP.mask()
for y = top, bot + 2 do
  local w = hw(min(y, bot))
  for x = floor(CX - w + .5), floor(CX + w - .5) do
    local dx = (x + 0.5 - CX) / w
    if y <= bot + 2 * sqrt(max(0, 1 - dx * dx)) then body:set(x, y) end
  end
end
A.tone(c, body, A.vn(body, CX - 14.5, CX + 14.5), T, { amb = 0.1, wrap = 0.3 })
-- cream wave band
local band = HP.mask()
for x = CX - 14, CX + 14 do
  local yb = 39 + floor(sin(x * 0.9) + .5)
  for y = yb, yb + 1 do if body:has(x, y) then band:set(x, y) end end
end
band:each(function(x, y) local t = (x - CX) / 14 c:px(x, y, t < 0.35 and A.CREAM or "#e9c9c0") end)
-- embossed foot ridge
for x = CX - 12, CX + 12 do
  local dx = (x + 0.5 - CX) / 12
  local y = floor(bot - 2 + 1.6 * sqrt(max(0, 1 - dx * dx)) + .5)
  if body:has(x, y) then A.dk(c, x, y, T, 2) end
  if body:has(x, y - 1) and x < CX + 4 then c:px(x, y - 1, T[6]) end
end
-- specular streak
for y = top + 4, 37 do c:px(CX - 8, y, T[6]) end
for y = 42, 45 do c:px(CX - 8, y, T[6]) end
c:px(CX - 8, top + 4, A.CREAM)
-- rolled steel rim (front half over the sand, back half hidden by the heap)
local rimO = c:ellipse(CX, top, 15, 3)
local rimI = c:ellipse(CX, top, 13, 1.6)
local rim = rimO:copy():cut(rimI)
rim:each(function(x, y) if y < top and sand:has(x, y) then rim.s[K(x, y)] = nil end end)
A.tone(c, rim, A.vn(rim, CX - 15, CX + 15), S, { amb = 0.15 })
rim:each(function(x, y) if not rim:has(x, y - 1) and x < CX + 6 then c:px(x, y, S[6]) end end)
A.ao(c, body, rim, T, 1)
-- ears
for _, ex in ipairs{ CX - 15, CX + 15 } do c:px(ex, 31, S[2]) c:px(ex, 32, S[1]) end

-- scoop (leans at the right)
local blade = c:poly{ { 42, 39 }, { 52, 39 }, { 53, 47 }, { 50, 52 }, { 45, 52 }, { 42, 47 } }
local hdl = A.rod(c, 47.5, 40, 50.5, 19, 1.3, TL)
local ring = c:ellipse(51, 15, 3, 3):cut(c:ellipse(51, 15, 1, 1))
A.pil(c, ring, TL, 1.2)
A.ao(c, hdl, ring, TL, 1)
A.pil(c, blade, TL, 2)
-- dish: concave interior lit from the opposite side
local dish = blade:shrink(2)
local dn = {}
for k, v in pairs(X.pillow(dish, 2)) do dn[k] = { -v[1], -v[2], v[3] } end
A.tone(c, dish, dn, TL, { amb = 0.05, cuts = { 0.3, 0.45, 0.6, 0.75, 0.9 } })
dish:each(function(x, y) if not dish:has(x, y - 1) then A.dk(c, x, y, TL, 1) end end)
c:px(44, 41, TL[6]) c:px(45, 41, TL[6])
c:px(48, 37, A.CREAM)
-- sand crumbs in the scoop
c:px(48, 48, SD[4]) c:px(49, 49, SD[3]) c:px(47, 49, SD[5])

-- damage 1: rim notch + split down the front of the pail
local nx = CX + 6
A.erase(c, c:poly{ { nx - 1, top - 2 }, { nx + 3, top - 2 }, { nx + 1, top + 3 } })
A.erase(c, A.lmask{ { nx + 1, top + 3 }, { nx, top + 6 }, { nx + 1, top + 9 }, { nx, top + 11 } })
A.poly(c, { { nx, top + 12 }, { nx + 1, top + 15 }, { nx, top + 17 } }, A.INK)
c:px(nx - 1, top + 5, T[6]) c:px(nx - 1, top + 9, T[6])
-- damage 2: scoop handle snapped through
A.erase(c, A.lmask{ { 47, 29 }, { 51, 28 } })
A.erase(c, A.lmask{ { 47, 30 }, { 51, 29 } })
c:px(49, 31, TL[6])
-- paint flake flying upper-right
A.chip(c, { { 40, 22 }, { 43, 21 }, { 42, 24 } }, T)

-- quirk: scallop shell on the sand
local sh = c:ellipse(CX + 3, top - 4, 2.5, 2)
sh:cut(c:rect(0, top - 2, 63, 63)):add(c:rect(CX + 2, top - 3, CX + 4, top - 2))
A.pil(c, sh, A.WORM, 1, { amb = 0.3 })
c:px(CX + 2, top - 5, A.WORM[3]) c:px(CX + 4, top - 5, A.WORM[3]) c:px(CX + 3, top - 6, A.WORM[6])
A.fin(c)
