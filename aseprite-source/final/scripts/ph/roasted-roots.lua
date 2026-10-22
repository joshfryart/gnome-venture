local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local heap = c:ellipse(31.5, 30, 21, 17):cut(c:rect(0,31,63,63))
local bowl = c:ellipse(31.5, 28, 24, 24):clip(c:rect(0,28,63,52))
bowl:add(c:rrect(7,28,56,31,1))
local h1 = c:ellipse(23, 22, 3.5)
local h2 = c:ellipse(35, 19, 3.5)
local h3 = c:ellipse(17, 27, 2.5)
local g1 = c:ellipse(43, 24, 3)
local g2 = c:ellipse(29, 27, 2.5)
local bw = GV.ramp("#f4f0e0", { gloss = "#fff3c8", dot = "#ffffff", rim = "#f5b860" })
local p = c:build{
  { "heap", heap, GV.ramp("#b0bc66"), { gloss = false } },
  { "g2", g2, "gold", { flat = true } },
  { "h3", h3, GV.ramp("#58a03e"), { flat = true } },
  { "h1", h1, GV.ramp("#58a03e") },
  { "h2", h2, "moss" },
  { "g1", g1, "gold" },
  { "bowl", bowl, bw, { gloss = {20,36} } },
}
-- fold arc across the heap
local arc = c:line({ {14,24},{20,20},{28,17},{40,17},{48,21} }, 1):clip(heap)
for _, m in ipairs({ h1, h2, h3, g1, g2 }) do arc:cut(m:grow(1)) end
c:fill(arc, "#17361c")
-- rim line
c:fill(c:rect(8,28,55,29):clip(bowl), "#d6c9b6")
c:seam({ {10,31}, {53,31} })
c:ground(31.5, 53, 15, 1.5)
local t = c:save(O.."aseprite/ph/roasted-roots.aseprite", O.."png/ph/roasted-roots.png")
print(GV.report(t))
