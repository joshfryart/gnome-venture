-- mini-bog-leech (61x31 still, side view, faces right). Opus second pass.
-- Named defect: it read as a worm / caterpillar blob. Fixes: the classic leech loop (body arched up,
-- big rear sucker disc planted on the ground, small front sucker with a tooth ring reaching down),
-- a tapered body (fat rear, thin neck), fine annulation rings, and the medicinal-leech orange side
-- stripe with dark dorsal spots. Kept from the game picture: moss-green ramp, the pale rear end,
-- the eye at the front and the little sprout on the back (quirk).
local NAME = "mini-bog-leech"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local function R(hi, base, shade, deep) return { hi = hi, base = base, shade = shade, deep = deep } end
local BODY = R("#a8d870", "#6aae52", "#3f8350", "#285646")
local BELLY = R("#d8e8a0", "#b4cc80", "#84a268", "#56704e")
local STRIPE = R("#ffc070", "#f0943c", "#c0642e", "#7e3a2a")
local SUCK = R("#c8dc94", "#98b874", "#6a8a5c", "#46604c")
local W, H = 61, 31

local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
c:groundShadow(30, 27, 26, 2)
-- trim the 1 px nubs at the top and bottom tips of the shadow ellipse
for y = 0, c.h - 1 do for x = 0, c.w - 1 do local i = y * c.w + x
  if c.pix[i] and not c.pix[i - 1] and not c.pix[i + 1] then c.pix[i], c.own[i] = nil, nil end end end

-- spine: cubic Bezier from the rear sucker (left) over the arch to the front sucker (right)
local P0, P1, P2, P3 = { 11, 21 }, { 17, 6 }, { 41, 5 }, { 51, 21 }
local function bez(t)
  local u = 1 - t
  return u^3 * P0[1] + 3 * u^2 * t * P1[1] + 3 * u * t^2 * P2[1] + t^3 * P3[1],
         u^3 * P0[2] + 3 * u^2 * t * P1[2] + 3 * u * t^2 * P2[2] + t^3 * P3[2]
end
local function tan(t) local a, b = bez(math.max(0, t - 0.01)) local x, y = bez(math.min(1, t + 0.01)) return x - a, y - b end
local function rad(t) return 5.2 - 2.6 * t end -- fat rear, thin neck
local body, samples = HP.mask(), {}
for i = 0, 200 do
  local t = i / 200
  local x, y = bez(t)
  samples[#samples + 1] = { x, y, t }
  body:add(HP.ellipse(x, y, rad(t), rad(t)))
end
-- rear sucker disc: a flat oval foot on the ground
local rear = c:ellipse(9, 24, 7, 2.5)
c:part(rear, SUCK, { band = 1, pop = { x = 4, y = 23 } })
c:fillMask(c:line({ { 4, 25 }, { 14, 25 } }, 1), SUCK.deep)
-- body
c:part(body, BODY, { band = 2, nopop = true })
-- belly: the inner (under) side of the arch is paler
local belly = HP.mask()
for _, s in ipairs(samples) do
  local x, y, t = s[1], s[2], s[3]
  local dx, dy = tan(t)
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = -dy / L, dx / L -- normal pointing to the inside (under) of the arch
  if ny < 0 then nx, ny = -nx, -ny end
  local r = rad(t)
  for k = r - 1.6, r - 0.4, 0.4 do belly:set(math.floor(x + nx * k), math.floor(y + ny * k)) end
end
belly:clip(body)
c:fillMask(belly, BELLY.shade)
-- orange side stripe along the middle of the body, dark dorsal spots above it
for _, s in ipairs(samples) do
  local x, y, t = s[1], s[2], s[3]
  local dx, dy = tan(t)
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = dy / L, -dx / L
  if ny > 0 then nx, ny = -nx, -ny end -- outward (top) normal
  if t > 0.06 and t < 0.78 then
    local sx, sy = math.floor(x + nx * 0.4), math.floor(y + ny * 0.4)
    if body:has(sx, sy) then c:put(sx, sy, STRIPE.base) end
  end
end
-- annulation: fine rings across the body every few samples
for i = 14, #samples - 24, 8 do
  local x, y, t = samples[i][1], samples[i][2], samples[i][3]
  local dx, dy = tan(t)
  local L = math.sqrt(dx * dx + dy * dy)
  local nx, ny = dy / L, -dx / L
  if ny > 0 then nx, ny = -nx, -ny end
  local r = rad(t)
  for k = -r + 0.8, -r + 2.4, 0.5 do -- rings show on the lower (shaded) half only, top stays glossy
    local px, py = math.floor(x + nx * k), math.floor(y + ny * k)
    if body:has(px, py) and c:get(px, py) ~= STRIPE.base then c:put(px, py, c:get(px, py) == BELLY.shade and BELLY.deep or BODY.shade) end
  end
  -- dorsal spot (off)
  local px, py = math.floor(x + nx * (r - 1.6)), math.floor(y + ny * (r - 1.6))
  if false then c:put(px, py, BODY.deep) end
end
-- glossy top: lit band along the outside of the arch (upper-left light)
for _, s in ipairs(samples) do
  local x, y, t = s[1], s[2], s[3]
  if t > 0.12 and t < 0.55 then
    local dx, dy = tan(t)
    local L = math.sqrt(dx * dx + dy * dy)
    local nx, ny = dy / L, -dx / L
    if ny > 0 then nx, ny = -nx, -ny end
    local k = rad(t) - 1.2
    local px, py = math.floor(x + nx * k), math.floor(y + ny * k)
    if body:has(px, py) then c:put(px, py, BODY.hi) end
  end
end
-- front sucker: a small cup at the mouth with a pale tooth ring
local fs = c:ellipse(52.5, 24, 3.5, 2)
c:part(fs, SUCK, { band = 1, nopop = true })
c:fillMask(c:line({ { 51, 25 }, { 54, 25 } }, 1), SUCK.deep)
c:put(52, 24, SUCK.deep) c:put(53, 24, SUCK.shade)
-- eye on the narrow head
local ex, ey = bez(0.88)
c:eyeSmall(math.floor(ex) - 1, math.floor(ey) - 2)
-- quirk: a two-leaf sprout riding on the top of the loop
c:fillMask(c:line({ { 27, 5 }, { 27, 3 } }, 1), P.moss.shade)
c:paint({ "hll.Lhh", "llldLLL" }, 24, 1, { h = "moss.hi", l = "moss.base", L = "moss.base", d = "moss.shade" })
c:finish{ outline = true }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
