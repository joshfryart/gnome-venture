-- Chimney Nest (bb-chimney-nest), perch sprite 36x36. Opus second pass, hand-built at this size.
-- Brick chimney (bigger, simpler bricks) on a slate roof slice, stone cap, wide twig nest, the dozing stork
-- with its red bill over the rim. Pill eyes and smile on the chimney. quirk: the striped sock drying on a twig.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("bb-chimney-nest-perch", 36)

local BRK  = { "#4a1c22", "#7a2a2a", "#a4402e", "#c8603a", "#e08a52", "#f2b680" }
local MOR  = { "#5e4a4e", "#7e6a66", "#a08c82", "#bcab9c", "#d4c6b4", "#e8dece" }
local STN  = { "#3a3648", "#57536a", "#78748a", "#9a97aa", "#bdbac8", "#dcdae2" }
local SLT  = { "#26283e", "#363a58", "#4a5074", "#626a90", "#8088ac", "#a2aac6" }
local TWG  = { "#3a2218", "#5c361e", "#82522a", "#a87038", "#c89452", "#e2b878" }
local STK  = { "#7a6e84", "#a39ab0", "#cbc4d2", "#e9e4ec", "#f6f2f2" }
local BILL = { "#7a2018", "#b8361e", "#e05a2a", "#f48a4a" }
local SOCK = { "#7a1e2e", "#b8324a", "#d84a5e", "#ece4dc" }

local roof = c:poly{ { 3, 34 }, { 3, 32 }, { 33, 28 }, { 33, 34 } }
O.shade(c, roof, SLT, { R = 2, amb = .3, wrap = .4 })
local stack = c:poly{ { 11, 17 }, { 24, 17 }, { 24, 30 }, { 11, 32 } }
local sI, sT = O.shade(c, stack, BRK, { R = 3, amb = .22, wrap = .35, sep = BRK[1], rim = true })
for k, i in pairs(sI) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  if c.own[y * c.w + x] == sT then
    local row = (y - 18) // 3
    local face = x >= 13 and x <= 22 and y >= 20 and y <= 27
    if not face and (y - 18) % 3 == 2 then c.pix[y * c.w + x] = MOR[math.max(1, math.min(6, i))]:lower()
    elseif not face and (x - 11 + (row % 2) * 2) % 5 == 4 and i >= 2 then c.pix[y * c.w + x] = BRK[i - 1]:lower() end
  end
end
O.shade(c, c:rect(9, 15, 26, 17), STN, { R = 1, amb = .3, sep = STN[1] })

-- stork
O.shade(c, c:ellipse(19.5, 10.5, 6, 3.5), STK, { R = 2, amb = .3, cuts = { .25, .5, .72, .9 }, sep = STK[1] })
O.dots(c, { { 23, 9 }, { 24, 10 }, { 25, 10 }, { 24, 11 } }, "#463a48")
local nk, nn = O.tube({ { 16, 10 }, { 15, 8 }, { 14, 6 }, { 13, 5 } }, function(t) return 1.6 end)
O.shadeN(c, nk, nn, STK, { amb = .35, cuts = { .25, .5, .72, .9 } })
O.shade(c, c:ellipse(12.5, 4, 2.5, 2), STK, { R = 1, amb = .35, cuts = { .25, .5, .72, .9 }, sep = STK[1] })
O.flat(c, c:line({ { 10, 4 }, { 8, 6 }, { 6, 8 } }, 1), BILL[3], "bill") O.dot(c, 9, 4, BILL[2]) O.dot(c, 10, 5, BILL[2])
O.dots(c, { { 12, 4 }, { 13, 4 } }, P.ink)

-- nest
local nest = c:ellipse(17.5, 13.5, 11, 3.5)
nest:add(c:line({ { 6, 12 }, { 5, 11 } }, 1)) nest:add(c:line({ { 29, 13 }, { 30, 12 } }, 1))
local tI, tT = O.shade(c, nest, TWG, { R = 2, amb = .22, wrap = .4, sep = TWG[1], rim = true })
O.tex(c, tI, tT, TWG, function(x, y, i) if (x + 2 * y) % 5 == 0 and i >= 2 then return -1 end end)

-- face
c:eyeSmall(14, 21) c:eyeSmall(20, 21)
O.dot(c, 12, 25, "#f5809f") O.dot(c, 23, 25, "#f5809f")
O.dots(c, { { 16, 25 }, { 17, 26 }, { 18, 26 }, { 19, 25 } }, P.ink)

-- quirk: sock on a twig
O.flat(c, c:line({ { 28, 14 }, { 31, 15 } }, 1), TWG[3], "twig")
O.flat(c, c:rect(29, 16, 31, 19), SOCK[2], "sock") O.dots(c, { { 31, 19 }, { 32, 19 }, { 31, 20 }, { 32, 20 }, { 29, 20 }, { 30, 20 } }, SOCK[2])
O.dots(c, { { 29, 16 }, { 30, 16 }, { 31, 16 }, { 29, 18 }, { 30, 18 }, { 31, 18 } }, SOCK[4])

O.done(c, "bb-chimney-nest-perch")
