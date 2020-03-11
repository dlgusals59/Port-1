#패키지 설치 밎 불로오기

#install.packages("qgraph")
#install.packages("SentimentAnalysis")
#install.packages("KoNLP")
#install.packages("rvest")
#install.packages("RSelenium")
#install.packages("wordcloud")
#install.packages("stringr")
#install.packages("seleniumPipes")
library("qgraph")
library("SentimentAnalysis")
library("rvest")
library("KoNLP")
library("wordcloud")
library("stringr")
library("RSelenium")
library("seleniumPipes")
library("tm")
library("plotrix")

library("RSelenium")
#에브리타임 로그인
remDr<-remoteDriver(remoteServerAddr="localhost", port=4445L, browserName="chrome")
remDr$open()
remDr$navigate("https://everytime.kr/hotarticle/p/1")

txt_id<-remDr$findElement(using="name",value="userid")
txt_pw<-remDr$findElement(using="name",value="password")
login_btn<-remDr$findElement(using="class",value="submit") 

txt_id$setElementAttribute("value","★★★★") # ★에 아이디 입력
txt_pw$setElementAttribute("value","★★★★") # ★에 비밀번호 입력
login_btn$clickElement()
#데이터 크롤링
contents=list()
for (i in 1:181){
  print(i)
  if(i%%50==0){
    remDr$close()
    remDr$open()
    remDr$navigate(paste0("https://everytime.kr/hotarticle/p/",i))
    txt_id<-remDr$findElement(using="name",value="userid")
    txt_pw<-remDr$findElement(using="name",value="password")
    login_btn<-remDr$findElement(using="class",value="submit") 
    Sys.sleep(0.2)
    txt_id$setElementAttribute("value","dlgusals59") # ★에 아이디 입력
    Sys.sleep(0.2)
    txt_pw$setElementAttribute("value","465713as") # ★에 비밀번호 입력
    Sys.sleep(0.2)
    login_btn$clickElement()
  }
  Sys.sleep(0.3)
  url_item<-remDr$getPageSource()[[1]]
  url_item<-read_html(url_item, encoding="UTF-8") 
  link=url_item%>%html_nodes(".article")%>%html_nodes(".wrap article")%>%html_nodes("a")%>%html_attr("href")
  link1=paste0("https://everytime.kr",link[seq(1,40,2)])
  Sys.sleep(0.2)
  if(i!=181){
    for(j in 1:20){
      remDr$navigate(link1[j])
      Sys.sleep(0.3)
      url_item<-remDr$getPageSource()[[1]]
      url_item<-read_html(url_item, encoding="UTF-8") 
      title=url_item%>%html_nodes(".article")%>%html_nodes(".wrap article")%>%html_nodes("h2")%>%html_text() 
      content=url_item%>%html_nodes(".article")%>%html_nodes(".wrap article")%>%html_nodes("p")%>%html_text() 
      contents[[(i-1)*20+j]]=c(title,content)
      Sys.sleep(0.3)
    }
  }
  else{
    for(j in 1:3){
      remDr$navigate(link1[j])
      Sys.sleep(0.3)
      url_item<-remDr$getPageSource()[[1]]
      url_item<-read_html(url_item, encoding="UTF-8") 
      title=url_item%>%html_nodes(".article")%>%html_nodes(".wrap article")%>%html_nodes("h2")%>%html_text() 
      content=url_item%>%html_nodes(".article")%>%html_nodes(".wrap article")%>%html_nodes("p")%>%html_text() 
      contents[[(i-1)*20+j]]=c(title,content)
      Sys.sleep(0.3)
    }
  }
  remDr$navigate(paste0("https://everytime.kr/hotarticle/p/",i+1))
}

