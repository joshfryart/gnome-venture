-- newt-tail: the Cistern Newt's dropped tail. A long, thick-based tail that snakes
-- up to the upper left and flicks up at the thin tip, with a scalloped aqua fin crest along its back
-- in the newt's own skin and gill colours. The cut end is sewn shut: seam plus button.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local skin = GV.ramp("#8f7060")      -- same skin ramp as creature-cistern-newt
local gill = GV.ramp("#3f93b2")      -- the newt's gill aqua, used for the fin crest

-- centre line: thick cut end at the left, sweeping right, tip curling up
local K = { {12,40,7}, {20,41,6.5}, {28,43,5.6}, {36,43,4.6}, {43,39,3.6},
            {48,33,2.7}, {51,27,2}, {52,21,1.6}, {51,16,1.3}, {49,13,1.2} }
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
-- flat cut across the thick end
tail:cut(c:rect(0, 0, 8, 63))

-- fin crest along the top (back) edge of the middle run, scalloped
local fin = tail:shift(0, -4):cut(tail):clip(c:rect(17, 0, 44, 63))
for _, x in ipairs({ 23, 30, 37 }) do fin:cut(c:rect(x, 0, x + 1, 63):cut(tail:shift(0, -2))) end

local p = c:build{
  { "fin",  fin,  gill, { flat = true } },
  { "tail", tail, skin, { gloss = { 13, 36 } } },
}
-- bean spots down the flank
c:spot(c:rect(21, 43, 22, 44))
c:spot(c:rect(30, 45, 31, 46))
c:spot(c:rect(38, 41, 39, 42))
-- sewn cut end: seam along the stump, button at its head
c:seam({ { 11, 37 }, { 11, 48 } })
c:button(10, 33)

local t = c:save(D .. "final/aseprite/ph/newt-tail.aseprite", PNG .. "newt-tail.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
