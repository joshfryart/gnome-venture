-- act-w5_bathers_hats (v3 Hearth Pop 2.5D): four gnomes soak in an outdoor pool, each keeping a silly hat on.
-- Hats: a folded towel on a gnome hat, an upside-down flowerpot with a sprout, a straw sun hat, a drooping hat with a duck.
-- Motion: the bathers bob out of step, steam rises, rings ripple out, the duck nods.
-- quirk: the flowerpot's sprout has one new leaf.
local DIR = (debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")) or "."
local A = dofile(DIR .. "/../actlib.lua")
local P, HP = A.P, A.HP
local floor = math.floor

local WAT = { hi = "#b6f0e0", base = "#5fc4c8", shade = "#3a9cb8", deep = "#2a6e98" }
local NOHAT = { shadow = true, hat = true, trim = true }

-- bather sprites (cell coords, front view)
local B1 = A.gnome{ view = "front", hat = "#e8493b", tunic = "#3a86b0", skip = { shadow = true } }
do -- folded towel draped on the hat
  A.spaint(B1, {
    "....kkkkkkkkkkkk....",
    "..kkTTTTTTTTTTTTkk..",
    ".kTTtTTTTTTTTTtTTTk.",
    "kTTTTTTTTTTTTTTTTTTk",
    "ksssssssssssssssssk.",
    ".kTTTTTTTTTTTTTTTk..",
    "..kkkkkkkkkkkkkkk...",
  }, 22, 18, { k = P.ink, T = "#e4f6ff", t = "#fff4d6", s = "#8bc4ea" })
end
local B2 = A.dropOrphanInk(A.gnome{ view = "front", tunic = "#7cc35a", beard = "#d98322", skip = NOHAT }, 37)
do -- upside-down terracotta flowerpot
  local rows = {}
  for j = 0, 18 do
    local half = 9 + floor(j * 6 / 18)
    local r = string.rep(".", 16 - half) .. "k" .. string.rep(j == 18 and "R" or (j >= 15 and "r" or (j % 7 == 3 and "d" or "m")), half * 2 - 1) .. "k"
    rows[#rows + 1] = r
  end
  rows[#rows + 1] = "......" .. string.rep("k", 23)
  for j, r in ipairs(rows) do
    for i = 1, #r do
      local ch = r:sub(i, i)
      if ch ~= "." then
        local x = 17 + i - 1
        local col = ({ k = P.ink, m = "#d9703a", d = "#b8502e", r = "#f08a4a", R = "#8a3a2a" })[ch]
        if ch == "m" and x < 26 then col = "#f08a4a" elseif ch == "m" and x > 40 then col = "#b8502e" end
        A.sput(B2, x, 19 + j - 1, col)
      end
    end
  end
  -- sprout from the drain hole (quirk: one new leaf)
  A.spaint(B2, {
    "..gg.....",
    ".gGgk.gg.",
    "..kgkgGg.",
    "....kk...",
    "....k....",
  }, 28, 14, { g = "#7cc35a", G = "#c4e07a", k = "#3f9150" })
end
local B3 = A.dropOrphanInk(A.gnome{ view = "front", tunic = "#e8493b", beard = "#74758c", skip = NOHAT }, 37)
do -- straw sun hat: wide brim, low crown, red ribbon
  for y = 20, 37 do for x = 6, 58 do
    local crown = (y >= 22 and y <= 33 and x >= 20 and x <= 44 and not ((y == 22) and (x == 20 or x == 44)))
    local brim = (y >= 32 and y <= 36 and ((x - 32) / 26) ^ 2 + ((y - 34) / 2.6) ^ 2 <= 1)
    if crown or brim then
      local col = ((x + y) % 3 == 0) and "#d9a84a" or "#f5d27a"
      if brim and y == 36 then col = "#b88a3a" end
      if crown and (y == 29 or y == 30) then col = (x < 24) and "#ff8a5c" or "#e8493b" end
      if crown and x >= 41 and y < 29 then col = "#d9a84a" end
      A.sput(B3, x, y, col)
    end
  end end
  -- ink outline round the hat
  local add = {}
  for y = 19, 38 do for x = 5, 59 do
    local k = A.K(x, y)
    local function hat(xx, yy) local v = B3.p[A.K(xx, yy)] return v and v ~= P.ink and yy <= 37 and (xx < 15 or xx > 50 or yy < 34) end
    if not B3.p[k] and (hat(x + 1, y) or hat(x - 1, y) or hat(x, y + 1) or hat(x, y - 1)) then add[#add + 1] = { x, y } end
  end end
  for _, p in ipairs(add) do A.sput(B3, p[1], p[2], P.ink) end
end
local B4 = A.gnome{ view = "front", hat = "#3f7fd6", tunic = "#f5b82e", beard = "#fff4d6", skip = { shadow = true } }

local function duck(c, x, y, nod)
  local m = HP.ellipse(x, y, 4, 3):add(HP.ellipse(x + 3, y - 3 + nod, 2.5, 2.5))
  c:rim(m, P.ink)
  m:each(function(px, py) c:put(px, py, (px < x and py < y) and "#ffe38a" or "#f5b82e") end)
  c:put(x + 6, y - 3 + nod, "#ff8a5c") c:put(x + 7, y - 3 + nod, "#e8493b")
  c:put(x + 4, y - 4 + nod, P.ink)
end

return A.run("w5_bathers_hats", function(f)
  local c = A.canvas("w5_bathers_hats")
  c:stripes(10, 44, { P.sky.base, "#c9eaf8", P.sky.hi })
  c:cloud(86, 24, 26, "#fff4d6", P.sky.hi)
  c:cloud(20, 30, 16, "#fff4d6", P.sky.hi)
  c:terrain(function(x) return 38 + math.sin(x / 12) * 4 end, "#8fc66a", 52)
  c:terrain(function(x) return 46 + math.sin((x + 20) / 16) * 3 end, "#6db552", 56)
  for y = 52, 99 do for x = 10, 137 do c:put(x, y, y < 60 and "#7cc35a" or "#6db552") end end
  for i = 1, 30 do local x, y = 12 + floor(A.hash(i, 1, 5) * 120), 54 + floor(A.hash(i, 2, 5) * 44) c:put(x, y, "#c4e07a") c:put(x + 1, y - 1, "#3f9150") end
  -- stone pool
  local pool = HP.ellipse(72, 80, 62, 21)
  local water = HP.ellipse(72, 80, 56, 16)
  c:rim(pool, P.stone.deep)
  pool:each(function(x, y) c:put(x, y, (y > 88) and P.stone.shade or P.stone.base) end)
  for i = 0, 29 do
    local a = i / 30 * math.pi * 2
    local x, y = floor(72 + math.cos(a) * 59 + .5), floor(80 + math.sin(a) * 18.5 + .5)
    c:put(x, y, P.stone.deep) c:put(x + 1, y - 1, P.stone.hi)
  end
  water:each(function(x, y) c:put(x, y, (y <= 67 or y >= 93) and WAT.shade or WAT.base) end)
  for r = 0, 3 do local y = 84 + r * 3 for x = 18, 128 do if water:has(x, y) and (x + f - r * 5) % 12 < 3 then c:put(x, y, WAT.hi) end end end
  -- bathers, bobbing out of step; the water line stays put
  local WL = 82
  local BOB = { { 0, 0, 1, 1, 1, 0 }, { 1, 1, 0, 0, 0, 1 }, { 0, 1, 1, 0, 0, 0 }, { 1, 0, 0, 0, 1, 1 } }
  local list = { { B1, -3 }, { B2, 24 }, { B3, 51 }, { B4, 78 } }
  for i, b in ipairs(list) do
    local oy = WL - 56 + BOB[i][f + 1] - ((i % 2 == 0) and 2 or 0)
    A.stamp(c, b[1], b[2], oy, { clip = function(_, y) return y < WL end })
  end
  -- duck on the blue hat's brim
  duck(c, 118, 56 + BOB[4][f + 1] - 2, (f % 3 == 0) and 0 or 1)
  -- water line and ripples round each bather
  for x = 16, 128 do if water:has(x, WL) and (x % 5 ~= 0) then c:put(x, WL, WAT.hi) end end
  for i, cx in ipairs({ 30, 57, 84, 111 }) do
    local cxx = cx
    local r = ((f + i) % 3) * 2 + 12
    for dx = -r, r do
      local y = WL + 2 + floor(math.sqrt(math.max(0, 1 - (dx / r) ^ 2)) * 2 + .5)
      if water:has(cxx + dx, y) and (dx + f) % 3 ~= 0 and A.ainside(cxx + dx, y) then c:put(cxx + dx, y, WAT.hi) end
    end
  end
  for i, x in ipairs({ 18, 46, 98, 128 }) do A.steam(c, f, x, 76, 22, i, { "#f4fbff", "#e4f6ff" }) end
  return c
end)
