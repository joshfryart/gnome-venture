local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 80, h = 100, mode = "bust" }

local disc = c:ellipse(39.5, 48, 33, 33)
local body = c:ellipse(39.5, 100, 34, 24)
-- scarf band + hanging tail
local scarf = c:line({ {27, 78}, {39.5, 84}, {52, 78} }, 6)
scarf:add(c:poly({ {45, 80}, {53, 80}, {54, 96}, {44, 96} }))
local face = c:ellipse(39.5, 52, 23, 21)
-- little ear nubs at the sides of the face
local muzzle = c:ellipse(39.5, 64, 14, 11)
local nose = c:mask()
local ncx, ncy = 39.5, 62.5
for i = 0, 7 do
  local a = i * math.pi / 4
  local ex, ey = ncx + 5.5 * math.cos(a), ncy + 5.5 * math.sin(a)
  nose:add(c:line({ {math.floor(ncx), math.floor(ncy)}, {math.floor(ex + 0.5), math.floor(ey + 0.5)} }, 2))
end
local band = c:line({ {17, 44}, {28, 39}, {39.5, 37}, {51, 39}, {62, 44} }, 6):clip(face:grow(1))

local p = c:build{
  { "disc",   disc,   GV.ramp("#b8d8d2"), { gloss = false } },
  { "body",   body,   GV.ramp("#58a03e"), { stitch = { side = "lit" } } },
  { "scarf",  scarf,  "moss", { gloss = { 46, 81 } } },
  { "face",   face,   GV.ramp("#8f7060") },
  { "band",   band,   GV.ramp("#6cb848"), { gloss = { 27, 40 } } },
  { "muzzle", muzzle, GV.ramp("#e6d2ae"), { gloss = false } },
  { "nose",   nose,   "petal", { flat = true } },
  { "nosec",  c:ellipse(39.5, 62.5, 3, 3), GV.ramp("#d9667f"), { gloss = { 38, 61 } } },
}
-- bead on the headband
c:paint({ ".dd.", "dggd", "dddd", ".dd." }, 54, 37, { d = "#2e5a2c", g = "#7ab55c" })
-- scarf hem seam
c:seam({ {45, 94}, {53, 94} })
c:button(37, 82)
-- tiny eyes
c:eye(29, 48, true); c:eye(48, 48, true)
-- smile
c:paint({ "u.........u", ".uuuuuuuuu." }, 34, 71, { u = "#2a1a10" })
local t = c:save(O .. "aseprite/ph/npc-nutmeg-rootstock.aseprite", O .. "png/ph/npc-nutmeg-rootstock.png")
print(GV.report(t))
