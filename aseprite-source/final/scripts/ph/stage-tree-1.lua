-- ph/stage-tree-1 : tiny sapling on a wide soil mound
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local mound = c:ellipse(31.5, 46, 21, 7):cut(c:rect(0, 47, 63, 63)):add(c:rrect(11, 44, 52, 50, 3))
local top = c:ellipse(31.5, 43, 15, 4)
local stem = c:rect(31, 34, 33, 44)

-- leaves: teardrops in a V, left one bigger
local function leaf(bx, by, tx, ty, w)
  local m = c:mask()
  local n = 14
  for i = 0, n do
    local t = i / n
    local x = bx + (tx - bx) * t
    local y = by + (ty - by) * t
    local r = w / 2 * math.sin(math.pi * math.min(1, t * 1.25)) + 0.3
    m:add(c:ellipse(x, y, r, r))
  end
  return m
end
local lleaf = leaf(31, 35, 18, 26, 8)
local rleaf = leaf(33, 34, 45, 23, 7)

c:build{
  { "mound", mound, "#8c4a1a" },
  { "top", top, "#a5663a", { contact = false } },
  { "stem", stem, "#c4925f", { gloss = false } },
  { "lleaf", lleaf, "#58a03e" },
  { "rleaf", rleaf, "#7ab55c" },
}
-- leaf veins
c:line({ {29, 33}, {22, 29} }, 1)
for _, p in ipairs({ {29,33},{28,32},{27,32},{26,31},{25,30},{24,30},{23,29} }) do c:px(p[1], p[2], GV.ramp("#58a03e").shade) end
for _, p in ipairs({ {35,32},{36,31},{37,30},{38,29},{39,28},{40,27},{41,27} }) do c:px(p[1], p[2], GV.ramp("#7ab55c").shade) end
-- soil crumbs
c:paint({ "u.", ".u" }, 19, 47, { u = "#5e2f1e" })
c:paint({ ".u", "u." }, 43, 46, { u = "#5e2f1e" })
c:paint({ "uu" }, 36, 48, { u = "#5e2f1e" })

local t = c:save(O .. "aseprite/ph/stage-tree-1.aseprite", O .. "png/ph/stage-tree-1.png")
print(GV.report(t))
