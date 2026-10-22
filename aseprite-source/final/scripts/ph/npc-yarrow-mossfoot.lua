local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local cream = GV.ramp("#f8eed2")
-- body
local body = c:rrect(6, 80, 73, 99, 9)
-- head
local head = c:ellipse(39.5, 60, 25, 17)
-- eye bulbs sit on top corners of head
local eyeL = c:ellipse(22, 46, 8, 8)
local eyeR = c:ellipse(57, 46, 8, 8)
-- hat
local cone = c:poly({ {21, 36}, {46, 9}, {54, 4}, {55, 9}, {60, 36} })
local brim = c:ellipse(40, 35, 29, 3.5)
local p = c:build{
  { "disc", c:ellipse(39.5, 52, 36, 36), "#e6d2ae", { gloss = false } },
  { "body", body, "#d9667f", { stitch = { side = "lit" } } },
  { "head", head, "#b0bc66" },
  { "eyeL", eyeL, cream },
  { "eyeR", eyeR, cream },
  { "cone", cone, "wood" },
  { "brim", brim, "#8c4a1a", { gloss = false } },
}
-- collar V
local collar = c:poly({ {26, 80}, {40, 94}, {54, 80}, {48, 80}, {40, 88}, {32, 80} })
c:fill(collar, "#f8eed2")
c:fill(c:poly({ {33, 80}, {40, 87}, {47, 80} }), "#9c2a1e")
c:fill(c:line({ {26, 80}, {40, 94} }, 1), "#e0c690")
c:fill(c:line({ {40, 94}, {54, 80} }, 1), "#e0c690")
-- chin patch
local chin = c:ellipse(39.5, 72, 9, 2.5)
c:fill(chin, "#f8eed2")
-- mouth: wide gecko smile
c:fill(c:line({ {25, 64}, {32, 67}, {40, 68}, {47, 67}, {54, 64} }, 2), "#2a1a10")
-- bean bumps
for _, b in ipairs({ {30, 50}, {48, 50}, {36, 46}, {43, 46}, {18, 62}, {60, 62} }) do
  c:spot(c:ellipse(b[1], b[2], 1.5, 1), "#2e5a2c", "#4a7a3a")
end
-- nostrils
c:px(36, 58, "#2e5a2c"); c:px(43, 58, "#2e5a2c")
-- eyes centred in bulbs
c:eye(20, 44); c:eye(55, 44)
-- seams
c:seam({ {12, 36}, {68, 36} })
c:seam({ {10, 84}, {24, 84} }); c:seam({ {56, 84}, {70, 84} })
c:button(38, 30)
local t = c:save(O .. "aseprite/ph/npc-yarrow-mossfoot.aseprite", O .. "png/ph/npc-yarrow-mossfoot.png")
print(GV.report(t))
