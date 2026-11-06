-- broken-steel-spade (aB12_4, Opus single pass). Upright digging spade: ash D-grip (crossbar + two slim arms), 4 px ash
-- shaft with grain, brass collar, riveted steel socket strap, tapered steel blade with rolled foot treads, centre frog
-- ridge, honed bright edge and a specular streak. broken: lower-right of the blade snapped away along a crack, with a
-- steel shard flying off. quirk: an earthworm draped over the left tread.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor = math.floor
local c = A.new("broken-steel-spade")
local W, S, B = A.ASH, A.STEEL, A.BRASS

-- D grip
local bar = A.rod(c, 25, 8, 40, 8, 1.6, W, { grain = true, seed = 1 })
local armL = A.rod(c, 26.5, 9, 31.5, 18, 1.2, W, { grain = true, seed = 2 })
local armR = A.rod(c, 38.5, 9, 33.5, 18, 1.2, W, { grain = true, seed = 4 })
A.ao(c, bar, armL:copy():add(armR), W, 1)
-- pale end grain on the bar ends
c:px(25, 7, W[6]) c:px(25, 8, W[5]) c:px(40, 8, W[3])
-- shaft
local shaft = A.rod(c, 32.5, 17, 32.5, 37, 2.0, W, { grain = true, seed = 7 })
-- brass collar where the arms meet the shaft
local col = c:rect(29, 17, 36, 19)
A.pil(c, col, B, 1)
c:px(30, 17, B[6]) c:px(31, 17, B[6])
A.ao(c, shaft, col, W, 2)
-- steel socket strap
local sock = c:poly{ { 29, 34 }, { 36, 34 }, { 38, 42 }, { 27, 42 } }
A.pil(c, sock, S, 1.5)
A.ao(c, shaft, sock, W, 1)
for _, r in ipairs{ { 31, 36 }, { 34, 36 } } do c:px(r[1], r[2], S[1]) c:px(r[1] - 1, r[2] - 1, S[6]) end

-- blade
local blade = c:poly{ { 23, 41 }, { 42, 41 }, { 42, 50 }, { 39, 55 }, { 35, 58 }, { 30, 58 }, { 26, 55 }, { 23, 50 } }
blade:cut(sock)
local _, bn = A.pil(c, blade, S, 3)
-- honed edge: bright bevel along the lower contour
blade:edge():each(function(x, y) if y >= 50 then c:px(x, y, S[5]) end end)
-- rolled treads: bright top row, dark fold row under it
for x = 23, 42 do
  if not sock:has(x, 41) then c:px(x, 41, x < 33 and S[6] or S[5]) c:px(x, 42, S[2]) end
end
A.ao(c, blade, sock, S, 1)
-- frog ridge down the middle
for y = 43, 51 do c:px(32, y, S[5]) c:px(33, y, S[3]) end
c:px(32, 52, S[4])
-- specular streak + glint on the lit left face
for y = 44, 49 do c:px(25, y, S[6]) end
c:px(26, 45, S[6]) c:px(25, 44, A.CREAM)
-- cool bounce along the right side
for y = 44, 49 do if c:get(41, y) then c:px(41, y, "#7f8fb8") end end

-- damage: crack running up from the snapped corner, corner gone
A.poly(c, { { 39, 53 }, { 37, 50 }, { 38, 48 }, { 36, 45 }, { 37, 43 } }, A.INK)
c:px(36, 50, S[6]) c:px(37, 48, S[6]) c:px(35, 45, S[6])
A.erase(c, c:poly{ { 38, 59 }, { 39, 54 }, { 41, 53 }, { 41, 50 }, { 43, 49 }, { 44, 49 }, { 44, 60 } })
-- shard flying off to the lower right
A.chip(c, { { 46, 52 }, { 49, 51 }, { 49, 54 }, { 47, 55 } }, S)
c:px(46, 52, S[6])
c:px(51, 57, S[4]) c:px(52, 57, S[3])

-- quirk: earthworm draped over the left tread
local wm, wn, WT, WS, wl = A.tube({ { 27, 41 }, { 23, 36 }, { 18, 38 }, { 19, 45 } }, function(t) return t > 0.95 and 0.8 or 1.15 end)
wm:cut(c:rect(23, 43, 44, 60))
A.tone(c, wm, wn, A.WORM, { amb = 0.15 })
wm:each(function(x, y) local k = K(x, y) if floor(WT[k] * wl / 2.2) % 2 == 0 and WS[k] > -0.3 then A.dk(c, x, y, A.WORM, 1) end end)
c:px(19, 37, A.WORM[6])
-- tiny face at the worm's tip
c:px(19, 44, A.INK)
A.fin(c)
