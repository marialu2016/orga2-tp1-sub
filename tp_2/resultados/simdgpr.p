#!/usr/bin/gnuplot

set title "SIMD vs General Purpose Registers"
set terminal png size 800,600
set output "simd.png"
set ylabel "# de clocks"

plot "robertsS.dat" using 1 w points t "Roberts SIMD" 1, "robertsG.dat" using 1 w points t "Roberts GPR" 2,\
        "prewittS.dat" using 1 w points t "Prewitt SIMD" 3 ,"prewittG.dat" using 1 w points t "Prewitt GPR" 4, \
        "SobelXYS.dat" using 1 w points t "Sobel_xy SIMD" 5 , "sobelXYG.dat" using 1 w points t  "Sobel_xy GPR" 6  
