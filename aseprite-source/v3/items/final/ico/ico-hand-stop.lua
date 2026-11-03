-- ico-hand-stop (final, Opus). An open hand held straight up, palm to the viewer: four slim fingers pressed together
-- (middle finger longest, little finger short), a thumb splayed out to the lower-left, a rounded palm with a soft
-- thumb mound, a narrow wrist and a blue cloth cuff.
-- Material: skin = pillow light per part snapped to a 6-tone warm ramp, lit fingertip pads, two joint creases per
-- finger (dark row with a lit lip under it), the heart line and the life line round the thumb mound, darker
-- separation lines where fingers press together, AO where the fingers and thumb meet the palm and under the cuff.
-- Cuff = 6-tone sea-blue cloth with diagonal weave, a rolled hem shadow and a gold stitch.
-- quirk: someone has doodled a little smiley on the palm in blue biro.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-hand-stop")
local SK = { "#7a4036", "#a95f48", "#cf8566", "#eaa883", "#f7caa3", "#ffe6c6" }
local CL = { "#22345e", "#2f4f86", "#3f72ae", "#5797cc", "#82bde0", "#bfe4f2" }
local stok, ctok = A.tok("skin"), A.tok("cuff")

-- fingers {x0, x1, tipY}; they run down into the palm (y 31)
local F = { { 20, 24, 15 }, { 25, 29, 11 }, { 30, 34, 13 }, { 35, 38, 19 } }
local palm = HP.rrect(19, 28, 39, 49, 6)
palm:add(HP.rect(20, 30, 38, 46))
local thumb = A.caps(22.5, 44, 12.5, 31.5, 2.6)
local wrist = HP.rect(23, 46, 37, 52)

-- palm (thumb mound bulges lower-left)
local pn = X.pillow(palm:copy():add(wrist), 6)
local mound = A.ell(24.5, 42.5, 5.5, 5.5)
local pbias = {}
local pidx = A.shade(c, palm:copy():add(wrist), pn, SK, { tok = stok, amb = 0.12, wrap = 0.32, bias = pbias, tilt = { 30, 38, 14, 0.05 } })
-- the mound catches light, the cup of the palm sits a touch darker
mound:each(function(x, y) if palm:has(x, y) and (x - 24.5) + (y - 42.5) < 2 then A.step(c, pidx, SK, x, y, 1, stok) end end)
for _, p in ipairs{ { 32, 37 }, { 33, 37 }, { 31, 38 }, { 32, 38 }, { 33, 38 }, { 34, 38 }, { 32, 39 }, { 33, 39 }, { 31, 39 } } do A.step(c, pidx, SK, p[1], p[2], -1, stok) end

-- thumb (in front of the palm edge)
local tidx = A.pill(c, thumb, 2.4, SK, { tok = stok, amb = 0.12, wrap = 0.32 })
-- thumb pad + joint crease
c:put(12, 30, SK[6], stok) c:put(12, 31, SK[5], stok)
for _, p in ipairs{ { 15, 36 }, { 16, 35 }, { 16, 36 }, { 17, 35 } } do A.step(c, tidx, SK, p[1], p[2], -1, stok) end
-- AO on the palm where the thumb crosses it
A.touch(palm:copy():cut(thumb), thumb):each(function(x, y) A.step(c, pidx, SK, x, y, -1, stok) end)

-- fingers
local fm = HP.mask()
local fidx = {}
for i, f in ipairs(F) do
  local m = HP.rrect(f[1], f[3], f[2], 32, 2)
  local idx = A.pill(c, m, 2.2, SK, { tok = stok, amb = 0.12, wrap = 0.32 })
  for k, v in pairs(idx) do fidx[k] = v end
  fm:add(m)
  -- fingertip pad: lit bulge near the tip
  c:put(f[1] + 1, f[3] + 1, SK[6], stok) c:put(f[1] + 1, f[3] + 2, SK[5], stok)
  -- joint creases: dark row, lit lip below
  local L = 31 - f[3]
  for _, j in ipairs{ floor(L * 0.36), floor(L * 0.66) } do
    local y = f[3] + j
    for x = f[1] + 1, f[2] - 1 do A.step(c, fidx, SK, x, y, -1, stok) end
    A.step(c, fidx, SK, f[1] + 1, y + 1, 1, stok)
  end
end
-- fingers press together: the shared edge becomes a dark separation line (skin deep), tips stay apart (ink)
for i = 1, #F - 1 do
  local gx = F[i][2]
  local top = max(F[i][3], F[i + 1][3]) + 3
  for y = top, 31 do c:put(gx, y, SK[2], stok) end
end
-- AO where the fingers meet the palm, and the knuckle-pad row of the palm
for x = 20, 38 do
  if fidx[K(x, 31)] then A.step(c, fidx, SK, x, 31, -1, stok) end
  if pidx[K(x, 33)] and not thumb:has(x, 33) then A.step(c, pidx, SK, x, 33, -1, stok) end
end

-- palm lines: heart line across the top, life line round the mound
local heart = { { 38, 35 }, { 37, 35 }, { 36, 35 }, { 35, 36 }, { 34, 36 }, { 33, 36 }, { 32, 36 }, { 31, 36 }, { 30, 35 }, { 29, 35 } }
for _, p in ipairs(heart) do A.step(c, pidx, SK, p[1], p[2], -2, stok) end
local life = { { 28, 37 }, { 28, 38 }, { 29, 39 }, { 29, 40 }, { 30, 41 }, { 30, 42 }, { 30, 43 }, { 30, 44 }, { 29, 45 } }
for _, p in ipairs(life) do A.step(c, pidx, SK, p[1], p[2], -2, stok) A.step(c, pidx, SK, p[1] - 1, p[2], 1, stok) end

-- cuff: blue cloth, slightly wider than the wrist
local cuff = HP.rrect(20, 50, 40, 57, 1)
local cn = {}
cuff:each(function(x, y)
  local u = (x - 30) / 11
  local ny = y <= 51 and -0.55 or 0.12
  local l = sqrt(u * u + ny * ny + max(0.05, 1 - u * u))
  cn[K(x, y)] = { u / l, ny / l, sqrt(max(0.05, 1 - u * u)) / l }
end)
local cidx = A.shade(c, cuff, cn, CL, { tok = ctok, amb = 0.1, wrap = 0.3 })
cuff:each(function(x, y)
  if (x + y) % 4 == 0 and y > 52 and y ~= 55 then A.step(c, cidx, CL, x, y, -1, ctok) end   -- diagonal weave
  if y == 52 then A.step(c, cidx, CL, x, y, -2, ctok) end                          -- under the rolled hem
end)
-- AO on the wrist just above the cuff
for x = 23, 37 do A.step(c, pidx, SK, x, 49, -1, stok) end
c:stitch{ { 21, 55 }, { 39, 55 } }

-- quirk: a blue biro smiley on the palm
local BIRO = "#3d5fb4"
for _, p in ipairs{ { 33, 40 }, { 36, 40 }, { 32, 42 }, { 33, 43 }, { 34, 43 }, { 35, 43 }, { 36, 42 } } do c:put(p[1], p[2], BIRO, stok) end
-- one glint: 2x1 hi on the lit shoulder of the middle finger
c:put(26, 13, SK[6], stok) c:put(26, 12, "#fff4d6", stok)
A.save(c, "ico-hand-stop")
