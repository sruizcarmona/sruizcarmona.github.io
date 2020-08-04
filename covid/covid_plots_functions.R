#################
# https://stackoverflow.com/questions/18332463/convert-written-number-to-number-in-r
word2num <- function(word){
    wsplit <- strsplit(tolower(word)," ")[[1]]
    one_digits <- list(zero=0, one=1, two=2, three=3, four=4, five=5,
                       six=6, seven=7, eight=8, nine=9)
    teens <- list(eleven=11, twelve=12, thirteen=13, fourteen=14, fifteen=15,
                  sixteen=16, seventeen=17, eighteen=18, nineteen=19)
    ten_digits <- list(ten=10, twenty=20, thirty=30, forty=40, fifty=50,
                       sixty=60, seventy=70, eighty=80, ninety=90)
    doubles <- c(teens,ten_digits)
    out <- 0
    i <- 1
    while(i <= length(wsplit)){
        j <- 1
        if(i==1 && wsplit[i]=="hundred")
            temp <- 100
        else if(i==1 && wsplit[i]=="thousand")
            temp <- 1000
        else if(wsplit[i] %in% names(one_digits))
            temp <- as.numeric(one_digits[wsplit[i]])
        else if(wsplit[i] %in% names(teens))
            temp <- as.numeric(teens[wsplit[i]])
        else if(wsplit[i] %in% names(ten_digits))
            temp <- (as.numeric(ten_digits[wsplit[i]]))
        if (!exists("temp")) {
          return(NA)
        }
        if(i < length(wsplit) && wsplit[i+1]=="hundred"){
            if(i>1 && wsplit[i-1] %in% c("hundred","thousand"))
                out <- out + 100*temp
            else
                out <- 100*(out + temp)
            j <- 2
        }
        else if(i < length(wsplit) && wsplit[i+1]=="thousand"){
            if(i>1 && wsplit[i-1] %in% c("hundred","thousand"))
                out <- out + 1000*temp
            else
                out <- 1000*(out + temp)
            j <- 2
        }
        else if(i < length(wsplit) && wsplit[i+1] %in% names(doubles)){
            temp <- temp*100
            out <- out + temp
        }
        else{
            out <- out + temp
        }
        i <- i + j
    }
    # return(list(word,out))
    return(out)
}
# word2num("four fifty seven")
# word2num("three")[[2]]
#################
# numbers only
numbers_only <- function(x) grepl("^[0-9]+([,.])?$", x)
#################
# clean HTML
cleanHTML <- function(htmlString) {
  htmlString <- gsub(".&nbsp;", "", htmlString, fixed =TRUE)
  htmlString <- gsub(". &nbsp;", " ", htmlString, fixed =TRUE)
  htmlString <- gsub("&nbsp;", " ", htmlString, fixed =TRUE)
  htmlString <- gsub("\\.<.*?>", "", htmlString)
  htmlString <- gsub("\\.<.*?>", "", htmlString)
  htmlString <- gsub("\\t", "", htmlString)
  return(gsub("<.*?>", "", htmlString))
  }
