-- Chimney Nest (bb-chimney-nest), yard sprite 64x64. Opus second pass (art-2701-pals-all/c03/opus2), built on the
-- Haiku first pass. Uncommon, seedkeeper, Birchbramble. "A stork's nest on a chimney, and a stork who never moves out."
-- Rebuilt silhouette (the first pass read as a loaf on a box): a tall brick chimney with staggered bricks, mortar,
-- a stone cap with soot, standing on a slice of slate roof; a wide shaggy twig nest overhangs the cap with sticks
-- poking out, and a fat cream stork sits snug in it, dozing (closed eye), long red bill resting over the rim.
-- The chimney is the pal and wears the face. quirk: the stork has hung a striped sock to dry on a nest twig.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("bb-chimney-nest-yard", 64)

local BRK  = { "#4a1c22", "#7a2a2a", "#a4402e", "#c8603a", "#e08a52", "#f2b680" }
local MOR  = { "#5e4a4e", "#7e6a66", "#a08c82", "#bcab9c", "#d4c6b4", "#e8dece" }
local STN  = { "#3a3648", "#57536a", "#78748a", "#9a97aa", "#bdbac8", "#dcdae2" }
local SLT  = { "#26283e", "#363a58", "#4a5074", "#626a90", "#8088ac", "#a2aac6" }
local TWG  = { "#3a2218", "#5c361e", "#82522a", "#a87038", "#c89452", "#e2b878" }
local STK  = { "#7a6e84", "#a39ab0", "#cbc4d2", "#e9e4ec", "#f6f2f2" }
local BILL = { "#7a2018", "#b8361e", "#e05a2a", "#f48a4a" }
local DARK = { "#2e2632", "#463a48" }
local SOCK = { "#7a1e2e", "#b8324a", "#d84a5e", "#ece4dc" }

-- slate roof slice under the chimney
local roof = c:poly{ { 5, 61 }, { 5, 57 }, { 59, 49 }, { 59, 61 } }
local rI, rT = O.shade(c, roof, SLT, { R = 3, amb = .3, wrap = .4, rim = true })
O.tex(c, rI, rT, SLT, function(x, y, i)
  local yy = y + math.floor((x - 5) * 8 / 54) -- rows follow the slope
  if yy % 4 == 0 and i >= 2 then return -1 end
  if yy % 4 == 1 and ((x + math.floor(yy / 4) * 3) % 6 == 0) and i >= 2 then return -1 end
end)

-- chimney stack
local stack = c:poly{ { 20, 30 }, { 42, 30 }, { 42, 52 }, { 20, 55 } }
local sI, sT = O.shade(c, stack, BRK, { R = 4, amb = .22, wrap = .35, sep = BRK[1], rim = true, bounce = "#7a6a9a", bmax = 2 })
for k, i in pairs(sI) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  if c.own[y * c.w + x] == sT then
    local row = (y - 31) // 3
    local mortar = (y - 31) % 3 == 2 or (x - 20 + (row % 2) * 3) % 6 == 5
    if mortar then c.pix[y * c.w + x] = MOR[math.max(1, math.min(6, i))]:lower()
    elseif H(x, y, 3) > .9 and i >= 2 then c.pix[y * c.w + x] = BRK[i - 1]:lower() end
  end
end
-- soot under the cap
for x = 21, 41 do if c:get(x, 30) then c:put(x, 30, BRK[1], sT) end end

-- stone cap
local cap = c:rect(17, 27, 45, 30)
O.shade(c, cap, STN, { R = 1, amb = .3, sep = STN[1], rim = true })

-- stork body (mostly inside the nest), wing tips dark
local sb = c:ellipse(34, 20, 10, 6)
local kI, kT = O.shade(c, sb, STK, { R = 4, amb = .3, wrap = .4, cuts = { .25, .5, .72, .9 }, sep = STK[1], rim = true })
O.tex(c, kI, kT, STK, function(x, y, i) if x >= 39 and y >= 18 then return -(i - 1) end end)
O.mark(c, { { 40, 17 }, { 42, 18 }, { 43, 19 }, { 44, 20 } }, DARK[2])
-- neck and head
local nk, nn = O.tube({ { 28, 18 }, { 26, 14 }, { 24, 11 }, { 23, 8 } }, function(t) return 2.6 - t * .5 end)
O.shadeN(c, nk, nn, STK, { amb = .35, cuts = { .25, .5, .72, .9 }, sep = STK[1] })
local hd = c:ellipse(22, 7, 4, 3.5)
O.shade(c, hd, STK, { R = 2, amb = .35, cuts = { .25, .5, .72, .9 }, sep = STK[1], rim = true })
-- long red bill resting down over the rim
local bl, bn = O.tube({ { 19, 8 }, { 15, 10 }, { 12, 13 }, { 10, 17 } }, function(t) return 1.5 - t * .9 end)
O.shadeN(c, bl, bn, BILL, { amb = .35, cuts = { .3, .55, .8 }, sep = BILL[1] })
-- dozing: a closed lid arc
O.dots(c, { { 20, 6 }, { 21, 7 }, { 22, 7 }, { 23, 6 } }, P.ink)
O.dot(c, 24, 9, "#f5809f")

-- shaggy twig nest overhanging the cap
local nest = c:ellipse(31, 25, 19, 6.5)
nest:add(c:ellipse(31, 22.5, 16, 4))
for _, s in ipairs({ { 11, 23, 9, 21 }, { 12, 27, 9, 29 }, { 50, 22, 53, 20 }, { 50, 27, 54, 28 }, { 18, 30, 16, 32 }, { 44, 30, 47, 32 }, { 30, 19, 29, 17 } }) do
  nest:add(c:line({ { s[1], s[2] }, { s[3], s[4] } }, 1))
end
local tI, tT = O.shade(c, nest, TWG, { R = 3, amb = .22, wrap = .4, sep = TWG[1], rim = true, bounce = "#6a5a7a", bmax = 2 })
O.tex(c, tI, tT, TWG, function(x, y, i) -- woven sticks: two crossing diagonal strands
  if (x + 2 * y) % 7 == 0 and i >= 2 then return -1 end
  if (x - 2 * y) % 9 == 0 and i <= 5 then return 1 end
  if (x - 3 * y) % 11 == 0 and i >= 3 then return -2 end
end)

-- face on the chimney
c:eyeLocked(24, 37) c:eyeLocked(34, 37)
c:cheek(22, 43) c:cheek(39, 43)
O.dots(c, { { 28, 44 }, { 29, 45 }, { 30, 45 }, { 31, 45 }, { 32, 45 }, { 33, 44 } }, P.ink)

-- quirk: a striped sock drying on a twig
O.flat(c, c:line({ { 49, 25 }, { 56, 27 } }, 1), TWG[3], "twig")
local sock = c:poly{ { 53, 27 }, { 56, 27 }, { 56, 33 }, { 58, 34 }, { 58, 36 }, { 53, 36 } }
O.shade(c, sock, { SOCK[1], SOCK[2], SOCK[3] }, { R = 1, amb = .4, cuts = { .35, .7 } })
O.mark(c, { { 53, 29 }, { 54, 29 }, { 55, 29 }, { 56, 29 }, { 53, 32 }, { 54, 32 }, { 55, 32 }, { 56, 32 } }, SOCK[4])
O.mark(c, { { 53, 27 }, { 54, 27 }, { 55, 27 }, { 56, 27 } }, SOCK[4])

O.done(c, "bb-chimney-nest-yard")
