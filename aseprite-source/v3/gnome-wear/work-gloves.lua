-- work-gloves: tan leather gloves with stitched cuffs, the front one giving a thumbs-up.
-- quirk: the front index fingertip is worn through (a tiny hole).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local W = dofile(DIR .. "/_gw.lua")
local HP, X, K, R, G = W.HP, W.X, W.K, W.R, W.G
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "work-gloves" }
local min, max = math.min, math.max

-- glove in local coords: palm x 0..14, cuff below; ox,oy offset; mir mirrors around palm centre
local function glove(ox, oy, mir, bias, thumbUp)
  local function tx(x) if mir then return math.floor(ox + 14 - x + 0.5) else return math.floor(ox + x + 0.5) end end
  local function rr(x0, y0, x1, y1, r) local a, b = tx(x0), tx(x1) return c:rrect(min(a, b), oy + y0, max(a, b), oy + y1, r) end
  local function pl(pts) local q = {} for i, p in ipairs(pts) do q[i] = { tx(p[1]), oy + p[2] } end return c:poly(q) end
  local g = {}
  g.palm = rr(0, 14, 14, 33, 3):add(rr(1, 30, 13, 34, 1))
  local tops = { 3, 0, 1, 5 }
  g.fingers = {}
  for i = 1, 4 do g.fingers[i] = rr((i - 1) * 3.75, tops[i], (i - 1) * 3.75 + 3, 18, 2) end
  g.cuff = pl{ {-0.5, 33}, {15, 33}, {16.5, 44}, {-2, 44} }
  local tm, tn
  if thumbUp then
    tm, tn = G.tube({ { tx(1), oy + 26 }, { tx(-3), oy + 24 }, { tx(-6), oy + 17 }, { tx(-6), oy + 10 } }, function(t) return 2.9 - t * 0.5 end)
  else
    tm, tn = G.tube({ { tx(1), oy + 24 }, { tx(-3), oy + 26 }, { tx(-5), oy + 29 }, { tx(-6), oy + 33 } }, function(t) return 2.8 - t * 0.4 end)
  end
  g.thumb, g.thumbN = tm, tn
  g.all = g.palm:copy():add(g.cuff):add(tm)
  for i = 1, 4 do g.all:add(g.fingers[i]) end
  g.paint = function()
    local b = {}
    g.all:each(function(x, y) b[K(x, y)] = bias end)
    -- thumb sits behind the palm edge
    W.toneN(c, tm, tn, R.leather, { bias = b })
    W.sep(c, g.palm, tm, R.leather[1])
    for i = 1, 4 do
      local f = g.fingers[i]
      local fx0, _, fx1 = f:bbox()
      local fi = W.vcyl(c, f, R.leather, fx0, fx1, { bias = b, cuts = { .22, .4, .56, .72, .9 } })
      if i > 1 then f:each(function(x, y) if not f:has(x - 1, y) and y > oy + tops[i] + 1 then c:put(x, y, R.leather[2 + (bias or 0)]) end end) end
    end
    local pi = W.lit(c, g.palm:copy():cut(c:rect(0, 0, 63, oy + 17)), R.leather, { R = 4, bias = b, cuts = { .22, .4, .56, .72, .9 } })
    -- knuckle creases
    for i = 1, 3 do c:put(tx(i * 3.75 - 1), oy + 19, R.leather[3]) c:put(tx(i * 3.75 - 0), oy + 19, R.leather[3]) end
    for x = 2, 12 do if x % 4 ~= 0 then c:put(tx(x), oy + 21, R.leather[3]) end end
    W.speckle(c, g.palm, pi, R.leather, 0.05, 11 + ox)
    -- cuff: darker leather, contact shadow above, stitched line
    local cb = {}
    g.cuff:each(function(x, y) cb[K(x, y)] = bias end)
    W.lit(c, g.cuff, R.cuffL, { R = 3, bias = cb })
    for x = -1, 15 do if g.cuff:has(tx(x), oy + 33) then c:put(tx(x), oy + 33, R.cuffL[1]) end end
    for x = 0, 15 do if g.cuff:has(tx(x), oy + 34) then c:put(tx(x), oy + 34, R.cuffL[5 + (bias or 0)]) end end
    for x = 0, 15 do if x % 3 < 2 and g.cuff:has(tx(x), oy + 36) then c:put(tx(x), oy + 36, "#f2e2b8") end end
    for x = -1, 16 do if g.cuff:has(tx(x), oy + 44) then c:put(tx(x), oy + 44, R.cuffL[2]) end end
  end
  return g
end

local back = glove(31, 9, true, -1, false)
local front = glove(18, 12, false, nil, true)
back.paint()
W.sep(c, front.all, back.all, W.ink)
front.paint()
-- leather sheen on the front palm and thumb tip
c:put(21, 28, R.leather[6]) c:put(22, 28, R.leather[6]) c:put(21, 29, R.leather[6])
c:put(11, 23, W.cream)
-- quirk: worn-through hole on the front index fingertip
c:put(23, 14, W.ink) c:put(24, 14, R.leather[2]) c:put(23, 15, R.leather[2])
W.save(c, "work-gloves")
