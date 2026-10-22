local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local G = GV.ramp("#8fc463")
-- a pair of curled blades: thick root, tapering up and out, tip curling upward into a knob
local function pair(ry, spread, curlL, curlR)
  local m = c:mask()
  for _, sd in ipairs({ -1, 1 }) do
    local function X(dx) return 32 + sd * dx end
    m:add(c:line({ {X(1), ry}, {X(6), ry - 2}, {X(spread - 4), ry - 5} }, 4))
    m:add(c:line({ {X(spread - 4), ry - 5}, {X(spread), ry - 8} }, 3))
    local cu = (sd < 0) and curlL or curlR
    m:add(c:ellipse(X(spread) + 0.5 * sd, ry - 10 - cu, 2, 2))
  end
  return m
end
c:build{
  { "stalk", c:rrect(31, 20, 33, 55, 1), "#2e5a2c", { flat = true } },
  { "low",  pair(49, 16, 0, 1), G },
  { "mid",  pair(39, 13, 1, 0), G },
  { "up",   pair(29, 10, 0, 1), G },
  { "bob",  c:ellipse(32, 16, 5, 5), G },
}
c:ground(32, 57, 9, 1.5)
local t = c:save(O .. "aseprite/ph/reindeer-lichen.aseprite", O .. "png/ph/reindeer-lichen.png")
print(GV.report(t))
