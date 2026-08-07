## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  echo       = TRUE,
  eval       = TRUE,
  collapse   = TRUE,
  comment    = "#>",
  fig.width  = 8.5,
  fig.height = 6,
  fig.align  = "center",
  out.width  = "100%",
  dpi        = 140
)
library(acR)

## ----corpus-------------------------------------------------------------------
textos <- c(
  # Tema 1: reforma tributária (8 documentos)
  "A reforma tributaria simplifica o sistema de impostos e reduz a carga fiscal para empresas.",
  "O IVA dual substitui PIS, COFINS e ICMS no novo modelo de arrecadacao federal.",
  "Deputados debatem aliquotas e excecoes tributarias para setores economicos.",
  "A reforma tributaria unifica impostos indiretos e simplifica obrigacoes das empresas.",
  "Empresarios criticam a alta carga tributaria brasileira sobre o consumo popular.",
  "O relator propoe aliquotas diferenciadas para produtos essenciais no novo IVA.",
  "A reforma tributaria promete reduzir litigios fiscais e aumentar a arrecadacao.",
  "Congresso avalia impacto da reforma tributaria sobre pequenas empresas e servicos.",
  # Tema 2: IA e proteção de dados (8 documentos)
  "O marco legal da inteligencia artificial regulamenta o uso de algoritmos e dados.",
  "Privacidade e seguranca de dados pessoais sao prioridades da nova lei de IA.",
  "Algoritmos de inteligencia artificial precisam de transparencia e auditoria publica.",
  "A LGPD estabelece regras para tratamento de dados pessoais por empresas e governo.",
  "Modelos de IA generativa levantam questoes eticas sobre direitos autorais e dados.",
  "A ANPD fiscaliza o cumprimento das regras de protecao de dados no Brasil.",
  "Especialistas defendem regulamentacao de algoritmos preditivos usados por bancos.",
  "Inteligencia artificial na saude requer protocolos de seguranca e privacidade.",
  # Tema 3: habitação e cidade (8 documentos)
  "O programa habitacional amplia recursos federais para moradia popular urbana.",
  "O deficit habitacional afeta milhoes de familias de baixa renda nas cidades.",
  "Urbanizacao de favelas e regularizacao fundiaria avancam em municipios brasileiros.",
  "Moradia digna e direito social garantido pela Constituicao federal de 1988.",
  "Assentamentos precarios crescem nas periferias metropolitanas do pais.",
  "O programa Minha Casa Minha Vida entrega novas unidades habitacionais populares.",
  "Especialistas em urbanismo debatem alugueis abusivos nas grandes cidades.",
  "Politicas de habitacao popular incluem regularizacao fundiaria e infraestrutura urbana.",
  # Tema 4: educação (8 documentos)
  "A educacao basica recebe novos recursos do Fundeb ampliado pelo Congresso.",
  "Alfabetizacao na idade certa e meta central do novo Plano Nacional de Educacao.",
  "Professores debatem remuneracao e condicoes de trabalho nas escolas publicas.",
  "O ensino medio integrado ao tecnico expande vagas em institutos federais.",
  "A avaliacao Prova Brasil mede aprendizagem em portugues e matematica.",
  "Politicas de permanencia estudantil ampliam bolsas para universitarios pobres.",
  "O piso salarial nacional dos professores e reajustado pelo governo federal.",
  "A formacao continuada de professores e desafio permanente da educacao basica."
)

corpus <- ac_corpus(
  data.frame(
    text = textos,
    tema = rep(c("tributario","tecnologia","habitacao","educacao"), each = 8L),
    stringsAsFactors = FALSE
  )
)
corpus

## ----limpeza------------------------------------------------------------------
corpus_limpo <- ac_clean(
  corpus,
  remove_stopwords = "pt",
  extra_stopwords  = c("brasil", "pais", "sobre", "novo", "nova")
)
corpus_limpo

## ----tune---------------------------------------------------------------------
tune <- ac_lda_tune(
  corpus_limpo,
  k_range = 2:8,
  seed    = 42L
)
tune

## ----plot-tune----------------------------------------------------------------
ac_plot_lda_tune(tune) +
  ggplot2::labs(
    title    = "Perplexidade por numero de topicos (K)",
    subtitle = "Menor = melhor ajuste. Procure o cotovelo, nao o minimo global.",
    caption  = "acR - ac_lda_tune()"
  )

## ----lda----------------------------------------------------------------------
modelo <- ac_lda(
  corpus_limpo,
  k    = 4L,
  seed = 42L
)
modelo

## ----beta---------------------------------------------------------------------
beta <- modelo$terms
head(beta, 10)

## ----plot-topics, fig.height=7------------------------------------------------
ac_plot_lda_topics(modelo, top_n = 10L) +
  ggplot2::labs(
    title    = "Top 10 termos por topico (LDA, K=4)",
    subtitle = "Beta = probabilidade do termo dado o topico"
  )

## ----gamma--------------------------------------------------------------------
gamma <- modelo$documents
head(gamma, 12)

## ----dominante----------------------------------------------------------------
dominante <- gamma |>
  dplyr::group_by(doc_id) |>
  dplyr::slice_max(gamma, n = 1L, with_ties = FALSE) |>
  dplyr::ungroup() |>
  dplyr::rename(topico_dominante = topic, prob = gamma)

head(dominante, 12)

## ----validacao----------------------------------------------------------------
# Recuperar o metadado 'tema' e cruzar com o topico dominante
tema_real <- corpus[, c("doc_id", "tema")]
comparacao <- merge(dominante, tema_real, by = "doc_id")

# Tabela de contingencia: topico dominante x tema real
table(comparacao$topico_dominante, comparacao$tema)

## ----rotulos------------------------------------------------------------------
top_terms_por_topico <- beta |>
  dplyr::group_by(topic) |>
  dplyr::slice_max(beta, n = 7L, with_ties = FALSE) |>
  dplyr::summarise(
    top_termos = paste(term, collapse = ", "),
    .groups    = "drop"
  )

top_terms_por_topico

## ----gamma-heatmap, fig.height=6----------------------------------------------
gamma_ord <- gamma |>
  dplyr::mutate(doc_id = factor(doc_id, levels = sort(unique(doc_id))))

ggplot2::ggplot(
  gamma_ord,
  ggplot2::aes(x = factor(topic), y = doc_id, fill = gamma)
) +
  ggplot2::geom_tile(color = "white") +
  ggplot2::scale_fill_gradient(
    low  = "#F1F5F9",
    high = ac_palette(1),
    name = "gamma"
  ) +
  ggplot2::labs(
    title    = "Composicao tematica de cada documento (matriz gamma)",
    subtitle = "Cores mais fortes = maior peso do topico no documento",
    x        = "Topico",
    y        = "Documento",
    caption  = "acR - LDA soft assignment"
  ) +
  theme_ac() +
  ggplot2::theme(
    axis.text.y = ggplot2::element_text(size = 7)
  )

## ----exportar, eval=FALSE-----------------------------------------------------
# ac_export(beta,  arquivo = "lda_beta.csv",  formato = "csv")
# ac_export(gamma, arquivo = "lda_gamma.csv", formato = "csv")
# 
# # Tabela pronta para LaTeX
# ac_export(top_terms_por_topico, arquivo = "lda_topicos.tex", formato = "latex")
# 
# # Objeto R serializado (recarregavel via readRDS)
# saveRDS(modelo, "lda_modelo.rds")

