-- trek-floor-o-1: sunlit packed-earth trail, colour master for the open set (family 1)
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local NAME = "trek-floor-o-1"
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
local P = {
  so_gloss = "#d9ba7c", so_rim = "#c9a96e", so_base = "#9a6b3f", so_bounce = "#8b5a31", so_shade = "#7a4a1f",
  umber2 = "#4a2c1a", mo_rim = "#a4b86a", mo_base = "#7ab55c", mo_shade = "#4a8a3e",
}
local function px(x, y, k) c:px(x, y, P[k] or k) end
local function rect(x0, y0, x1, y1, k) for y = y0, y1 do for x = x0, x1 do px(x, y, k) end end end

rect(0, 0, 41, 41, "so_base")

-- pebble: body so_rim, gloss upper-left, lower-right L in umber2; cut = drop top-right and bottom-left corners
local function pebble(x0, y0, w, h, cut)
  local x1, y1 = x0 + w - 1, y0 + h - 1
  rect(x0, y0, x1, y1, "so_rim")
  for y = y0, y1 do px(x1, y, "umber2") end
  for x = x0, x1 do px(x, y1, "umber2") end
  if cut then
    px(x1, y0, "so_base"); px(x1 - 1, y0, "umber2")   -- rounded top-right, outline steps in
    px(x0, y1, "so_base"); px(x0, y1 - 1, "umber2")   -- rounded bottom-left
  end
  px(x0, y0, "so_gloss")
end
pebble(9, 9, 5, 4, true)    -- A
pebble(15, 12, 4, 3, true)  -- B
pebble(11, 15, 3, 3, false) -- C

-- scuff trail: so_bounce dashes, so_shade under the 2nd and 4th
local dashes = { {20, 22, 30}, {25, 27, 30}, {30, 32, 29}, {34, 36, 27} }
for i, d in ipairs(dashes) do
  for x = d[1], d[2] do
    px(x, d[3], "so_bounce")
    if i == 2 or i == 4 then px(x, d[3] + 1, "so_shade") end
  end
end

-- moss tuft, base (30,15)
for _, p in ipairs({ {29,14}, {28,13}, {31,14}, {32,13}, {32,12} }) do px(p[1], p[2], "mo_base") end
px(28, 12, "mo_rim"); px(32, 11, "mo_rim")
px(30, 15, "mo_shade"); px(30, 16, "mo_shade")

-- dust specks
for _, p in ipairs({ {24,9}, {33,21}, {14,25}, {8,33}, {27,35}, {36,12} }) do px(p[1], p[2], "so_gloss") end

local t = c:save(D .. "trek-pixel/aseprite/" .. NAME .. ".aseprite", D .. "trek-pixel/png/" .. NAME .. ".png")
print(NAME, GV.report(t))
