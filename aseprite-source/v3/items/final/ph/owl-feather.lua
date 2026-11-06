-- owl-feather (final, Opus single pass aC31_3). A slim curved owl flight feather on the diagonal: narrow leading
-- vane (upper left), broad soft trailing vane (lower right) with a comb-fringed edge, barred cream / tawny / umber
-- bands that sweep back along the barbs, fine barb lines, a pale horn rachis with a bright edge, a bare translucent
-- calamus at the base and a grey downy afterfeather where the vane starts (AO where vane meets shaft).
-- quirk: the trailing vane is "unzipped" in one place: a small V split where the barbs have parted.
local NAME = "owl-feather"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new(NAME)

local VANE = { "#3b2520", "#5d3b2b", "#83573a", "#a97b4f", "#cfa36f", "#ecd3a2" }
local BAR  = { "#2f1c1e", "#46291f", "#613a26", "#7c4e30", "#9a6a42", "#b98a5a" } -- umber bars
local PALE = { "#8a6a54", "#b09276", "#cdb393", "#e2cfae", "#f1e3c6", "#fbf1dc" } -- cream bars
local HORN = { "#6e5844", "#9a8266", "#c2ab88", "#ddc9a6", "#efe2c4", "#fff4d6" }
local DOWN = { "#6f6878", "#8f889a", "#b2acbb", "#d2cdd6" }

