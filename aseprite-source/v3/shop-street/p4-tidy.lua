-- Shop Street pass 4 (tidy): conservative cleanup only, no repainting.
-- 1. stray pixels: isolated, far from all 4 neighbours which agree with each other -> majority neighbour colour
--    (skips dither/checkerboards, saturated or bright accents: bunting, leaves, flowers, glow, stars)
-- 2. outline gaps: a 1px hole in a straight run of ink (#2b1c26) on a building edge -> ink
-- 3. opacity: every pixel set (nil -> nearest set neighbour); #000000 -> ink, #ffffff -> cream
-- 4. stand points (+-10px) and compass_clear are checked for non-street intruders; only tiny clusters are overpainted
-- 5. HP.assertClean (reported, not fatal), then export final/<region>.png
-- Signature: return function(c, L, X) ... end
return function(c, L, X)
  local floor, abs, max, min = math.floor, math.abs, math.max, math.min
  local W, H = c.w, c.h
  local INK, CREAM = "#2b1c26", "#f8eacc"
  local RA = X.RAMPS
  local N4 = { {1, 0}, {-1, 0}, {0, 1}, {0, -1} }
  local DIAG = { {1, 1}, {-1, 1}, {1, -1}, {-1, -1} }

  local function dist(a, b)
    local r1, g1, b1 = X.rgb(a)
    local r2, g2, b2 = X.rgb(b)
    return math.sqrt((r1 - r2) ^ 2 + (g1 - g2) ^ 2 + (b1 - b2) ^ 2)
  end
  local function satmax(h) -- saturation 0..1, max channel
    local r, g, b = X.rgb(h)
    local mx, mn = max(r, g, b), min(r, g, b)
    return (mx > 0 and (mx - mn) / mx or 0), mx
  end
  local function get(x, y)
    if x < 0 or y < 0 or x >= W or y >= H then return nil end
    return c:get(x, y)
  end
  local function key(x, y) return y * W + x end

  -- protected: saturated (bunting, leaves, flowers, roofs), bright (glow, stars, sparkles), or near an accent ramp highlight
  local PROT = { X.HUB.glow, CREAM }
  for _, nm in ipairs({ "GOLDL", "MAPLE", "ROSE", "LEAFG", "ORANGE", "GREEN", "TEAL", "PLUM" }) do
    for i = 4, 6 do PROT[#PROT + 1] = RA[nm][i] end
  end
  local function protected(h)
    local s, mx = satmax(h)
    if s > 0.3 or mx >= 235 then return true end
    for _, p in ipairs(PROT) do if dist(h, p) <= 18 then return true end end
    return false
  end
  -- street: desaturated mid-tones (cobble, stair, stone)
  local function streetish(h)
    local s, mx = satmax(h)
    return s < 0.28 and mx >= 40 and mx <= 240
  end

  -- 1. stray pixels (decide on the original snapshot, apply afterwards)
  local strayFix = {}
  for y = 1, H - 2 do
    for x = 1, W - 2 do
      local p = get(x, y)
      if p and not protected(p) then
        local n, ok = {}, true
        for i, d in ipairs(N4) do
          n[i] = get(x + d[1], y + d[2])
          if not n[i] then ok = false end
        end
        if ok then
          local far, agree = true, true
          for i = 1, 4 do if dist(p, n[i]) < 110 then far = false end end
          for i = 1, 4 do for j = i + 1, 4 do if dist(n[i], n[j]) > 36 then agree = false end end end
          local dither = false
          for _, d in ipairs(DIAG) do
            local q = get(x + d[1], y + d[2])
            if q and dist(p, q) <= 20 then dither = true end
          end
          if far and agree and not dither and not protected(n[1]) then
            -- majority of the four (they agree, so this is normally n[1])
            local cnt, best, bestN = {}, n[1], 0
            for i = 1, 4 do
              cnt[n[i]] = (cnt[n[i]] or 0) + 1
              if cnt[n[i]] > bestN then best, bestN = n[i], cnt[n[i]] end
            end
            strayFix[#strayFix + 1] = { x, y, best }
          end
        end
      end
    end
  end
  for _, f in ipairs(strayFix) do c:put(f[1], f[2], f[3]) end

  -- 2. outline gaps: a non-ink, non-accent pixel that breaks a straight 1px ink run
  local gaps = {}
  for y = 2, H - 3 do
    for x = 2, W - 3 do
      local p = get(x, y)
      if p and p ~= INK and not protected(p) then
        local vert = get(x, y - 1) == INK and get(x, y + 1) == INK and get(x - 1, y) ~= INK and get(x + 1, y) ~= INK
          and (get(x, y - 2) == INK or get(x, y + 2) == INK)
        local horz = get(x - 1, y) == INK and get(x + 1, y) == INK and get(x, y - 1) ~= INK and get(x, y + 1) ~= INK
          and (get(x - 2, y) == INK or get(x + 2, y) == INK)
        if vert or horz then gaps[#gaps + 1] = { x, y } end
      end
    end
  end
  for _, g in ipairs(gaps) do c:put(g[1], g[2], INK) end

  -- 3. opacity: fill unset pixels from the nearest set pixel (ring search), then remap pure black/white
  local holes = {}
  for y = 0, H - 1 do
    for x = 0, W - 1 do
      if not c:get(x, y) then holes[#holes + 1] = { x, y } end
    end
  end
  local filled, fallback = 0, 0
  for _, hp in ipairs(holes) do
    local found
    for r = 1, 8 do
      for dy = -r, r do
        for dx = -r, r do
          if not found and max(abs(dx), abs(dy)) == r then found = get(hp[1] + dx, hp[2] + dy) end
        end
      end
      if found then break end
    end
    if found then
      c:put(hp[1], hp[2], found)
      filled = filled + 1
    else
      c:put(hp[1], hp[2], CREAM)
      fallback = fallback + 1
    end
  end
  local blk, wht = 0, 0
  for y = 0, H - 1 do
    for x = 0, W - 1 do
      local p = c:get(x, y)
      if p == "#000000" then c:put(x, y, INK) blk = blk + 1
      elseif p == "#ffffff" then c:put(x, y, CREAM) wht = wht + 1 end
    end
  end

  -- 4. stand points and compass corner: report non-street intruders, overpaint only tiny stray clusters
  local zones = {}
  for _, s in ipairs(L.stand) do zones[#zones + 1] = { s[1] - 10, s[2] - 10, s[1] + 10, s[2] + 10 } end
  zones[#zones + 1] = { 380, 262, W - 1, H - 1 }
  local seen = {}
  local intruders, overpainted, reported = 0, 0, 0
  -- an intruder is a non-street pixel that is not building outline (ink is never a stray prop)
  local function intrudes(h) return h ~= INK and not streetish(h) end
  local function cluster(x0, y0)
    local cl, seenL, stack = {}, { [key(x0, y0)] = true }, { { x0, y0 } }
    while #stack > 0 and #cl <= 40 do
      local p = table.remove(stack)
      cl[#cl + 1] = p
      for _, d in ipairs(N4) do
        local nx, ny = p[1] + d[1], p[2] + d[2]
        local q = get(nx, ny)
        if q and intrudes(q) and not seenL[key(nx, ny)] then
          seenL[key(nx, ny)] = true
          stack[#stack + 1] = { nx, ny }
        end
      end
    end
    return cl, seenL
  end
  for _, z in ipairs(zones) do
    for y = max(0, z[2]), min(H - 1, z[4]) do
      for x = max(0, z[1]), min(W - 1, z[3]) do
        local h = c:get(x, y)
        if h and intrudes(h) and not seen[key(x, y)] then
          local cl, seenL = cluster(x, y)
          for k in pairs(seenL) do seen[k] = true end
          intruders = intruders + #cl
          if #cl <= 6 then
            -- clearly a stray prop: repaint with the most common street colour around it
            local cnt, best, bestN = {}, nil, 0
            for _, p in ipairs(cl) do
              for dy = -4, 4 do
                for dx = -4, 4 do
                  local q = get(p[1] + dx, p[2] + dy)
                  if q and streetish(q) then
                    cnt[q] = (cnt[q] or 0) + 1
                    if cnt[q] > bestN then best, bestN = q, cnt[q] end
                  end
                end
              end
            end
            if best then
              for _, p in ipairs(cl) do c:put(p[1], p[2], best) end
              overpainted = overpainted + #cl
            else
              reported = reported + #cl
            end
          else
            reported = reported + #cl
          end
        end
      end
    end
  end

  -- report
  print(string.format("p4-tidy %s: stray fixed %d | outline gaps filled %d | unset filled %d (fallback %d) | black->ink %d, white->cream %d",
    X.region or "?", #strayFix, #gaps, filled, fallback, blk, wht))
  print(string.format("p4-tidy %s: stand/compass non-street px %d (overpainted %d, reported only %d)",
    X.region or "?", intruders, overpainted, reported))
  local okA, errA = pcall(X.HP.assertClean, c)
  print("p4-tidy " .. (X.region or "?") .. ": HP.assertClean " .. (okA and "ok" or ("FAILED: " .. tostring(errA))))

  -- 5. export the finished region
  if X.region then
    local dir = X.SRC .. "/v3/shop-street/final/"
    pcall(function() app.fs.makeAllDirectories(dir) end)
    c:save{ png = dir .. X.region .. ".png", scale = 1 }
    print("p4-tidy exported " .. dir .. X.region .. ".png")
  end
  return c
end
