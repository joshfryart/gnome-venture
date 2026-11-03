-- broken-willow-fishing-rod (aB13_0, Opus single pass). A slim peeled-willow rod on the diagonal, butt lower-left:
-- twine-whipped cork grip with a brass reel seat, then the rod snapped clean through about halfway. The tip section has
-- jumped off and droops, splintered ends facing each other, the line sagging slack across the gap and on to a
-- red-and-cream bobber. Material: per-pixel cylinder light (6 tones), wavy grain, two willow nodes, pale end grain at
-- the breaks, cork pits, diagonal twine twist, brass ring guides, glossy bobber with one specular.
-- broken: real gap + splintered faces + two flying splinters.
-- quirk: a little pink worm is still wriggling on the hook.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB13_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sin = math.floor, math.max, math.min, math.abs, math.sin
local c = A.new("broken-willow-fishing-rod")
local WIL  = { "#4a2c2a", "#71472f", "#9d6c43", "#c4995f", "#dfbd7e", "#f3dca4" }
local CORK = { "#4a2a24", "#73433a", "#9a6448", "#bf895c", "#d9ab7a", "#efcd9a" }
local TW   = { "#3d3a52", "#5d5a78", "#8c8aa6", "#c6c4d8" }
local BR   = { "#5a3020", "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local RED  = { "#5e1c30", "#8e2236", "#c2303a", "#e8493b", "#ff7a5a", "#ffb08a" }
local CRM  = { "#8a7a8a", "#b8aab0", "#e2d6cc", "#fff4d6" }
local LINE, LINED = "#c9ccdc", "#8e93ad"
local ENDG, ENDS = "#f6e4b6", "#cfa46c"

-- butt section: (10,55) -> break near (31,34)
local TB = 0.97
local butt = { { 10, 55 }, { 17, 48 }, { 24, 41 }, { 32, 33 } }
local function bw(t)
  if t < 0.03 then return 1.7 + t / 0.03 * 0.5 end
  if t < 0.36 then return 2.3 end
  if t < 0.42 then return 2.3 - (t - 0.36) / 0.06 * 0.8 end
  return 1.5 - (t - 0.42) * 0.25
end
local B = A.tube(c, butt, bw, WIL, {
  keep = function(t, s) return t <= TB + A.jag(s) / 32 end,
  bias = function(t, s) if t < 0.02 then return -1 end return 0 end })
-- cork grip (t 0.04..0.36) with pits, twine whipping at both ends with a diagonal twist
A.over(c, B, function(t, s, x, y, i)
  if t >= 0.03 and t <= 0.37 then
    local j = i
    if A.X.hash(x, y, 3) > 0.8 and i > 2 then j = i - 1 end
    return CORK[j]
  end
end)
A.over(c, B, function(t, s, x, y, i)
  local d = t * B.len
  local inA = d >= 0.5 and d <= 3.0
  local inB = t >= 0.37 and t <= 0.42
  if inA or inB then
    local ph = floor(d + s * 1.6 + 0.5) % 2
    local j = floor((i + 1) / 1.5)
    j = max(1, min(4, j - ph))
    return TW[j]
  end
end)
-- grain + node on the bare rod
A.grain(c, B, { { -0.3, 0.45, 0.92, 0.12 }, { 0.45, 0.5, 0.88, 0.1 } })
A.over(c, B, function(t, s, x, y, i)
  local d = t * B.len - 0.66 * B.len
  if abs(d) < 0.6 then return i - 2 end
  if d > 0.6 and d < 1.6 and s < 0 then return min(6, i + 1) end
end)
-- end grain on the break face (pale) with a dark core split
A.over(c, B, function(t, s, x, y, i)
  local e = TB * B.len + A.jag(s) - t * B.len
  if e < 1.1 then return (abs(s) < 0.3) and ENDS or ENDG end
end)
-- brass reel seat: small reel disc on the lower-right side of the grip
do
  local s = B.samp[floor(0.22 * 160) + 1]
  local cx, cy = s.x + s.px * 4.2, s.y + s.py * 4.2
  local foot = c:line({ { floor(s.x + s.px * 2 + .5), floor(s.y + s.py * 2 + .5) }, { floor(cx + .5), floor(cy + .5) } }, 2)
  foot:each(function(x, y) c:put(x, y, BR[2]) end)
  local rm = c:ellipse(cx, cy, 2.5, 2.5)
  local n = X.sphere(cx - 0.5, cy - 0.5, 2.5, rm)
  A.G.toneN(c, rm, n, { BR[1], BR[2], BR[3], BR[4], BR[4], BR[5] }, { cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
  c:put(floor(cx + .5), floor(cy + .5), BR[1]) -- spindle
  c:put(floor(cx - 1 + .5), floor(cy - 1 + .5), "#fff4d6")
end

-- tip section: jumped clear, drooping a little more steeply
local tip = { { 38, 25 }, { 42, 20 }, { 47, 15 }, { 54, 11 } }
local TT = 0.03
local function tw(t) return 1.25 - t * 0.7 end
local T2 = A.tube(c, tip, tw, WIL, { keep = function(t, s) return t >= TT - A.jag(s, 2) / 22 end })
A.grain(c, T2, { { -0.2, 0.15, 0.7, 0.15 } })
A.over(c, T2, function(t, s, x, y, i)
  local e = t * T2.len - (TT * T2.len - A.jag(s, 2))
  if e < 1.1 then return (abs(s) < 0.3) and ENDS or ENDG end
  local d = t * T2.len - 0.5 * T2.len
  if abs(d) < 0.6 then return i - 2 end
end)
-- ring guides (brass dots on the upper side)
for _, gt in ipairs({ 0.35, 0.7 }) do
  local s = T2.samp[floor(gt * 160) + 1]
  local x, y = floor(s.x - s.px * (s.w + 1) + .5), floor(s.y - s.py * (s.w + 1) + .5)
  c:put(x, y, BR[3]) c:put(x + 1, y, BR[1])
end
-- flying splinters in the gap
A.shard(c, 30.5, 26.5, -0.8, 2.0, 0.7, WIL)
A.shard(c, 36.5, 33.5, 0.5, 1.6, 0.6, WIL)
c:put(29, 27, ENDG)

-- slack line: from the butt break sagging under the gap, then from the tip down to the bobber
A.ln(c, { { 31, 36 }, { 32, 39 }, { 34, 39 }, { 37, 36 }, { 39, 29 } }, LINE)
c:put(32, 39, LINED) c:put(33, 39, LINED)
local tx, ty = 55, 11
A.ln(c, { { tx, ty + 1 }, { tx + 1, ty + 6 }, { tx + 1, 20 } }, LINE)
-- bobber: red top, cream band, red underside; 5x8
local bob = c:ellipse(56, 25, 2.5, 3.5)
local bn = X.sphere(55.4, 24.4, 3.2, bob)
local v = X.light(bn, { amb = 0.08, wrap = 0.25 })
bob:each(function(x, y) local k = K(x, y)
  local i = max(1, min(6, floor(v[k] * 6) + 1))
  if y >= 25 and y <= 26 then c:put(x, y, CRM[max(1, min(4, floor(v[k] * 4) + 1))])
  else c:put(x, y, RED[i]) end
end)
c:put(55, 22, "#fff4d6")
c:put(56, 21, BR[1]) -- stem nub
-- hook line, hook and the worm (quirk)
A.ln(c, { { 56, 29 }, { 56, 34 } }, LINE)
c:put(56, 35, TW[3]) c:put(56, 36, TW[2]) c:put(55, 37, TW[2]) c:put(54, 36, TW[3])
A.map(c, 51, 34, {
  "..p.",
  ".Pp.",
  "PP..",
  "Pd..",
  ".dp.",
}, { P = "#f5809f", p = "#ffb0c4", d = "#c94f84" })
A.fin(c)
