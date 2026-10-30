-- shops/SE-items.lua : Cat Fish pet shop SE "The Olive Pantry Pets" (Olivewhistle Shore, South Europe), 5 room items.
-- Run: AppRun -b --script SE-items.lua     Writes art22/out/cf-pet-<slug>.png + .aseprite
--   amphora              shelf       20x24  two-handled terracotta jar on a foot, Aegean-blue glaze band
--   terracotta_catgrass  sill        30x26  wide terracotta pot, blue band with cream wave, fan of catgrass
--   mosaic_mat           floor-right 36x28  felt mat seen in perspective, blue tile border, terracotta fish
--   lemon_on_a_string    rod         16x16  felt lemon with an olive leaf, hung from a short string stub
--   siesta_fan           ceiling     48x34  open folding fan, cream/terracotta pleats, blue edge, gold tassel
-- Shared regional look: terracotta + Aegean blue + whitewash cream + olive green + lemon, felt ramps (4 steps).
-- Shown at 1x on the 320x200 room like the cats and cf-yarn-*: so 1 px three-tone umber outline (ol=1) and the
-- 1 px #000000 border (sticker mode). Strings are bare 1 px umber like the room's fish strings (border removed).
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../../gvlib/gvlib.lua")
local OUT = here .. "/../out/"
local floor, atan2, sqrt, pi = math.floor, math.atan, math.sqrt, math.pi

local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  n.deep, n.bounce = n.shade, n.base
  for k, v in pairs(ov or {}) do n[k] = v end
  return n
end
-- shared SE palette
local TERRA = felt("#c8643c", { gloss = "#ffb27a", dot = "#ffd9a0", rim = "#e08850" })
local BLUE  = felt("#2f6fb8", { gloss = "#9fd0f0", rim = "#5a94d0" })
local CREAM = felt("#f1ece0")
local OLIVE = felt("#7d8f34", { gloss = "#d8e08a", rim = "#a4b44e" })
local GRASS = felt("#7ab55c", { gloss = "#d8ec9a", rim = "#a4d070" })
local LEMON = felt("#f2cc2e", { gloss = "#fff6b0", dot = "#fffbe0", rim = "#ffe066", shade = "#d0921e" })
local WOOD  = felt("#b07a45")
local GOLD  = felt("#e8a317")

-- remap pixels of mask m painted in ramp a to the same tone of ramp b
local function remap(c, m, a, b)
  m:each(function(x, y)
    local v = c:get(x, y)
    for _, t in ipairs({ "base", "rim", "shade", "deep", "bounce", "gloss", "dot" }) do
      if v == a[t] then c:px(x, y, b[t]) return end
    end
  end)
end
-- finish (outline + border), then strip black border pixels whose only art neighbours are string pixels
local function strings(c, list)
  c:finish()
  local str = {}
  for _, p in ipairs(list) do str[c:key(p[1], p[2])] = true end
  for y = 0, c.H - 1 do for x = 0, c.W - 1 do
    local k = c:key(x, y)
    if c.pix[k] == "#000000" then
      local art, only = false, true
      for _, d in ipairs({ {1,0}, {-1,0}, {0,1}, {0,-1} }) do
        local kn = c:key(x + d[1], y + d[2])
        local v = c.pix[kn]
        if v and v ~= "#000000" then art = true if not str[kn] then only = false end end
      end
      if art and only then c.pix[k] = nil end
    end
  end end
