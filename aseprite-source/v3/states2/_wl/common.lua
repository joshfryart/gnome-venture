-------------------------------------------------------------- shared bits
local GLYPH = {
  B = { "110", "101", "110", "101", "110" }, U = { "101", "101", "101", "101", "111" },
  I = { "111", "010", "010", "010", "111" }, L = { "100", "100", "100", "100", "111" },
  D = { "110", "101", "101", "101", "110" },
}
local function drawBuild(x, y, hex)   -- 19x5, (x,y) top-left
  local cx = x
  for ch in ("BUILD"):gmatch(".") do
    for r = 1, 5 do for k = 1, 3 do if GLYPH[ch][r]:sub(k, k) == "1" then px(cx + k - 1, y + r - 1, hex or P.ink) end end end
    cx = cx + 4
  end
end
local function patch(x0, y0, x1, y1)
  local m = c:rrect(x0, y0, x1, y1, 4)
  ink(m)
  c:part(m, "wood", { band = 2, nopop = true })
  for _, p in ipairs{ { x0 + 5, y0 + 6 }, { x1 - 9, y1 - 2 }, { x1 - 3, y0 + 5 }, { x0 + 13, y1 - 1 }, { x0 + 22, y0 + 3 }, { x0 + 2, y1 - 4 } } do px(p[1], p[2], P.wood.deep) end
  for _, p in ipairs{ { x0 + 9, y0 + 7 }, { x1 - 14, y0 + 8 }, { x0 + 3, y0 + 3 } } do px(p[1], p[2], P.wood.hi) end
  return m
end
local function stake(x, y0, y1) local m = c:rect(x, y0, x, y1); ink(m); c:part(m, "wood", { band = 1, nopop = true }) end
local function sline(x0, y0, x1, y1) c:fillMask(c:line({ { x0, y0 }, { x1, y1 } }, 1), P.cream) end
local function flower(x, y, col)
  local head = HP.mask():set(x, y - 1):set(x - 1, y):set(x, y):set(x + 1, y):set(x, y + 1)
  local stem = c:rect(x, y + 2, x, y + 3)
  ink(head, stem)
  c:fillMask(stem, P.moss.base)
  c:fillMask(head, col or P.petal.base)
  px(x, y, P.gold.hi)
end
local function stone(x, y, w)
  local m = c:rrect(x, y, x + w, y + 2, 1)
  ink(m); c:part(m, "stone", { band = 1, pop = { x = x + 1, y = y, horizontal = true } })
end
local function leaf(x, y)   -- little flying leaf, 4x2
  local m = HP.mask():set(x, y):set(x + 1, y):set(x + 2, y):set(x + 1, y + 1):set(x + 2, y + 1):set(x + 3, y + 1)
  ink(m)
  c:fillMask(m, P.moss.base); px(x, y, P.moss.hi); px(x + 3, y + 1, P.moss.shade)
end
local function badge(dy)
  local cx, cy = 50, 6 + dy
  local disc = E(cx, cy, 4, 4)
  ink(disc)
  c:part(disc, "gold", { band = 2, pop = { x = cx - 2, y = cy - 3, horizontal = true } })
  R(cx, cy - 3, cx + 1, cy, P.ink) R(cx, cy + 2, cx + 1, cy + 3, P.ink)   -- drop shadow of the mark
  R(cx - 1, cy - 3, cx, cy - 1, P.cream)
  R(cx - 1, cy + 1, cx, cy + 2, P.cream)
end
local BOB = { 0, -1, 0, 1 }
local function savePiece(canvas, name)
  HP.assertClean(canvas)
  canvas:save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
local function saveStrip(frames, name, tag)
  for k = 1, 4 do HP.assertClean(frames[k]) end
  HP.sheet{ cellw = CW, cellh = CH, frames = frames, tags = { { name = tag, from = 1, to = 4 } } }
    :save{ aseprite = out .. name .. ".aseprite", png = out .. name .. ".png", scale = 1 }
end
