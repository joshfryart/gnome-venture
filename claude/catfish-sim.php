<?php
// Balance sim: php claude/catfish-sim.php <run minutes> <cycles> [taps per day]. Greedy active player, Nap at the end of every run.
// Third argument (default 0): active play, taps on the dangling fish per Hollow day (the server pays at most 360). The taps are spread evenly over the day's 1440 minutes,
// each paid max(1, floor(kph x 5 / 3600 x tier)) by catfish_play_value() at that minute's income, tiers 1 / 0.5 / 0.25 by tap number within the day.
// After every cycle it asserts that a full day of those taps at the run's final income is at most 10% of a full day of idle income (kph x 24), and exits 1 if not.
function is_admin(){return false;} function setting($n){return '';}
require __DIR__ . '/../game/includes/catfish.php';
$mins=(int)($argv[1]??120); $cycles=(int)($argv[2]??10); $taps=max(0,min(CATFISH_PLAY_TIERS[count(CATFISH_PLAY_TIERS)-1][0],(int)($argv[3]??0))); $yarn=0; $cat=['mood'=>'lazy'];
$clock=0; $acc=0.0; $dayTaps=0; $bad=0; $playAll=0.0; $idleAll=0.0;
echo "run length {$mins}m, {$taps} taps a day: ";
for($c=1;$c<=$cycles;$c++){ $up=[]; $k=0.0; $runk=0.0; $kph=catfish_kph($up,$cat,true,$yarn); $playRun=0.0;
 for($t=1;$t<=$mins;$t++){ $kph=catfish_kph($up,$cat,true,$yarn); $k+=$kph/60; $runk+=$kph/60;
  if($taps>0){ if($clock%1440===0) $dayTaps=0; $clock++; $acc+=$taps/1440;
   while($acc>=1 && $dayTaps<360){ $acc-=1; $dayTaps++; $v=catfish_play_value($kph,$dayTaps); $k+=$v; $runk+=$v; $playRun+=$v; } }
  while(true){ $best=null;$bv=0;
   foreach(CATFISH_UPGRADES as $key=>$d){ $n=$up[$key]??0; $cc=catfish_cost($key,$n); if($cc>$k) continue;
    $u2=$up; $u2[$key]=$n+1; $v=(catfish_kph($u2,$cat,true,$yarn)-$kph)/$cc; if($v>$bv){$bv=$v;$best=$key;} }
   if(!$best)break; $n=$up[$best]??0; $k-=catfish_cost($best,$n); $up[$best]=$n+1; $kph=catfish_kph($up,$cat,true,$yarn); } }
 $dayPlay=0.0; for($i=1;$i<=$taps;$i++) $dayPlay+=catfish_play_value($kph,$i); $dayIdle=$kph*24;
 if($dayPlay>0.10*$dayIdle) $bad++;
 $playAll+=$dayPlay; $idleAll+=$dayIdle;
 $y=catfish_nap_yarn((int)$runk,$cat); $yarn+=$y; printf("[%d: run %s +%dY =%d%s] ",$c,number_format($runk),$y,$yarn,$taps>0?sprintf(", play %.1f%% of a day's idle",100*$dayPlay/max(1,$dayIdle)):'');}
echo "\n";
if($taps>0){ printf("play Kibble / daily idle income over %d cycles: %.2f%% (limit 10%%) -> %s\n",$cycles,100*$playAll/max(1,$idleAll),$bad?"FAIL ($bad cycles over)":"ok"); exit($bad?1:0); }
