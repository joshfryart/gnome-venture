-- First draft: folk-frog 64x80 cell, 3/4 top-down. idle(2) + walk(4). Quirk: lily-pad umbrella hat that sways.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../lib/hp.lua")
local out = app.params.out or "./"
local NAME = "folk-frog"
local function frame(pose)
  local c = HP.canvas{ w = 64, h = 80, scale = 1, name = NAME }
  local b = -pose.bob
  c:groundShadow(32, 69, 15, 4)
  local lf = pose.leg * 2 + (pose.lift == -1 and -2 or 0)
  local rf = -pose.leg * 2 + (pose.lift == 1 and -2 or 0)
  -- big webbed feet
  c:part(c:ellipse(26, 66 + lf, 6, 3), "moss", { band = 1 })
  c:part(c:ellipse(38, 66 + rf, 6, 3), "moss", { band = 1 })
  local la, ra = pose.arm, -pose.arm
  c:part(c:rrect(15, 46 + b + la, 21, 57 + b + la, 3), "moss")
  c:part(c:rrect(43, 46 + b + ra, 49, 57 + b + ra, 3), "moss")
  c:part(c:ellipse(32, 54 + b, 14, 12), "moss")      -- round body
  c:part(c:ellipse(32, 56 + b, 7, 8), "skinA", { band = 1, nopop = true }) -- belly
  -- waistcoat
  c:part(c:poly({ {19, 48 + b}, {27, 46 + b}, {29, 64}, {20, 62} }), "dusk")
  c:part(c:poly({ {45, 48 + b}, {37, 46 + b}, {35, 64}, {44, 62} }), "dusk")
  c:button(26, 55 + b)
  c:part(c:ellipse(18 + 0, 59 + b + la, 3, 2), "moss", { nopop = true })
  c:part(c:ellipse(46, 59 + b + ra, 3, 2), "moss", { nopop = true })
  -- head: wide, eyes on top
  c:part(c:ellipse(32, 40 + b, 16, 10), "moss")
  c:part(c:ellipse(32, 44 + b, 9, 3), "moss", { band = 1, nopop = true }) -- mouth area
  c:line({ {26, 46 + b}, {38, 46 + b} }, 1)
  c:px(26, 46 + b, "#2b1c26") for x = 27, 37 do c:px(x, 46 + b, "#2b1c26") end
  c:cheek(18, 43 + b) c:cheek(44, 43 + b)
  -- eye bumps on top of head
  c:part(c:ellipse(23, 32 + b, 6, 5), "moss")
  c:part(c:ellipse(41, 32 + b, 6, 5), "moss")
  c:eyeLocked(21, 30 + b) c:eyeLocked(39, 30 + b)
  -- lily-pad umbrella hat, sways
  local s = pose.sway
  c:part(c:ellipse(32 + s, 21 + b, 14, 5), "moss", { band = 1 })
  c:part(c:rect(31 + s, 24 + b, 32 + s, 27 + b), "moss", { noshade = true, nopop = true })
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
