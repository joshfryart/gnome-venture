-- _aC21_0: helper for ph/lm-delve, lm-haven, lm-lair, lm-ruins (Opus single pass). Wraps batch2/_b2.lua read-only.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local B = dofile(DIR .. "/../../batch2/_b2.lua")
local A = { B = B, H = B.H, HP = B.HP, X = B.X, K = B.K, P = B.H.P }
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local K = B.K
-- 6-tone ramps, dark -> light
A.R = {
  stone = { "#2b2840", "#433f5c", "#5f5b78", "#807e98", "#a9a8bc", "#d6d5e2" },
  lair  = { "#1d1530", "#30244a", "#463664", "#5f4c83", "#8270a6", "#ab9ccb" },
  marble= { "#4a3238", "#6c4c4c", "#927062", "#b9967c", "#dabd9c", "#f3e0c0" },
  wood  = { "#3a1f22", "#5c3426", "#7f4c2e", "#a5693a", "#c88d52", "#e8b878" },
  canvas= { "#5a1a2e", "#8a2434", "#b83832", "#de5636", "#f5824e", "#ffb47e" },
  gold  = { "#6a3a1c", "#9a5a1e", "#cf8722", "#f2b333", "#ffd862", "#fff0a8" },
  ember = { "#4a1230", "#7a1c36", "#b02e3a", "#e04a3c", "#ff7a58", "#ffb48a" },
  bone  = { "#5e4a4a", "#8a7468", "#b6a28e", "#d8c8ae", "#efe4cc", "#fff6e0" },
  leaf  = { "#123a3c", "#1a5a4b", "#247b55", "#3a9c5f", "#64be6c", "#a2dc86" },
  earth = { "#2e1c24", "#4a2c2c", "#6a4234", "#8a5c40", "#a87a52", "#c89a6a" },
  sea   = { "#1e3a5e", "#2a5a86", "#3a86b0", "#5fb4c8", "#94dcd8", "#d2f6ee" },
}
A.CREAM, A.VOID = "#fff4d6", "#170f1f"
function A.new(name) return B.new(name) end
A.ln, A.polyline, A.ell, A.seam = B.ln, B.polyline, B.ell, B.seam
function A.lit(c, m, ramp, R, o) return B.lit(c, m, ramp, R, o) end
function A.vcyl(c, m, ramp, x0, x1, o) return B.H.vcyl(c, m, ramp, x0, x1, o) end
-- darken mask pixels by one step of ramp where they touch `front` (ambient occlusion row)
function A.ao(c, m, front, hex) B.seam(c, m, front, hex) end
-- flat two-face facet lighting for crystals/spikes: left of axis lit, right shaded, bright edge on the ridge
function A.crystal(c, base, tip, w, ramp)
  local bx, by, tx, ty = base[1], base[2], tip[1], tip[2]
  local m = c:poly{ { bx - w, by }, { tx, ty }, { bx + w, by }, { bx, by + 1 } }
  m:each(function(x, y)
    local t = (y - ty) / max(1, by - ty)
    local ax = tx + (bx - tx) * t
    local i
    if x < ax - 0.5 then i = 4 elseif x <= ax + 0.5 then i = 6 else i = 3 end
    if y >= by - 1 then i = i - 2 end
    c:px(x, y, ramp[max(1, i)])
  end)
  return m
end
function A.recentre(c)
  local x0, y0, x1, y1 = 1e9, 1e9, -1e9, -1e9
  for i, _ in pairs(c.pix) do local x, y = i % c.w, i // c.w
    x0, y0, x1, y1 = min(x0, x), min(y0, y), max(x1, x), max(y1, y) end
  local W, Hh = x1 - x0 + 3, y1 - y0 + 3
  local dx = floor((c.w - W) / 2) - (x0 - 1)
  local dy = floor((c.h - Hh) / 2 + 0.5) - (y0 - 1)
  local pix, own = {}, {}
  for i, v in pairs(c.pix) do local x, y = i % c.w + dx, i // c.w + dy pix[y * c.w + x] = v own[y * c.w + x] = c.own[i] end
  c.pix, c.own = pix, own
  print(string.format("recentre dx %d dy %d (outlined %dx%d)", dx, dy, W, Hh))
end
function A.fin() A.recentre(B.c) B.fin() end
return A
