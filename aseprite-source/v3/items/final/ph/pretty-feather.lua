-- pretty-feather (D10 final, Sonnet high). One long, slim, gently curving feather: a pale cream quill (calamus) wrapped with
-- gold thread, a fine rachis, and an asymmetric vane built from per-pixel barbs that lean toward the tip. The vane's
-- colour drifts like iridescence (deep teal at the base, emerald, lime, then a gold tip); the lit upper-left rim is
-- bright, the lower-right rim is shaded with a cool reflected edge; the edge is feathery (single-pixel barb notches).
-- quirk: a barb split, a zipper-like gap where two barbs parted, opening wider toward the edge.
local NAME = "pretty-feather"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD10_2.lua")
local HP, X, K, G = A.HP, A.X, A.K, A.G
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local TEAL = { "#0f2f45", "#164e63", "#1f7a80", "#2fa398", "#5cc8aa", "#9ae6c4" }
local GREEN = { "#173f33", "#1f5f3c", "#2e8444", "#4cab4e", "#7fcf63", "#bff08a" }
local LIME = { "#3a4a1c", "#5b6a22", "#8a8e2a", "#b8b238", "#e0d055", "#f6ef9a" }
local GOLD = { "#6e3a14", "#9a5a1a", "#cc8a22", "#eab030", "#f8d050", "#fff0a0" }
local CREAM = { "#7a6a52", "#a8946a", "#d4c496", "#f0e4b8", "#fff8dc", "#ffffee" }
local COOL = "#3a6c72"
local vtok = { r = { name = "vane" } }
local qtok = { r = { name = "quill" } }

local P = { { 13, 58 }, { 5, 37 }, { 29, 28 }, { 51, 8 } }
local _, _, _, _, sm = G.tube(P, function(t) return 1 end, 200)
local len = 0
for i = 2, #sm do len = len + sqrt((sm[i].x - sm[i-1].x)^2 + (sm[i].y - sm[i-1].y)^2) end
local WMAX, T0, SLANT = 8.6, 0.1, 1.7

