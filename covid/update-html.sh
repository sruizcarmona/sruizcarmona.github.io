source /Users/sruizcarmona/miniconda3/etc/profile.d/conda.sh
conda activate rstudio

# only run if covid_data.rda is from day before
# meaning that it has not been yet calculated for the day
file_date=`GetFileInfo -m covid_data.rda | cut -d' ' -f1 | awk '{print $3$1$2}' FS='/'`
today=`date  +%Y%m%d`

# check also that link exists
today_day=`date +%d`
today_month=`date +%B | tr '[:upper:]' '[:lower:]'`
today_url=`echo https://www.dhhs.vic.gov.au/coronavirus-update-victoria-${today_day}-${today_month}-2020`
today_url2=`echo https://www.dhhs.vic.gov.au/coronavirus-update-victoria-${today_day}-${today_month}`

if [ $file_date -eq $today ]; then
    exit
elif ! curl --output /dev/null --silent --head --fail "$today_url"; then
    if ! curl --output /dev/null --silent --head --fail "$today_url2"; then
        exit
    fi
fi


# only run following lines if file is from yesterday and the links exist
Rscript -e 'library(rmarkdown); rmarkdown::render("covid_plots.Rmd", encoding = encoding, output_file = "index.html")'
git commit -am 'covidplots update'
git push origin master
