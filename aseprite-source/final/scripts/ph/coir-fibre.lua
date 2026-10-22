local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = GV.ramp("#b07a45")
local face = GV.ramp("#d9a660")
local twine = GV.ramp("#e8c27a")

-- frayed tuft behind the end face (thick roots, thin tips)
local fray = c:line({ {48, 28}, {52, 24}, {54, 22} }, 2)
fray:add(c:line({ {50, 33}, {55, 31} }, 2))
fray:add(c:line({ {50, 38}, {54, 40}, {55, 42} }, 2))
fray:add(c:line({ {48, 43}, {51, 46}, {53, 48} }, 2))
local bundle = c:rrect(10, 22, 46, 46, 10)
local endf = c:ellipse(45, 34, 5, 11)
local p = c:build{
  { "fray", fray, "wood", { flat = true } },
  { "bundle", bundle, body },
  { "end", endf, face, { gloss = false } },
}
-- fibre streaks along the length (broken, felt-like)
for _, y in ipairs({ 28, 34, 40 }) do
  for x = 13, 40 do
    if (x + y) % 7 ~= 0 and bundle:shrink(2):has(x, y) then
      c:px(x, y, (x % 9 == 0) and body.rim or "#8a4f2a")
    end
  end
end
-- twine wraps: 2px bands with a darker back edge
for _, x in ipairs({ 18, 27, 36 }) do
  local band = c:rect(x, 21, x + 2, 47):clip(bundle)
  c:part(band, twine, { gloss = false, cres = 1, deep = 0 })
end
-- swirl ring on the end face
local ring = c:ellipse(45, 34, 3, 8):edge()
c:fill(ring, "#a8582f")
c:fill(c:ellipse(45, 34, 1, 3), "#a8582f")
c:px(45, 34, "#8a4f2a")

local t = c:save(O .. "aseprite/ph/coir-fibre.aseprite", O .. "png/ph/coir-fibre.png")
print(GV.report(t))
