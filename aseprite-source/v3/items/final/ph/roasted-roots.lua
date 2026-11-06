-- roasted-roots (final, Sonnet high). A round cast-iron skillet with a slim pierced handle, seen from above-front,
-- holding three roasted roots: a glazed carrot (growth rings, charred greens), a golden parsnip crossing it, and a
-- halved beet with magenta rings on its cut face. Caramel patches, charred tips, salt flecks, a rosemary sprig and an
-- oil sheen on the iron. Iron wall and rim are lit pillow shapes; roots are per-pixel cylinders/domes.
-- quirk: the steam rising from the pan curls into a little heart.
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_5.lua")
local HP, X, K, B = D.HP, D.X, D.K, D.B
local floor, ceil, abs, sin, cos, pi, max, min, sqrt = math.floor, math.ceil, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = D.new("roasted-roots")
local IR = { "#17131f", "#262031", "#3a3248", "#52495f", "#6f667c", "#958ba2" }
local OR = D.R.orange
local PAR = { "#5a3a22", "#8a5c34", "#b88850", "#d8ac6c", "#ecc88a", "#f8e0b0" }
local BEET = { "#2a1030", "#4a1a4a", "#6e2a68", "#923a80", "#b85a9c", "#dc8cc0" }
local LEAF = D.R.leaf
local ST, ST2, ST3 = "#e4f6ff", "#b9e2f5", "#8bc4ea"
local CX, CY = 28, 43
D.shadow(c, 30, 56, 24, 1.6)

-- skillet wall (lower body) and rim
local body = c:ellipse(CX, CY, 21, 10):add(c:ellipse(CX, CY + 4, 20, 9.5))
-- handle first (rim overlaps its root)
local hm = D.stalk(c, 46, 46, 54, 42, function(t) return 2.0 + 0.5 * t end, IR, { -0.3 })
local tab = B.ell(55, 41, 2.7, 2.4, 0)
B.lit(c, tab, IR, 2.2)
c:px(55, 41, IR[1]) c:px(56, 41, IR[2])
-- wall tone: vertical cylinder x-shade, darker lower
do
  local nrm = {}
  body:each(function(x, y)
    local t = D.clamp((x - CX) / 21.5, -0.97, 0.97)
    local ny = D.clamp((y - 46) / 12, -0.7, 0.6)
    local l = sqrt(t * t + ny * ny + (1 - t * t))
    nrm[K(x, y)] = { t / l, ny / l, sqrt(max(0.05, 1 - t * t)) / l }
  end)
  local v = X.light(nrm, { amb = 0.06, wrap = 0.3 })
  local bias = {}
  body:each(function(x, y) local h = D.hash(x, y, 4) if h > 0.94 then bias[K(x, y)] = 1 elseif h < 0.06 then bias[K(x, y)] = -1 end end)
  X.tone(c, body, v, IR, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.88 }, bias = bias })
end
-- underside / bottom row
body:each(function(x, y) if not body:has(x, y + 1) then c:px(x, y, IR[1]) end end)
-- rim ring
local rimOut = c:ellipse(CX, CY, 21, 10)
local rimIn = c:ellipse(CX, CY, 18.4, 8)
local ring = rimOut:copy():cut(rimIn)
do
  local n = X.pillow(ring, 1.7)
  local v = X.light(n, { amb = 0.08, wrap = 0.35 })
  X.tone(c, ring, v, IR, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 } })
  -- bright specular on the rim, upper-left
  c:px(14, 36, IR[6]) c:px(15, 35, IR[6]) c:px(16, 35, IR[6]) c:px(13, 37, IR[5])
  -- pour spout notch at left
  c:px(7, 41, IR[1]) c:px(7, 42, IR[2])
end
-- interior iron with oil sheen
D.paintF(c, rimIn, IR, function(x, y)
  local r = sqrt(((x - CX) / 18.4) ^ 2 + ((y - CY) / 8) ^ 2)
  local i = 2 + (y < CY and 0.9 or 0) - (r < 0.45 and 0.4 or 0)
  if r > 0.82 and x < CX and y < CY then i = 4 end
  if r > 0.86 and x > CX and y > CY then i = 1 end
  if D.hash(x, y, 8) > 0.93 then i = i + 1 end
  return i
end)
c:px(18, 37, IR[5]) c:px(19, 37, IR[5])  -- oil glint
for _, q in ipairs{ {33,48},{36,49},{20,48} } do c:px(q[1], q[2], "#0e0b14") end

