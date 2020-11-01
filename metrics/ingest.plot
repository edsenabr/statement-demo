run=ARG1
start=strftime("%d/%m %H:%M", ARG2)
if (tm_mday(ARG2) == tm_mday(ARG3) ) {
	end=strftime("%H:%M", ARG3)
} else {
	end=strftime("%d/%m %H:%M", ARG3)
}
input=sprintf("metrics-ingest-%s.csv", run)

set datafile separator ','
set xdata time 
set key outside center bottom horizontal autotitle columnheader
set timefmt "%Y-%m-%dT%H:%M:%S"
set format x "%H:%M" # otherwise it will show only MM:SS
set term pngcairo enhanced size 1440, 900 lw 3
set style line 1 lt 1 lc rgb "grey" lw 0.5 # linestyle for the grid
set grid ls 1 # enable grid with specific linestyle
set border 12 lw 1
set border 3 lw 1
set output sprintf("metrics-ingest-%s.png", run)
set xtics 60 # smaller ytics
set style data lines
set ytics add autofreq

set multiplot \
title sprintf("Ingestion test #%s (%s ~ %s)", run, start, end) noenhanced \
layout 3,1 \
rowsfirst downwards 

set title "Resources"
set ylabel "% used"

plot input using 1:2 , \
	'' using 1:3, \
	'' using 1:4, \
	'' using 1:5, \
	'' using 1:6, \
	'' using 1:7

set title "Operations (Millions)"
set ylabel "ingestion operations per minute"
set y2label "Search Latency "
#set ytics  format "%'.0f"
set y2tics add autofreq

plot input using 1:($8/1000000), \
	'' using 1:12 axes x1y2, \
	'' using 1:13 axes x1y2

unset y2label
unset y2tics

set title "Queues"
set ylabel "Queue size"
set ytics add autofreq

plot input using 1:14, \
	'' using 1:15

#plot "metrics.csv" using 1:2 with lp ls 2, '' using 1:3 with lines ls 3, '' using 1:4 with lines ls 4, '' using 1:5 with lines ls 5
