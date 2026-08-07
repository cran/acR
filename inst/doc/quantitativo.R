## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  collapse   = TRUE,
  comment    = "#>",
  fig.width  = 8.5,
  fig.height = 5.5,
  fig.align  = "center",
  out.width  = "100%",
  dpi        = 140
)

## ----pkg----------------------------------------------------------------------
library(acR)

## ----corpus-------------------------------------------------------------------
textos <- c(
  "O governo anunciou nova politica fiscal para reduzir o deficit publico.",
  "A oposicao critica o aumento dos gastos e da divida publica no orcamento.",
  "Parlamentares debatem a reforma tributaria e o imposto de renda das familias.",
  "O presidente vetou o projeto que ampliava beneficios sociais para os pobres.",
  "O Senado aprovou o marco legal para investimentos em infraestrutura logistica.",
  "Deputados votam pela reducao da carga tributaria para pequenas empresas.",
  "A politica monetaria do Banco Central eleva a taxa de juros para conter inflacao.",
  "A inflacao acima da meta preocupa economistas e o mercado financeiro.",
  "O relator defendeu emendas ao texto do orcamento com foco em saude e educacao.",
  "A comissao aprovou o projeto que amplia beneficios sociais no interior.",
  "O ministro afirmou que a reforma tributaria simplifica o sistema para empresas.",
  "Lideres da oposicao pediram vistas ao projeto na comissao de constituicao."
)

meta <- data.frame(
  text = textos,
  tema = c("fiscal","fiscal","tributario","social","infraestrutura",
           "tributario","monetario","monetario","fiscal","social",
           "tributario","fiscal"),
  stringsAsFactors = FALSE
)

corpus <- ac_corpus(meta)
corpus

## ----limpeza------------------------------------------------------------------
corpus_limpo <- ac_clean(
  corpus,
  remove_stopwords = "pt",
  extra_stopwords  = c("pra", "pro")  # opcional: coloquiais
)
corpus_limpo

## ----tokenizacao--------------------------------------------------------------
tokens <- ac_tokenize(corpus_limpo, n = 1L)
head(tokens, 12)

## ----frequencia---------------------------------------------------------------
contagem <- ac_count(corpus_limpo)
contagem

## ----top-termos, fig.height=6-------------------------------------------------
top <- ac_top_terms(contagem, n = 15)
ac_plot_top_terms(top) +
  ggplot2::labs(
    title    = "Termos mais frequentes no corpus",
    subtitle = "Discursos legislativos - 12 documentos fabricados",
    caption  = "acR - vignette Analise Quantitativa"
  )

## ----wordcloud, fig.height=6--------------------------------------------------
ac_wordcloud(contagem, max_words = 40, title = "Panorama do corpus")

## ----wordcloud-comp, fig.height=6---------------------------------------------
# Nosso corpus tem 5 temas distintos — todos entram na comparativa:
ac_plot_wordcloud_comparative(
  corpus,
  group     = tema,
  max_words = 25,
  title     = "Termos distintivos por tema"
)

## ----tfidf, fig.height=6------------------------------------------------------
freq_tema  <- ac_count(corpus_limpo, by = "tema")
tfidf_tema <- ac_tf_idf(freq_tema, by = "tema")

ac_plot_tf_idf(tfidf_tema, by = "tema", n = 6) +
  ggplot2::labs(
    title    = "Termos mais distintivos por tema (TF-IDF)",
    subtitle = "Cada eixo temático como um documento; alta pontuação = termo característico do tema"
  )

## ----keyness, fig.height=6----------------------------------------------------
freq_tema     <- ac_count(corpus_limpo, by = "tema")
freq_2grupos  <- freq_tema[freq_tema$tema %in% c("fiscal", "tributario"), ]

kn <- ac_keyness(freq_2grupos, group = "tema", target = "fiscal")

ac_plot_keyness(kn, n = 10) +
  ggplot2::labs(
    title    = "Palavras distintivas: 'fiscal' vs. 'tributario'",
    subtitle = "Barras positivas = distintivas do tema 'fiscal'"
  )

## ----coocorrencia, fig.height=7-----------------------------------------------
cooc <- ac_cooccurrence(corpus_limpo, window = 5L, min_count = 2L)

if (requireNamespace("ggraph", quietly = TRUE)) {
  ac_plot_cooccurrence(cooc, top_n = 25) +
    ggplot2::labs(
      title    = "Rede de coocorrencia (janela = 5, freq minima = 2)",
      subtitle = "Arestas conectam termos que co-ocorrem no mesmo contexto"
    )
}

## ----coocorrencia-pmi, fig.height=7-------------------------------------------
if (requireNamespace("ggraph", quietly = TRUE)) {
  ac_plot_cooccurrence(cooc, top_n = 25, weight = "pmi") +
    ggplot2::labs(
      title    = "Rede de coocorrencia ponderada por PMI",
      subtitle = "Destaca pares associados alem do esperado por acaso"
    )
}

## ----coocorrencia-circle, fig.height=7----------------------------------------
if (requireNamespace("ggraph", quietly = TRUE)) {
  ac_plot_cooccurrence(cooc, top_n = 25, layout = "circle") +
    ggplot2::labs(
      title    = "Rede de coocorrencia — layout circular",
      subtitle = "Todas as palavras num anel; arestas mostram o grafo cru"
    )
}

## ----coocorrencia-heatmap, fig.height=6---------------------------------------
top_tokens <- ac_top_terms(ac_count(corpus_limpo), n = 12)$token
cooc_mat   <- cooc[cooc$word1 %in% top_tokens & cooc$word2 %in% top_tokens, ]

ggplot2::ggplot(cooc_mat,
                ggplot2::aes(word1, word2, fill = cooc)) +
  ggplot2::geom_tile(color = "white") +
  ggplot2::scale_fill_gradient(low = "#F1F5F9", high = ac_palette(1)) +
  ggplot2::labs(
    title    = "Matriz de coocorrencia (top 12 termos)",
    subtitle = "Alternativa ao grafo quando a rede fica densa",
    x = NULL, y = NULL, fill = "cooc."
  ) +
  theme_ac() +
  ggplot2::theme(
    axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
  )

