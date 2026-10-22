local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local wood = GV.ramp("#a5663a")
local stone = GV.ramp("#a38f80")
local tan = GV.ramp("#dcb06a")
local cream = GV.ramp("#f8eed2")
local dusk = GV.ramp("#7a5cc0")
local duskD = GV.ramp("#4e3a8a")

-- shell
local shell = c:ellipse(53, 40, 17, 17)
-- body
local body = c:ellipse(40, 102, 35, 25)
local bib = c:poly({ {26, 80}, {54, 80}, {59, 100}, {21, 100} })
-- head
local head = c:ellipse(36, 59, 19, 18)
local muzzle = c:ellipse(36, 66, 12, 8)
-- stalks
local stalkL = c:line({ {29, 44}, {27, 38}, {24, 33}, {22, 29} }, 3)
local stalkR = c:line({ {42, 44}, {43, 38}, {45, 32}, {45, 28} }, 3)
local ballL = c:ellipse(21, 25, 5, 5)
local ballR = c:ellipse(46, 23, 5, 5)
-- ribbon
local rib = c:line({ {19, 49}, {25, 46}, {32, 44}, {40, 44}, {48, 45}, {56, 48} }, 4)
local knot = c:ellipse(56, 46, 3, 3)

local p = c:build{
  { "shell", shell, wood },
  { "body", body, stone, { stitch = { side = "lit" } } },
  { "bib", bib, cream, { flat = true } },
  { "stalkL", stalkL, tan, { flat = true } },
  { "stalkR", stalkR, tan, { flat = true } },
  { "head", head, tan },
  { "muzzle", muzzle, cream, { gloss = false } },
  { "ballL", ballL, tan },
  { "ballR", ballR, tan },
  { "rib", rib, dusk, { flat = true } },
  { "knot", knot, duskD, { flat = true } },
}

-- spiral on shell
local pts = {}
local cx, cy = 53, 40
for i = 0, 40 do
  local t = i / 40
  local a = t * 4.4 * math.pi + math.pi
  local r = 1 + t * 12
  pts[#pts + 1] = { math.floor(cx + r * math.cos(a) + 0.5), math.floor(cy + r * math.sin(a) + 0.5) }
end
c:fill(c:line(pts, 2):clip(shell), "#2a1a10")

-- seam where bib meets collar, button at bib top
c:seam({ {27, 81}, {53, 81} })
c:button(38, 78)

-- eyes on stalk tips
c:eye(19, 23); c:eye(44, 21)
-- nostrils and mouth
c:paint({ "nn", "nn" }, 31, 61, { n = "umber" })
c:paint({ "nn", "nn" }, 39, 61, { n = "umber" })
c:paint({ "u.......u", ".uuuuuuu." }, 32, 66, { u = "umber" })

local t = c:save(O .. "aseprite/ph/npc-sorrel-inkcap.aseprite", O .. "png/ph/npc-sorrel-inkcap.png")
print(GV.report(t))