#################
fix_old_reports <- function(cdata){
  cdata[1,is.na(cdata[1,])] <- c(355,6,0,97)
  cdata[2,c(4,7)] <- c(411,113)
  cdata[3,7] <- 128
  cdata[4,c(4,7)] <- c(520,149)
  cdata[8,c(6,7)] <- c(4,248)
  cdata$deaths[c(14,16)] <- c(8,11)
  # 7 april break of line for transmission
  cdata$community[16] <- 93
  # 16 april no web report (I did 13 just to run the code)
  cdata[25,c(1:3)] <- c("april","16","2020-04-16")
  cdata[25,c(4:9)]<- c(1301,39,18,1137,14,132)
  cdata[54,4] <- 1543
  # 17 may no web report (I did 6 just to run the code)
  cdata[56,c(1:3)] <- c("may","17","2020-05-17")
  cdata[56,c(4:9)]<- c(1561,11,7,1417,18,160)
  cdata[68,'icu'] <- 2
  cdata[68,'recovered'] <- 1549
  return(cdata)
}
#################
get_dhhs_url <- function(day,month){
  day.bkp <- day
  url.prefix <- ''
  dhhs.url <- paste0('https://www.dhhs.vic.gov.au/',url.prefix,'coronavirus-update-victoria-',day,'-',month,'-2020')
  dhhs.url <- gsub(" ","",dhhs.url)
  months <- 1:12
  names(months) <- tolower(month.name)
  weekday <- tolower(weekdays(as.Date(paste0(2020,"-",unname(months[month]),"-",day))))
  if (!url.exists(dhhs.url)) {
      dhhs.url <- paste0('https://www.dhhs.vic.gov.au/',url.prefix,'coronavirus-update-victoria-',day,'-',month)
      if (!url.exists(dhhs.url)) {
          dhhs.url <- paste0('https://www.dhhs.vic.gov.au/',url.prefix,'coronavirus-update-victoria-',weekday,'-',day,'-',month)
          if (!url.exists(dhhs.url)) {
              dhhs.url <- paste0('https://www.dhhs.vic.gov.au/',url.prefix,'coronavirus-update-victoria-',weekday,'-',day,'-',month,'-2020')
          }
      }
  }
  if (!url.exists(dhhs.url)) {
    day <- paste0("0",day)
    dhhs.url <- paste0('https://www.dhhs.vic.gov.au/',url.prefix,'coronavirus-update-victoria-',day,'-',month,'-2020')
    dhhs.url <- gsub(" ","",dhhs.url)
  }
  if (!url.exists(dhhs.url)) {
       dhhs.url <- paste0('https://www.dhhs.vic.gov.au/',url.prefix,'coronavirus-update-victoria-',day,'-',month)
       if (!url.exists(dhhs.url)) {
           dhhs.url <- paste0('https://www.dhhs.vic.gov.au/',url.prefix,'coronavirus-update-victoria-',weekday,'-',day,'-',month)
           if (!url.exists(dhhs.url)) {
               dhhs.url <- paste0('https://www.dhhs.vic.gov.au/',url.prefix,'coronavirus-update-victoria-',weekday,'-',day,'-', month,'-2020')
           }
       }
  }
  # add media-release to base url
  if (!url.exists(dhhs.url)) {
    url.prefix <- 'media-release-'
    day <- day.bkp
    dhhs.url <- paste0('https://www.dhhs.vic.gov.au/',url.prefix,'coronavirus-update-victoria-',day,'-',month,'-2020')
  }
  if (!url.exists(dhhs.url)) {
    dhhs.url <- paste0('https://www.dhhs.vic.gov.au/',url.prefix,'coronavirus-update-victoria-',day,'-',month)
    if (!url.exists(dhhs.url)) {
      dhhs.url <- paste0('https://www.dhhs.vic.gov.au/',url.prefix,'coronavirus-update-victoria-',weekday,'-',day,'-',month)
      if (!url.exists(dhhs.url)) {
        dhhs.url <- paste0('https://www.dhhs.vic.gov.au/',url.prefix,'coronavirus-update-victoria-',weekday,'-',day,'-',month,'-2020')
      }
    }
  }
  if (!url.exists(dhhs.url)) {
    day <- paste0("0",day)
    dhhs.url <- paste0('https://www.dhhs.vic.gov.au/',url.prefix,'coronavirus-update-victoria-',day,'-',month,'-2020')
    dhhs.url <- gsub(" ","",dhhs.url)
  }
  if (!url.exists(dhhs.url)) {
    dhhs.url <- paste0('https://www.dhhs.vic.gov.au/',url.prefix,'coronavirus-update-victoria-',day,'-',month)
    if (!url.exists(dhhs.url)) {
      dhhs.url <- paste0('https://www.dhhs.vic.gov.au/',url.prefix,'coronavirus-update-victoria-',weekday,'-',day,'-',month)
      if (!url.exists(dhhs.url)) {
        dhhs.url <- paste0('https://www.dhhs.vic.gov.au/',url.prefix,'coronavirus-update-victoria-',weekday,'-',day,'-', month,'-2020')
      }
    }
  }
  if (!url.exists(dhhs.url)){
    return(FALSE)
  }
  return (dhhs.url)
}
###############
#function to get cases per day
get_data_from_url <- function(day,month,item){
  dhhs.url <- get_dhhs_url(as.character(day),as.character(month))
  con <- url(dhhs.url)
  htmlcode <- readLines(con)
  close.connection(con)
  if (item == 'html') {
    return (htmlcode)
  }
  if (item == 'cases'){
    cases_match <- str_subset(htmlcode,"total number of coronavirus|total number of cases")
    cases_match <- cleanHTML(cases_match)
    cases_match <- gsub(",","",cases_match[cases_match != ""])
    cases_n <- as.numeric(unlist(str_split(paste(cases_match,collapse=" ")," "))[numbers_only(unlist(str_split(paste(cases_match,collapse=" ")," ")))])
    # cases <- as.numeric(str_replace_all(unlist(str_split(unlist(str_split(paste(cases_match,collapse=" "),"Victoria is | now at "))[2]," "))[1],",",""))
    cases <- max(cases_n)
    return(cases)
  }
  if (item == 'patients'){
    pat_match <- str_subset(htmlcode," in intensive care|recovered")
    pat_clean <- gsub("COVID-19","COVID",gsub(",","",unlist(str_split(pat_match,"[.] "))))
    pat_clean <- cleanHTML(pat_clean)
    # remove sentences without needed information (community transmission and tests)
    pat_clean <- pat_clean[!str_detect(pat_clean,"community|tests|ctive cases")]
    # split by words
    pat_parsed <- unlist(str_split(pat_clean," "))
    patients <- as.numeric(unlist(regmatches(pat_parsed, gregexpr("[[:digit:]]+", pat_parsed))))
    if(any(patients > 50000)) {patients <- patients[patients < 50000]}
    # remove tests, as some times it gets selected
    # manually get from words to numbers the hospital and icu cases
    if (length(patients) < 3){
      # get numbers from all words and keep only the ones with numbers
      extra_num <- sapply(pat_parsed,word2num)[!is.na(sapply(pat_parsed,word2num))]
      if (length(patients) == 1){
        patients <- c(extra_num,patients)
      } else {
        # patients <- c(patients[1],word2num(pat_parsed[which (pat_parsed == 'including') +1]),patients[2])
        patients <- c(patients[1],extra_num[1],patients[2])
      }
    }
    # sometimes hospital and icu have word instead of number, just to fix the order, as icu should always be smaller
    if (length(patients) == 3 && patients[1] < patients[2]) {patients <- patients[c(2,1,3)]}
    return(patients[c(1:3)])
  }
  #check deaths (lots of differences on the first reports) will try to take all of them
  if (item == 'deaths'){
    # fix covid19 so it doesnt account as a number
    # htmlcode <- gsub("COVID-19","COVID",htmlcode)
    max_deaths <- 199 #to check death numbers are not artifacts
    # check word died
    death_match <- str_subset(htmlcode,"died")
    # clean html tags
    death_match <- cleanHTML(death_match)
    # split everything on words
    death_clean <- unlist(str_split(death_match," "))
    death_clean <- death_clean[!death_clean == ""]
    # check if there are numbers on the splitted items
    death_n <- as.numeric(death_clean[numbers_only(death_clean)])
    # double check if the numbers are more than 5 times of previous day, as it is an artifact, then
    if (all(death_n[!is.na(death_n)] > max_deaths)) {
      death_n <- NULL
    }
    # if not, check if some of the words are numbers in letters
    if (length(death_n) == 0){
      death_n <- as.numeric(unlist(lapply(death_clean,word2num)))
    }
    # deaths <- death_n[!is.na(death_n)][1]
    deaths <- max(death_n[!is.na(death_n)])

    # if still, there is no option, change the key word to death and repeat the same
    if (length(death_match) == 0 || length(death_n[!is.na(death_n)]) == 0) {
        death_match <- str_subset(htmlcode,"death")
        # clean html tags
        death_match <- cleanHTML(death_match)
        # there are different matches, normally. check one by one
        for (death_match_i in death_match) {
          # split and remove empty spaces in the beginning
          death_clean <- unlist(str_split(death_match_i," "))
          death_clean <- death_clean[!death_clean == ""]
          # check if numbers
          death_n <- as.numeric(death_clean[numbers_only(death_clean)])
          # death_n <- as.numeric(unlist(regmatches(death_clean, gregexpr("[[:digit:]]+", death_clean))))
          # double check if the numbers are more than 5 times of previous day, as it is an artifact, then
          if (all(death_n[!is.na(death_n)] > max_deaths)) {
            death_n <- NULL
          }
          if (length(death_n) == 0){
            death_n <- as.numeric(unlist(lapply(death_clean,word2num)))
            if (length(death_n[!is.na(death_n)]) != 0){
              break
            }
          }
        }
      deaths <- death_n[!is.na(death_n)][1]
    }
    # if it still persists, it means there are no deaths
    if (length(death_match)==0) {
      deaths <- 0
      return(deaths)
    }
    return(deaths)
  }
  if (item == 'community'){
    # check word died
    comm_match <- str_subset(str_subset(htmlcode,"transmission|source"),"community|unknown")

    # clean html tags and remove commas
    comm_match <- cleanHTML(comm_match)
    comm_match <- gsub(",","",comm_match)
    # split everything on words
    comm_clean <- unlist(str_split(comm_match,"transmission. "))[1]
    comm_clean <- unlist(str_split(comm_clean," "))
    comm_clean <- comm_clean[!comm_clean == ""]
    # check if there are numbers on the splitted items
    comm_n <- as.numeric(comm_clean[numbers_only(comm_clean)])
    # check if no results, and get word2num
    if (length(comm_n) == 0){
      comm_n <- as.numeric(unlist(lapply(comm_clean,word2num)))
    }
    comm <- comm_n[!is.na(comm_n)][1]
    # some times, there is no "community" word on the transmission lines, fix it by changing "community" to "unknown"
    if (sum(!is.na(comm)) == 0) {
      comm_match <- cleanHTML(str_subset(str_subset(htmlcode,"transmission"),"unknown"))
      comm_clean <- unlist(str_split(unlist(str_split(comm_match,"transmission. "))[1]," "))
      comm_n <- as.numeric(comm_clean[numbers_only(comm_clean)])
      if (length(comm_n) == 0){ comm_n <- as.numeric(unlist(lapply(comm_clean,word2num))) }
      comm <- comm_n[!is.na(comm_n)][1]
    }
    return(comm)
  }
}
#########
