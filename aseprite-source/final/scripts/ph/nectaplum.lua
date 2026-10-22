local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local violet = GV.ramp("#7a5cc0", { gloss = "#a894dc", shade = "#4e3a8a", deep = "#3e2f66" })
-- fruit: slightly wide sphere with a dimple at the top where the crease starts
local body = c:ellipse(32, 37, 17, 16)
body:add(c:ellipse(25, 38, 10, 14)):add(c:ellipse(39, 38, 10, 14))
body:cut(c:poly({ {29, 19}, {35, 19}, {32, 24} }))
local stem = c:poly({ {30, 13}, {34, 13}, {35, 24}, {30, 24} })
local leaf = c:poly({ {34, 16}, {37, 11}, {42, 8}, {48, 6}, {53, 5}, {51, 9}, {47, 13}, {41, 16}, {36, 18} })
local p = c:build{
  { "stem", stem, GV.ramp("#6a9a3a"), { flat = true } },
  { "fruit", body, violet, { gloss = { 20, 27 } } },
  { "leaf", leaf, "leaf", { cres = 2, deep = 1, gloss = false } },
}
-- deep crease top to bottom, bowing left, with a shaded right lip
local crease = c:line({ {32, 23}, {30, 28}, {29, 34}, {29, 41}, {30, 47}, {31, 51} }, 2):clip(p.fruit.m)
c:fill(crease, "#291d4a")
local llip = crease:shift(-1, 0):cut(crease):clip(p.fruit.m:shrink(2))
c:fill(llip, violet.rim)
local lip = crease:shift(2, 0):cut(crease):clip(p.fruit.m)
lip:each(function(x, y) if c:get(x, y) ~= nil then c:px(x, y, "#4e3a8a") end end)
-- bloom sheen arc left of the crease
c:fill(c:line({ {24, 30}, {23, 34}, {23, 38} }, 1), "#a894dc")
-- leaf vein
c:fill(c:line({ {37, 15}, {42, 12}, {49, 8} }, 1), "#4a8a3e")
local t = c:save(O .. "aseprite/ph/nectaplum.aseprite", O .. "png/ph/nectaplum.png")
print(GV.report(t))
