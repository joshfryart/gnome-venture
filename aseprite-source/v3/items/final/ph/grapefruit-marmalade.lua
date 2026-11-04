-- grapefruit-marmalade (aC10_0, Opus single pass). A slim straight-sided glass jar of glowing pink-coral
-- marmalade: contents lit like translucent jelly (bright core, darker rim), suspended peel shreds, a glass rim
-- streak + pale core highlight, cool empty headspace with a meniscus, thick glass foot. Lid hidden under a pinked
-- gingham cloth cap (dome + skirt with fold lines) cinched by twisted twine with a dangling knot. A small kraft
-- label with a grapefruit-wedge mark. Ground shadow under the jar.
-- quirk: a drip of marmalade has escaped from under the cloth and runs down the glass.
local NAME = "grapefruit-marmalade"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC10_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local MARM  = { "#6a1c2e", "#9e2d3c", "#cc4646", "#e86a4f", "#f7955e", "#ffc489" }
local PEEL  = { "#b8562a", "#eaa23e", "#ffd36a" }
local GLASS = { "#4e6f86", "#7fa5b8", "#b2d3dc", "#dcf0f0", "#f4fcf8" }
local CL    = { -- gingham: {cream, pink, crossing} per light level (shade, mid, lit)
  { "#d9b6b0", "#c25f80", "#8e3a62" },
  { "#f6e6d4", "#ec7d9b", "#b9487a" },
  { "#fff4e4", "#ffa6bd", "#d9608f" },
}
local TWINE = { "#7a4a24", "#b5793a", "#e2b366" }
local KRAFT = { "#8f6a44", "#c49a68", "#e6c999" }

local X0, X1 = 22, 42           -- jar body x span (21 px wide)
local YT, YB = 21, 54           -- glass from neck to foot
c:groundShadow(32, 56, 14, 2)

-- glass jar silhouette: straight body, rounded shoulders into a short neck
local body = c:rrect(X0, 25, X1, YB, 3)
local neck = c:rect(X0 + 2, YT, X1 - 2, 26)
local jar = body:copy():add(neck)
-- normals: vertical cylinder
local nrm = {}
jar:each(function(x, y)
  local t = max(-0.97, min(0.97, ((x + 0.5 - X0) / (X1 + 1 - X0)) * 2 - 1))
  nrm[K(x, y)] = { t, 0, sqrt(1 - t * t) }
end)
local v = X.light(nrm, { amb = 0.1, wrap = 0.35 })
local FILL = 30                  -- marmalade surface row
local jtok = { r = { name = "jar" } }
local contents = HP.mask()
jar:each(function(x, y) if y >= FILL and y <= YB - 2 and x > X0 and x < X1 then contents:set(x, y) end end)
local headspace = jar:copy():cut(contents)
-- headspace + glass walls + foot
headspace:each(function(x, y) local k = K(x, y)
  local i = 1 + floor(v[k] * 3.2 + 0.5)
  if y >= YB - 1 then i = max(1, i - 1) end
  c:put(x, y, GLASS[max(1, min(4, i))], jtok)
end)
-- contents: translucent, so the centre glows and the rim goes deep
contents:each(function(x, y) local k = K(x, y)
  local t = ((x + 0.5 - X0) / (X1 + 1 - X0)) * 2 - 1
  local glow = 1 - abs(t + 0.12) ^ 1.6
  local l = 0.55 * glow + 0.45 * v[k]
  local i = 1
  for j, cut in ipairs{ 0.2, 0.36, 0.52, 0.68, 0.84 } do if l >= cut then i = j + 1 end end
  if y == FILL then i = min(6, i + 1) end                                -- meniscus catches light
  if y >= YB - 3 then i = max(1, i - 1) end                              -- darker at the base
  c:put(x, y, MARM[i], jtok)
end)
-- peel shreds suspended in the jelly (short diagonal slivers)
for _, q in ipairs{ { 25, 31, 1, 1 }, { 30, 34, -1, 2 }, { 36, 30, 1, 2 }, { 27, 39, 1, 1 }, { 34, 41, -1, 1 },
                    { 38, 37, -1, 1 }, { 24, 46, 1, 2 }, { 31, 48, 1, 1 }, { 37, 47, -1, 2 }, { 29, 43, -1, 1 } } do
  local x, y, d, col = q[1], q[2], q[3], q[4]
  for i = 0, 2 do local px, py = x + i * d, y + (i == 2 and 1 or 0)
    if contents:has(px, py) then c:put(px, py, i == 0 and PEEL[col + 1] or PEEL[col], jtok) end end
