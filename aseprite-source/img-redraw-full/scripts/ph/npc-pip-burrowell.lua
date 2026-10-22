local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local fur = GV.ramp("#a38f80")
local hatR = GV.ramp("#a5663a")
local brimR = GV.ramp("#8c4a1a")
-- ears
local earL = c:ellipse(21, 36, 10)
local earR = c:ellipse(59, 36, 10)
-- body
local body = c:ellipse(40, 100, 34, 24):cut(c:rect(0, 0, 79, 75))
local vee = c:poly({ {30, 77}, {50, 77}, {40, 88} })
local collar = c:poly({ {27, 76}, {53, 76}, {40, 90} })
local head = c:ellipse(40, 53, 21, 18)
local muz = c:ellipse(40, 61, 10, 7):add(c:poly({ {32, 63}, {48, 63}, {40, 72} }))
local cone = c:poly({ {17, 43}, {53, 4}, {64, 43} })
local brim = c:ellipse(40, 42.5, 28, 4.5)
local p = c:build{
  { "earL", earL, fur },
  { "earR", earR, fur },
  { "body", body, fur, { stitch = { side = "lit" } } },
  { "collar", collar, "#8f7060", { gloss = false } },
  { "vee", vee, "#f8eed2", { gloss = false } },
  { "head", head, fur },
  { "muz", muz, "#e6d2ae", { gloss = false } },
  { "cone", cone, hatR },
  { "brim", brim, brimR, { stitch = { side = "lit" } } },
}
-- inner ears (visible parts only)
c:fill(c:ellipse(21, 34, 6):clip(earL):cut(cone):cut(brim):cut(earL:edge()), "#f6b8cf")
c:fill(c:ellipse(59, 34, 6):clip(earR):cut(cone):cut(brim):cut(earR:edge()), "#f6b8cf")
-- hat light streak and band notch
c:fill(c:line({ {24, 37}, {32, 25} }, 2), "#d9a660")
c:fill(c:poly({ {44, 14}, {54, 14}, {54, 17}, {44, 17} }):clip(cone):cut(cone:edge()), "#8c4a1a")
c:button(38, 78)
-- face
c:eye(28, 48); c:eye(47, 48)
c:fill(c:ellipse(40, 59, 3.5, 2.5), "#d9667f")
c:px(38, 58, "#f2a0b4"); c:px(39, 57, "#f2a0b4")
c:paint({ "u...u", ".uuu." }, 38, 66, { u = "umber" })
-- whiskers
for _, w in ipairs({ { {26, 60}, {31, 61} }, { {25, 64}, {31, 63} }, { {49, 61}, {54, 60} }, { {49, 63}, {55, 64} } }) do
  c:fill(c:line(w, 1), "#5e4a40")
end
local t = c:save(O .. "aseprite/ph/npc-pip-burrowell.aseprite", O .. "png/ph/npc-pip-burrowell.png")
print(GV.report(t))
