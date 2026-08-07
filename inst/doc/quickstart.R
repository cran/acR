## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  fig.width  = 7,
  fig.height = 4
)

## ----setup--------------------------------------------------------------------
library(acR)

## ----corpus-------------------------------------------------------------------
df <- data.frame(
  id       = paste0("d", 1:6),
  texto    = c(
    "Sou favoravel a reforma tributaria que simplifica os impostos.",
    "Voto contra a proposta, ela vai destruir o setor produtivo.",
    "Apoio integralmente a reforma, ha ganhos claros de eficiencia.",
    "Esta reforma e um retrocesso, vamos rejeitar em plenario.",
    "Defendo a proposta que corrige distorcoes historicas do sistema.",
    "Somos contra, o texto beneficia apenas grandes corporacoes."
  ),
  posicao  = c("favor", "contra", "favor", "contra", "favor", "contra"),
  stringsAsFactors = FALSE
)

corpus <- ac_corpus(df, text = texto, docid = id, meta = posicao)
corpus

## ----frequencia---------------------------------------------------------------
corpus <- ac_clean(corpus, remove_stopwords = "pt")
freq_por_grupo <- ac_count(corpus, by = "posicao")
ac_top_terms(freq_por_grupo, n = 5, by = "posicao")

## ----keyness------------------------------------------------------------------
key <- ac_keyness(freq_por_grupo, group = "posicao", target = "favor")
head(key, 5)

## ----sentimento---------------------------------------------------------------
ac_sentiment(corpus)

## ----modelos------------------------------------------------------------------
ac_qual_recommend_model(task = "coding", budget = "medium", lang = "pt", n = 3)

