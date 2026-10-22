local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local olive, olive2, leafR = GV.ramp("#b0bc66"), GV.ramp("#a4b86a"), GV.ramp("#58a03e")
-- twin sprout leaves tilted outward
local leaves = c:poly({ {29, 20}, {24, 15}, {20, 9}, {26, 11}, {31, 17} })
leaves:add(c:poly({ {34, 20}, {39, 15}, {43, 9}, {37, 11}, {32, 17} }))
-- ruffled frill (scalloped top)
local ruffle = c:rrect(20, 19, 43, 28, 4)
for x = 22, 42, 5 do ruffle:add(c:ellipse(x, 19, 2.5, 2)) end
local body = c:ellipse(31.5, 42, 19, 15)
local p = c:build{
  { "leaves", leaves, leafR, { gloss = false } },
  { "ruffle", ruffle, olive2 },
  { "body", body, olive, { stitch = { side = "lit" } } },
}
-- ruffle pleats
for x = 24, 40, 4 do c:px(x, 22, olive2.shade); c:px(x, 23, olive2.shade); c:px(x, 24, olive2.shade) end
-- cord and tails
c:fill(c:rect(19, 27, 44, 28), "#7a4a1f")
local tails = c:line({ {26, 29}, {23, 37} }, 2):add(c:line({ {37, 29}, {40, 37} }, 2))
c:fill(tails, "#7a4a1f")
c:part(c:rrect(21, 37, 24, 40, 1), "gold", { flat = true, contact = false })
c:part(c:rrect(39, 37, 42, 40, 1), "gold", { flat = true, contact = false })
-- lotus pod emblem (teardrop, point down)
local pod = c:ellipse(32, 38, 6, 6):add(c:poly({ {26, 39}, {39, 39}, {32, 53} }))
c:part(pod, "moss", { cres = 2, deep = 1, contact = false, gloss = { 28, 35 } })
for _, q in ipairs({ {30, 37}, {34, 37}, {32, 40}, {30, 43}, {34, 43} }) do
  c:px(q[1], q[2], "#2f5a2a"); c:px(q[1] + 1, q[2], "#2f5a2a")
end
local t = c:save(O .. "aseprite/ph/sacred-lotus-seed.aseprite", O .. "png/ph/sacred-lotus-seed.png")
print(GV.report(t))
