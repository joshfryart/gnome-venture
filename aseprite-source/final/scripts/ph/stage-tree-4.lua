local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local G = GV.R.gold
local trunk = c:rect(29, 30, 35, 47):add(c:poly({ {27,48},{29,43},{36,43},{38,48} }))
c:build{
  { "mound", c:ellipse(32, 47, 19, 5), "#7a4a1f", { gloss = false } },
  { "top",   c:ellipse(32, 46, 15, 3.5), "#9a6b3f", { gloss = false } },
  { "trunk", trunk, GV.ramp("#b07a45", { rim = "#d9a660" }), { gloss = false } },
  { "crown", c:ellipse(32, 22, 12), GV.ramp("#6a9a3a", { gloss = "#c8d77a", shade = "#4a8a3e", deep = "#2f5a2a" }) },
  { "lobeL", c:ellipse(23.5, 27, 8.5), GV.ramp("#4a8a3e", { deep = "#2f5a2a" }), { gloss = false } },
  { "lobeR", c:ellipse(40.5, 26.5, 8.5), GV.ramp("#7ab55c", { gloss = "#c8d77a" }) },
}
-- gold fruit (4x4 cut-corner discs)
for _, p in ipairs({ {22,25}, {37,18}, {31,29}, {27,15}, {42,28} }) do
  c:paint({ ".rb.", "rgbs", "bbsd", ".sd." }, p[1]-1, p[2]-1,
    { r = G.rim, g = "#fff1c8", b = G.base, s = G.shade, d = G.deep })
end
local t = c:save(O .. "aseprite/ph/stage-tree-4.aseprite", O .. "png/ph/stage-tree-4.png")
print(GV.report(t))
