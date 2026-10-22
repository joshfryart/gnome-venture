local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local handle = c:rrect(28, 35, 36, 52, 4)
local head = c:rrect(15, 23, 49, 31, 4)
for _, x in ipairs({15, 30, 45}) do
  head:add(c:poly({{x, 26}, {x, 14}, {x + 2.5, 10}, {x + 5, 14}, {x + 5, 26}}))
end
head:add(c:poly({{22, 30}, {42, 30}, {38, 34}, {26, 34}}))
local ferrule = c:rrect(26, 30, 38, 36, 1)
c:build{
  { "handle", handle, "wood" },
  { "head", head, "stone", { gloss = { 16, 15 } } },
  { "ferrule", ferrule, "stone", { gloss = false } },
}
c:seam({ {26, 33}, {38, 33} })
for x = 29, 35 do c:px(x, 42, "#8a4f2a"); c:px(x, 47, "#8a4f2a") end
local t = c:save(O .. "aseprite/ph/hand-fork.aseprite", O .. "png/ph/hand-fork.png")
print(GV.report(t))
