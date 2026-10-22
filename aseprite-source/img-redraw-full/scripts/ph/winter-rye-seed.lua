local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rect(13, 12, 50, 54)
local flap = c:poly({ {13, 12}, {51, 12}, {51, 26}, {32, 35}, {13, 26} })
local p = c:build{
  { "body", body, GV.ramp("#d9a660"), { gloss = false } },
  { "flap", flap, GV.ramp("#b07a45") },
}
-- crease along the top of the flap fold
c:fill(c:line({ {14, 13}, {50, 13} }, 1), "#ecc58a")
c:seam({ {15, 27}, {31, 35}, {49, 27} }, { free = true })
-- rye ear
local stem = "#5e2f1e"
c:fill(c:rect(31, 38, 32, 52), stem)
local g = "#e8a317"
for i = 0, 4 do
  local y = 38 + i * 2
  c:fill(c:rect(27, y, 30, y + 1), g); c:px(27, y + 1, "#7a3a14"); c:px(28, y, "#fff1c8")
  c:fill(c:rect(33, y, 36, y + 1), g); c:px(36, y + 1, "#7a3a14")
end
c:fill(c:rect(31, 36, 32, 37), g)
c:px(27, 37, stem); c:px(36, 37, stem); c:px(26, 36, stem); c:px(37, 36, stem)
-- label tab
c:fill(c:rect(42, 44, 46, 48), "#f1ece0"); c:fill(c:rect(43, 46, 45, 46), "#c9a96e")
c:ground(31.5, 56, 17, 1.5)
local t = c:save(O .. "aseprite/ph/winter-rye-seed.aseprite", O .. "png/ph/winter-rye-seed.png")
print(GV.report(t))
