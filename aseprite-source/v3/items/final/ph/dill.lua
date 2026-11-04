-- dill (final pass, Opus). One slim blue-green dill stalk (tube lit, pale longitudinal ridge, sheathing leaf bases at
-- two nodes, pale cut end with a hollow) topped by a compound umbel: seven thin rays fanning in a dome, each ending in a
-- tight yellow umbellet lit as a small sphere with flower-dot texture and a dark base where the rays meet. Two feathery
-- fronds of thread-fine pinnae (lit/shade threads, darker where they join the rachis).
-- quirk: a striped swallowtail caterpillar (dill is its favourite) is climbing the stalk.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, sin, cos, rad = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.rad
local OUT = app.params.out or (debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/")
local c = A.new("dill")

local STEM = { "#1f4a44", "#2c6650", "#3f8459", "#5ea263", "#86c070", "#b8dc8e" }
local LEAF = { "#1d4a3c", "#2d6a48", "#45894f", "#68a85a", "#93c76a" }
local FLOW = { "#7a4a14", "#b7741c", "#dea12a", "#f2c63a", "#fbe26a", "#fff4a8" }
local RAY  = { "#4f8a4e", "#86b862" }
local ftok, stok, rtok, ltok = { r = { name = "flower" } }, { r = { name = "stem" } }, { r = { name = "ray" } }, { r = { name = "leaf" } }

-- feathery frond: rachis along a cubic bezier, thread pinnae alternating sides
local function frond(p, n, L0)
  local pts = {}
  for i = 0, 40 do local t = i / 40 local x, y = A.bez(p, t) pts[#pts + 1] = { x, y, t } end
  for i = 1, #pts - 1 do local a = pts[i] c:put(floor(a[1] + .5), floor(a[2] + .5), a[3] < 0.3 and LEAF[2] or LEAF[3], ltok) end
  for j = 1, n do
    local t = 0.15 + 0.8 * (j - 1) / (n - 1)
    local x, y = A.bez(p, t)
    local x2, y2 = A.bez(p, t + 0.01)
    local tx, ty = x2 - x, y2 - y local l = sqrt(tx*tx + ty*ty) tx, ty = tx / l, ty / l
    for _, side in ipairs{ -1, 1 } do
      local ux, uy = A.rot(tx, ty, side * 0.95)
      local L = L0 * (1 - t * 0.55)
      for s = 1, floor(L + .5) do
        local px, py = floor(x + ux * s + tx * s * 0.35 + .5), floor(y + uy * s + ty * s * 0.35 + .5)
        local lit = (ux + uy) < 0
        local col = s == 1 and LEAF[1] or (lit and (s >= L - 1 and LEAF[5] or LEAF[4]) or LEAF[2 + (s % 2)])
        c:put(px, py, col, ltok)
      end
    end
  end
end
frond({ { 31, 45 }, { 25, 42 }, { 20, 38 }, { 15, 32 } }, 6, 4.5)
frond({ { 33, 33 }, { 38, 31 }, { 43, 28 }, { 48, 23 } }, 5, 4.2)
frond({ { 31, 51 }, { 36, 50 }, { 40, 48 }, { 45, 47 } }, 4, 3.4)

-- umbel rays (behind the umbellets, in front of nothing)
local UX, UY = 33, 20
local ends = {}
for _, a in ipairs{ -165, -140, -115, -90, -65, -40, -15 } do
  local ex, ey = UX + 13 * cos(rad(a)), UY + 9.5 * sin(rad(a))
  ends[#ends + 1] = { ex, ey }
  local n = 14
  for i = 1, n - 2 do local t = i / n
    local x, y = UX + (ex - UX) * t, UY + (ey - UY) * t - sin(t * 3.14) * 0.8
    c:put(floor(x + .5), floor(y + .5), (a < -90) and RAY[2] or RAY[1], rtok) end
end

-- stalk
local sp = { { 31, 56 }, { 30, 46 }, { 33, 32 }, { UX, UY + 1 } }
local sm, sn, ST, SS = A.tube(sp, function(t) return t > 0.9 and 1.0 or 1.35 end)
local sb = {}
sm:each(function(x, y) local k = K(x, y) if ST[k] > 0.93 then sb[k] = -1 end end)
local si = A.shade(c, sm, sn, STEM, { amb = 0.1, wrap = 0.25, bias = sb, tok = stok })
-- pale longitudinal ridge on the lit side
sm:each(function(x, y) local k = K(x, y) if SS[k] < -0.3 and SS[k] > -0.75 and ST[k] > 0.05 and ST[k] < 0.88 and y % 5 ~= 0 then
  c:put(x, y, STEM[5], stok) end end)
-- node sheaths (pale, wrapping) where fronds leave
for _, nd in ipairs{ { 31, 45 }, { 32, 33 }, { 31, 51 } } do
  local m = c:ellipse(nd[1], nd[2], 1.6, 1.4)
  m:each(function(x, y) c:put(x, y, x < nd[1] and STEM[6] or x == nd[1] and STEM[5] or STEM[3], stok) end)
  c:put(nd[1], nd[2] + 1, STEM[2], stok)
end
-- cut end: pale ring with hollow
c:put(30, 56, STEM[6], stok) c:put(31, 56, STEM[1], stok) c:put(32, 56, STEM[4], stok)
-- spec
c:put(31, 40, A.CREAM, stok)

-- umbellets: small spheres of florets
for i, e in ipairs(ends) do
  local cx, cy = e[1], e[2]
  local r = (i == 1 or i == 7) and 1.7 or 2.1
  local m = c:ellipse(cx, cy, r, r * 0.85)
  local n = X.sphere(cx - 0.3, cy - 0.3, r + 0.4, m)
  local b = {}
  m:each(function(x, y) local k = K(x, y) if X.hash(x, y, i) > 0.7 then b[k] = 1 elseif X.hash(x, y, i + 9) > 0.8 then b[k] = -1 end
    if y >= cy + r * 0.6 then b[k] = (b[k] or 0) - 1 end end)
  A.shade(c, m, n, FLOW, { amb = 0.1, wrap = 0.3, bias = b, tok = ftok })
  -- dark base where the ray meets
  local bx, by = floor(cx + (UX - cx) * 0.35 + .5), floor(cy + (UY - cy) * 0.35 + .5)
  if m:has(bx, by) then c:put(bx, by, FLOW[1], ftok) end
end
-- umbel hub
c:put(UX, UY, STEM[2], stok) c:put(UX - 1, UY, STEM[4], stok) c:put(UX + 1, UY, STEM[2], stok)
c:put(floor(ends[4][1]) - 1, floor(ends[4][2]) - 1, A.CREAM, ftok)

-- quirk: swallowtail caterpillar climbing the right side of the stalk (head up)
local map = {
  ".k.",
  "kgk",
  "GyG",
  "KKK",
  "gGg",
  "yKy",
  "gGg",
  "KKK",
  ".g.",
}
local CM = { k = "#2b1c26", K = "#3a2a30", g = "#9fd36c", G = "#5fae52", y = "#f5a32e" }
A.stamp(c, map, 33, 37, CM, { r = { name = "bug" } })
c:put(34, 38, "#fff1cf", { r = { name = "bug" } })

A.finish(c, "dill", OUT)
