local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- sack body: trapezoid widening downward, rounded bottom
local body = c:poly({ {16,19}, {48,19}, {54,46}, {10,46} })
body:add(c:rrect(10, 36, 53, 54, 8))

-- folded-back rim, a bit wider than the sack mouth
local rim = c:poly({ {19,13}, {45,13}, {49,22}, {15,22} })

-- straw tuft poking up out of the mouth (behind the rim)
local tuft = c:poly({ {22,14}, {24,9}, {27,13} })
tuft:add(c:poly({ {28,13}, {31,7}, {34,13} }))
tuft:add(c:poly({ {35,13}, {39,9}, {41,14} }))

-- round straw puff spilling from the front
local puff = c:ellipse(32, 37, 12, 10)

local sack = GV.ramp("#a5663a")
local p = c:build{
  { "tuft", tuft, "gold", { flat = true } },
  { "body", body, sack, { stitch = { side = "lit" } } },
  { "rim",  rim,  GV.ramp("#dcb06a"), { gloss = { 22, 15 } } },
  { "puff", puff, "gold", { gloss = { 25, 31 } } },
}

-- straw V-blades on the puff
c:fill(c:line({ {26,33}, {32,41}, {38,33} }, 2), "#b8661a")
c:fill(c:line({ {32,30}, {32,36} }, 2), "#e8a317")

-- weave flecks on the burlap
c:px(17, 26, sack.shade); c:px(18, 26, sack.shade)
c:px(46, 28, sack.shade); c:px(47, 28, sack.shade)
c:px(20, 49, sack.shade); c:px(21, 49, sack.shade)
c:px(43, 50, sack.shade); c:px(44, 50, sack.shade)

-- seam along the bottom of the rim
c:seam({ {16, 23}, {48, 23} })

local t = c:save(O .. "aseprite/ph/straw-mulch.aseprite", O .. "png/ph/straw-mulch.png")
print(GV.report(t))
