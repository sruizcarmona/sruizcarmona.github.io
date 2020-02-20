for f in `awk '{print $1}' FS=":" sym_list.txt`; 
do 
	echo "<div class=\"vote-icon\" style=\"color:black\"> <i class=\"fa $f\"> $f </i> </div>"
done
