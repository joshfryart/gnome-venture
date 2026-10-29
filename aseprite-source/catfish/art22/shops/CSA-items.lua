-- shops/CSA-items.lua : Cat Fish pet shop CSA "Spice Bazaar Pets" (Spicepeak, Central and South Asia), the 5 item
-- sprites (claude/catfish-shops-art-spec.md). Stitched Toy at 1x (like the cats): 1 px three-tone umber outline lit
-- by side, 1 px #000000 border, rim upper left, one crescent shade lower right, enamel gloss comma, gold thread.
-- Shared regional palette: marigold orange, turmeric yellow, rani pink, peacock teal, bronze/brass, terracotta.
--   singing_bowl      shelf   20x24  bronze singing bowl on a pink felt ring cushion, wooden striker leaning behind
--   marigold_garland  ceiling 48x34  toran: two swags of marigold balls + three dangling strands, mango-leaf ties
--   tiger_stripe_rug  floor-l 38x28  Tibetan-style felt tiger-stripe rug, back edge rolled, cream fringe in front
--   kite_tail_lure    rod     16x16  little patang (diamond fighter kite) with a bowed tail, hanging from its string
--   chai_stall_sign   frame   35x31  painted chai-stall board: brass kettle pouring into a clay kulhad, steam
-- Run: AppRun -b --script shops/CSA-items.lua    Writes art22/out/cf-pet-<slug>.png + .aseprite
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local C = GV.C

