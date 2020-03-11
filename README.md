# 에브리타임 자유게시판 텍스트 마이닝

 ① R SELENIUM을 이용한 실시간 로그인
  > 에브리타임의 게시판을 이용하기 위해서 본인의 계정을 로그인해야된다

 ② 자유 게시판의 데이터 크롤링
  > 실시간 데이터 처리로 인해 중복이 발생되어 중복된 게시물들을 제거해주어야 함

 ③ 전처리 실시
  > 한글을 전처리 함으로 인해 sejong,woorimalsam,insighter 사전들을 이용함

 ④ 명사 추출 후 WordCloud 시각화
  > 2음절 이상의 명사들로만 시각화
<div>
<img width="900" src="https://user-images.githubusercontent.com/48160116/76382786-32b59e00-639d-11ea-82d6-34857e9cc0b2.png">
</div>

 ⑤상위 빈도 20개의 단어(명사) 연결망  

<div>
<img width="900" src="https://user-images.githubusercontent.com/48160116/76382798-39dcac00-639d-11ea-80cc-42426e8148e8.png">
</div>

