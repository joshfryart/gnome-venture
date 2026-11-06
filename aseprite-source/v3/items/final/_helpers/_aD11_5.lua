-- _aD11_5.lua: private helpers for ph/raphanobrassica-seed, raspberry, raspberry-jam, raspberry-seed (final pass, Sonnet high).
-- Read-only use of _aD11_0.lua (-> _aD10_0.lua -> batch2/_b2g1.lua -> batch1/_g1.lua -> _h.lua -> lib). No shared file is edited.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/_aD11_0.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local sqrt, floor, max, min, abs, sin, cos, pi = math.sqrt, math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi

-- sawtooth / rippled half-width profile. base(t) in [0,inf); teeth of height amp every `per` px along len
function A.sawW(len, w, o)
  o = o or {}
  return function(t)
    if o.start and t < o.start then return 0.55 + (w - 0.55) * (t / o.start) end
    if t > 0.985 then return -1 end
    local prof = sin(pi * min(1, t * (o.k or 0.92) + (o.off or 0.08))) ^ (o.pw or 0.7)
    local wv = w * prof
    if o.saw and t > (o.s0 or 0.12) and t < (o.s1 or 0.94) then
      local ph = (t * len / o.saw) % 1
      wv = wv + (ph < 0.5 and (o.amp or 1.1) * (1 - ph * 2) or 0)
    end
    if o.ripple then wv = wv + o.ripple * sin(t * len / (o.rp or 3.2) * 2 * pi) * prof end
    return max(0.5, wv)
  end
end

-- kidney / heart cotyledon: pivot (nx,ny), direction angle ang, length L, lobe radius r. returns mask, normals
function A.cotMask(nx, ny, ang, L, r)
  local ca, sa = cos(ang), sin(ang)
  local m = HP.mask()
  local R = floor(L + r) + 2
  for y = floor(ny) - R, floor(ny) + R do for x = floor(nx) - R, floor(nx) + R do
    local dx, dy = x - nx, y - ny
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    local inLobe = false
    for _, sgn in ipairs{ -1, 1 } do
      local lu, lv = L - r * 0.9, sgn * r * 0.78
      if (u - lu) ^ 2 + (v - lv) ^ 2 <= r * r then inLobe = true end
    end
    local inBase = u >= 0 and u <= L - r * 0.9 and abs(v) <= 0.55 + (u / (L - r * 0.9)) * (r * 0.9)
    -- notch at the tip centre
    local notch = u > L - 1.9 and abs(v) < 0.4 + (u - (L - 1.9)) * 0.45
    if (inLobe or inBase) and not notch then m:set(x, y) end
  end end
  return m
end

-- ordered ramp mixing helper
function A.mixr(r1, r2, t) local o = {} for i = 1, #r1 do o[i] = G.mix(r1[i], r2[i], t) end return o end
return A
