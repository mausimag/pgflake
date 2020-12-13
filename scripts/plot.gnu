set terminal pngcairo enhanced font "arial,10" fontscale 1.0 size 600, 400 
set output './scripts/out.png'
set grid
set title "inserts"
set ylabel "time (ms)"
set colorsequence classic
set for [i=1:3] linetype i lw 1.5
plot for [i=2:4] '/dev/stdin' using i:xtic(1) title col with lines