end
local FAILS = {}
local function save(c, slug, W, H)
  local name = "cf-pet-" .. slug
  local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
  print(string.format("%-28s ", name) .. GV.report(t))
  if not (t.semi == 0 and t.bw == 0 and t.w == W and t.h == H) then FAILS[#FAILS + 1] = name end
end
local function canvas(w, h, o)
  o = o or {}
  return GV.canvas{ w = w, h = h, mode = "sticker", ol = 1, olx = 0, cres = o.cres or 2, deep = o.deep or 2, margin = 0 }
end

-- ===== amphora (shelf, 20x24) =====
do
  local c = canvas(20, 24)
  local body = c:ellipse(9.5, 12.5, 5.5, 6):add(c:poly({ {6, 16}, {14, 16}, {12, 20}, {8, 20} }))
  local neck = c:rect(7, 4, 12, 8)
  local lip  = c:rrect(5, 2, 14, 4, 1)
  local hL   = c:line({ {7, 6}, {3, 6}, {3, 10}, {4, 11} }, 2)
  local hR   = c:line({ {12, 6}, {16, 6}, {16, 10}, {15, 11} }, 2)
  local foot = c:rrect(6, 20, 13, 21, 1)
  c:build{
    { "hL",   hL, TERRA, { flat = true } },
    { "hR",   hR, TERRA, { flat = true } },
    { "foot", foot, TERRA, { flat = true } },
    { "body", body, TERRA, { cres = 3, deep = 1, gloss = false } },
    { "neck", neck, TERRA, { flat = true, contour = false } },
    { "lip",  lip, TERRA, { flat = true } },
  }
  -- Aegean-blue glaze band round the belly with cream dots (painted, follows the belly curve)
  for x = 4, 15 do for y = 12, 14 do
    if body:has(x, y) and body:has(x, y + 1) or (y == 14 and body:has(x, y)) then
      local v = c:get(x, y)
      local sh = (v == TERRA.shade or v == TERRA.deep)
      if y == 12 or y == 14 then c:px(x, y, sh and BLUE.shade or BLUE.base) end
      if y == 13 then c:px(x, y, (x % 2 == 0) and (sh and "#d8cfb8" or CREAM.base) or (sh and BLUE.shade or BLUE.base)) end
    end
  end end
  c:paint({ "gg", "g." }, 6, 8, { g = TERRA.gloss })                 -- enamel comma on the shoulder
  c:px(7, 9, TERRA.dot)
  c:px(6, 10, TERRA.gloss)
  c:paint({ "ddddd" }, 7, 3, { d = TERRA.shade })                     -- mouth opening
  c:paint({ "uuuu" }, 8, 3, { u = "ol3" })
  save(c, "amphora", 20, 24)
end

-- ===== lemon on a string (rod, 16x16) =====
do
  local c = canvas(16, 16)
  local lemon = c:ellipse(7.5, 10, 5, 3.6):add(c:rect(2, 9, 13, 10))
  local leaf = c:poly({ {8, 4}, {12, 3}, {14, 4}, {11, 7}, {8, 6} })
  c:build{
    { "leaf",  leaf, OLIVE, { flat = true } },
    { "lemon", lemon, LEMON, { cres = 2, deep = 1, gloss = false } },
  }
  c:paint({ "ggg", "gd." , "g.."}, 4, 7, { g = LEMON.gloss, d = LEMON.dot })
  c:px(11, 5, OLIVE.shade); c:px(10, 5, OLIVE.shade)                  -- leaf vein
  c:px(7, 6, "#4a2c1a")                                               -- stem nub
  local S = {}
  for y = 0, 5 do c:px(7, y, "#4a2c1a"); S[#S + 1] = { 7, y } end     -- string stub (bare 1 px umber)
  strings(c, S)
  save(c, "lemon_on_a_string", 16, 16)
end

-- ===== terracotta catgrass (sill, 30x26) =====
-- Pass 1: the grass is one spiky clump (slim tapering blades, 3 px at the root, 1 px tip) so it reads as
-- catgrass, not as the shelf's fat succulent; blade edges are 1 px shade lines inside the clump.
do
  local c = canvas(30, 26)
  local rim = c:rrect(5, 14, 24, 16, 1)
  local pot = c:poly({ {6, 17}, {24, 17}, {22, 24}, {8, 24} })
  -- blades {root x, tip x, tip y}
  -- pass 2: tips spread wider and at more varied heights so the top is a fan of points, not a hedge
  local B = { {7, 2, 7}, {9, 5, 2}, {11, 9, 4}, {12, 11, 0}, {15, 15, 3}, {17, 18, 0}, {18, 21, 4}, {20, 24, 2}, {22, 27, 7} }
  local clump = c:rect(7, 12, 22, 14)
  for _, b in ipairs(B) do
    clump:add(c:poly({ {b[1] - 1, 15}, {b[1] + 2, 15}, {b[2] + 1, b[3]}, {b[2], b[3]} }))
    clump:add(c:line({ {b[1], 14}, {b[2], b[3]} }, 1))
  end
  c:build{
    { "grass", clump, GRASS, { cres = 3, deep = 1, gloss = false } },
    { "pot",   pot, TERRA, { cres = 3, deep = 1, gloss = false } },
    { "rim",   rim, TERRA, { flat = true } },
  }
  -- blade lines: the right edge of each blade in shade, tips light
  for _, b in ipairs(B) do
    local n = 14 - b[3]
    for t = 0, n do
      local x = floor(b[1] + 1 + (b[2] - b[1]) * t / n + 0.5)
      local y = 14 - t
      if t > 2 and clump:has(x + 1, y) and clump:has(x, y) and c:get(x, y) ~= "#2a1a10" then c:px(x, y, GRASS.shade) end
    end
    if clump:has(b[2], b[3]) then c:px(b[2], b[3], GRASS.gloss) end
  end
  -- blue glaze band with a cream wave
  for x = 7, 23 do for y = 19, 21 do
    if pot:has(x, y) then
      local v = c:get(x, y)
      local sh = (v == TERRA.shade or v == TERRA.deep)
      local wave = (y == 20 and (x % 4 == 1 or x % 4 == 3)) or (y == 19 and x % 4 == 2) or (y == 21 and x % 4 == 0)
      c:px(x, y, wave and (sh and "#d8cfb8" or CREAM.base) or (sh and BLUE.shade or BLUE.base))
    end
  end end
  c:paint({ "gggg", "gd.." }, 7, 15, { g = TERRA.gloss, d = TERRA.dot })  -- gloss on the lit rim
  save(c, "terracotta_catgrass", 30, 26)
end

-- ===== mosaic mat (floor-right, 36x28) =====
-- Pass 1: taller top face so the tiles read at 1x; outer ring of 2x2 blue tiles with cream grout and
-- terracotta corner tiles, cream field with a big terracotta fish and two olive sprigs, blue felt front edge
-- with a gold hem stitch.
do
  local c = canvas(36, 28, { cres = 2, deep = 1 })
  local mat = c:rrect(2, 9, 33, 25, 3)
  c:build{ { "mat", mat, CREAM, { cres = 2, deep = 1, gloss = false } } }
  local top = c:rrect(2, 9, 33, 22, 3)
  local inner = c:rrect(6, 12, 29, 19, 1)
  local GR = "#ddd2bb"
  top:each(function(x, y)
    if inner:has(x, y) then return end
    local v = c:get(x, y)
    local lit = (v == CREAM.rim)
    local gx, gy = (x - 2) % 3 == 0, (y - 9) % 3 == 0
    local corner = (x < 6 or x > 29) and (y < 12 or y > 19)
    if gx or gy then c:px(x, y, lit and CREAM.rim or GR)
    else c:px(x, y, corner and TERRA.base or BLUE.base) end
  end)
  -- tile glints on the lit (upper-left) tile of each blue tile
  top:each(function(x, y)
    if not inner:has(x, y) and (x - 2) % 3 == 1 and (y - 9) % 3 == 1 and x < 18 and c:get(x, y) == BLUE.base then c:px(x, y, BLUE.rim) end
  end)
  -- field shade at the lower right of the cream
  inner:each(function(x, y) if (not inner:has(x + 2, y + 2)) and x > 20 then c:px(x, y, "#ddd2bb") end end)
  -- front edge (felt thickness) in blue felt with a gold hem stitch
  for x = 2, 33 do for y = 23, 25 do if mat:has(x, y) then c:px(x, y, (y == 25 or x > 29) and BLUE.shade or BLUE.base) end end end
  for x = 4, 31 do if (x % 3) ~= 2 then c:px(x, 24, (x > 29) and GV.C.goldS or GV.C.gold) end end
  -- fish motif (terracotta, umber eye, cream glint)
  c:paint({
    "....ttt.....",
    "..ttttttt..t",
    ".ttttttttttt",
    "tetttttttt.t",
    ".tttttssss.t",
    "..ttsssss..s",
  }, 12, 13, { t = TERRA.base, s = TERRA.shade, e = "#2a1a10" })
  c:px(14, 14, TERRA.gloss); c:px(15, 14, TERRA.gloss)
  -- olive sprigs at the field ends
  c:paint({ ".o.", "o.o", ".o.", "o.." }, 7, 13, { o = OLIVE.base })
  c:paint({ ".o.", "o.o", ".o.", "..o" }, 26, 14, { o = OLIVE.base })
  save(c, "mosaic_mat", 36, 28)
end

-- ===== siesta fan (ceiling, 48x34) =====
do
  local c = canvas(48, 34, { cres = 3, deep = 1 })
  local PX, PY = 23.5, 27
  local leafM, stick = c:mask(), c:mask()
  for y = 0, 33 do for x = 0, 47 do
    local dx, dy = x - PX, PY - y
    local r = sqrt(dx * dx + dy * dy)
    if dy >= -0.5 and r <= 20.5 then
      if r >= 9 then leafM:set(x, y) else stick:set(x, y) end
    end
  end end
  local guard = c:rrect(21, 24, 26, 30, 2)
  c:build{
    { "stick", stick, WOOD, { flat = true } },
    { "leaf",  leafM, CREAM, { cres = 3, deep = 1, gloss = false } },
    { "guard", guard, WOOD, { flat = true } },
  }
  -- pleats: 12 sectors, alternate cream / terracotta; blue band on the outer 2 px
  local function ang(x, y) return atan2(PY - y, x - PX) end
  leafM:each(function(x, y)
    local a = ang(x, y)
    local i = floor(a / (pi / 12))
    local dx, dy = x - PX, PY - y
    local r = sqrt(dx * dx + dy * dy)
    local v = c:get(x, y)
    local function tone(R)
      if v == CREAM.shade or v == CREAM.deep then return R.shade elseif v == CREAM.rim then return R.rim end
      return R.base
    end
    if r > 18.6 then c:px(x, y, tone(BLUE))
    elseif i % 2 == 1 then c:px(x, y, tone(TERRA)) end
  end)
  -- stick lines between sectors on the wood
  stick:each(function(x, y)
    local a = ang(x, y)
    local f = (a / (pi / 12)) % 1
    local i = floor(a / (pi / 12))
    if c:get(x, y) == WOOD.base and i % 2 == 1 then c:px(x, y, WOOD.shade) end
  end)
  -- gold seam where the blue edge band is sewn to the pleats (pass 2)
  leafM:each(function(x, y)
    local dx, dy = x - PX, PY - y
    local r = sqrt(dx * dx + dy * dy)
    if r > 18.1 and r <= 18.6 + 0.0 and floor(ang(x, y) * 20) % 3 ~= 2 then c:px(x, y, x > 30 and GV.C.goldS or GV.C.gold) end
  end)
  -- gloss comma on the lit upper-left of the leaf
  c:paint({ "..gg", ".gd.", "g..." }, 11, 10, { g = "#fff3c8", d = "#fffbe0" })
  -- pivot rivet + tassel
  c:paint({ ".kk.", "kgkk", "kkks", ".ss." }, 22, 26, { k = GOLD.base, g = GOLD.gloss, s = GOLD.shade })
  local tas = c:rect(22, 30, 25, 32)
  c:part(tas, GOLD, { flat = true, contour = false })
  c:px(23, 31, GOLD.shade); c:px(25, 31, GOLD.shade)
  -- hanging string: from the top edge to the top of the fan
  local S = {}
  for y = 0, 5 do c:px(23, y, "#4a2c1a"); S[#S + 1] = { 23, y } end
  strings(c, S)
  save(c, "siesta_fan", 48, 34)
end

if #FAILS > 0 then print("FAIL: " .. table.concat(FAILS, ", ")) else print("all OK") end
