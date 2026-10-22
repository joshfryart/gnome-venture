local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }
c:fill(c:rect(0, 0, 63, 63), "#f4f0e0")
local tops = { 1, 12, 22, 33, 44, 54 }
local hts  = { 9, 8, 9, 9, 8, 9 }
local light = { ["9,33"]=1, ["1,44"]=1, ["17,44"]=1, ["25,54"]=1, ["41,54"]=1 }
local function wp(x, y, col) c:px(x % 64, y, col) end
for r = 1, 6 do
  local y0, h = tops[r], hts[r]
  local starts = (r % 2 == 1) and { 1, 17, 33, 49 } or { -7, 9, 25, 41 }
  for _, x0 in ipairs(starts) do
    local lt = light[x0 .. "," .. y0]
    local base = lt and "#d6322b" or "#a8241f"
    local hi   = lt and "#f08a24" or "#e0501f"
    local sh   = lt and "#ae2a2a" or "#6b1b2c"
    local x1, y1 = x0 + 13, y0 + h - 1
    for y = y0, y1 do for x = x0, x1 do
      local corner = (x == x0 or x == x1) and (y == y0 or y == y1)
      if not corner then
        local col = base
        if y == y1 or x == x1 then col = sh
        elseif y == y0 or x == x0 then col = hi end
        wp(x, y, col)
      end
    end end
  end
end
-- scuffs (on brick faces)
local sc = { {11,16}, {44,6}, {26,48}, {52,37}, {7,58}, {36,26} }
for _, s in ipairs(sc) do for i = 0, 2 do wp(s[1] + i, s[2], "#4a2c1a") end end
local t = c:save(O .. "aseprite/ph/tile-brick-path.aseprite", O .. "png/ph/tile-brick-path.png")
print(GV.report(t))
