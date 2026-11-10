-- act-w3_politest_bow (v3 Hearth Pop 2.5D): two gnomes bow to each other in front of a red gate.
-- Motion: the bow itself. The left gnome dips from the hip and comes back up; the right gnome answers a beat later.
-- quirk: a gold star plaque on the gate.
local DIR = (debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")) or "."
local A = dofile(DIR .. "/../actlib.lua")
local P, HP = A.P, A.HP

local LA = { 0, 12, 24, 30, 20, 8 }   -- left gnome bow angle per frame (degrees)
local RA = { 0, 4, 12, 20, 24, 12 }   -- right gnome answers a beat later
local GL = A.gnome{ view = "side", hat = "#3f7fd6", tunic = "#e8493b", scarf = "#f5b82e" }
local GR = A.gnome{ view = "side", hat = "#f5b82e", tunic = "#5fc4c8", scarf = "#c94f84" }
local cacheL, cacheR = {}, {}

local function bg(c)
  -- sky: flat bands, light near the horizon
  c:stripes(10, 52, { P.sky.base, "#c9eaf8", P.sky.hi }, { 3, 3, 4 })
  c:cloud(18, 26, 22, "#fff4d6", P.sky.hi)
  c:cloud(100, 20, 16, "#fff4d6", P.sky.hi)
  -- far hills (low contrast) and mid hills
  c:terrain(function(x) return 44 + math.sin(x / 13) * 3 + math.sin(x / 5) * 1 end, "#a9d48a", 60)
  c:terrain(function(x) return 52 + math.sin((x + 30) / 17) * 3 end, "#8fc66a", 62)
  -- grass field
  for y = 58, 99 do for x = 10, 137 do
    local col = y < 66 and "#7cc35a" or (y < 80 and "#6db552" or "#5fa84a")
    c:put(x, y, col)
  end end
  -- grass tufts
  for i = 1, 40 do
    local x, y = 12 + math.floor(A.hash(i, 1, 4) * 120), 62 + math.floor(A.hash(i, 2, 4) * 34)
    c:put(x, y, "#c4e07a") c:put(x + 1, y - 1, "#c4e07a") c:put(x + 2, y, "#3f9150")
  end
  -- path: from the gate down to the front, widening
  local path = c:poly{ { 66, 70 }, { 88, 70 }, { 114, 100 }, { 38, 100 } }
  A.mfill(c, path, "#e8c992")
  c:rim(path, "#c99a62", c:rect(10, 58, 137, 99))
  for i = 1, 14 do
    local x, y = 50 + math.floor(A.hash(i, 9, 2) * 54), 74 + math.floor(A.hash(i, 8, 2) * 22)
    if path:has(x, y) and path:has(x + 2, y) then c:put(x, y, "#c99a62") c:put(x + 1, y, "#c99a62") c:put(x, y - 1, "#f6e2b6") end
  end
  -- pines behind
  A.pine(c, 22, 66, 36, {})
  A.pine(c, 124, 68, 40, {})
  A.pine(c, 112, 62, 26, {})
end

local function gate(c)
  local R = { hi = "#ff8a5c", base = "#e8493b", shade = "#b52e3f", deep = "#6e2038" }
  local posts = c:rect(53, 24, 56, 74):add(c:rect(98, 24, 101, 74))
  local beam = c:rect(47, 31, 107, 33)
  local top = c:poly{ { 40, 17 }, { 114, 17 }, { 111, 22 }, { 43, 22 } }
  local plq = c:rect(73, 22, 81, 31)
  local all = posts:copy():add(beam):add(top):add(plq)
  c:rim(all, P.ink)
  -- posts: lit left column, shade right
  posts:each(function(x, y)
    local lx = (x - 53) % 45
    c:put(x, y, lx == 0 and R.hi or (lx == 3 and R.shade or R.base))
  end)
  beam:each(function(x, y) c:put(x, y, y == 31 and R.hi or (y == 33 and R.shade or R.base)) end)
  top:each(function(x, y) c:put(x, y, y == 17 and "#5e4a5c" or (y >= 21 and P.ink or "#4a3646")) end)
  -- post feet (stone)
  c:fillMask(c:rect(52, 73, 57, 75), P.stone.shade) c:fillMask(c:rect(97, 73, 102, 75), P.stone.shade)
  c:fillMask(c:rect(52, 73, 57, 73), P.stone.base) c:fillMask(c:rect(97, 73, 102, 73), P.stone.base)
  -- plaque with gold star
  plq:each(function(x, y) c:put(x, y, (x == 73 or y == 22) and "#fff4d6" or "#f6e6b8") end)
  c:paint({
    "...g...",
    "..ggg..",
    "ggGGGgg",
    ".gGGGg.",
    ".gg.gg.",
  }, 74, 24, { g = P.gold.base, G = P.gold.hi })
end

return A.run("w3_politest_bow", function(f)
  local c = A.canvas("w3_politest_bow")
  bg(c)
  gate(c)
  local la, ra = LA[f + 1], RA[f + 1]
  cacheL[la] = cacheL[la] or A.bend(GL, 33, 61, la, 5)
  cacheR[ra] = cacheR[ra] or A.bend(GR, 33, 61, ra, 5)
  -- feet baseline y=71 in the cell -> ground y 93
  A.stamp(c, cacheL[la], 6, 22)
  A.stamp(c, cacheR[ra], 76, 22, { flip = true })
  return c
end)
