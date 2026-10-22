local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local cx, cy, d, r = 31.5, 32.5, 12, 9.5
local petal = GV.ramp("#e58aa8", { gloss = "#f6b8cf" })
local function P(a)
  local t = math.rad(a)
  return c:ellipse(cx + d * math.cos(t), cy + d * math.sin(t), r, r)
end
local whole = c:mask()
for _, a in ipairs({ -90, -18, 54, 126, 198 }) do whole:add(P(a)) end
-- paint bottom petals first, top petal last so each overlap gets a contour
c:part(P(54), petal, { light = whole, gloss = false })
c:part(P(126), petal, { light = whole, gloss = false })
c:part(P(-18), petal, { light = whole, gloss = false })
c:part(P(198), petal, { light = whole, gloss = { 16, 26 } })
c:part(P(-90), petal, { light = whole, gloss = { 27, 16 } })
c:part(c:ellipse(cx, cy, 6.5, 6.5), GV.ramp("#f2b830", { shade = "#d0862a" }), { gloss = { 28, 29 } })
c:paint({ "dd", "dd" }, 30, 34, { d = "#b8661a" })
c:paint({ "dd", "dd" }, 34, 31, { d = "#b8661a" })
local t = c:save(O .. "aseprite/ico/ico-blossom.aseprite", O .. "png/ico/ico-blossom.png")
print(GV.report(t))
