local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(B .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon", bleed = "lr" }
local box = GV.ramp("#58a03e", { gloss = "#b8d47c" })
-- pickets with pointed tops
local pick = c:mask()
for i = 0, 5 do
  local x = 19 + i * 5
  pick:add(c:rect(x, 24, x + 3, 45))
  pick:add(c:poly({ {x, 24}, {x + 2, 21}, {x + 4, 24} }))
end
local hedgeL = c:ellipse(1, 34, 11, 12):add(c:ellipse(10, 37, 8, 9))
local hedgeR = c:ellipse(62, 34, 11, 12):add(c:ellipse(53, 37, 8, 9))
local p = c:build{
  { "ground", c:rect(0, 44, 63, 49), "soil" },
  { "rails", c:rect(17, 28, 47, 31):add(c:rect(17, 37, 47, 40)), "#c4925f", { gloss = false } },
  { "pickets", pick, "#dcb06a" },
  { "brace", c:line({ {20, 39}, {44, 30} }, 2), "#b07a45", { flat = true } },
  { "hedgeL", hedgeL, box },
  { "hedgeR", hedgeR, box },
}
c:seam({ {18, 29}, {46, 29} })
local t = c:save(B .. "img-redraw-full/aseprite/ph/box-hedge-gate.aseprite", B .. "img-redraw-full/png/ph/box-hedge-gate.png")
print(GV.report(t))
