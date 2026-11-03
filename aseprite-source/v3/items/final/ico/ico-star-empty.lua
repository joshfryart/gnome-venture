local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA10.lua")
local HP, X, INK, CREAM = D.HP, D.X, D.INK, D.CREAM
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-star-empty: a tan wooden-rimmed star frame with a pale hollow centre, the unearned star.
-- quirk: a hairline crack runs across the hollow and a spider-silk strand bridges two arms.
local c = D.new("ico-star-empty")
local outer = c:poly(D.starPts(32, 34, 27, 13, 5)) outer:add(c:ellipse(32, 34, 13, 13))
D.lit(c, outer, D.TAN, 12, { amb = 0.08 })
local inner = c:poly(D.starPts(32, 35, 15, 7, 5)) inner:add(c:ellipse(32, 35, 6, 6))
c:fillMask(inner, D.CRM[6])
D.seam(c, inner, c:rect(0, 0, 0, 0), D.CRM[2])
inner:each(function(x, y) if not inner:has(x - 1, y - 1) then c:px(x, y, D.TAN[1]) elseif not inner:has(x + 1, y + 1) then c:px(x, y, D.CRM[4]) end end)
D.ln(c, 28, 30, 31, 35, D.TAN[2]) D.ln(c, 31, 35, 30, 38, D.TAN[2]) D.ln(c, 30, 38, 34, 42, D.TAN[2])
D.ln(c, 12, 27, 52, 27, D.CRM[1], c:rect(0, 0, 0, 0))
D.fin()
