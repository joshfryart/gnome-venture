-- trek-floor-o-2: dry cracked dust with sandy flecks and a fallen twig (family 1)
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local NAME = "trek-floor-o-2"
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
local P = {
  so_gloss = "#d9ba7c", so_rim = "#c9a96e", so_base = "#9a6b3f", so_shade = "#7a4a1f", so_deep = "#3d2a1c",
  wd_rim = "#d9a660", wd_shade = "#8a4f2a",
}
local function px(x, y, k) c:px(x, y, P[k] or k) end
local function rect(x0, y0, x1, y1, k) for y = y0, y1 do for x = x0, x1 do px(x, y, k) end end end

rect(0, 0, 41, 41, "so_base")

-- sandy flecks 6x2, gloss at the left end
for _, f in ipairs({ {24,10}, {9,12}, {27,33} }) do
  rect(f[1], f[2], f[1] + 5, f[2] + 1, "so_rim")
  px(f[1], f[2], "so_gloss")
end

-- hairline crack (ordered path), then branch
local crack = {}
local function seg(x0, y0, x1, y1)
  local n = math.max(math.abs(x1 - x0), math.abs(y1 - y0))
  for i = 0, n do
    local x = x0 + (n == 0 and 0 or math.floor((x1 - x0) * i / n + 0.5))
    local y = y0 + (n == 0 and 0 or math.floor((y1 - y0) * i / n + 0.5))
    crack[#crack + 1] = { x, y }
  end
end
seg(8, 22, 13, 22); seg(14, 23, 14, 23); seg(15, 24, 15, 25); seg(16, 25, 21, 25)
seg(22, 26, 22, 26); seg(23, 27, 23, 28); seg(24, 28, 30, 28)
local on = {}
for _, p in ipairs(crack) do on[p[1] .. "," .. p[2]] = true end
for _, p in ipairs({ {15,26}, {14,27}, {14,28}, {13,29}, {14,30} }) do on[p[1] .. "," .. p[2]] = true; px(p[1], p[2], "so_shade") end
for _, p in ipairs(crack) do px(p[1], p[2], "so_shade") end
-- lit lip: so_rim above every third crack pixel, starting at (10,22) -> lip (10,21)
for i = 3, #crack, 3 do
  local p = crack[i]
  if not on[p[1] .. "," .. (p[2] - 1)] then px(p[1], p[2] - 1, "so_rim") end
end

-- fallen twig (12,34) -> (19,31), 2 px thick, snapped thick end at the left
for x = 12, 19 do
  local y = 34 - math.floor((x - 12) * 3 / 7 + 0.5)
  px(x, y, "wd_shade"); px(x, y - 1, "wd_shade")
end
px(11, 33, "wd_shade"); px(11, 34, "wd_shade")   -- snapped butt, a touch thicker
px(11, 32, "wd_rim"); px(12, 32, "wd_rim")       -- lit top of the thick end
px(20, 30, "wd_shade")                            -- thin tip

-- two tiny knots
rect(33, 17, 34, 18, "so_deep")
rect(7, 29, 8, 30, "so_deep")

local t = c:save(D .. "trek-pixel/aseprite/" .. NAME .. ".aseprite", D .. "trek-pixel/png/" .. NAME .. ".png")
print(NAME, GV.report(t))
