-- trek-floor-o-3: meadow edge, grass clump, moss blotches, leaf and stone (family 1)
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local NAME = "trek-floor-o-3"
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
local P = {
  so_gloss = "#d9ba7c", so_rim = "#c9a96e", so_base = "#9a6b3f", so_shade = "#7a4a1f", umber2 = "#4a2c1a",
  mo_rim = "#a4b86a", mo_base = "#7ab55c", mo_shade = "#4a8a3e", mo_deep = "#2f5a2a", moss600 = "#4f9a45",
}
local function px(x, y, k) c:px(x, y, P[k] or k) end
local function rect(x0, y0, x1, y1, k) for y = y0, y1 do for x = x0, x1 do px(x, y, k) end end end

rect(0, 0, 41, 41, "so_base")

-- moss blotches: top row mo_base, lower rows mo_shade, rim top-left; soft corners
local function blotch(x0, y0, w)
  local x1 = x0 + w - 1
  rect(x0, y0, x1, y0, "mo_base")
  rect(x0, y0 + 1, x1, y0 + 2, "mo_shade")
  px(x1, y0, "so_base"); px(x0, y0 + 2, "so_base")       -- clipped corners
  px(x1 - 1, y0 + 3, "so_base")
  px(x0, y0, "mo_rim")
end
blotch(8, 20, 6)
blotch(22, 32, 7)

-- leaf at (10,28)
for _, p in ipairs({ {11,28}, {12,28}, {13,28}, {10,29}, {11,29}, {12,29}, {13,29}, {10,30}, {11,30}, {12,30} }) do
  px(p[1], p[2], "mo_shade")
end
px(11, 28, "mo_rim"); px(10, 29, "mo_rim")
px(9, 30, "so_shade") -- stem

-- small stone 4x3 at (13,10)
rect(13, 10, 16, 12, "so_rim")
for y = 10, 12 do px(16, y, "umber2") end
for x = 13, 16 do px(x, 12, "umber2") end
px(16, 10, "so_base"); px(15, 10, "umber2")
px(13, 10, "so_gloss")

-- grass clump, base line y=19: blades at x=27,29,31,33,34 heights 8,6,9,5,7
local blades = { {27, 8, -1}, {29, 6, 0}, {31, 9, 0}, {33, 5, 0}, {34, 7, 1} }
local isBlade = {}
for _, b in ipairs(blades) do
  for y = 19 - b[2] + 1, 19 do isBlade[b[1] .. "," .. y] = true end
end
-- body shade column right of each tall blade (lower half), so the clump has weight at the base
for _, b in ipairs(blades) do
  if b[2] >= 5 then
    for y = 19 - math.floor(b[2] / 3), 19 do
      if not isBlade[(b[1] + 1) .. "," .. y] then px(b[1] + 1, y, "mo_shade") end
    end
  end
end
for _, b in ipairs(blades) do
  local x, h, lean = b[1], b[2], b[3]
  local top = 19 - h + 1
  for y = top, 19 do px(x, y, "moss600") end
  if lean ~= 0 then  -- outer blades lean out at the tip
    px(x, top, "so_base"); px(x + lean, top, "mo_rim")
  else
    px(x, top, "mo_rim")
  end
end
rect(29, 20, 30, 20, "mo_deep"); rect(32, 20, 33, 20, "mo_deep")

local t = c:save(D .. "trek-pixel/aseprite/" .. NAME .. ".aseprite", D .. "trek-pixel/png/" .. NAME .. ".png")
print(NAME, GV.report(t))
