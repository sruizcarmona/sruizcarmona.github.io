cp index.html kk.html;
sed -e '/absteel-1\"/{s//absteel-X\"/;:a' -e '$!N;$!ba' -e '}' kk.html > kk;
mv kk kk.html;
for i in {2..33};
do
    echo $i;
    sed -e '/absteel-1\"/{s//absteel-'$i'\"/;:a' -e '$!N;$!ba' -e '}' kk.html > kk;
    mv kk kk.html;
done
sed -e 's/absteel-X\"/absteel-1\"/' kk.html > kk;
mv kk kk.html;
mv kk.html index.html
