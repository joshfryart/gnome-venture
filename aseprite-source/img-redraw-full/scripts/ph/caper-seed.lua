local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 40, 19, 15)
local lid = c:ellipse(31.5, 23, 14, 8):cut(c:rect(0, 23, 63, 63))
c:build{
  { "foot", c:rrect(21, 52, 42, 57, 2), "#8a4f2a" },
  { "body", body, GV.ramp("#a4b86a"), { gloss = { 19, 31 } } },
  { "neck", c:rrect(19, 22, 44, 28, 2), "#7ab55c", { gloss = false } },
  { "lid", lid, "#4a8a3e" },
  { "knob", c:ellipse(31.5, 12.5, 3.5, 3.5), "#d9a660", { gloss = false } },
}
-- sprig
c:fill(c:line({ {22, 45}, {27, 41}, {32, 39}, {37, 37}, {42, 36} }, 2), "#4a8a3e")
for _, b in ipairs({ {24, 41}, {30, 37}, {37, 34} }) do
  c:fill(c:ellipse(b[1] + 1, b[2] + 1, 1.5, 1.5), "#2f5a2a")
  c:px(b[1], b[2], "#c8d77a")
end
c:seam({ {20, 25}, {43, 25} })
c:ground(31.5, 58, 14, 1.5)
local t = c:save(O .. "aseprite/ph/caper-seed.aseprite", O .. "png/ph/caper-seed.png")
print(GV.report(t))
