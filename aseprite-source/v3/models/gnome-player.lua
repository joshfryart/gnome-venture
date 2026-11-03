-- First draft: gnome-player 64x80 cell, 3/4 top-down. idle(2) + walk(4). Also exports a grey-hat tint variant.
local HP = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../lib/hp.lua")
local out = app.params.out or "./"
local WHITE = { hi = "#fff4d6", base = "#e2e0e6", shade = "#aaa9b8", deep = "#74758c" } -- beard (cream/stone mix)

-- pose: bob (0/1 raise), leg (-1,0,1 stride phase), lift (which foot is up at pass: -1 L, 1 R, 0), arm (-2..2 swing of left arm, right = -arm), bell (-1..1 px)
local function frame(pose, grey)
  local c = HP.canvas{ w = 64, h = 80, scale = 1, name = "gnome" }
  local b = -pose.bob
  c:groundShadow(32, 69, 14, 4)
  -- boots (feet baseline y=70)
  local lf = pose.leg * 2 + (pose.lift == -1 and -2 or 0)  -- left foot forward = lower on screen
  local rf = -pose.leg * 2 + (pose.lift == 1 and -2 or 0)
  c:part(c:rrect(22, 63 + lf, 30, 70 + lf, 2), "wood")
  c:part(c:rrect(34, 63 + rf, 42, 70 + rf, 2), "wood")
  -- arms (behind body edge) with hands
  local la, ra = pose.arm, -pose.arm
  c:part(c:rrect(15, 44 + b + la, 21, 56 + b + la, 3), "sea")
  c:part(c:rrect(43, 44 + b + ra, 49, 56 + b + ra, 3), "sea")
  c:part(c:ellipse(18, 58 + b + la, 3, 2), "skinA", { nopop = true })
  c:part(c:ellipse(46, 58 + b + ra, 3, 2), "skinA", { nopop = true })
  -- tunic
  c:part(c:rrect(20, 44 + b, 44, 65, 6), "sea")
  c:stitch({ {23, 63}, {41, 63} })
  c:button(32, 57 + b)
  -- scarf
  c:part(c:rrect(21, 43 + b, 43, 48 + b, 2), "gold")
  c:part(c:rrect(37, 47 + b, 42, 57 + b, 2), "gold", { band = 1, nopop = true }) -- hanging tail
  -- head
  c:part(c:ellipse(32, 36 + b, 12, 10), "skinA")
  c:cheek(23, 40 + b) c:cheek(39, 40 + b)
  -- beard
  c:part(c:poly({ {21, 40 + b}, {43, 40 + b}, {40, 52 + b}, {32, 57 + b}, {24, 52 + b} }), WHITE)
  -- nose
  c:part(c:ellipse(32, 39 + b, 2, 2), "skinB", { noshade = true, nopop = true })
  -- hat
  local bell = pose.bell
  c:part(c:poly({ {19, 33 + b}, {45, 33 + b}, {40, 20 + b}, {36, 10 + b}, {31 + bell, 7 + b}, {27, 14 + b}, {22, 24 + b} }), grey and "stone" or "ember")
  c:part(c:rrect(18, 29 + b, 46, 34 + b, 2), grey and "stone" or "ember", { band = 1, nopop = true }) -- brim
  c:part(c:ellipse(31 + bell, 7 + b, 3, 3), "gold") -- droopy bell
  -- eyes
  c:eyeSmall(26, 35 + b) c:eyeSmall(36, 35 + b)
  c:finish{ outline = true }
  HP.assertClean(c)
  return c
end

local idle = { {bob=0,leg=0,lift=0,arm=0,bell=0}, {bob=1,leg=0,lift=0,arm=0,bell=1} }
local walk = {
  {bob=0,leg= 1,lift=0,arm= 2,bell= 1},
  {bob=1,leg= 0,lift=-1,arm= 0,bell= 0},
  {bob=0,leg=-1,lift=0,arm=-2,bell=-1},
  {bob=1,leg= 0,lift= 1,arm= 0,bell= 0},
}
local function sheet(grey, name)
  local fr = {}
  for _, p in ipairs(idle) do fr[#fr + 1] = frame(p, grey) end
  for _, p in ipairs(walk) do fr[#fr + 1] = frame(p, grey) end
  local s = HP.sheet{ cellw = 64, cellh = 80, frames = fr, tags = { {name="idle",from=1,to=2}, {name="walk",from=3,to=6} } }
  s:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
  s:save{ png = out .. name .. "_x4.png", scale = 4 }
end
sheet(false, "gnome-player")
sheet(true, "gnome-player-grey")
