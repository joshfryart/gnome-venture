local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local roof = c:poly({ {32, 7}, {58, 29}, {7, 29} })
local p = c:build{
  { "walls", c:rrect(14, 26, 50, 54, 3), GV.ramp("#a5663a") },
  { "roof", roof, "moss", { gloss = { 24, 19 } } },
  { "lip", c:rect(8, 27, 56, 29), GV.ramp("#4a8a3e"), { flat = true } },
  { "door", c:ellipse(32, 42, 7, 7), GV.ramp("#44281c"), { gloss = false, bounce = false } },
}
-- plank lines
for _, y in ipairs({ 35, 42, 49 }) do
  for x = 17, 22 do c:px(x, y, "#5e2f1e") end
  for x = 42, 47 do c:px(x, y, "#5e2f1e") end
end
-- door rim, lit upper-left
c:paint({
  "...rrrr",
  ".rr....",
  ".r.....",
  "r......",
  "r......",
}, 25, 35, { r = "#ecc58a" })
c:seam({ {11, 28}, {53, 28} })
c:button(30, 15)
local t = c:save(O .. "aseprite/ph/tea-shrine.aseprite", O .. "png/ph/tea-shrine.png")
print(GV.report(t))
