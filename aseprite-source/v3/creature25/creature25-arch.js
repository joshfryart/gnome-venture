/* Motion extras for the three creature25 examples. Loaded after assets/fightarch.js and creature25-rigs.js. Each keeps its body type's whole pose set and adds only what its new parts need:
 * boar: the leaf is a spring, the snort puff is hidden until a pose shows it; hawk: the kinked crest feather is a spring; frog: the fly buzzes and takes off when the frog moves. */
(function () {
  var A = window.FE_ARCH, O = 'cubic-bezier(.2,.7,.3,1)', S = 'ease-in-out';
  function ext(base, more) { var o = {}, k; for (k in base) o[k] = base[k]; for (k in more) o[k] = more[k]; return o; }
  function add(pose, tracks) { return ext(pose, { tracks: ext(pose.tracks, tracks) }); }   // the same pose plus tracks for the new parts
  function puff(t0) { return [[0, { o: 0 }], [t0, { o: 0 }], [t0 + 60, { o: 1, sx: .6, sy: .6 }], [t0 + 320, { o: 1, x: 4, y: -3, sx: 1.3, sy: 1.3 }, O], [t0 + 520, { o: 0, x: 7, y: -6, sx: 1.6, sy: 1.6 }]]; }
  var Q = A['quad.bear'], P = Q.poses;
  A['quad.boar25'] = ext(Q, {
    hide: { puff: 1 }, fidgets: ['snort', 'paw', 'sniff', 'scratch'],
    springs: ext(Q.springs, { leaf: { k: 70, d: 3.5, g: .22, w: .7, max: 55, dir: [.5, -1] } }),
    poses: ext(P, {
      charge: add(P.charge, { puff: puff(180).concat([[900, { o: 0 }]]) }),                       // it snorts as it paws the ground
      hit: add(P.hit, { puff: [[0, { o: 0 }], [40, { o: 1 }], [260, { o: 1, x: 5, y: -5, sx: 1.4, sy: 1.4 }, O], [380, { o: 0, x: 7, y: -7 }]] }),
      snort: { dur: 1300, tracks: { head: [[0, {}], [200, { r: -10 }, O], [320, { r: 8 }], [520, { r: -4 }], [700, { r: 6 }], [820, { r: -3 }], [1300, {}, S]], body: [[0, {}], [320, { r: 2 }], [1300, {}, S]],
        puff: puff(300).concat([[840, { o: 0 }], [900, { o: 1, sx: .6, sy: .6 }], [1150, { o: 1, x: 4, y: -3, sx: 1.2, sy: 1.2 }, O], [1300, { o: 0, x: 6, y: -5 }]]),
        eyes: [[0, { sy: 1 }], [300, { sy: .2 }], [520, { sy: .2 }], [640, { sy: 1 }], [1300, { sy: 1 }]] } }
    })
  });
  var B = A.bird;
  A.bird25 = ext(B, { springs: ext(B.springs, { crest: { k: 90, d: 4, g: .2, w: .5, max: 50, dir: [.2, -1] }, tail: { k: 150, d: 9, g: .07, w: .25, max: 22, dir: [-1, .1] } }) });
  var F = A.frog, FP = F.poses;
  function buzz(dur) { var out = [], n = 12, i; for (i = 0; i <= n; i++) out.push([Math.round(dur * i / n), { x: 2.2 * Math.sin(i * 2.1), y: -1.2 - 1.2 * Math.cos(i * 1.3) }]); out[n][1] = out[0][1]; return out; }
  function away(dur, up) { return [[0, {}], [dur * .15, { x: 5, y: -up, r: 30 }, O], [dur * .45, { x: -6, y: -up - 3, r: -30 }, S], [dur * .75, { x: 4, y: -up * .6, r: 20 }, S], [dur, {}, S]]; }   // off it goes, round, and back to the same spot
  A.frog25 = ext(F, {
    fidgets: ['croak', 'eyes', 'flick'],
    poses: ext(FP, {
      idle: add(FP.idle, { fly: buzz(1700) }), hop: add(FP.hop, { fly: away(800, 14) }), hit: add(FP.hit, { fly: away(380, 8) }), dodge: add(FP.dodge, { fly: away(520, 10) }), run: add(FP.run, { fly: away(440, 6) }),
      ko: add(FP.ko, { fly: [[0, {}], [300, { x: 6, y: -10 }, O], [900, { x: 0, y: 3 }, S]] }),   // the fly settles on the flattened frog
      croak: add(FP.croak, { fly: away(1300, 9) }),
      flick: { dur: 1100, tracks: {   // it tries for the fly and misses
        body: [[0, { sx: 1, sy: 1 }], [250, { sx: 1.08, sy: .9 }, O], [380, { sx: .9, sy: 1.16 }, O], [560, { sx: 1.05, sy: .95 }], [1100, { sx: 1, sy: 1 }, S]],
        eyeL: [[0, {}], [250, { y: 1 }], [380, { y: -3 }, O], [1100, {}, S]], eyeR: [[0, {}], [250, { y: 1 }], [380, { y: -3 }, O], [1100, {}, S]],
        fly: [[0, {}], [300, { y: -1 }], [380, { x: 7, y: -12, r: 40 }, O], [700, { x: -5, y: -9, r: -30 }, S], [1100, {}, S]] } }
    })
  });
  A.slug['c25-boar'] = { size: 1.087 }; A.slug['c25-hawk'] = { attack: 'swoop', size: 1.087 }; A.slug['c25-frog'] = { size: 1.087 };   // size: the gnome's pixel scale
})();
