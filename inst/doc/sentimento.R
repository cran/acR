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
  dpi        = 140
)
library(acR)

## ----pkg----------------------------------------------------------------------
library(acR)
library(dplyr)

## ----corpus-------------------------------------------------------------------
textos <- c(
  # Favoráveis
  "Excelente proposta que moderniza o sistema e protege as geracoes futuras.",
  "Aprovamos com convicção esta reforma responsável e necessária ao país.",
  "Vitória histórica para a economia: reforma corrige distorções antigas.",
  "Reforma equilibrada garante sustentabilidade fiscal e futuro promissor.",
  "Conquista importante que beneficia trabalhadores e empresas do Brasil.",
  # Contrários
  "Esta reforma é um retrocesso vergonhoso que prejudica os trabalhadores.",
  "Voto contra: proposta desastrosa ataca os mais pobres e vulneráveis.",
  "Uma tragédia nacional: estão roubando direitos duramente conquistados.",
  "Rejeitamos com indignação essa proposta injusta e cruel com o povo.",
  "Reforma péssima que aprofunda desigualdades e destrói a proteção social.",
  # Neutros / técnicos
  "O texto substitutivo altera o artigo 201 da Constituição Federal.",
  "O relatório final incorporou emendas apresentadas em plenário.",
  "A comissão aprovou o parecer com dez votos a favor e oito contra.",
  "A proposta segue para votação na próxima sessão ordinária."
)

df <- data.frame(
  text     = textos,
  posicao  = c(rep("favor", 5), rep("contra", 5), rep("neutro", 4)),
  partido  = c("PT","PSD","PL","MDB","PSDB",
               "PSOL","PT","PDT","PSOL","PCdoB",
               "MDB","PSDB","PL","MDB"),
  stringsAsFactors = FALSE
)
corpus <- ac_corpus(df)
corpus

## ----sentiment----------------------------------------------------------------
sent <- ac_sentiment(corpus)
sent

## ----validacao----------------------------------------------------------------
sent |>
  dplyr::left_join(df |> dplyr::mutate(doc_id = paste0("doc_", dplyr::row_number())),
                   by = "doc_id") |>
  dplyr::count(posicao, sentiment) |>
  tidyr::pivot_wider(names_from = sentiment, values_from = n, values_fill = 0L)

## ----metodos------------------------------------------------------------------
sent_sum   <- ac_sentiment(corpus, method = "sum")
sent_mean  <- ac_sentiment(corpus, method = "mean")
sent_ratio <- ac_sentiment(corpus, method = "ratio")

comparacao <- data.frame(
  doc_id = sent_sum$doc_id,
  sum    = round(sent_sum$score,   2),
  mean   = round(sent_mean$score,  2),
  ratio  = round(sent_ratio$score, 2)
)
head(comparacao, 10)

## ----plot-bar, fig.height=6---------------------------------------------------
ac_plot_sentiment(sent, type = "bar") +
  ggplot2::labs(
    title    = "Sentimento por documento",
    subtitle = "Contagem de palavras positivas vs. negativas (OpLexicon)",
    caption  = "acR - ac_plot_sentiment(type = \"bar\")"
  )

## ----plot-density, fig.height=5-----------------------------------------------
ac_plot_sentiment(sent, type = "density") +
  ggplot2::labs(
    title    = "Distribuição de scores de sentimento",
    subtitle = "Bimodalidade sugere polarização; unimodal sugere consenso"
  )

## ----plot-line, fig.height=5--------------------------------------------------
ac_plot_sentiment(sent, type = "line") +
  ggplot2::labs(
    title    = "Sentimento ao longo dos documentos (ordem de entrada)",
    subtitle = "Substitua a ordem por data em corpora reais"
  )

## ----por-partido--------------------------------------------------------------
por_partido <- sent |>
  dplyr::left_join(df |> dplyr::mutate(doc_id = paste0("doc_", dplyr::row_number())),
                   by = "doc_id") |>
  dplyr::group_by(partido) |>
  dplyr::summarise(
    n_docs     = dplyr::n(),
    score_med  = round(mean(score), 2),
    score_dp   = round(stats::sd(score, na.rm = TRUE), 2),
    n_positivo = sum(sentiment == "positivo"),
    n_negativo = sum(sentiment == "negativo"),
    n_neutro   = sum(sentiment == "neutro"),
    .groups    = "drop"
  ) |>
  dplyr::arrange(dplyr::desc(score_med))

por_partido

## ----plot-partidos, fig.height=6----------------------------------------------
if (requireNamespace("ggplot2", quietly = TRUE)) {
  ggplot2::ggplot(
    por_partido,
    ggplot2::aes(x = stats::reorder(partido, score_med), y = score_med,
                 fill = score_med > 0)
  ) +
    ggplot2::geom_col(alpha = 0.85, show.legend = FALSE) +
    ggplot2::geom_hline(yintercept = 0, linetype = 2, color = "grey40") +
    ggplot2::coord_flip() +
    ggplot2::scale_fill_manual(values = c("TRUE" = "#166534", "FALSE" = "#991B1B")) +
    ggplot2::labs(
      title    = "Sentimento médio por partido",
      subtitle = "Score médio agregando pronunciamentos por sigla partidária",
      x        = NULL,
      y        = "Score médio (positivo = verde, negativo = vermelho)",
      caption  = "acR"
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      plot.title    = ggplot2::element_text(face = "bold"),
      plot.subtitle = ggplot2::element_text(color = "grey40", size = 10),
      panel.grid.major.y = ggplot2::element_blank()
    )
}

## ----plot-xray, fig.height=5--------------------------------------------------
ac_plot_xray(corpus, terms = c("reforma", "trabalhadores", "aprovar", "vergonha")) +
  ggplot2::labs(
    title    = "Onde os termos-chave aparecem no corpus",
    subtitle = "Cada ponto marca uma ocorrência do termo (posição relativa no texto)"
  )

## ----exportar, eval=FALSE-----------------------------------------------------
# # Tabela por partido pronta para colar no LaTeX
# ac_export(por_partido, arquivo = "sentimento_por_partido.tex", formato = "latex")
# 
# # CSV para Excel/planilha
# ac_export(sent, arquivo = "sentimento.csv", formato = "csv")
# 
# # Se quiser passar para a etapa qualitativa (LLM):
# # amostrar documentos ambíguos (perto de score = 0) para revisão humana
# casos_limitrofes <- sent |> dplyr::filter(abs(score) <= 1)

