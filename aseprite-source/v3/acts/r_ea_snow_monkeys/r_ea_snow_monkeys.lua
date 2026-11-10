-- act-r_ea_snow_monkeys (v3 Hearth Pop 2.5D): a gnome soaks in a snowy hot spring with three snow monkeys.
-- Motion: snow falls, steam rises off the water, rings ripple round the bathers, a yuzu bobs.
-- quirk: the middle monkey wears a little snow cap; a yuzu floats by.
local DIR = (debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")) or "."
local A = dofile(DIR .. "/../actlib.lua")
local P, HP = A.P, A.HP
local floor = math.floor

local G = A.gnome{ view = "front", hat = "#e8493b", tunic = "#3a86b0", skip = { shadow = true } }
local SNOW, SNOW2, SNOW3 = "#f4fbff", "#dbe9f4", "#b9cfe4"
local FUR = { hi = "#dccbb4", base = "#b9a48f", shade = "#8a7468", deep = "#5a4650" }
local FACE = { hi = "#ff9c8a", base = "#e8786a", shade = "#c4505e" }
local WAT = { hi = "#b6f0e0", base = "#5fc4c8", shade = "#3a9cb8", deep = "#2a6e98" }
local WL = 74   -- water line

local function bg(c)
  c:stripes(10, 44, { "#b9cfe4", "#c9dbec", "#d8e6f2", "#e4eef7" })
  c:terrain(function(x) return 36 + math.abs(((x + 10) % 46) - 23) * .45 end, "#c9d9ea", 50)
  c:terrain(function(x) return 36 + math.abs(((x + 10) % 46) - 23) * .45 + 3 end, "#aec3da", 50)
  for y = 46, 99 do for x = 10, 137 do c:put(x, y, y < 52 and SNOW2 or SNOW) end end
  for i = 1, 26 do
    local x, y = 12 + floor(A.hash(i, 1, 6) * 120), 50 + floor(A.hash(i, 2, 6) * 46)
    c:put(x, y, SNOW2) c:put(x + 1, y, SNOW2)
  end
  A.pine(c, 22, 60, 44, { snow = true })
  A.pine(c, 122, 62, 46, { snow = true })
  A.pine(c, 106, 52, 26, { snow = true })
end

local pool = HP.ellipse(74, 79, 58, 16)
local water = HP.ellipse(74, 79, 52, 12)

local function spring(c, f)
  -- stone ring: rounded rocks with snow caps
  A.mfill(c, pool, P.stone.shade)
  for i = 0, 25 do
    local a = i / 26 * math.pi * 2
    local x, y = floor(74 + math.cos(a) * 56 + .5), floor(79 + math.sin(a) * 14.5 + .5)
    local r = 3 + floor(A.hash(i, 3, 2) * 2)
    local rock = HP.ellipse(x, y, r + 1, r)
    c:rim(rock, P.stone.deep)
    rock:each(function(px, py)
      local col = P.stone.base
      if px - x + py - y > 1 then col = P.stone.shade end
      if px - x + py - y < -2 then col = P.stone.hi end
      c:put(px, py, col)
    end)
    if y < 79 then for px = x - r + 1, x + r - 1 do c:put(px, y - r, SNOW) c:put(px, y - r + 1, (px % 3 == 0) and SNOW2 or SNOW) end end
  end
  -- water
  water:each(function(x, y)
    local col = WAT.base
    if y <= 69 then col = WAT.shade end
    if y >= 88 then col = WAT.shade end
    c:put(x, y, col)
  end)
  -- light dashes drifting right on the water (loop 6 frames)
  for r = 0, 3 do
    local y = 76 + r * 3
    for x = 26, 124 do
      if water:has(x, y) and (x - f - r * 4) % 12 < 3 then c:put(x, y, WAT.hi) end
    end
  end
end

local function ripple(c, f, cx, cy, ph)
  local r = ((f + ph) % 3) * 2 + 9
  for dx = -r, r do
    local y = cy + floor(math.sqrt(math.max(0, 1 - (dx / r) ^ 2)) * 3 + .5)
    if water:has(cx + dx, y) and (dx + f) % 3 ~= 0 then c:put(cx + dx, y, WAT.hi) end
  end
end

local function monkey(c, cx, top, capped, look)
  -- head 15 wide, ears, red heart face, shoulders down into the water
  local head = HP.ellipse(cx, top + 7, 8.5, 8)
  local ears = HP.ellipse(cx - 9, top + 8, 2, 2.5):add(HP.ellipse(cx + 9, top + 8, 2, 2.5))
  local body = HP.ellipse(cx, top + 19, 10, 6):clip(HP.rect(cx - 12, 0, cx + 12, WL - 1))
  local all = head:copy():add(ears):add(body)
  local face = HP.ellipse(cx, top + 10, 5.5, 4.5):add(HP.ellipse(cx - 3, top + 6, 3, 2.5)):add(HP.ellipse(cx + 3, top + 6, 3, 2.5))
  c:rim(all, P.ink, HP.rect(0, 0, 200, WL - 1))
  all:each(function(x, y)
    if y < WL then
      local col = FUR.base
      if (x - cx) + (y - top - 7) > 7 then col = FUR.shade end
      if (x - cx) + (y - top - 7) < -8 then col = FUR.hi end
      if (x * 3 + y) % 7 == 0 and col == FUR.base then col = FUR.shade end
      c:put(x, y, col)
    end
  end)
  ears:each(function(x, y) c:put(x, y, FACE.shade) end)
  face:each(function(x, y) c:put(x, y, (x > cx + 2 or y > top + 11) and FACE.shade or FACE.base) end)
  c:put(cx - 3, top + 6, FACE.hi) c:put(cx - 2, top + 6, FACE.hi)
  -- eyes (2x2 ink with a glint), nostrils, mouth
  local ex = look or 0
  c:put(cx - 2 + ex, top + 8, P.ink) c:put(cx - 2 + ex, top + 9, P.ink)
  c:put(cx + 2 + ex, top + 8, P.ink) c:put(cx + 2 + ex, top + 9, P.ink)
  c:put(cx - 2 + ex, top + 8, "#fff4d6")
  c:put(cx - 1, top + 11, FACE.shade) c:put(cx + 1, top + 11, FACE.shade)
  c:put(cx, top + 12, "#7d2c5e")
  -- crown fur tuft
  c:put(cx - 1, top - 1, FUR.base) c:put(cx, top - 1, FUR.hi) c:put(cx, top - 2, P.ink) c:put(cx - 1, top - 2, P.ink)
  if capped then
    local cap = HP.ellipse(cx, top + 1, 6, 2.5):clip(HP.rect(cx - 7, top - 3, cx + 7, top + 2))
    c:rim(cap, "#8bc4ea")
    cap:each(function(x, y) c:put(x, y, (y == top - 1 or x < cx - 2) and SNOW or SNOW2) end)
  end
end

return A.run("r_ea_snow_monkeys", function(f)
  local c = A.canvas("r_ea_snow_monkeys")
  bg(c)
  spring(c, f)
  -- gnome soaks on the left: everything above the water line
  A.stamp(c, G, 6, 20, { clip = function(x, y) return y < WL end })
  c:fillMask(HP.rect(20, WL, 54, WL), WAT.hi)
  monkey(c, 70, 52, false, 0)
  monkey(c, 93, 49, true, -1)
  monkey(c, 116, 54, false, -1)
  for x = 60, 124 do if water:has(x, WL) and (x % 4 ~= 0) then c:put(x, WL, WAT.hi) end end
  ripple(c, f, 38, 76, 0) ripple(c, f, 70, 77, 1) ripple(c, f, 93, 76, 2) ripple(c, f, 116, 78, 1)
  -- yuzu bobbing
  local bob = ({ 0, 0, 1, 1, 1, 0 })[f + 1]
  local yz = HP.ellipse(52, 84 + bob, 2, 2)
  c:rim(yz, "#8f4a1f")
  yz:each(function(x, y) c:put(x, y, (x < 52 and y < 84 + bob) and "#ffe38a" or "#f5b82e") end)
  c:put(52, 81 + bob, "#3f9150")
  -- steam wisps rising off the water
  for i, x in ipairs({ 30, 58, 82, 104, 120 }) do A.steam(c, f, x, 72 - (i % 2) * 2, 20, i, { "#f4fbff", "#dbe9f4" }) end
  A.snow(c, f, { n = 14, seed = 3, col = SNOW, col2 = SNOW2 })
  return c
end)
