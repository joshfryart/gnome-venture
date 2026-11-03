-- bought-garden-vegetable-soup (final, Opus aB10). A slim tin can standing upright. Per-pixel vertical-cylinder light:
-- tinplate (6-tone cool steel) with a rolled lid lip (bright rim upper-left), recessed lid with a groove ring and a
-- pull-tab ring, ribbed body bands top and bottom, a specular streak and cool reflected light on the right edge.
-- Wrapped paper label: tomato-red bands with a gold rule, cream panel with a carrot, pea pod and tomato, and "SOUP"
-- in red; the label shades with the cylinder. Ground shadow.
-- quirk: a shop price sticker, slapped on crooked, one corner peeling up.
local NAME = "bought-garden-vegetable-soup"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local c = A.new(NAME)
local TIN = { "#3b3d5a", "#5a5d7c", "#7e8098", "#a4a6b8", "#cbcdd8", "#eceaf0" }
local RED = { "#5e1c30", "#8e2636", "#bc3236", "#e04a3a", "#f47454", "#ffa07a" }
local CRM = { "#9a7e78", "#c4aa94", "#e2cdb0", "#f6e6c6", "#fff4d6" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local BOUNCE = "#8a9cc8"

local CX, R = 31.5, 13          -- body spans 19..44
local TOPY, BOTY = 15, 50       -- lid centre row, bottom ellipse centre row
local RY = 4
c:groundShadow(32, BOTY + 3, 16, 2)

-- per-column light for an upright cylinder (index into a ramp of n tones)
local function colV(x)
  local nx = (x - CX) / (R + 0.5)
  local nz = sqrt(max(0.02, 1 - nx*nx))
  local v = X.light({ [1] = { nx, -0.05, nz } }, { amb = 0.12, wrap = 0.3 })[1]
  return v, nx
end
local function pick(ramp, v, shift)
  local n = #ramp
  local i = floor(v * n * 0.98) + 1 + (shift or 0)
  return ramp[max(1, min(n, i))], max(1, min(n, i))
end

-- body: rect + bottom half-ellipse
local body = c:rect(19, TOPY, 44, BOTY):add(c:ellipse(CX, BOTY, 12.5, RY))
local btok, ltok = { r = { name = "tin" } }, { r = { name = "label" } }
local L0, L1 = 23, 43   -- label rows
body:each(function(x, y)
  local v, nx = colV(x)
  -- ribs on the metal bands: groove row + lit row
  local sh = 0
  local rib = { [20] = 1, [21] = -1, [46] = -1, [47] = 1, [BOTY] = -1 }
  if rib[y] then sh = rib[y] end
  if y == L0 - 1 or y == L1 + 1 then sh = sh - 1 end          -- label edge AO on the tin
  if y > BOTY then sh = sh - 1 end                               -- rolled bottom rim
  if y >= L0 and y <= L1 then
    local col
    if y <= L0 + 3 or y >= L1 - 3 then col = pick(RED, v, (y == L0 + 3 or y == L1 - 3) and -1 or 0)
      if y == L0 + 3 or y == L1 - 3 then col = pick(GOLD, v) end
    else col = pick(CRM, v) end
    c:put(x, y, col, ltok)
  else
    c:put(x, y, (pick(TIN, v, sh)), btok)
  end
end)
-- specular streak (vertical) on the tin bands + paper sheen on the label
for y = TOPY + 2, BOTY do
  local onLab = y >= L0 and y <= L1
  if not onLab then c:put(23, y, TIN[6], btok) c:put(24, y, TIN[5], btok)
  elseif y > L0 + 3 and y < L1 - 3 then c:put(23, y, CRM[5], ltok) end
end
-- cool reflected light on the right edge
for y = TOPY + 3, BOTY - 1 do if not (y >= L0 and y <= L1) then c:put(44, y, BOUNCE, btok) end end

-- lid: rolled lip ring + recessed lid + groove + pull tab
local lid = c:ellipse(CX, TOPY, 12.5, RY)
local inner = c:ellipse(CX, TOPY + 0.3, 10.5, RY - 1.2)
local ltk = { r = { name = "lid" } }
lid:each(function(x, y)
  local dx, dy = (x - CX) / 12.5, (y - TOPY) / RY
  if inner:has(x, y) then
    local g = ((x - CX) / 7) ^ 2 + ((y - TOPY - 0.3) / 2.1) ^ 2
    local t = 4
    if g > 0.7 and g < 1.3 then t = (dy < 0) and 2 or 5 end         -- groove ring: shaded far side, lit near side
    if dy < -0.35 and g >= 1.3 then t = 3 end                          -- inner wall under the far lip
    c:put(x, y, TIN[t], ltk)
  else
    c:put(x, y, (dx + dy * 0.6 < 0.1) and ((dy < 0) and TIN[6] or TIN[5]) or (dx > 0.55 and TIN[3] or TIN[4]), ltk)
  end
end)
-- pull tab: rivet + elongated ring lying toward the right
A.map(c, 28, 13, {
  ".DDDDD..",
  "Dhs.ssD.",
  "DsR.ssD.",
  ".DDDDD..",
}, { D = TIN[2], h = TIN[6], s = TIN[5], R = TIN[3] }, ltk)
c:put(29, 14, TIN[6], ltk)

-- label art: carrot, pea pod, tomato (flat icons, dimmed on the shade side)
local function art(rows, x0, y0, cm)
  for yy, row in ipairs(rows) do for xx = 1, #row do local ch = row:sub(xx, xx)
    if cm[ch] then local x = x0 + xx - 1 local v = colV(x)
      local col = cm[ch]
      if v < 0.45 and cm[ch .. "d"] then col = cm[ch .. "d"] end
      c:put(x, y0 + yy - 1, col, ltok) end end end
end
art({ -- carrot (leafy top, leaning)
  ".g.g",
  "..gG",
  ".oO.",
  ".oo.",
  "oO..",
  "o...",
}, 21, 27, { g = "#7cc35a", G = "#3f9150", o = "#ee6c22", O = "#fb983a", gd = "#3f9150", od = "#c45224" })
art({ -- pea pod
  "..gG",
  ".GpP",
  "GpPg",
  "gPg.",
  "Gg..",
}, 26, 28, { g = "#7cc35a", G = "#3f9150", p = "#c4e07a", P = "#9dd06c", gd = "#3f9150", Gd = "#24544a", pd = "#7cc35a", Pd = "#6ab455" })
art({ -- tomato
  ".gGg.",
  "rRrrr",
  "rhrrr",
  "rrrrd",
  ".rrd.",
}, 31, 28, { g = "#7cc35a", G = "#3f9150", r = "#e8493b", R = "#ff8a5c", h = "#ffc4a8", d = "#b52e3f", rd = "#b52e3f", gd = "#3f9150", Rd = "#e8493b", hd = "#e8493b" })
-- "SOUP" 3x4 letters in red
local FONT = {
  S = { "###", "#..", ".##", "###" }, O = { "###", "#.#", "#.#", "###" },
  U = { "#.#", "#.#", "#.#", "###" }, P = { "###", "#.#", "###", "#.." },
}
local tx = 22
for _, ch in ipairs{ "S", "O", "U", "P" } do
  art((function() local r = {} for i, row in ipairs(FONT[ch]) do r[i] = row:gsub("#", "r") end return r end)(),
    tx, 34, { r = RED[3], rd = RED[2] })
  tx = tx + 4
end
-- a small leaf flourish to the right of the word
art({ ".g", "gG" }, 38, 35, { g = "#7cc35a", G = "#3f9150", gd = "#3f9150", Gd = "#24544a" })

-- quirk: crooked price sticker on the upper tin band / label, top-right corner peeling
local ptok = { r = { name = "sticker" } }
A.map(c, 34, 18, {
  "yyyyyw.",
  "ykkkyBw",
  "yyyyyf.",
  "yykyyy.",
  "YYYYYY.",
}, { y = "#ffb648", Y = "#e68a2a", k = "#7a2c2c", w = "#fff4d6", B = "#d6c8b4", f = "#5a5d7c" }, ptok)

A.save(c, NAME)
