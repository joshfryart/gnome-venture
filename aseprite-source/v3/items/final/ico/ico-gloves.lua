-- ico-gloves (final, Opus). One slim gardening glove seen from the back: four separate fingers (5 px, pinky 4 px)
-- with ink gaps between them, a thumb angled out to the left, a rounded back and a green ribbed knit cuff.
-- Material: per-pixel pillow light on each part, snapped to a 6-tone mustard canvas ramp; brown leather fingertip
-- caps with a dark seam row and a tiny sheen; side seams with a lit lip down each finger; knuckle creases; a sparse
-- canvas weave (diagonal tone steps); a 6-tone moss knit cuff with vertical ribs and a rolled top edge; AO where the
-- fingers and thumb meet the back and where the back tucks into the cuff; gold stitch on the cuff hem.
-- quirk: an earthworm has wriggled out of the cuff and is curling away.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA5_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs = math.floor, math.sqrt, math.max, math.min, math.abs
local c = A.new("ico-gloves")
local CAN  = { "#6e3f1f", "#a3621f", "#cf8f2a", "#eab53e", "#f8d468", "#fff0a6" }
local LEA  = { "#3e2420", "#5e3729", "#864c33", "#a86a42", "#c98e5a", "#e8b982" }
local KNIT = { "#1a4838", "#24663e", "#36874a", "#58a850", "#88c75c", "#c2e380" }
local htok, ltok, ktok = A.tok("canvas"), A.tok("leather"), A.tok("knit")

-- fingers: {x0, x1, tipY}; all reach down to the back at y=30
local FING = { { 22, 26, 12 }, { 28, 32, 9 }, { 34, 38, 11 }, { 40, 43, 16 } }
local back = HP.mask()
back:add(HP.rrect(21, 26, 44, 47, 5))
back:add(HP.poly{ { 21, 34 }, { 44, 34 }, { 45, 48 }, { 21, 48 } })
-- thumb: slanted capsule from the back out to the upper-left
local thumb = A.seg(0, 0, 0, 0)
thumb = c:line({ { 22, 41 }, { 17, 35 }, { 14, 29 } }, 5)
thumb:add(A.ell(14.5, 28.5, 2.5, 2.5))

-- back of the hand first (fingers and thumb overlap it)
local bidx = A.pill(c, back, 5, CAN, { tok = htok, amb = 0.1, wrap = 0.3, tilt = { 32, 36, 16, 0.08 } })
-- thumb
local tidx = A.pill(c, thumb, 2.4, CAN, { tok = htok, amb = 0.1, wrap = 0.3 })
-- AO on the back along the thumb's lower-right edge (contact shadow)
-- leather cap on the thumb tip with a seam row
do local tn = X.pillow(thumb, 2.4)
  local cap = HP.mask()
  thumb:each(function(x, y) if (x - 14.5) * 0.55 + (y - 28.5) * 0.85 < 1.2 then cap:set(x, y) end end)
  A.shade(c, cap, tn, LEA, { tok = ltok, amb = 0.12, wrap = 0.3 })
  thumb:each(function(x, y) local d = (x - 14.5) * 0.55 + (y - 28.5) * 0.85
    if d >= 1.2 and d < 2.2 then c:put(x, y, LEA[1], ltok) end end)
  c:put(13, 27, LEA[6], ltok) end
A.touch(back:copy():cut(thumb), thumb):each(function(x, y) A.step(c, bidx, CAN, x, y, -1, htok) end)

