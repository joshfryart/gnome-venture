local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local caseM = c:ellipse(31.5, 44, 26, 10):add(c:rect(6, 36, 57, 44))
local rim = c:ellipse(31.5, 36, 26, 10)
local custard = c:ellipse(31.5, 36, 20, 6.5)
local p = c:build{
  { "case", caseM, GV.ramp("#a5663a") },
  { "rim", rim, GV.ramp("#dcb06a"), { gloss = false } },
  { "custard", custard, GV.ramp("#f8ecc8"), { gloss = { 17, 33 }, cres = 2, deep = 1 } },
}
-- caramel cross
local X = c:line({ {24, 33}, {39, 39} }, 2):add(c:line({ {39, 33}, {24, 39} }, 2))
c:fill(X, "#b07a45")
c:fill(c:rect(31, 35, 32, 36), "#8a4f2a")
-- crimp notches around the rim
for i = 0, 15 do
  local a = i / 16 * 2 * math.pi
  local x = math.floor(31.5 + math.cos(a) * 23 + 0.5)
  local y = math.floor(36 + math.sin(a) * 8.4 + 0.5)
  if not custard:grow(1):has(x, y) then c:px(x, y, "#8a4f2a") end
end
-- pastry side flutes
for x = 10, 54, 5 do
  c:px(x, 47, "#8a4f2a"); c:px(x, 48, "#8a4f2a")
end
local t = c:save(O .. "aseprite/ph/custard-tart.aseprite", O .. "png/ph/custard-tart.png")
print(GV.report(t))
