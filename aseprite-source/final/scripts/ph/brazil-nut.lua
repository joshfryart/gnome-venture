local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- wedge: ellipse cut by a straight flat side (upper-right)
local shell = c:ellipse(31, 32, 19, 22):clip(c:poly({ {18, 0}, {60, 56}, {0, 64}, {0, 0} }))
-- flat face strip along the straight side
local face = shell:copy():clip(c:poly({ {5, 0}, {47, 56}, {48, 64}, {64, 64}, {64, 0} }))
-- cream nut meat inside the face, tapered at both ends
local meat = face:copy():shrink(1):clip(c:poly({ {7, 0}, {49, 56}, {50, 64}, {64, 64}, {64, 0} }))
meat:cut(c:poly({ {15, 0}, {57, 56}, {64, 56}, {64, 0} })):clip(c:ellipse(36, 31, 12, 19))
c:build{
  { "shell", shell, GV.ramp("#8a4f2a") },
  { "face", face, GV.ramp("#b07a45"), { gloss = false } },
  { "meat", meat, "cream", { contour = "#74462a" } },
}
-- ridges following the curved back
local function arc(rx, ry, a0, a1)
  local pts = {}
  for a = a0, a1, 6 do
    local r = math.rad(a)
    pts[#pts + 1] = { math.floor(31 + rx * math.cos(r) + 0.5), math.floor(32 + ry * math.sin(r) + 0.5) }
  end
  return pts
end
c:fill(c:line(arc(13, 16, 115, 230), 2):clip(shell):cut(face:grow(1)), "#5e2f1e")
c:fill(c:line(arc(7, 9, 120, 215), 2):clip(shell):cut(face:grow(1)), "#5e2f1e")
-- stem scar at the bottom
c:fill(c:rrect(29, 49, 32, 52, 1):clip(shell), "#5e2f1e")
local t = c:save(O .. "aseprite/ph/brazil-nut.aseprite", O .. "png/ph/brazil-nut.png")
print(GV.report(t))
