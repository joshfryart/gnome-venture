local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

-- backdrop disc (gold)
local disc = c:ellipse(39.5, 50, 34, 34)
-- smock dome, bleeds off bottom
local smock = c:ellipse(39.5, 101, 33, 23):clip(c:rect(0, 78, 79, 99))
-- shell at upper right
local shell = c:ellipse(56, 43, 15, 15)
-- head/body
local head = c:ellipse(35.5, 62, 19, 18)
local muzzle = c:ellipse(35.5, 70, 12, 8)
-- eyestalks with bulbs
local stalks = c:line({ {29, 46}, {26, 36}, {22, 27} }, 3)
stalks:add(c:line({ {42, 46}, {45, 36}, {47, 25} }, 3))
local bulbL = c:ellipse(21.5, 24.5, 4.5, 4.5)
local bulbR = c:ellipse(47.5, 22.5, 4.5, 4.5)
-- low half-dome cap with brim and bobble
local cap = c:ellipse(35.5, 46, 16, 11):cut(c:rect(0, 46, 79, 99))
cap:add(c:rrect(16, 44, 55, 48, 2))
local bob = c:ellipse(35.5, 34.5, 3, 3)

local smockR = GV.ramp("#a38f80")
local tan = GV.ramp("#dcb06a")
local brown = GV.ramp("#a5663a")
c:build{
  { "disc", disc, "gold", { gloss = false } },
  { "smock", smock, smockR, { stitch = { side = "lit" } } },
  { "shell", shell, brown },
  { "stalks", stalks, tan, { flat = true } },
  { "bulbL", bulbL, tan, { gloss = false } },
  { "bulbR", bulbR, tan, { gloss = false } },
  { "head", head, tan },
  { "muzzle", muzzle, "#f8eed2", { gloss = false } },
  { "cap", cap, GV.ramp("#d6322b") },
  { "bob", bob, GV.ramp("#d6322b"), { gloss = false } },
}

-- shell spiral
local pts = {}
for i = 0, 60 do
  local t = i / 60
  local a = -1.2 + t * 4.2 * math.pi
  local r = 1.5 + t * 10
  pts[#pts + 1] = { math.floor(56 + r * math.cos(a) + 0.5), math.floor(43 + r * math.sin(a) + 0.5) }
end
local sp = c:line(pts, 2):clip(shell:shrink(2)):cut(head:grow(1)):cut(cap:grow(1))
c:fill(sp, "#5e2f1e")

-- seams and buttons
c:seam({ {18, 46}, {53, 46} })
c:seam({ {39, 82}, {39, 99} })
c:button(38, 84); c:button(38, 91)

-- eyes on stalk bulbs
c:eye(19, 22); c:eye(45, 20)
-- smile
c:paint({ "u.......u", ".uuuuuuu." }, 31, 71, { u = "#2a1a10" })

local t = c:save(O .. "aseprite/ph/npc-ember-seedwell.aseprite", O .. "png/ph/npc-ember-seedwell.png")
print(GV.report(t))
