-- ico-snail (final, Opus single pass). Garden snail gliding left: slim tapering foot, neck raised with two 3 px
-- eyestalks and ball tips, round banded shell with an off-centre spiral. Material: shell lit as a sphere plus a rounded
-- bump per whorl (6-tone caramel), deep groove in the spiral suture, a chocolate band riding each whorl, fine radial
-- growth lines, glossy spec + cream glint. Skin: 6-tone putty with lavender shade, a few dimples, darker foot fringe,
-- contact shadow where the shell sits on the foot; wet slime trail with glints behind.
-- quirk: a tiny red toadstool has sprouted on top of the shell.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA9_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sqrt, max, min, abs, cos, sin, pi, atan = math.floor, math.sqrt, math.max, math.min, math.abs, math.cos, math.sin, math.pi, math.atan
local c = A.new("ico-snail")
local SH = { "#5a2a2e", "#8e3f2c", "#c0642c", "#e08a3a", "#f4b25a", "#ffdc94" }
local BD = { "#3e1e26", "#5e2a28", "#80402c", "#a05a34", "#be7a44", "#d89a5c" }
local SK = { "#47283e", "#74405a", "#a85e68", "#d0846e", "#eaa880", "#fcd2a2" }
local SL = { "#5f9ad0", "#8bc4ea", "#c8ecfa" }
local stok, ktok, mtok = A.tok("shell"), A.tok("skin"), A.tok("shroom")

-- slime trail (behind everything)
for x = 42, 55 do c:put(x, 53, x % 5 == 0 and SL[3] or SL[2]) c:put(x, 54, SL[1]) end
c:put(55, 53, SL[1])

-- foot + neck as one tube (tail at right, head at upper left)
local fpts = { { 53, 51 }, { 45, 51 }, { 32, 50.5 }, { 20, 49.5 }, { 14, 46 }, { 12.5, 40 }, { 13, 34.5 } }
local function fw(t)
  if t < 0.12 then return 1.2 + t / 0.12 * 1.6 end
  if t < 0.62 then return 2.8 end
  return 2.8 + (t - 0.62) / 0.38 * 0.6
end
local fm, fn, FT, FS = A.ctube(fpts, fw, 260)
local head, hn = A.oval(13, 32.5, 4.4, 4.0, 0)
-- eyestalks with ball tips
local s1, s1n = A.ctube({ { 11, 30 }, { 9.5, 25 }, { 7.5, 19.5 } }, function() return 1.15 end, 60)
local s2, s2n = A.ctube({ { 15, 30 }, { 16.5, 25 }, { 18.5, 19 } }, function() return 1.15 end, 60)
local b1, b1n = A.oval(7.2, 18.2, 2.5, 2.5, 0)
local b2, b2n = A.oval(18.8, 17.6, 2.5, 2.5, 0)
-- far stalk first (right one sits slightly behind), then the near one
A.shade(c, s2, s2n, SK, { amb = 0.15, wrap = 0.3, tok = ktok, bias = (function() local b = {} s2:each(function(x, y) b[K(x, y)] = -1 end) return b end)() })
A.shade(c, b2, b2n, SK, { amb = 0.15, wrap = 0.3, tok = ktok })
A.shade(c, s1, s1n, SK, { amb = 0.15, wrap = 0.3, tok = ktok })
A.shade(c, b1, b1n, SK, { amb = 0.15, wrap = 0.3, tok = ktok })
local fbias = {}
local fidx = A.shade(c, fm, fn, SK, { amb = 0.1, wrap = 0.3, tok = ktok, bias = fbias })
local hidx = A.shade(c, head, hn, SK, { amb = 0.12, wrap = 0.3, tok = ktok })
-- foot fringe: darker skirt row with tiny dashes
fm:each(function(x, y) local k = K(x, y)
  if not fm:has(x, y + 1) and FT[k] < 0.75 then c:put(x, y, (x % 3 == 0) and SK[1] or SK[2], ktok) end end)
-- skin dimples
fm:each(function(x, y) local k = K(x, y)
  if FT[k] > 0.2 and FT[k] < 0.9 and (fidx[k] or 1) >= 4 and X.hash(x, y, 7) < 0.12 then A.step(c, fidx, SK, x, y, -1, ktok) end end)

