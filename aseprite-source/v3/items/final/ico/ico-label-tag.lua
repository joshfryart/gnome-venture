-- ico-label-tag (final, Opus). A kraft shipping tag hanging slightly tilted (top to the upper-left): chamfered top,
-- round reinforcement disc and brass eyelet, a twisted twine loop rising from the eyelet with a knot, two inked
-- lines of writing, and the lower-right corner dog-eared over.
-- Material: card = 6-tone kraft with a soft pillow bevel and a gentle curl, paper fibre dashes, paler reinforcement
-- disc; eyelet = brass ring with a bright edge and dark hole; twine = 3-tone twist ticks; dog-ear = paler back of the
-- card, dark fold line and a contact shadow under the flap.
-- quirk: someone doodled a tiny red gnome hat in the corner.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aA6_1.lua")
local HP, X, K = A.HP, A.X, A.K
local sqrt, abs, floor, max, min, pi, cos, sin = math.sqrt, math.abs, math.floor, math.max, math.min, math.pi, math.cos, math.sin
local c = A.new("ico-label-tag")
local KR = { "#51302b", "#7e4a30", "#a8693f", "#c98c56", "#e2ae72", "#f6d9a2" }
local TW = { "#6a4630", "#a47a4e", "#d6b07a", "#f0d5a0" }
local BR = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local INKL = "#5a3030"
local HAT = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local ptok, ttok, btok = { r = { name = "card" } }, { r = { name = "twine" } }, { r = { name = "brass" } }

local OX, OY, ANG = 33, 38, pi / 2 - 0.2        -- u runs down the tag, +v points left
local UT, UB, HW = -17, 15, 11
local tag, U, V, F = A.local_mask(OX, OY, ANG, 26, function(u, v)
  if u < UT or u > UB then return false end
  local w = HW
  if u < UT + 7 then w = HW - (UT + 7 - u) * 1.0 end
    return abs(v) <= w
end)
local function scr(u, v) return OX + F.ux * u + F.vx * v, OY + F.uy * u + F.vy * v end
local EU = UT + 4.6
local ex, ey = scr(EU, 0)

-- twine loop (behind the card top), knot at the eyelet
local loop = { { ex - 1, ey }, { ex - 20, ey - 19 }, { ex + 17, ey - 23 }, { ex + 1, ey - 0.5 } }
local lm, ln, LT, LS = A.tube(loop, function(t) return 1.3 end, 240)
local LEN = 60
lm:each(function(x, y) local k = K(x, y)
  local s, t = LS[k], LT[k]
  local tw = (t * LEN + s * 2.2) % 3
  local i = (tw < 1) and 4 or (tw < 2) and 3 or 2
  if s > 0.55 then i = i - 1 end
  if s < -0.6 and i < 4 then i = i + 1 end
  c:put(x, y, TW[max(1, min(4, i))], ttok)
end)

-- card: soft pillow + gentle curl across v
local n0, d = X.pillow(tag, 1.6)
local n = {}
for k, a in pairs(n0) do
  local v = V[k]
  local cx = -0.3 * (v / HW)          -- slight cylindrical curl
  n[k] = { A.norm(a[1] + F.vx * cx, a[2] + F.vy * cx, a[3]) }
end
local bias = {}
tag:each(function(x, y) local k = K(x, y) if V[k] < -HW + 2.2 then bias[k] = -1 end end)
local idx = A.shade(c, tag, n, KR, { tok = ptok, amb = 0.12, wrap = 0.3, cuts = { 0.2, 0.36, 0.54, 0.72, 0.88 }, bias = bias })
-- fibre dashes (2 px, along the card)
for _, f in ipairs{ { -4, 6 }, { 3, -6 }, { 9, 4 }, { -9, -5 }, { 6, 7.5 }, { 11, -2 } } do
  for i = 0, 1 do local x, y = scr(f[1] + i, f[2]) x, y = floor(x + 0.5), floor(y + 0.5)
    if tag:has(x, y) then A.step(c, idx, KR, x, y, -1, ptok) end end
end
-- reinforcement disc (paler card, darker rim on the lower-right)
local disc = A.ell(ex, ey, 4.2, 4.2)
disc:each(function(x, y) if tag:has(x, y) then
  local dx, dy = x - ex, y - ey
  local r = sqrt(dx*dx + dy*dy)
  local col = KR[5]
  if r > 3.4 then col = (dx + dy > 0) and KR[3] or KR[6] end
  c:put(x, y, col, ptok)
end end)
-- eyelet: brass ring + dark hole
local ring = A.ell(ex, ey, 2.6, 2.6)
ring:each(function(x, y)
  local dx, dy = x - ex, y - ey
  local col = (dx + dy < -1.5) and BR[4] or (dx + dy > 1.5) and BR[1] or BR[2]
  if dx + dy < -0.5 and dx + dy >= -1.5 then col = BR[3] end
  c:put(x, y, col, btok)
end)
local hole = A.ell(ex, ey, 1.1, 1.1)
hole:each(function(x, y) c:put(x, y, A.INK, btok) end)
-- twine knot over the eyelet top (front strand)
A.map(c, { ".ab.", "abbc", ".cc." }, floor(ex) - 2, floor(ey) - 4, { a = TW[4], b = TW[3], c = TW[1] }, ttok)

-- writing: two inked lines (broken into words)
local function lineAt(u, v0, v1, gaps)
  for v = v1, v0, -0.5 do
    local skip = false
    for _, g in ipairs(gaps) do if v <= g + 0.6 and v >= g - 0.6 then skip = true end end
    if not skip then local x, y = scr(u, v) x, y = floor(x + 0.5), floor(y + 0.5)
      if tag:has(x, y) then c:put(x, y, INKL, ptok) end end
  end
end
lineAt(-4.5, -6, 6, { 1 })
lineAt(-0.5, -6, 4, { -2.5 })
lineAt(3.5, -2, 6, {})

-- dog-ear on the lower-right corner (v = -HW side, u = UB)
local DE = 7
tag:each(function(x, y) local k = K(x, y)
  local a, b = UB - U[k], V[k] + HW
  if a + b < DE then c.pix[y * c.w + x] = nil c.own[y * c.w + x] = nil end
end)
local flap = HP.mask()
tag:each(function(x, y) local k = K(x, y)
  local a, b = UB - U[k], V[k] + HW
  if a <= DE and b <= DE and a + b >= DE then
    flap:set(x, y)
    local col = (a + b < DE + 1.1) and KR[2] or ((a < 1.2 or b < 1.2) and KR[4] or KR[6])
    c:put(x, y, col, ptok)
  elseif (a > DE and a < DE + 1.6 and b < DE + 1) or (b > DE and b < DE + 1.6 and a < DE + 1) then
    A.step(c, idx, KR, x, y, -2, ptok)      -- contact shadow beside the flap
  end
end)

-- quirk: tiny red gnome hat doodle (upright, lower-left area of the card)
local hx, hy = scr(9.5, 4.5) hx, hy = floor(hx + 0.5), floor(hy + 0.5)
A.map(c, {
  "...h..",
  "..hr..",
  "..hrr.",
  ".hrrd.",
  ".hrrrd",
  "ccccbb",
}, hx - 3, hy - 3, { h = HAT[4], r = HAT[3], d = HAT[2], c = "#fff4d6", b = "#e0cfae" }, ptok)
A.save(c, "ico-label-tag")
