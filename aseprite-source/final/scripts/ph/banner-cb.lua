-- ph/banner-cb : tropical palm-isle seascape, 120x40 grid written at 2x (240x80)
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local c = GV.canvas{ mode = "scene", w = 120, h = 40, out = 2, ol = 1, olx = 1, cres = 2, deep = 1 }
-- sky: hard stepped bands, paler toward the horizon
c:bands(c:rect(0, 0, 119, 20), { "#a9d6ea", "#b4dcec", "#bfe4e6", "#c8ecdc" })
-- sea: flat turquoise deepening toward the viewer
c:bands(c:rect(0, 21, 119, 39), { "#3f93b2", "#3f93b2", "#3787ab", "#2f7ca6" })
c:fill(c:rect(0, 21, 119, 21), "#8fcbd8")                       -- horizon glint strip
-- sun and cloud
c:part(c:ellipse(102, 8, 4), "gold", { gloss = { 100, 6 } })
local cloud = c:ellipse(36, 7.5, 7, 2):add(c:ellipse(33, 5.5, 3, 2)):add(c:ellipse(39, 6, 3, 1.5))
c:part(cloud, "#f4f0e0", { flat = true })
-- island
c:part(c:ellipse(60, 30, 20, 5), "gold", { gloss = { 46, 28 } })
c:part(c:ellipse(60, 28, 17, 3), "#9cb85a", { gloss = { 50, 26 } })
-- palms (lean toward each other)
local function palm(base, mid, top, tw, fronds, nuts)
  c:part(c:line({ base, mid, top }, tw), "#c4925f", { gloss = false })
  for _, f in ipairs(fronds) do c:part(c:line(f, 2), "#58a03e", { gloss = false, contact = false }) end
  for _, n in ipairs(nuts) do c:part(c:rect(n[1], n[2], n[1] + 1, n[2] + 1), "#8c4a1a", { flat = true, contact = false }) end
end
palm({ 50, 28 }, { 48, 21 }, { 46, 13 }, 3, {
  { {46, 12}, {41, 10}, {37, 13} },
  { {46, 12}, {42, 15}, {40, 19} },
  { {46, 12}, {50, 9},  {55, 10} },
  { {46, 12}, {51, 14}, {54, 18} },
  { {46, 12}, {45, 8},  {41, 6} },
}, { {45, 14}, {47, 15} })
palm({ 69, 28 }, { 71, 22 }, { 73, 17 }, 2, {
  { {73, 16}, {69, 14}, {66, 16} },
  { {73, 16}, {77, 14}, {80, 16} },
  { {73, 16}, {76, 18}, {78, 21} },
  { {73, 16}, {74, 12}, {77, 10} },
}, { {72, 18} })
-- wave marks
for _, w in ipairs({ {5, 36}, {31, 34}, {58, 37}, {84, 34}, {111, 36} }) do
  c:paint({ ".ww..", "w..ww" }, w[1], w[2], { w = "#f4f0e0" })
end
-- hem stitch top and bottom
c:seam({ {0, 1}, {119, 1} }, { free = true })
c:seam({ {0, 38}, {119, 38} }, { free = true })
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local t = c:save(O .. "aseprite/ph/banner-cb.aseprite", O .. "png/ph/banner-cb.png")
print(GV.report(t))
