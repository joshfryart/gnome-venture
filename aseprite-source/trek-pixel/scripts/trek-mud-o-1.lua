-- trek-mud-o-1: open mud, three wet dots big to small (family 1)
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local NAME = "trek-mud-o-1"
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
local P = {
  mud_base = "#7a4a1f", mud_shade = "#5c3520", soil900 = "#3d2a1c", so_base = "#9a6b3f", so_bounce = "#8b5a31",
}
local function px(x, y, k) c:px(x, y, P[k] or k) end
local function rect(x0, y0, x1, y1, k) for y = y0, y1 do for x = x0, x1 do px(x, y, k) end end end

rect(0, 0, 41, 41, "mud_base")

-- soft ridges 8x2, sheared ends
local function ridge(x0, y0)
  rect(x0 + 1, y0, x0 + 7, y0, "mud_shade")
  rect(x0, y0 + 1, x0 + 6, y0 + 1, "mud_shade")
end
ridge(20, 10); ridge(6, 27)

-- mud sheen dashes
for _, d in ipairs({ {21,18}, {31,32}, {7,36} }) do rect(d[1], d[2], d[1] + 2, d[2], "so_bounce") end

-- wet dots: soil900 hole, lit wet lip outside lower-right (+1,+1), sunk shade on upper-left inside pixel
local function dot(rows, x0, y0, sx, sy)
  local m = {}
  for j, r in ipairs(rows) do for i = 1, #r do
    if r:sub(i, i) == "#" then m[(x0 + i - 1) .. "," .. (y0 + j - 1)] = { x0 + i - 1, y0 + j - 1 } end
  end end
  for _, p in pairs(m) do
    if not m[(p[1] + 1) .. "," .. (p[2] + 1)] then px(p[1] + 1, p[2] + 1, "so_base") end
  end
  for _, p in pairs(m) do px(p[1], p[2], "soil900") end
  px(sx, sy, "mud_shade")
end
dot({ ".###.", "#####", "#####", "#####", ".###." }, 12, 12, 13, 13)
dot({ ".##.", "####", "####", ".##." }, 27, 23, 28, 24)
dot({ ".#.", "###", ".#." }, 14, 30, 15, 31)

local t = c:save(D .. "trek-pixel/aseprite/" .. NAME .. ".aseprite", D .. "trek-pixel/png/" .. NAME .. ".png")
print(NAME, GV.report(t))
