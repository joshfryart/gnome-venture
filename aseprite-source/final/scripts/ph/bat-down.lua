-- bat-down: a soft brown tuft of Echo Bat down, fanned up from a little pinched quill
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- a lock of soft down: discs strung along a curve, fat at the root, thinning to a curled tip
local function lock(pts, r0, r1)
  local m = c:mask()
  local n = #pts
  for i = 1, n - 1 do
    local a, b = pts[i], pts[i + 1]
    for k = 0, 3 do
      local u = ((i - 1) + k / 4) / (n - 1)
      local r = r0 + (r1 - r0) * u
      m:add(c:ellipse(a[1] + (b[1] - a[1]) * k / 4, a[2] + (b[2] - a[2]) * k / 4, r, r))
    end
  end
  return m
end

-- main lock sweeps up from the root and curls over to the right
local MAIN = { {22, 46}, {19, 37}, {22, 27}, {30, 19}, {40, 15}, {48, 17}, {51, 22} }
-- a smaller lock forks off the middle and curls the same way
local FORK = { {26, 40}, {33, 33}, {41, 31}, {47, 34}, {48, 39} }
local main = lock(MAIN, 8.5, 2.5)
local fork = lock(FORK, 5, 2)
-- fluffy root: three soft bumps where the down was plucked
local root = c:ellipse(18, 48, 4, 4):add(c:ellipse(24, 50, 4.5, 4)):add(c:ellipse(29, 47, 3.5, 3.5))

local brown = GV.ramp("#6e5646")
local whole = main:copy():add(fork):add(root)
local p = c:build{
  { "fork", fork, brown, { light = whole, gloss = false } },
  { "root", root, brown, { light = whole, gloss = false } },
  { "main", main, brown, { light = whole, gloss = { 20, 33 } } },
}

-- strands following the curl (2 px, shade) so it reads as soft fur, not a solid lump
local strand = brown.shade
local function hair(pts, m) c:fill(c:line(pts, 2):clip(m:shrink(2)), strand) end
hair({ {25, 42}, {24, 34}, {28, 27}, {35, 22}, {42, 20} }, p.main.m)
hair({ {20, 44}, {22, 47} }, p.main.m)
hair({ {31, 37}, {37, 35}, {42, 35} }, p.fork.m)

local t = c:save(D .. "final/aseprite/ph/bat-down.aseprite", PNG .. "bat-down.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
