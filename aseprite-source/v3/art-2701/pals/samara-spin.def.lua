-- Samara Spin (thornblade, rare): a maple key that learned to fly on purpose. Quirk: it spins; one wing paper is thorn-edged.
return function(H)
  local c, P = H.c, H.P
  H.shadow(32, 60, 10, 2)  -- it hovers
  -- long paper wing (tilted up-right)
  c:part(H.Pg({ {28,36},{34,24},{50,10},{58,12},{56,22},{44,34},{32,44} }), "gold")
  c:part(H.Pg({ {30,40},{36,30},{48,18},{52,22},{44,32},{34,42} }), "ember", { band = 1, noshade = true, nopop = true })
  -- veins
  if H.big then c:line({ {H.S(32), H.S(38)}, {H.S(55), H.S(13)} }, 1) end
  -- small second wing (down-left)
  c:part(H.Pg({ {24,46},{14,52},{8,56},{14,58},{24,54} }), "gold", { band = 1 })
  -- seed pod body
  c:part(H.E(27, 44, 10, 11), "wood")
  c:part(H.E(27, 53, 5, 3), "wood", { band = 1, nopop = true })
  -- thorn bits on the lower wing edge (quirk)
  c:px(H.S(11), H.S(52), P.ember.deep) c:px(H.S(15), H.S(56), P.ember.deep)
  H.eye(24, 42)
  H.cheek(30, 49)
  -- spin marks
  c:fillMask(H.R(10, 28, 15, 28), P.cream) c:fillMask(H.R(8, 33, 11, 33), P.cream)
  c:sparkle(H.S(48), H.S(46)) c:sparkle(H.S(14), H.S(14))
end