#실시간 데이터 처리로 인한 중복된 게시물들 삭제
for(i in 3:length(contents)){
  print(i)
  if(all(contents[i-1]%in%contents[i])){
    contents[i]=NULL
  } 
  if(all(contents[i-2]%in%contents[i])){
    contents[i]=NULL
  }
}
#전처리 실시
contents=str_replace_all(contents,"[[:digit:]]","")
contents=str_replace_all(contents,"[[:lower:]]","")
contents=str_replace_all(contents,"[[:upper:]]","")
contents=str_replace_all(contents,"\\[~!@#$%^&*()_+=?]<>"," ")
contents=str_replace_all(contents,"\\~"," ")
contents=str_replace_all(contents,"\\,"," ")
contents=str_replace_all(contents,"\\."," ")
contents=str_replace_all(contents,"제곧내","")
contents=str_replace_all(contents,"\\?"," ")
contents=str_replace_all(contents,"\\!"," ")
contents=str_replace_all(contents,"(ㅜ|ㅠ|ㅗ|ㅑ)+"," ")
contents=str_replace_all(contents,"[ㄱ-ㅎ]","")
contents=str_replace_all(contents,"\\/"," ")
contents=str_replace_all(contents,"\\_"," ")
contents=str_replace_all(contents,"\\:"," ")
contents=str_replace_all(contents,"★","")
contents=str_replace_all(contents,"\\-"," ")
contents=str_replace_all(contents,"\\)"," ")
contents=str_replace_all(contents,"\\%"," ")
contents=str_replace_all(contents,"\\^"," ")
contents=str_replace_all(contents,"\\'"," ")
contents=str_replace_all(contents,"\\※"," ")
contents=str_replace_all(contents,"\\ㅡ","")
contents=str_replace_all(contents,"\\;"," ")
contents=str_replace_all(contents,"\\<U+0001F616>"," ")
contents=str_replace_all(contents,"\\■"," ")
contents=str_replace_all(contents,"\\≪"," ")
contents=str_replace_all(contents,"\\≥"," ")
contents=str_replace_all(contents,"\\∀"," ")
contents=str_replace_all(contents,"\\≤"," ")
contents=str_replace_all(contents,"\\☆","")
contents=str_replace_all(contents,"\\★","")
contents=str_replace_all(contents,"\\♡","")
contents=str_replace_all(contents,"\\♥","")
contents <- gsub("[[:punct:]]", " ", contents)



#dictonary에 없는 "댓글"이라는 단어 추가
new_term=c("댓글") 
new_dic <- data.frame(new_term , "ncn")
#여러 사전을 합친 새로운 사전을 생성
buildDictionary(ext_dic = c('sejong', 'woorimalsam', 'insighter'),user_dic = new_dic) 
#명사 추출
out1=lapply(contents,extractNoun)


out_v <- do.call(c, out1)
wt <- table(out_v)
#한글은 모호할 수 있으므로 2음절 이상의 명사들로만 확인을 해봄
wt <- wt[nchar(names(wt)) > 1] 
#상위 빈도의 40개의 단어 확인
sort(wt, decreasing = T)[1:40]


#워드 클라우드 생성
pdf.options(family = "Korea1deb")
pal <- brewer.pal(8,"Dark2")
wordcloud(words=names(wt), freq=wt, min.freq=150,random.order=F, random.color=T, colors=pal)

########################################################
#감성분석
#긍정을 나타내는 단어들 불러오기
positive = readLines("C:/Users/korea/Desktop/positive.txt", encoding = "UTF-8")
positive=positive[-(1:20)]
#부정을 나타내는 단어들 불러오기
negative = readLines("C:/Users/korea/Desktop/negative.txt", encoding = "UTF-8")
negative=negative[-(1:16)]

#혐오를 나타내는 단어들 불러오기
Hyum_o=readLines("C:/Users/korea/Desktop/Hyum_o.txt", encoding = "UTF-8")


words=unlist(out1)
pos.matches = match(words, positive)           # words의 단어를 positive에서 matching
neg.matches = match(words, negative)
Hyum_o.matches = match(words, Hyum_o)
pos.matches = !is.na(pos.matches)            # NA 제거, 위치(숫자)만 추출
neg.matches = !is.na(neg.matches)
Hyum_o.matches = !is.na(Hyum_o.matches)
head(words[neg.matches])
#부정에서 혐오를 나타내는 단어들만 빨간 글씨 처리
color=ifelse(names(table(words[neg.matches]))%in%names(table(words[Hyum_o.matches])),"red","black")
#부정의미의 워드 클라우드
wordcloud(words=names(table(words[neg.matches])), freq=table(words[neg.matches]),min.freq = 35,random.order=F, colors=color,ordered.colors=T)

