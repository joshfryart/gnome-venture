local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:ellipse(31.5, 37, 16, 15)
local stem = c:rrect(30, 14, 33, 24, 1)
local leaf = c:poly({ { 33, 20 }, { 36, 14 }, { 41, 10 }, { 47, 8 }, { 45, 13 }, { 41, 18 }, { 36, 21 } })

local p = c:build{
  { "stem", stem, GV.ramp("#2f5a2a"), { flat = true } },
  { "body", body, "moss", { gloss = { 23, 28 } } },
  { "leaf", leaf, GV.ramp("#58a03e") },
}
-- darker belly band: repaint the base tone below a gentle curve
local band = GV.ramp("#58a03e")
local base = GV.R.moss.base
p.body.m:each(function(x, y)
  local edge = 41 + math.floor(((x - 31.5) / 16) ^ 2 * -3 + 0.5)
  if y >= edge and c:get(x, y) == base then c:px(x, y, band.base) end
end)
-- skin crease arc across the lower belly
c:fill(c:line({ { 20, 40 }, { 25, 42 }, { 32, 43 }, { 38, 42 }, { 43, 40 } }, 1):clip(p.body.m:shrink(2)), "#2f5a2a")
-- leaf midrib
c:fill(c:line({ { 36, 18 }, { 44, 11 } }, 1):clip(p.leaf.m:shrink(1)), "#2f5a2a")
local t = c:save(O .. "aseprite/ph/lucuma.aseprite", O .. "png/ph/lucuma.png")
print(GV.report(t))
