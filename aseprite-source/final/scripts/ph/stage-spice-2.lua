local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- pointed leaf from base (bx,by) to tip (tx,ty), widest at 45%
local function leaf(bx, by, tx, ty, w)
  local dx, dy = tx - bx, ty - by
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L, dx / L
  local function at(f, o) return { bx + dx * f + nx * o, by + dy * f + ny * o } end
  return c:poly({ at(0, 1.6), at(0.25, w * 0.9), at(0.5, w), at(0.78, w * 0.6), at(1, 0),
                  at(0.78, -w * 0.6), at(0.5, -w), at(0.25, -w * 0.9), at(0, -1.6) })
end
local mound = c:ellipse(32, 45, 21, 7)
local top = c:ellipse(32, 43.5, 16, 3.5):clip(mound)
local p = c:build{
  { "mound", mound, GV.ramp("#7a4a1f") },
  { "top", top, GV.ramp("#9a6b3f"), { flat = true, contour = false, contact = false } },
  { "left", leaf(30, 43, 19, 31, 3.4), "moss" },
  { "right", leaf(34, 43, 45, 31, 3.4), "moss" },
  { "centre", leaf(32, 44, 32, 28, 3.4), GV.ramp("#4a8a3e") },
}
-- leaf midribs
c:fill(c:line({ { 28, 40 }, { 23, 35 } }, 1), "#4a8a3e")
c:fill(c:line({ { 36, 40 }, { 41, 35 } }, 1), "#4a8a3e")
c:fill(c:line({ { 32, 41 }, { 32, 33 } }, 1), "#2f5a2a")
-- a few soil crumbs
c:px(19, 46, "#5e2f1e"); c:px(44, 47, "#5e2f1e"); c:px(25, 49, "#5e2f1e"); c:px(39, 50, "#5e2f1e")
c:px(20, 45, "#9a6b3f"); c:px(45, 46, "#9a6b3f")
local t = c:save(O .. "aseprite/ph/stage-spice-2.aseprite", O .. "png/ph/stage-spice-2.png")
print(GV.report(t))
