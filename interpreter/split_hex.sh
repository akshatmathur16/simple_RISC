
rm -rf new_instr_file
while read line; do

    input_var=`echo "$line" | sed 's/^.*: //'| sed 's/^0x//'`

# Loop through the string in chunks of 2 characters
for ((i=0; i<8; i+=2)); do
    echo "${input_var:$i:2}" >> new_instr_file
done

done < instr_file
