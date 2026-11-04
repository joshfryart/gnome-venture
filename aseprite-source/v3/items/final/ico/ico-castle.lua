-- ico-castle (final pass, Opus). Storybook stone castle: two slim round towers with steep blue-slate cone roofs
-- flanking a crenellated curtain wall and an arched gate. Stone: per-pixel cylinder light on the towers, flat
-- wall with bevelled edges, offset brick courses (mortar groove + lit top lip), a few odd-toned blocks, cool
-- reflected light on the right tower. Roofs: cone normals, scalloped slate rows, AO under the eaves. Gate: plank
-- door with grain, iron straps and a gold ring in a dark recess under a pale voussoir arch.
-- quirk: someone keeps a little window box of red flowers on the right tower.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA2_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = A.new("ico-castle")
local ST = { "#393650", "#55546e", "#75758e", "#9796ac", "#bdbccb", "#e4e1ea" }
local SL = { "#26285a", "#33408a", "#4660b4", "#6688d4", "#93b4ec", "#cfe2fb" }
local WD = { "#45262a", "#6a3a2c", "#905438", "#b5764a", "#d49a60", "#ecc184" }
local IRON = { "#2e2a3c", "#4c485e", "#77738a" }
local stok, rtok, wtok = A.tok("stone"), A.tok("slate"), A.tok("door")

c:groundShadow(32, 56, 23, 1.5)

-- bricks: mortar grooves (-1) + lit top lip (+1) on a 4-row course, joints every 6 px offset by 3
local function bricks(m, idx, x0, y0, seed, curve)
  m:each(function(x, y)
    local ry = y - y0
    local course = ry // 4
    local u = x
    if curve then u = curve(x) end
    local off = (course % 2) * 3
    local jx = floor(u + off) % 6
    local k = K(x, y)
    if not idx[k] then return end
    if ry % 4 == 3 or jx == 0 then A.step(c, idx, ST, x, y, -1, stok)
    elseif ry % 4 == 0 and jx >= 1 and jx <= 3 and idx[k] >= 3 then A.step(c, idx, ST, x, y, 1, stok)
    else
      local b = floor((u + off) / 6) * 31 + course * 17 + seed
      local h = X.hash(b, course, seed)
      if h < 0.13 then A.step(c, idx, ST, x, y, -1, stok) end
    end
  end)
end

-- curtain wall with three merlons
local WL, WR, WT, WB = 20, 43, 31, 55
local wall = A.fn(WL, WT, WR, WB, function() return true end)
for _, r in ipairs{ { 22, 25 }, { 29, 34 }, { 38, 41 } } do wall:add(A.fn(r[1], WT - 4, r[2], WT - 1, function() return true end)) end
local widx = A.shade(c, wall, A.plane(wall, { -0.05, -0.05, 1 }, 1.6), ST, { tok = stok, cuts = { 0.18, 0.4, 0.58, 0.72, 0.86 } })
bricks(wall, widx, WL, WT - 4, 3)
-- merlon caps lit, walkway shadow behind the gaps
for x = WL, WR do
  for y = WT - 4, WT do
    if wall:has(x, y) and not wall:has(x, y - 1) then A.set(c, widx, ST, x, y, wall:has(x, WT - 4) and 6 or 2, stok) end
  end
end

