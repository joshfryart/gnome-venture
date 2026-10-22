local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(B .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

-- pointed leaf from base a to tip b, max width w (lens with a slight belly near the base)
local function leaf(ax, ay, bx, by, w)
  local dx, dy = bx - ax, by - ay
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L, dx / L
  local top, bot = {}, {}
  local N = 10
  for i = 0, N do
    local t = i / N
    local hw = (w / 2) * math.sin(math.pi * t ^ 0.8)
    local px, py = ax + dx * t, ay + dy * t
    top[#top + 1] = { px + nx * hw, py + ny * hw }
    table.insert(bot, 1, { px - nx * hw, py - ny * hw })
  end
  for _, p in ipairs(bot) do top[#top + 1] = p end
  return c:poly(top)
end

local dish = c:ellipse(31.5, 50, 20, 7)
local soil = c:ellipse(31.5, 47.5, 15, 3.5)
local stem = c:rect(31, 28, 33, 47)
local lleaf = leaf(32, 38, 13, 28, 10)
local rleaf = leaf(32, 33, 51, 18, 11)
local bud = c:ellipse(32, 23.5, 4.5, 4.5)

local p = c:build{
  { "dish", dish, GV.ramp("#8c4a1a") },
  { "soil", soil, GV.ramp("#a5663a"), { gloss = false } },
  { "stem", stem, GV.ramp("#2f5a2a"), { flat = true } },
  { "lleaf", lleaf, GV.ramp("#58a03e") },
  { "rleaf", rleaf, GV.ramp("#7ab55c") },
  { "bud", bud, "gold", { gloss = { 30, 21 }, cres = 2, deep = 1 } },
}

-- leaf midribs
c:fill(c:line({ { 30, 37 }, { 18, 30 } }, 1), "#3e7a2e")
c:fill(c:line({ { 34, 32 }, { 47, 22 } }, 1), "#4a8a3e")
-- dish rim seam
c:seam({ { 15, 51 }, { 21, 54 }, { 31, 56 }, { 42, 54 }, { 48, 51 } })

local t = c:save(B .. "img-redraw-full/aseprite/ph/nav-start.aseprite", B .. "img-redraw-full/png/ph/nav-start.png")
print(GV.report(t))
