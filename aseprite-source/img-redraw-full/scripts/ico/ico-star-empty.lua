local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local function star(cx, cy, R, r)
  local pts = {}
  for i = 0, 9 do
    local a = math.rad(-90 + i * 36)
    local rr = (i % 2 == 0) and R or r
    pts[#pts + 1] = { cx + rr * math.cos(a), cy + rr * math.sin(a) }
  end
  return c:poly(pts)
end
local outer = star(32, 33.5, 21, 9.5)
local well = star(32, 34, 13.5, 6):clip(outer:shrink(3))
local p = c:build{
  { "rim", outer, "#c9a96e" },
}
-- pale recessed well: flat, shaded on the upper-left inside edge (light falls past the lip)
c:part(well, "#f1ece0", { flat = true, rim = false, contour = false, contact = false })
well:each(function(x, y)
  if not well:has(x - 1, y) or not well:has(x, y - 1) then c:px(x, y, "#9a6b3f") end
end)
local t = c:save(O .. "aseprite/ico/ico-star-empty.aseprite", O .. "png/ico/ico-star-empty.png")
print(GV.report(t))
