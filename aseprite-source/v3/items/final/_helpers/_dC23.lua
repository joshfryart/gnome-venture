-- _dC23: helper for chunk dC23 (m* items). Wraps batch2/_b2.lua (unchanged).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local H, HP, X = B.H, B.HP, B.X
local floor, abs, sin, cos, max, min, sqrt, pi = math.floor, math.abs, math.sin, math.cos, math.max, math.min, math.sqrt, math.pi
local D = { B = B, H = H, HP = HP, X = X, P = H.P, K = B.K }
D.R = {
  leaf  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" },
  grey  = { "#2f4a3e", "#4b6e58", "#6f9674", "#93b88e", "#b7d4aa", "#dcecc8" },
  cream = { "#7a5a52", "#b08e78", "#d8b894", "#ecd4ae", "#f8e8c4", "#fffaec" },
  straw = { "#6a4a2a", "#9a7038", "#c79c4c", "#e2c066", "#f2dc8a", "#fff0b8" },
  bread = { "#5e3a2b", "#8a5638", "#b9814e", "#d9a468", "#ecc58a", "#f8e2b0" },
  lemon = { "#8a4a1c", "#c47a1c", "#eca626", "#f8c83a", "#ffe066", "#fff4a8" },
  glass = { "#3a6a8a", "#5f9cb8", "#92c8d4", "#b8e4e0", "#dcf4ee", "#f6fffa" },
  iron  = { "#25222e", "#3c3a4c", "#56566a", "#76778c", "#9a9bb0", "#c6c6d6" },
  berry = { "#3a1448", "#5c1f62", "#85307a", "#ab4a8e", "#cf72a8", "#f0a4c4" },
  olive = { "#2a2a22", "#44432c", "#625f38", "#837c46", "#a59c5c", "#c8bf84" },
  brown = { "#3a2218", "#5a3626", "#7e4e30", "#a46c40", "#c8905a", "#e8b884" },
  seedD = { "#22141a", "#371d1f", "#512a24", "#6f3c2b", "#925636", "#b97c4c" },
  seedP = { "#8a6a48", "#b8966a", "#d8b888", "#ecd4a4", "#f8e8c0", "#fffaea" },
  gold  = { "#8f4a1f", "#c06a20", "#e89a28", "#f5b82e", "#ffd860", "#fff0a0" },
  jam   = { "#6a2a10", "#a4481a", "#d4701e", "#f09a2a", "#ffc24a", "#ffe58a" },
}
D.SH = "#1f553f"
function D.new(name) return B.new(name) end
function D.rr(c, x0, y0, x1, y1, r, ramp, R) local m = c:rrect(x0, y0, x1, y1, r) B.lit(c, m, ramp, R or 3) return m end
function D.el(c, cx, cy, rx, ry, ramp, R, ang) local m = B.ell(cx, cy, rx, ry, ang or 0) B.lit(c, m, ramp, R or min(rx, ry) + .5) return m end
function D.poly(c, pts, ramp, R) local m = c:poly(pts) B.lit(c, m, ramp, R or 3) return m end
function D.stem(c, pts, hex, hex2)
  for i = 1, #pts - 1 do B.ln(c, pts[i][1], pts[i][2], pts[i+1][1], pts[i+1][2], hex) if hex2 then B.ln(c, pts[i][1]+1, pts[i][2], pts[i+1][1]+1, pts[i+1][2], hex2) end end
end
-- dots on mask where f(x,y) true
function D.dots(c, m, f, hex) m:each(function(x, y) if f(x, y) then c:px(x, y, hex) end end) end
-- seed scene: leaf scrap + seeds with contact shadow. o = {ax,ay,bx,by,w,leaf,veins,prof,seeds={{cx,cy,rx,ry,ang}},ramp,shadow}
function D.scrap(c, o)
  local m = B.blade(c, o.ax, o.ay, o.bx, o.by, o.w, o.leaf or D.R.leaf, { veins = o.veins or { 6, 11, 16, 21, 26 }, prof = o.prof, slant = o.slant })
  return m
end
function D.seeds(c, o)
  for _, s in ipairs(o.seeds) do B.seed(c, s[1], s[2], s[3], s[4], s[5] or 0, o.ramp, o.shadow or D.SH, o.glint) end
end
function D.fin() B.fin() end
return D
