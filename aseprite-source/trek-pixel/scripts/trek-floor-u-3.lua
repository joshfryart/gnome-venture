-- trek-floor-u-3: quiet cave floor with an S-shaped worm track, two burrow holes and a lichen patch
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/trek-pixel/"
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }

local su = { r = "#a06c3c", b = "#8a5a30", n = "#6e4426", s = "#5c3520", d = "#33221a" }
local UR, URHI = "#4a4632", "#6e6e48"

c:fill(c:rect(0, 0, 41, 41), su.b)

-- lichen patch x20..27 y18..22: flat, top pixel of each column lit
local lich = c:ascii({
  "..xxx...",   -- y18
  ".xxxxxx.",   -- y19
  "xxxxxxxx",   -- y20
  ".xxxxxxx",   -- y21
  "..xx.xx.",   -- y22
}, 20, 18)
c:fill(lich, UR)
for x = 20, 27 do
  for y = 18, 22 do
    if lich:has(x, y) then c:px(x, y, URHI) break end
  end
end

-- worm track: 9 bumps (2 px su_bounce, su_shade below) along an S from (6,12) to (34,30)
local bumps = { {6,12}, {10,10}, {14,11}, {16,15}, {17,19}, {19,23}, {23,26}, {28,27}, {33,29} }
-- a 1 px groove pixel between bumps so the track reads as one S-line
for i = 1, #bumps - 1 do
  local a, b = bumps[i], bumps[i + 1]
  c:px(math.floor((a[1] + b[1]) / 2 + 1), math.floor((a[2] + b[2]) / 2 + 1), su.s)
end
for _, b in ipairs(bumps) do
  c:px(b[1], b[2], su.n); c:px(b[1] + 1, b[2], su.n)
  c:px(b[1], b[2] + 1, su.s); c:px(b[1] + 1, b[2] + 1, su.s)
end

-- burrow holes: 4x3 su_deep, lit lip upper-left, shade under
local function hole(x, y, lip, under)
  c:fill(c:ascii({ ".xx.", "xxxx", ".xx." }, x, y), su.d)
  for _, p in ipairs(lip) do c:px(x + p[1], y + p[2], su.r) end
  for _, p in ipairs(under) do c:px(x + p[1], y + p[2], su.s) end
end
hole(12, 26, { {0,0}, {1,-1}, {2,-1}, {-1,1} }, { {1,3}, {2,3}, {3,2} })
hole(29, 11, { {0,0}, {1,-1} },                 { {1,3}, {2,3}, {3,2}, {4,1} })

-- flecks
for _, p in ipairs({ {9,34}, {36,17}, {18,8} }) do c:px(p[1], p[2], su.r) end

local t = c:save(R .. "aseprite/trek-floor-u-3.aseprite", R .. "png/trek-floor-u-3.png")
print(GV.report(t))
