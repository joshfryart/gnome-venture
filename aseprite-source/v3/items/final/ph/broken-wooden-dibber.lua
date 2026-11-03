-- broken-wooden-dibber (aB13_0, Opus single pass). An upright turned-beech dibber: a T crossbar with domed ends on
-- top, a turned collar bead, then a slim shaft with depth rings (groove + lit lip) every 5 px. The point has snapped
-- off two rings down and lies tipped over at the lower right, splintered faces toward each other.
-- Material: cylinder light on crossbar and shaft (6 tones), paler end grain on the crossbar ends, wavy grain, AO under
-- the crossbar and the collar, pale torn end grain at both breaks.
-- broken: real gap + two flying splinters.
-- quirk: a clod of soil still stuck to the snapped point, with a seed peeping out of it.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB13_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local c = A.new("broken-wooden-dibber")
local BEECH = { "#4a2a2c", "#764634", "#a2683f", "#c99357", "#e2b677", "#f5d8a0" }
local SOIL = { "#3a2226", "#55332a", "#76503a", "#946a4a" }
local SEED = { "#5e3a1e", "#a8702a", "#f5b82e" }
local ENDG, ENDS = "#f6e2b2", "#cfa46c"

-- shaft (top part, ends at the break)
local TB = 0.98
local sh = { { 31, 18 }, { 31.2, 26 }, { 31.5, 34 }, { 31.8, 43 } }
local S = A.tube(c, sh, function(t) return 1.75 end, BEECH, {
  keep = function(t, s) return t <= TB + A.jag(s) / 25 end,
  bias = function(t) if t < 0.08 then return -1 end return 0 end })
A.grain(c, S, { { -0.35, 0.1, 0.9, 0.08 }, { 0.35, 0.2, 0.8, 0.1 } })
-- depth rings every 5 px from the collar
A.over(c, S, function(t, s, x, y, i)
  local d = t * S.len
  for r = 6, 22, 5 do
    if abs(d - r) < 0.5 then return i - 2 end
    if abs(d - (r - 1)) < 0.5 and s < 0.4 then return i + 1 end
  end
  local e = TB * S.len + A.jag(s) - d
  if e < 1.1 then return (abs(s) < 0.3) and ENDS or ENDG end
end)

-- collar bead under the crossbar
local bead = c:ellipse(31.5, 18.5, 3, 1.5)
local bn = X.sphere(31, 18, 3, bead)
A.G.toneN(c, bead, bn, BEECH, { cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
bead:each(function(x, y) if y == 20 then c:put(x, y, BEECH[2]) end end)

-- T crossbar
local bar = { { 21, 14 }, { 27, 13.6 }, { 36, 13.6 }, { 42, 14 } }
local CB = A.tube(c, bar, function(t)
  local e = math.min(t, 1 - t)
  if e < 0.08 then return 2.2 + (0.08 - e) * 4 end
  return 2.0 - 0.3 * math.sin(math.pi * t)
end, BEECH)
A.grain(c, CB, { { -0.3, 0.12, 0.88, 0.12 }, { 0.4, 0.15, 0.85, 0.1 } })
A.over(c, CB, function(t, s, x, y, i)
  local d = t * CB.len
  if d < 1.2 or d > CB.len - 1.2 then return (s < 0) and ENDG or ENDS end -- end grain
  if abs(t - 0.5) < 0.09 and s > 0.55 then return i - 1 end            -- AO above the collar
end)
-- turned ring lines at the domes
A.over(c, CB, function(t, s, x, y, i) local d = t * CB.len
  if abs(d - 3.2) < 0.5 or abs(d - (CB.len - 3.2)) < 0.5 then return i - 2 end end)
c:put(26, 12, BEECH[6]) c:put(27, 12, BEECH[6])

-- snapped point lying tipped over at the lower right
local pt = { { 37, 46 }, { 40, 49 }, { 43, 53 }, { 46, 57 } }
local TT = 0.03
local PT = A.tube(c, pt, function(t) return 1.75 * (1 - t) ^ 0.8 + 0.2 end, BEECH, {
  keep = function(t, s) return t >= TT - A.jag(s, 3) / 15 end })
A.grain(c, PT, { { -0.3, 0.1, 0.7, 0.1 } })
A.over(c, PT, function(t, s, x, y, i)
  local d = t * PT.len
  local e = d - (TT * PT.len - A.jag(s, 3))
  if e < 1.1 then return (abs(s) < 0.3) and ENDS or ENDG end
  if abs(d - 4.5) < 0.5 then return i - 2 end
  if abs(d - 3.5) < 0.5 and s < 0.4 then return i + 1 end
end)
-- quirk: soil clod on the point with a seed peeping out
local clod = c:ellipse(44.5, 55, 2.5, 1.8)
clod:add(c:ellipse(42.5, 56, 1.5, 1.2))
local cn = X.pillow(clod, 1.5)
A.G.toneN(c, clod, cn, { SOIL[1], SOIL[2], SOIL[2], SOIL[3], SOIL[3], SOIL[4] }, { cuts = { 0.2, 0.35, 0.5, 0.65, 0.85 } })
clod:each(function(x, y) if A.X.hash(x, y, 5) > 0.82 then c:put(x, y, SOIL[4]) end end)
c:put(45, 53, SEED[2]) c:put(46, 53, SEED[2]) c:put(45, 52, SEED[3]) c:put(46, 54, SEED[1])

-- flying splinters
A.shard(c, 37.5, 41.5, -1.0, 2.0, 0.7, BEECH)
A.shard(c, 27.5, 47.5, 0.6, 1.5, 0.6, BEECH)
c:put(37, 40, ENDG)
A.fin(c)