#감성분석
rate=c(length(words)-sum(pos.matches)-sum(neg.matches),sum(pos.matches),sum(neg.matches))
lbls=paste(c("중립","긍정","부정"),round(rate/sum(rate),2))
pie(rate,labels = lbls,col=c("blue","green","red"))

###################################################################
##########################단어 연결망#########################
x=VCorpus(VectorSource(out1))
dtm.k <- TermDocumentMatrix(x)
mat=as.matrix(dtm.k)
inspect(dtm.k)
#자주 쓰이는 단어 순으로 order 처리
word.count <- rowSums(mat)  ##각 단어별 합계를 구함
word.order <- order(word.count, decreasing=T)  #다음으로 단어들을 쓰인 횟수에 따라 내림차순으로 정렬
freq.words <- dtm.k[word.order[1:20], ] #Term Document Matrix에서 자주 쓰인 단어 상위 20개에 해당하는 것만 추출
co.matrix <- as.matrix(freq.words) %*% t(as.matrix(freq.words))  #행렬의 곱셈을 이용해 Term Document Matrix를 Co-occurence Matrix로 변경
#단어 연결망 그림 
qgraph(co.matrix,
       labels=rownames(co.matrix),   ##label 추가
       diag=F,                       ## 자신의 관계는 제거함
       layout='spring',              ##노드들의 위치를 spring으로 연결된 것 처럼 관련이 강하면 같이 붙어 있고 없으면 멀리 떨어지도록 표시됨
       edge.color='blue',
       vsize=log(diag(co.matrix))*1.5) 
#부정적인 단어 연결망 그림
negcon=list()
k=1
for(i in 1:3200){
  negaa=match(out1[[i]],negative)
  negaa=!is.na(negaa)
  if(any(negaa)){
    negcon[[k]]=out1[[i]][negaa]
    k=k+1
  }  
}
x=VCorpus(VectorSource(negcon))
dtm.k <- TermDocumentMatrix(x)
mat=as.matrix(dtm.k)
inspect(dtm.k)
#자주 쓰이는 단어 순으로 order 처리
word.count <- rowSums(mat)  ##각 단어별 합계를 구함
word.order <- order(word.count, decreasing=T)  #다음으로 단어들을 쓰인 횟수에 따라 내림차순으로 정렬
freq.words <- dtm.k[word.order[1:20], ] #Term Document Matrix에서 자주 쓰인 단어 상위 20개에 해당하는 것만 추출
co.matrix <- as.matrix(freq.words) %*% t(as.matrix(freq.words))  #행렬의 곱셈을 이용해 Term Document Matrix를 Co-occurence Matrix로 변경
#단어 연결망 그림 
qgraph(co.matrix,
       labels=rownames(co.matrix),   ##label 추가
       diag=F,                       ## 자신의 관계는 제거함
       layout='spring',              ##노드들의 위치를 spring으로 연결된 것 처럼 관련이 강하면 같이 붙어 있고 없으면 멀리 떨어지도록 표시됨
       edge.color='blue',
       vsize=log(diag(co.matrix))*1.5) 

#########################################

#감성분석 긍정은 +1 부정은 -2
con=rep(0,3200)
for(i in 1:3200){
  posaa=match(out1[[i]],positive)
  negaa=match(out1[[i]],negative)
  posaa=!is.na(posaa)
  negaa=!is.na(negaa)
  con[i]=sum(posaa)-2*sum(negaa)
  
}
senti=c(length(con[con>0]),length(con[con==0]),length(con[con<0]))
lbls=round(senti/sum(senti)*100,2)
pie(senti,labels=lbls,col=c("green","blue","red"))
