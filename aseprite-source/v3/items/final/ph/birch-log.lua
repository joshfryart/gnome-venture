-- birch-log: a horizontal silver-birch log, peeling white bark with black lenticel dashes, pale end grain with rings. quirk: a tiny sapling with two leaves is sprouting from a knot, and bark peels at the left.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_dA15.lua")
local HP, X, K = D.HP, D.X, D.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local c = D.new("birch-log")
local B = D.BIRCH
D.sh(30, 51, 24, 3)
local body = c:rect(6, 28, 42, 46)
body:add(D.ell(8, 37, 3, 9.2, 0))
-- vertical cylinder shading on horizontal log: use pillow but bias by y
local n = {}
body:each(function(x, y) local t = max(-.97, min(.97, (y - 37) / 9.6)) n[K(x, y)] = { 0, t, sqrt(1 - t * t) } end)
X.tone(c, body, X.light(n, { amb = .1, wrap = .3 }), B, { cuts = { .24, .42, .58, .74, .9 } })
-- black lenticel dashes
for i = 0, 22 do
  local x, y = 8 + (i * 7) % 33, 29 + (i * 5) % 17
  if body:has(x + 2, y) and x > 9 then c:px(x, y, "#2c2430") c:px(x + 1, y, "#2c2430") if i % 3 == 0 then c:px(x + 2, y, "#4a4252") end end
end
-- peel curl at bottom-left
c:paint({ "xxxx", "xyyxx", ".xxxx" }, 8, 44, { x = "#fffaf0", y = "#c0b8bc" })
-- end grain (right)
local en = D.ell(43, 37, 5, 9.3, 0)
D.lit(en, { "#8a5a30", "#a8743c", "#c8984e", "#e0b868", "#f0d088", "#fae8b0" }, 2, { wrap = .5 })
for _, rr in ipairs{ .3, .6, .88 } do for a = 0, 6.28, .2 do
  local x, y = floor(43 + cos(a) * 4.4 * rr + .5), floor(37 + sin(a) * 8.6 * rr + .5)
  if en:has(x, y) then c:px(x, y, "#a8743c") end
end end
c:px(43, 37, "#8a5a30")
for y = 28, 46 do if en:has(47, y) then c:px(47, y, "#b8985a") end end
-- bark rim around the end
for a = 0, 6.28, .08 do local x, y = floor(43 + cos(a) * 5.2 + .5), floor(37 + sin(a) * 9.6 + .5) if cos(a) > -.2 and not body:has(x, y) then c:px(x, y, B[3]) end end
-- sapling from a knot
c:paint({ "..x", ".x.", "x.." }, 26, 24, { x = "#6a9a48" })
D.ln(27, 28, 27, 20, "#6a9a48")
D.lf(23, 18, 3.2, 1.6, -.4, D.LEAF2) D.lf(31, 16, 3.4, 1.7, .4, D.LEAF2)
c:px(27, 26, "#2c2430") c:px(26, 27, "#2c2430") c:px(28, 27, "#2c2430") c:px(27, 28, "#2c2430")
D.fin()
