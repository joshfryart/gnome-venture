local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#c4925f", { rim = "#f0d49a" })
local arc = c:line({ {17, 30}, {18, 23}, {22, 17}, {27, 13}, {32, 12}, {37, 13}, {42, 17}, {46, 23}, {47, 30} }, 3)
local p = c:build{
  { "handle", arc, tan, { flat = true } },
  { "body", c:poly({ {15, 31}, {49, 31}, {45, 54}, {19, 54} }), "wood", { gloss = { 22, 37 } } },
  { "hoop", c:rrect(13, 27, 50, 33, 2), tan, { gloss = { 16, 28 } } },
  { "band", c:rect(17, 45, 47, 47), tan, { gloss = false } },
}
for y = 34, 53 do
  if not (y >= 45 and y <= 47) then c:px(26, y, "#5e2f1e"); c:px(38, y, "#5e2f1e") end
end
c:seam({ {21, 30}, {48, 30} })
c:button(16, 28)
c:part(c:rect(44, 53, 45, 55), "water", { flat = true })
c:px(47, 54, "#8fcbd8"); c:px(47, 55, "#8fcbd8")
local t = c:save(O .. "aseprite/ph/tide-bucket.aseprite", O .. "png/ph/tide-bucket.png")
print(GV.report(t))
