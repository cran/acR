## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  fig.width  = 7,
  fig.height = 4
)

## ----setup--------------------------------------------------------------------
library(acR)

## ----lexico, include=FALSE----------------------------------------------------
# ac_sentiment() baixa o OpLexicon (GitHub) na primeira execução e guarda
# em cache. Sem acesso a ele, os trechos que dependem do léxico não rodam,
# em vez de interromper a vignette com erro.
tem_lexico <- tryCatch({
  suppressMessages(ac_sentiment(ac_corpus(data.frame(text = "bom"))))
  TRUE
}, error = function(e) FALSE)

## ----aviso-lexico, echo=FALSE, results="asis", eval=!tem_lexico---------------
# cat(
#   "> **Aviso:** o léxico OpLexicon não pôde ser baixado ao gerar esta",
#   "> página (sem acesso à internet), então os trechos que dependem dele",
#   "> não foram executados. Rode a vignette com internet para ver as saídas.",
#   sep = "\n"
# )

## ----corpus-------------------------------------------------------------------
df <- data.frame(
  id       = paste0("d", 1:6),
  texto    = c(
    "Sou favoravel a reforma tributária que simplifica os impostos.",
    "Voto contra a proposta, ela vai destruir o setor produtivo.",
    "Apoio integralmente a reforma, ha ganhos claros de eficiência.",
    "Esta reforma e um retrocesso, vamos rejeitar em plenário.",
    "Defendo a proposta que corrige distorcoes historicas do sistema.",
    "Somos contra, o texto beneficia apenas grandes corporacoes."
  ),
  posicao  = c("favor", "contra", "favor", "contra", "favor", "contra"),
  stringsAsFactors = FALSE
)

corpus <- ac_corpus(df, text = texto, docid = id, meta = posicao)
corpus

## ----frequência---------------------------------------------------------------
corpus <- ac_clean(corpus, remove_stopwords = "pt")
freq_por_grupo <- ac_count(corpus, by = "posicao")
ac_top_terms(freq_por_grupo, n = 5, by = "posicao")

## ----keyness------------------------------------------------------------------
key <- ac_keyness(freq_por_grupo, group = "posicao", target = "favor")
head(key, 5)

## ----sentimento, eval=tem_lexico----------------------------------------------
ac_sentiment(corpus)

## ----modelos------------------------------------------------------------------
ac_qual_recommend_model(task = "coding", budget = "medium", lang = "pt", n = 3)

