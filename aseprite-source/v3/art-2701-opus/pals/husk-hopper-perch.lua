-- Husk Hopper (mh-husk-hopper), perch sprite 36x36. Opus pass, drawn at this size by hand:
-- husk cup of three leaves, knees up high, antennae, pill eyes, shut mouth.
-- quirk: the husk-leaf hat, a 2-3 px band with its tip flopping down the right side.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("husk-hopper-perch", 36)

local GRN  = { "#1f4a3a", "#2f6e44", "#4c9a48", "#74c056", "#a3dc6c", "#d0f08e" }
local HUSK = { "#55542c", "#7a7838", "#a29f4a", "#c4bf66", "#ded98c", "#f2edb6" }

c:groundShadow(18, 33, 12, 2)

local function leg(s)
  local m = function(x) return 18 + s * (x - 18) end
  local th, tn = O.tube({ { m(13), 26 }, { m(10), 22 }, { m(7), 18 }, { m(7), 14 } }, function(t) return 2.3 - 1.2 * t end)
  O.shadeN(c, th, tn, GRN, { amb = .2 })
  c:line({ { m(7), 14 }, { m(6), 22 }, { m(5), 31 } }, 1):each(function(x, y) O.dot(c, x, y, GRN[3]) end)
  O.dot(c, m(4), 23, GRN[3])
  O.dots(c, { { m(4), 32 }, { m(5), 32 }, { m(6), 32 } }, GRN[2])
  O.dot(c, m(8), 19, GRN[2]) O.dot(c, m(9), 21, GRN[2])
end
leg(1) leg(-1)

local body = c:ellipse(18, 18, 7, 6.5)
O.shade(c, body, GRN, { sphere = { 17, 17, 8 }, amb = .2, wrap = .35 })

local leaves = {
  { { 10, 32 }, { 5, 19 }, { 12, 24 }, { 16, 32 } },
  { { 26, 32 }, { 31, 19 }, { 24, 24 }, { 20, 32 } },
  { { 13, 32 }, { 18, 22 }, { 23, 32 } },
}
local SIDE = { HUSK[1], HUSK[2], HUSK[2], HUSK[3], HUSK[4], HUSK[5] }
for i, pts in ipairs(leaves) do
  local m = c:poly(pts)
  local b = {}
  O.shade(c, m, i < 3 and SIDE or HUSK, { R = 1.5, amb = .3, sep = HUSK[1] })
end
-- one fibre line per leaf
c:line({ {7,22},{11,30} }, 1):each(function(x, y) O.mark(c, { { x, y } }, HUSK[2]) end)
c:line({ {29,22},{25,30} }, 1):each(function(x, y) O.mark(c, { { x, y } }, HUSK[1]) end)
c:line({ {18,26},{18,30} }, 1):each(function(x, y) O.mark(c, { { x, y } }, HUSK[3]) end)
-- little hands on the rim
O.dots(c, { {13,24},{14,24},{22,24},{23,24} }, GRN[4]) O.dots(c, { {13,25},{23,25} }, GRN[3])

-- quirk: husk-leaf hat
local H4 = { { 11, 14 }, { 13, 9 }, { 23, 8 }, { 26, 17 } }
local hm, hn = O.tube(H4, function(t) if t > .9 then return .6 end return .8 + 1.4 * math.sin(math.pi * t / .9) ^ .7 end)
O.shadeN(c, hm, hn, HUSK, { amb = .3, wrap = .45, sep = HUSK[1] })
for i = 4, 44 do local x, y = O.bez(H4, i / 50) if hm:has(math.floor(x + .5), math.floor(y + .5)) then O.mark(c, { { math.floor(x + .5), math.floor(y + .5) } }, HUSK[3]) end end
O.mark(c, { {14,10},{15,10} }, HUSK[6])

-- antennae
for _, pts in ipairs({ { { 16, 8 }, { 13, 5 }, { 10, 3 } }, { { 20, 8 }, { 23, 5 }, { 26, 3 } } }) do
  c:line(pts, 1):each(function(x, y) O.dot(c, x, y, GRN[2]) end)
end
O.dots(c, { {9,3},{27,3} }, GRN[4])

-- face
c:eyeSmall(14, 15)
c:eyeSmall(21, 15)
O.dot(c, 12, 19, "#f5809f") O.dot(c, 25, 19, "#f5809f")
O.dots(c, { {17,20},{18,20},{19,20} }, GRN[1])

O.shift(c, 0, -1)
O.done(c, "husk-hopper-perch")
