local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local function hex(cx, cy, r)
  local h = r * 0.866
  return c:poly({ {cx, cy - r}, {cx + h, cy - r / 2}, {cx + h, cy + r / 2}, {cx, cy + r}, {cx - h, cy + r / 2}, {cx - h, cy - r / 2} })
end
local slab = hex(32, 30, 18)
slab:add(c:rrect(30, 44, 33, 51, 1))           -- honey drip bead
local p = c:build{
  { "slab",  slab, "gold" },
  { "rim",   hex(32, 30, 11), GV.ramp("#f5cf6a"), { gloss = false } },
  { "cell",  hex(32, 30, 5.5), GV.ramp("#b8661a", { shade = "#7a3a14" }), { gloss = false, cres = 2, deep = 1 } },
  { "c1",    hex(20, 31, 3.5), "#d0862a", { flat = true } },
  { "c2",    hex(44, 31, 3.5), "#d0862a", { flat = true } },
}
c:px(30, 27, "#e8a317"); c:px(31, 27, "#e8a317")  -- glint in the honey cell
local t = c:save(O .. "aseprite/ph/wild-honeycomb.aseprite", O .. "png/ph/wild-honeycomb.png")
print(GV.report(t))
