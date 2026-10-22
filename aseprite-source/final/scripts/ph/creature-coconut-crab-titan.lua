local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local shell = GV.ramp("#a5663a")
local belly = GV.ramp("#dcb06a")
local gold = "gold"
-- claws: palm ellipse with an upper-inner pincer notch
local function claw(cx, dir)
  local m = c:ellipse(cx, 19, 5.5, 9)
  local tip = cx + dir * 1
  m:cut(c:poly({ {tip, 8}, {cx + dir * 7, 8}, {cx + dir * 7, 13}, {tip + dir * 0.5, 19} }))
  return m
end
local clawL = claw(14.5, 1)
local clawR = claw(48.5, -1)
local body = c:ellipse(31.5, 41, 15, 10)
local crown = c:poly({ {25, 30}, {25, 21}, {28.5, 25}, {31.5, 19}, {34.5, 25}, {38, 21}, {38, 30} })
local band = c:rect(25, 28, 38, 31)
local p = c:build{
  { "aura",   c:ellipse(31.5, 33, 21), "#f0bf56", { flat = true, gloss = false, contour = false, contact = false } },
  { "aura2",  c:ellipse(31.5, 33, 15), "#f8db8c", { flat = true, gloss = false, contour = false, contact = false, rim = false } },
  { "legs",   c:line({ {19, 47}, {13, 53} }, 2):add(c:line({ {23, 49}, {18, 54} }, 2))
                :add(c:line({ {44, 47}, {50, 53} }, 2)):add(c:line({ {40, 49}, {45, 54} }, 2)), "#5e2f1e", { flat = true } },
  { "arms",   c:line({ {20, 39}, {16, 27} }, 3):add(c:line({ {43, 39}, {47, 27} }, 3)), GV.ramp("#b6814d"), { flat = true } },
  { "clawL",  clawL, shell },
  { "clawR",  clawR, shell },
  { "body",   body, shell },
  { "belly",  c:ellipse(31.5, 45, 8.5, 4.5), belly, { gloss = false } },
  { "stalks", c:line({ {21, 34}, {21, 25} }, 2):add(c:line({ {42, 34}, {42, 25} }, 2)), "#2a1a10", { flat = true } },
  { "crown",  crown, gold },
  { "band",   band, GV.ramp("#b07a10") },
}
c:paint({ "rrr", "rrr", "rrr" }, 30, 22, { r = "#d6322b" })
c:px(30, 22, "#ff9158")
c:seam({ {26, 29}, {37, 29} })
c:eye(19, 21); c:eye(40, 21)
local t = c:save(O .. "aseprite/ph/creature-coconut-crab-titan.aseprite", O .. "png/ph/creature-coconut-crab-titan.png")
print(GV.report(t))
