local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(B .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- knife axis: origin at the guard, d points up-left along the blade
local ox, oy = 39, 38
local dx, dy = -0.6, -0.8
local nx, ny = 0.8, -0.6
local function P(a, b) return { math.floor(ox + a * dx + b * nx + 0.5), math.floor(oy + a * dy + b * ny + 0.5) } end

-- handle: rounded bar from a=-1 to a=-20, 7 px wide
local handle = c:line({ P(-3, 0), P(-15, 0) }, 6)
-- blade: straight spine (b=-3), curved belly, snapped zigzag end
local blade = c:poly({
  P(-1, -3.5), P(22, -3.5), P(25, -1.5), P(21.5, 0.5), P(24.5, 2.5), P(21, 4.5),
  P(16, 6.2), P(9, 6.6), P(3, 5.6), P(-1, 4),
})
local tip = c:poly({ {7, 25}, {15, 27}, {9, 32} })
local chip = c:poly({ {43, 15}, {48, 16}, {44, 20} })

local p = c:build{
  { "handle", handle, "wood" },
  { "blade", blade, "stone" },
  { "tip", tip, "stone" },
  { "chip", chip, "stone", { gloss = false } },
}
-- bind wraps at the top of the handle
for _, a in ipairs({ -3, -5.5 }) do
  c:seam({ P(a, -3), P(a, 3) }, { on = 2, off = 1 })
end
-- crack: zigzag running back from the break into the blade
local function cr(a, b) local q = P(a, b); c:px(q[1], q[2], "#2a1a10") end
for _, ab in ipairs({ {21, 0.5}, {20, 1}, {19, 1.5}, {18, 2}, {17, 1.5}, {16, 1}, {15, 0.5}, {14, 1}, {13, 1.5}, {12, 2} }) do
  cr(ab[1], ab[2])
end
local t = c:save(B .. "img-redraw-full/aseprite/ph/broken-foraging-knife.aseprite", B .. "img-redraw-full/png/ph/broken-foraging-knife.png")
print(GV.report(t))
