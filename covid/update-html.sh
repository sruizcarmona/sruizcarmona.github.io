conda activate rmarkdown
Rscript -e 'library(rmarkdown); rmarkdown::render("covid_plots.Rmd", encoding = encoding, output_file = "index.html")'
git commit -am 'covidplots update'
git push origin master
