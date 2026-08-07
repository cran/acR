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
library(acR)
library(dplyr)

## ----corpus-------------------------------------------------------------------
df <- data.frame(
  doc_id = paste0("d", sprintf("%02d", 1:12)),
  text = c(
    "Apoio integralmente esta reforma que simplifica o sistema tributario.",
    "Sou favoravel a proposta: reduz distorcoes historicas do setor.",
    "Voto sim com plena adesao: precisamos modernizar a estrutura fiscal.",
    "Aprovo a reforma tributaria, e uma conquista para o desenvolvimento.",
    "Rejeito esta proposta, e um retrocesso para os trabalhadores.",
    "Voto contra: a reforma prejudica os mais pobres e as pequenas empresas.",
    "Sou contrario a essa proposta, ela beneficia apenas grandes corporacoes.",
    "Nao apoio o texto atual, precisa de revisao profunda antes da votacao.",
    "O texto substitutivo altera o artigo 145 da Constituicao Federal.",
    "O relatorio incorporou 47 emendas apresentadas em plenario.",
    "A comissao aprovou o parecer com 15 votos a favor e 8 contra.",
    "O projeto seguira para votacao na proxima sessao ordinaria."
  ),
  partido = c("PT","PSD","PL","MDB","PSOL","PT","PDT","PSOL",
              "MDB","PSDB","PL","MDB"),
  stringsAsFactors = FALSE
)

corpus <- ac_corpus(df)
corpus

## ----codebook-----------------------------------------------------------------
cb <- ac_qual_codebook(
  name         = "posicao_reforma_tributaria",
  instructions = paste(
    "Classifique a posicao do parlamentar sobre a reforma tributaria",
    "com base no discurso apresentado."
  ),
  categories = list(
    favor = list(
      definition   = "Apoio explicito a aprovacao da reforma tributaria.",
      examples_pos = c("Sou a favor desta reforma que simplifica o sistema."),
      examples_neg = c("O texto altera o artigo 145 da Constituicao Federal."),
      weight       = 1
    ),
    contra = list(
      definition   = "Oposicao explicita a reforma, com argumentos de rejeicao.",
      examples_pos = c("Voto contra: prejudica os trabalhadores."),
      examples_neg = c("Precisa de ajustes antes da votacao."),
      weight       = 1.2  # categoria com mais dificuldade retorica
    ),
    neutro = list(
      definition   = "Discurso tecnico ou processual, sem posicionamento claro.",
      examples_pos = c("O relatorio incorporou emendas apresentadas."),
      examples_neg = c("Sou totalmente contra esta proposta.")
    )
  ),
  lang = "pt"
)

cb

## ----save-codebook------------------------------------------------------------
arquivo_cb <- tempfile(fileext = ".yaml")
ac_qual_save_codebook(cb, path = arquivo_cb)
cat("Codebook salvo em:", arquivo_cb, "\n")

## ----simular-resultado--------------------------------------------------------
set.seed(42)
resultado <- tibble::tibble(
  doc_id = df$doc_id,
  categoria = c(rep("favor", 4), rep("contra", 4), rep("neutro", 4)),
  confidence_score = c(1.00, 1.00, 0.67, 1.00,
                       1.00, 1.00, 1.00, 0.67,
                       1.00, 1.00, 0.67, 1.00),
  reasoning = c(
    "Apoio explicito com 'apoio integralmente'.",
    "Uso do adjetivo 'favoravel' e 'reduz distorcoes'.",
    "Voto declarado, mas ambivalente entre favor e neutro.",
    "'Aprovo' e 'conquista' marcam adesao.",
    "'Rejeito' e 'retrocesso' marcam oposicao.",
    "'Voto contra' e argumento distributivo.",
    "'Sou contrario' com justificativa.",
    "'Nao apoio' + pede revisao (borderline neutro/contra).",
    "Descreve alteracao normativa sem posicionar.",
    "Descreve processo legislativo.",
    "Numeros do resultado, sem opiniao. Borderline.",
    "Encaminhamento processual."
  )
)
resultado

## ----distribuicao-------------------------------------------------------------
resultado |>
  dplyr::count(categoria) |>
  dplyr::mutate(pct = round(100 * n / sum(n), 1))

## ----low-conf-----------------------------------------------------------------
resultado |>
  dplyr::filter(confidence_score < 1.0) |>
  dplyr::select(doc_id, categoria, confidence_score, reasoning)

## ----amostra------------------------------------------------------------------
amostra <- ac_qual_sample(
  resultado,
  n        = 4,
  strategy = "uncertainty"
)
amostra |> dplyr::select(doc_id, categoria, confidence_score, sample_reason)

## ----export-excel, eval=FALSE-------------------------------------------------
# ac_qual_export_for_review(amostra, path = "revisao.xlsx", corpus = corpus)
# # ... revisor humano preenche a coluna categoria_humano no Excel ...
# revisado <- ac_qual_import_human("revisao.xlsx")

## ----reliability--------------------------------------------------------------
humano <- tibble::tibble(
  doc_id    = resultado$doc_id,
  categoria = c(rep("favor", 4), rep("contra", 4),
                "neutro","neutro","favor","neutro")  # 1 discordancia
)

irr <- ac_qual_reliability(
  llm       = resultado,
  human     = humano,
  bootstrap = 100L
)
irr

## ----report-------------------------------------------------------------------
arquivo_md <- tempfile(pattern = "relatorio-", fileext = ".md")

ac_qual_report(
  coded       = resultado,
  codebook    = cb,
  reliability = irr,
  chat        = "anthropic/claude-sonnet-4-5",  # ou objeto Chat
  title       = "Classificacao de posicionamento na reforma tributaria",
  author      = "Silva, A.; Souza, B.",
  method      = "Corpus de 12 pronunciamentos parlamentares (2023-2024).",
  format      = "md",
  path        = arquivo_md,
  lang        = "pt"
)

## ----preview-report-----------------------------------------------------------
cat(head(readLines(arquivo_md), 40), sep = "\n")

## ----html, eval=FALSE---------------------------------------------------------
# ac_qual_report(
#   coded       = resultado,
#   codebook    = cb,
#   reliability = irr,
#   format      = "html",
#   path        = "apendice_metodo.html",
#   lang        = "pt"      # ou "en" para submissao internacional
# )

