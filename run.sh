id_start=1750000
id_end=$((1900000-1))
step=15000

for i in `seq -f %.0f $id_start $step $id_end`
do
	r < scrape.R --no-save --args $i $((i+step-1)) &

done


wait


id_start=1600000
id_end=$((1750000-1))
step=15000

for i in `seq -f %.0f $id_start $step $id_end`
do
	r < scrape.R --no-save --args $i $((i+step-1)) &

done


wait


id_start=1450000
id_end=$((1600000-1))
step=15000

for i in `seq -f %.0f $id_start $step $id_end`
do
	r < scrape.R --no-save --args $i $((i+step-1)) &

done


wait


id_start=1300000
id_end=$((1450000-1))
step=15000

for i in `seq -f %.0f $id_start $step $id_end`
do
	r < scrape.R --no-save --args $i $((i+step-1)) &

done