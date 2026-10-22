local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local cx, cy, ro, ri = 32, 33, 26, 13
local pts, inner = {}, {}
for i = 0, 9 do
  local a = -math.pi / 2 + i * math.pi / 5
  local r = (i % 2 == 0) and ro or ri
  local p = { math.floor(cx + r * math.cos(a) + 0.5), math.floor(cy + r * math.sin(a) + 0.5) }
  pts[#pts + 1] = p
  if i % 2 == 1 then inner[#inner + 1] = p end
end
local star = c:poly(pts):shrink(2):grow(2)   -- round the tips

local gold = GV.ramp("#f2b830", { shade = "#d0862a", deep = "#b8661a", gloss = "#fff1c8" })
c:build{
  { "star", star, gold, { cres = 5, deep = 2, gloss = { 24, 21 } } },
}
-- facet lines from centre toward each notch
for _, p in ipairs(inner) do
  local ex = cx + (p[1] - cx) * 0.7
  local ey = cy + (p[2] - cy) * 0.7
  local n = 8
  for k = 2, n do
    local x = math.floor(cx + (ex - cx) * k / n + 0.5)
    local y = math.floor(cy + (ey - cy) * k / n + 0.5)
    local col = c:get(x, y)
    if star:has(x, y) then c:px(x, y, "#d0862a") end
  end
end
c:px(cx, cy, "#d0862a")

local t = c:save(B .. "aseprite/ico/ico-star.aseprite", B .. "png/ico/ico-star.png")
print(GV.report(t))
