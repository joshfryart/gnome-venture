-- Husk Hopper (mh-husk-hopper), yard sprite 64x64. Opus pass, art-2701-opus.
-- Bloomcaller, common. A young grasshopper popping up out of a corn husk: three straw-green husk
-- leaves as a cup, big folded hind legs with knees up high on both sides, long antennae, mouth
-- pressed shut (it says nothing at all). quirk: a husk leaf worn as a floppy hat, tip drooping.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("husk-hopper-yard", 64)

local GRN  = { "#1f4a3a", "#2f6e44", "#4c9a48", "#74c056", "#a3dc6c", "#d0f08e" }
local HUSK = { "#55542c", "#7a7838", "#a29f4a", "#c4bf66", "#ded98c", "#f2edb6" }
local HAT  = { "#4f5a2a", "#6f8236", "#93a944", "#b6c95e", "#d4e084", "#ecf2b0" }
local KERN = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }

c:groundShadow(32, 58, 19, 3)

-- hind legs (behind the husk): thick thigh up to a high knee, thin spiny shin down to the ground
local function leg(s)
  local m = function(x) return 32 + s * (x - 32) end
  local th, tn = O.tube({ { m(25), 46 }, { m(19), 41 }, { m(14), 33 }, { m(13), 26 } },
    function(t) return 4.0 - 2.2 * t end)
  O.shadeN(c, th, tn, GRN, { amb = .2 })
  -- stripe on the thigh (grasshopper chevrons)
  for _, p in ipairs({ { 17, 37 }, { 16, 34 }, { 15, 31 } }) do
    O.mark(c, { { m(p[1]), p[2] }, { m(p[1] + 1), p[2] + 1 } }, GRN[2])
  end
  local sh, sn = O.tube({ { m(13), 26 }, { m(11), 34 }, { m(10), 44 }, { m(9), 54 } }, function() return 1.1 end)
  O.shadeN(c, sh, sn, GRN, { amb = .25, sep = GRN[1] })
  O.dots(c, { { m(8), 38 }, { m(7), 46 } }, GRN[3]) -- spines
  local ft = c:rect(math.min(m(7), m(11)), 56, math.max(m(7), m(11)), 57)
  O.shade(c, ft, GRN, { R = 1, amb = .3, sep = GRN[1] })
end
leg(1) leg(-1)

-- back husk leaf (darker, behind the body)
local back = c:poly{ { 20, 50 }, { 22, 34 }, { 32, 40 }, { 42, 34 }, { 44, 50 } }
O.shade(c, back, { HUSK[1], HUSK[1], HUSK[2], HUSK[2], HUSK[3], HUSK[3] }, { R = 2 })

-- body + head popping out
local body = c:ellipse(32, 31, 11.5, 10.5):add(c:ellipse(32, 41, 8, 6))
O.shade(c, body, GRN, { sphere = { 30, 30, 13 }, amb = .18, wrap = .35 })

-- front husk leaves: three pointed straw leaves, midribs, separation lines
local leaves = {
  { pts = { { 17, 57 }, { 9, 33 }, { 21, 42 }, { 28, 57 } }, rib = { { 12, 38 }, { 17, 48 }, { 21, 55 } } },
  { pts = { { 47, 57 }, { 55, 33 }, { 43, 42 }, { 36, 57 } }, rib = { { 52, 38 }, { 47, 48 }, { 43, 55 } } },
  { pts = { { 23, 57 }, { 32, 39 }, { 41, 57 } }, rib = { { 32, 43 }, { 32, 50 }, { 32, 55 } } },
}
for i, L in ipairs(leaves) do
  local m = c:poly(L.pts)
  O.shade(c, m, HUSK, { R = 2.5, amb = .25, sep = HUSK[1] })
  local r = L.rib
  for j = 1, #r - 1 do
    local seg = c:line({ r[j], r[j + 1] }, 1)
    seg:each(function(x, y) if m:has(x, y) and c:get(x, y) ~= HUSK[1] then O.mark(c, { { x, y } }, HUSK[2]) end end)
  end
end
-- fibre lines on the husk (material)
O.mark(c, { {28,49},{27,51},{27,52},{36,49},{37,51},{37,52},{14,42},{15,45},{50,42},{49,45} }, HUSK[3])
-- front arms resting on the rim
O.shade(c, c:rrect(23, 42, 27, 44, 1), GRN, { R = 1, amb = .35, sep = GRN[1] })
O.shade(c, c:rrect(37, 42, 41, 44, 1), GRN, { R = 1, amb = .35, sep = GRN[1] })
O.dots(c, { {24,44},{26,44},{38,44},{40,44} }, GRN[2])

-- quirk: husk-leaf hat: one dry husk leaf laid over the head, stem end up-left, tip flopping down the right
local HP4 = { { 19, 25 }, { 24, 15 }, { 41, 14 }, { 49, 36 } }
local hm, hn, hT = O.tube(HP4, function(t)
  if t > .9 then return .7 end
  return 1.4 + 2.8 * math.sin(math.pi * math.min(1, t / .9)) ^ .7 end)
O.shadeN(c, hm, hn, HUSK, { amb = .3, wrap = .45, sep = HUSK[1] })
for i = 4, 46 do -- midrib along the leaf
  local x, y = O.bez(HP4, i / 50)
  local px, py = math.floor(x + .5), math.floor(y + .5)
  if hm:has(px, py) then O.mark(c, { { px, py } }, i % 9 == 0 and HUSK[4] or HUSK[2]) end
end
O.mark(c, { {25,16},{26,16},{31,15},{32,15} }, HUSK[6]) -- sheen
O.dots(c, { {18,26},{17,27} }, HUSK[2]) -- torn stem end

-- antennae out through the hat
local function ant(pts, tip)
  c:line(pts, 1):each(function(x, y) O.dot(c, x, y, GRN[2]) end)
  O.dots(c, { tip }, GRN[4])
end
ant({ { 28, 14 }, { 24, 8 }, { 19, 4 } }, { 18, 4 })
ant({ { 36, 14 }, { 40, 8 }, { 45, 4 } }, { 46, 4 })

-- face: big eyes, cheeks, a tiny pressed-shut mouth
c:eyeLocked(24, 26)
c:eyeLocked(35, 26)
c:cheek(22, 32) c:cheek(40, 32)
O.dots(c, { {31,35},{32,35},{33,35} }, GRN[1])
O.dot(c, 30, 34, GRN[2]) O.dot(c, 34, 34, GRN[2])

O.done(c, "husk-hopper-yard")
