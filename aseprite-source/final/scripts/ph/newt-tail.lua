-- newt-tail: the Cistern Newt's dropped tail. A long, thick-based tail that snakes
-- up to the upper left and flicks up at the thin tip, with a scalloped aqua fin crest along its back
-- in the newt's own skin and gill colours. The cut end is sewn shut: seam plus button.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local skin = GV.ramp("#8f7060")      -- same skin ramp as creature-cistern-newt
local gill = GV.ramp("#3f93b2")      -- the newt's gill aqua, used for the fin crest

-- centre line: thick cut end at the lower right, S-curve up-left, tip flicks up
local K = { {51,49,6.5}, {44,45,6}, {36,44,5.2}, {29,41,4.5}, {24,35,3.6},
            {21,28,2.8}, {18,22,2.2}, {14,17,1.6}, {12,12,1.2}, {12,10,1.2} }
local path = {}
for i = 1, #K - 1 do                          -- Catmull-Rom through the knots
  local p0, p1, p2, p3 = K[math.max(i - 1, 1)], K[i], K[i + 1], K[math.min(i + 2, #K)]
  for s = 0, 9 do
    local u = s / 10
    local q = {}
    for j = 1, 3 do
      q[j] = 0.5 * (2 * p1[j] + (-p0[j] + p2[j]) * u + (2 * p0[j] - 5 * p1[j] + 4 * p2[j] - p3[j]) * u * u
             + (-p0[j] + 3 * p1[j] - 3 * p2[j] + p3[j]) * u * u * u)
    end
    path[#path + 1] = q
  end
end
local tail = c:mask()
for _, q in ipairs(path) do tail:add(c:ellipse(q[1], q[2], q[3], q[3])) end
-- flat cut across the thick end, perpendicular to the tail
tail:cut(c:poly({ { 40, 63 }, { 63, 40 }, { 63, 63 } }))

-- fin crest along the upper-right (back) edge of the middle run, scalloped
local fin = tail:shift(3, -3):cut(tail):clip(c:poly({ { 17, 0 }, { 46, 0 }, { 46, 40 }, { 17, 26 } }))
for _, n in ipairs({ { 25, 26 }, { 31, 33 }, { 38, 38 } }) do fin:cut(c:rect(n[1], n[2] - 3, n[1] + 1, n[2])) end

local p = c:build{
  { "fin",  fin,  gill, { flat = true } },
  { "tail", tail, skin, { gloss = { 23, 33 } } },
}
-- bean spots down the flank
c:spot(c:rect(36, 47, 37, 48))
c:spot(c:rect(29, 44, 30, 45))
c:spot(c:rect(23, 38, 24, 39))
-- sewn cut end: seam along the stump, button at its head
c:seam({ { 43, 56 }, { 56, 43 } })
c:button(49, 41)

local t = c:save(D .. "final/aseprite/ph/newt-tail.aseprite", PNG .. "newt-tail.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
