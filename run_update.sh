id_start=2597176
id_end=$((2730000-1))
step=50000

for i in `seq -f %.0f $id_start $step $id_end`
do
	r < scrape.R --no-save --args $i $((i+step-1)) &

done


wait