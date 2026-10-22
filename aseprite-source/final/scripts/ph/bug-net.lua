local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local hoop = c:ellipse(42, 22, 14, 14)
local net = c:ellipse(42, 22, 11, 11)
local rim = hoop:copy():cut(net)
c:build{
  { "handle", c:line({ {12,56},{34,32} }, 4), GV.ramp("#b6814d") },
  { "net", net, GV.ramp("#a9d6ea"), { flat = true } },
}
-- mesh: cross plus diagonal light threads inside net
local M = "#2a1a10"
local m = c:rect(31, 21, 53, 22):add(c:rect(41, 11, 42, 33)):clip(net)
c:fill(m, M)
local thin = c:mask()
for _, d in ipairs({ -12, 12 }) do
  for x = 30, 54 do thin:set(x, 22 + (x - 42) + d); thin:set(x, 22 - (x - 42) + d) end
end
thin:clip(net:shrink(1)); thin:cut(m)
c:fill(thin, "#7fb6cc")
c:part(rim, GV.ramp("#8c4a1a"))
-- lashing where handle meets hoop
c:seam({ {33,31},{36,34} }, { on = 1, off = 1 })
c:seam({ {31,33},{34,36} }, { on = 1, off = 1 })
c:gloss(net, GV.ramp("#a9d6ea"), { 36, 15 })
local t = c:save(O .. "aseprite/ph/bug-net.aseprite", O .. "png/ph/bug-net.png")
print(GV.report(t))