-- vane along a quadratic curve from base (A) to tip (B)
local AX, AY, CX, CY, BX, BY = 19, 50, 27, 24, 51, 9
local WT, WL = 8.6, 3.8     -- trailing / leading half widths
local vm, vn, VT, VS, len = G.blade(AX, AY, CX, CY, BX, BY, function(t)
  if t > 0.99 then return -1 end
  local u = min(1, t * 1.05)
  return max(0.6, WT * sin(pi * min(1, 0.18 + u * 0.82)) ^ 0.45 * (1 - 0.15 * t))
end, { fold = 0.3 })
-- asymmetric vane: S<0 is the lit (upper-left) leading side, keep it narrow
local drop = {}
vm:each(function(x, y) local k = K(x, y) local s, t = VS[k], VT[k]
  local w = max(0.6, WT * sin(pi * min(1, 0.18 + min(1, t * 1.05) * 0.82)) ^ 0.45 * (1 - 0.15 * t))
  local sp = s * (w + 0.6)
  if s < 0 and -sp > WL * (0.55 + 0.45 * sin(pi * min(1, t * 1.1))) then drop[#drop + 1] = k end
  -- comb fringe on the trailing edge: notch every 3 px along the length (owl's soft edge)
  if s > 0 and sp > w - 0.7 and t > 0.12 and t < 0.93 then
    local ph = (t * len - sp * 0.9) / 3.0
    if ph - floor(ph) < 0.34 then drop[#drop + 1] = k end
  end
  -- quirk: a V split in the trailing vane (barbs parted)
  local q = t * len - sp * 0.85
  if s > 0.28 and q > 0.555 * len - 0.6 - (sp - 2) * 0.35 and q < 0.555 * len + 0.6 + (sp - 2) * 0.35 then drop[#drop + 1] = k end
  -- trim the base so the vane starts cleanly above the down
  if t < 0.05 then drop[#drop + 1] = k end
end)
for _, k in ipairs(drop) do vm.s[k] = nil end

-- shaft line samples (the curve itself)
local function qpt(t) local u = 1 - t return u*u*AX + 2*u*t*CX + t*t*BX, u*u*AY + 2*u*t*CY + t*t*BY end
local shaft = HP.mask()
for i = 0, 200 do local t = i / 200 if t < 0.97 then local x, y = qpt(t) shaft:set(floor(x + .5), floor(y + .5)) end end

-- tone the vane: base light + bars + barb lines + AO next to the shaft
local bias = {}
X.ao(bias, vm, shaft, 1, -1)
local vtok = { r = { name = "vane" } }
local v = X.light(vn, { amb = 0.16, wrap = 0.35 })
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }
vm:each(function(x, y) local k = K(x, y)
  if shaft:has(x, y) then return end
  local s, t = VS[k], VT[k]
  local val = v[k]
  local i = 1 for j, ct in ipairs(CUTS) do if val >= ct then i = j + 1 end end
  i = i + (bias[k] or 0)
  -- bars sweep back toward the base, away from the shaft
  local ph = (t * len + abs(s) * 4.2) / 7.2
  local f = ph - floor(ph)
  local R = VANE
  if t > 0.1 then
    if f < 0.36 then R = BAR elseif f > 0.58 and f < 0.86 then R = PALE end
  end
  -- barb lines on the broad vane: one tone down every 2 px along the barb direction
  if R ~= VANE then i = max(2, min(5, i)) end
  -- one barb line inside each tawny band (fine texture)
  if R == VANE and f > 0.42 and f < 0.48 and abs(s) > 0.2 then i = i - 1 end
  -- tip and edges darken a little (rounded vane)
  if t > 0.9 then i = i - 1 end
  c:put(x, y, R[max(1, min(6, i))], vtok)
end)

-- rachis: pale horn, bright edge on the lit side
local htok = { r = { name = "rachis" } }
for i = 0, 200 do local t = i / 200
  if t >= 0.0 and t < 0.95 then
    local x, y = qpt(t)
    local xi, yi = floor(x + .5), floor(y + .5)
    c:put(xi, yi, t < 0.5 and HORN[4] or HORN[3], htok)
  end
end
-- lit edge along the lower half of the rachis (upper-left side of the line)
for i = 0, 120 do local t = i / 200
  local x, y = qpt(t)
  local xi, yi = floor(x + .5) - 1, floor(y + .5)
  if vm:has(xi, yi) and not shaft:has(xi, yi) and t > 0.08 then c:put(xi, yi, HORN[5], htok) end
end

-- calamus: bare translucent quill, slightly wider, below the vane
local cp = { { 19.3, 50.5 }, { 18, 53.5 }, { 16.5, 56 }, { 14.5, 58.5 } }
local cm, cn, CT, CS = G.tube(cp, function(t) return 1.25 - 0.45 * t end)
local ctok = { r = { name = "calamus" } }
local ci = G.toneN(c, cm, cn, HORN, { tok = ctok, amb = 0.14, wrap = 0.3, cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
-- hollow core line (pale) and dark tip
cm:each(function(x, y) local k = K(x, y)
  if CT[k] > 0.25 and CT[k] < 0.8 and abs(CS[k]) < 0.25 then c:put(x, y, HORN[5], ctok) end
  if CT[k] > 0.9 then c:put(x, y, HORN[2], ctok) end
end)

-- afterfeather: grey down wisps at the vane base (drawn as soft little curls on both sides of the shaft)
local dtok = { r = { name = "down" } }
local dm = HP.mask()
for _, q in ipairs{ { 22.5, 51.5, 2.6, 1.7, -0.5 }, { 25.5, 51, 1.8, 1.2, -0.2 }, { 16.2, 48.6, 2.2, 1.5, -2.2 }, { 21, 54, 1.6, 1.1, 0.3 } } do
  dm:add((G.oval(q[1], q[2], q[3], q[4], q[5])))
end
dm:cut(vm):cut(cm)
-- wispy ends: a few 1px strands
for _, q in ipairs{ { 28, 50 }, { 29, 49 }, { 13, 47 }, { 14, 46 }, { 23, 56 } } do dm:set(q[1], q[2]) end
local dn = X.pillow(dm, 1.5)
G.toneN(c, dm, dn, { DOWN[1], DOWN[1], DOWN[2], DOWN[3], DOWN[4], "#e6e2ea" }, { tok = dtok, amb = 0.2, wrap = 0.4 })
-- strands: lighter lines inside the puff following the fluff
dm:each(function(x, y) if (x + 2 * y) % 4 == 0 and dm:has(x + 1, y) and dm:has(x - 1, y) then c:put(x, y, DOWN[2], dtok) end end)
-- AO where down meets the calamus
for _, q in ipairs{ { 20, 51 }, { 18, 50 }, { 20, 52 } } do if dm:has(q[1], q[2]) then c:put(q[1], q[2], DOWN[1], dtok) end end

-- glint: one cream 2x1 on the lit leading vane near the upper third, plus spec on the quill
do
  local bx, by = G.specAt(vm, vn, 30)
  c:put(bx, by, "#fff4d6", vtok)
end
c:put(17, 54, "#fff4d6", ctok)

G.save(c, NAME)
