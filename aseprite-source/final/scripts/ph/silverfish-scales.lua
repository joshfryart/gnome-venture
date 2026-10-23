-- silverfish-scales: three loose teardrop scales shed by the Page Silverfish, silver with fine ridges
local D = "/home/user/gnome-venture/aseprite-source/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local PNG = "/home/user/gnome-venture/game/assets/img/ph/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- teardrop: round end at (cx,cy) radius r, tapering to a point at (px,py)
local function drop(cx, cy, r, px, py)
  local dx, dy = px - cx, py - cy
  local l = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / l * r, dx / l * r
  local m = c:ellipse(cx, cy, r, r)
  m:add(c:poly({ { cx + nx, cy + ny }, { px, py }, { cx - nx, cy - ny } }))
  return m
end
-- ridges: lines fanning from the point toward the round end
local function ridges(m, cx, cy, r, px, py, hex)
  local dx, dy = px - cx, py - cy
  local l = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / l, dx / l
  local inner = m:shrink(2)
  for _, k in ipairs({ -0.5, 0, 0.5 }) do
    local ex, ey = cx + nx * r * k - dx / l * r * 0.45, cy + ny * r * k - dy / l * r * 0.45
    c:fill(c:line({ { px - dx / l * 4, py - dy / l * 4 }, { ex, ey } }, 1):clip(inner), hex)
  end
end

local B = { 21, 23, 10, 41, 41 }   -- big scale, silver, lying across the middle
local A = { 47, 16, 6, 35, 24 }    -- little scale up top, clay-grey like the silverfish back
local C = { 45, 45, 7.5, 24, 51 }  -- middle scale in front, silver

local grey   = GV.ramp("#8b8f96")
local silver = GV.ramp("#c9c5bc")
local mA, mB, mC = drop(table.unpack(A)), drop(table.unpack(B)), drop(table.unpack(C))
local p = c:build{
  { "a", mA, grey,   { gloss = { 44, 13 } } },
  { "b", mB, silver, { gloss = { 15, 16 } } },
  { "c", mC, silver, { gloss = { 43, 41 } } },
}
ridges(p.a.m, A[1], A[2], A[3], A[4], A[5], grey.shade)
ridges(p.b.m, B[1], B[2], B[3], B[4], B[5], "#8b8f96")
ridges(p.c.m, C[1], C[2], C[3], C[4], C[5], "#8b8f96")
-- silver sheen: a cold 1 px glint beside the middle ridge of each silver scale
local sheen = GV.R.glass.gloss
c:fill(c:line({ { 19, 27 }, { 27, 31 } }, 1):clip(p.b.m:shrink(3)), sheen)
c:fill(c:line({ { 41, 47 }, { 33, 49 } }, 1):clip(p.c.m:shrink(3)), sheen)

local t = c:save(D .. "final/aseprite/ph/silverfish-scales.aseprite", PNG .. "silverfish-scales.png")
print(GV.report(t))
assert(t.semi == 0 and t.bw == 0 and t.margin >= 3)
