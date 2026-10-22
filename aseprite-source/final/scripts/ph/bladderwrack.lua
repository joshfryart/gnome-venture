local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- moss family nudged olive
local olive  = GV.ramp("#7a8a34")
local olive2 = GV.ramp("#8c9a3c")
local stalkR = GV.ramp("#5e6e2c")

-- forked, wavy ribbon blades splaying into a Y
local left = c:line({ {31, 40}, {26, 35}, {21, 31}, {17, 26}, {14, 21} }, 6)
left:add(c:line({ {15, 22}, {10, 17}, {9, 13} }, 5))      -- outer fork tip
left:add(c:line({ {16, 23}, {18, 17}, {19, 13} }, 5))     -- inner fork tip
local right = c:line({ {33, 40}, {38, 35}, {43, 31}, {47, 26}, {50, 21} }, 6)
right:add(c:line({ {49, 22}, {54, 17}, {55, 13} }, 5))
right:add(c:line({ {48, 23}, {46, 17}, {45, 13} }, 5))
local mid = c:line({ {32, 38}, {32, 30}, {31, 24}, {32, 18}, {32, 12} }, 5)
mid:add(c:ellipse(32, 12, 2.5, 2.5))
local stalk = c:rrect(30, 36, 34, 51, 1)
local hold  = c:ellipse(32, 52, 6, 2.5)

c:build{
  { "hold",  hold,  "wood" },
  { "stalk", stalk, stalkR },
  { "mid",   mid,   olive2 },
  { "left",  left,  olive },
  { "right", right, olive },
}

-- paired round air bladders along each blade
local bl = GV.ramp("#d2b84a")
local beads = {
  {23, 31}, {17, 25},     -- left blade
  {41, 31}, {47, 25},     -- right blade
  {29, 22}, {35, 22},     -- centre pair
}
for _, b in ipairs(beads) do
  c:part(c:ellipse(b[1], b[2], 3, 3), bl, { gloss = { b[1] - 1, b[2] - 1 }, cres = 1, deep = 0 })
end

c:ground(32, 54, 12, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/bladderwrack.aseprite", D .. "img-redraw-full/png/ph/bladderwrack.png")
print(GV.report(t))
