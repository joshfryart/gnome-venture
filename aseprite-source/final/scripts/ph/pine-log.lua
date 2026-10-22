local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- horizontal log body, rounded left end, ring face on the right
local body = c:rect(12, 24, 49, 49)
body:add(c:ellipse(12, 36.5, 6, 12.5))
local stub = c:poly({ {18, 26}, {19, 18}, {26, 18}, {27, 26} })
local face = c:ellipse(49.5, 36.5, 8, 12.5)

local p = c:build{
  { "stub", stub, GV.ramp("#8a4f2a") },
  { "body", body, GV.ramp("#8a4f2a"), { light = body:copy():add(face) } },
  { "face", face, GV.ramp("#e8bf7a", { rim = "#fff1c8" }), { gloss = { 45, 28 } } },
}
-- stub cut end on top
c:fill(c:ellipse(22.5, 18.5, 3, 1.5), "#d9a660")
c:px(22, 18, "#b07a45"); c:px(23, 18, "#b07a45")

-- rings on the face
local ring1 = face:shrink(3):edge()
local ring2 = c:ellipse(49.5, 36.5, 3, 6):edge()
c:fill(ring1:cut(c:rect(42, 24, 46, 31)), "#b07a45")
c:fill(ring2, "#b07a45")
c:fill(c:rect(49, 35, 50, 37), "#8a4f2a")

-- bark grooves
local deep = "#5e2f1e"
c:fill(c:line({ {12, 31}, {20, 30}, {30, 31}, {40, 30} }, 2), deep)
c:fill(c:line({ {9, 38}, {18, 39}, {28, 38}, {38, 39} }, 2), deep)
c:fill(c:line({ {13, 45}, {22, 44}, {34, 45} }, 2), deep)
-- bark lit flecks above grooves
for _, q in ipairs({ {14, 29}, {25, 29}, {33, 36}, {16, 36}, {27, 43} }) do c:px(q[1], q[2], "#b07a45") end

-- needle tuft on the stub
local g = GV.ramp("#4a8a3e")
c:paint({
  "a.a.a",
  ".bbb.",
  "a.b.a",
}, 20, 12, { a = "#7ab55c", b = "#4a8a3e" })
c:fill(c:rect(22, 15, 23, 17), "#2f5a2a")

c:ground(32, 51, 22, 1.5)
local t = c:save(O .. "aseprite/ph/pine-log.aseprite", O .. "png/ph/pine-log.png")
print(GV.report(t))
