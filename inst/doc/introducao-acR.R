## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse   = TRUE,
  comment    = "#>",
  fig.width  = 7,
  fig.height = 4,
  fig.align  = "center",
  dpi        = 120
)

## ----setup--------------------------------------------------------------------
library(acR)

## ----corpus-------------------------------------------------------------------
df <- data.frame(
  id      = paste0("d", 1:8),
  texto   = c(
    "Sou favoravel a reforma tributaria: simplifica o sistema e reduz distorcoes.",
    "Voto contra: essa reforma vai destruir o setor produtivo brasileiro.",
    "Apoio a proposta com forte adesao, ha ganhos claros de eficiencia arrecadatoria.",
    "Rejeito o texto: transfere renda das familias para grandes corporacoes.",
    "Defendo a reforma que corrige as distorcoes historicas do nosso sistema.",
    "Somos contrarios: o projeto beneficia apenas os mais ricos do pais.",
    "Voto sim, precisamos modernizar urgentemente a estrutura tributaria.",
    "Voto nao, os pequenos empresarios serao os grandes prejudicados."
  ),
  partido = c("PT","PL","PT","PL","PT","PL","PT","PL"),
  posicao = c("favor","contra","favor","contra","favor","contra","favor","contra"),
  stringsAsFactors = FALSE
)

corpus <- ac_corpus(df, text = texto, docid = id, meta = c(partido, posicao))
corpus

## ----contagem-----------------------------------------------------------------
corpus_limpo <- ac_clean(corpus, remove_stopwords = "pt")

# Frequência global
freq <- ac_count(corpus_limpo)
ac_top_terms(freq, n = 8)

## ----contagem-grupo-----------------------------------------------------------
freq_lado <- ac_count(corpus_limpo, by = "posicao")
ac_top_terms(freq_lado, n = 5, by = "posicao")

## ----keyness------------------------------------------------------------------
key <- ac_keyness(freq_lado, group = "posicao", target = "favor")
head(key, 6)

## ----plot-keyness-------------------------------------------------------------
if (requireNamespace("ggplot2", quietly = TRUE)) {
  ac_plot_keyness(key, n = 6)
}

## ----sentimento---------------------------------------------------------------
sent <- ac_sentiment(corpus)
sent

## ----plot-sentimento----------------------------------------------------------
if (requireNamespace("ggplot2", quietly = TRUE)) {
  ac_plot_sentiment(sent)
}

## ----modelos------------------------------------------------------------------
ac_qual_recommend_model(task = "coding", budget = "medium", lang = "pt", n = 3)

## ----coding, eval = FALSE-----------------------------------------------------
# codebook <- ac_qual_codebook(
#   name         = "posicionamento",
#   instructions = "Classifique o posicionamento sobre a reforma tributaria.",
#   categories   = list(
#     favor  = list(
#       definition   = "Manifestação favorável à reforma.",
#       examples_pos = "Sou favoravel a reforma, simplifica o sistema."
#     ),
#     contra = list(
#       definition   = "Manifestação contrária à reforma.",
#       examples_pos = "Voto contra, vai destruir o setor produtivo."
#     )
#   )
# )
# 
# codificado <- ac_qual_code(
#   corpus   = corpus,
#   codebook = codebook,
#   model    = "anthropic/claude-sonnet-4-5"
# )

## ----validacao-code, eval = FALSE---------------------------------------------
# # Amostra estratificada priorizando casos incertos
# amostra <- ac_qual_sample(codificado, n = 50, strategy = "uncertainty")
# 
# # Exporta planilha para revisão humana
# ac_qual_export_for_review(amostra, path = "revisao.xlsx", corpus = corpus)
# 
# # Após preencher, reimporta e calcula IRR
# humano <- ac_qual_import_human("revisao.xlsx")
# ac_qual_reliability(llm = codificado, human = humano)

## ----validacao-demo-----------------------------------------------------------
llm_sim <- tibble::tibble(
  doc_id    = paste0("d", 1:8),
  categoria = c("favor","contra","favor","contra","favor","contra","favor","contra")
)
humano_sim <- tibble::tibble(
  doc_id    = paste0("d", 1:8),
  categoria = c("favor","contra","favor","contra","favor","favor","favor","contra")
  # 1 discordância em 8 casos -> ~87.5% de concordância
)

ac_qual_reliability(llm = llm_sim, human = humano_sim, bootstrap = 50)

