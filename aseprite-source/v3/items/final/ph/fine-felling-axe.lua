-- fine-felling-axe (Opus single pass, aB31_3). A slim, long-bitted felling axe: hickory haft with a gentle S-sweep
-- and a fawn's-foot swell at the butt (pale end grain), grain streaks along its length. Polished steel head: boxy poll,
-- dark eye with a brass wedge showing at the top, narrow cheek flaring to a curved bit with a bright honed bevel band,
-- a specular streak along the upper cheek, a stamped maker's mark, cool bounce on the lower edge. AO where haft meets head.
-- quirk: a pale wood-shaving curl is still caught on the edge of the bit.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new("fine-felling-axe")
local STEEL = { "#363a58", "#545b7c", "#7a83a2", "#a3abc2", "#cad0de", "#eceff5" }
local HICK  = { "#4a2a24", "#6e3f2c", "#93593a", "#b5774a", "#d39a62", "#ebc187" }
local BRASS = { "#6a4220", "#a8702a", "#e0a83e", "#ffe08a" }
local BOUNCE = "#8ea6c8"

-- frame: eye centre E, haft axis u (up the haft), blade direction a (toward the bit, left)
local EX, EY = 37, 19
local ux, uy = 0.22, -0.976
local ax, ay = -0.976, -0.22
local function P(a, b) return EX + a * ax + b * ux, EY + a * ay + b * uy end

-- haft: bezier from butt (lower left) up through the eye, gentle S-sweep; slim 3-4 px
local hp = { { 27, 55 }, { 25, 46 }, { 34, 34 }, { P(0, 6) } }
local hm, hn, HT, HS, samp = A.tube(hp, function(t)
  if t < 0.06 then return 2.6 - t * 8 end            -- fawn's-foot swell
  if t < 0.12 then return 2.1 - (t - 0.06) * 6 end
  return 1.7 + t * 0.3
end)
-- head polygon in local (a, b) coords
local loc = { {-6,-3.4},{-6,3.4},{-4.5,4.4},{3,4.6},{9,2.6},{14,3.8},{18.5,6.8},{21,8.6},{22.4,4},{22.8,0},{22.4,-4.5},{21,-9.6},{18,-7.4},{13,-4.2},{8,-3.2},{3,-4.6},{-4.5,-4.4} }
local pts = {}
for i, q in ipairs(loc) do local x, y = P(q[1], q[2]) pts[i] = { x, y } end
local head = HP.poly(pts)
-- local coords per pixel
local LA, LB = {}, {}
head:each(function(x, y) local dx, dy = x + .5 - EX, y + .5 - EY local k = K(x, y)
  LA[k] = dx * ax + dy * ay LB[k] = dx * ux + dy * uy end)

-- haft painted first (visible only outside the head, plus the wedge top)
local hvis = hm:copy():cut(head)
local hb = {}
X.ao(hb, hvis, head, 2, -1)
local htok = A.tok("haft")
local hidx = A.tone(c, hvis, hn, HICK, { bias = hb, tok = htok, amb = 0.1, wrap = 0.3 })
-- grain: long darker streaks following the haft, lit side gets a pale streak
hvis:each(function(x, y) local k = K(x, y) local s, t = HS[k], HT[k]
  local band = floor((s + 1) * 3.2)
  local ph = (t * 9 + band * 0.37) % 1
  if t > 0.1 and (band == 2 or band == 4) and ph < 0.55 and not hb[k] then c:put(x, y, HICK[max(1, (hidx[k] or 3) - 1)], htok) end
  if t > 0.14 and t < 0.8 and s > -0.62 and s < -0.3 and ph > 0.6 and ph < 0.85 then c:put(x, y, HICK[6], htok) end
end)
-- pale end grain on the butt: last two rows of the swell
hvis:each(function(x, y) local k = K(x, y) if HT[k] < 0.02 then c:put(x, y, HS[k] < 0.3 and HICK[6] or HICK[5], htok) end end)
c:put(27, 57, HICK[3], htok) -- growth ring dot

