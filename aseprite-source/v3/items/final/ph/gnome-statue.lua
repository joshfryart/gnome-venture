-- gnome-statue (B3, Opus single pass, replaces the Sonnet draft). A slim carved stone gnome (tall pointed hat with a
-- tip bending right, rolled hat band, closed smiling eyes, big round nose, moustache, long fluted beard, coat with a
-- belt and buckle, arms at the sides) on a warm sandstone plinth (bevelled cap, recessed panel, base slab).
-- Material: cool blue-grey stone vs warm sandstone, 6 tones each, per-pixel pillow light per carved part, chisel
-- grooves on the beard and hat, speckle grit, a hairline crack on the column, moss in the hat band and on the cap,
-- AO where parts meet, ground shadow.
-- quirk: a robin has landed on the plinth to keep the gnome company.
local NAME = "gnome-statue"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB34_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new(NAME)

local ST = { "#33344f", "#4f5170", "#717390", "#9798ad", "#bcbccb", "#e0dfe8" }
local PL = { "#4a3438", "#6e5250", "#957566", "#b89a82", "#d6bea0", "#efdcc0" }
local MS = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }
local CX = 32

c:groundShadow(CX, 56, 16, 1)

local function grit(m, seed, amt)
  m:each(function(x, y) if X.hash(x, y, seed) > (amt or 0.92) then A.shift(c, x, y, -1) end end)
end

-- plinth: base slab, column, cap
local base = c:rrect(18, 52, 46, 55, 1)
A.pil(c, base, PL, 1.5, { cuts = CUTS })
local col = c:rect(21, 47, 43, 51)
local bias = {}
for x = 21, 43 do bias[K(x, 47)] = -2 end                       -- AO under the cap
A.tone(c, col, A.vnorm(col, 21, 43, 0), PL, { bias = bias, cuts = CUTS })
-- recessed panel
for x = 26, 38 do A.shift(c, x, 48, -2) A.shift(c, x, 50, 1) end
for y = 48, 50 do A.shift(c, 26, y, -2) A.shift(c, 38, y, 1) end
-- hairline crack down the column
for _, p in ipairs{ { 40, 47 }, { 40, 48 }, { 41, 49 }, { 41, 50 }, { 40, 51 } } do A.shift(c, p[1], p[2], -2) end
grit(col, 3, 0.93)
local cap = c:rrect(19, 44, 45, 46, 1)
A.pil(c, cap, PL, 1.2, { cuts = CUTS })
for x = 20, 44 do A.shift(c, x, 44, 1) end                         -- lit top edge
grit(base, 5, 0.94)

-- gnome (cool stone). feet
local feet = c:ellipse(28, 43, 3, 1):add(c:ellipse(36, 43, 3, 1))
A.pil(c, feet, ST, 1.5, { cuts = CUTS })
A.sep(c, feet, 2)
-- arms (behind body edges)
local armL = c:poly{ { 26, 29 }, { 28, 30 }, { 25, 39 }, { 23, 38 } }
local armR = c:poly{ { 38, 29 }, { 36, 30 }, { 39, 39 }, { 41, 38 } }
A.pil(c, armL, ST, 1.5, { cuts = CUTS })
A.pil(c, armR, ST, 1.5, { cuts = CUTS })
-- coat
local coat = c:poly{ { 27, 27 }, { 37, 27 }, { 40, 43 }, { 24, 43 } }
local cb = {}
for x = 24, 40 do cb[K(x, 43)] = -1 end
local _ = A.pil(c, coat, ST, 3, { bias = cb, cuts = CUTS })
A.sep(c, coat, 2)
-- hands
local hands = c:ellipse(24, 39, 1.5, 1.5):add(c:ellipse(40, 39, 1.5, 1.5))
A.pil(c, hands, ST, 1.2, { cuts = CUTS })
A.sep(c, hands, 2)
-- belt + buckle
for x = 24, 40 do if coat:has(x, 38) then A.shift(c, x, 38, -2) end if coat:has(x, 39) then A.shift(c, x, 39, -1) end end
for x = 31, 33 do A.setp(c, x, 38, ST, x == 31 and 6 or 5) A.setp(c, x, 39, ST, 4) end
A.setp(c, 32, 38, ST, 2)
-- coat hem fold lines
for _, p in ipairs{ { 29, 41 }, { 29, 42 }, { 35, 41 }, { 35, 42 } } do A.shift(c, p[1], p[2], -1) end
grit(coat, 7, 0.95)

