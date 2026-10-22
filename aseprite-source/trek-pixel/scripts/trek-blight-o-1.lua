-- trek-blight-o-1: dusk-purple blighted ground, two spore dots and thin cracks (family 1)
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local NAME = "trek-blight-o-1"
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
local P = {
  du_gloss = "#a894dc", du_rim = "#7b66b4", du_base = "#4e3a8a", du_shade = "#3e2f66", du_deep = "#291d4a",
  dusk500 = "#7a5cc0",
}
local function px(x, y, k) c:px(x, y, P[k] or k) end
local function rect(x0, y0, x1, y1, k) for y = y0, y1 do for x = x0, x1 do px(x, y, k) end end end

rect(0, 0, 41, 41, "du_base")

-- cracks (du_deep)
for _, p in ipairs({ {20,8}, {20,9}, {20,10}, {20,11}, {21,12}, {22,13}, {23,14}, {24,15}, {24,16}, {24,17}, {24,18},
                     {6,30}, {7,30}, {8,30}, {9,30}, {10,31}, {11,32}, {12,33} }) do
  px(p[1], p[2], "du_deep")
end

-- spore dot 5x5 cut corners: dusk500, rim on the upper-left edge, gloss, du_shade lower-right row/column
local function spore(x0, y0)
  local rows = { ".###.", "#####", "#####", "#####", ".###." }
  for j, r in ipairs(rows) do for i = 1, 5 do
    if r:sub(i, i) == "#" then px(x0 + i - 1, y0 + j - 1, "dusk500") end
  end end
  for y = y0 + 1, y0 + 3 do px(x0 + 4, y, "du_shade") end
  for x = x0 + 1, x0 + 3 do px(x, y0 + 4, "du_shade") end
  px(x0 + 3, y0 + 3, "du_shade")
  px(x0 + 1, y0, "du_rim"); px(x0, y0 + 1, "du_rim")
  px(x0 + 1, y0 + 1, "du_gloss")
end
spore(11, 13)
spore(26, 25)

-- specks
for _, p in ipairs({ {32,12}, {8,22}, {22,34} }) do px(p[1], p[2], "dusk500") end
for _, p in ipairs({ {17,24}, {35,19} }) do px(p[1], p[2], "du_shade") end

local t = c:save(D .. "trek-pixel/aseprite/" .. NAME .. ".aseprite", D .. "trek-pixel/png/" .. NAME .. ".png")
print(NAME, GV.report(t))
