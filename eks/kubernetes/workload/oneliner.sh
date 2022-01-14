TIMEFORMAT=%R;
for i in {1..10}
do
  sleep 5
  time ./test.sh
  sleep 5
done
