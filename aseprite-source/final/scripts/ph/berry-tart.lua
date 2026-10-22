local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- scalloped crust: ellipse plus bumps around the rim
local crust = c:ellipse(31.5, 33, 23, 11)
for i = 0, 17 do
  local a = i * math.pi * 2 / 18
  crust:add(c:ellipse(31.5 + math.cos(a) * 22, 33 + math.sin(a) * 10.5, 2.5, 2))
end
local tin = c:ellipse(31.5, 38, 23, 11):add(c:rect(9, 33, 54, 38))
local p = c:build{
  { "tin",   tin,   GV.ramp("#a8582f"), { gloss = false } },
  { "crust", crust, GV.ramp("#d9a660"), { gloss = { 12, 28 } } },
}
-- crimp notches
for i = 0, 17 do
  local a = i * math.pi * 2 / 18 + math.pi / 18
  local x = math.floor(31.5 + math.cos(a) * 22.5 + 0.5)
  local y = math.floor(33 + math.sin(a) * 11 + 0.5)
  if crust:has(x, y) then c:px(x, y, "#b07a45") end
end
local fill = c:ellipse(31.5, 33, 17, 7)
local pf = c:build{
  { "filling", fill, GV.ramp("#dd3a2a", { shade = "#ae2a2a" }), { gloss = { 18, 28 }, contact = false } },
}
-- berries
local function berry(x, y)
  c:paint({ ".bb.", "bbbb", "bbbb", ".bb." }, x, y, { b = "#6b1b2c" })
  c:px(x + 1, y + 1, "#ff9158")
end
berry(18, 32); berry(42, 32); berry(30, 35); berry(24, 28); berry(36, 28)
-- lattice strips clipped to filling
local lat = c:mask()
for _, s in ipairs({ { {16,28},{38,40} }, { {25,26},{48,38} }, { {47,28},{25,40} }, { {38,26},{15,38} } }) do
  lat:add(c:line(s, 2))
end
lat:clip(fill:grow(1))
c:part(lat, GV.ramp("#d9a660"), { flat = true, contact = false })
-- crust seam dashes along the front rim
local pts = {}
for i = 2, 16 do local a = i * math.pi / 18; pts[#pts+1] = { 31.5 + math.cos(a) * 20, 33 + math.sin(a) * 9.5 } end
c:seam(pts)
local t = c:save(O .. "aseprite/ph/berry-tart.aseprite", O .. "png/ph/berry-tart.png")
print(GV.report(t))
