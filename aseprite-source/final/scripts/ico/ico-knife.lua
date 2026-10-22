local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- axis: handle at lower-left, tip at upper-right (~41 deg from vertical)
local ux, uy = 0.66, -0.75
local nx, ny = 0.75, 0.66          -- normal toward lower-right (cutting edge side)
local ox, oy = 17.5, 50.5
local function P(t, s) return { ox + t * ux + s * nx, oy + t * uy + s * ny } end
local function shape(list) local r = {} for i, v in ipairs(list) do r[i] = P(v[1], v[2]) end return r end
local handle = c:poly(shape{ {0,-3}, {1,-4}, {15,-4}, {15,4}, {1,4}, {0,3} })
local bolster = c:poly(shape{ {14,-6}, {19,-6}, {19,6}, {14,6} })
local blade = c:poly(shape{ {18,-4.5}, {36,-4.5}, {41,-3.5}, {44,-2}, {43.5,0}, {41,2.5}, {36,4.5}, {28,5.5}, {18,5.5} })
c:build{
  { "handle", handle, "wood" },
  { "bolster", bolster, "gold" },
  { "blade", blade, GV.ramp("#cfd6dc") },
}
-- spine bevel line just inside the upper-left edge
local a, b = P(20, -2), P(37, -2)
c:fill(c:line({ { math.floor(a[1]), math.floor(a[2]) }, { math.floor(b[1]), math.floor(b[2]) } }, 1), "#8b8f96")
-- handle rivets
for _, t in ipairs({ 4, 10 }) do
  local p = P(t, 0)
  c:paint({ "gg", "gG" }, math.floor(p[1]) - 1, math.floor(p[2]) - 1, { g = "#dcb06a", G = "#b8661a" })
end
local t = c:save(O .. "aseprite/ico/ico-knife.aseprite", O .. "png/ico/ico-knife.png")
print(GV.report(t))