---------------------------------------------------------------- palette (hand-set hue-shifted ramps)
local R = {
  mari  = { gloss = "#ffe08a", rim = "#f9a541", base = "#f08a24", shade = "#c8571e", deep = "#8e3418" },
  turm  = { gloss = "#fff1c8", rim = "#ffd860", base = "#f5b820", shade = "#d0862a", deep = "#9a5418" },
  pink  = { gloss = "#ffb8c8", rim = "#e8608e", base = "#c8336e", shade = "#92245a", deep = "#5e1a44" },
  teal  = { gloss = "#b8f0d8", rim = "#4fb8a8", base = "#2a8a86", shade = "#1f6070", deep = "#18405a" },
  bronze= { gloss = "#ffe8b0", rim = "#e8a85a", base = "#c07a36", shade = "#8a4a2a", deep = "#5e2a1e" },
  brass = { gloss = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a", deep = "#7a3a14" },
  terra = { gloss = "#ffc8a0", rim = "#e08a5a", base = "#c8643c", shade = "#9a4430", deep = "#6b2a26" },
  leaf  = { gloss = "#c8d77a", rim = "#8cc064", base = "#5f9e48", shade = "#3f7a3a", deep = "#2f5a2a" },
  wood  = { gloss = "#ecc58a", rim = "#d9a660", base = "#b07a45", shade = "#8a4f2a", deep = "#5e2f1e" },
  cream = { gloss = "#fff3c8", rim = "#fff3c8", base = "#f2e4c0", shade = "#d8b98a", deep = "#b8905a", pale = true },
  back  = { gloss = "#f0b060", rim = "#d0862a", base = "#b8661a", shade = "#8a4220", deep = "#5e2a1e" }, -- rug backing
}
local OL1, OL2, OL3, BLACK = C.ol1, C.ol2, C.ol3, "#000000"
local GOLD, GOLDS = C.gold, C.goldS

---------------------------------------------------------------- tiny 1x sprite kit
local function sprite(w, h)
  local c = GV.canvas{ w = w, h = h, mode = "scene", bleed = "", out = 1 }
  c.art, c.pale, c.nob = {}, {}, {}
  return c
end
local function K(c, x, y) return c:key(x, y) end
-- distance (1..n+1) to the edge of m along the diagonal (dx, dy)
local function dist(m, x, y, dx, dy, n)
  for d = 1, n do if not m:has(x + dx * d, y + dy * d) then return d end end
  return n + 1
end
-- part: shaded felt/enamel blob. o.cres (crescent depth, 2), o.deep (deep tone on the lower-right edge),
-- o.contour=false (no inner contour against earlier parts), o.gloss = {{x,y},...} comma px, o.dot = {x,y}
local function part(c, m, r, o)
  o = o or {}
  local cres = o.cres or 2
  if o.contour ~= false then
    local ring = {}
    m:each(function(x, y)
      for _, d in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
        local nx, ny = x + d[1], y + d[2]
        if not m:has(nx, ny) and c.art[K(c, nx, ny)] then
          local k = K(c, nx, ny)
          local lit = (d[1] + d[2]) < 0
          if lit then ring[k] = ring[k] or OL2 else ring[k] = OL3 end
        end
      end
    end)
    for k, t in pairs(ring) do c.pix[k] = t end
  end
  m:each(function(x, y)
    local lr = dist(m, x, y, 1, 1, 4)
    local ul = dist(m, x, y, -1, -1, 4)
    local t = r.base
    if lr <= cres and lr < ul then
      t = r.shade
      if o.deep and lr == 1 and (not m:has(x + 1, y) or not m:has(x, y + 1)) then t = r.deep end
    elseif ul == 1 and lr > 1 and o.rim ~= false then
      t = r.rim
    end
    c:px(x, y, t)
    local k = K(c, x, y)
    c.art[k] = true
    c.pale[k] = r.pale or nil
  end)
  for _, g in ipairs(o.gloss or {}) do c:px(g[1], g[2], r.gloss) end
  if o.dot then c:px(o.dot[1], o.dot[2], r.dot or r.gloss) end
  return m
end
local function P(c, x, y, h) c:px(x, y, h); c.art[K(c, x, y)] = true end
-- paint rows with a legend (also marks art)
local function paint(c, rows, x0, y0, L)
  for j, row in ipairs(rows) do for i = 1, #row do
    local v = L[row:sub(i, i)]
    if v then P(c, x0 + i - 1, y0 + j - 1, v) end
  end end
end
-- gold thread 2 on / 1 off along a list of px
local function thread(c, pts, gap)
  for i, p in ipairs(pts) do
    if i % 3 ~= 0 then c:px(p[1], p[2], (c:get(p[1], p[2]) and c.shadeset and c.shadeset[c:get(p[1], p[2])]) and GOLDS or GOLD)
    elseif gap then c:px(p[1], p[2], gap) end
  end
end
-- silhouette outline (selective by side) + 1 px black border (skips c.nob px)
local N4 = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }
local function finish(c)
  local add = {}
  for y = 0, c.H - 1 do for x = 0, c.W - 1 do
    if not c:get(x, y) then
      local vx, vy, any, pale = 0, 0, false, false
      for _, d in ipairs(N4) do
        local k = K(c, x + d[1], y + d[2])
        if c:inside(x + d[1], y + d[2]) and c.art[k] then
          any = true; vx = vx - d[1]; vy = vy - d[2]
          if c.pale[k] then pale = true end
        end
      end
      if any then
        local s = vx + vy
        local t = s < 0 and OL1 or (s > 0 and OL3 or OL2)
        if pale and t == OL1 then t = OL2 end
        add[K(c, x, y)] = t
      end
    end
  end end
  for k, t in pairs(add) do c.pix[k] = t end
  add = {}
  for y = 0, c.H - 1 do for x = 0, c.W - 1 do
    local k = K(c, x, y)
    if not c.pix[k] and not c.nob[k] then
      for _, d in ipairs(N4) do
        local nx, ny = x + d[1], y + d[2]
        if c:inside(nx, ny) and c.pix[K(c, nx, ny)] and not c.nob[K(c, nx, ny)] then add[k] = true break end
      end
    end
  end end
  for k in pairs(add) do c.pix[k] = BLACK end
end
-- string px drawn after the border (no outline, no border)
local function str(c, x, y, h) c:px(x, y, h or OL2); c.nob[K(c, x, y)] = true end

