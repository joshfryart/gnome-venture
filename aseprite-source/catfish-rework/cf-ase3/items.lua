-- items.lua: cf-rod (48x64), cf-ico-kibble, cf-ico-yarn (32x32) in the pass-1 style (hard pixels, 1px ink outline).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local L = dofile(DIR .. "/cflib.lua")
local OUT = app.params["out"] or (DIR .. "/out/")
local function mix(a, b)
  local function ch(h, i) return tonumber(h:sub(i, i + 1), 16) end
  return string.format("#%02x%02x%02x", (ch(a, 2) + ch(b, 2)) // 2, (ch(a, 4) + ch(b, 4)) // 2, (ch(a, 6) + ch(b, 6)) // 2)
end
local function R(D, s, m, l, Lh, g) return { D = D, s = mix(D, s), b = s, m = m, l = l, L = Lh, g = g } end
local WOOD = R("#3d2314", "#6a4128", "#8a5a34", "#b07a48", "#cf9a62", "#efc990")
local RED = R("#7a1f2a", "#b8353a", "#e0523f", "#f07a52", "#ff9d70", "#ffd0a8")
local BLUE = R("#2a3a7a", "#3a5ab0", "#4f9fe0", "#7cc0f0", "#a8dcff", "#e4f6ff")
local GOLD = R("#8f4a1f", "#d98322", "#f5b82e", "#ffd257", "#ffe38a", "#fff6cf")
local PINK = R("#7d2c5e", "#c94f84", "#e8609c", "#f08aac", "#f7a9c2", "#fff0f4")
local BROWN = R("#3a1f12", "#6a3a1e", "#9a5e2e", "#c08040", "#dda35a", "#f4cf8a")
local function part(c, m, ramp, ws, wl, o) o = o or {} o.ws, o.wl, o.ramp = ws or 1, wl or 1, ramp c:part(m, o) end
local function px(c, list, col, layer) for _, p in ipairs(list) do c:put(p[1], p[2], col, layer or "detail") end end

-- ROD ------------------------------------------------------------------------------------------------
do
  local c = L.canvas(48, 64)
  local A, B = { 13, 49 }, { 34, 11 }
  local function at(t) return { A[1] + (B[1] - A[1]) * t, A[2] + (B[2] - A[2]) * t } end
  local shaft = L.tube({ at(0.1), at(1) }, function() return 1.5 end)
  part(c, shaft, WOOD, 1, 1)
  local p0, p1 = at(0.0), at(0.46)
  local grip = L.tube({ p0, p1 }, function() return 2.7 end)
  part(c, grip, RED, 2, 2)
  -- wrap bands across the grip
  for i = 1, 5 do
    local q = at(0.04 + i * 0.075)
    for dx = -3, 3 do local x, y = math.floor(q[1] + dx + 0.5), math.floor(q[2] - dx * 0.55 + 0.5)
      if grip:has(x, y) then c:put(x, y, (i % 2 == 0) and RED.s or RED.l, "detail") end end
  end
  local pom = L.ellipse(11.5, 51.5, 3.4, 3.4)
  part(c, pom, BLUE, 2, 2)
  px(c, { { 10, 50, BLUE.g }, { 11, 49, BLUE.L } }, nil)
  local bead = at(0.5)
  local b1 = L.ellipse(bead[1], bead[2], 2.6, 2.6) part(c, b1, GOLD, 1, 1)
  px(c, { { math.floor(bead[1]) - 1, math.floor(bead[2]) - 1, GOLD.g } })
  -- bow: two loops and a knot
  local k = at(0.78)
  local kx, ky = math.floor(k[1] + 0.5), math.floor(k[2] + 0.5)
  local l1 = L.poly({ { kx, ky }, { kx - 8, ky - 4 }, { kx - 8, ky + 3 } })
  local l2 = L.poly({ { kx, ky }, { kx + 8, ky - 3 }, { kx + 8, ky + 5 } })
  part(c, l1, BLUE, 1, 1) part(c, l2, BLUE, 1, 1)
  local knot = L.ellipse(kx, ky, 1.9, 1.9) part(c, knot, BLUE, 1, 1, { lift = -1 })
  px(c, { { kx - 5, ky - 1, BLUE.L }, { kx + 4, ky, BLUE.L }, { kx - 1, ky - 1, BLUE.g } })
  local tip = L.ellipse(B[1] + 1.5, B[2] - 1.5, 3, 3) part(c, tip, GOLD, 2, 2)
  px(c, { { B[1], B[2] - 3, GOLD.g }, { B[1] - 1, B[2] - 2, GOLD.L } })
  -- feather tuft hanging off the bead is skipped: the red grip carries the colour
  c:outline() c:save(OUT, "cf-rod")
  print("rod colours", c:colours())
end

-- KIBBLE ---------------------------------------------------------------------------------------------
do
  local c = L.canvas(32, 32)
  local bowl = L.poly({ { 5, 18 }, { 27, 18 }, { 24, 28 }, { 8, 28 } })
  part(c, bowl, BLUE, 2, 3)
  for x = 8, 24, 3 do c:put(x, 22, GOLD.m, "detail") c:put(x + 1, 22, GOLD.m, "detail") end   -- stitched band
  L.rect(5, 17, 27, 18):each(function(x, y) c:put(x, y, (y == 17) and BLUE.L or BLUE.l, "light") end)
  local nug = { { 11, 14, 3.6, 3 }, { 21, 14, 3.6, 3 }, { 16, 10, 3.8, 3.2 }, { 8, 17, 2.8, 2 }, { 24, 17, 2.8, 2 }, { 16, 16, 3.4, 2.6 } }
  for _, n in ipairs(nug) do part(c, L.ellipse(n[1], n[2], n[3], n[4]), BROWN, 1, 1) end
  px(c, { { 15, 9, BROWN.g }, { 10, 13, BROWN.g }, { 20, 13, BROWN.g }, { 16, 14, BROWN.L } })
  c:outline() c:save(OUT, "cf-ico-kibble")
  print("kibble colours", c:colours())
end

-- YARN -----------------------------------------------------------------------------------------------
do
  local c = L.canvas(32, 32)
  local tail = L.tube({ { 20, 23 }, { 24, 26 }, { 27, 24 } }, function() return 1.5 end)
  part(c, tail, PINK, 1, 1)
  local ball = L.ellipse(14, 14, 10.4, 10.4)
  part(c, ball, PINK, 4, 4)
  -- wound strands: three diagonal arcs across the ball
  for _, off in ipairs({ -6, -1, 4 }) do
    for t = -9, 9 do
      local x, y = math.floor(14 + t + 0.5), math.floor(14 + off - t * 0.55 + 0.5)
      if ball:has(x, y) and ball:has(x + 1, y + 1) and ball:has(x - 1, y - 1) then
        c:put(x, y, PINK.s, "detail")
        if ball:has(x, y - 1) then c:put(x, y - 1, PINK.L, "detail") end
      end
    end
  end
  px(c, { { 9, 8, PINK.g }, { 10, 7, PINK.g }, { 8, 9, PINK.L } })
  c:outline() c:save(OUT, "cf-ico-yarn")
  print("yarn colours", c:colours())
end
