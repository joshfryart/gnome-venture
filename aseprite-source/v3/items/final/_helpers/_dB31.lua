-- _dB31: helper for the d-B31 chunk (ph feijoa-seed .. fireweed-seed) (thin layer over batch2/_b2.lua, not edited)
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local D = { B = B, H = H, HP = HP, X = X, K = B.K, P = H.P }
local floor, sin, cos, pi, max, min, abs, sqrt = math.floor, math.sin, math.cos, math.pi, math.max, math.min, math.abs, math.sqrt
D.INK, D.CREAM = "#2b1c26", "#fff4d6"
function D.new(name) return B.new(name) end
function D.ramp(r) return H.ramp(r) end
function D.mix(a, b, t) return H.mix(a, b, t) end
function D.lit(c, m, ramp, R, o) o = o or {} o.R = R or 3 return H.lit(c, m, ramp, o) end
function D.rr(c, x0, y0, x1, y1, r, ramp, R) local m = c:rrect(x0, y0, x1, y1, r) H.lit(c, m, ramp, { R = R or 3 }) return m end
function D.el(c, cx, cy, rx, ry, ramp, ang, R) local m = B.ell(cx, cy, rx, ry, ang or 0) H.lit(c, m, ramp, { R = R or min(rx, ry) + .6 }) return m end
function D.poly(c, pts, ramp, R) local m = c:poly(pts) H.lit(c, m, ramp, { R = R or 2.5 }) return m end
function D.cylx(c, m, ramp, x0, x1, o) return H.vcyl(c, m, ramp, x0, x1, o) end
function D.sweep(c, pts, wfn, ramp, R) local m, T = H.sweep(pts, wfn) H.lit(c, m, ramp, { R = R or 2.5 }) return m, T end
function D.shadow(c, cx, cy, rx, ry) c:groundShadow(cx, cy, rx, ry) end
function D.ln(c, x0, y0, x1, y1, hex, clip) B.ln(c, x0, y0, x1, y1, hex, clip) end
function D.pl(c, pts, hex, clip) B.polyline(c, pts, hex, clip) end
function D.px(c, x, y, hex) c:px(x, y, hex) end
function D.spec(c, x, y, big) c:px(x, y, D.CREAM) if big then c:px(x + 1, y, D.CREAM) end end
function D.noise(x, y, s) return X.hash(x, y, s or 1) end
function D.bez(p, t) local u = 1 - t
  return u^3*p[1][1] + 3*u*u*t*p[2][1] + 3*u*t*t*p[3][1] + t^3*p[4][1], u^3*p[1][2] + 3*u*u*t*p[2][2] + 3*u*t*t*p[3][2] + t^3*p[4][2] end
-- 6-tone ramps
D.R = {
  paste = { "#2a1410", "#4a2418", "#6e3a22", "#8e5430", "#b27640", "#d29a5c" },
  green = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" },
  pink  = { "#5a1450", "#8c2468", "#c03a80", "#e45a98", "#f58cb4", "#ffc0d8" },
  orange = { "#6a2236", "#a2332e", "#d04b25", "#ee6c22", "#fb983a", "#ffc874" },
  cream = { "#6a5a5c", "#a08c80", "#cbb89a", "#e8d8b4", "#f6ead0", "#fffaea" },
  tan   = { "#51302b", "#7a4a34", "#a87048", "#caa06a", "#e2c088", "#f6dcaa" },
  kraft = { "#5a3a30", "#8a5c3e", "#b98456", "#d6a670", "#ecc896", "#fae2b4" },
  glass = { "#3a7a86", "#5aa4ae", "#86c8c4", "#acdcd4", "#cdeee4", "#eefaf0" },
  grey  = { "#4a4658", "#6e6a7c", "#948f9e", "#bdb2a2", "#d8ceba", "#efe8d6" },
  red   = { "#4a1230", "#7a1c3a", "#a8283e", "#cc3844", "#e8605a", "#ff9a84" },
  purple = { "#2c1a3a", "#4a2a4e", "#6c3e62", "#8c5876", "#ac7890", "#cc9cb0" },
  white = { "#7a6e86", "#aaa0b4", "#cfc8d0", "#e8e2de", "#f8f2e6", "#fffcf0" },
  yolk  = { "#8f4a1f", "#c27a20", "#e8a428", "#f5c13a", "#ffd95c", "#fff0a0" },
  night = { "#141428", "#1e2a46", "#2a4666", "#3a6a82", "#5a98a0", "#9ad0c4" },
}

