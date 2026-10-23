-- newt-tail: the Cistern Newt's dropped tail. A long, thick-based tail that sweeps
-- left and curls up into a hook at the tip, with a thin aqua fin crest along its top
-- and the newt's pale clay-slick sheen. The cut end is sewn shut: seam plus button.
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local skin = GV.ramp("#8f7060")      -- same skin ramp as creature-cistern-newt
local gill = GV.ramp("#3f93b2")      -- the newt's gill aqua, used for the fin crest

-- centre line: from the thick cut end (right) sweeping left, then curling up
local path = {}
local N = 60
for i = 0, N do
  local t = i / N
  local x, y
  if t < 0.6 then
    local u = t / 0.6
    x = 50 - u * 30
    y = 40 + 4 * math.sin(u * math.pi)
  else
    local u = (t - 0.6) / 0.4                 -- curl: arc around a centre
    local a = math.pi / 2 + u * 1.25 * math.pi
    x = 20 + math.cos(a) * 9 * (1 - 0.25 * u) * -1
    y = 31 + math.sin(a) * 9 * (1 - 0.25 * u)
  end
  path[#path + 1] = { x, y, 7.5 - 6 * t }
end
local tail = c:mask()
for _, q in ipairs(path) do tail:add(c:ellipse(q[1], q[2], q[3], q[3])) end
tail:cut(c:rect(55, 0, 63, 63))             -- flat cut end

-- fin crest: the tail's top edge raised 3 px, along the straight run only
local fin = tail:shift(0, -3):cut(tail):clip(c:rect(24, 0, 50, 63))

local p = c:build{
  { "fin",  fin,  gill, { flat = true } },
  { "tail", tail, skin, { gloss = { 41, 34 } } },
}
-- pale sheen line along the back (like the creature)
local sheen = c:mask()
for _, q in ipairs(path) do
  local x, y = math.floor(q[1] + 0.5), math.floor(q[2] - q[3] + 1.5)
  if x > 22 and x < 47 then sheen:set(x, y) end
end
c:fill(sheen:clip(p.tail.m), "#b8d8d2")
-- bean spots down the flank
c:spot(c:ellipse(44, 41, 1.5, 1))
c:spot(c:ellipse(36, 44, 1.5, 1))
c:spot(c:ellipse(28, 44, 1, 1))
-- sewn cut end: seam down the stump, button at its head
c:seam({ { 52, 35 }, { 52, 47 } })
c:button(51, 31)

local t = c:save(D .. "final/aseprite/ph/newt-tail.aseprite", PNG .. "newt-tail.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
