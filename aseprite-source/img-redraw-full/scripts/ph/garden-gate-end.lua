local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local pale = GV.ramp("#f4f0e0")
-- rails run behind the pickets toward the right
local rails = c:rect(26, 26, 56, 28):add(c:rect(26, 37, 56, 39))
-- five pickets with pointed rounded tops, stepping slightly
local pick = c:mask()
for i, x in ipairs({ 31, 37, 43, 49, 55 }) do
  local top = 18 + (i % 2)
  pick:add(c:rect(x, top + 1, x + 2, 45))
  pick:add(c:rect(x + 1, top, x + 1, top))
end
local post = c:rrect(9, 14, 25, 49, 2)
local cap = c:rrect(7, 11, 27, 15, 1)
local panel = c:rrect(13, 21, 21, 42, 2)
local p = c:build{
  { "rails", rails, "#968f96" },
  { "pick", pick, pale, { gloss = false } },
  { "post", post, "#d6c9b6" },
  { "cap", cap, "#d6c9b6", { gloss = false } },
  { "panel", panel, pale, { gloss = false } },
}
-- picket glints
for i, x in ipairs({ 31, 37, 43, 49, 55 }) do c:px(x, 21 + (i % 2), "#fff3c8") end
c:button(15, 24)
c:ground(32, 50, 22, 1.5)
local t = c:save(O .. "aseprite/ph/garden-gate-end.aseprite", O .. "png/ph/garden-gate-end.png")
print(GV.report(t))
