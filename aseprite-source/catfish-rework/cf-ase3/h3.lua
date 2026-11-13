-- h3.lua: shared helpers for the icon / badge passes
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local L = dofile(DIR .. "/cflib.lua")
local floor, max, min, sin, cos, sqrt, abs, pi = math.floor, math.max, math.min, math.sin, math.cos, math.sqrt, math.abs, math.pi
local H = { L = L, DIR = DIR, OUT = app.params["out"] or (DIR .. "/out/") }
local function mixc(a, b, t)
  local function ch(h, i) return tonumber(h:sub(i, i + 1), 16) end
  return string.format("#%02x%02x%02x", floor(ch(a, 2) + (ch(b, 2) - ch(a, 2)) * t + .5), floor(ch(a, 4) + (ch(b, 4) - ch(a, 4)) * t + .5), floor(ch(a, 6) + (ch(b, 6) - ch(a, 6)) * t + .5))
end
H.mixc = mixc
local function R(D, s, m, l, Lh, g) return { D = D, s = mixc(D, s, .5), b = s, m = m, l = l, L = Lh, g = g } end
H.R = R
H.PINK = R("#6e2850", "#b8446e", "#e0608c", "#f080a4", "#f9a8c0", "#fff0f4")
H.GREEN = R("#1f4a3a", "#2f7a48", "#4a9a4c", "#72b858", "#9ad06a", "#d4f09a")
H.SISAL = R("#6a4a2a", "#a07a44", "#c8a064", "#dcbc80", "#ecd29c", "#fcf0c8")
H.CREAM = R("#9a7a78", "#cdb092", "#f0dcae", "#f8ebc6", "#fff4d8", "#ffffff")
H.TERRA = R("#6e2c20", "#a8482e", "#d0643a", "#e8844a", "#f4a468", "#ffd4a0")
H.GOLD = R("#7a3e18", "#c47a22", "#f0b030", "#ffd257", "#ffe68c", "#fff8d0")
H.WOOD = R("#3d2314", "#6a4128", "#8a5a34", "#b07a48", "#cf9a62", "#efc990")
H.GREY = R("#3d3654", "#6e6684", "#9890b0", "#b8b2cc", "#d4d0e0", "#f4f0fa")
H.BLUE = R("#2a3a7a", "#3a5ab0", "#4f8fd8", "#7cb4ee", "#a8d4ff", "#e4f6ff")
H.NAVY = R("#161a4a", "#26307a", "#3a4a9a", "#5a70c0", "#8aa0e0", "#c8d8ff")
H.PLUM = R("#4a2048", "#7a3a6e", "#a85c92", "#c880b0", "#e0a4c8", "#f8d8ec")
H.ORANGE = R("#8f3a1f", "#c4532a", "#ee8a34", "#f6a94e", "#ffd27a", "#fff1c8")
H.RED = R("#7a1f2a", "#b8353a", "#e0523f", "#f07a52", "#ff9d70", "#ffd0a8")
H.BROWN = R("#3a1f12", "#6a3a1e", "#9a5e2e", "#c08040", "#dda35a", "#f4cf8a")
H.STEEL = R("#2f3a5a", "#566a8c", "#8098b8", "#a8bcd4", "#cfdcec", "#f4f8ff")
H.VIOLET = R("#35295f", "#5a459e", "#8a6fd0", "#a98ee0", "#c9b2f0", "#eee4ff")
H.TEAL = R("#124a4a", "#1f8a80", "#34b0a0", "#5cd0b8", "#8ae8d0", "#d4fff0")
H.SILVER = R("#4a4a6a", "#8a8ca8", "#b8bcd0", "#d4d8e4", "#eceef6", "#ffffff")
H.BRONZE = R("#3a1a12", "#7a3a24", "#a85a32", "#c87a48", "#e09a68", "#f8c8a0")
H.INK = "#2b1c26"
function H.part(c, m, ramp, ws, wl, o) o = o or {} o.ws, o.wl, o.ramp, o.ao = ws or 1, wl or 1, ramp, false c:part(m, o) end
function H.px(c, list, col, lay) for _, p in ipairs(list) do c:put(p[1], p[2], p[3] or col, lay or "detail") end end
function H.sep(c, m)   -- internal 1px ink ring around a part, only over already-painted pixels
  m:grow(1):cut(m):each(function(x, y) if c:isObj(x, y) then c:put(x, y, '#', "outline") end end)
end
function H.leaf(pts, w) return L.tube(pts, function(t) return max(0.6, w * sin(t * pi) ^ 0.7) end) end
function H.rrect(x0, y0, x1, y1, r)
  local m = L.rect(x0, y0, x1, y1)
  for _, cr in ipairs({ { x0, y0, 1, 1 }, { x1, y0, -1, 1 }, { x0, y1, 1, -1 }, { x1, y1, -1, -1 } }) do
    for j = 0, r - 1 do for i = 0, r - 1 do
      local dx, dy = r - 0.5 - i, r - 0.5 - j
      if dx * dx + dy * dy > r * r then m:unset(cr[1] + cr[3] * i, cr[2] + cr[4] * j) end
    end end
  end
  return m
end
function H.arcline(cx, cy, rx, ry, a0, a1, n)
  local pts = {}
  for i = 0, n do local a = a0 + (a1 - a0) * i / n pts[#pts + 1] = { cx + rx * cos(a), cy + ry * sin(a) } end
  return pts
end
function H.star4(c, x, y, r, col, hi, lay)   -- 4-point sparkle, ink handled by caller's outline
  for d = -r, r do c:put(x + d, y, abs(d) <= 1 and hi or col, lay or "detail") c:put(x, y + d, abs(d) <= 1 and hi or col, lay or "detail") end
  c:put(x, y, hi, lay or "detail")
end
function H.new(w, h) local c = L.canvas(w or 64, h or 64, true) return c end
function H.finish(c, name)
  c:outline()
  -- centre on the 64 canvas is handled in the drawing; report bbox
  local x0, y0, x1, y1 = 999, 999, -1, -1
  c.obj:each(function(x, y) x0 = min(x0, x) y0 = min(y0, y) x1 = max(x1, x) y1 = max(y1, y) end)
  c:save(H.OUT, name)
  print(name, c:colours(), string.format("bbox %d,%d..%d,%d", x0, y0, x1, y1))
end
return H
