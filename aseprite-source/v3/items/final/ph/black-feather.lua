-- black-feather: one long curved raven feather, black with a blue-green iridescent sheen on the lit vane, pale quill, fine barbs. quirk: a small split has opened in the vane, parted like a zip, near the tip.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("black-feather")
local F = { "#0e0a14", "#1a1426", "#2a2238", "#3c3a5a", "#2e6a78", "#5ab8a8" }
local pts = { {12,57}, {20,38}, {36,28}, {52,8} }
local m, n, T, S = D.tube(pts, function(t) if t < .1 then return 0 end return 6.4 * sin(pi * min(1, (t - .1) / .92)) ^ .75 + .3 end)
D.tn(m, n, F, { .3, .5, .66, .8, .93 }, { wrap = .2, amb = .06 })
-- barbs
local function dir(t) local x1, y1 = D.bez(pts, t - .01) local x2, y2 = D.bez(pts, min(1, t + .01)) local l = sqrt((x2-x1)^2 + (y2-y1)^2) return (x2-x1)/l, (y2-y1)/l end
for i = 0, 36 do
  local t = .1 + i / 36 * .88
  local x, y = D.bez(pts, t) local tx, ty = dir(t)
  local px, py = -ty, tx
  for _, side in ipairs{ -1, 1 } do
    local w = 7.5
    local ex, ey = x + (side * px * w + tx * w * .9), y + (side * py * w + ty * w * .9)
    local col = side < 0 and (i % 2 == 0 and F[5] or F[4]) or F[2]
    D.ln(floor(x + .5), floor(y + .5), floor(ex + .5), floor(ey + .5), col, m)
  end
end
-- sheen specks
for _, p in ipairs{ {26,34}, {32,30}, {40,22}, {20,44} } do if m:has(p[1], p[2]) then c:px(p[1], p[2], F[6]) end end
-- shaft
for i = 0, 70 do
  local t = .02 + i / 70 * .94
  local x, y = D.bez(pts, t)
  c:px(floor(x + .5), floor(y + .5), t < .16 and "#e8d8b8" or F[4])
  if t < .16 then c:px(floor(x + 1.5), floor(y + .5), "#a89878") end
end
-- split
local sx, sy = D.bez(pts, .62)
for k = 0, 5 do D.erase(c:rect(floor(sx) + 4 + k, floor(sy) - 1 - k + 3, floor(sx) + 4 + k, floor(sy) + 1 - k + 3)) end
c:px(floor(sx) + 3, floor(sy) + 2, F[6])
D.fin()
