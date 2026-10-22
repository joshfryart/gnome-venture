local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local tan  = GV.ramp("#c4925f", { rim = "#f0d49a" })
local leaf = GV.ramp("#c9481e")

local blade = c:poly({
  { 32, 7 }, { 37, 17 }, { 46, 11 }, { 43, 25 }, { 56, 22 }, { 48, 34 },
  { 53, 40 }, { 36, 41 }, { 34, 46 }, { 30, 46 }, { 28, 41 }, { 11, 40 },
  { 16, 34 }, { 8, 22 }, { 21, 25 }, { 18, 11 }, { 27, 17 },
})

local p = c:build{
  { "stem",  c:line({ { 32, 41 }, { 32, 56 } }, 3), tan, { flat = true } },
  { "blade", blade, leaf, { gloss = { 22, 21 } } },
}

local vein = "#ae2a2a"
c:fill(c:line({ { 32, 16 }, { 32, 42 } }, 3):clip(blade), vein)
c:fill(c:line({ { 31, 31 }, { 21, 25 } }, 3):clip(blade), vein)
c:fill(c:line({ { 33, 31 }, { 43, 25 } }, 3):clip(blade), vein)
c:fill(c:line({ { 31, 37 }, { 18, 37 } }, 3):clip(blade), vein)
c:fill(c:line({ { 33, 37 }, { 46, 37 } }, 3):clip(blade), vein)

local t = c:save(D .. "img-redraw-full/aseprite/ico/ico-autumn-leaf.aseprite",
                 D .. "img-redraw-full/png/ico/ico-autumn-leaf.png")
print(GV.report(t))