local fm = HP.mask()
local fidx = {}
for i, f in ipairs(FING) do
  local m = HP.rrect(f[1], f[3], f[2], 31, 2)
  fm:add(m)
  local idx = A.pill(c, m, 2.3, CAN, { tok = htok, amb = 0.1, wrap = 0.3 })
  for k, v in pairs(idx) do fidx[k] = v end
  -- leather fingertip cap: top 5 px, rounded seam row at its base
  local capY = f[3] + 4
  local cap = m:copy():clip(HP.rect(f[1], f[3], f[2], capY))
  local cn = X.pillow(m, 2.3)
  local cidx = A.shade(c, cap, cn, LEA, { tok = ltok, amb = 0.12, wrap = 0.3 })
  for x = f[1], f[2] do if cap:has(x, capY) then c:put(x, capY, LEA[1], ltok) end end
  -- sheen on the cap
  c:put(f[1] + 1, f[3] + 1, LEA[6], ltok)
  -- side seam: a dark line one pixel inside the right edge, with a lit lip left of it
  for y = capY + 2, 29 do
    if (y % 3) ~= 0 then A.step(c, fidx, CAN, f[2] - 1, y, -1, htok) end
  end
  -- knuckle crease: short 2 px dark mark
  local ky = f[3] + 10 + (i % 2)
  if ky < 28 then A.step(c, fidx, CAN, f[1] + 1, ky, -1, htok) A.step(c, fidx, CAN, f[1] + 2, ky + 1, -1, htok) end
end
-- fingers sit apart: 1 px gaps (become ink) between fingers above the back
for i = 1, #FING - 1 do
  local gx = FING[i][2] + 1
  for y = FING[i][3], 27 do c.pix[y * c.w + gx] = nil c.own[y * c.w + gx] = nil end
end
-- AO where fingers meet the back: the back's top rows under each finger
for _, f in ipairs(FING) do
  for x = f[1], f[2] do A.step(c, bidx, CAN, x, 32, -1, htok) end
  for x = f[1] + 1, f[2] - 1 do A.step(c, fidx, CAN, x, 31, -1, htok) end
end
-- canvas weave: sparse diagonal tone steps on the back
back:each(function(x, y) local k = K(x, y)
  if not fm:has(x, y) and not thumb:has(x, y) and y > 33 and y < 46 then
    if (x + y) % 4 == 0 and X.hash(x, y, 5) < 0.45 then A.step(c, bidx, CAN, x, y, -1, htok) end
  end end)
-- a centre seam on the back running from the middle knuckle down
for y = 35, 45 do if y % 3 ~= 0 then A.step(c, bidx, CAN, 32, y, -1, htok) A.step(c, bidx, CAN, 31, y, 1, htok) end end
-- specular glint: 2x1 hi on the back's upper-left shoulder + cream
c:put(24, 35, CAN[6], htok) c:put(25, 35, CAN[6], htok) c:put(24, 36, "#fff4d6", htok)

-- knit cuff: slightly flared, rolled top edge
local cuff = HP.poly{ { 19.5, 46 }, { 45.5, 46 }, { 47, 57 }, { 18, 57 } }
local cn = {}
cuff:each(function(x, y)
  local u = (x - 32.5) / 15
  local ny = y <= 48 and -0.6 or 0.15
  cn[K(x, y)] = { u, ny, sqrt(max(0.05, 1 - u * u)) }
end)
for k, v in pairs(cn) do local l = sqrt(v[1]^2 + v[2]^2 + v[3]^2) cn[k] = { v[1]/l, v[2]/l, v[3]/l } end
local kidx = A.shade(c, cuff, cn, KNIT, { tok = ktok, amb = 0.1, wrap = 0.3 })
-- roll: dark row under the rolled edge, AO row on the canvas above it
cuff:each(function(x, y)
  if y == 49 then A.step(c, kidx, KNIT, x, y, -2, ktok) end
  if y > 49 and (x % 3) == 0 then A.step(c, kidx, KNIT, x, y, -1, ktok) end          -- ribs
  if y > 49 and (x % 3) == 1 and y % 2 == 0 then A.step(c, kidx, KNIT, x, y, 1, ktok) end
  if y == 56 then A.step(c, kidx, KNIT, x, y, -1, ktok) end
end)
for x = 20, 45 do if bidx[K(x, 45)] then A.step(c, bidx, CAN, x, 45, -1, htok) end end
c:stitch{ { 21, 47 }, { 44, 47 } }

-- quirk: earthworm curling out from under the cuff's lower-right edge
local WM = { a = "#f5a0a8", b = "#d96f86", d = "#9a4060", h = "#ffd0d4" }
A.map(c, {
  "......ha.",
  ".....abbd",
  "aaa.abd..",
  "bbbbbd...",
  ".ddd.....",
}, 41, 53, WM, A.tok("worm"))
A.save(c, "ico-gloves")
