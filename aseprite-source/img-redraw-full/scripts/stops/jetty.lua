local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 48, h = 48, mode = "icon" }
-- wavy water band with three crests
local water = c:rect(11, 32, 36, 36)
for _, x in ipairs({ 15, 23.5, 31 }) do water:add(c:ellipse(x, 31, 3.5, 2)) end
local posts = c:mask()
for _, x in ipairs({ 12, 19, 26 }) do posts:add(c:rect(x, 26, x + 2, 34)) end
local deck = c:rrect(10, 23, 32, 27, 1)
local rod = c:line({ {28, 25}, {34, 12} }, 2)
local P = c:build{
  { "water", water, "water" },
  { "posts", posts, "wood", { flat = true } },
  { "deck",  deck, "wood", { cres = 1, deep = 0 } },
  { "rod",   rod, GV.ramp("#5e2f1e"), { flat = true } },
  { "bob",   c:ellipse(33.5, 29.5, 2, 2), "red", { flat = true } },
}
-- plank gaps
for _, x in ipairs({ 16, 23 }) do c:fill(c:rect(x, 24, x, 26), GV.R.wood.shade) end
-- fishing line, 1 px accent
for y = 12, 26 do
  local x = 35 - math.floor((y - 12) / 7 + 0.5)
  if y > 19 then x = 34 end
  c:px(x, y, "#f2e4c0")
end
-- crest highlights on water
for _, x in ipairs({ 14, 22, 30 }) do c:px(x, 30, "#c8ecdc"); c:px(x + 1, 30, "#c8ecdc") end
local t = c:save(O .. "aseprite/stops/jetty.aseprite", O .. "png/stops/jetty.png")
print(GV.report(t))
