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

local RED = felt("#dd3a2a", { gloss = "#ff9158", dot = "#ff9158", rim = "#f2793a", shade = "#ae2a2a" })
local SKY = felt("#4f8fd8", { gloss = "#c8e4ff", dot = "#c8e4ff", rim = "#8cbcf0", shade = "#3a5fae" })
local MINT = felt("#4fb88a", { gloss = "#c8f0d8", dot = "#c8f0d8", rim = "#86d8b0", shade = "#2f8a6a" })
local VIO = felt("#7a5cc0", { gloss = "#d8c8ff", dot = "#d8c8ff", rim = "#a890e0", shade = "#4e3a8a" })
local PINK = felt("#f08cb4", { gloss = "#ffe0ec", dot = "#ffe0ec", rim = "#ffb8d0", shade = "#c85a8e" })
local GOLD = { gloss = "#fff1c8", dot = "#fff1c8", rim = "#f5cf6a", base = "#e8a317", shade = "#b8661a" }
GOLD.deep, GOLD.bounce = GOLD.shade, GOLD.base

local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- the string: a catenary-ish sag from (7,11) to (56,11), lowest at the middle
local X0, X1, YT, SAG = 11, 52, 11, 12
local function sy(x) local u = (x - (X0 + X1) / 2) / ((X1 - X0) / 2) return YT + SAG * (1 - u * u) end
local pts = {}
for x = X0, X1, 3 do pts[#pts + 1] = { x, sy(x) } end
pts[#pts + 1] = { X1, sy(X1) }
local str = c:line(pts, 3)

-- pennants: top corners on the string, tip straight below the middle
local FL = { { 9, 20, RED }, { 21, 32, SKY }, { 32, 43, MINT }, { 43, 54, VIO } }
local H = 24
local list = {}
local flags = {}
for i, f in ipairs(FL) do
  local xa, xb, R = f[1], f[2] - 1, f[3]
  -- outer flags sit a bit higher on the sag; keep the tip under the centre, sloped with the string
  local ya, yb = sy(xa) + 1, sy(xb) + 1
  local xm = (xa + xb) / 2 + 0.5
  local tip = { xm, (ya + yb) / 2 + H - math.abs(xm - 31.5) * 0.35 }
  local m = c:poly({ { xa, ya }, { xb + 1, yb }, tip })
  flags[i] = { m = m, R = R, xa = xa, xb = xb, ya = ya, yb = yb, tip = tip }
  list[#list + 1] = { "f" .. i, m, R, { cres = 3, gloss = false } }
end
list[#list + 1] = { "str", str, PINK, { cres = 1, deep = 0, gloss = false, contact = false } }
list[#list + 1] = { "beadL", c:ellipse(X0 - 2, YT, 3), GOLD, { cres = 2, gloss = false, bounce = false } }
list[#list + 1] = { "beadR", c:ellipse(X1 + 2, YT, 3), GOLD, { cres = 2, gloss = false, bounce = false } }
local p = c:build(list)

-- twisted yarn: a shade tick every 3 px along the string's lower row
for x = X0 + 2, X1 - 2 do
  if x % 3 == 0 then
    local y = math.floor(sy(x) + 0.5)
    local k = c:key(x, y + 1)
    if c.own[k] == p.str then c:px(x, y + 1, PINK.shade) end
    local k2 = c:key(x - 1, y - 1)
    if c.own[k2] == p.str and not c.shd[k2] then c:px(x - 1, y - 1, PINK.rim) end
  end
end

-- each pennant: a gold hem stitch down both slanted sides, a glint on the lit upper left
for i, f in ipairs(flags) do
  local ins = 3
  local A = { f.xa + ins, f.ya + 4 }
  local B = { f.xb - ins + 1, f.yb + 4 }
  local T = { f.tip[1] - 0.5, f.tip[2] - 6 }
  c:seam({ A, T, B }, { gap = f.R.shade })
  c:paint({ "gg", "g." }, f.xa + 2, math.floor(f.ya) + 3, { g = f.R.gloss })
end
c:px(X0 - 2, YT - 1, GOLD.gloss); c:px(X1, YT - 1, GOLD.gloss)

local name = "cf-yi-bunting"
local t = c:save(OUT .. name .. ".aseprite", OUT .. name .. ".png")
print("bunting  " .. GV.report(t))
assert(t.semi == 0 and t.margin >= 3 and t.colours <= 24 and t.bw == 0, "check failed")
