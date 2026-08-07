## ----setup, include=FALSE-----------------------------------------------------
knitr::opts_chunk$set(
  echo       = TRUE,
  eval       = TRUE,
  collapse   = TRUE,
  comment    = "#>",
  fig.width  = 8.5,
  fig.height = 5.5,
  fig.align  = "center",
  out.width  = "100%",
  dpi        = 140,
  message    = FALSE,
  warning    = FALSE
)
library(acR)
library(ggplot2)
library(dplyr)
library(tidyr)
set.seed(42)

## ----corpus-------------------------------------------------------------------
df <- data.frame(
  id = paste0("d", sprintf("%02d", 1:16)),
  tema_real = rep(c("democracia", "mercado"), each = 8),
  texto = c(
    "democracia participacao voto liberdade cidadania popular",
    "cidadania direitos participacao democracia representacao politica",
    "voto direitos liberdade cidadania soberania popular",
    "democracia voto participacao popular assembleia direta",
    "participacao social democracia direitos coletivos comunidade",
    "cidadania voto democracia representacao plural minorias",
    "liberdade participacao politica assembleia popular deliberacao",
    "democracia direta cidadania voto plebiscito referendo",
    "mercado economia eficiencia privatizacao competicao livre",
    "privatizacao mercado livre eficiencia produtividade lucro",
    "economia crescimento investimento mercado capital juros",
    "eficiencia mercado economia livre concorrencia produtividade",
    "mercado privado investimento economia lucro capital risco",
    "economia livre mercado eficiencia produtividade escala",
    "crescimento economico mercado investimento privatizacao abertura",
    "mercado competicao eficiencia lucro capital privado"
  ),
  stringsAsFactors = FALSE
)

corpus <- ac_corpus(df, text = texto, docid = id)
corpus

## ----fit----------------------------------------------------------------------
clust <- ac_cluster_documents(corpus)
clust

## ----plot-dendrogram, fig.height=5--------------------------------------------
ac_plot_cluster(clust, kind = "dendrogram")

## ----plot-scatter, fig.height=5-----------------------------------------------
ac_plot_cluster(clust, kind = "scatter")

## ----plot-heatmap, fig.height=6-----------------------------------------------
ac_plot_cluster(clust, kind = "heatmap")

## ----plot-top-terms, fig.height=5.5-------------------------------------------
tokens_com_cluster <- corpus |>
  ac_clean() |>
  ac_count() |>
  left_join(clust$assignments, by = "doc_id") |>
  group_by(cluster, token) |>
  summarise(n = sum(n), .groups = "drop") |>
  rename(doc_id = cluster) |>
  mutate(doc_id = paste0("Cluster ", doc_id))

tfidf_cluster <- ac_tf_idf(tokens_com_cluster)

top_por_cluster <- tfidf_cluster |>
  group_by(doc_id) |>
  slice_max(tf_idf, n = 8) |>
  ungroup() |>
  mutate(token = tidytext::reorder_within(token, tf_idf, doc_id))

ggplot(top_por_cluster, aes(tf_idf, token, fill = doc_id)) +
  geom_col(show.legend = FALSE) +
  tidytext::scale_y_reordered() +
  facet_wrap(~ doc_id, scales = "free") +
  scale_fill_manual(values = ac_palette(clust$k)) +
  labs(
    title    = "Termos mais distintivos por cluster (TF-IDF)",
    subtitle = "O 'o que cada grupo fala de diferente'",
    x = "TF-IDF", y = NULL,
    caption = "acR • pos-clustering"
  ) +
  theme_ac()

## ----plot-silhouette, fig.height=4.5------------------------------------------
if (requireNamespace("cluster", quietly = TRUE)) {
  ks   <- 2:6
  sils <- vapply(ks, function(k_try) {
    ac_cluster_documents(corpus, k = k_try)$silhouette
  }, numeric(1))

  df_sil <- data.frame(k = ks, silhueta = sils)

  ggplot(df_sil, aes(k, silhueta)) +
    geom_line(color = ac_palette(1), linewidth = 1.1) +
    geom_point(size = 3.5, color = ac_palette(1)) +
    geom_point(
      data = df_sil[which.max(df_sil$silhueta), ],
      aes(k, silhueta),
      size = 6, shape = 21, stroke = 1.4,
      fill = "white", color = ac_palette(1)
    ) +
    scale_x_continuous(breaks = ks) +
    labs(
      title    = "Silhueta media por numero de grupos",
      subtitle = "Circulo vazado = k escolhido automaticamente",
      x = "k (numero de clusters)", y = "Silhueta media"
    ) +
    theme_ac()
}

## ----plot-lda-vs-cluster, fig.height=5.5--------------------------------------
lda_fit <- ac_lda(corpus, k = 2, seed = 42)

hard <- clust$assignments |>
  mutate(valor = 1, tipo = paste0("Cluster ", cluster)) |>
  select(doc_id, tipo, valor)

soft <- lda_fit$documents |>
  mutate(tipo = paste0("Topico ", topic), valor = gamma) |>
  select(doc_id, tipo, valor)

plot_df <- bind_rows(
  hard |> mutate(painel = "Hard clustering\n(1 = pertence)"),
  soft |> mutate(painel = "LDA (soft)\n(gamma = proporcao)")
) |>
  mutate(doc_id = factor(doc_id, levels = rev(sort(unique(doc_id)))))

ggplot(plot_df, aes(tipo, doc_id, fill = valor)) +
  geom_tile(color = "white") +
  facet_wrap(~ painel, scales = "free_x") +
  scale_fill_gradient(low = "#F1F5F9", high = ac_palette(1), name = "Valor") +
  labs(
    title    = "Hard vs. soft: a mesma pergunta, duas respostas",
    subtitle = "Cluster da uma etiqueta; LDA da proporcoes por documento",
    x = NULL, y = NULL,
    caption = "acR • ac_cluster_documents vs. ac_lda"
  ) +
  theme_ac() +
  theme(axis.text.x = element_text(angle = 30, hjust = 1))

## ----validacao----------------------------------------------------------------
validacao <- clust$assignments |>
  mutate(tema_real = df$tema_real[match(doc_id, df$id)]) |>
  count(tema_real, cluster)
validacao

## ----kmeans, fig.height=4.5---------------------------------------------------
clust_km <- ac_cluster_documents(corpus, method = "kmeans", k = 2)
ac_plot_cluster(clust_km, kind = "scatter")

