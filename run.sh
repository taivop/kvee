id_start=2350000
id_end=$((2500000-1))
step=15000

for i in `seq -f %.0f $id_start $step $id_end`
do
	r < scrape.R --no-save --args $i $((i+step-1)) &

done


wait


id_start=2200000
id_end=$((2350000-1))
step=15000

for i in `seq -f %.0f $id_start $step $id_end`
do
	r < scrape.R --no-save --args $i $((i+step-1)) &

done


wait


id_start=2050000
id_end=$((2200000-1))
step=15000

for i in `seq -f %.0f $id_start $step $id_end`
do
	r < scrape.R --no-save --args $i $((i+step-1)) &

done


wait


id_start=1900000
id_end=$((2050000-1))
step=15000

for i in `seq -f %.0f $id_start $step $id_end`
do
	r < scrape.R --no-save --args $i $((i+step-1)) &

done