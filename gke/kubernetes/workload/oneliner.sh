TIMEFORMAT=%R;
for i in {1..50}
do
  sleep 5
  time timeout 300s ./test.sh
  sleep 5
done
