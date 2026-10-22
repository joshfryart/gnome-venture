local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#a9d6ea", { gloss = "#e4f6ee", rim = "#c8ecdc", shade = "#6fa6cc", deep = "#2f6290" })
local body = c:poly({ {10,51}, {10,36}, {17,17}, {47,17}, {54,36}, {54,51} })
c:part(body, glass, { gloss = { 16, 26 } })
-- white lattice: outer sash, vertical bars, rail
local inner = body:shrink(2)
local frame = body:copy():cut(inner)
for _, x in ipairs({ 20, 27, 32, 37, 44 }) do frame:add(c:rect(x, 17, x, 51):clip(body)) end
frame:add(c:rect(10, 35, 54, 35):clip(body))
frame:each(function(x, y)
  local s = (x - 32) + (y - 34)
  c:px(x, y, (s > 16 or x >= 52 or y >= 50) and "#c9c5bc" or "#f4f0e0")
end)
-- re-gloss upper-left pane over the bars
c:paint({ "gg.", "g..", "g.." }, 13, 30, { g = "#fff3c8" })
c:px(16, 33, "#fff3c8")
local plinth = c:rrect(9, 46, 55, 53, 2)
local plants = c:ellipse(16, 43, 5, 5):add(c:ellipse(23, 41, 5, 6)):add(c:ellipse(31, 43, 5, 4.5))
  :add(c:ellipse(39, 40, 5, 6)):add(c:ellipse(47, 43, 5, 5)):add(c:rect(12, 43, 51, 47))
c:build{
  { "plinth", plinth, GV.ramp("#968f96") },
  { "plants", plants, "moss", { gloss = { 20, 37 } } },
}
c:seam({ {12, 50}, {52, 50} })
-- two red fruits
local berry = { ".rr.", "rgrr", "rrrd", ".dd." }
c:paint(berry, 20, 42, { r = "#d6322b", g = "#ff9158", d = "#ae2a2a" })
c:paint(berry, 39, 40, { r = "#d6322b", g = "#ff9158", d = "#ae2a2a" })
c:ground(32, 56, 25, 2.5)
local t = c:save(O .. "aseprite/ph/greenhouse-1.aseprite", O .. "png/ph/greenhouse-1.png")
print(GV.report(t))
