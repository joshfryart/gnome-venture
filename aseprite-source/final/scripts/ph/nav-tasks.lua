local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local wood = GV.ramp("#a5663a")
local stone = GV.R.stone

c:build{
  { "board", c:rrect(12, 11, 52, 54, 5), wood },
  { "paper", c:rect(16, 17, 48, 50), "cream", { gloss = false } },
  { "clip",  c:rrect(23, 8, 41, 16, 2), stone },
}
-- clip hole
c:paint({ ".hh.", "hhhh", "hhhh", ".hh." }, 30, 9, { h = "#f4f0e0" })

-- check marks and text bars
local green, pale, grey = "#58a03e", "#d6c9b6", "#8b8f96"
for i, y in ipairs({ 24, 33, 42 }) do
  local col = (i < 3) and green or pale
  c:fill(c:line({ {20, y}, {22, y + 2}, {26, y - 2} }, 3), col)
  c:fill(c:rect(30, y - 1, 45, y + 1), (i < 3) and pale or grey)
end

local t = c:save(O .. "aseprite/ph/nav-tasks.aseprite", O .. "png/ph/nav-tasks.png")
print(GV.report(t))
