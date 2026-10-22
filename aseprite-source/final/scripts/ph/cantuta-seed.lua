local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local seed = c:ellipse(31.5, 24, 8, 8)
local crate = c:rrect(11, 30, 52, 56, 2)
local rim = c:rrect(9, 27, 54, 33, 2)
local leaf = c:poly({ {33,14}, {37,10}, {42,10}, {41,13}, {37,15} })
local p = c:build{
  { "seed",  seed,  GV.ramp("#3f93b2", { shade = "#2f6290" }) },
  { "crate", crate, "wood", { gloss = false } },
  { "rim",   rim,   GV.ramp("#d9a660", { shade = "#a8582f" }) },
}
-- slat gaps
c:fill(c:rect(13, 42, 50, 42), "#5e2f1e")
c:fill(c:rect(13, 49, 50, 49), "#5e2f1e")
c:fill(c:rect(31, 34, 32, 54), "#8a4f2a")
-- nails
for _, q in ipairs({ {14,37}, {48,37}, {14,52}, {48,52} }) do
  c:fill(c:rect(q[1], q[2], q[1] + 1, q[2] + 1), "#2a1a10")
  c:px(q[1], q[2], "#ecc58a")
end
-- sprout
c:fill(c:line({ {32,16}, {32,11} }, 2), "#2f5a2a")
c:part(leaf, GV.ramp("#58a03e"), { flat = true })
local t = c:save(O .. "aseprite/ph/cantuta-seed.aseprite", O .. "png/ph/cantuta-seed.png")
print(GV.report(t))
