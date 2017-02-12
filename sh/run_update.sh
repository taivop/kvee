id_start=2747175
id_end=$((2887616))
num_threads=8
step=$(((id_end-id_start+num_threads)/num_threads))

for i in `seq -f %.0f $id_start $step $id_end`
do
	#R < scrape.R --no-save --args $i $((i+step-1)) &
	echo $i $((i+step-1))
done


wait