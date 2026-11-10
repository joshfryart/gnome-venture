-- act-r_esa_rift_cichlids (v3 Hearth Pop 2.5D): a gnome sits on a jetty over a clear rift lake full of bright cichlids.
-- Motion: the fish hover and flick their tails, bubbles rise, the surface shimmers.
-- quirk: one small fish swims the other way.
local DIR = (debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")) or "."
local A = dofile(DIR .. "/../actlib.lua")
local P, HP = A.P, A.HP
local floor = math.floor

local G = A.gnome{ view = "front", hat = "#e8493b", tunic = "#7cc35a", scarf = "#f5b82e", skip = { shadow = true, boots = true } }
local WAT = { hi = "#c9f4ea", top = "#8adbd8", base = "#5fc4c8", shade = "#45a8c0", deep = "#3a86b0" }

local function bg(c, f)
  c:stripes(10, 40, { P.sky.base, "#c9eaf8", P.sky.hi }, { 3, 3, 3 })
  c:cloud(92, 22, 24, "#fff4d6", P.sky.hi)
  c:cloud(120, 30, 14, "#fff4d6", P.sky.hi)
  -- rift wall far away, then green hills
  c:terrain(function(x) return 30 + (x > 70 and (x - 70) * .12 or 0) + math.sin(x / 6) * 1.2 end, "#9cb8c4", 44)
  c:terrain(function(x) return 38 + math.sin(x / 10) * 2.5 end, "#8fc66a", 46)
  c:terrain(function(x) return 42 + math.sin((x + 9) / 14) * 2 end, "#6db552", 46)
  -- lake
  for y = 46, 88 do for x = 10, 137 do
    local col = y < 50 and WAT.top or (y < 64 and WAT.base or (y < 78 and WAT.shade or WAT.deep))
    c:put(x, y, col)
  end end
  -- surface shimmer drifting right (6 px period)
  for _, y in ipairs({ 47, 49 }) do
    for x = 10, 133 do if (x - f + y) % 12 < 3 then c:put(x, y, WAT.hi) end end
  end
  -- light rays on the water body
  for i = 0, 3 do
    local x0 = 60 + i * 18
    for y = 52, 84 do local x = x0 - floor((y - 52) * .35) if (y % 4) ~= 0 then c:put(x, y, y < 64 and "#78d2d0" or (y < 78 and "#55b6c6" or "#4294ba")) end end
  end
  -- sandy bed with rocks
  c:terrain(function(x) return 88 + math.sin(x / 7) * 1.2 end, "#e8c992", 99)
  for x = 10, 137 do local y = floor(88 + math.sin(x / 7) * 1.2 + .5) c:put(x, y, "#f6e2b6") end
  for i, r in ipairs({ { 22, 92, 6, 4 }, { 74, 93, 7, 4 }, { 118, 91, 7, 5 }, { 96, 95, 4, 3 }, { 48, 95, 4, 2 } }) do
    local m = HP.ellipse(r[1], r[2], r[3], r[4])
    c:rim(m, P.stone.deep)
    m:each(function(x, y)
      local col = P.stone.base
      if (x - r[1]) + (y - r[2]) * 1.5 > 2 then col = P.stone.shade end
      if (x - r[1]) + (y - r[2]) * 1.5 < -4 then col = P.stone.hi end
      c:put(x, y, col)
    end)
    c:put(r[1] - 2, r[2] - r[4] + 1, "#7cc35a") c:put(r[1] - 1, r[2] - r[4], "#3f9150")
  end
end

local function dock(c)
  for _, px in ipairs({ 14, 34, 52 }) do
    c:fillMask(HP.rect(px, 66, px + 3, 86), P.wood.deep)
    c:fillMask(HP.rect(px, 66, px, 86), P.wood.shade)
  end
  local deck = HP.rect(10, 60, 60, 65)
  c:rim(deck, P.ink, HP.rect(10, 10, 137, 99))
  deck:each(function(x, y)
    local col = P.wood.base
    if y == 60 then col = P.wood.hi elseif y >= 64 then col = P.wood.shade end
    if (x - 10) % 8 == 0 and y < 64 then col = P.wood.shade end
    c:put(x, y, col)
  end)
end

local FISH = {
  { x = 74, y = 58, dir = 1, r = { hi = "#ffe38a", base = "#f5b82e", shade = "#d98322", deep = "#8f4a1f" }, st = "#3f6ac0", ph = 0 },
  { x = 104, y = 54, dir = -1, r = { hi = "#9cc8ff", base = "#3f7fd6", shade = "#2f58a8", deep = "#253a78" }, st = "#ffe38a", ph = 2 },
  { x = 120, y = 70, dir = -1, r = { hi = "#ffb48a", base = "#ff7a3a", shade = "#d9502a", deep = "#8a2a2a" }, st = "#fff4d6", ph = 4 },
  { x = 86, y = 76, dir = 1, r = { hi = "#ff8a8a", base = "#e8493b", shade = "#b52e3f", deep = "#6e2038" }, st = "#ffe38a", ph = 1 },
  { x = 46, y = 80, dir = 1, r = { hi = "#c4e07a", base = "#5fc48a", shade = "#3a9070", deep = "#24544a" }, st = "#ffe38a", ph = 3 },
  { x = 64, y = 70, dir = -1, small = true, r = { hi = "#ffc4d8", base = "#f5809f", shade = "#c94f84", deep = "#7d2c5e" }, st = "#fff4d6", ph = 5 },
}

local function fish(c, F, f)
  local dx = floor(math.sin((f + F.ph) * math.pi / 3) * 2 + .5)
  local cx, cy, d = F.x + dx, F.y, F.dir
  local L = F.small and 4 or 6
  local H = F.small and 2 or 3
  local body = HP.ellipse(cx, cy, L, H)
  local flick = ((f + F.ph) % 2 == 0) and 1 or 0
  local tx = cx - d * (L + 1)
  local tail = HP.poly{ { tx + d, cy }, { tx - d * 3, cy - 3 + flick }, { tx - d * 3, cy + 3 + flick } }
  local fin = HP.poly{ { cx - d * 2, cy - H }, { cx + d * 2, cy - H - 2 }, { cx + d * 3, cy - H } }
  local all = body:copy():add(tail):add(fin)
  c:rim(all, P.ink)
  all:each(function(x, y)
    local col = F.r.base
    if y > cy then col = F.r.shade end
    if y < cy - 1 and x * d < (cx - 0) * d then col = F.r.hi end
    if not body:has(x, y) then col = F.r.shade end
    c:put(x, y, col)
  end)
  -- stripes
  for k = -1, 1 do local sx = cx - d * k * 3 for y = cy - H + 1, cy + H - 1 do if body:has(sx, y) and not F.small then c:put(sx, y, F.st) end end end
  -- eye
  c:put(cx + d * (L - 2), cy - 1, P.ink)
  c:put(cx + d * (L - 1), cy, F.r.deep)
end

return A.run("r_esa_rift_cichlids", function(f)
  local c = A.canvas("r_esa_rift_cichlids")
  bg(c, f)
  -- bubbles rising from the rocks (loop: 2 px per frame, 12 px apart)
  A.lanes{ lanes = { { x = 76, ph = 0 }, { x = 117, ph = 5 }, { x = 24, ph = 9 } }, ytop = 52, L = 36, s = 2, D = 12, f = f,
    sway = function(y, li) return floor(math.sin(y / 3 + li) + .5) end,
    put = function(x, y) c:put(x, y, WAT.hi) if y % 3 == 0 then c:put(x + 1, y, WAT.top) end end }
  for _, F in ipairs(FISH) do fish(c, F, f) end
  dock(c)
  -- gnome sits on the jetty edge: legs hang over the front, boots dangle
  A.stamp(c, G, 0, 1, { clip = function(x, y) return y < 61 end })
  local sw = ({ 0, 1, 1, 0, 0, 0 })[f + 1]
  for _, bx in ipairs({ 26, 37 }) do
    local o = (bx == 26) and sw or 0
    local leg = HP.rect(bx + 1, 66, bx + 5, 69)
    local boot = HP.rect(bx + o, 70, bx + 6 + o, 73)
    c:rim(leg:copy():add(boot), P.ink)
    leg:each(function(x, y) c:put(x, y, x == bx + 5 and "#2a4a7a" or "#3a86b0") end)
    boot:each(function(x, y) c:put(x, y, (y == 70 and x < bx + 4 + o) and P.wood.hi or (y == 73 and P.wood.shade or P.wood.base)) end)
  end
  return c
end)
