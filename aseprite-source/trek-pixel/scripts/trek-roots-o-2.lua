-- trek-roots-o-2: grey-green ground, thin Y root network, big tuft, two caught stones (family 1)
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local NAME = "trek-roots-o-2"
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
local P = {
  or_hi = "#b9c58a", or_base = "#7d8a62", or_shade = "#5f6c4a", or_deep = "#3a4530",
  so_base = "#9a6b3f", so_shade = "#7a4a1f", umber2 = "#4a2c1a",
  mo_rim = "#a4b86a", mo_shade = "#4a8a3e", moss600 = "#4f9a45",
  sn_gloss = "#c9c5bc", sn_rim = "#b3b2b0",
}
local function px(x, y, k) c:px(x, y, P[k] or k) end
local function rect(x0, y0, x1, y1, k) for y = y0, y1 do for x = x0, x1 do px(x, y, k) end end end

rect(0, 0, 41, 41, "or_base")

-- Y root, 2 px thick: so_shade body, lit so_base pixels on the upper edge
local root = c:mask()
root:add(c:line({ {8,35}, {12,30}, {15,27}, {17,24} }, 2))  -- trunk, slight bend
root:add(c:line({ {17,24}, {14,20}, {12,16}, {9,12} }, 2))  -- left branch
root:add(c:line({ {18,23}, {23,19}, {28,14}, {32,10} }, 2)) -- right branch
root:each(function(x, y) px(x, y, "so_shade") end)
root:each(function(x, y)
  if not root:has(x, y - 1) and not root:has(x - 1, y) then px(x, y, "so_base") end
end)
-- junction knot 4x4: so_base, so_shade lower-right
rect(16, 22, 19, 25, "so_base")
for y = 22, 25 do px(19, y, "so_shade") end
for x = 16, 19 do px(x, 25, "so_shade") end
px(19, 22, "or_base"); px(16, 25, "or_base") -- rounded

-- two stones caught in the roots
local function stone(x0, y0, w, h)
  local x1, y1 = x0 + w - 1, y0 + h - 1
  rect(x0, y0, x1, y1, "sn_rim")
  for y = y0, y1 do px(x1, y, "umber2") end
  for x = x0, x1 do px(x, y1, "umber2") end
  px(x0, y0, "sn_gloss")
end
stone(28, 26, 4, 3)
px(31, 26, "or_base"); px(30, 26, "umber2") -- rounded top-right
stone(11, 29, 3, 3)

-- big tuft at the junction, base (21,27): three blades, heights 6, 8, 5 (left, middle, right)
local blades = {
  { {20,26}, {19,25}, {19,24}, {18,23}, {18,22} },                 -- left, tip (18,22): 6 tall
  { {21,26}, {21,25}, {21,24}, {21,23}, {21,22}, {22,21}, {22,20} },-- middle, 8 tall, tip leans right
  { {22,26}, {23,25}, {24,24}, {25,23} },                           -- right, 5 tall
  { {20,25}, {20,24} }, { {22,25}, {22,24} },                       -- fill between, so the clump has body
}
-- a little width at the base so it reads bigger than the roots-o-1 tufts
px(20, 27, "mo_shade"); px(22, 27, "mo_shade")
for i, b in ipairs(blades) do
  for _, p in ipairs(b) do px(p[1], p[2], "moss600") end
  if i <= 3 then px(b[#b][1], b[#b][2], "mo_rim") end
end
px(21, 27, "mo_shade")

-- speckles
for _, p in ipairs({ {30,19}, {5,18}, {25,36} }) do px(p[1], p[2], "or_hi") end
for _, p in ipairs({ {12,17}, {34,22} }) do px(p[1], p[2], "or_deep") end

local t = c:save(D .. "trek-pixel/aseprite/" .. NAME .. ".aseprite", D .. "trek-pixel/png/" .. NAME .. ".png")
print(NAME, GV.report(t))
