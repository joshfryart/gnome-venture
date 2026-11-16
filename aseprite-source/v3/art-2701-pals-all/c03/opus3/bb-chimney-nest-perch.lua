-- Chimney Nest (bb-chimney-nest), perch sprite 36x36. Opus richness pass (c03/opus3), hand-built at this size.
-- Brick chimney with big bricks (per-brick tone, lit lips) and a clean face panel, chipped stone cap, a deep nest bowl
-- drawn as three bold strands of sticks with dark gaps and two strays (not noise), the dozing stork with black
-- primaries, slate roof with lit tile lips. quirk: the striped sock on a twig
-- (the yard's smoke curl is left off here: fewer, bolder details).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local floor, max, min = math.floor, math.max, math.min
local c = O.canvas("bb-chimney-nest-perch", 36)

local BRK  = { "#3e1820", "#6a2428", "#963a2e", "#bc5838", "#da8450", "#f0b07e" }
local MOR  = { "#4e3e48", "#6e5e62", "#90807c", "#b0a294", "#ccc0ae", "#e4dacb" }
local STN  = { "#33304a", "#4e4b66", "#6e6c86", "#918fa6", "#b6b4c6", "#d8d6e0" }
local SLT  = { "#202238", "#30344f", "#434a6c", "#5a6488", "#7682a6", "#9aa6c4" }
local TWG  = { "#2e1a16", "#4a2c1c", "#6e4426", "#946234", "#b8844a", "#dcb072" }
local STK  = { "#6a6278", "#968ea8", "#c2bccc", "#e4dfe8", "#f4f0ee" }
local BLK  = { "#21182a", "#3a2c42" }
local BILL = { "#6e1c18", "#b0341e", "#de582a", "#f4904c" }
local SOCK = { "#6e1a2a", "#b0304a", "#d84a5e", "#ece2d8" }
local SMK  = { "#8a8aa4", "#b4b4c8", "#dcdce6" }

local roof = c:poly{ { 2, 34 }, { 2, 32 }, { 34, 28 }, { 34, 34 } }
local rI, rT = O.shade(c, roof, SLT, { R = 2, amb = .3, wrap = .4, rim = true })
O.tex(c, rI, rT, SLT, function(x, y, i)
  local yy = y + floor((x - 2) * 4 / 32)
  if yy % 3 == 0 then return 1 end
  if (x + (yy // 3) * 3) % 6 == 0 and i >= 2 then return -1 end
end)

local stack = c:poly{ { 11, 18 }, { 24, 18 }, { 24, 30 }, { 11, 32 } }
local sI, sT = O.shade(c, stack, BRK, { R = 3, amb = .22, wrap = .35, sep = BRK[1], rim = true, bounce = "#7a6a9a", bmax = 2 })
for k, i in pairs(sI) do
  local x, y = k % 1024 - 256, k // 1024 - 256
  local p = y * c.w + x
  if c.own[p] == sT then
    local row = (y - 19) // 3
    local bx = x - 11 + (row % 2) * 2
    local face = x >= 13 and x <= 22 and y >= 21 and y <= 27
    if face then c.pix[p] = BRK[min(5, i)]:lower()
    elseif (y - 19) % 3 == 2 or bx % 5 == 4 then c.pix[p] = MOR[max(1, min(6, i - 1))]:lower()
    else
      local d = H(bx // 5, row, 21) > .6 and 1 or 0
      if (y - 19) % 3 == 0 and i >= 3 then d = d + 1 end
      c.pix[p] = BRK[max(1, min(6, i + d))]:lower()
    end
  end
end
O.mark(c, { { 20, 19 }, { 21, 19 }, { 21, 20 } }, BRK[1]) -- soot
local cap = c:rect(9, 16, 26, 18) cap:cut(c:rect(26, 18, 26, 18))
O.shade(c, cap, STN, { R = 1, amb = .3, sep = STN[1], rim = true })

-- back rim of the nest
O.shade(c, c:ellipse(17.5, 11.5, 11, 2), TWG, { R = 1, amb = .2, wrap = .3, sep = TWG[1] })
-- stork
O.shade(c, c:ellipse(19.5, 9.5, 6, 3.5), STK, { sphere = { 17, 7, 7 }, amb = .3, cuts = { .25, .5, .72, .9 }, sep = STK[1], rim = true })
O.dots(c, { { 23, 9 }, { 24, 9 }, { 25, 10 }, { 24, 10 }, { 25, 9 } }, BLK[1]) O.dots(c, { { 22, 9 }, { 23, 8 } }, BLK[2])
local nk, nn = O.tube({ { 16, 9 }, { 15, 7 }, { 14, 5 }, { 13, 4 } }, function(t) return 1.6 end)
O.shadeN(c, nk, nn, STK, { amb = .35, cuts = { .25, .5, .72, .9 } })
O.shade(c, c:ellipse(12.5, 3.5, 2.5, 2), STK, { R = 1, amb = .35, cuts = { .25, .5, .72, .9 }, sep = STK[1] })
O.flat(c, c:line({ { 10, 4 }, { 8, 6 }, { 6, 9 } }, 1), BILL[3], "bill") O.dot(c, 9, 4, BILL[2]) O.dot(c, 10, 5, BILL[2]) O.dot(c, 6, 9, BILL[2])
O.dots(c, { { 12, 3 }, { 13, 3 } }, P.ink)

-- nest bowl: three bold strands of sticks, dark gaps between
local bowl = c:ellipse(17.5, 11.5, 11.5, 5) bowl:cut(c:rect(0, 0, 35, 11)) bowl:add(c:ellipse(17.5, 12, 11.5, 1))
local nT = { r = { name = "nest" } }
bowl:each(function(x, y) c:put(x, y, (x > 22 or y > 14) and TWG[1] or TWG[2], nT) end)
local function tone(x, y) return max(3, min(6, floor((.7 - .4 * (x - 17.5) / 11 - .4 * (y - 13) / 4) * 4) + 2)) end
for row, y0 in ipairs({ 11, 13, 15 }) do
  local x = 6 + row
  local n = 0
  while x < 30 do
    n = n + 1
    local len = 4 + floor(H(row, n, 5) * 4)
    for xx = x, x + len - 1 do
      local u = (xx - 17.5) / 11.5
      local y = floor(y0 + 1.4 * (1 - u * u) - .5 + (xx - x) * ((n % 2 == 0) and .12 or -.08))
      if bowl:has(xx, y) then c:put(xx, y, TWG[(xx == x and n % 3 == 0) and 6 or tone(xx, y)], nT) end
    end
    x = x + len
  end
end
for _, s in ipairs({ { { 7, 11 }, { 4, 9 } }, { { 28, 12 }, { 31, 10 } } }) do
  O.flat(c, c:line(s, 1), TWG[5], "stray")
end

-- face
c:eyeSmall(14, 22) c:eyeSmall(20, 22)
O.dot(c, 12, 26, "#f5809f") O.dot(c, 23, 26, "#f5809f")
O.dots(c, { { 16, 26 }, { 17, 27 }, { 18, 27 }, { 19, 26 } }, P.ink)

-- quirk: sock on a twig
O.flat(c, c:line({ { 27, 13 }, { 32, 15 } }, 1), TWG[4], "twig")
local sock = c:rect(29, 16, 31, 20) sock:add(c:rect(31, 20, 33, 21)) sock:add(c:rect(29, 21, 30, 21))
O.shade(c, sock, { SOCK[1], SOCK[2], SOCK[3] }, { R = 1, amb = .4, cuts = { .35, .7 }, sep = SOCK[1] })
O.mark(c, { { 29, 16 }, { 30, 16 }, { 31, 16 }, { 29, 18 }, { 30, 18 }, { 31, 18 } }, SOCK[4])
O.done(c, "bb-chimney-nest-perch")
