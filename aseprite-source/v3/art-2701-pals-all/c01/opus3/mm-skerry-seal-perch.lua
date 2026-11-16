-- Skerry Seal (mm-skerry-seal), perch sprite 36x36. Opus third pass (c01/opus3), richness pass over opus2: the
-- uninvented fish is a bold 9x5 pale outline (body, tail fork, eye, two gaps so it still reads as "not drawn
-- in yet"); a sheen streak on the back, a pale ring on the spots, a crack and a wet band on the rock, a door
-- at the lighthouse foot, a ripple in the sea.
-- Seal on a dark wet skerry with a sea band, head big and raised (pill eyes, pale muzzle, dark nose, open
-- barking mouth), a few spots; the lighthouse cut to a 4 px striped tower with a lit lamp and red cap.
-- quirk: the uninvented fish, a dotted pale outline above the tail.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("mm-skerry-seal-perch", 36)

local SEAL = { "#262234", "#3c3648", "#565062", "#77707e", "#9a929c", "#c2b8bc" }
local BELY = { "#8a8494", "#b4aeb8", "#d8d2d4", "#ece6e2" }
local ROCK = { "#1e1e2e", "#2e3044", "#454a60", "#62687e", "#8288a0", "#a8aec0" }
local SEA  = { "#1d3f63", "#25628a", "#2f8fae", "#4fbcc4", "#8ee0d4", "#d2f6ea" }

local sea = c:ellipse(18, 31, 14, 1.2)
sea:each(function(x, y) c:put(x, y, y <= 30 and ((x % 5 == 0) and SEA[6] or SEA[4]) or SEA[2], { r = { name = "sea" } }) end)
local rock = c:poly{ { 4, 31 }, { 6, 27 }, { 14, 26 }, { 26, 25 }, { 31, 27 }, { 32, 31 } }
local rI, rT = O.shade(c, rock, ROCK, { R = 2, amb = .15, wrap = .3, sep = ROCK[1], rim = true })
O.tex(c, rI, rT, ROCK, function(x, y, i) if y >= 30 then return -1 end end)
O.dots(c, { { 8, 28 }, { 27, 28 } }, "#d8d0c8")
O.mark(c, { { 16, 27 }, { 17, 28 }, { 17, 29 } }, ROCK[2]) O.mark(c, { { 18, 28 }, { 18, 29 } }, ROCK[5])
-- lighthouse
local tw = c:rect(27, 12, 30, 25)
tw:each(function(x, y)
  local red = ((y - 12) // 3) % 2 == 0
  c:put(x, y, red and (x < 29 and "#c43a3a" or "#7c1c34") or (x < 29 and "#f4ece0" or "#a8a0a0"), { r = { name = "tower" } })
end)
O.flat(c, c:rect(27, 9, 30, 10), "#f5b82e", "lamp") O.dot(c, 28, 9, "#ffe38a")
O.flat(c, c:rect(26, 11, 31, 11), ROCK[3], "gallery")
O.flat(c, c:rect(28, 7, 29, 8), "#c43a3a", "cap") O.dot(c, 27, 8, "#c43a3a") O.dot(c, 30, 8, "#7c1c34")
O.dots(c, { { 28, 23 }, { 28, 24 } }, "#4a2c2a")
-- seal
O.shade(c, c:poly{ { 3, 21 }, { 7, 23 }, { 9, 26 }, { 5, 26 }, { 3, 25 } }, SEAL, { R = 1, amb = .2, sep = SEAL[1] })
local body = c:ellipse(13, 23, 8, 3.5)
body:add(c:poly{ { 13, 21 }, { 15, 15 }, { 22, 15 }, { 23, 23 }, { 18, 26 } })
local sI, sT = O.shade(c, body, SEAL, { R = 3, amb = .04, wrap = .25, sep = SEAL[1], rim = true, bounce = "#4f7a9a", bmax = 2 })
O.mark(c, { { 9, 21 }, { 12, 20 }, { 15, 22 }, { 17, 18 } }, SEAL[2])
O.mark(c, { { 10, 21 }, { 13, 20 }, { 18, 18 } }, SEAL[5])
O.mark(c, { { 8, 20 }, { 9, 20 }, { 10, 19 }, { 11, 19 } }, SEAL[6]) -- wet sheen
O.shade(c, c:poly{ { 19, 18 }, { 22, 18 }, { 22, 24 }, { 18, 25 } }, BELY, { R = 1, amb = .35, cuts = { .3, .55, .8 } })
local head = c:ellipse(19, 12, 6, 5)
O.shade(c, head, SEAL, { R = 3, amb = .4, wrap = .5, sep = SEAL[1], rim = true })
O.shade(c, c:ellipse(20.5, 15.5, 3, 1.5), BELY, { R = 1, amb = .4, cuts = { .3, .55, .8 } })
O.dots(c, { { 20, 14 }, { 21, 14 } }, SEAL[1])
O.dots(c, { { 20, 16 }, { 21, 16 }, { 20, 17 } }, P.ink)
c:eyeSmall(15, 10)
c:eyeSmall(21, 10)
O.dot(c, 15, 14, P.petal.base)
O.done(c, "mm-skerry-seal-perch", function(c)
  local rows = { "x...xxx..", "xx.x...x.", ".xx..o..x", "xx.x...x.", "x...x.x.." }
  for j, r in ipairs(rows) do for i = 1, #r do
    local ch = r:sub(i, i)
    if ch == "x" or ch == "o" then c:put(1 + i, 9 + j, "#e2e8f2") end
  end end

  c:put(25, 15, "#eef3f8") c:put(25, 17, "#eef3f8")
end)
