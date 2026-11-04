-- _dC20: helpers for the ph/l* chunk (first drafts). Wraps batch2/_b2.lua (read only).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
local D = { B = B, H = H, HP = HP, X = X }
D.R = {
  GREEN = { "#163a35", "#1f553f", "#2b7046", "#3f8f4c", "#62ad55", "#93cb68" },
  DKLEAF = { "#10302e", "#194a38", "#25633f", "#357e44", "#52a04e", "#86c266" },
  LIME = { "#1f4a2e", "#2f6a34", "#4a8a2e", "#6aa83a", "#92c44a", "#c4e27a" },
  LIMEG = { "#3f4a1a", "#68741f", "#8e9a26", "#b4bc3a", "#d4d85a", "#eeee98" },
  YEL = { "#6e4a1f", "#a8741f", "#d9a022", "#f2c42e", "#ffe05a", "#fff1a0" },
  ORG = { "#6e2a1f", "#a8431f", "#d9682a", "#f08c3a", "#ffb060", "#ffd89a" },
  RED = { "#3f1429", "#6e1c36", "#a82a40", "#d4403f", "#f06a52", "#ff9f80" },
  BRN = { "#3a1f1a", "#5e3326", "#8a5236", "#b47a4a", "#d6a468", "#f0cf96" },
  TAN = { "#4a3a22", "#7a5e36", "#a88a4e", "#c8aa68", "#e0c888", "#f2e4b0" },
  CRM = { "#8a7456", "#b8a07a", "#dccaa0", "#efe0b8", "#f8eed0", "#fffaea" },
  GLS = { "#2f5f78", "#4a8aa8", "#7fbad0", "#b0dce8", "#d8f2f6", "#f4ffff" },
  VIO = { "#2a1a4a", "#43307a", "#5e48a0", "#7f66c0", "#a48ae0", "#d2c0f8" },
  TEAL = { "#12384a", "#1d5c66", "#2c8480", "#42a898", "#76d0b0", "#b8f0d0" },
  GOLD = { "#6a3a1a", "#9a5a1f", "#d98322", "#f5b82e", "#ffd45a", "#ffeea0" },
  STONE = { "#3a3b55", "#5a5c78", "#7c7d94", "#a0a0b4", "#c4c3d0", "#e4e2e8" },
  PINK = { "#7d2c5e", "#a83c70", "#c94f84", "#e8689a", "#f5809f", "#ffc4d8" },
  MOSS = { "#1e3f34", "#2c5f3f", "#3f8148", "#5ea652", "#86c85e", "#b8e47c" },
}
function D.c(name) return B.new(name) end
function D.fin() B.fin() end
function D.lit(m, ramp, R, o) return B.lit(B.c, m, ramp, R or 3, o) end
function D.px(x, y, hex) B.c:px(x, y, hex) end
function D.ln(x0, y0, x1, y1, hex, clip) B.ln(B.c, x0, y0, x1, y1, hex, clip) end
function D.shadow(cx, cy, rx, ry) B.c:groundShadow(cx, cy, rx, ry) end
-- lit leaf ellipse with midrib along its axis
function D.leafE(cx, cy, rx, ry, ang, ramp, o)
  o = o or {}
  local m = B.ell(cx, cy, rx, ry, ang)
  D.lit(m, ramp, o.R or 1.8)
  local ca, sa = cos(ang), sin(ang)
  if not o.norib then D.ln(cx - ca * rx * .85, cy - sa * rx * .85, cx + ca * rx * .85, cy + sa * rx * .85, ramp[6], m) end
  if o.veins then
    for _, t in ipairs(o.veins) do
      local bx, by = cx + ca * rx * t, cy + sa * rx * t
      for _, sgn in ipairs{ 1, -1 } do
        D.ln(bx, by, bx + ca * 2 - sa * ry * .8 * sgn, by + sa * 2 + ca * ry * .8 * sgn, ramp[2], m)
      end
    end
  end
  return m
end
-- stem tube a->b, half width w
function D.stem(ax, ay, bx, by, w, ramp)
  return H.cyl(B.c, ax, ay, bx, by, function(t) if t > 0.97 then return -1 end return w end, ramp or D.R.MOSS)
end
-- curved swept ribbon: bezier pts, wfn(t)
function D.sweep(pts, wfn, ramp, R)
  local m, T = H.sweep(pts, wfn)
  D.lit(m, ramp, R or 1.6)
  return m, T
end
-- frilly rounded blob mask: radius modulated by angle
function D.frill(cx, cy, rx, ry, k, amp, ph, rot)
  local m = HP.mask() rot = rot or 0
  local ca, sa = cos(rot), sin(rot)
  local R = math.ceil(max(rx, ry) * (1 + amp)) + 2
  for y = floor(cy) - R, floor(cy) + R do for x = floor(cx) - R, floor(cx) + R do
    local dx, dy = x - cx, y - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    local a = math.atan(v / ry, u / rx)
    local lim = 1 + amp * sin(k * a + (ph or 0))
    if (u / rx) ^ 2 + (v / ry) ^ 2 <= lim * lim then m:set(x, y) end
  end end
  return m
end
-- glass vertical streak
function D.streak(x, y0, y1, hex, clip) for y = y0, y1 do if not clip or clip:has(x, y) then B.c:px(x, y, hex) end end end
-- little droplet (3 wide)
function D.drop(x, y, ramp)
  local m = B.ell(x, y + 1, 1.6, 2.2, 0) m:add(B.ell(x, y - 1, 0.7, 1.6, 0))
  D.lit(m, ramp, 1.2) return m
end
-- sprinkle noise pixels inside mask from hex list
function D.speckle(m, hexes, seed, thr)
  m:each(function(x, y) local h = X.hash(x, y, seed) if h > (thr or .8) then B.c:px(x, y, hexes[1 + floor((h * 997) % #hexes)]) end end)
end
-- tiny seed leaf scrap base: laid across bottom, returns mask
function D.scrap(ax, ay, bx, by, w, ramp, o) return B.blade(B.c, ax, ay, bx, by, w, ramp, o) end
-- lime/lemon-ish teardrop-less seed: lit ellipse with contact shadow
function D.seed(cx, cy, rx, ry, ang, ramp, shadow, glint) return B.seed(B.c, cx, cy, rx, ry, ang, ramp, shadow or "#163a35", glint) end
return D
