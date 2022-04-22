FILE=$1
NTHREADS=$2
JULIA_EXE="/home/netto/julia/julia"

for ((i=1;i<=$NTHREADS;i++)) do
    echo "Running with $i threads"
    $JULIA_EXE -t$i $FILE
    echo "~~~~~~~"
done
