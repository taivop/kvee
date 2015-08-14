id_start=2500000
id_end=$((2600000-1))
step=10000

for i in `seq -f %.0f $id_start $step $id_end`
do
	r < scrape.R --no-save --args $i $((i+step-1)) &

done