-- generic stroke along a polyline: radius r (number or f(t)); returns mask, T
function D.stroke(pts, r)
  local m, T = HP.mask(), {}
  local segs, tot = {}, 0
  for i = 1, #pts - 1 do local l = sqrt((pts[i+1][1]-pts[i][1])^2 + (pts[i+1][2]-pts[i][2])^2) segs[i] = l tot = tot + l end
  local acc = 0
  for i = 1, #pts - 1 do
    local n = max(1, math.ceil(segs[i] * 2))
    for j = 0, n do
      local f = j / n
      local x, y = pts[i][1] + (pts[i+1][1]-pts[i][1]) * f, pts[i][2] + (pts[i+1][2]-pts[i][2]) * f
      local t = (acc + segs[i] * f) / tot
      local rr = type(r) == "function" and r(t) or r
      local R = math.ceil(rr)
      for dy = -R, R do for dx = -R, R do
        if dx*dx + dy*dy <= rr*rr + 0.3 then
          local px, py = floor(x + dx + .5), floor(y + dy + .5)
          if not m:has(px, py) then T[D.K(px, py)] = t end
          m:set(px, py)
        end
      end end
    end
    acc = acc + segs[i]
  end
  return m, T
end
function D.stk(c, pts, r, ramp, R) local m, T = D.stroke(pts, r) H.lit(c, m, D.ex(ramp), { R = R or 1.8 }) return m, T end
-- spiral points: centre, start radius, turns, start angle, dir (+1 cw on screen)
function D.spiral(cx, cy, r0, turns, a0, dir, r1)
  local pts, n = {}, 28
  for i = 0, n do local f = i / n
    local a = a0 + dir * f * turns * 2 * pi
    local r = r0 + ((r1 or 0.8) - r0) * f
    pts[#pts+1] = { cx + cos(a) * r, cy + sin(a) * r }
  end
  return pts
end
-- local frame: origin (cx,cy), handle direction h (unit, pointing from grip to head), a along perpendicular
function D.xf(cx, cy, hx, hy)
  local px, py = -hy, hx
  if px < 0 then px, py = -px, -py end
  return function(a, b) return { floor(cx + a*px + b*hx + .5), floor(cy + a*py + b*hy + .5) } end, px, py
end
function D.unit(ax, ay, bx, by) local l = sqrt((bx-ax)^2 + (by-ay)^2) return (bx-ax)/l, (by-ay)/l end
-- little cream/lime sparkle plus
function D.spark(c, x, y, hex) hex = hex or D.CREAM for _, d in ipairs{{0,0},{1,0},{-1,0},{0,1},{0,-1}} do c:px(x+d[1], y+d[2], hex) end end
-- seed tone ramps
D.R.leafg = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
D.R.silver = { "#2a4a44", "#3f6a5a", "#5d8a72", "#82aa8c", "#a8c8a6", "#d0e2c4" }
D.R.steel = { "#3a3a52", "#5a5c78", "#7e82a0", "#a4a8c2", "#cfd2e4", "#f2f0fa" }
D.R.wood = { "#3a2020", "#51302b", "#6e4030", "#8e5a3a", "#b27a4c", "#d4a070" }
D.R.plum = { "#1e1030", "#3a1e54", "#5a2e74", "#7c4496", "#a066b4", "#d0a0d6" }
D.R.lime = { "#2c5a30", "#3f7e3a", "#68a444", "#9acb56", "#c8e47a", "#eef6a8" }
D.R.glow = { "#3f7a2c", "#78b030", "#b4d83c", "#dcf05a", "#f4fa8a", "#fffcd0" }
D.R.gold = { "#8f4a1f", "#c27a20", "#e8a428", "#f5c13a", "#ffd95c", "#fff0a0" }
function D.ex(r)
  if type(r) ~= "table" or r.hi or #r == 6 or #r == 0 then return r end
  local o, n = {}, #r
  for i = 1, 6 do local f = (i - 1) / 5 * (n - 1) local a = floor(f) + 1 local b = min(n, a + 1) o[i] = H.mix(r[a], r[b], f - floor(f)) end
  return o
end
function D.lit(c, m, ramp, R, o) o = o or {} o.R = R or 3 return H.lit(c, m, D.ex(ramp), o) end
function D.fin() B.fin() end
return D