-- shell: logarithmic spiral (body whorl widest), mouth at the lower left where the neck comes out
local OX, OY = 36.5, 33.0
local TE = pi * 0.7          -- mouth angle (screen, clockwise)
local RE = 15.2
local KK = math.log(1.6) / (2 * pi)
local function r(th) return RE * math.exp(KK * (th - TE)) end
local shell, n, bias, FR, TH, RHO = HP.mask(), {}, {}, {}, {}, {}
for y = 10, 50 do for x = 18, 54 do
  local dx, dy = (x - OX) / 1.08, y - OY
  local rho = sqrt(dx * dx + dy * dy)
  local th = atan(dy, dx)
  while th > TE do th = th - 2 * pi end
  while th + 2 * pi <= TE do th = th + 2 * pi end
  if rho <= r(th) then
    while rho < r(th - 2 * pi) do th = th - 2 * pi end
    local ro, ri = r(th), r(th - 2 * pi)
    if ro > 1.0 then
      shell:set(x, y)
      local k = K(x, y)
      local u = (rho - ri) / max(0.5, ro - ri)
      FR[k], TH[k], RHO[k] = u, th, rho
      local ex, ey = rho > 0.3 and dx / rho or 0, rho > 0.3 and dy / rho or 0
      local s = max(-0.95, min(0.95, (u * 2 - 1) * 0.9))
      n[k] = { A.norm(ex * s + dx / 40, ey * s + dy / 40, sqrt(1 - s * s)) }
      local d = rho - ri
      if rho < 3.2 then
        n[k] = { A.norm(dx / 5, dy / 5, 1) } FR[k] = 0.4
      elseif d < 1.0 then bias[k] = -2 elseif d < 2.0 then bias[k] = -1 end
    end
  end
end end
-- contact shadow on the foot under the shell rim
fm:each(function(x, y) if not shell:has(x, y) and (shell:has(x, y - 1) or shell:has(x - 1, y - 1) or shell:has(x + 1, y - 1)) then
  A.step(c, fidx, SK, x, y, -2, ktok) end end)
local idx = A.shade(c, shell, n, SH, { amb = 0.1, wrap = 0.3, bias = bias, tok = stok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 } })
-- chocolate band riding each whorl (outer third of the tube)
shell:each(function(x, y) local k = K(x, y)
  local u = FR[k]
  if u > 0.6 and u < 0.84 and RHO[k] > 6 then c:put(x, y, BD[max(1, min(6, idx[k]))], stok) end end)
-- growth lines across the body whorl only
shell:each(function(x, y) local k = K(x, y)
  local left = TE - TH[k]
  if left >= 0 and left < 2 * pi and FR[k] > 0.15 and FR[k] < 0.6 then
    local ph = left / 0.7
    if ph - floor(ph) < 0.1 and FR[k] > 0.3 then A.step(c, idx, SH, x, y, -1, stok) end
  end end)
-- glossy spec on the upper-left crest of the body whorl
do
  for i = 0, 4 do
    local t = -pi * 0.8 + (i - 2) * 0.1
    while t > TE do t = t - 2 * pi end
    while t + 2 * pi <= TE do t = t + 2 * pi end
    local ro, ri = r(t), r(t - 2 * pi)
    local rr = ri + (ro - ri) * 0.42
    c:put(floor(OX + cos(t) * rr + .5), floor(OY + sin(t) * rr + .5), i == 2 and A.CREAM or SH[6], stok)
  end
end
-- cool bounce on the lower-right rim
local rim = X.rim(n)
shell:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.6 and FR[k] > 0.8 and y < 44 then c:put(x, y, "#9c5a6e", stok) end end)
-- mouth lip: pale rim along the mouth edge
shell:each(function(x, y) local k = K(x, y)
  if TE - TH[k] < 0.12 and TE - TH[k] >= 0 then c:put(x, y, SH[5], stok) end end)

-- face on the eye balls and head
c:eyeSmall(6, 17) c:eyeSmall(18, 16)
c:put(9, 35, SK[1], ktok) c:put(10, 36, SK[1], ktok) c:put(11, 36, SK[1], ktok) c:put(12, 35, SK[1], ktok) -- smile
c:cheek(13, 34)
c:put(10, 30, SK[6], ktok) c:put(11, 30, A.CREAM, ktok) -- wet glint on the head

-- quirk: tiny toadstool on top of the shell
do
  local TP = { w = "#fff4d6", s = "#e2d3bc", t = "#b8a48e", h = "#ff8a5c", R = "#e8493b", r = "#b52e3f", d = "#6e2038" }
  A.map(c, {
    "..hRR..",
    ".hRwRr.",
    "hRRRrwr",
    "dddrddd",
    "..wst..",
    "..wst..",
  }, 31, (function() for y = 0, 63 do if shell:has(34, y) then return y - 6 end end end)(), TP, mtok)
end
A.save(c, "ico-snail")
