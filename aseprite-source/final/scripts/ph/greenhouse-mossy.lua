local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glass = c:poly({ {8, 51}, {8, 33}, {16, 17}, {48, 17}, {56, 33}, {56, 51} })
local plinth = c:rrect(7, 45, 56, 51, 2)
local bush = c:ellipse(15, 40, 5, 4):add(c:ellipse(24, 38, 6, 5)):add(c:ellipse(34, 39, 6, 4))
  :add(c:ellipse(44, 38, 6, 5)):add(c:ellipse(50, 41, 4, 3)):add(c:rect(11, 40, 52, 45))
bush:clip(glass)

c:build{
  { "glass", glass, GV.ramp("#a9d6ea"), { gloss = false } },
  { "bush", bush, GV.ramp("#6a9a3a"), { gloss = false } },
  { "plinth", plinth, "stone" },
}
-- berries
c:part(c:rrect(18, 39, 21, 42, 1), "red", { flat = true })
c:part(c:rrect(38, 38, 41, 41, 1), "red", { flat = true })
-- cream frame: outer edge band and bars
local F = "#f4f0e0"
local frame = glass:copy():cut(glass:shrink(2))
frame:cut(c:rect(0, 45, 63, 63))
c:fill(frame, F)
for _, b in ipairs({ { 22, 17, 20, 44 }, { 32, 17, 32, 44 }, { 42, 17, 44, 44 } }) do
  c:fill(c:line({ { b[1], b[2] }, { b[3], b[4] } }, 1), F)
end
c:fill(c:line({ { 9, 32 }, { 55, 32 } }, 1), F)
-- glint streak on glass
c:paint({ "..gg....gg..", "gg..gggg..gg" }, 12, 26, { g = "#fff1c8" })
-- moss on roof and base
c:build{
  { "mossR", c:ellipse(16, 18, 6, 3):add(c:ellipse(47, 19, 6, 3)), "moss" },
  { "mossC", c:ellipse(32, 16, 5, 2.5), GV.ramp("#6a9a3a") },
  { "mossB", c:ellipse(19, 51, 7, 3):add(c:ellipse(43, 51.5, 8, 3)), "moss" },
}
c:fill(c:line({ { 9, 34 }, { 9, 40 }, { 10, 46 } }, 2), "#6a9a3a")
c:fill(c:line({ { 54, 36 }, { 54, 42 }, { 53, 46 } }, 2), "#6a9a3a")
c:ground(31.5, 54, 24, 1)
local t = c:save(O .. "aseprite/ph/greenhouse-mossy.aseprite", O .. "png/ph/greenhouse-mossy.png")
print(GV.report(t))
