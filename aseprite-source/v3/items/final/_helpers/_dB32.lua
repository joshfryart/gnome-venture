-- _dB32: helper for the d-B32 chunk (ph fishermans-stew .. frost-fur). Extends _dB31 (which wraps batch2/_b2.lua); nothing shared is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/_dB31.lua")
local B, H, HP, X = D.B, D.H, D.HP, D.X
local floor, sin, cos, pi, max, min, abs, sqrt = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs, math.sqrt
D.R.flint = { "#1e1c2c", "#34324a", "#4c4a62", "#6c6a80", "#8f8da0", "#c0bdc8" }
D.R.ice   = { "#2a4a7a", "#3a7ab0", "#5fb4d4", "#8fd8e8", "#c4f0f4", "#f0fcff" }
D.R.fox   = { "#6a2a2a", "#a23e22", "#d0581e", "#ee7a2a", "#fa9e46", "#ffc878" }
D.R.frog  = { "#1f4a3a", "#2c6e3e", "#43923f", "#66b84a", "#92d85e", "#c8f090" }
D.R.ivory = { "#6a5648", "#a08c74", "#cdb890", "#e8d8b4", "#f6ead0", "#fffaea" }
D.R.canvas = { "#2a3a2e", "#3e5a3c", "#587a48", "#789a58", "#9cb870", "#c4d890" }
D.R.pod   = { "#5a3a22", "#80572e", "#a8803f", "#c8a458", "#e0c47c", "#f4e2a8" }
D.R.black = { "#0f0b16", "#1c1626", "#2e2638", "#463c52", "#6a6076", "#a49cb0" }
D.R.blueleaf = { "#1a3a46", "#22566a", "#2f7686", "#46968e", "#6ab4a0", "#9cd2b0" }
-- feathery pinnate frond along a rachis: n pairs of leaflets
function D.pinnate(c, x0, y0, x1, y1, n, rx, ry, ramp)
  local dx, dy = x1 - x0, y1 - y0
  local len = sqrt(dx*dx + dy*dy)
  local ang = math.atan(dy, dx)
  local nx, ny = -dy / len, dx / len
  D.stk(c, { { x0, y0 }, { x1, y1 } }, 0.5, ramp, 1)
  for i = 1, n do
    local t = i / (n + 0.5)
    local sx, sy = x0 + dx * t, y0 + dy * t
    local s = rx * (1 - 0.5 * t)
    for _, side in ipairs{ -1, 1 } do
      local m = B.ell(sx + nx * side * s * .8, sy + ny * side * s * .8, s, ry, ang + side * 0.9)
      D.lit(c, m, ramp, 1.4)
    end
  end
  local m = B.ell(x1, y1, rx * .5, ry, ang) D.lit(c, m, ramp, 1.2)
end
-- short fur streaks over a mask, using ramp tones
function D.fur(c, m, ramp, seed, dens)
  m:each(function(x, y)
    local h = D.noise(x, y, seed or 5)
    if h > (dens or 0.84) and m:has(x, y + 1) then
      c:px(x, y, h > 0.93 and ramp[2] or ramp[5]) c:px(x, y + 1, ramp[3])
    end
  end)
end
return D
