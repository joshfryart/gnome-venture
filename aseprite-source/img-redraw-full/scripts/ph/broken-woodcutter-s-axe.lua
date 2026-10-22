local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local handleR = GV.ramp("#b6814d", { rim = "#f0d49a" })
local bladeR  = GV.ramp("#8c4a1a")

-- handle: diagonal shaft, snapped with a zigzag break
local upper = c:line({ {37, 13}, {29, 34} }, 6)
upper:cut(c:poly({ {20, 33}, {25, 31}, {28, 34}, {32, 31}, {36, 35}, {36, 42}, {20, 42} }))
local lower = c:line({ {29, 34}, {22, 52} }, 6)
lower:cut(c:poly({ {18, 26}, {38, 26}, {38, 35}, {32, 33}, {28, 37}, {25, 34}, {18, 37} }))
lower = lower:shift(-2, 1)

-- blade: fan swelling to the right at the top
local blade = c:poly({ {32, 12}, {39, 9}, {46, 8}, {50, 11}, {54, 18}, {53, 25}, {50, 31}, {44, 28}, {37, 22}, {33, 18} })
blade:add(c:ellipse(48, 19, 6, 11))

-- loose chips
local chip1 = c:poly({ {39, 46}, {43, 47}, {46, 51}, {41, 51} })
local chip2 = c:poly({ {11, 40}, {16, 38}, {17, 41}, {12, 43} })

c:build{
  { "lower",  lower,  handleR },
  { "chip1",  chip1,  handleR, { flat = true } },
  { "chip2",  chip2,  handleR, { flat = true } },
  { "upper",  upper,  handleR },
  { "blade",  blade,  bladeR,  { gloss = { 39, 13 } } },
}

-- engraved grooves on the blade
local g = "#2a1a10"
for _, s in ipairs({ { {41,14},{44,17} }, { {46,18},{49,21} }, { {42,23},{45,26} } }) do
  c:fill(c:line(s, 1), g)
end
-- crack running up the upper handle
c:fill(c:line({ {33, 22}, {31, 26}, {32, 28}, {30, 31} }, 1), g)

local t = c:save(D .. "img-redraw-full/aseprite/ph/broken-woodcutter-s-axe.aseprite",
                 D .. "img-redraw-full/png/ph/broken-woodcutter-s-axe.png")
print(GV.report(t))
