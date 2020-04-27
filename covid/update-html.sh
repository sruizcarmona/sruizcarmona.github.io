source /Users/sruizcarmona/miniconda3/etc/profile.d/conda.sh
conda activate rstudio

# only run if covid_data.rda is from day before
# meaning that it has not been yet calculated for the day
file_date=`GetFileInfo -m covid_data.rda | cut -d' ' -f1 | awk '{print $3$1$2}' FS='/'`
today=`date  +%Y%m%d`

if [ $file_date -eq $today ];
then
    exit
fi

Rscript -e 'library(rmarkdown); rmarkdown::render("covid_plots.Rmd", encoding = encoding, output_file = "index.html")'
git commit -am 'covidplots update'
git push origin master
