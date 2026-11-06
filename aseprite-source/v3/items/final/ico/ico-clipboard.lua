-- ico-clipboard (final pass, Opus). A slim upright hardwood clipboard with a bevelled edge, a cream checklist
-- sheet (two bold green ticks, one empty box), and a steel spring clip on top.
-- Material: wood pillow bevel + wavy grain lines and a knot; steel clip with bevel, bright top edge, specular
-- streak and a dark eye; paper lies flat with AO under the clip and a contact shadow on the board.
-- quirk: a faint coffee-cup ring on the sheet.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA2_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, sin, abs = math.floor, math.max, math.min, math.sqrt, math.sin, math.abs
local c = A.new("ico-clipboard")
local WOOD = { "#51302b", "#6e3f2e", "#864c33", "#a3653e", "#b97a4a", "#dca674" }
local PAP  = { "#8f7584", "#bba39f", "#dccab4", "#ecdcc0", "#f8ebcf", "#fff4d6" }
local MET  = { "#35344f", "#4c4e6c", "#74758c", "#9fa0b2", "#cfcedb", "#eeedf3" }
local MOSS = { "#24544a", "#2f7747", "#47964d", "#7cc35a", "#b6dd78" }
local LINE = { "#8a8aa0", "#b0afc0" }
local wt, pt, mt = A.tok("board"), A.tok("paper"), A.tok("clip")

-- board
local B = c:rrect(16, 10, 47, 56, 3)
local bn = X.pillow(B, 2.2)
local bb = {}
B:each(function(x, y) local k = K(x, y)
  local g = sin(y * 0.33 + x * 0.05) * 1.6 + sin(y * 0.11) * 1.2
  if floor(x + g) % 5 == 0 then bb[k] = -1 end                       -- grain lines
  local dx, dy = (x - 44) / 1.6, (y - 47) / 2.6
  if dx * dx + dy * dy < 1.2 and dx * dx + dy * dy > 0.25 then bb[k] = -2 end   -- knot ring
end)
local bidx = A.shade(c, B, bn, WOOD, { amb = 0.12, wrap = 0.35, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }, bias = bb, tok = wt })
c:put(44, 47, WOOD[2], wt)

-- paper sheet
local P = c:rect(20, 15, 43, 52)
-- contact shadow of the sheet on the board: one row right and below
P:shift(1, 1):each(function(x, y) if B:has(x, y) and not P:has(x, y) then A.step(c, bidx, WOOD, x, y, -2, wt) end end)
P:each(function(x, y)
  local t = 5
  if x == 43 or y == 52 then t = 3 elseif x == 42 or y == 51 then t = 4 end
  if x == 20 or y == 15 then t = 6 end
  if y <= 18 and x >= 24 and x <= 39 then t = (y <= 17) and 3 or 4 end     -- AO under the clip
  c:put(x, y, PAP[t], pt)
end)

-- checklist rows: box (5x5), tick, two text lines
local rows = { 23, 33, 43 }
for i, ry in ipairs(rows) do
  local bx = 23
  for x = bx, bx + 5 do for y = ry, ry + 5 do
    local edge = x == bx or x == bx + 5 or y == ry or y == ry + 5
    if edge then c:put(x, y, (x == bx + 5 or y == ry + 5) and MET[2] or MET[3], pt) else c:put(x, y, PAP[6], pt) end
  end end
  -- text lines: a long and a short line, 2 px tall
  for x = 31, 40 do c:put(x, ry + 1, LINE[1], pt) c:put(x, ry + 2, LINE[2], pt) end
  for x = 31, 36 do c:put(x, ry + 4, LINE[1], pt) c:put(x, ry + 5, LINE[2], pt) end
  if i < 3 then
    -- bold tick spilling out of the box, 3 px stroke
    local tm = A.stroke({ { bx + 1.5, ry + 2.5 }, { bx + 3, ry + 4.2 }, { bx + 7, ry - 1.5 } }, 1.15)
    tm:each(function(x, y)
      local top = not tm:has(x, y - 1) or not tm:has(x - 1, y)
      local bot = not tm:has(x, y + 1) or not tm:has(x + 1, y)
      c:put(x, y, top and MOSS[4] or (bot and MOSS[2] or MOSS[3]), pt)
    end)
    c:put(bx + 6, ry - 1, MOSS[5], pt)
  end
end

-- quirk: a faint coffee-cup ring near the bottom-right of the sheet
local ring = A.ell(38.5, 48.5, 3.6, 2.8)
ring:cut(A.ell(38.5, 48.5, 2.6, 1.8))
ring:each(function(x, y) if (x + y) % 7 ~= 0 and y <= 51 then c:put(x, y, (x > 39 and y > 48) and "#c9a888" or "#d8bf9e", pt) end end)

-- clip: base plate, curled spring bar with a dark eye
local plate = c:rrect(23, 9, 40, 15, 1)
local pn = X.pillow(plate, 1.6)
A.shade(c, plate, pn, MET, { amb = 0.08, wrap = 0.25, cuts = { 0.2, 0.36, 0.52, 0.7, 0.88 }, tok = mt })
local bar = c:rrect(26, 5, 37, 11, 2)
local brn = X.pillow(bar, 2.4)
local bri = A.shade(c, bar, brn, MET, { amb = 0.06, wrap = 0.2, cuts = { 0.2, 0.36, 0.52, 0.7, 0.88 }, tok = mt })
-- AO where the bar sits on the plate
for x = 26, 37 do if plate:has(x, 12) then c:put(x, 12, MET[2], mt) end end
-- eye (hole) with a lit lower lip
for x = 30, 33 do c:put(x, 7, MET[1], mt) c:put(x, 8, MET[1], mt) end
c:put(30, 9, MET[4], mt) c:put(31, 9, MET[5], mt) c:put(32, 9, MET[5], mt) c:put(33, 9, MET[4], mt)
-- bright top edge + specular streak + glint
for x = 28, 35 do c:put(x, 5, MET[6], mt) end
c:put(27, 6, MET[6], mt) c:put(28, 6, "#fbfaff", mt)
-- rivets on the plate
c:put(24, 13, MET[6], mt) c:put(25, 14, MET[2], mt) c:put(39, 13, MET[5], mt) c:put(40, 14, MET[2], mt)
-- clip shadow onto paper
for x = 24, 39 do if P:has(x, 16) then c:put(x, 16, PAP[2], pt) end end
A.save(c, "ico-clipboard")
