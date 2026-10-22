-- trek-blight-u: deep indigo ground, one glowing pustule veined to four small spore dots
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/trek-pixel/"
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }

local du = { g = "#a894dc", r = "#7b66b4", b = "#4e3a8a", s = "#3e2f66", d = "#291d4a" }
local D500 = "#7a5cc0"

c:fill(c:rect(0, 0, 41, 41), du.s)

local function line(x0, y0, x1, y1, hex)
  local dx, dy = math.abs(x1 - x0), -math.abs(y1 - y0)
  local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
  local err = dx + dy
  while true do
    c:px(x0, y0, hex)
    if x0 == x1 and y0 == y1 then break end
    local e2 = 2 * err
    if e2 >= dy then err = err + dy; x0 = x0 + sx end
    if e2 <= dx then err = err + dx; y0 = y0 + sy end
  end
end
local function vein(pts) for i = 1, #pts - 1 do line(pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2], du.d) end end

-- veins first; the pustule and dots sit on top of their ends
vein({ {17,19}, {13,15}, {11,12} })
vein({ {24,19}, {28,15}, {30,13} })
vein({ {18,23}, {14,27}, {12,29} })
vein({ {24,23}, {28,27}, {30,29} })

-- big glowing pustule 8x8 cut corners x17..24 y16..23
c:paint({
  ".bbbbbb.",  -- y16
  "bbpppbbb",
  "bpgrrpbb",
  "bprrrpbd",
  "bprrrpdd",
  "bbpppddd",
  "bbbbdddd",
  ".bbdddd.",  -- y23
}, 17, 16, { b = du.b, p = D500, r = du.r, g = du.g, d = du.d })

-- four small spore dots 4x4 cut corners, each with a glaze glint (glint placed by light, varied pulse)
local function dot(x, y, rows)
  c:paint(rows, x, y, { p = D500, g = du.g, b = du.b })
end
dot(8, 9,   { ".pp.", "pgpp", "pppp", ".pp." })
dot(30, 10, { ".gp.", "pppp", "pppp", ".pb." })
dot(9, 29,  { ".pp.", "gppp", "pppp", ".pb." })
dot(31, 30, { ".pp.", "pgpp", "pppb", ".pp." })

-- flecks
for _, p in ipairs({ {21,6}, {36,21}, {5,20}, {22,35} }) do c:px(p[1], p[2], du.b) end

local t = c:save(R .. "aseprite/trek-blight-u.aseprite", R .. "png/trek-blight-u.png")
print(GV.report(t))
