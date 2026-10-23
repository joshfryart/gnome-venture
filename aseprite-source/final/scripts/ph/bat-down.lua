-- bat-down: a soft brown tuft of Echo Bat down, fanned up from a little pinched quill
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- puff: a scalloped cloud of down, upper right, tapering down-left into a short quill
local puff = c:ellipse(37, 29, 9, 8)
for _, b in ipairs({ {26, 27, 5.5}, {28, 18, 5.5}, {38, 15, 6.5}, {48, 20, 5.5}, {49, 31, 5.5}, {42, 39, 5}, {32, 38, 4.5} }) do
  puff:add(c:ellipse(b[1], b[2], b[3], b[3]))
end
puff:add(c:poly({ {23, 29}, {35, 38}, {22, 47}, {19, 45} }))
-- two loose wisps lifting off the top
local wisp1 = c:line({ {27, 14}, {23, 11}, {19, 12}, {18, 15} }, 3)
local wisp2 = c:line({ {51, 16}, {53, 12}, {56, 11} }, 3)
local quill = c:line({ {14, 54}, {22, 44} }, 3)

local brown = GV.ramp("#8a6a5a")
local p = c:build{
  { "w1", wisp1, brown, { flat = true } },
  { "w2", wisp2, brown, { flat = true } },
  { "puff", puff, brown, { gloss = { 28, 18 } } },
  { "quill", quill, GV.ramp("#4b3a2f"), { flat = true } },
}

-- soft barb curls inside the puff (2 px, shade), opening away from the quill
local curl = brown.shade
local inner = p.puff.m:shrink(2)
local function arc(pts) c:fill(c:line(pts, 2):clip(inner), curl) end
arc({ {34, 21}, {37, 24}, {40, 24}, {43, 21} })
arc({ {27, 29}, {30, 32}, {33, 32} })
arc({ {39, 32}, {42, 35}, {46, 34} })
-- a mauve echo of the bat's inner ear where the down meets the quill
c:paint({ ".mm", "mm.", "m.." }, 22, 41, { m = "#8a6a7a" })

local t = c:save(D .. "final/aseprite/ph/bat-down.aseprite", PNG .. "bat-down.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
