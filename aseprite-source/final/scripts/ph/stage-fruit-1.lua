local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dy = -3
local function leaf(mirror)
  local pts = { {33,50},{31.8,43.6},{29.8,40},{26,37.5},{20.5,35.5},{21.5,42},{23.2,46},{26.7,48.5} }
  local out = {}
  for i, p in ipairs(pts) do
    local x = p[1]
    if mirror then x = 64 - x end
    out[i] = { x, p[2] + dy }
  end
  return c:poly(out)
end
local mound = c:ellipse(32, 48, 21, 7)
local top = c:ellipse(32, 47, 16, 4)
local lL, lR = leaf(false), leaf(true)
c:build{
  { "mound", mound, GV.ramp("#8a4f2a") },
  { "top", top, GV.ramp("#a5663a"), { gloss = false } },
  { "leafL", lL, "moss" },
  { "leafR", lR, GV.ramp("#58a03e") },
}
-- veins
c:fill(c:line({ {31, 46}, {28, 42}, {24, 37} }, 1), "#4a8a3e")
c:fill(c:line({ {33, 46}, {36, 42}, {40, 37} }, 1), "#3f7a34")
-- a few soil crumbs on the mound
c:px(19, 50, "#5e2f1e"); c:px(44, 51, "#5e2f1e"); c:px(25, 52, "#5e2f1e"); c:px(38, 53, "#5e2f1e")
local t = c:save(O .. "aseprite/ph/stage-fruit-1.aseprite", O .. "png/ph/stage-fruit-1.png")
print(GV.report(t))
