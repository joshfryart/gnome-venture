local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-full/"
-- bell shell: dome + flared skirt + lip
local shell = c:ellipse(27, 30, 14, 12):cut(c:rect(0, 31, 63, 63))
shell:add(c:poly({ {13, 30}, {42, 30}, {45, 44}, {10, 44} }))
shell:add(c:rrect(9, 41, 45, 47, 2))
local head = c:ellipse(47, 42, 6.5, 6)
local bead = c:ellipse(27.5, 15.5, 3.5, 3.5)
-- legs
c:limb({ {13, 47}, {10, 52} }); c:limb({ {21, 47}, {19, 53} })
c:limb({ {33, 47}, {35, 53} }); c:limb({ {41, 48}, {44, 53} })
local p = c:build{
  { "bead", bead, "#e8a317" },
  { "shell", shell, "#4a5160", { light = shell:copy():add(head) } },
  { "head", head, "#6e7685" },
}
-- ribs (clipped to shell, not over head)
local rmask = c:mask()
rmask:add(c:line({ {27, 19}, {27, 46} }, 2))
rmask:add(c:line({ {19, 22}, {16, 32}, {14, 46} }, 2))
rmask:add(c:line({ {35, 22}, {38, 32}, {40, 46} }, 2))
rmask:clip(p.shell.m:shrink(1)); rmask:cut(head:grow(1))
c:fill(rmask, "#2f3440")
local ll = c:line({ {12, 40}, {42, 40} }, 1); ll:clip(p.shell.m:shrink(1)); ll:cut(head:grow(1)); ll:cut(rmask)
c:fill(ll, "#a9afba")
c:seam({ {11, 44}, {40, 44} })
-- antennae
local ant = c:line({ {50, 37}, {53, 32} }, 2):add(c:rect(51, 29, 54, 32))
local ant2 = c:line({ {46, 37}, {45, 31} }, 2):add(c:rect(43, 28, 46, 31))
c:part(ant, "#6e7685", { flat = true }); c:part(ant2, "#6e7685", { flat = true })
c:eye(48, 40, true)
local t = c:save(O .. "aseprite/ph/creature-bellcap-beetle.aseprite", O .. "png/ph/creature-bellcap-beetle.png")
print(GV.report(t))
