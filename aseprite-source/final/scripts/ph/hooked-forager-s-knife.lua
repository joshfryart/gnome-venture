local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- sickle blade: bulges right, hooks back left at the top
local blade = c:poly({
  {32,37},{37,32},{42,26},{46,19},{48,13},{47,8},{44,5},{39,4},{34,5},{32,7},
  {33,10},{37,9},{40,10},{42,13},{41,18},{37,24},{32,29},{26,33}
})
local handle = c:poly({ {14,50},{21,55},{31,41},{25,36} })
local ferrule = c:poly({ {33,38},{31,42},{23,37},{25,33} })
local pommel = c:ellipse(17, 53, 4.5, 4.5)

local p = c:build{
  { "blade",   blade,   "#8b8f96" },
  { "handle",  handle,  "wood" },
  { "ferrule", ferrule, "gold", { gloss = false } },
  { "pommel",  pommel,  "#a8582f" },
}

-- bright honed edge along the inner (cutting) curve
local edge = c:line({ {33,8},{37,8},{40,9},{41,12},{40,17},{36,23},{31,28},{28,31} }, 1)
c:fill(edge:clip(p.blade.m), "#c9c5bc")

c:seam({ {20,51}, {28,40} })

local t = c:save(O .. "aseprite/ph/hooked-forager-s-knife.aseprite", O .. "png/ph/hooked-forager-s-knife.png")
print(GV.report(t))
