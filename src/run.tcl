
clear -all

analyze -v2k bubble_sort.v
analyze -sv  bubble_sort_sva.sv
analyze -sv  bubble_sort_bind.sv

elaborate -top bubble_sort

clock clk
reset -expression {!rst_n}


prove -all