-- beet half (back right): skin dome then cut face with rings
local dome = B.ell(39, 41.5, 6.3, 4.6, 0)
D.litB(c, dome, BEET, 3.5, { wrap = 0.3 }, function(x, y) if D.hash(x, y, 6) > 0.9 then return 1 end end)
local cut = B.ell(39, 38.8, 5.6, 3.3, 0)
D.paintF(c, cut, BEET, function(x, y)
  local r = sqrt(((x - 39) / 5.6) ^ 2 + ((y - 38.8) / 3.3) ^ 2)
  local k = floor(r * 3.4)
  local i = ({ 6, 4, 5, 3 })[k + 1] or 3
  if x > 41 and y > 39 then i = i - 1 end
  return i
end)
c:px(36, 37, BEET[6]) c:px(37, 36, BEET[6])  -- glaze glint on the cut face
c:px(45, 43, BEET[2]) c:px(46, 44, BEET[1])  -- root tail

-- parsnip (from crown upper-left to tip lower-left)
local pm, pidx, pT, pS = D.stalk(c, 27, 36, 16, 48, function(t) return 3.5 * (1 - t) ^ 0.75 + 0.4 end, PAR, { -0.25, 0.4 })
pm:each(function(x, y) local k = K(x, y) local t = pT[k]
  if D.hash(x, y, 15) > 0.9 then c:px(x, y, "#a8683a") end
  if t > 0.93 then c:px(x, y, "#3a2420") end
  if abs((t * 14) % 4.4 - 2.2) < 0.45 and abs(pS[k]) < 0.8 then c:px(x, y, PAR[max(1, (pidx[k] or 3) - 1)]) end
end)
-- crown dip + glaze
c:px(26, 36, PAR[2]) c:px(27, 36, PAR[1]) c:px(28, 36, PAR[2])
c:px(24, 38, PAR[6]) c:px(25, 39, PAR[6])

-- carrot in front (crown right, tip left)
local rm, ridx, rT, rS = D.stalk(c, 40, 46, 13, 41, function(t) return 3.1 * (1 - t) ^ 0.8 + 0.35 end, OR, { -0.3, 0.38 })
local rlen = sqrt(27 ^ 2 + 5 ^ 2)
rm:each(function(x, y) local k = K(x, y) local t = rT[k]
  if abs((t * rlen) % 4 - 2) < 0.5 and abs(rS[k]) < 0.85 and t > 0.08 then c:px(x, y, OR[max(1, (ridx[k] or 3) - 1)]) end
  if D.hash(x, y, 21) > 0.91 then c:px(x, y, OR[2]) end
  if t > 0.9 then c:px(x, y, "#3a2420") end
end)
-- char marks and caramel at the carrot tip and shoulder
for _, q in ipairs{ {15,41},{16,42},{20,43},{24,43} } do c:px(q[1], q[2], "#5a2a1e") end
-- charred greens at the crown
for _, q in ipairs{ {43,44},{44,45},{43,46},{44,47},{45,46} } do c:px(q[1], q[2], LEAF[1]) end
c:px(43, 45, LEAF[3]) c:px(44, 46, LEAF[2])
-- glaze streak and glint
for _, q in ipairs{ {34,44},{35,43},{36,43},{30,43},{31,43} } do c:px(q[1], q[2], OR[6]) end
c:px(37, 44, "#fff4d6")

-- rosemary sprig across the back
local sprig = "#3e8048"
B.ln(c, 19, 38, 34, 35, sprig)
for x = 21, 33, 2 do
  local y = 38 - floor((x - 19) * 0.2 + 0.5)
  c:px(x, y - 1, "#6ab455") c:px(x + 1, y + 1, "#45954c")
end
c:px(34, 34, "#6ab455")
-- salt flecks
for _, q in ipairs{ {19,45},{25,41},{29,46},{22,40},{31,38},{37,46} } do c:px(q[1], q[2], "#fff4d6") end

-- quirk: steam curls into a heart
local function dot2(x, y, col) for dx = 0, 1 do for dy = 0, 1 do c:px(x + dx, y + dy, col) end end end
local hx0, hy0 = 28, 14.5
local seen = {}
for i = 0, 360 do
  local t = i / 360 * 2 * pi
  local x = 16 * sin(t) ^ 3
  local y = 13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t)
  local px, py = floor(hx0 + x * 0.46 + 0.5), floor(hy0 - y * 0.46 + 0.5)
  if not seen[px * 100 + py] then seen[px * 100 + py] = true
    local col = (py < 14) and ST or ((py < 19) and ST2 or ST3)
    if px > hx0 + 2 and py > 14 then col = ST3 end
    dot2(px, py, col)
  end
end
c:px(23, 11, "#ffffff" == nil and ST or ST)
-- wisp up from the pan
for i, q in ipairs{ {28,23},{28,24},{27,25},{27,26},{28,27},{29,28},{28,29},{28,30} } do c:px(q[1], q[2], (i % 3 == 0) and ST3 or ST2) end
c:px(29, 24, ST2) c:px(29, 27, ST3)
D.fin()
