-- ico-ant (final pass, Opus single pass). Bold icon: a slim worker ant in side view, walking left. Round head with a
-- big eye and jaws, narrow waisted thorax, a tiny petiole knob and a glossy tear-drop gaster. Per-pixel light, 6-tone
-- red-brown chitin: banded gaster plates (dark groove + lit lip), hard specular + cream glint, cool bounce under the
-- belly, AO where the parts meet. Six jointed 3 px legs (far side a tone darker), elbowed antennae with club tips.
-- quirk: it is hauling a sugar cube in its jaws, a little too big for it.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/../_helpers/_aA0_3.lua")
local HP, X, K = T.HP, T.X, T.K
local floor, max, min, sqrt, abs = math.floor, math.max, math.min, math.sqrt, math.abs
local c = T.new("ico-ant")
local ANT = { "#24101a", "#421a26", "#6a2430", "#963830", "#c45a38", "#f09a5e" }
local FAR = { "#1e0e16", "#2e1420", "#40182a", "#5a2030", "#783034" }
local LEGR = { "#24101a", "#4a1c2a", "#7a2c30", "#a8442e", "#e07a48" }
local BOUNCE = "#8a4a6a"
local tk = function(n) return { r = { name = n } } end
local CA = { 0.3, 0.46, 0.62, 0.77, 0.9 }
-- dark seam on pixels of m that touch mask o
local function seam(m, o, hex) m:each(function(x, y)
  if o:has(x - 1, y) or o:has(x + 1, y) or o:has(x, y - 1) or o:has(x, y + 1) then c:put(x, y, hex) end end) end

local function leg(pts, ramp, name)
  local lm = c:line(pts, 3)
  local tok = tk(name)
  local nR = #ramp
  -- crisp cylinder: lit rim on the upper-left side, shade on the lower-right, mid core
  lm:each(function(x, y)
    local ul = not lm:has(x - 1, y) or not lm:has(x, y - 1)
    local lr = not lm:has(x + 1, y) or not lm:has(x, y + 1)
    local i = nR - 1
    if ul and not lr then i = nR elseif lr and not ul then i = 2 elseif ul and lr then i = nR - 2 end
    c:put(x, y, ramp[i], tok)
  end)
  return lm
end
-- far legs first (behind the body, darker)
leg({ { 27, 31 }, { 25, 36 }, { 22, 44 } }, FAR, "fl1")
leg({ { 34, 31 }, { 45, 33 }, { 51, 42 } }, FAR, "fl3")

-- gaster
local gm, gn = T.oval(45.5, 29, 10, 7.6, -0.32)
local gb = {}
local gtok = tk("gaster")
local gidx = T.shade(c, gm, gn, ANT, { amb = 0.03, wrap = 0.15, bias = gb, tok = gtok, cuts = CA })
-- plate grooves: arcs across the gaster (dark line + lit lip behind)
for _, gx in ipairs{ 41, 46, 50.5 } do
  gm:each(function(x, y) local k = K(x, y)
    local d = (x - gx) + (y - 30) * 0.35 - ((y - 29) / 7) ^ 2 * 2.2
    local i = gidx[k]
    if d > -0.5 and d < 0.5 then T.step(c, gidx, ANT, x, y, -2, gtok)
    elseif d >= 0.5 and d < 1.5 and i and i >= 3 then T.step(c, gidx, ANT, x, y, 1, gtok) end
  end)
end
-- petiole knob
local pm, pn = T.oval(36, 30.5, 2, 2.6, 0)
T.shade(c, pm, pn, ANT, { amb = 0.05, wrap = 0.2, tok = tk("pet") })
seam(pm, gm, ANT[1])
-- thorax: slim, humped front
local tm = c:ellipse(26.5, 28, 3.6, 3.4):add(c:ellipse(31, 29.5, 3.4, 2.8)):add(c:rect(27, 29, 32, 31))
local tn = X.pillow(tm, 3)
local tb = {}
X.ao(tb, tm, pm, 2, -1)
local tidx = T.shade(c, tm, tn, ANT, { amb = 0.04, wrap = 0.2, bias = tb, tok = tk("thorax"), cuts = CA })
seam(tm, pm, ANT[1])
-- near legs (over thorax)
leg({ { 25, 31 }, { 18, 34 }, { 12, 46 } }, LEGR, "l1")
leg({ { 30, 32 }, { 31, 39 }, { 27, 47 } }, LEGR, "l2")
leg({ { 33, 31 }, { 41, 35 }, { 46, 47 } }, LEGR, "l3")
-- knee joints: one bright pixel each
for _, p in ipairs{ { 18, 33 }, { 31, 38 }, { 41, 34 } } do c:put(p[1], p[2], LEGR[5]) end
-- toes: a 1px pale claw tip under each foot
for _, p in ipairs{ { 11, 47 }, { 26, 48 }, { 47, 48 } } do c:put(p[1], p[2], LEGR[2]) end

-- antennae: scape up, elbow, funiculus forward, 3 px club
local function ant(pts, ramp, club)
  local am = c:line(pts, 2)
  am:add(c:ellipse(club[1], club[2], 1.5, 1.5))
  T.pil(c, am, ramp, 1, { amb = 0.12, wrap = 0.3, tok = tk("ant") })
end
ant({ { 18, 21 }, { 22, 12 }, { 15, 7 } }, FAR, { 14, 7 })
ant({ { 15, 21 }, { 15, 12 }, { 9, 9 } }, LEGR, { 8, 9 })

-- head: round, slightly heavy jaw
local hm, hn = T.oval(16.5, 25.5, 6.2, 5.6, 0.25)
local hb = {}
X.ao(hb, hm, tm, 1, -1)
local hidx = T.shade(c, hm, hn, ANT, { amb = 0.04, wrap = 0.2, bias = hb, tok = tk("head"), cuts = CA })
seam(tm:copy():cut(hm), hm, ANT[1])
-- eye: big glossy 2x3 ink pill + glint, and a clear mouth line
c:eyeSmall(15, 22)
c:put(14, 25, ANT[2]) c:put(15, 25, ANT[2])
-- specular on head and gaster
c:put(14, 21, ANT[6]) c:put(15, 21, ANT[6])
T.map(c, { ".hh", "hss", "hs." }, 39, 24, { h = ANT[6], s = "#ffd0a0" }, gtok)
c:put(40, 25, T.CREAM, gtok)
c:put(25, 26, ANT[6]) c:put(26, 26, ANT[6])
-- cool bounce under the gaster belly
local rim = X.rim(gn)
gm:edge():each(function(x, y) if rim[K(x, y)] > 0.68 and y > 31 then c:put(x, y, BOUNCE, gtok) end end)

-- quirk: sugar cube in the jaws (3 faces: lit top, mid left, shade right; sparkly crystal flecks)
local SUG = { top = "#fff4d6", left = "#e6e2ea", right = "#b8b4c8", edge = "#cfc8da", fleck = "#ffffe8" }
T.map(c, {
  ".tttttt",
  "tttttttr",
  "eeeeeerr",
  "lflllerr",
  "llllllrr",
  "lllfllrr",
  "llllllr.",
}, 4, 27, { t = SUG.top, l = SUG.left, r = SUG.right, e = SUG.edge, f = "#fffbe8" }, tk("sugar"))
-- jaws gripping the cube
c:put(11, 29, ANT[3]) c:put(12, 29, ANT[4]) c:put(11, 30, ANT[2])
c:put(11, 33, ANT[3]) c:put(12, 33, ANT[3]) c:put(11, 32, ANT[2])
T.save(c, "ico-ant", "ico")
