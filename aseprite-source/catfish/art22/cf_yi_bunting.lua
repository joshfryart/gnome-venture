-- cf_yi_bunting.lua : Cat Fish Yarn panel icon `bunting` (hang Yarn bunting in the festival jar: 1 Yarn, +3 jar
-- points, three a day), 64x64, gvlib "icon" mode, the house look of cf_icons.lua (helpers copied from it).
-- Run: AppRun -b --script cf_yi_bunting.lua      Writes out/cf-yi-bunting.png + .aseprite.
-- Drawing: a pink twisted yarn string drooping between two gold end beads, four felt pennant flags hanging
-- from it (red, sky, mint, violet), each with a gold hem stitch and an enamel glint. Silhouette: a wide
-- sagging garland of downward triangles, unlike the other round / boxy Yarn icons.
local here = debug.getinfo(1, "S").source:sub(2):match("^(.*)/[^/]*$") or "."
local GV = dofile(here .. "/../../gvlib/gvlib.lua")
local OUT = here .. "/out/"
local C = GV.C

-- felt(hex): gvlib ramp with deep = shade and bounce = base (from cf_icons.lua)
local function felt(hex, ov)
  local r = GV.ramp(hex)
  local n = {} for k, v in pairs(r) do n[k] = v end
  for k, v in pairs(ov or {}) do n[k] = v end
  n.deep, n.bounce = (ov or {}).deep or n.shade, (ov or {}).bounce or n.base
  return n
end
-- paint only on pixels owned by part P (not gloss, optionally lit felt only) (from cf_icons.lua)
local function onPart(c, m, P, hex, litOnly)
  m:each(function(x, y)
    local k = c:key(x, y)
    if c.own[k] == P and not c.gl.s[k] and not (litOnly and c.shd[k]) then c:px(x, y, hex) end
  end)
end

-- flag felts: gloss = rim so each flag is 3 tones (the icon stays at 20 colours)
local function flag(base, rim, shade) return felt(base, { gloss = rim, dot = rim, rim = rim, shade = shade }) end
local RED = flag("#dd3a2a", "#f2793a", "#ae2a2a")
local SKY = flag("#4f8fd8", "#8cbcf0", "#3a5fae")
local MINT = flag("#4fb88a", "#86d8b0", "#2f8a6a")
local VIO = flag("#7a5cc0", "#a890e0", "#4e3a8a")
local GOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
GOLD.deep, GOLD.bounce = GOLD.shade, GOLD.base

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- the string: gold yarn sagging from (8,8) to (55,8), lowest (y 23) in the middle, a knot and tail at each end
local X0, X1, YT, SAG = 10, 53, 13, 14
local CXS = (X0 + X1) / 2
local function sy(x) local u = (x - CXS) / ((X1 - X0) / 2) return YT + SAG * (1 - u * u) end
local pts = {}
for x = X0, X1, 2 do pts[#pts + 1] = { x, sy(x) } end
pts[#pts + 1] = { X1, sy(X1) }
local str = c:line(pts, 3)
local knotL = c:ellipse(X0 - 0.5, YT, 2.5)
local knotR = c:ellipse(X1 + 0.5, YT, 2.5)
local tailL = c:line({ { X0 - 1, YT + 2 }, { X0 - 2, YT + 7 } }, 2)
local tailR = c:line({ { X1 + 1, YT + 2 }, { X1 + 2, YT + 7 } }, 2)

-- pennants: top corners on the string, tip straight below the middle, neighbours overlap 1 px (contour)
local FL = { { 9, 20, RED }, { 20, 31, SKY }, { 31, 42, MINT }, { 42, 53, VIO } }
local H = 23
local list = { { "tailL", tailL, GOLD, { flat = true, contact = false } },
               { "tailR", tailR, GOLD, { flat = true, contact = false } } }
local flags = {}
for i, f in ipairs(FL) do
  local xa, xb, R = f[1], f[2], f[3]
  local ya, yb = sy(xa), sy(xb + 1)
  local xm = (xa + xb + 1) / 2
  local tip = { xm, math.max(ya, yb) + H }
  local m = c:poly({ { xa, ya }, { xb + 1, yb }, tip })
  flags[i] = { m = m, R = R, xa = xa, xb = xb, ya = ya, yb = yb, tip = tip }
  list[#list + 1] = { "f" .. i, m, R, { cres = 2, gloss = false } }
end
list[#list + 1] = { "str", str, GOLD, { cres = 1, deep = 0, gloss = false, contact = false } }
list[#list + 1] = { "knotL", knotL, GOLD, { cres = 2, gloss = false, bounce = false, contact = false } }
list[#list + 1] = { "knotR", knotR, GOLD, { cres = 2, gloss = false, bounce = false, contact = false } }
local p = c:build(list)

-- twisted yarn: a shade tick every 3 px along the string's lower row, a lit tick above it
for x = X0 + 3, X1 - 3 do
  if x % 3 == 0 then
    local y = math.floor(sy(x) + 0.5)
    local k = c:key(x, y + 1)
    if c.own[k] == p.str then c:px(x, y + 1, GOLD.shade) end
    local k2 = c:key(x - 1, y - 1)
    if c.own[k2] == p.str and not c.shd[k2] then c:px(x - 1, y - 1, GOLD.gloss) end
  end
end

-- each pennant: a gold hem stitch under the string (the folded-over top), an enamel comma (rim tone, cream dot) on the lit upper left
for i, f in ipairs(flags) do
  local y0 = function(x) return math.floor(sy(x) + 0.5) + 4 end
  local hem = {}
  for x = f.xa + 2, f.xb - 1 do hem[#hem + 1] = { x, y0(x) } end
  c:seam(hem, { gap = f.R.shade })
  c:paint({ "dg", "g.", "g." }, f.xa + 3, y0(f.xa + 3) + 2, { g = f.R.rim, d = GOLD.gloss })
end

local name = "cf-yi-bunting"
local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
print("bunting  " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 20 and t.bw == 0, "check failed")
