-- opening-day-bunting (final pass, Opus aC31_1). A swag of twisted jute cord with a bead knot at each end and five
-- slim cloth pennants (ember, gold, sea, petal, moss) hung over it on a folded sleeve. Material: cord twist (2-tone
-- diagonal strands), 6-tone cloth with soft vertical ripples, diagonal weave on the lit tones, dark sleeve fold + AO
-- under the cord, lower cloth a step darker, gold stitch along the centre pennant's hem, one sparkle.
-- quirk: a tiny brown wren perches on the cord between the middle pennants.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "opening-day-bunting"
local c = A.new(NAME)
local R = {
  { "#5e1a34", "#8e2438", "#c2343c", "#e8493b", "#ff7a54", "#ffb07a" },
  { "#7a3c1c", "#b0631f", "#d98322", "#f5b82e", "#ffd860", "#fff0a8" },
  { "#253f6e", "#2f6496", "#3a86b0", "#5fc4c8", "#8fe0d8", "#c8f6ea" },
  { "#6a2452", "#9c3a72", "#c94f84", "#f5809f", "#ffa8c0", "#ffd2e0" },
  { "#1f4a42", "#2f6e4c", "#3f9150", "#7cc35a", "#a6d86c", "#d2ee98" },
}
local CORD = { "#5a3a2a", "#8a5e3a", "#b98a58", "#e0bc86" }
local function sy(x) local u = (x - 31.5) / 26 return 13 + 7 * (1 - u * u) end
local function cy(x) return floor(sy(x) + 0.5) end

-- pennants
for i = 1, 5 do
  local x0 = 10 + (i - 1) * 9
  local x1, xc = x0 + 6, x0 + 3
  local L = 19 + ((i == 3) and 2 or 0) + ((i % 2 == 0) and 1 or 0)
  local sway = ({ -1, 0, 0, 1, 1 })[i]
  local tipy = cy(xc) + L
  local m = HP.mask()
  for y = cy(x0) + 1, tipy do
    local f = (y - (cy(xc) + 1)) / (tipy - cy(xc) - 1)
    local hwid = 3.5 * (1 - max(0, f)) ^ 0.95
    local mid = xc + 0.0 + sway * max(0, f) ^ 2
    for x = x0, x1 do
      if y > cy(x) and abs(x - mid) <= hwid + 0.05 then m:set(x, y) end
    end
  end
  local n, vadd = {}, {}
  m:each(function(x, y) local k = K(x, y)
    local top = cy(x)
    local f = (y - top) / L
    n[k] = { A.norm(0.42 * sin((x - x0) * 1.15 + i * 0.7) - 0.15, -0.15, 1) }
    vadd[k] = -0.22 * f
  end)
  local ramp = R[i]
  local tok = { r = { name = "pennant" .. i } }
  local idx = A.shade(c, m, n, ramp, { tok = tok, vadd = vadd, amb = 0.15, wrap = 0.35, cuts = { 0.16, 0.32, 0.5, 0.68, 0.84 } })
  m:each(function(x, y) local d = y - cy(x)
    if d == 1 then A.step(c, idx, ramp, x, y, -3, tok)          -- AO under the cord
    elseif d == 2 then A.step(c, idx, ramp, x, y, 1, tok)       -- sleeve ridge, lit
    elseif d == 3 then A.step(c, idx, ramp, x, y, -2, tok)      -- sleeve seam fold
    elseif (x + y) % 4 == 0 and idx[K(x, y)] >= 4 then A.step(c, idx, ramp, x, y, -1, tok) end  -- weave
  end)
  if i == 3 then
    local pts = {} for x = x0, x1 do pts[#pts + 1] = { x, cy(x) + 4 } end
    for j, p in ipairs(pts) do if j % 3 ~= 0 then c:put(p[1], p[2], "#ffe38a", tok) end end
  end
end

-- cord: 2 px, twisted strands
local ctok = { r = { name = "cord" } }
for x = 9, 53 do
  local y = cy(x)
  c:put(x, y - 1, (x % 3 == 0) and CORD[2] or CORD[3], ctok)
  c:put(x, y, (x % 3 == 1) and CORD[3] or CORD[1], ctok)
end
c:put(20, cy(20) - 1, CORD[4], ctok) c:put(21, cy(21) - 1, CORD[4], ctok)
-- bead knots at the ends, with a short tail
local function knot(x, y, dir)
  A.map(c, { ".ab.", "abbc", "bccd", ".cd." }, x - 1, y - 2, { a = CORD[4], b = CORD[3], c = CORD[2], d = CORD[1] }, ctok)
  for j = 1, 3 do c:put(x + 1 + (dir < 0 and -1 or 0) + floor(j * 0.4) * dir, y + 1 + j, j < 3 and CORD[3] or CORD[2], ctok) end
end
knot(7, cy(8), -1)
knot(54, cy(54), 1)

-- quirk: a tiny wren on the cord between pennants 3 and 4
local wx = 36
local wy = cy(wx) - 2
A.map(c, {
  ".....hh.",
  "....hbKb",
  "t..hbbbbo",
  ".tbbwbbd.",
  "..dbbbd..",
  "...dKK...",
}, wx - 4, wy - 5, { h = "#c99062", b = "#9a6440", d = "#5e3a2c", w = "#e8c49a", K = "#2b1c26", t = "#7a4e34", o = "#f5b82e" }, { r = { name = "wren" } })
c:put(wx + 2, wy - 4, "#fff4d6", { r = { name = "wren" } })
c:sparkle(14, cy(14) + 6)

A.save(c, NAME)
