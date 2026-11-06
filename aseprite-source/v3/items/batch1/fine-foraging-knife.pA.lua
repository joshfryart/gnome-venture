-- fine-foraging-knife (pass A). A mushroom knife: slim hooked steel blade (convex spine, concave edge), brass bolster,
-- swelling olive-wood handle with wavy figure, brass ferrule and a boar-bristle brush at the butt.
-- quirk: a thin slice of mushroom cap stuck to the blade.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_b1g3.lua")
local HP, X, c, P = G.start(debug.getinfo(1, "S").source)
local K = G.K
local floor, max, min, abs, sqrt, sin = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin

local STEEL = { "#3c3e57", "#555973", "#72778f", "#9296ab", "#b7bacb", "#dddfe8" }
local SPEC  = "#f5f6fa"
local OLIVE = { "#3e2a1e", "#5e3e26", "#83592f", "#a87a3e", "#c99c58", "#e6c483" }
local FIG   = "#4a3020"
local BRASS = { "#73361c", "#a2521f", "#d0802a", "#eeab3a", "#ffd15e", "#fff0b4" }
local BRIS  = { "#6b5038", "#a8865e", "#d9bf8c", "#f3e2b8" }
local MUSH  = { "#7a4a36", "#b07850", "#e9d7b6", "#fbf1dc" }

-- axis frame: tip at O, running down-right; s > 0 is the lower-left (edge) side
local OX, OY = 9.5, 8.5
local ux, uy = 0.7071, 0.7071
local px, py = -0.7071, 0.7071
local function TS(x, y) local dx, dy = x - OX, y - OY return dx * ux + dy * uy, dx * px + dy * py end
local TB0, TB1, TH1, TF1, TE = 27, 30, 49, 51.5, 59   -- blade end, bolster end, handle end, ferrule end, brush end

local function spine(t) local q = max(0, 1 - t / 17) return -3.4 + 5.2 * q * q end     -- tip hooks toward the edge
local function edge(t)
  local w = 1 + 5 * min(1, t / 12) ^ 0.7 - 1.1 * sin(math.pi * min(1, t / TB0)) ^ 2   -- concave hook
  return spine(t) + max(1, w)
end
local function hw(t)   -- handle half width (swells to the butt)
  local u = (t - TB1) / (TH1 - TB1)
  return 1.7 + 0.9 * sin(math.pi * min(1, u * 0.85 + 0.15)) ^ 0.8
end

local blade, bol, hdl, fer, brush = HP.mask(), HP.mask(), HP.mask(), HP.mask(), HP.mask()
local T, S = {}, {}
for y = 0, 63 do for x = 0, 63 do
  local t, s = TS(x, y)
  local k = K(x, y)
  T[k], S[k] = t, s
  if t >= 0 and t < TB0 and s >= spine(t) - 0.5 and s <= edge(t) + 0.5 then blade:set(x, y)
  elseif t >= TB0 and t < TB1 and abs(s - 0.2) <= 2.9 then bol:set(x, y)
  elseif t >= TB1 and t < TH1 and abs(s) <= hw(t) then hdl:set(x, y)
  elseif t >= TH1 and t < TF1 and abs(s) <= 2.3 then fer:set(x, y)
  elseif t >= TF1 and t < TE then
    local spread = 2.2 + (t - TF1) * 0.33
    if abs(s) <= spread and not (t > TE - 1.5 and (floor(s * 1.4) % 2 == 0)) then brush:set(x, y) end
  end
end end

-- blade: polished flat (upper half sky-lit) + ground bevel along the edge, bright edge, spine catches light
blade:each(function(x, y)
  local k = K(x, y)
  local t, s = T[k], S[k]
  local sp, ed = spine(t), edge(t)
  local f = (s - sp) / max(1, ed - sp)          -- 0 spine .. 1 edge
  local i
  if f < 0.18 then i = 5
  elseif f < 0.5 then i = 4
  elseif f < 0.62 then i = 2                    -- grind line (ridge)
  else i = 3 end
  if not blade:has(x, y + 1) and not blade:has(x - 1, y) then i = 6 end   -- cutting edge (lower-left boundary)
  if not blade:has(x, y - 1) and not blade:has(x + 1, y) then i = 6 end   -- spine highlight
  if t > TB0 - 2.5 then i = max(1, i - 1) end  -- AO toward the bolster
  c:put(x, y, STEEL[i])
end)
-- specular streak on the flat
for t = 6, 16 do
  local s = spine(t) + 1.2
  local x, y = floor(OX + t * ux + s * px + 0.5), floor(OY + t * uy + s * py + 0.5)
  if blade:has(x, y) then c:px(x, y, SPEC) end
end

-- bolster (brass, banded)
local bn = {}
bol:each(function(x, y) local s = S[K(x, y)] local q = max(-0.95, min(0.95, (s - 0.2) / 3.3)) bn[K(x, y)] = { px * q, py * q, sqrt(1 - q * q) } end)
G.paint(c, bol, X.light(bn, { amb = 0.1, wrap = 0.2 }), BRASS)

-- handle (olive wood): cylinder light + wavy dark figure + pale streaks
local hn, hb = {}, {}
hdl:each(function(x, y)
  local k = K(x, y)
  local t, s = T[k], S[k]
  local q = max(-0.95, min(0.95, s / (hw(t) + 0.5)))
  hn[k] = { px * q, py * q, sqrt(1 - q * q) }
  local fig = q - 0.35 * sin(t * 0.55) - 0.15 * sin(t * 1.3 + 1)
  if abs(fig - 0.1) < 0.09 then hb[k] = -2 end
  if t < TB1 + 1.2 or t > TH1 - 1.2 then hb[k] = (hb[k] or 0) - 1 end            -- AO at the metal joints
end)
G.paint(c, hdl, X.light(hn, { amb = 0.12, wrap = 0.3 }), OLIVE, nil, hb)

-- ferrule
local fn = {}
fer:each(function(x, y) local q = max(-0.95, min(0.95, S[K(x, y)] / 2.8)) fn[K(x, y)] = { px * q, py * q, sqrt(1 - q * q) } end)
G.paint(c, fer, X.light(fn, { amb = 0.1, wrap = 0.2 }), BRASS)

-- brush: bristles as strands along the axis, darker toward the ferrule and on the shade side
brush:each(function(x, y)
  local k = K(x, y)
  local t, s = T[k], S[k]
  local strand = floor(s * 1.6 + 20) % 3
  local i = 3
  if s > 1 then i = 2 end
  if s < -1 then i = 4 end
  if strand == 0 then i = max(1, i - 1) end
  if t < TF1 + 1.2 then i = 1 end
  c:put(x, y, BRIS[i])
end)

-- quirk: mushroom slice on the blade flat (cap brown arc over pale gills)
c:paint({
  ".aaab.",
  "abcccb",
  "bcdddb",
  "..cd..",
  "..cd..",
  "..bb..",
}, 15, 16, { a = MUSH[2], b = MUSH[1], c = MUSH[4], d = MUSH[3] })

G.fin(c)
