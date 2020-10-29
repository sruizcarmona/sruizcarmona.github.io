source /Users/sruizcarmona/miniconda3/etc/profile.d/conda.sh
conda activate rstudio

# only run if covid_data.rda is from day before
# meaning that it has not been yet calculated for the day
file_date=`GetFileInfo -m covid_data.rda | cut -d' ' -f1 | awk '{print $3$1$2}' FS='/'`
today=`date  +%Y%m%d`

# check also that link exists
today_day=`date +%-d`
today_month=`date +%B | tr '[:upper:]' '[:lower:]'`
today_weekday=`date +%A | tr '[:upper:]' '[:lower:]'`

url_prefix="/"
fornotfor=""
function get_today_url_all () {
    today_day=$1
    url_prefix=$2
    fornotfor=$3
    today_url_all=(
    https://www.dhhs.vic.gov.au/${url_prefix}coronavirus-update-${fornotfor}victoria-${today_day}-${today_month}-2020
    https://www.dhhs.vic.gov.au/${url_prefix}coronavirus-update-${fornotfor}victoria-${today_day}-${today_month}
    https://www.dhhs.vic.gov.au/${url_prefix}coronavirus-update-${fornotfor}victoria-${today_weekday}-${today_day}-${today_month}
    https://www.dhhs.vic.gov.au/${url_prefix}coronavirus-update-${fornotfor}victoria-${today_weekday}-${today_day}-${today_month}-2020
    )
}
get_today_url_all $today_day  $url_prefix $fornotfor

found=0
if [ $file_date -eq $today ]; then
    exit
else
    for i in "${today_url_all[@]}"; do
        if [[ "$found" -eq 0 ]] && curl --output /dev/null --silent --head --fail "$i"; then
            found=1
            break
        fi
    done
    # try with for before victoria
    fornotfor="for-"
    get_today_url_all $today_day $url_prefix $fornotfor
    for i in "${today_url_all[@]}"; do
        echo $i
        if [[ "$found" -eq 0 ]] && curl --output /dev/null --silent --head --fail "$i"; then
            found=1
            break
        fi
    done
    # try with date with preceded 0
    today_day=`date +%d`
    fornotfor=""
    get_today_url_all $today_day $url_prefix $fornotfor
    for i in "${today_url_all[@]}"; do
        if [[ "$found" -eq 0 ]] && curl --output /dev/null --silent --head --fail "$i"; then
            found=1
            break
        fi
    done
    #try with different prefix
    today_day=`date +%-d`
    url_prefix="media-release-"
    get_today_url_all $today_day  $url_prefix $fornotfor
    for i in "${today_url_all[@]}"; do
        if [[ "$found" -eq 0 ]] && curl --output /dev/null --silent --head --fail "$i"; then
            found=1
            break
        fi
    done
    # try with date with preceded 0
    today_day=`date +%d`
    for i in "${today_url_all[@]}"; do
        if [[ "$found" -eq 0 ]] && curl --output /dev/null --silent --head --fail "$i"; then
            found=1
            break
        fi
    done
    # exit if url not found
    if [[ "$found" -eq 0 ]]; then
        exit
    fi
fi

# only run following lines if file is from yesterday and the links exist
Rscript -e 'library(rmarkdown); rmarkdown::render("covid_plots.Rmd", encoding = encoding, output_file = "index.html")'
git add index.html covid_data.rda
git commit -m 'covidplots auto update'
git push origin master
