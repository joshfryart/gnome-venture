-- First draft: npc-hedgehog (Bramble Mossfoot) 64x80 cell, 3/4 top-down. idle(2) + walk(4).
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../lib/hp.lua")
local out = app.params.out or "./"
local NAME = "npc-hedgehog"
-- pose: bob, leg phase, lift, arm swing, sway (leaf/spike jiggle)
local function frame(pose)
  local c = HP.canvas{ w = 64, h = 80, scale = 1, name = NAME }
  local b = -pose.bob
  c:groundShadow(32, 69, 14, 4)
  local lf = pose.leg * 2 + (pose.lift == -1 and -2 or 0)
  local rf = -pose.leg * 2 + (pose.lift == 1 and -2 or 0)
  c:part(c:rrect(22, 63 + lf, 30, 70 + lf, 2), "wood", { band = 1 })
  c:part(c:rrect(34, 63 + rf, 42, 70 + rf, 2), "wood", { band = 1 })
  local la, ra = pose.arm, -pose.arm
  c:part(c:rrect(15, 44 + b + la, 21, 56 + b + la, 3), "moss")
  c:part(c:rrect(43, 44 + b + ra, 49, 56 + b + ra, 3), "moss")
  c:part(c:ellipse(18, 58 + b + la, 3, 2), "wood", { nopop = true })
  c:part(c:ellipse(46, 58 + b + ra, 3, 2), "wood", { nopop = true })
  c:part(c:rrect(20, 44 + b, 44, 65, 6), "moss")
  c:button(32, 58 + b)
  c:part(c:rrect(21, 43 + b, 43, 48 + b, 2), "ember")
  c:part(c:rrect(37, 47 + b, 42, 56 + b, 2), "ember", { band = 1, nopop = true })
  -- spiky crown, different lengths (messy haircut): back row of triangles over head
  local spikes = { {17,7}, {22,3}, {28,0}, {34,5}, {40,1}, {46,8}, {49,15} }
  local crown = c:ellipse(32, 29 + b, 15, 11)
  for i, s in ipairs(spikes) do
    local x, h = s[1], s[2]
    local j = (i % 2 == 0) and pose.sway or 0
    crown:add(c:poly({ {x - 4, 28 + b}, {x + j, 8 + h + b - 6}, {x + 4, 28 + b} }))
  end
  c:part(crown, "wood")
  -- head / cream face
  c:part(c:ellipse(32, 38 + b, 11, 10), "skinA")
  c:part(c:ellipse(32, 44 + b, 5, 4), "wood", { noshade = true, nopop = true }) -- snout
  c:px(31, 42 + b, "#2b1c26") c:px(32, 42 + b, "#2b1c26") -- nose
  c:eyeSmall(25, 35 + b) c:eyeSmall(37, 35 + b)
  c:cheek(21, 40 + b) c:cheek(40, 40 + b)
  -- ears with leaf tucked behind one
  c:part(c:ellipse(19, 29 + b, 3, 3), "wood", { nopop = true })
  c:part(c:ellipse(45, 29 + b, 3, 3), "wood", { nopop = true })
  c:part(c:poly({ {42, 26 + b}, {50 + pose.sway, 20 + b}, {49, 28 + b}, {44, 30 + b} }), "moss", { band = 1 })
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end

local idle = { {bob=0,leg=0,lift=0,arm=0,sway=0}, {bob=1,leg=0,lift=0,arm=0,sway=1} }
local walk = {
  {bob=0,leg= 1,lift=0,arm= 2,sway= 1},
  {bob=1,leg= 0,lift=-1,arm= 0,sway= 0},
  {bob=0,leg=-1,lift=0,arm=-2,sway=-1},
  {bob=1,leg= 0,lift= 1,arm= 0,sway= 0},
}
local fr = {}
for _, p in ipairs(idle) do fr[#fr + 1] = frame(p) end
for _, p in ipairs(walk) do fr[#fr + 1] = frame(p) end
local s = HP.sheet{ cellw = 64, cellh = 80, frames = fr, tags = { {name="idle",from=1,to=2}, {name="walk",from=3,to=6} } }
s:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
s:save{ png = out .. NAME .. "_x4.png", scale = 4 }
