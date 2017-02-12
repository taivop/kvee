id_start=2747175
id_end=$((2887616))
step=25000

for i in `seq -f %.0f $id_start $step $id_end`
do
	r < scrape.R --no-save --args $i $((i+step-1)) &

done


wait