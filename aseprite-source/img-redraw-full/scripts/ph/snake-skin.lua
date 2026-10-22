local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- S path via Catmull-Rom through control points
local K = { {14,16}, {30,16}, {46,22}, {40,32}, {22,36}, {18,46}, {32,52}, {44,52}, {48,46} }
local pts = {}
local function cr(p0, p1, p2, p3, t)
  local t2, t3 = t*t, t*t*t
  return 0.5 * (2*p1 + (-p0 + p2)*t + (2*p0 - 5*p1 + 4*p2 - p3)*t2 + (-p0 + 3*p1 - 3*p2 + p3)*t3)
end
for i = 1, #K - 1 do
  local p0, p1, p2, p3 = K[math.max(1, i - 1)], K[i], K[i + 1], K[math.min(#K, i + 2)]
  for s = 0, 9 do
    local t = s / 10
    pts[#pts + 1] = { cr(p0[1], p1[1], p2[1], p3[1], t), cr(p0[2], p1[2], p2[2], p3[2], t) }
  end
end
pts[#pts + 1] = K[#K]
local N = #pts
local body = c:mask()
local rad = {}
for i, p in ipairs(pts) do
  local f = (i - 1) / (N - 1)
  local r = 5.3 - 4.2 * f
  if r < 1 then r = 1 end
  rad[i] = r
  body:add(c:ellipse(p[1], p[2], r, r))
end
-- head cap
local head = c:poly({ {8,10}, {20,9}, {25,15}, {20,22}, {8,21}, {5,15} })

local p = c:build{
  { "body", body, GV.ramp("#a4b86a") },
  { "head", head, GV.ramp("#4a8a3e") },
}
-- belly edge strip (pale) along the lower side of the ribbon for the first half
-- scale diamonds along the middle
for i = 9, N - 6, 6 do
  local p = pts[i]
  local x, y = math.floor(p[1] + 0.5), math.floor(p[2] + 0.5)
  if rad[i] >= 3.5 then
    c:paint({ "..s..", ".sgs.", "sgggs", ".sgs.", "..s.." }, x - 2, y - 2, { s = "#2f5a2a", g = "#4a8a3e" })
  elseif rad[i] >= 2 then
    c:paint({ ".s.", "sgs", ".s." }, x - 1, y - 1, { s = "#2f5a2a", g = "#4a8a3e" })
  else
    c:px(x, y, "#2f5a2a")
  end
end
-- head ridge seam and hollow eye holes
c:paint({ "ddd", "d.d", "ddd" }, 10, 12, { d = "#2f5a2a" })
c:paint({ "ddd", "d.d", "ddd" }, 16, 12, { d = "#2f5a2a" })
c:px(11, 13, "#1f3a1c"); c:px(17, 13, "#1f3a1c")
-- nostril slit / mouth
c:paint({ "d...d" }, 11, 18, { d = "#2f5a2a" })

local t = c:save(O .. "aseprite/ph/snake-skin.aseprite", O .. "png/ph/snake-skin.png")
print(GV.report(t))
