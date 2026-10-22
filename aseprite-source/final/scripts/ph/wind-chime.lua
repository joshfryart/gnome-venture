local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- sagging string
local pts = {}
for i = 0, 22 do
  local x = 10 + i * 2
  local u = (x - 32) / 22
  pts[#pts + 1] = { x, math.floor(17 + 8 * (1 - u * u) + 0.5) }
end
local string_ = c:line(pts, 2)
local function yAt(x) local u = (x - 32) / 22; return math.floor(17 + 8 * (1 - u * u) + 0.5) end
-- pennant triangles hanging below the string, staggered tips
local function tri(cx, top, w, tip)
  return c:poly({ { cx - w, top }, { cx + w + 1, top }, { cx + 1, tip }, { cx, tip } })
end
local L = tri(16, yAt(16) + 4, 5, 42)
local C = tri(32, yAt(32) + 4, 6, 52)
local R = tri(48, yAt(48) + 4, 5, 46)
-- caps (little gold rings) joining each pennant to the string
local cL = c:rrect(14, yAt(16) + 1, 19, yAt(16) + 5, 1)
local cC = c:rrect(30, yAt(32) + 1, 35, yAt(32) + 5, 1)
local cR = c:rrect(46, yAt(48) + 1, 51, yAt(48) + 5, 1)
c:build{
  { "string", string_, GV.ramp("#74462a"), { flat = true } },
  { "L", L, GV.ramp("#f08a24") },
  { "R", R, GV.ramp("#f08a24") },
  { "C", C, "gold" },
  { "cL", cL, "wood", { flat = true } },
  { "cC", cC, "wood", { flat = true } },
  { "cR", cR, "wood", { flat = true } },
}
-- thread ties
c:px(16, yAt(16) + 2, "#f5cf6a"); c:px(32, yAt(32) + 2, "#f5cf6a"); c:px(48, yAt(48) + 2, "#f5cf6a")
-- string end knots
c:px(10, yAt(10), "#f5cf6a"); c:px(54, yAt(54), "#f5cf6a")

local t = c:save(O .. "aseprite/ph/wind-chime.aseprite", O .. "png/ph/wind-chime.png")
print(GV.report(t))
