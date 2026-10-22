local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bulb = c:ellipse(32, 35, 19, 16):add(c:poly({ {32, 8}, {47, 26}, {17, 26} }))
local p = c:build{
  { "stem",  c:rrect(29, 48, 35, 56, 1), "#4a8a3e", { gloss = false } },
  { "bulb",  bulb, GV.ramp("#58a03e"), { gloss = { 22, 20 } } },
  { "heart", c:poly({ {32, 10}, {37, 20}, {36, 30}, {32, 33}, {28, 30}, {27, 20} }), "moss", { gloss = false, contact = false } },
}
local inner = bulb:shrink(2)
local dark, lite = "#2f5a2a", "#a4b86a"
local rows = { { y = 22, xs = { 22, 42 } }, { y = 32, xs = { 17, 27, 37, 47 } }, { y = 42, xs = { 22, 32, 42 } } }
for _, r in ipairs(rows) do
  for _, x in ipairs(r.xs) do
    local v = c:line({ {x - 6, r.y + 5}, {x, r.y}, {x + 6, r.y + 5} }, 2):clip(inner)
    c:fill(v, dark)
    c:fill(c:line({ {x - 5, r.y + 3}, {x, r.y - 1} }, 1):clip(inner):cut(v), lite)
  end
end
local t = c:save(O .. "aseprite/ph/artichoke.aseprite", O .. "png/ph/artichoke.png")
print(GV.report(t))
