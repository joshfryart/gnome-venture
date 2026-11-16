-- pass (32x32 trail map marker, Opus pass). Two slate-blue peaks with snow caps and a low saddle between
-- them; a zig-zag path climbs the near peak to the saddle, where a red flag stands up in the open V of sky
-- (so the flag sits in front, never hidden behind a peak). Lit faces on the left of each ridge.
-- quirk: the flag is a gnome's red-and-cream striped scarf, knotted to a crooked walking staff (the staff tier).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local T = dofile(DIR .. "/_trail.lua")
local c = T.new("pass")

local FAR = { lit = "#8f8cc0", mid = "#6a66a2", sh = "#4e4984", dp = "#34305a" }
local NEAR = { lit = "#b9b3e0", mid = "#8a83c4", sh = "#635b9e", dp = "#433b74" }
local SNOW = { hi = "#fff4d6", mid = "#e6e8f6", sh = "#b4bedf" }

local function peak(ax, ay, xl, xr, yb, R, snowY)
  local m = c:poly{ { ax, ay }, { xr, yb }, { xl, yb } }
  m:each(function(x, y)
    -- ridge runs from the apex down and slightly right; left of it is lit
    local ridge = ax + (y - ay) * 0.25
    local col
    if x < ridge then col = R.lit else col = R.mid end
    if x >= ridge + (y - ay) * 0.35 + 2 then col = R.sh end
    if y >= yb - 1 then col = R.dp end
    c:put(x, y, col)
  end)
  -- snow cap with a drippy hem
  m:each(function(x, y)
    local ridge = ax + (y - ay) * 0.25
    local hem = snowY + ({ 0, 2, 1, 3 })[x % 4 + 1]
    if y <= hem then c:put(x, y, x < ridge and SNOW.hi or (x < ridge + 2 and SNOW.mid or SNOW.sh)) end
  end)
  return m
end

local far = peak(26, 9, 13, 31, 29, FAR, 12)
local near = peak(9, 2, 0, 24, 29, NEAR, 7)
-- seam where the near slope crosses the far peak
c:line({ { 9, 2 }, { 24, 29 } }, 1):each(function(x, y) if far:has(x + 1, y) and y > 15 then c:put(x, y, NEAR.dp) end end)
-- rock strata on the faces
for _, l in ipairs{ { { 3, 20 }, { 6, 19 } }, { { 7, 24 }, { 10, 23 } }, { { 13, 13 }, { 15, 12 } }, { { 4, 15 }, { 7, 14 } }, { { 26, 18 }, { 28, 19 } }, { { 27, 23 }, { 29, 24 } }, { { 22, 24 }, { 25, 25 } } } do
  c:line(l, 1):each(function(x, y) local h = c:get(x, y) if h then c:put(x, y, (x < 20 and NEAR.mid) or FAR.dp) end end)
end

-- zig-zag path up to the saddle (tan, lit top edge)
local PATH = { "#c98f5a", "#e8b982", "#f3d4a4" }
for _, l in ipairs{ { { 9, 28 }, { 16, 25 } }, { { 16, 25 }, { 10, 21 } }, { { 10, 21 }, { 15, 17 } }, { { 15, 17 }, { 17, 15 } } } do
  c:line(l, 1):each(function(x, y) c:put(x, y, PATH[2]) if c:get(x, y + 1) and y < 29 then c:put(x, y + 1, PATH[1]) end end)
end
c:put(9, 28, PATH[3]) c:put(10, 21, PATH[3]) c:put(16, 25, PATH[3])

-- walking staff planted at the saddle, standing up in the open V of sky, crook on top
c:line({ { 17, 7 }, { 17, 16 } }, 1):each(function(x, y) c:put(x, y, "#864c33") end)
c:put(16, 7, "#b97a4a") c:put(16, 6, "#b97a4a") c:put(17, 5, "#b97a4a") c:put(18, 5, "#864c33") c:put(19, 6, "#864c33")
c:put(16, 10, "#b97a4a") c:put(16, 13, "#b97a4a")
-- striped scarf knotted under the crook, flying right
T.grid(c, 18, 7, {
  "Krrccrr.",
  "Krrccrrf",
  ".ssccss.",
  "..f...f.",
}, { K = "#b52e3f", r = "#e8493b", c = "#fff4d6", s = "#b52e3f", f = "#f5b82e" })
c:put(25, 8, "#f5b82e")
T.done(c)