local FAILS, REPORT = {}, {}
local function save(c, slug, mw, mh)
  local name = "cf-pet-" .. slug
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  local line = string.format("%-18s %s", slug, GV.report(t))
  print(line)
  if t.semi ~= 0 or t.bw ~= 0 or t.w > mw or t.h > mh then FAILS[#FAILS + 1] = slug end
end

---------------------------------------------------------------- 1. singing bowl (shelf 20x24)
do
  local c = sprite(20, 24)
  -- wooden striker leaning behind the bowl's right shoulder, a pink suede-wrapped knob on top
  part(c, c:line({ { 16, 15 }, { 16, 6 } }, 2), R.wood, { cres = 1 })
  part(c, c:rrect(14, 2, 17, 5, 1), R.pink, { cres = 1, gloss = { { 15, 3 } } })
  -- felt ring cushion
  local cush = c:rrect(2, 15, 17, 21, 2)
  part(c, cush, R.pink, { cres = 2, gloss = { { 4, 16 }, { 5, 16 } } })
  -- bronze bowl, seen a little from above: back lip, dark inside, bright front lip, round belly
  local bowl = c:ascii({
    "..##########..",
    ".############.",
    "##############",
    "##############",
    "##############",
    ".############.",
    "..##########..",
    "...########...",
  }, 3, 9)
  part(c, bowl, R.bronze, { cres = 3, deep = true })
  for x = 5, 14 do c:px(x, 9, R.bronze.rim) end                      -- back lip
  for x = 5, 14 do c:px(x, 10, R.bronze.deep) end                    -- inside, back wall in shadow
  for x = 4, 15 do c:px(x, 11, (x < 6) and R.bronze.deep or R.bronze.shade) end -- inside floor
  c:px(4, 10, R.bronze.rim); c:px(15, 10, R.bronze.base); c:px(3, 11, R.bronze.rim); c:px(16, 11, R.bronze.shade)
  for x = 3, 16 do c:px(x, 12, (x < 11) and R.bronze.gloss or (x < 15 and R.bronze.rim or R.bronze.shade)) end -- front lip
  c:px(3, 12, R.bronze.rim)
  -- engraved band round the belly + gloss comma
  for x = 5, 14, 2 do c:px(x, 14, (x < 11) and R.bronze.shade or R.bronze.deep) end
  c:px(4, 13, R.bronze.gloss); c:px(5, 13, R.bronze.gloss)
  -- gold seam across the cushion front
  local pts = {} for x = 3, 16 do pts[#pts + 1] = { x, 19 } end
  thread(c, pts, R.pink.shade)
  finish(c)
  save(c, "singing_bowl", 20, 24)
end

---------------------------------------------------------------- 2. marigold garland (ceiling 48x34)
do
  local c = sprite(48, 34)
  local balls = {}
  local function ball(x, y, col) balls[#balls + 1] = { x, y, col } end
  -- two swags between ties at x 3, 24, 44 (top y 3), dipping to y 11
  local function swag(xa, xb, n, off)
    for i = 0, n do
      local t = i / n
      local x = xa + (xb - xa) * t
      local y = 4 + 8 * (1 - (2 * t - 1) ^ 2)
      ball(math.floor(x + 0.5), math.floor(y + 0.5), ((i + off) % 2 == 1) and "turm" or "mari")
    end
  end
  swag(4, 23, 5, 0)
  swag(25, 43, 5, 1)
  -- dangling strands (drawn after, so they sit in front)
  local strands = { { 4, 3 }, { 24, 5 }, { 43, 3 } }
  for si, s in ipairs(strands) do
    for j = 1, s[2] do ball(s[1] + ((j % 2 == 0) and 1 or 0), 4 + j * 4, ((j + si) % 2 == 0) and "turm" or "mari") end
  end
  -- paint balls back to front: swags first, then strands top-down
  for _, b in ipairs(balls) do
    local m = c:ellipse(b[1], b[2], 2, 2)
    part(c, m, R[b[3]], { cres = 2, gloss = { { b[1] - 1, b[2] - 1 } } })
    c:px(b[1] + 1, b[2] + 1, R[b[3]].deep) -- ruffle notch
  end
  -- mango-leaf tips under each strand and leaf ties at the knots
  for si, s in ipairs(strands) do
    local yb = 4 + s[2] * 4 + 3
    local lf = c:poly({ { s[1] - 1, yb }, { s[1] + 2, yb }, { s[1] + 1, yb + 4 }, { s[1], yb + 4 } })
    part(c, lf, R.leaf, { cres = 1 })
    -- knot tie: two little leaves either side at the top
    part(c, c:rect(s[1] - 3, 1, s[1] - 1, 2), R.leaf, { cres = 1 })
    part(c, c:rect(s[1] + 1, 1, s[1] + 3, 2), R.leaf, { cres = 1 })
    part(c, c:rect(s[1] - 1, 1, s[1] + 1, 3), R.pink, { cres = 1, gloss = { { s[1] - 1, 1 } } })
  end
  finish(c)
  save(c, "marigold_garland", 48, 34)
end

---------------------------------------------------------------- 3. tiger-stripe rug (floor-left 38x28)
do
  local c = sprite(38, 28)
  -- flat felt rug in perspective: back edge y 6 (x 8..29), front edge y 20 (x 2..35)
  local yb, yf = 6, 20
  local function xl(y) return 8 - (y - yb) * 6 / (yf - yb) end
  local function xr(y) return 29 + (y - yb) * 6 / (yf - yb) end
  local function X(v) return math.floor(v + 0.5) end
  local top = c:mask()
  for y = yb, yf do for x = X(xl(y)), X(xr(y)) do top:set(x, y) end end
  local edge = c:mask()
  for x = 2, 35 do edge:set(x, 21); edge:set(x, 22) end
  -- cream fringe front and back (behind the rug)
  local fr = c:mask()
  for x = 3, 34 do fr:set(x, 23) end
  for x = 3, 34, 2 do fr:set(x, 24); fr:set(x, 25) end
  for x = 9, 28 do fr:set(x, 5) end
  for x = 9, 28, 2 do fr:set(x, 4) end
  part(c, fr, R.cream, { cres = 0, rim = false, contour = false })
  part(c, edge, R.back, { cres = 1, contour = false })
  part(c, top, R.mari, { cres = 2, gloss = { { 9, 7 }, { 10, 7 }, { 11, 7 } } })
  top:each(function(x, y)
    local x0, x1 = X(xl(y)), X(xr(y))
    local u = (x - xl(y)) / (xr(y) - xl(y))
    local edgepx = (y == yb or y == yf or x == x0 or x == x1)
    local band = not edgepx and (y == yb + 1 or y == yf - 1 or x == x0 + 1 or x == x1 - 1)
    if band then c:px(x, y, (u > 0.55 or y >= yf - 1) and R.pink.shade or R.pink.base)
    elseif not edgepx and y > yb + 1 and y < yf - 1 then
      -- tiger stripes: wedges from the back and from the front, alternating across the rug
      local v = (y - yb - 2) / (yf - yb - 4)
      local n = 9
      local f = u * n
      local i = math.floor(f)
      local w = f - i
      local fromBack = (i % 2 == 0)
      local len = fromBack and (0.66 - v) or (v - 0.34)
      local mid = 0.5 + (fromBack and 1 or -1) * 0.22 * (v - 0.5)
      if len > 0 then
        local half = 0.07 + len * 0.40
        if math.abs(w - mid) < half then c:px(x, y, (v > 0.5) and OL3 or OL2) end
      end
    end
  end)
  -- gold stitch along the front edge
  local pts = {} for x = 3, 34 do pts[#pts + 1] = { x, 21 } end
  thread(c, pts, nil)
  finish(c)
  save(c, "tiger_stripe_rug", 38, 28)
end

---------------------------------------------------------------- 4. kite tail lure (rod 16x16)
do
  local c = sprite(16, 16)
  -- diamond patang, top (6,2) right (10,6) bottom (6,10) left (2,6)
  local dia = c:mask()
  for y = 2, 10 do local h = 4 - math.abs(y - 6) for x = 6 - h, 6 + h do dia:set(x, y) end end
  local upper = c:mask(); dia:each(function(x, y) if y <= 6 then upper:set(x, y) end end)
  local lower = c:mask(); dia:each(function(x, y) if y > 6 then lower:set(x, y) end end)
  part(c, upper, R.pink, { cres = 2, gloss = { { 5, 4 }, { 4, 5 } } })
  part(c, lower, R.turm, { cres = 2 })
  -- spine
  for y = 3, 9 do if c:get(6, y) and y ~= 6 then c:px(6, y, (y < 6) and R.pink.shade or R.turm.shade) end end
  -- little pucchi tail triangle
  part(c, c:rect(5, 11, 7, 11):add(c:rect(6, 12, 6, 12)), R.teal, { cres = 1 })
  -- ribbon bows on the tail
  part(c, c:line({ { 8, 12 }, { 10, 12 }, { 12, 11 } }, 2), R.teal, { cres = 1 })
  c:px(10, 12, R.turm.base); c:px(10, 13, R.turm.shade)
  finish(c)
  -- string on top, tail string between the bows (no border)
  str(c, 6, 0); str(c, 6, 1)
  save(c, "kite_tail_lure", 16, 16)
end

---------------------------------------------------------------- 5. chai stall sign (frame 35x31)
do
  local c = sprite(35, 31)
  local board = c:rect(2, 2, 32, 28)
  part(c, board, R.pink, { cres = 2, gloss = { { 3, 3 }, { 4, 3 }, { 3, 4 } } })
  -- painted field
  local field = c:rect(6, 6, 28, 24)
  part(c, field, R.teal, { cres = 0, rim = false })
  -- counter strip
  part(c, c:rect(6, 21, 28, 24), R.wood, { cres = 1, contour = false })
  -- tall chai kettle: bail handle over the top, knob lid, spout low on the right
  for _, p in ipairs({ { 9, 11 }, { 9, 10 }, { 10, 9 }, { 11, 8 }, { 12, 8 }, { 13, 8 }, { 14, 8 }, { 15, 9 }, { 16, 10 }, { 16, 11 } }) do
    P(c, p[1], p[2], OL2)
  end
  part(c, c:line({ { 17, 18 }, { 18, 16 }, { 19, 14 } }, 2), R.brass, { cres = 1 })
  local pot = c:rrect(9, 12, 16, 20, 2)
  part(c, pot, R.brass, { cres = 2, deep = true, gloss = { { 10, 14 }, { 10, 15 }, { 11, 14 } } })
  for x = 10, 15 do c:px(x, 13, (x < 13) and R.brass.shade or R.brass.deep) end   -- lid seam
  part(c, c:rect(12, 10, 13, 11), R.brass, { cres = 1 })                            -- knob
  -- chai pouring into the kulhad
  P(c, 21, 14, R.terra.rim); P(c, 21, 15, R.terra.rim); P(c, 22, 16, R.terra.rim)
  -- clay kulhad cups
  part(c, c:rect(20, 17, 24, 17):add(c:rect(21, 18, 23, 20)), R.terra, { cres = 1 })
  part(c, c:rect(25, 18, 27, 18):add(c:rect(25, 19, 27, 20)), R.terra, { cres = 1 })
  -- steam curls
  for _, p in ipairs({ { 25, 15 }, { 26, 14 }, { 25, 13 }, { 26, 12 } }) do c:px(p[1], p[2], R.cream.base) end
  -- marigold studs at the corners
  for _, p in ipairs({ { 4, 4 }, { 30, 4 }, { 4, 26 }, { 30, 26 } }) do
    part(c, c:ellipse(p[1], p[2], 1, 1), R.mari, { cres = 1, gloss = { { p[1], p[2] - 1 } } })
  end
  finish(c)
  save(c, "chai_stall_sign", 35, 31)
end

if #FAILS > 0 then print("FAIL: " .. table.concat(FAILS, ", ")) else print("ALL OK") end
