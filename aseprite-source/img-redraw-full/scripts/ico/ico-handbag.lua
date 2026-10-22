local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local pts = {}
for i = 0, 16 do
  local a = math.rad(180 - 180 * i / 16)
  pts[#pts + 1] = { math.floor(32 + 15 * math.cos(a) + 0.5), math.floor(30 - 15 * math.sin(a) + 0.5) }
end
local handle = c:line(pts, 4)
local body = c:rrect(9, 27, 55, 53, 8)
local flap = c:poly({ { 9, 27 }, { 56, 27 }, { 56, 37 }, { 32, 48 }, { 9, 37 } }):clip(body)
local p = c:build{
  { "handle", handle, "wood" },
  { "body", body, GV.ramp("#d9667f") },
  { "flap", flap, "red", { stitch = { side = "lit" } } },
}
c:seam({ { 11, 38 }, { 32, 47 }, { 53, 38 } }, { free = false })
local clasp = c:ellipse(32, 42, 3.5, 3.5)
c:part(clasp, GV.ramp("#f8eed2"), { flat = true, contour = "#4a2c1a" })
c:outline(clasp)

local t = c:save(O .. "aseprite/ico/ico-handbag.aseprite", O .. "png/ico/ico-handbag.png")
print(GV.report(t))
