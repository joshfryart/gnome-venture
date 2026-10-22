local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- lens-shaped leaf from base (bx,by) to tip (tx,ty), half width w
local function leaf(bx, by, tx, ty, w)
  local dx, dy = tx - bx, ty - by
  local len = math.sqrt(dx * dx + dy * dy)
  local px, py = -dy / len, dx / len
  local mx, my = bx + dx * 0.45, by + dy * 0.45
  return c:poly({
    { bx - px * 1.5, by - py * 1.5 },
    { mx - px * w, my - py * w },
    { tx, ty },
    { mx + px * w, my + py * w },
    { bx + px * 1.5, by + py * 1.5 },
  })
end

local p = c:build{
  { "mound", c:ellipse(32, 47, 21, 6), "#7a4a1f" },
  { "top",   c:ellipse(32, 45.5, 16, 3.5), "#9a6b3f", { gloss = false, flat = true } },
  { "lo",    leaf(30, 45, 11, 30, 5), "moss" },
  { "ro",    leaf(34, 45, 53, 30, 5), "#4a8a3e" },
  { "li",    leaf(31, 45, 21, 23, 4.5), "#4a8a3e" },
  { "ri",    leaf(33, 45, 43, 23, 4.5), "moss" },
  { "stem",  c:rect(31, 26, 33, 42), "#4a8a3e", { flat = true } },
  { "bud",   c:ellipse(32, 19, 8.5, 8), "#58a03e" },
}
local t = c:save(O .. "aseprite/ph/stage-spice-3.aseprite", O .. "png/ph/stage-spice-3.png")
print(GV.report(t))
