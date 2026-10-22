-- ph/tile-tilled-wet : top-down freshly tilled, freshly watered soil tile (full bleed, no halo)
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local N = "ph/tile-tilled-wet"
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }

c:fill(c:rect(0, 0, 63, 63), "#44281c")
for _, y in ipairs({ 6, 21, 36, 51 }) do
  c:fill(c:rect(0, y, 63, y + 6), "#3d2a1c")                -- furrow trough
  c:fill(c:rect(0, y + 7, 63, y + 9), "#7a4a1f")            -- ridge
  c:fill(c:rect(0, y + 7, 63, y + 7), "#9a6b3f")            -- lit ridge top
  c:fill(c:rect(0, y + 10, 63, y + 10), "#2a1a10")          -- ridge shadow
end
-- clods: little lumps on the ridges and dark notches, varied but tile-safe
local clod = { {5,0},{17,0},{29,1},{40,0},{52,1},{60,0} }
for r, y in ipairs({ 13, 28, 43, 58 }) do
  for i, p in ipairs(clod) do
    local x = (p[1] + r * 7) % 64
    c:px(x, y - 1, "#7a4a1f"); c:px(x + 1, y - 1, "#9a6b3f")
    if i % 2 == 0 then c:px((x + 4) % 64, y + 2, "#5e3418") end
  end
end
-- pebbles (3x3 cut-corner, 1 px dark outline)
for _, p in ipairs({ {47,41},{58,4},{33,6},{46,48},{41,53},{30,30} }) do
  c:paint({ ".ooo.", "oglbo", "olbso", "obsso", ".ooo." }, p[1] - 2, p[2] - 2,
    { o = "#2a1a10", g = "#f1ece0", l = "#c9a96e", b = "#c9a96e", s = "#9a6b3f" })
end
-- water beads: 4x6 ovals with lower-right shade and a gloss pixel
for _, p in ipairs({ {41,32},{47,16},{39,45},{12,20},{39,55} }) do
  c:paint({
    "..oo..",
    ".obbo.",
    "ogbbbo",
    "obbbso",
    "obbsso",
    "obssso",
    ".osso.",
    "..oo..",
  }, p[1] - 3, p[2] - 4, { o = "#2a1a10", b = "#8fcbd8", s = "#3f8fb0", g = "#c8ecdc" })
end
-- tiny damp sparkle dots
for _, p in ipairs({ {20,9},{55,24},{9,40},{27,57},{60,33} }) do c:px(p[1], p[2], "#5a86b8") end

local t = c:save(O .. "aseprite/" .. N .. ".aseprite", O .. "png/" .. N .. ".png")
print(GV.report(t))
