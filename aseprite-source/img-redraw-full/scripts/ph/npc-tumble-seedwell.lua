local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }
local cx, cy = 39.5, 50
-- quill fan: 15 triangles, alternating two browns
local qA, qB = c:mask(), c:mask()
for i = 0, 14 do
  local a = math.rad(166 - i * (152 / 14))
  local h = math.rad(9)
  local rb, rt = 18, 36
  if i % 2 == 1 then rt = 31 end
  local p = {
    { cx + rb * math.cos(a - h), cy - rb * math.sin(a - h) },
    { cx + rt * math.cos(a), cy - rt * math.sin(a) },
    { cx + rb * math.cos(a + h), cy - rb * math.sin(a + h) },
  }
  local t = c:poly(p)
  if i % 2 == 0 then qA:add(t) else qB:add(t) end
end
qB:cut(qA)
local head = c:ellipse(cx, cy, 24, 24)
local body = c:rrect(7, 74, 72, 105, 9)
local collar = c:poly({ {28, 75}, {51, 75}, {39.5, 88} })
local cap = c:ellipse(cx, cy, 25, 25):clip(c:rect(0, 0, 79, 37))
cap:add(c:poly({ {14, 33}, {21, 33}, {17, 56} }))
cap:add(c:poly({ {58, 33}, {65, 33}, {62, 56} }))
cap:add(c:ellipse(39.5, 23, 3, 3))
local band = c:rect(15, 35, 64, 37):clip(cap)
local face = c:ellipse(cx, 55, 15, 12)
c:build{
  { "qB", qB, "#44281c" },
  { "qA", qA, "#8c4a1a" },
  { "body", body, "#d9667f" },
  { "collar", collar, "#9c2a1e", { flat = true } },
  { "head", head, "#c3b2ea" },
  { "face", face, "#f8eed2" },
  { "cap", cap, "#58a03e" },
  { "band", band, "#2e5a2c", { flat = true } },
}
c:seam({ {16, 36}, {63, 36} })
-- placket + buttons
c:fill(c:rect(39, 88, 40, 99), "#2a1a10")
c:button(38, 89); c:button(38, 95)
-- face
c:eye(27, 48); c:eye(48, 48)
c:paint({ ".nnnn.", "nnnnnn", ".nnnn." }, 37, 56, { n = "#2a1a10" })
c:px(38, 56, "#5e2a3a")
c:paint({ "u......u", ".uuuuuu." }, 36, 61, { u = "umber" })
local t = c:save(O .. "aseprite/ph/npc-tumble-seedwell.aseprite", O .. "png/ph/npc-tumble-seedwell.png")
print(GV.report(t))
