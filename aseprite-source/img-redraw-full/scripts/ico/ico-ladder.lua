local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local rungs = c:rect(24, 15, 40, 20):add(c:rect(24, 29, 40, 34)):add(c:rect(24, 43, 40, 48))
local lrail = c:rrect(16, 8, 24, 55, 2)
local rrail = c:rrect(40, 8, 48, 55, 2)
local lfoot = c:rrect(13, 53, 25, 57, 1)
local rfoot = c:rrect(39, 53, 51, 57, 1)

c:build{
  { "rungs", rungs, "#b6814d", { light = c:rect(14, 6, 50, 58) } },
  { "lfoot", lfoot, "#8a4f2a", { gloss = false } },
  { "rfoot", rfoot, "#8a4f2a", { gloss = false } },
  { "lrail", lrail, "#c4925f" },
  { "rrail", rrail, "#c4925f" },
}
-- gold rivets where rungs meet rails
for _, y in ipairs({ 16, 30, 44 }) do
  c:paint({ "gg", "gs" }, 19, y + 1, { g = "#f5cf6a", s = "#e8a317" })
  c:paint({ "gg", "gs" }, 43, y + 1, { g = "#f5cf6a", s = "#e8a317" })
end
c:ground(31.5, 59, 22, 1.5)
local t = c:save(O .. "aseprite/ico/ico-ladder.aseprite", O .. "png/ico/ico-ladder.png")
print(GV.report(t))
