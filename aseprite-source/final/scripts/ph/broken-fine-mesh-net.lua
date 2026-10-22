local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local wood = GV.ramp("#b6814d", { rim = "#f0d49a" })
local ringR = GV.ramp("#d6c9b6")
local mesh = GV.ramp("#a9d6ea")

-- handle, chipped at the bottom end
local handle = c:line({ {14, 54}, {33, 33} }, 4)
handle:cut(c:poly({ {11, 52}, {15, 56}, {11, 58} }))
local cx, cy = 41.5, 22.5
local ring = c:ellipse(cx, cy, 15, 15):cut(c:ellipse(cx, cy, 12, 12))
-- crack in the ring at upper left
ring:cut(c:poly({ {28, 13}, {31, 15}, {30, 17}, {27, 15} }))
local fill = c:ellipse(cx, cy, 12, 12)
-- jagged tear gap through the mesh
local tear = c:line({ {33, 13}, {37, 20}, {33, 25}, {38, 31} }, 2)
fill:cut(tear)

local p = c:build{
  { "handle", handle, wood },
  { "mesh", fill, mesh, { gloss = false, rim = false, light = c:ellipse(cx, cy, 15, 15) } },
  { "ring", ring, ringR, { light = c:ellipse(cx, cy, 15, 15), gloss = { 30, 11 } } },
}
-- cross-hatch mesh lines, skipping the tear
local fm = p.mesh.m
for i = -24, 24, 4 do
  for t = -14, 14 do
    local x1, y1 = math.floor(cx + t), math.floor(cy + t + i)
    if fm:has(x1, y1) then c:px(x1, y1, "#7fa7c0") end
    local x2, y2 = math.floor(cx + t), math.floor(cy - t + i)
    if fm:has(x2, y2) then c:px(x2, y2, "#7fa7c0") end
  end
end
-- dark torn edge pixels along the gap
tear:grow(1):clip(fm):edge():each(function(x, y) end)
c:paint({ "d.", ".d" }, 31, 12, { d = "#2a1a10" })
-- loose scraps of mesh
local s1 = c:line({ {46, 46}, {50, 49} }, 2)
local s2 = c:line({ {22, 42}, {18, 44} }, 2)
c:part(s1, mesh, { flat = true })
c:part(s2, mesh, { flat = true })

local t = c:save(O .. "aseprite/ph/broken-fine-mesh-net.aseprite", O .. "png/ph/broken-fine-mesh-net.png")
print(GV.report(t))
