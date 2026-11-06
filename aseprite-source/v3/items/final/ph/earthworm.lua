-- earthworm (final, Opus single pass). A slim glossy worm lying in a lazy S, tail lower-left, head upper-right.
-- Material: per-pixel tube light (6-tone pink, cool-violet shade), segment grooves with a lit lip, a swollen
-- coral saddle (clitellum) with AO rows where it meets the body, wet specular streaks, cool bounce on the shade side.
-- quirk: a single dewdrop rides on its back.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB25_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, sqrt, abs, sin, pi = math.floor, math.max, math.min, math.sqrt, math.abs, math.sin, math.pi
local NAME = "earthworm"
local c = A.new(NAME)
local PK  = { "#5a1d3a", "#8a2f50", "#b84a68", "#d96c80", "#f093a0", "#ffc4bd" }
local SAD = { "#68233a", "#983846", "#c45658", "#df7a6c", "#f2a086", "#ffcaa4" }
local SPEC, BOUNCE = "#fff1e6", "#8c5a92"
local tok = { r = { name = "worm" } }

local p = { { 11, 49 }, { 38, 62 }, { 22, 8 }, { 52, 16 } }
local function hw(t)
  local w = 3.1
  if t < 0.25 then w = 1.0 + 2.1 * (t / 0.25) ^ 0.7 end
  if t > 0.93 then w = 3.1 - 0.6 * (t - 0.93) / 0.07 end
  if t > 0.62 and t < 0.75 then w = w + 0.55 * sin(pi * (t - 0.62) / 0.13) end
  return w
end
local m, n, T, S, samp = A.tube(p, hw, 200)
local LEN = 0
for i = 2, #samp do LEN = LEN + sqrt((samp[i].x - samp[i-1].x)^2 + (samp[i].y - samp[i-1].y)^2) end
local sad = HP.mask()
m:each(function(x, y) local t = T[K(x, y)] if t > 0.625 and t < 0.745 then sad:set(x, y) end end)
local body = m:copy():cut(sad)
local bias = {}
X.ao(bias, body, sad, 1, -1)
local v = X.light(n, { amb = 0.06, wrap = 0.22 })
local idx = X.tone(c, body, v, PK, { cuts = A.CUTS, bias = bias, tok = tok })
local sidx = X.tone(c, sad, v, SAD, { cuts = A.CUTS, tok = tok })
-- segment grooves (curve a little with the tube), lit lip toward the head
m:each(function(x, y) local k = K(x, y)
  local t, s = T[k], S[k]
  if t > 0.06 and t < 0.97 and abs(s) < 0.9 then
    local d = (t * LEN + s * s * 0.9) % 2.6
    local onS = sad:has(x, y)
    local R, I = onS and SAD or PK, onS and sidx or idx
    if onS then
      if d < 0.55 and abs(s) < 0.75 then A.step(c, I, R, x, y, -1, tok) end
    else
      if d < 0.6 then A.step(c, I, R, x, y, -1, tok)
      elseif d < 1.2 and s < 0 and (I[k] or 0) >= 4 then A.step(c, I, R, x, y, 1, tok) end
    end
  end
end)
-- saddle edges: dark row on the body side (ambient where the band meets)
-- cool bounce light on the lower-right edge
local rim = X.rim(n)
m:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.72 and S[k] > 0.75 and T[k] > 0.1 and T[k] < 0.94 then c:put(x, y, BOUNCE, tok) end end)
-- wet specular streaks on the lit side
for _, q in ipairs{ { 0.33, 0.37 }, { 0.47, 0.51 }, { 0.8, 0.85 } } do
  for i = floor(q[1] * 200), floor(q[2] * 200) do
    local s = samp[i + 1]
    local x, y = floor(s.x - s.px * s.w * 0.5 + .5), floor(s.y - s.py * s.w * 0.5 + .5)
    if m:has(x, y) then c:put(x, y, PK[6], tok) end
  end
end
do local s = samp[floor(0.83 * 200) + 1]
  c:put(floor(s.x - s.px * s.w * 0.5 + .5), floor(s.y - s.py * s.w * 0.5 + .5), SPEC, tok) end
-- face: a tiny ink eye and a small smile near the head tip
local hs = samp[floor(0.965 * 200) + 1]
local ex, ey = floor(hs.x + .5), floor(hs.y - 1.2 + .5)
c:put(ex, ey, A.INK) c:put(ex, ey + 1, A.INK)
c:put(ex + 2, ey + 3, PK[1]) c:put(ex + 1, ey + 3, PK[1]) c:put(ex + 3, ey + 2, PK[1])
c:put(ex - 2, ey + 2, PK[5])
-- quirk: a dewdrop on its back (glass: bright rim, pale core, dark lower edge)
local ds = samp[floor(0.5 * 200) + 1]
local dx, dy = floor(ds.x - ds.px * (ds.w + 1.5) + .5), floor(ds.y - ds.py * (ds.w + 1.5) + .5)
local drop = {
  ".a.",
  "abc",
  "bcd",
  ".d.",
}
local DC = { a = "#e4f6ff", b = "#b6e6f2", c = "#7fc4dc", d = "#4f8fb8" }
for yy, row in ipairs(drop) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if DC[ch] then c:put(dx + xx - 2, dy + yy - 3, DC[ch]) end end end
c:put(dx - 1, dy - 1, "#fff8ec")
A.save(c, NAME)
