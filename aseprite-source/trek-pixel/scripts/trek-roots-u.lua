-- trek-roots-u: dark soil, pale root hairs curling out of a central knot, two glow-green tufts
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/trek-pixel/"
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }

local UR, URSH, URDP = "#4a4632", "#38352a", "#272219"
local WL, WLSH = "#c9a96e", "#9a6b3f"
local M600, MORIM, MOSH = "#4f9a45", "#a4b86a", "#4a8a3e"

c:fill(c:rect(0, 0, 41, 41), UR)

-- ordered 1 px polyline (Bresenham), no repeated joints
local function poly(pts)
  local out, seen = {}, {}
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2]
    local dx, dy = math.abs(x1 - x0), -math.abs(y1 - y0)
    local sx, sy = x0 < x1 and 1 or -1, y0 < y1 and 1 or -1
    local err = dx + dy
    while true do
      local k = x0 .. "," .. y0
      if not seen[k] then seen[k] = true; out[#out+1] = { x0, y0 } end
      if x0 == x1 and y0 == y1 then break end
      local e2 = 2 * err
      if e2 >= dy then err = err + dy; x0 = x0 + sx end
      if e2 <= dx then err = err + dx; y0 = y0 + sy end
    end
  end
  return out
end

-- six hairs out of the knot; 1 px wl_shade under every third hair pixel
local hairs = {
  { {17,20}, {13,20}, {11,17}, {11,13} },
  { {24,20}, {28,19}, {31,15} },
  { {19,24}, {17,28}, {13,30} },
  { {23,24}, {26,28}, {31,28}, {33,31} },
  { {20,17}, {20,13}, {23,10} },
  { {22,17}, {25,13} },
}
local hairpx = {}
for _, h in ipairs(hairs) do
  local p = poly(h)
  for _, q in ipairs(p) do hairpx[q[1] .. "," .. q[2]] = true; c:px(q[1], q[2], WL) end
  hairs[_] = p
end
for _, p in ipairs(hairs) do
  for i, q in ipairs(p) do
    if i % 3 == 0 and not hairpx[q[1] .. "," .. (q[2] + 1)] then c:px(q[1], q[2] + 1, WLSH) end
  end
end

-- central knot 6x6 cut corners x18..23 y18..23
c:paint({
  ".LLss.",   -- y18
  "LLssss",
  "Lsssss",
  "ssssss",
  "sssssD",
  ".ssDD.",   -- y23
}, 18, 18, { L = WL, s = WLSH, D = URDP })

-- tufts: moss600 blades, mo_rim tips, mo_shade base
local function tuft(base, blades, tips)
  c:px(base[1], base[2], MOSH)
  for _, b in ipairs(blades) do c:px(b[1], b[2], M600) end
  for _, b in ipairs(tips) do c:px(b[1], b[2], MORIM) end
end
tuft({9,32},  { {8,31}, {7,30}, {10,31}, {11,30}, {11,29} },  { {7,29}, {11,28} })
tuft({32,12}, { {31,11}, {30,10}, {33,11}, {34,10}, {34,9} }, { {30,9}, {34,8} })

-- dark flecks
for _, p in ipairs({ {6,22}, {35,24}, {15,36} }) do c:px(p[1], p[2], URSH) end

local t = c:save(R .. "aseprite/trek-roots-u.aseprite", R .. "png/trek-roots-u.png")
print(GV.report(t))
