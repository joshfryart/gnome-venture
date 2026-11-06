local function flamingo(x, y, s, d, pose)
  local PK = RR("#ffc8d2", "#f08aa4", "#c8587c", "#8a3a62")
  local LEG = RR("#f4a0b0", "#d86a88", "#a8466a", "#7a3058")
  local bx, by = x, y - 36 * s
  local function ptr(a, b) return { bx + d * a * s, by + b * s } end
  -- legs
  local function leg(hx, hy, kx, ky, fx, fy) local m = spline({ { hx, hy }, { kx, ky }, { fx, fy } }, max(.7, 1.1 * s), max(.6, .8 * s), nil, 8); c:rim(m, INK); fill(m, LEG.base); return m end
  if pose == "one" or pose == "preen" then
    leg(x - d * 2 * s, by + 8 * s, x - d * 3 * s, y - 16 * s, x - d * 2 * s, y)
    local m = spline({ ptr(2, 8), ptr(10, 18), ptr(3, 19) }, max(.7, 1.1 * s), max(.6, .8 * s), nil, 8); c:rim(m, INK); fill(m, LEG.base)
  else
    leg(x - d * 4 * s, by + 8 * s, x - d * 6 * s, y - 15 * s, x - d * 5 * s, y)
    leg(x + d * 3 * s, by + 8 * s, x + d * 5 * s, y - 15 * s, x + d * 4 * s, y)
    for _, fx in ipairs({ x - d * 5 * s, x + d * 4 * s }) do fill(PL({ { fx, y }, { fx + d * 7 * s, y + 1 }, { fx - d * 2 * s, y + 1 } }), LEG.shade) end
  end
  -- wing for flap pose (behind body)
  if pose == "flap" then
    local wg = PL({ ptr(-2, -6), ptr(-14, -34), ptr(-2, -50), ptr(16, -42), ptr(24, -22), ptr(14, -6) })
    c:rim(wg, INK); lit(wg, PK, 9, { R = 10, tex = .2, ink = false })
    fill(PL({ ptr(24, -22), ptr(14, -6), ptr(-2, -6), ptr(8, -16) }), "#3a2840")
  end
  -- body + tail
  local body = E(bx, by, 15 * s, 10 * s)
  body:add(PL({ ptr(-10, -6), ptr(-27, 4), ptr(-12, 9) }))
  lit(body, PK, 3 + floor(x), { R = floor(10 * s), tex = .3 })
  local wing = E(bx - d * 2 * s, by - 1 * s, 10 * s, 5 * s); fill(wing, PK.hi)
  wing:each(function(xx, yy) if not wing:has(xx, yy + 1) then P(xx, yy, PK.base) end end)
  fill(PL({ ptr(-12, 1), ptr(-26, 3), ptr(-14, 7) }), "#3a2840")
  -- neck + head
  local N = {
    stand = { { 0, 0 }, { 5, -14 }, { -1, -28 }, { 5, -42 }, { 10, -50 } },
    high = { { 0, 0 }, { 2, -18 }, { -3, -34 }, { 2, -52 }, { 6, -62 } },
    feed = { { 0, 0 }, { 10, -4 }, { 19, 8 }, { 22, 24 }, { 19, 36 } },
    preen = { { 0, 0 }, { 8, -14 }, { 0, -28 }, { -12, -24 }, { -18, -12 } },
    one = { { 0, 0 }, { 8, -10 }, { 2, -22 }, { 9, -34 }, { 14, -38 } },
    flap = { { 0, 0 }, { 6, -14 }, { 0, -30 }, { 6, -44 }, { 10, -52 } },
  }
  local npts = {}
  for i, p in ipairs(N[pose]) do npts[i] = { bx + d * (11 + p[1]) * s, by - 5 * s + p[2] * s } end
  local neck = spline(npts, 0, 0, function(t) return (2.8 - t * .9) * s end, 14)
  lit(neck, PK, 20 + floor(x), { R = 4, tex = .2 })
  local h = npts[#npts]
  local hdm = E(h[1], h[2], 3.6 * s, 3 * s); lit(hdm, PK, 21, { R = 3, tex = 0 })
  local bd = ({ stand = { d, .4 }, high = { d, .4 }, feed = { .2 * d, 1 }, preen = { -d, .6 }, one = { d, .4 }, flap = { d, .4 } })[pose]
  local bl = sqrt(bd[1] ^ 2 + bd[2] ^ 2)
  local b1 = { h[1] + bd[1] / bl * 5 * s, h[2] + bd[2] / bl * 5 * s }
  local b2 = { h[1] + bd[1] / bl * 9 * s, h[2] + bd[2] / bl * 9 * s + 3 * s }
  local bk = spline({ h, b1, b2 }, 2.6 * s, 1 * s, nil, 8); c:rim(bk, INK); fill(bk, "#f6d8c8")
  fill(spline({ b1, b2 }, 1.6 * s, 1 * s, nil, 6), "#2b1c26")
  P(h[1] + d * 1.5 * s, h[2] - 1 * s, INK); P(h[1] + d * 1.5 * s - 1, h[2] - 1 * s - 1, CREAM)
  -- ripples at feet
  c:rim(E(x, y + 1, 14 * s, 3 * s), "#ffe6e0")
end
