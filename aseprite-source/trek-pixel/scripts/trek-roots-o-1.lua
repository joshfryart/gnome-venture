-- trek-roots-o-1: grey-green ground, one thick diagonal root with a knot and two V tufts (family 1)
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local NAME = "trek-roots-o-1"
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
local P = {
  or_hi = "#b9c58a", or_base = "#7d8a62", or_shade = "#5f6c4a", or_deep = "#3a4530",
  so_rim = "#c9a96e", so_base = "#9a6b3f", so_shade = "#7a4a1f",
  mo_rim = "#a4b86a", mo_shade = "#4a8a3e", moss600 = "#4f9a45",
}
local function px(x, y, k) c:px(x, y, P[k] or k) end
local function rect(x0, y0, x1, y1, k) for y = y0, y1 do for x = x0, x1 do px(x, y, k) end end end

rect(0, 0, 41, 41, "or_base")

-- main root (5,28) -> (36,16), 3 px thick: rim top, base middle, shade bottom, or_deep contact under
local function yc(x) return 28 - math.floor((x - 5) * 12 / 31 + 0.5) end
for x = 5, 36 do
  local y = yc(x)
  local taper = (x <= 6 or x >= 35)
  px(x, y + 2, "or_deep")
  px(x, y + 1, "so_shade")
  px(x, y, "so_base")
  if not taper then px(x, y - 1, "so_rim") end
end
-- knot 5x5 at (19..23,19..23): so_shade ring, so_base core, rounded corners, lit pixel on its top-left
for y = 19, 23 do for x = 19, 23 do
  local corner = (x == 19 or x == 23) and (y == 19 or y == 23)
  if not corner then
    local ring = (x == 19 or x == 23 or y == 19 or y == 23)
    px(x, y, ring and "so_shade" or "so_base")
  end
end end
px(20, 20, "so_rim")
px(20, 24, "or_deep"); px(21, 24, "or_deep"); px(22, 24, "or_deep") -- knot sits on the ground

-- V tuft: moss600 blades, mo_rim tips, mo_shade base pixel
local function tuft(base, left, right)
  for _, p in ipairs(left) do px(p[1], p[2], "moss600") end
  for _, p in ipairs(right) do px(p[1], p[2], "moss600") end
  px(left[#left][1], left[#left][2], "mo_rim")
  px(right[#right][1], right[#right][2], "mo_rim")
  px(base[1], base[2], "mo_shade")
end
tuft({12,30}, { {11,29}, {10,28}, {10,27}, {9,26} }, { {13,29}, {14,28}, {14,27}, {15,26}, {15,25} })
tuft({30,17}, { {29,16}, {28,15}, {28,14} }, { {31,16}, {32,15}, {32,14}, {33,13} })

-- speckles
for _, p in ipairs({ {24,10}, {8,12}, {33,33} }) do px(p[1], p[2], "or_hi") end
for _, p in ipairs({ {16,10}, {26,35}, {36,26} }) do px(p[1], p[2], "or_shade") end

local t = c:save(D .. "trek-pixel/aseprite/" .. NAME .. ".aseprite", D .. "trek-pixel/png/" .. NAME .. ".png")
print(NAME, GV.report(t))
