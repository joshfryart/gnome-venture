local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local legs = c:line({{21,45},{14,54}},3):add(c:line({{25,49},{17,55}},3))
legs:add(c:line({{42,45},{49,54}},3)):add(c:line({{38,49},{46,55}},3))
local arms = c:line({{20,40},{16,30}},3):add(c:line({{43,40},{47,30}},3))
local function claw(cx)
  local m = c:ellipse(cx, 24, 5.5, 7)
  m:cut(c:poly({{cx-2,16},{cx+3,16},{cx+0.5,23}}))
  return m
end
local claws = claw(15.5):add(claw(47.5))
local shell = c:ellipse(31.5, 43.5, 16, 11)
local belly = c:ellipse(31.5, 47.5, 8.5, 4.5)
local stalks = c:line({{26,34},{26,28}},2):add(c:line({{37,34},{37,28}},2))
c:build{
  { "legs", legs, GV.ramp("#e0501f"), { flat = true } },
  { "arms", arms, GV.ramp("#e0501f"), { flat = true } },
  { "claws", claws, GV.ramp("#f08a24") },
  { "shell", shell, GV.ramp("#f08a24") },
  { "belly", belly, GV.ramp("#f8eed2"), { gloss = false } },
  { "stalks", stalks, GV.ramp("#e0501f"), { flat = true } },
}
c:eye(24, 24); c:eye(35, 24)
c:paint({ "u...u", ".uuu." }, 29, 37, { u = "umber" })
local t = c:save(O .. "aseprite/ico/ico-crab.aseprite", O .. "png/ico/ico-crab.png")
print(GV.report(t))