-- gate: pale voussoir ring, dark recess, plank door
local GX, GY, GR = 31.5, 45, 6
local arch = A.fn(GX - GR - 2.5, GY - GR - 3, GX + GR + 2.5, WB, function(x, y)
  local d = sqrt((x - GX)^2 + (min(y, GY) - GY)^2)
  return d <= GR + 2.6
end)
local open = A.fn(GX - GR, GY - GR, GX + GR, WB, function(x, y)
  return sqrt((x - GX)^2 + (min(y, GY) - GY)^2) <= GR + 0.5
end)
local vous = arch:copy():cut(open)
vous:each(function(x, y)
  if y <= GY + 1 then
    local a = math.atan(y - GY, x - GX)
    local seg = floor((a + math.pi) / (math.pi / 7))
    local i = widx[K(x, y)] or 4
    local t = (seg % 2 == 0) and 6 or 5
    if x > GX + 3 then t = t - 1 end
    if not arch:has(x, y - 1) or not arch:has(x - 1, y) or not arch:has(x + 1, y) then t = 2 end
    A.set(c, widx, ST, x, y, t, stok)
    -- radial joints
    local fa = ((a + math.pi) / (math.pi / 7)) % 1
    if fa < 0.14 then A.set(c, widx, ST, x, y, 3, stok) end
  end
end)
-- door (planks) inside, 1 px recess
local door = open:copy():shrink(1)
open:copy():cut(door):each(function(x, y) c:put(x, y, "#2e1e2c", wtok) end)
local didx = A.shade(c, door, A.plane(door, { 0.05, 0.1, 1 }, 1.2), WD, { tok = wtok, cuts = { 0.15, 0.32, 0.5, 0.66, 0.84 } })
door:each(function(x, y)
  local px = (x - 27) % 3
  if px == 0 then A.step(c, didx, WD, x, y, -2, wtok)
  elseif X.hash(x, y // 2, 5) < 0.18 then A.step(c, didx, WD, x, y, -1, wtok) end
  if y <= GY - 4 then A.step(c, didx, WD, x, y, -1, wtok) end -- AO under the arch
end)
for _, by in ipairs{ 46, 52 } do
  for x = floor(GX - GR + 1), floor(GX + GR) do
    if door:has(x, by) then c:put(x, by, IRON[2], wtok) end
    if door:has(x, by - 1) then c:put(x, by - 1, IRON[3], wtok) end
    if door:has(x, by + 1) then A.step(c, didx, WD, x, by + 1, -1, wtok) end
  end
  c:put(28, by, IRON[1], wtok) c:put(35, by, IRON[1], wtok)
end
A.map(c, { ".g.", "g.g", ".G." }, 33, 48, { g = "#f5b82e", G = "#b06a22" }, wtok)
c:put(33, 48, "#ffe38a", wtok)

-- towers
local TT, TB = 24, 55
local function tower(x0, x1, cx, seed, right)
  local m = A.fn(x0, TT, x1, TB, function() return true end)
  local n = A.vcyl(m, x0, x1)
  local idx = A.shade(c, m, n, ST, { tok = stok, cuts = { 0.16, 0.34, 0.52, 0.68, 0.84 } })
  local hw = (x1 - x0) / 2 + 0.5
  bricks(m, idx, x0, TT, seed, function(x)
    local s = max(-0.99, min(0.99, (x - cx) / hw))
    return cx + math.asin(s) * hw * 1.05
  end)
  -- AO where the wall meets the tower (wall side) is done after; AO under eaves
  for x = x0, x1 do A.step(c, idx, ST, x, TT, -2, stok) A.step(c, idx, ST, x, TT + 1, -1, stok) end
  -- cool reflected light on the far right edge
  if right then for y = TT + 6, TB - 3 do c:put(x1, y, "#6a7aa6", stok) end end
  -- arched window slit 3 wide
  local wx = floor(cx) - 1
  A.map(c, { ".w.", "www", "www", "www", "www", "www" }, wx, 31, { w = "#2a2238" }, stok)
  c:put(wx, 32, "#3d3352", stok)
  for x = wx - 1, wx + 3 do A.set(c, idx, ST, x, 37, 5, stok) end -- sill
  for x = wx - 1, wx + 3 do A.step(c, idx, ST, x, 38, -1, stok) end
  return m, idx
end
local tl, tlidx = tower(9, 19, 14, 7)
local tr, tridx = tower(44, 54, 49, 11, true)
-- wall AO beside the towers
A.ao(c, widx, ST, wall, tl, 2, -1, stok)
A.ao(c, widx, ST, wall, tr, 2, -1, stok)

-- cone roofs
local function roof(cx, apex, base, hwb)
  local m = A.fn(cx - hwb - 1, apex, cx + hwb + 1, base + 2, function(x, y)
    local hw = 0.6 + (y - apex) / (base - apex) * hwb
    if y > base then hw = hwb end
    local dx = abs(x - cx)
    if dx > hw then return false end
    local lip = base + 1.6 * sqrt(max(0, 1 - (dx / (hwb + 0.6))^2))
    return y <= lip
  end)
  local n = A.nfn(m, function(x, y)
    local hw = max(1, 0.6 + (min(y, base) - apex) / (base - apex) * hwb)
    local s = max(-0.95, min(0.95, (x - cx) / (hw + 0.5)))
    return s * 0.9, -0.42, sqrt(1 - s*s) * 0.9
  end)
  local idx = A.shade(c, m, n, SL, { tok = rtok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 } })
  -- slate rows: scalloped course line every 3 rows, tile joints offset
  m:each(function(x, y)
    local dx = x - cx
    local ry = y - apex - floor(dx * dx / 40)
    if y > apex + 2 then
      if ry % 3 == 0 then A.step(c, idx, SL, x, y, -1, rtok)
      elseif ry % 3 == 1 and floor(x + (ry // 3) * 2) % 4 == 0 then A.step(c, idx, SL, x, y, -1, rtok) end
    end
  end)
  -- eave lip: lit front edge row
  m:each(function(x, y) if not m:has(x, y + 1) and abs(x - cx) < hwb - 1 then A.step(c, idx, SL, x, y, -1, rtok) end end)
  return m, idx
end
local rl, rlidx = roof(14, 12, 25, 7)
local rr, rridx = roof(49, 12, 25, 7)
-- specular glints on the slate (glossy wet slate)
c:put(11, 18, SL[6], rtok) c:put(11, 19, SL[5], rtok)
c:put(46, 18, SL[6], rtok) c:put(46, 19, SL[5], rtok)
-- AO on the tower just under the eave lip
for _, t in ipairs{ { tl, tlidx, rl }, { tr, tridx, rr } } do A.ao(c, t[2], ST, t[1], t[3], 1, -1, stok) end

-- pennant on the left roof, gold finial on the right
for y = 7, 12 do c:put(14, y, y == 7 and "#ffe38a" or "#8f4a1f") end
A.map(c, {
  "ERRr..",
  "eRRRrr",
  "eRRr..",
}, 15, 7, { E = "#ff8a5c", e = "#e8493b", R = "#e8493b", r = "#b52e3f" })
c:put(21, 8, "#6e2038")
A.map(c, { "hg", "gG" }, 49, 10, { h = "#ffe38a", g = "#f5b82e", G = "#d98322" })
c:put(49, 12, "#8f4a1f") c:put(50, 12, "#8f4a1f")

-- quirk: window box with red flowers under the right tower window
A.map(c, {
  "R.R.R",
  "rgrgr",
  "WWWWW",
  "wwwww",
}, 47, 35, { R = "#ff6a5a", r = "#c93a44", g = "#5fae4e", W = "#c98a52", w = "#7a4630" })
c:put(48, 35, "#3f9150") c:put(50, 35, "#3f9150")
c:put(47, 34, "#ffb0a0")

A.save(c, "ico-castle")
