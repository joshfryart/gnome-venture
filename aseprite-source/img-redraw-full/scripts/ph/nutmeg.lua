-- ph/nutmeg : brown oval seed with a scalloped scarlet mace cap
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = D .. "img-redraw-full/"

local body = c:ellipse(31.5, 37, 15, 17)          -- x 17..46, y 20..54
local cap = body:grow(1):clip(c:rect(0, 0, 63, 30))
for _, x in ipairs({ 19, 25, 31.5, 38, 44 }) do    -- scalloped lower edge
  cap:add(c:ellipse(x, 30, 3, 3):clip(body:grow(1)))
end

c:build{
  { "stem", c:rrect(30, 13, 33, 21, 1), "#2f5a2a", { flat = true } },
  { "body", body, "wood", { gloss = { 22, 36 } } },
  { "cap",  cap,  "red" },
}

-- mace lace: netted diagonals on the cap
local lace = GV.R.red.shade
c:fill(c:line({ {22, 24}, {27, 31} }, 1):clip(cap), lace)
c:fill(c:line({ {30, 21}, {35, 29} }, 1):clip(cap), lace)
c:fill(c:line({ {38, 22}, {42, 28} }, 1):clip(cap), lace)
c:fill(c:line({ {27, 22}, {23, 28} }, 1):clip(cap), lace)
c:fill(c:line({ {37, 22}, {33, 28} }, 1):clip(cap), lace)

-- crosshatch grain on the lower body
local g = "#8a4f2a"
for _, p in ipairs({ {24, 40}, {34, 39}, {29, 45}, {39, 46}, {22, 48}, {33, 50} }) do
  c:paint({ "g..", ".g.", "..g" }, p[1], p[2], { g = g })
end
for _, p in ipairs({ {29, 38}, {40, 41}, {25, 44}, {35, 45}, {28, 50} }) do
  c:paint({ "..g", ".g.", "g.." }, p[1], p[2], { g = g })
end

local t = c:save(O .. "aseprite/ph/nutmeg.aseprite", O .. "png/ph/nutmeg.png")
print(GV.report(t))