end
-- glass cues: bright left rim streak, pale core highlight, dark right wall, thick foot line
for y = 25, YB - 2 do c:put(X0, y, GLASS[4], jtok) c:put(X1, y, GLASS[1], jtok) end
for y = 29, 49 do if y ~= 37 and y ~= 38 then c:put(X0 + 2, y, MARM[6], jtok) end end
for y = 30, 44 do c:put(X0 + 3, y, (y % 5 == 0) and MARM[6] or MARM[5], jtok) end
c:put(X0 + 2, 30, GLASS[5], jtok) c:put(X0 + 2, 31, GLASS[5], jtok)
for x = X0 + 1, X1 - 1 do c:put(x, YB - 1, (x < 30) and GLASS[3] or GLASS[2], jtok) c:put(x, YB, GLASS[1], jtok) end
c:put(X0 + 1, YB, GLASS[2], jtok)
-- reflected cool light on the right of the contents
for y = 32, 48 do c:put(X1 - 1, y, (y % 4 == 0) and MARM[2] or MARM[3], jtok) end

-- label: small kraft oval with a grapefruit wedge
local lab = c:rrect(28, 38, 39, 45, 2)
local ltok = { r = { name = "label" } }
lab:each(function(x, y) c:put(x, y, (x >= 38 or y >= 45) and KRAFT[1] or ((x <= 29 or y <= 38) and KRAFT[3] or KRAFT[2]), ltok) end)
lab:edge():each(function(x, y) c:put(x, y, KRAFT[1], ltok) end)
local wedge = { "..rrrr..", ".rppppr.", "rpwpwppr", "rrrrrrrr" }
local wmap = { r = "#f2c24a", p = "#ef6f86", w = "#ffd3dc" }
for j, row in ipairs(wedge) do for i = 1, 8 do local ch = row:sub(i, i)
  if wmap[ch] then c:put(29 + i, 38 + j, wmap[ch], ltok) end end end

-- gingham cloth cap: dome over the lid + flaring pinked skirt
local cap = c:ellipse(32, 15, 11, 4)
local skirt = c:poly{ { 20, 15 }, { 44, 15 }, { 46, 22 }, { 18, 22 } }
skirt:add(c:rect(20, 15, 44, 19))
for x = 18, 46 do if (x % 3) == 1 then skirt:set(x, 23) end end   -- pinked hem teeth
local cloth = cap:copy():add(skirt)
cloth:cut(c:rect(0, 23, 64, 23):cut(skirt))
local cn = X.pillow(cloth, 3)
local cv = X.light(cn, { amb = 0.15, wrap = 0.3 })
local ctok = { r = { name = "cloth" } }
cloth:each(function(x, y) local k = K(x, y)
  local l = cv[k]
  local lv = (l > 0.72) and 3 or ((l > 0.42) and 2 or 1)
  if y >= 17 and ((x - 18) % 6 == 5) then lv = max(1, lv - 1) end      -- skirt folds
  if y >= 20 and x >= 41 then lv = 1 end
  local sx = ((x - 18) // 2) % 2 == 0
  local sy = ((y - 9) // 2) % 2 == 0
  local p = (sx and sy) and 3 or ((sx or sy) and 2 or 1)
  c:put(x, y, CL[lv][p], ctok)
end)
-- AO on the glass right under the skirt
for x = X0 + 2, X1 - 2 do if not cloth:has(x, 24) then c:put(x, 24, GLASS[1], jtok) end end
-- twine twisted around the neck, over the cloth
local ttok = { r = { name = "twine" } }
for x = 20, 44 do
  c:put(x, 18, ((x % 2) == 0) and TWINE[3] or TWINE[2], ttok)
  c:put(x, 19, ((x % 2) == 1) and TWINE[2] or TWINE[1], ttok)
end
-- knot and dangling ends
for _, q in ipairs{ { 26, 18, 3 }, { 27, 18, 2 }, { 26, 19, 2 }, { 27, 19, 1 }, { 25, 20, 2 }, { 25, 21, 1 }, { 24, 22, 2 },
                    { 24, 23, 1 }, { 28, 20, 2 }, { 28, 21, 2 }, { 29, 22, 1 }, { 29, 23, 2 }, { 29, 24, 1 } } do
  c:put(q[1], q[2], TWINE[q[3]], ttok)
end

-- quirk: a marmalade drip escaping from under the cloth, down the right side of the glass
local dtok = { r = { name = "drip" } }
for _, q in ipairs{ { 38, 24, 4 }, { 39, 24, 3 }, { 38, 25, 5 }, { 39, 25, 3 }, { 38, 26, 5 }, { 39, 26, 3 },
                    { 39, 27, 3 }, { 38, 28, 5 }, { 39, 28, 3 }, { 40, 28, 2 }, { 38, 29, 4 }, { 39, 29, 3 }, { 40, 29, 2 } } do
  c:put(q[1], q[2], MARM[q[3]], dtok)
end
c:put(38, 26, MARM[6], dtok)
c:put(38, 30, MARM[2], dtok) c:put(39, 30, MARM[1], dtok) c:put(40, 30, MARM[1], dtok)
G.save2(c, NAME)
