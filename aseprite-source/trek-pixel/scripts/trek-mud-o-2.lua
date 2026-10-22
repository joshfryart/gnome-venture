-- trek-mud-o-2: trampled mud, dots in a triangle, boot dent and smear (family 1)
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local NAME = "trek-mud-o-2"
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
local P = {
  mud_base = "#7a4a1f", mud_shade = "#5c3520", soil900 = "#3d2a1c", so_base = "#9a6b3f", so_bounce = "#8b5a31",
}
local function px(x, y, k) c:px(x, y, P[k] or k) end
local function rect(x0, y0, x1, y1, k) for y = y0, y1 do for x = x0, x1 do px(x, y, k) end end end

rect(0, 0, 41, 41, "mud_base")

local function shape(rows, x0, y0)
  local m = {}
  for j, r in ipairs(rows) do for i = 1, #r do
    if r:sub(i, i) == "#" then m[(x0 + i - 1) .. "," .. (y0 + j - 1)] = { x0 + i - 1, y0 + j - 1 } end
  end end
  return m
end
local function lip(m, k) -- lit lip outside the lower-right edge
  for _, p in pairs(m) do
    if not m[(p[1] + 1) .. "," .. (p[2] + 1)] then px(p[1] + 1, p[2] + 1, k) end
  end
end

-- boot-print dent: oval 8x5, with a heel notch
local dent = shape({ "..####..", ".######.", "########", ".######.", "..####.." }, 11, 10)
lip(dent, "so_base")
for _, p in pairs(dent) do px(p[1], p[2], "mud_shade") end
px(12, 12, "soil900"); px(13, 12, "soil900")

-- smear: 2 px ridge (18,31) -> (26,27), steps +2,-1, so_bounce above
local sm = { {18,31}, {19,31}, {20,30}, {21,30}, {22,29}, {23,29}, {24,28}, {25,28}, {26,27} }
for _, p in ipairs(sm) do px(p[1], p[2] - 1, "so_bounce") end
for _, p in ipairs(sm) do px(p[1], p[2], "mud_shade"); px(p[1], p[2] + 1, "mud_shade") end

-- three dots in a triangle
local function dot(rows, x0, y0)
  local m = shape(rows, x0, y0)
  lip(m, "so_base")
  for _, p in pairs(m) do px(p[1], p[2], "soil900") end
  px(x0 + (rows[1]:find("#") == 1 and 0 or 1), y0 + (rows[1]:find("#") == 1 and 0 or 1), "mud_shade")
end
dot({ ".###.", "#####", "#####", "#####", ".###." }, 27, 11)
dot({ ".##.", "####", "####", ".##." }, 11, 25)
dot({ ".#.", "###", ".#." }, 28, 30)

-- crumbs: lit grain with its own 1 px shade lower-right (so_shade equals mud_base, so it is lifted to so_bounce)
for _, p in ipairs({ {21,16}, {35,22}, {8,34} }) do
  px(p[1], p[2], "so_bounce"); px(p[1] + 1, p[2] + 1, "mud_shade")
end

local t = c:save(D .. "trek-pixel/aseprite/" .. NAME .. ".aseprite", D .. "trek-pixel/png/" .. NAME .. ".png")
print(NAME, GV.report(t))
