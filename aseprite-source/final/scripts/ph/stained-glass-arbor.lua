local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local post = GV.ramp("#8a4f2a")
local beam = GV.ramp("#b07a45")
local arch = GV.ramp("#d9a660")

local inner = c:ellipse(31.5, 29, 19, 13)
-- jewel panes (behind the frame)
local redP  = inner:copy():clip(c:rect(14, 14, 30, 27))
local blueP = inner:copy():clip(c:rect(33, 14, 49, 27))
local grnP  = c:rect(14, 29, 30, 40)
local goldP = c:rect(33, 29, 49, 40)

local posts = c:rect(11, 22, 14, 51):add(c:rect(30, 22, 33, 51)):add(c:rect(49, 22, 52, 51))
local beams = c:rect(10, 26, 53, 30):add(c:rect(10, 39, 53, 43))
local top = c:ellipse(31.5, 29, 22, 16):cut(inner):cut(c:rect(0, 28, 63, 63))
local feet = c:rect(10, 51, 15, 53):add(c:rect(29, 51, 34, 53)):add(c:rect(48, 51, 53, 53))

local p = c:build{
  { "red", redP, "red", { gloss = { 18, 19 } } },
  { "blue", blueP, "water", { gloss = { 37, 19 } } },
  { "green", grnP, "moss", { gloss = { 17, 32 } } },
  { "gold", goldP, "gold", { gloss = { 36, 32 } } },
  { "posts", posts, post, { gloss = false } },
  { "feet", feet, "#5e2f1e", { gloss = false } },
  { "beams", beams, beam, { gloss = false } },
  { "arch", top, arch, { gloss = false } },
}
c:seam({ { 11, 28 }, { 52, 28 } })
c:seam({ { 11, 41 }, { 52, 41 } })

c:ground(31.5, 54, 25, 1.5)
local t = c:save(O .. "aseprite/ph/stained-glass-arbor.aseprite", O .. "png/ph/stained-glass-arbor.png")
print(GV.report(t))
