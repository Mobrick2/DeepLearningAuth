set size 0.6,0.55
set autoscale
unset log
unset label
set xtic auto
#set xrange[0:25]
#set yrange[0:3]

set ytic auto
unset grid

set key default
set key box 0
set key ins vert
set key top left

set style fill pattern border

unset title
set xlabel "# of Neurons"
set ylabel "VO Construction Time (s)"

set terminal postscript eps enhanced color "Helvetica" 18
set output "vo_construct_time_minist.eps"

plot \
 "voconstructTime.dat" using 1:2 ps 1.5 lt 4 w linesp title "Input-layer",\
 "voconstructTime.dat" using 1:3 ps 1.5 lt 2 w linesp title "Output-layer",\
 "voconstructTime.dat" using 1:4 ps 1.5 lt 3 w linesp title "Other-layer"

