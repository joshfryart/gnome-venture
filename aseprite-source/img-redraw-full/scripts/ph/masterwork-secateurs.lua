local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- blades: tapered, curved hooks; left blade is a bypass blade with a broad back
local bl = c:poly({ {28, 37}, {34, 32}, {23, 13}, {17, 9}, {16, 16} })
local br = c:poly({ {30, 32}, {36, 37}, {48, 16}, {47, 9}, {41, 13} })
local hl = c:line({ {30, 37}, {22, 53} }, 6)
local hr = c:line({ {34, 37}, {42, 53} }, 6)
local piv = c:ellipse(32, 34, 4.5)
local p = c:build{
  { "hl", hl, GV.ramp("#8a4f2a") },
  { "hr", hr, GV.ramp("#8a4f2a") },
  { "bl", bl, "gold" },
  { "br", br, "gold", { gloss = false } },
  { "piv", piv, GV.ramp("#b8661a"), { gloss = { 30, 32 } } },
}
-- handle grip wraps
c:seam({ {18, 47}, {29, 49} }, { free = false })
c:seam({ {35, 49}, {46, 47} }, { free = false })
-- rivet centre
c:fill(c:rect(32, 34, 33, 35), "#7a3a14")
c:px(30, 32, "#fff1c8")
local t = c:save(O .. "aseprite/ph/masterwork-secateurs.aseprite", O .. "png/ph/masterwork-secateurs.png")
print(GV.report(t))
