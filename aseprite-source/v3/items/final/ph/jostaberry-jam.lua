-- jostaberry-jam (final pass, Opus single pass). A slim glass jar of deep purple jostaberry jam standing on a small
-- ground shadow: thick pale glass base and lip, cylinder-lit jam with tiny pale seed flecks, a pale empty headspace
-- under the lid, bright vertical glass streak + glint, cool reflected light on the right rim. Red gingham cloth cap
-- (domed top, check pattern lit per pixel, fold lines, pinked hem) cinched by twisted twine with a bow; kraft paper
-- label wrapping the jar with a little berry sprig and a hand-written line.
-- quirk: a fat drip of jam has escaped from under the cloth and is crawling down the outside of the glass.
local NAME = "jostaberry-jam"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local norm = A.norm
local c = A.new(NAME)
local JAM  = { "#1a0a1c", "#2e1230", "#481a46", "#64265c", "#86407a", "#b46aa0" }
local GL   = { "#4e6e7e", "#7a9eaa", "#a6c8c6", "#cde8e0", "#eafaf2" }
local KRAFT = { "#7a4c2e", "#a87648", "#d0a26c", "#e8c690", "#f8e2b4" }
local TW   = { "#5e3a22", "#8f6234", "#c4964e", "#e8c27a" }
local CLOTH = {
  [0] = { "#fff4d6", "#f2dcc2", "#d6b2a8", "#9c7a86" },
  [1] = { "#ffa088", "#ee7268", "#c4505a", "#8a3448" },
  [2] = { "#ee5240", "#c4343e", "#94283c", "#5e1c34" },
}
local CX = 32
local L = { norm(-0.55, -0.7, 0.55) }

-- ground shadow (under the jar)
c:groundShadow(CX + 1, 56, 15, 1.5)

-- jar profile
local function jhw(y)
  if y < 17 then return nil end
  if y <= 20 then return 9.5 end
  if y == 21 then return 10.5 end
  if y == 22 then return 11.5 end
  if y <= 51 then return 12 end
  if y == 52 then return 11.6 end
  if y == 53 then return 11 end
  if y == 54 then return 10 end
  return nil
end
local jar = HP.mask()
for y = 17, 54 do local h = jhw(y) for x = CX - 13, CX + 13 do if abs(x - CX + 0.5) <= h then jar:set(x, y) end end end
local function cyl(x, y) local h = jhw(y) or 12 local s = max(-0.97, min(0.97, (x - CX + 0.5) / (h + 0.3))) return s end
local function lam(nx, ny, nz) local d = nx * L[1] + ny * L[2] + nz * L[3] return max(0, (d + 0.25) / 1.25) end

local JAMTOP, LAB0, LAB1 = 27, 35, 44
local gtok = { r = { name = "glass" } }
jar:each(function(x, y)
  local s = cyl(x, y)
  local v = lam(s, 0, sqrt(1 - s * s))
  local edge = not (jar:has(x - 1, y) and jar:has(x + 1, y))
  if y >= 52 then -- thick glass base
    local i = y == 52 and 4 or (v > 0.6 and 3 or 2)
    c:put(x, y, GL[i], gtok)
  elseif y <= 20 then -- threaded lip (mostly hidden by cloth)
    c:put(x, y, GL[(y % 2 == 0) and 2 or 3], gtok)
  elseif y < JAMTOP then -- empty headspace: pale glass, inner back wall darker
    local i = v > 0.75 and 4 or v > 0.45 and 3 or 2
    if y == JAMTOP - 1 then i = max(1, i - 1) end
    c:put(x, y, GL[i], gtok)
  else
    local cuts = { 0.12, 0.28, 0.46, 0.64, 0.84 }
    local i = 1 for j, t in ipairs(cuts) do if v >= t then i = j + 1 end end
    if y == JAMTOP then i = min(6, i + 1) end -- meniscus catches light
    if y >= 50 then i = max(1, i - 1) end      -- AO at the bottom inside the base
    c:put(x, y, JAM[i], gtok)
  end
  if edge and y > 20 and y < 52 then c:put(x, y, s < 0 and GL[3] or GL[1], gtok) end
end)
-- seed flecks in the jam
for y = JAMTOP + 2, 50 do for x = CX - 10, CX + 10 do
  if (y < LAB0 or y > LAB1) and X.hash(x, y, 7) < 0.035 then c:put(x, y, "#a8607a", gtok) end end end
-- label (kraft, wraps the cylinder)
jar:each(function(x, y)
  if y >= LAB0 and y <= LAB1 and jar:has(x - 1, y) and jar:has(x + 1, y) then
    local s = cyl(x, y) local v = lam(s, 0, sqrt(1 - s * s))
    local i = v > 0.8 and 5 or v > 0.6 and 4 or v > 0.38 and 3 or v > 0.18 and 2 or 1
    if y == LAB0 or y == LAB1 then i = max(1, i - 2) end
    c:put(x, y, KRAFT[i], gtok)
  end
end)
-- label art: berry sprig + hand-written line
A.map(c, {
  "...g..",
  "..gG..",
  ".bb.cc",
  "bBbcCc",
  ".bb.cc",
}, CX - 4, LAB0 + 2, { g = "#3f9150", G = "#7cc35a", b = "#2e1230", B = "#86407a", c = "#481a46", C = "#b46aa0" }, gtok)
for x = CX - 7, CX + 5 do local y = LAB0 + 8 + ((x % 4 == 0) and 0 or (x % 4 == 2 and 0 or 0))
  if (x % 5) ~= 3 then c:put(x, y, KRAFT[1], gtok) end end