-- head: flat polished plate with bevelled rims
local hn2 = X.pillow(head, 2.2)
local hbias = {}
local stok = A.tok("steel")
-- region tilt: cheek facing slightly up-left, bit bevel turned toward the light
for k, n in pairs(hn2) do local a = LA[k]
  if a > 19.4 then hn2[k] = { A.norm(n[1] - 0.25, n[2] - 0.35, n[3]) } end
  if a < -3.5 then hn2[k] = { A.norm(n[1] + 0.15, n[2] + 0.2, n[3]) } end
end
-- dark eye: AO ring around the haft opening
local eye = HP.mask()
head:each(function(x, y) local k = K(x, y) if abs(LA[k]) < 2.2 and abs(LB[k]) < 4.6 then eye:set(x, y) end end)
local sidx = A.tone(c, head, hn2, STEEL, { tok = stok, amb = 0.08, wrap = 0.3, cuts = { 0.3, 0.48, 0.64, 0.77, 0.9 } })
-- eye boss: slightly darker block with a lit top-left lip
eye:each(function(x, y) local k = K(x, y)
  local i = sidx[k] or 3
  if LA[k] > 1.4 then i = i - 1 end
  c:put(x, y, STEEL[max(2, min(5, i))], stok) end)
-- bevel line between cheek and honed bit
head:each(function(x, y) local k = K(x, y) local a, b = LA[k], LB[k]
  local edge = 19.4 + abs(b) * 0.1
  if a > edge - 0.5 and a < edge + 0.5 then c:put(x, y, STEEL[2], stok)
  elseif a >= edge + 0.5 and a < edge + 2.2 and b > -8 and b < 7.5 then
    c:put(x, y, (b > 1.5 and STEEL[6]) or (b > -4 and STEEL[5]) or STEEL[4], stok) end
end)
-- cheek specular streak along the upper side
for _, q in ipairs{ {5,2.6},{6,2.4},{7,2.2},{8,2},{11,2.4},{12,2.6} } do local x, y = P(q[1], q[2]) c:put(floor(x+.5), floor(y+.5), STEEL[6], stok) end
-- cool bounce on the lower edge of the cheek
head:edge():each(function(x, y) local k = K(x, y) if LB[k] < -2.5 and LA[k] > 4 and LA[k] < 17 then c:put(x, y, BOUNCE, stok) end end)
-- maker's mark: tiny stamped diamond on the cheek
do local x, y = P(11, 0) x, y = floor(x+.5), floor(y+.5)
  c:put(x, y, STEEL[2], stok) c:put(x+1, y, STEEL[3], stok) c:put(x, y-1, STEEL[3], stok) c:put(x-1, y, STEEL[4], stok) end
-- haft shows through the top of the eye with a brass wedge in it
do
  local wx, wy = P(0, 4.6)
  wx, wy = floor(wx + .5), floor(wy + .5)
  c:put(wx - 1, wy, HICK[5], htok) c:put(wx, wy, BRASS[3], htok) c:put(wx + 1, wy, HICK[3], htok)
  c:put(wx, wy - 1, BRASS[4], htok) c:put(wx - 1, wy - 1, HICK[4], htok) c:put(wx + 1, wy - 1, BRASS[2], htok)
end
-- dark underside of the eye where the haft enters (ambient)
do for a = -1.5, 1.5, 0.5 do local x, y = P(a, -4.3) c:put(floor(x+.5), floor(y+.5), STEEL[1], stok) end end

-- quirk: a wood-shaving curl hanging off the bit
local SH = { "#b07a4a", "#e2b67a", "#f6dcaa" }
local cx, cy = P(22.6, -6.5)
cx, cy = floor(cx + .5) - 1, floor(cy + .5)
local curl = { "..ab.", ".a..b", ".c..b", "..cb." }
for j, row in ipairs(curl) do for i = 1, #row do local ch = row:sub(i, i)
  if ch ~= "." then c:put(cx + i - 3, cy + j - 1, ch == "a" and SH[3] or ch == "b" and SH[1] or SH[2]) end end end
A.save(c, "fine-felling-axe")
