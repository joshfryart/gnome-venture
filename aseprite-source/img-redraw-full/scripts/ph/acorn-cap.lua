local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(25, 36, 18, 13):add(c:rrect(25, 23, 49, 49, 4))
c:build{
  { "nub", c:rrect(6, 33, 10, 38, 1), "wood", { flat = true } },
  { "cup", body, GV.ramp("#8c4a1a"), { gloss = { 14, 28 } } },
  { "open", c:ellipse(48, 36, 7, 13), GV.ramp("#dcb06a"), { gloss = { 45, 27 } } },
  { "inner", c:ellipse(48.5, 37, 3.5, 7.5), GV.ramp("#a5663a"), { gloss = false, rim = false } },
}
c:fill(c:ellipse(49, 38.5, 1.5, 4), "#5e2f1e")
-- overlapping scale scallops, staggered rows
local rows = { 27, 32, 37, 42 }
for i, y in ipairs(rows) do
  local x0 = (i % 2 == 0) and 15 or 12
  for x = x0, 34, 7 do
    if body:has(x, y) and body:has(x + 5, y + 2) then
      c:paint({ "d.....d", ".d...d.", "..ddd.." }, x, y, { d = "#5e2f1e" })
    end
  end
end
c:seam({ {39, 25}, {39, 47} })
c:ground(30, 54, 21, 3, "#6a4528")
local t = c:save(O .. "aseprite/ph/acorn-cap.aseprite", O .. "png/ph/acorn-cap.png")
print(GV.report(t))
