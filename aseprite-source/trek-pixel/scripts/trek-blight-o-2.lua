-- trek-blight-o-2: further-gone blight, one big blister with a drip trail, three small dots (family 1)
local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local NAME = "trek-blight-o-2"
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }
local P = {
  du_gloss = "#a894dc", du_rim = "#7b66b4", du_base = "#4e3a8a", du_shade = "#3e2f66", du_deep = "#291d4a",
  dusk500 = "#7a5cc0",
}
local function px(x, y, k) c:px(x, y, P[k] or k) end
local function rect(x0, y0, x1, y1, k) for y = y0, y1 do for x = x0, x1 do px(x, y, k) end end end

rect(0, 0, 41, 41, "du_base")

-- drip trail (27,17)->(27,24), 2 px du_shade + du_deep on the right; puddle 4x3 at x25..28, y25..27
rect(27, 17, 28, 24, "du_shade")
for y = 17, 24 do px(29, y, "du_deep") end
-- a bead half-way down so the trail looks liquid, not a stick
px(26, 20, "du_shade"); px(26, 21, "du_shade"); px(29, 20, "du_shade"); px(29, 21, "du_shade")
px(30, 20, "du_deep"); px(30, 21, "du_deep"); px(26, 22, "du_deep"); px(29, 22, "du_deep")
rect(25, 25, 28, 27, "du_shade")
px(25, 25, "du_base"); px(29, 26, "du_deep"); px(29, 25, "du_deep") -- rounded puddle, dark right lip
for x = 26, 28 do px(x, 28, "du_deep") end
px(26, 25, "du_rim") -- wet glint on the puddle

-- blister 9x7 at x23..31, y10..16
local rows = { "..#####..", ".#######.", "#########", "#########", "#########", ".#######.", "..#####.." }
local m = {}
for j, r in ipairs(rows) do for i = 1, 9 do
  if r:sub(i, i) == "#" then m[(22 + i) .. "," .. (9 + j)] = true end
end end
local function has(x, y) return m[x .. "," .. y] == true end
local function inner(x, y) return has(x, y) and has(x - 1, y) and has(x + 1, y) and has(x, y - 1) and has(x, y + 1) end
for k in pairs(m) do
  local x, y = k:match("(%-?%d+),(%-?%d+)"); x, y = tonumber(x), tonumber(y)
  if not inner(x, y) then
    px(x, y, "du_deep")
  else
    local col = "dusk500"
    -- lower-right 2 px du_shade (distance to the outline toward lower-right)
    if not inner(x + 1, y) or not inner(x, y + 1) or not inner(x + 1, y + 1) then col = "du_shade"
    elseif not inner(x + 2, y) or not inner(x, y + 2) or not inner(x + 2, y + 1) or not inner(x + 1, y + 2) then col = "du_shade" end
    -- rim on the upper-left inside edge
    if (not inner(x - 1, y) or not inner(x, y - 1)) and (x - 27) + (y - 13) < 0 then col = "du_rim" end
    px(x, y, col)
  end
end
-- gloss comma (25..27,11) plus a dot
px(25, 11, "du_gloss"); px(26, 11, "du_gloss"); px(27, 11, "du_gloss"); px(24, 12, "du_gloss")
px(29, 12, "du_rim")

-- three small plus dots, gloss on the top arm
for _, d in ipairs({ {11,14}, {14,28}, {33,32} }) do
  local x, y = d[1], d[2]
  px(x, y, "dusk500"); px(x - 1, y, "dusk500"); px(x + 1, y, "dusk500"); px(x, y + 1, "dusk500")
  px(x, y - 1, "du_gloss")
  px(x + 1, y + 1, "du_shade")
end

-- specks
px(8, 22, "du_deep"); px(19, 35, "du_deep")

local t = c:save(D .. "trek-pixel/aseprite/" .. NAME .. ".aseprite", D .. "trek-pixel/png/" .. NAME .. ".png")
print(NAME, GV.report(t))