local vane, quill, shaft = HP.mask(), HP.mask(), HP.mask()
local N, T, S, D, SD = {}, {}, {}, {}, {}
local xs, ys = {}, {}
for _, s in ipairs(sm) do xs[#xs + 1] = s.x ys[#ys + 1] = s.y end
local x0, x1, y0, y1 = floor(min(table.unpack(xs))) - 10, floor(max(table.unpack(xs))) + 10, floor(min(table.unpack(ys))) - 10, floor(max(table.unpack(ys))) + 10
local function wprof(t)
  if t < 0.075 then return 0 end
  local s = max(0, min(1, (t - 0.11) / 0.89))
  local w = WMAX * sin(pi * min(1, s * 1.02 + 0.0)) ^ 0.78
  if t < 0.2 then w = max(w, 1.6 + (t - 0.09) * 9) end        -- downy base
  if t > 0.975 then return -1 end
  return w
end
for y = y0, y1 do for x = x0, x1 do
  local best, bs
  for _, s in ipairs(sm) do local q = (x - s.x)^2 + (y - s.y)^2 if not best or q < best then best, bs = q, s end end
  local sd = (x - bs.x) * bs.px + (y - bs.y) * bs.py
  local along = (x - bs.x) * bs.tx + (y - bs.y) * bs.ty
  local t = bs.t
  local k = K(x, y)
  if not ((bs == sm[1] and along < -0.5) or (bs == sm[#sm] and along > 0.5)) then
    local qw = 1.7 - t * 3
    if t < 0.115 and abs(sd) <= qw then
      quill:set(x, y)
      local sn = max(-0.95, min(0.95, sd / (qw + 0.5)))
      N[k] = { bs.px * sn, bs.py * sn, sqrt(1 - sn * sn) }
      T[k], SD[k] = t, sd
    end
    local w = wprof(t)
    if w > 0 and t >= 0.09 then
      local wl, wr = w * 1.0, w * 0.76                 -- upper-left vane is wider
      if sd >= -wl and sd <= wr then
        local sn = sd < 0 and sd / (wl + 0.5) or sd / (wr + 0.5)
        local d = t * len - abs(sd) * SLANT
        local edge = abs(sn) > 0.8
        local keep = true
        -- feathery edge: single-pixel barb notches
        if abs(sn) > 0.84 and t > 0.22 and t < 0.95 then
          local ph = d / 1.5
          if (ph - floor(ph)) < 0.34 and X.hash(x, y, 3) < 0.7 then keep = false end
        end
        -- quirk: the split, a barb-parting gap on the lower side, widening toward the edge
        if sd > 0 and sn > 0.1 and t > 0.3 and t < 0.86 then
          local gw = 0.45 + (sn - 0.1) * 3.0
          if abs(d - 0.42 * len) < gw then keep = false end
        end
        if keep and not quill:has(x, y) then
          vane:set(x, y)
          local fold = 0.46
          local sx = (sn < 0 and -fold or fold) * 0.9 + sn * 0.35
          N[k] = { bs.px * sx, bs.py * sx, 1 }
          local nl = sqrt(N[k][1]^2 + N[k][2]^2 + 1) N[k] = { N[k][1] / nl, N[k][2] / nl, 1 / nl }
          T[k], S[k], D[k], SD[k] = t, sn, d, sd
        end
      end
    end
    if t >= 0.09 and t < 0.985 and abs(sd) <= 0.72 then shaft:set(x, y) T[k], SD[k] = t, sd end
  end
end end
vane:cut(quill)

-- zones along the barb coordinate
local zones = { HP.mask(), HP.mask(), HP.mask(), HP.mask() }
local bias = {}
vane:each(function(x, y)
  local k = K(x, y)
  local d = D[k] / len
  local z = d < 0.3 and 1 or d < 0.58 and 2 or d < 0.8 and 3 or 4
  zones[z]:set(x, y)
  local st = floor(D[k] / 1.3) % 3
  local b = 0
  if st == 0 then b = -1 elseif st == 2 then b = 0 end
  if S[k] < -0.74 then b = b + 1 end                        -- bright lit rim
  bias[k] = b
end)
local ramps = { TEAL, GREEN, LIME, GOLD }
for z = 1, 4 do
  G.toneN(c, zones[z], N, ramps[z], { tok = vtok, bias = bias, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.3 })
end
-- cool reflected light on the lower-right rim (base and middle only)
vane:edge():each(function(x, y) local k = K(x, y)
  if S[k] > 0.7 and D[k] / len < 0.6 and X.hash(x, y, 8) < 0.8 then c:put(x, y, COOL, vtok) end end)
-- split: darken the pixels flanking the gap, one lifted barb tip each side
vane:each(function(x, y) local k = K(x, y)
  if S[k] > 0.1 and T[k] > 0.3 and T[k] < 0.86 and abs(D[k] - 0.42 * len) < 0.45 + (S[k] - 0.1) * 3.0 + 1.1 and abs(D[k] - 0.42 * len) >= 0.45 + (S[k] - 0.1) * 3.0 and S[k] < 0.8 then
    local cur = c:get(x, y)
    for z = 1, 4 do for i = 2, 6 do if ramps[z][i] == cur then c:put(x, y, ramps[z][i - 1], vtok) end end end
  end
end)

-- shaft (rachis): pale, lit on the upper-left, a shade row below
shaft:cut(quill)
shaft:each(function(x, y) local k = K(x, y)
  local sd = SD[k]
  local i = sd < -0.25 and 5 or sd > 0.35 and 2 or 4
  c:put(x, y, CREAM[i], qtok)
end)
-- quill: cylinder tone, gold thread wrap, open tip
local qn = {}
quill:each(function(x, y) qn[K(x, y)] = N[K(x, y)] end)
G.toneN(c, quill, qn, CREAM, { tok = qtok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
quill:each(function(x, y) local k = K(x, y) local t, sd = T[k], SD[k]
  if t > 0.03 and t < 0.085 then
    local ph = (t * len + sd * 0.9) % 3
    if ph < 1.5 then c:put(x, y, sd < -0.3 and GOLD[5] or sd > 0.4 and GOLD[2] or GOLD[4], qtok) end
  end
  if t < 0.02 then c:put(x, y, sd < 0 and CREAM[2] or CREAM[1], qtok) end
end)
-- glints: one on the shaft, one cream sparkle on the lit vane
do
  local best, bx, by
  shaft:each(function(x, y) local t = T[K(x, y)] if t > 0.4 and t < 0.46 and SD[K(x, y)] < -0.2 then bx, by = x, y end end)
  if bx then c:put(bx, by, CREAM[6], qtok) c:put(bx + 1, by - 1, CREAM[6], qtok) end
  vane:each(function(x, y) local k = K(x, y)
    if S[k] < -0.3 and S[k] > -0.5 and D[k] / len > 0.33 and D[k] / len < 0.36 and not best then best = true c:put(x, y, "#fff4d6", vtok) c:put(x - 1, y, "#e9fbd0", vtok) end end)
end
A.save(c, NAME)
