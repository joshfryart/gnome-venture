local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local wood = GV.ramp("#a5663a", { gloss = "#ecc58a", shade = "#8a4f2a" })
local stake = GV.ramp("#8a4f2a")
local band = c:rect(12, 22, 51, 32):add(c:rect(27, 28, 36, 52))
c:build{
  { "stakeL", c:rrect(11, 18, 13, 34, 1), stake, { flat = true } },
  { "stakeR", c:rrect(50, 18, 52, 34, 1), stake, { flat = true } },
  { "band", band, wood, { gloss = false } },
}
-- weave on horizontal band
for x = 12, 48, 6 do
  if x < 26 or x > 34 then
    c:fill(c:line({ {x, 23}, {x + 3, 31} }, 1):clip(band), "#4a2c1a")
    c:fill(c:line({ {x + 1, 23}, {x + 4, 31} }, 1):clip(band), "#4a2c1a")
    c:fill(c:line({ {x + 3, 23}, {x + 6, 31} }, 1):clip(band), "#d9a660")
  end
end
-- weave on branch (runs toward the viewer)
for y = 37, 49, 6 do
  c:fill(c:line({ {28, y}, {35, y + 3} }, 1), "#4a2c1a")
  c:fill(c:line({ {28, y + 1}, {35, y + 4} }, 1), "#4a2c1a")
  c:fill(c:line({ {28, y + 3}, {35, y + 6} }, 1):clip(band), "#d9a660")
end
c:part(c:ellipse(31.5, 27.5, 5.5, 5.5), GV.ramp("#5e2f1e"), { gloss = { 29, 25 } })
c:ground(31.5, 53, 12, 1.5)
local t = c:save(O .. "aseprite/ph/wattle-fence-tee.aseprite", O .. "png/ph/wattle-fence-tee.png")
print(GV.report(t))
