id_start=1150000
id_end=$((1300000-1))
step=15000

for i in `seq -f %.0f $id_start $step $id_end`
do
	r < scrape.R --no-save --args $i $((i+step-1)) &

done


wait


id_start=1000000
id_end=$((1150000-1))
step=15000

for i in `seq -f %.0f $id_start $step $id_end`
do
	r < scrape.R --no-save --args $i $((i+step-1)) &

done