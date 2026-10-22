local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local px, py = 31.5, 36
-- pointed spike: diamond-ish leaf from pivot outward at angle a (deg from vertical)
local function spike(a, len, wid)
  local r = math.rad(a)
  local dx, dy = math.sin(r), -math.cos(r)
  local nx, ny = -dy, dx
  local tip = { px + dx * len, py + dy * len }
  local m1  = { px + dx * len * 0.45 + nx * wid, py + dy * len * 0.45 + ny * wid }
  local m2  = { px + dx * len * 0.45 - nx * wid, py + dy * len * 0.45 - ny * wid }
  local b1  = { px + nx * 2, py + ny * 2 }
  local b2  = { px - nx * 2, py - ny * 2 }
  return c:poly({ b1, m1, tip, m2, b2 })
end
local moss  = "moss"
local dark  = GV.ramp("#4a8a3e")
local stem  = c:rrect(29, 34, 34, 51, 2)
c:build{
  { "stem",  stem,               GV.ramp("#2f5a2a"), { gloss = false } },
  { "s1",    spike(-68, 21, 5),  moss, { gloss = false } },
  { "s5",    spike(68, 21, 5),   moss, { gloss = false } },
  { "s2",    spike(-34, 25, 5.5), moss, { gloss = { 22, 22 } } },
  { "s4",    spike(34, 25, 5.5),  moss, { gloss = false } },
  { "s3",    spike(0, 29, 6),    dark, { gloss = { 29, 16 } } },
  { "hub",   c:ellipse(31.5, 36, 5.5, 5), "gold" },
}
c:seam({ { 31, 11 }, { 31, 28 } })
c:ground(31.5, 52, 13, 2)
local t = c:save(O .. "aseprite/ph/thistle-heart.aseprite", O .. "png/ph/thistle-heart.png")
print(GV.report(t))
