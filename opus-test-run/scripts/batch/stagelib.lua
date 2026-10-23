-- stagelib.lua : shared helpers for the richer stage backdrops (pines band, faceted peaks, outlined trees/rocks/plants, deterministic scatter).
local X = ...
local S = loadfile(X.OUT .. "scripts/shared.lua")(X)
local floor, sin, cos = math.floor, math.sin, math.cos
local H = { S = S }
-- flat ramp: base / shade / rim only (keeps a figure within the 32-colour cap)
function H.flat(base, shade, rim) return X.ramp(base, { shade = shade, deep = shade, bounce = shade, rim = rim or base, gloss = base, dot = base }) end
H.STONE = H.flat("#8b8f96", "#5b6470", "#c9c5bc"); H.WOOD = H.flat("#b07a45", "#8a4f2a", "#d9a660"); H.PINE = H.flat("#4f9a45", "#2f6a3a", "#7ab55c"); H.LEAF = H.flat("#7ab55c", "#4f9a45", "#a4b86a")
function H.rng(seed) local s = seed or 7; return function(n) s = (s * 1103515245 + 12345) % 2147483648; return s % n end end
-- row of small triangle pines (flat, no outline), farther = paler
function H.pines(c, col, base, step, h, off, y1)
  local m = c:rect(0, base, c.W - 1, y1 or (c.H - 1)); local x, i = off, 0
  while x < c.W + step do local hh = h + ((i * 7) % 3) * 3; m:poly({ { x - step * 0.6, base + 1 }, { x, base - hh }, { x + step * 0.6 + 1, base + 1 } }); x, i = x + step, i + 1 end
  c:fill(m, col)
end
-- faceted peak: lit left face, shaded right face, optional snow cap with a ragged lower edge
function H.peak(c, cx, top, w, base, lit, dark, snow, snowShade)
  c:fill(c:poly({ { cx - w, base }, { cx, top }, { cx + w, base } }), lit)
  c:fill(c:poly({ { cx, top }, { cx + w, base }, { cx + w * 0.35, base }, { cx - w * 0.1, top + (base - top) * 0.55 } }), dark)
  if snow then
    local h = (base - top) * 0.32
    c:fill(c:poly({ { cx - w * 0.38, top + h }, { cx - w * 0.2, top + h * 0.7 }, { cx - w * 0.1, top + h }, { cx + w * 0.05, top + h * 0.6 }, { cx + w * 0.2, top + h }, { cx + w * 0.4, top + h * 0.85 }, { cx, top } }), snow)
    if snowShade then c:fill(c:poly({ { cx, top }, { cx + w * 0.4, top + h * 0.85 }, { cx + w * 0.2, top + h }, { cx + w * 0.05, top + h * 0.6 } }), snowShade) end
  end
end
function H.birds(c, list) for _, b in ipairs(list) do S.bird(c, b[1], b[2]) end end
-- outlined tree: trunk + lumpy canopy, uses full ramps (gloss comma, crescent, rim)
function H.tree(c, x, y, h, leaf, trunk)
  local tw = math.max(2, floor(h / 9))
  local canopy = c:ellipse(x, y - h * 0.65, h * 0.38, h * 0.3):add(c:ellipse(x - h * 0.22, y - h * 0.55, h * 0.24, h * 0.2)):add(c:ellipse(x + h * 0.22, y - h * 0.55, h * 0.24, h * 0.2)):add(c:ellipse(x, y - h * 0.85, h * 0.24, h * 0.2))
  c:build{ { "trunk", c:rect(x - tw, y - h * 0.5, x + tw, y), trunk or H.WOOD, { gloss = false } }, { "canopy", canopy, leaf } }
end
function H.rock(c, x, y, rx, ry, ramp) c:part(c:ellipse(x, y, rx, ry), ramp or H.STONE, { gloss = false, cres = 3, deep = 1 }) end
function H.sparkle(c, x, y, col) c:px(x, y, col); c:px(x - 1, y, col); c:px(x + 1, y, col); c:px(x, y - 1, col); c:px(x, y + 1, col) end
return H
