local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local s = 0.7071
-- axis runs along the diagonal (t,t); b is perpendicular (+ = upper right)
local function P(t, b, dx, dy) return { t + b * s + (dx or 0), t - b * s + (dy or 0) } end
local function poly(list, dx, dy)
  local pts = {}
  for _, q in ipairs(list) do pts[#pts + 1] = P(q[1], q[2], dx, dy) end
  return c:poly(pts)
end
-- blade stub: curved upper side, straight lower side, jagged snapped end
local blade = poly({ {35,4.2}, {31,5.6}, {28,5.6}, {26,5}, {24.2,3}, {26.2,1}, {24.2,-1}, {26.2,-3}, {25.5,-4}, {35,-4.2} })
-- loose tip, floating with a gap and a slight drift
local tip = poly({ {21.6,4.6}, {19.6,2.6}, {21.6,0.6}, {19.6,-1.4}, {21.6,-3.4}, {16.5,-1}, {14.5,0.5}, {16.5,2.5}, {19,4.6} }, -3, -2)
-- handle: fat capsule
local handle = c:mask()
for t = 38, 47, 0.5 do handle:add(c:ellipse(t, t, 5.3, 5.3)) end
handle:cut(c:rect(50, 50, 55, 51)) -- chipped butt corner
handle:cut(c:rect(52, 47, 53, 49))
local ferrule = poly({ {38.6,6}, {38.6,-6}, {34.6,-6}, {34.6,6} })
local steel = GV.ramp("#8b8f96", { gloss = "#e2e0d8", rim = "#c9c5bc" })
local p = c:build{
  { "blade", blade, steel },
  { "tip", tip, steel },
  { "handle", handle, "wood" },
  { "ferrule", ferrule, GV.ramp("#d9a660"), { cres = 2, deep = 1 } },
}
-- crack up the handle
c:paint({
  "....c",
  "...c.",
  "..cc.",
  ".c...",
  ".c...",
  "c....",
}, 41, 45, { c = "#4a2c1a" })
-- grain line on the steel
c:line({ P(33, 0), P(28, 0) }, 1)
c:fill(c:line({ P(33.5, 0.5), P(28.5, 0.5) }, 1), "#6a6f78")
local t = c:save(O .. "aseprite/ph/broken-hori-hori.aseprite", O .. "png/ph/broken-hori-hori.png")
print(GV.report(t))