-- face
local face = c:ellipse(32, 23, 5, 3)
A.pil(c, face, ST, 2, { cuts = CUTS })
A.sep(c, face, 2)
-- beard: long, fluted, to a point
local beard = c:poly{ { 26, 25 }, { 38, 25 }, { 37, 31 }, { 33, 38 }, { 31, 38 }, { 27, 31 } }
local bn = X.pillow(beard, 3)
local bb = {}
beard:each(function(x, y)
  local h = 39 - y
  local f = (x - 32) / max(1, h * 0.55)
  if y > 26 and abs((f * 4) - floor(f * 4 + 0.5)) < 0.12 then bb[K(x, y)] = -1 end
end)
A.tone(c, beard, bn, ST, { bias = bb, cuts = CUTS })
A.sep(c, beard, 2)
A.contact(c, beard, 1, 1, 1)
-- moustache
local mo = c:ellipse(29.5, 26, 2.5, 1):add(c:ellipse(34.5, 26, 2.5, 1))
A.pil(c, mo, ST, 1.2, { cuts = { 0.15, 0.3, 0.45, 0.62, 0.8 } })
A.sep(c, mo, 2)
-- nose: round, lit tip, dark underside
local nose = c:ellipse(32, 24, 2, 1.6)
A.tone(c, nose, X.sphere(32, 24, 2, nose), ST, { cuts = CUTS })
A.sep(c, nose, 2)
for x = 31, 33 do A.shift(c, x, 26, -1) end
c:put(31, 23, "#f2f0f6")
-- closed, smiling carved eyes
for _, e in ipairs{ { 28, 22 }, { 29, 21 }, { 30, 22 }, { 34, 22 }, { 35, 21 }, { 36, 22 } } do c:put(e[1], e[2], "#2b1c26") end
for _, e in ipairs{ { 29, 22 }, { 35, 22 } } do A.setp(c, e[1], e[2], ST, 5) end

-- hat: tall cone, tip bending right
local hat, hn = HP.mask(), {}
local HB, HT = 19, 7
for y = HT, HB do
  local t = (HB - y) / (HB - HT)
  local cxl = CX + 4.5 * t ^ 2.6
  local w = 6.6 * (1 - t) ^ 0.85 + 0.3
  for x = floor(cxl - w - 1), floor(cxl + w + 1) do
    local u = (x - cxl) / (w + 0.5)
    if abs(u) <= 1 then hat:set(x, y) hn[K(x, y)] = A.norm(u, -0.35, sqrt(max(0.05, 1 - u * u))) end
  end
end
local hb = {}
X.ao(hb, hat, face, 1, -1)
-- chisel grooves around the cone
hat:each(function(x, y) if (y == 12 or y == 15) then hb[K(x, y)] = (hb[K(x, y)] or 0) - 1 end end)
A.tone(c, hat, hn, ST, { bias = hb, cuts = CUTS })
-- rolled hat band
local band = c:rrect(25, 18, 39, 20, 1)
local bdb = {}
for x = 25, 39 do bdb[K(x, 20)] = -1 end
A.tone(c, band, A.vnorm(band, 25, 39, -0.2), ST, { bias = bdb, cuts = CUTS })
A.sep(c, band, 2)
A.contact(c, band, 0, 1, 1)
grit(hat, 11, 0.95)
-- moss: in the hat band crease and on the cap
for _, p in ipairs{ { 26, 20, 2 }, { 27, 20, 3 }, { 28, 20, 2 }, { 27, 19, 4 } } do c:put(p[1], p[2], MS[p[3]]) end
for _, p in ipairs{ { 20, 44, 3 }, { 21, 44, 4 }, { 22, 44, 3 }, { 21, 45, 2 }, { 20, 45, 1 }, { 23, 44, 2 } } do c:put(p[1], p[2], MS[p[3]]) end
-- stone specular on the hat
c:put(29, 14, ST[6]) c:put(29, 15, ST[6])

-- quirk: a robin perched on the plinth cap, looking up at the gnome
local map = {
  "..bBB...",
  ".bBBeB..",
  "kRRBBBbt",
  ".rRRbbtt",
  "..r.d...",
  "..l.l...",
}
local BC = { B = "#a8683f", b = "#7a4a33", e = "#2b1c26", k = "#d98322", R = "#ef6a3c", r = "#b8403a", t = "#5e3530", d = "#7a4a33", l = "#5e3530" }
local bx, by = 41, 38
for yy, row in ipairs(map) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if BC[ch] then c:put(bx + xx - 1, by + yy - 1, BC[ch]) end end end
c:put(bx + 3, by, "#c98d55")
c:put(bx + 1, by + 2, "#ff9a6a")

A.save(c, NAME)
