-- bat-down: a soft brown tuft of Echo Bat down, fanned up from a little pinched quill
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- puff: a scalloped cloud of down, upper right, tapering down-left into a short quill
local puff = c:ellipse(37, 29, 12, 10)
for _, b in ipairs({ {25, 26, 5}, {28, 18, 5.5}, {37, 15, 6}, {46, 18, 5.5}, {51, 27, 5}, {47, 36, 5}, {38, 39, 4.5} }) do
  puff:add(c:ellipse(b[1], b[2], b[3], b[3]))
end
puff:add(c:poly({ {23, 29}, {35, 38}, {22, 47}, {19, 45} }))
-- two loose wisps lifting off the top
local wisp1 = c:line({ {30, 12}, {27, 8}, {23, 8} }, 2)
local wisp2 = c:line({ {54, 22}, {57, 19}, {57, 15} }, 2)
local quill = c:line({ {14, 54}, {22, 44} }, 3)

local brown = GV.ramp("#6e5646")
local p = c:build{
  { "w1", wisp1, brown, { flat = true } },
  { "w2", wisp2, brown, { flat = true } },
  { "puff", puff, brown, { gloss = { 28, 18 } } },
  { "quill", quill, GV.ramp("#4b3a2f"), { flat = true } },
}

-- soft barb curls inside the puff (2 px, shade), opening away from the quill
local curl = brown.deep
local inner = p.puff.m:shrink(2)
local function arc(pts) c:fill(c:line(pts, 2):clip(inner), curl) end
arc({ {33, 22}, {36, 25}, {39, 25}, {42, 22} })
arc({ {28, 30}, {31, 33}, {34, 33} })
arc({ {40, 31}, {43, 34}, {47, 33} })
-- a mauve echo of the bat's inner ear where the down meets the quill
c:paint({ ".mm", "mm.", "m.." }, 22, 41, { m = "#8a6a7a" })

local t = c:save(D .. "final/aseprite/ph/bat-down.aseprite", PNG .. "bat-down.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
