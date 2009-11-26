#!/usr/bin/gnuplot
set terminal png size 800,600
set output "graf3.png"
set title "Comparación clocks vs operadores y tamaños de imagen"
set style data histogram
set style histogram cluster gap 3
set style fill solid border -1
set boxwidth 0.9
set bmargin 5
set xtics ("bla" 2.0000 -1, "ble" 1.0000 -1) # podria ignorarse pero no se :pi
set xlabel "asdf"
set ylabel "# de clocks"

plot 'data.dat' using 3:xtic(1) t col, '' u 2 t col, '' u 4 t col
