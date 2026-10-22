local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- backdrop disc
local disc = c:ellipse(40, 50, 36, 36)

-- wings: pale ovals tilted up on both sides
local wingL = c:ellipse(17, 46, 11, 8):add(c:ellipse(13, 40, 8, 6))
local wingR = c:ellipse(62, 46, 11, 8):add(c:ellipse(66, 40, 8, 6))

-- antennae behind the head
local antL = c:line({ {35, 36}, {31, 28}, {27, 21} }, 2)
local antR = c:line({ {44, 36}, {48, 28}, {52, 21} }, 2)
local clubL = c:rrect(24, 17, 28, 21, 1)
local clubR = c:rrect(51, 17, 55, 21, 1)

-- round fuzzy bee body (face + belly)
local body = c:ellipse(39.5, 57, 23, 22)

-- fluff crest: three scallops on top of the head
local crest = c:ellipse(33, 36, 5, 4):add(c:ellipse(39.5, 33, 6, 5)):add(c:ellipse(46, 36, 5, 4))

-- apron over the lower body
local apron = c:ellipse(39.5, 104, 30, 22):clip(c:rect(0, 80, 79, 99))

local wing = GV.ramp("#f2f6f0")
local dark = GV.ramp("#3e2f66")
local p = c:build{
  { "disc",  disc,  GV.ramp("#b8d8d2"), { gloss = false, bounce = false } },
  { "wingL", wingL, wing },
  { "wingR", wingR, wing },
  { "antL",  antL,  dark, { flat = true } },
  { "antR",  antR,  dark, { flat = true } },
  { "clubL", clubL, dark, { flat = true } },
  { "clubR", clubR, dark, { flat = true } },
  { "body",  body,  "gold", { stitch = { side = "lit" } } },
  { "crest", crest, GV.ramp("#f5cf6a"), { gloss = { 36, 31 } } },
  { "apron", apron, GV.ramp("#a38f80") },
}

-- two crisp black stripes across the belly, gently curved
local s1 = c:poly({ {16, 60}, {28, 62}, {40, 63}, {52, 62}, {64, 60}, {64, 63}, {52, 65}, {40, 66}, {28, 65}, {16, 63} })
local s2 = c:poly({ {16, 69}, {28, 71}, {40, 72}, {52, 71}, {64, 69}, {64, 72}, {52, 74}, {40, 75}, {28, 74}, {16, 72} })
local inner = p.body.m:copy()
s1:clip(inner); s2:clip(inner)
c:fill(s1, "#2a1a10"); c:fill(s2, "#2a1a10")
-- lit fuzz glint along the top of each stripe on the left
c:px(22, 61, "#4a2c1a"); c:px(23, 61, "#4a2c1a"); c:px(22, 70, "#4a2c1a"); c:px(23, 70, "#4a2c1a")

-- face
c:eye(30, 44); c:eye(45, 44)
c:paint({ "u.......u", ".uu...uu.", "...uuu..." }, 35, 52, { u = "#4a2c1a" })

-- apron: collar seam, centre line, buttons
c:seam({ {14, 85}, {26, 82}, {40, 81}, {53, 82}, {65, 85} })
local cl = c:rect(39, 86, 40, 99)
c:fill(cl, "#2a1a10")
c:button(38, 87); c:button(38, 93)

local t = c:save(D .. "img-redraw-full/aseprite/ph/npc-ginger-thornwhistle.aseprite",
                 D .. "img-redraw-full/png/ph/npc-ginger-thornwhistle.png")
print(GV.report(t))
