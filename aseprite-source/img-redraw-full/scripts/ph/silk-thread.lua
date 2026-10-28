local GV = dofile("/home/user/gnome-venture/aseprite-source/gvlib/gvlib.lua")
local O = "/home/user/gnome-venture/aseprite-source/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local silk = GV.ramp("#f1ece0", { shade = "#dcb06a", deep = "#b07a45", bounce = "#f5b860" })
local hole = c:ellipse(31.5, 36, 6.5, 6.5)
local ring = c:ellipse(31.5, 35, 21.5, 19):cut(hole)
local loops = c:ellipse(27, 12, 4, 3):cut(c:ellipse(27, 12, 1.5, 1))
loops:add(c:ellipse(36, 12, 4, 3):cut(c:ellipse(36, 12, 1.5, 1)))
local tail = c:line({ {45, 49}, {48, 52}, {51, 54}, {54, 53}, {55, 50}, {53, 48} }, 2)
local p = c:build{
  { "loops", loops, silk, { contour = "#dcb06a", gloss = false } },
  { "ring",  ring,  silk, { gloss = { 18, 24 } } },
  { "tail",  tail,  silk, { flat = true, contact = false } },
  { "band",  c:rrect(27, 15, 36, 24, 1), "gold", { gloss = false } },
}
-- diagonal strand bands, tilted up-right, kept off the gloss
local inner = ring:shrink(2)
for _, o in ipairs({ -16, -4, 8, 20 }) do
  local b = c:line({ {12 + o, 56}, {52 + o, 16} }, 2):clip(inner)
  b:each(function(x, y)
    if c:get(x, y) == silk.base then c:px(x, y, silk.shade) end
  end)
end
c:button(30, 18)
local t = c:save(O .. "aseprite/ph/silk-thread.aseprite", O .. "png/ph/silk-thread.png")
print(GV.report(t))