c:put(CX - 8, LAB0 + 7, KRAFT[1], gtok)
-- glass highlight streak + glint, cool reflected light
for y = 23, 51 do if y < LAB0 or y > LAB1 then
  c:put(CX - 8, y, (y < JAMTOP) and GL[5] or JAM[6], gtok)
  if y > 46 or (y > 28 and y < 33) then c:put(CX - 7, y, (y < JAMTOP) and GL[5] or JAM[5], gtok) end
end end
c:put(CX - 8, LAB0 + 2, KRAFT[5], gtok) c:put(CX - 8, LAB0 + 3, KRAFT[5], gtok)
c:put(CX - 8, 29, "#fff4d6", gtok)
for y = 28, 50 do if y < LAB0 or y > LAB1 then c:put(CX + 10, y, "#4a5a9a", gtok) end end

-- cloth cap
local function chw(y)
  local t = { [10] = 5, [11] = 8, [12] = 10, [13] = 11.5, [14] = 12.5, [15] = 12.8, [16] = 13, [17] = 12.6,
    [18] = 11.2, [19] = 10.8, [20] = 12, [21] = 13.2, [22] = 14, [23] = 14.6 }
  return t[y]
end
local cm = HP.mask()
for y = 10, 23 do local h = chw(y) for x = CX - 16, CX + 16 do if abs(x - CX + 0.5) <= h then cm:set(x, y) end end end
-- pinked hem: zigzag points below the last row
for x = CX - 14, CX + 14 do if (x % 3) == 0 then cm:set(x, 24) end end
local ctok = { r = { name = "cloth" } }
cm:each(function(x, y)
  local nx, ny, nz
  if y <= 17 then -- dome
    local u = (x - CX + 0.5) / 13.5 local w = (y - 17) / 7.5
    nx, ny, nz = norm(u * 0.8, w * 0.9, sqrt(max(0.1, 1 - u * u * 0.6 - w * w * 0.6)))
  else
    local h = chw(y) or 14.6 local s = max(-0.95, min(0.95, (x - CX + 0.5) / (h + 0.5)))
    nx, ny, nz = s, 0.15, sqrt(1 - s * s)
  end
  local v = lam(nx, ny, nz)
  local lv = v > 0.72 and 1 or v > 0.48 and 2 or v > 0.26 and 3 or 4
  -- fold lines on the skirt (pleats from the cinch)
  if y >= 21 and ((x - CX) % 5 == 0) then lv = min(4, lv + 1) end
  if y == 18 then lv = min(4, lv + 1) end -- AO above the twine
  if y >= 23 then lv = min(4, lv + 1) end
  -- gingham check (3 px), bands follow the dome a little
  local gx = floor((x - CX + 30) / 3) % 2
  local gy = floor((y + (y <= 17 and floor(abs(x - CX) / 6) or 0)) / 3) % 2
  local cl = gx + gy
  -- weave: diagonal dashes on cream squares
  if cl == 0 and (x + y) % 4 == 0 and lv < 4 then lv = lv + 1 end
  c:put(x, y, CLOTH[cl][lv], ctok)
end)
-- twine (twisted) around the cinch rows 19-20
local ttok = { r = { name = "twine" } }
for y = 19, 20 do for x = CX - 12, CX + 12 do if cm:has(x, y) then
  local s = (x - CX) / 12
  local lit = s < 0.3
  local tw = (x + y) % 3
  c:put(x, y, tw == 0 and TW[1] or (lit and (tw == 1 and TW[4] or TW[3]) or TW[2]), ttok)
end end end
-- bow on the right: two loops + two tails
A.map(c, {
  ".abb.",
  "abcb.",
  "bc.cb",
  "abbXbba",
  "...dbc.b",
  "..ad..cb",
  "..ab...a",
  "..a.....",
}, CX + 9, 16, { a = TW[1], b = TW[3], c = TW[2], d = TW[2], X = TW[4] }, ttok)

-- quirk: jam drip on the outside of the glass (painted over glass, under the cloth hem)
local dtok = { r = { name = "drip" } }
A.map(c, {
  "Ab",
  "Ab",
  "Ab",
  "Ab",
  "Ab",
  "Ab",
  "Ab",
  "Ab",
  "Ab",
  "Ab",
  "Ab",
  "AAb",
  "ACbb",
  "Abbd",
  "Abbd",
  ".dd",
}, CX + 4, 24, { A = JAM[5], b = JAM[3], C = "#fff4d6", d = JAM[2] }, dtok)

A.save(c, NAME)
