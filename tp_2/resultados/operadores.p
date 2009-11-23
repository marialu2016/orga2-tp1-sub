#!/usr/bin/gnuplot

set title "Operadores en SIMD"
set terminal png size 800,600
set output "operadores.png"
set ylabel "# de clocks"
plot "robertsS.dat" using 1 w points t "Roberts" 3, "prewittS.dat" using 1 w points t "Prewitt" 5, "freichenS.dat" using 1 w points t "Frei-Chen" 4, "SobelXYS.dat" using 1 w points t "Sobel_xy" 8
