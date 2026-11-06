-- fine-foraging-knife (pass B, final). A mushroom knife: slim hooked steel blade (convex spine, concave edge), brass bolster,
-- swelling olive-wood handle with wavy figure, brass ferrule and a boar-bristle brush at the butt.
-- Realism: polished blade with sky/ground reflection split + specular streak, dark grind ridge, lit bevel, bright edge
-- with a cool bounce near the hook; rounded brass bolster face; olive figure; splayed bristles with strands.
-- History: fine-foraging-knife.pA (pass A).
-- quirk: a thin slice of mushroom (cap and stem) stuck to the blade.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_b1g3.lua")
local HP, X, c, P = G.start(debug.getinfo(1, "S").source)
local K = G.K
local floor, max, min, abs, sqrt, sin = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin

local STEEL = { "#3c3e57", "#555973", "#72778f", "#9296ab", "#b7bacb", "#dddfe8" }
local SPEC, BOUNCE = "#f5f6fa", "#89a3c8"
local OLIVE = { "#3e2a1e", "#5e3e26", "#83592f", "#a87a3e", "#c99c58", "#e6c483" }
local FIG   = "#4a3020"
local BRASS = { "#73361c", "#a2521f", "#d0802a", "#eeab3a", "#ffd15e", "#fff0b4" }
local BRIS  = { "#6b5038", "#a8865e", "#d9bf8c", "#f3e2b8" }
local MUSH  = { "#7a4a36", "#b07850", "#e9d7b6", "#fbf1dc" }

-- axis frame: tip at O, running down-right; s > 0 is the lower-left (edge) side
local OX, OY = 10.5, 8.5
local ux, uy = 0.7071, 0.7071
local px, py = -0.7071, 0.7071
local function TS(x, y) local dx, dy = x - OX, y - OY return dx * ux + dy * uy, dx * px + dy * py end
local TB0, TB1, TH1, TF1, TE = 27, 30, 47, 49.5, 58.5   -- blade end, bolster end, handle end, ferrule end, brush end

local function spine(t) local q = max(0, 1 - t / 16) return -3.4 + 5.6 * q ^ 2.2 end     -- tip hooks toward the edge
local function edge(t)
  local w = 1 + 6.2 * min(1, t / 13) ^ 0.7 - 1.5 * sin(math.pi * min(1, t / TB0)) ^ 2   -- concave hook
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
    local spread = 2.1 + (t - TF1) * 0.5
    local tipcut = TE - 1.6 * (floor(s + 10) % 2) - 0.6 * abs(s) / spread
    if abs(s) <= spread and t < tipcut then brush:set(x, y) end
  end
end end

-- blade
blade:each(function(x, y)
  local k = K(x, y)
  local t, s = T[k], S[k]
  local sp, ed = spine(t), edge(t)
  local f = (s - sp) / max(1, ed - sp)          -- 0 spine .. 1 edge
  local i
  if f < 0.33 then i = 5                        -- flat, reflecting sky
  elseif f < 0.5 then i = (t > 6 and t < 21) and 7 or 5   -- specular streak on the horizon
  elseif f < 0.76 then i = 2                    -- ground reflection / grind ridge
  else i = 4 end                                -- bevel
  local onEdge = not blade:has(x - 1, y + 1) and (not blade:has(x, y + 1) or not blade:has(x - 1, y))
  local onSpine = not blade:has(x + 1, y - 1) and (not blade:has(x, y - 1) or not blade:has(x + 1, y))
  if onSpine then i = (t < 5) and 5 or 6 end
  if t > TB0 - 2 then i = max(1, min(6, i) - 2) end     -- AO toward the bolster
  c:put(x, y, i == 7 and SPEC or STEEL[i])
  if onEdge then c:put(x, y, t < 9 and BOUNCE or STEEL[6]) end
end)
-- maker's mark
c:px(28, 23, STEEL[2]) c:px(29, 24, STEEL[2])

-- bolster: rounded brass with a pale front face toward the blade
local bn = {}
bol:each(function(x, y) local s = S[K(x, y)] local q = max(-0.95, min(0.95, (s - 0.2) / 3.3)) bn[K(x, y)] = { px * q, py * q, sqrt(1 - q * q) } end)
G.paint(c, bol, X.light(bn, { amb = 0.1, wrap = 0.2 }), BRASS)
bol:each(function(x, y) local k = K(x, y)
  if T[k] < TB0 + 0.8 and S[k] < 0.8 then c:px(x, y, BRASS[6]) end
  if T[k] > TB1 - 0.8 then c:px(x, y, BRASS[2]) end end)

-- handle (olive wood): cylinder light + wavy dark figure + AO at the metal
local hn, hb = {}, {}
hdl:each(function(x, y)
  local k = K(x, y)
  local t, s = T[k], S[k]
  local q = max(-0.95, min(0.95, s / (hw(t) + 0.5)))
  hn[k] = { px * q, py * q, sqrt(1 - q * q) }
  local fig = q - 0.4 * sin(t * 0.5) - 0.15 * sin(t * 1.4 + 1)
  if abs(fig - 0.05) < 0.09 then hb[k] = -2 end
  if abs(fig + 0.75) < 0.08 and t % 5 > 1 then hb[k] = -1 end
  if t < TB1 + 1.2 or t > TH1 - 1.2 then hb[k] = (hb[k] or 0) - 1 end
end)
G.paint(c, hdl, X.light(hn, { amb = 0.14, wrap = 0.3 }), OLIVE, { 0.2, 0.36, 0.52, 0.7, 0.86 }, hb)

-- ferrule
local fn = {}
fer:each(function(x, y) local q = max(-0.95, min(0.95, S[K(x, y)] / 2.8)) fn[K(x, y)] = { px * q, py * q, sqrt(1 - q * q) } end)
G.paint(c, fer, X.light(fn, { amb = 0.1, wrap = 0.2 }), BRASS)
fer:each(function(x, y) if T[K(x, y)] > TF1 - 0.8 then c:px(x, y, BRASS[2]) end end)

-- brush: splayed bristles, strands along the axis, darker at the root and on the shade side
brush:each(function(x, y)
  local k = K(x, y)
  local t, s = T[k], S[k]
  local i = s > 1.2 and 2 or (s < -1.5 and 4 or 3)
  if (x - y) % 3 == 0 then i = max(1, i - 1) end
  if (x - y) % 5 == 1 and i < 4 then i = i + 1 end
  if t < TF1 + 1.3 then i = 1 end
  c:put(x, y, BRIS[i])
end)

-- quirk: mushroom slice on the blade flat (cap arc over pale gills, little stem) + its contact shadow
c:paint({
  ".aaab.",
  "abccdb",
  "bdddbb",
  ".bcdb.",
  ".bcdb.",
  "..bbe.",
}, 17, 16, { a = MUSH[2], b = MUSH[1], c = MUSH[4], d = MUSH[3], e = STEEL[2] })
c:px(23, 18, STEEL[2]) c:px(22, 19, STEEL[2])

G.fin(c)
