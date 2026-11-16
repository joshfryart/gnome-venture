-- Sap Drip (mw-sap-drip), yard sprite 64x64. Opus pass, art-2701-opus.
-- Brewroot, common. A dollop of maple sap with a curled top, glassy amber (bright rim, glowing
-- pale core, a hard specular), sitting in its own sticky puddle with one drip running down its
-- side, mid-yawn (always a little late). quirk: a tiny fly stuck in its middle.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("sap-drip-yard", 64)

local AMB = { "#6e3412", "#a5521a", "#d27a22", "#eca23a", "#f8c860", "#fde49a" }

-- puddle (flat, darker amber with a lit far rim)
local pud = c:ellipse(31, 56, 20, 3.5)
local pt = O.flat(c, pud, AMB[3], "puddle")
pud:each(function(x, y)
  if not pud:has(x, y - 1) then c:put(x, y, AMB[4], pt) end
  if not pud:has(x, y + 1) or not pud:has(x + 1, y + 1) then c:put(x, y, AMB[2], pt) end
end)
O.mark(c, { {17,55},{18,55},{19,55},{43,56},{44,56} }, AMB[6]) -- puddle glints

-- body: dollop with a curled tip
local body = c:ellipse(31, 43, 15, 12.5)
local curl, _, cT = O.tube({ { 31, 34 }, { 34, 24 }, { 31, 16 }, { 24, 16 } }, function(t) return 7 - 6 * t end)
body:add(curl)
-- drip down the right side into the puddle
local drip = O.tube({ { 43, 46 }, { 45, 49 }, { 45, 52 }, { 45, 54 } }, function(t) return 1.4 + .6 * t end)
body:add(drip)
O.shade(c, body, { AMB[1], AMB[2], AMB[3], AMB[3], AMB[4], AMB[5] }, { sphere = { 28, 36, 18 }, amb = .2, wrap = .3 })
-- translucency: glowing pale core low in the body, bright inner rim on the shade side
local core = c:ellipse(32, 28, 4.5, 4):clip(body)
core:each(function(x, y)
  local d = ((x - 32) / 4.5) ^ 2 + ((y - 28) / 4) ^ 2
  O.mark(c, { { x, y } }, d < .35 and AMB[6] or (d < .75 and AMB[5] or AMB[4]))
end)
local glow = c:ellipse(33, 50, 8, 3):clip(body) -- light passing through: warm glow low in the body
glow:each(function(x, y)
  local d = ((x - 33) / 8) ^ 2 + ((y - 50) / 3) ^ 2
  O.mark(c, { { x, y } }, d < .4 and AMB[5] or AMB[4])
end)
body:edge():each(function(x, y)
  if x + y > 74 and y > 36 and not drip:has(x, y) then
    local e = { { x - 1, y - 1 } }
    O.mark(c, e, AMB[4])
  end
end)
-- spec: hard cream glint + streak upper-left, and one on the curl
O.dots(c, { {21,35},{22,35},{21,36},{22,36} }, P.cream)
O.dots(c, { {20,38},{20,39},{24,33} }, AMB[6])
O.dots(c, { {31,20},{30,21} }, AMB[6])

-- quirk: a fly stuck in the amber, up in the dome above its face, lit by a glowing core
local function fly(dx, dy)
  local function sh(t) local o = {} for i, p in ipairs(t) do o[i] = { p[1] + dx, p[2] + dy } end return o end
  O.dots(c, sh{ {0,2},{0,3} }, "#2f1c18")                                       -- head
  O.dot(c, dx, dy + 2, "#c0443a")                                                 -- red eye
  O.dots(c, sh{ {1,2},{2,2},{3,2},{4,2},{1,3},{2,3},{3,3},{4,3},{5,3} }, "#4a2a1e") -- body
  O.dots(c, sh{ {3,3},{5,3} }, "#7a4a24")                                         -- stripes
  O.dots(c, sh{ {2,1},{2,0},{3,0},{3,-1},{4,-1}, {4,1},{5,1},{5,0},{6,0},{6,-1},{7,-1} }, "#eef4ec") -- wings
  O.dots(c, sh{ {3,1},{4,0},{7,0} }, "#9fb4b0")
  O.dots(c, sh{ {1,4},{3,4},{5,4} }, "#6e3412")                                   -- legs
end
fly(28, 26)

-- face: eyes, cheeks, a sleepy yawn
c:eyeLocked(22, 36)
c:eyeLocked(35, 36)
c:cheek(19, 42) c:cheek(41, 42)
O.dots(c, { {29,44},{30,44},{31,44},{28,45},{32,45},{28,46},{32,46},{29,47},{30,47},{31,47} }, "#6e2038") -- yawn
O.dots(c, { {29,45},{30,45},{31,45} }, "#6e2038") O.dots(c, { {29,46},{30,46},{31,46} }, "#e8493b")

O.done(c, "sap-drip-yard")
