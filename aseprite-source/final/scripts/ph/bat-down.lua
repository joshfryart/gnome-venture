-- bat-down: a soft brown tuft of Echo Bat down, fanned up from a little pinched quill
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- outer fluff: a fan of soft lobes leaning right, narrowing to a pinch
local fluff = c:ellipse(31, 31, 12, 11)
for _, b in ipairs({ {18, 28, 6.5}, {22, 18, 6.5}, {32, 14, 7}, {43, 18, 6.5}, {47, 29, 5.5} }) do
  fluff:add(c:ellipse(b[1], b[2], b[3], b[3]))
end
fluff:add(c:poly({ {21, 36}, {42, 36}, {34, 51}, {29, 51} }))
-- wisp tips curling off the top lobes
fluff:add(c:line({ {13, 23}, {11, 19}, {12, 16} }, 2))
fluff:add(c:line({ {37, 8}, {40, 6}, {43, 7} }, 2))
fluff:add(c:line({ {51, 24}, {54, 21}, {54, 18} }, 2))

-- downy core in the bat's mauve inner-ear tone
local core = c:ellipse(31, 32, 7, 6)
for _, b in ipairs({ {26, 27, 4}, {32, 23, 4.5}, {37, 28, 4} }) do
  core:add(c:ellipse(b[1], b[2], b[3], b[3]))
end
core:add(c:poly({ {26, 36}, {37, 36}, {32, 45} }))

local quill = c:line({ {31, 50}, {33, 56} }, 3)

local brown = GV.ramp("#6e5646")
local mauve = GV.ramp("#8a6a7a")
local p = c:build{
  { "quill", quill, GV.ramp("#4b3a2f"), { flat = true } },
  { "fluff", fluff, brown, { gloss = { 18, 16 } } },
  { "core",  core,  mauve, { gloss = { 28, 21 } } },
}

-- soft barb strands fanning out of the core into the fluff (2 px, deep brown)
local strand = brown.deep
local function wisp(pts) c:fill(c:line(pts, 2):clip(p.fluff.m:shrink(2):cut(p.core.m)), strand) end
wisp({ {24, 36}, {19, 33}, {16, 29} })
wisp({ {40, 35}, {45, 32}, {47, 27} })
wisp({ {38, 21}, {41, 17}, {41, 13} })

local t = c:save(D .. "final/aseprite/ph/bat-down.aseprite", PNG .. "bat-down.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
