local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- pale yellow-green berry; crescent pushed into moss greens for the darker underside
local berryR = GV.ramp("#b0bc66", { shade = "#7ab55c", deep = "#4a8a3e", bounce = "#6a9a3a" })
local berry = c:ellipse(31.5, 37, 15.5, 15)

local stem = c:line({ {31, 24}, {31, 14} }, 3)
local leaf = c:poly({ {32, 18}, {35, 13}, {40, 9}, {47, 7}, {46, 12}, {42, 17}, {37, 19} })

c:build{
  { "stem",  stem,  GV.ramp("#2f5a2a", { base = "#2f5a2a", rim = "#4a8a3e" }), { flat = true } },
  { "berry", berry, berryR, { cres = 6, deep = 2, gloss = { 24, 28 } } },
  { "leaf",  leaf,  GV.ramp("#58a03e"), { cres = 2, deep = 1, gloss = false } },
}
-- leaf midrib
c:line({ {35, 16}, {44, 10} }, 1):each(function(x, y) c:px(x, y, "#4a8a3e") end)
-- calyx dimple where the stem meets the berry
c:paint({ "d.d", ".d." }, 30, 23, { d = "#6a9a3a" })

c:ground(31.5, 53, 12, 1.5)
local t = c:save(O .. "aseprite/ph/sea-buckthorn.aseprite", O .. "png/ph/sea-buckthorn.png")
print(GV.report(t))
