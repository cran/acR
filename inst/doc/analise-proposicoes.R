## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  eval     = FALSE
)

## ----instalacao---------------------------------------------------------------
# remotes::install_github("andersonheri/acR")
# install.packages("ellmer")
# 
# # Configurar chave de API no .Renviron
# usethis::edit_r_environ()
# # Adicione: GROQ_API_KEY=sua_chave

## ----corpus-------------------------------------------------------------------
# library(acR)
# library(ellmer)
# library(dplyr)
# 
# textos <- c(
#   "Altera a CLT para instituir a escala 4x3, vedando a jornada 6x1.",
#   "Conquista histórica: votaremos favoráveis com convicção.",
#   "Gerará desemprego em massa nas micro e pequenas empresas.",
#   "Concede anistia aos condenados pelos atos de 8 de janeiro de 2023.",
#   "Presos políticos: votar pela anistia é votar pela democracia.",
#   "Anistiar quem atacou o Congresso é uma afronta à democracia.",
#   "Modifica a CF/88, extinguindo a estabilidade para novos servidores.",
#   "Modernização necessária para aumentar eficiência e reduzir custos.",
#   "Ataca direitos conquistados e abre espaço para perseguição política."
# )
# 
# df <- data.frame(
#   id    = c("plp300_ementa",  "plp300_favor",  "plp300_contra",
#             "pl2858_ementa",  "pl2858_favor",  "pl2858_contra",
#             "pec32_ementa",   "pec32_favor",   "pec32_contra"),
#   texto = textos,
#   tema  = c("6x1",     "6x1",     "6x1",
#             "anistia", "anistia", "anistia",
#             "reform",  "reform",  "reform"),
#   tipo  = c("ementa",   "favoravel", "contrario",
#             "ementa",   "favoravel", "contrario",
#             "ementa",   "favoravel", "contrario"),
#   stringsAsFactors = FALSE
# )
# 
# corpus <- ac_corpus(df, text = texto, docid = id)
# print(corpus)

## ----codebook-----------------------------------------------------------------
# codebook <- ac_qual_codebook(
#   name         = "posicionamento_proposicoes",
#   instructions = paste(
#     "Classifique o posicionamento do texto em relação à proposição.",
#     "Use Populista para apelo emocional sem argumentação substantiva."
#   ),
#   categories = list(
#     favoravel      = list(definition = "Apoio explícito à proposição com argumentação substantiva."),
#     contrario      = list(definition = "Oposição à proposição com argumentação substantiva."),
#     neutro_tecnico = list(definition = "Descrição jurídica ou técnica sem valoração explícita."),
#     populista      = list(definition = "Apelo emocional sem evidência ou argumentação técnica."),
#     ambiguo        = list(definition = "Posicionamento contraditório ou impossível de classificar.")
#   ),
#   mode = "manual"
# )
# 
# print(codebook)

## ----codebook-add-exemplos----------------------------------------------------
# # Recriar com exemplos explícitos para as categorias mais difíceis
# codebook <- ac_qual_codebook(
#   name         = "posicionamento_proposicoes",
#   instructions = paste(
#     "Classifique o posicionamento do texto em relação à proposição.",
#     "Use Populista para apelo emocional sem argumentação substantiva."
#   ),
#   categories = list(
#     favoravel = list(
#       definition   = "Apoio explícito à proposição com argumentação substantiva.",
#       examples_pos = c("Esta reforma aumentará a produtividade e reduzirá custos."),
#       examples_neg = c("Votaremos com o coração pela causa do povo.")
#     ),
#     contrario = list(
#       definition   = "Oposição à proposição com argumentação substantiva.",
#       examples_pos = c("Os dados mostram que esta medida aumentará o desemprego."),
#       examples_neg = c("Esta proposta é uma vergonha nacional.")
#     ),
#     neutro_tecnico = list(
#       definition   = "Descrição jurídica ou técnica sem valoração explícita.",
#       examples_pos = c("Altera o art. 58 da CLT, estabelecendo nova escala."),
#       examples_neg = c("Apoiamos esta proposta de modernização.")
#     ),
#     populista = list(
#       definition   = "Apelo emocional sem evidência ou argumentação técnica.",
#       examples_pos = c("Presos políticos: este é o momento da justiça!"),
#       examples_neg = c("Estudos mostram que a medida reduz 15% dos custos."),
#       weight       = 1.5  # categoria mais difícil: peso maior
#     ),
#     ambiguo = list(
#       definition   = "Posicionamento contraditório ou impossível de classificar.",
#       examples_pos = c("Apoio a reforma mas temo suas consequências sociais."),
#       weight       = 1.2
#     )
#   ),
#   mode = "manual"
# )

## ----codebook-hybrid----------------------------------------------------------
# chat_obj <- chat_groq(
#   model = "llama-3.3-70b-versatile",
#   echo  = "none"
# )
# 
# codebook_enriquecido <- ac_qual_codebook_hybrid(
#   codebook = codebook,
#   chat     = chat_obj,
#   n_refs   = 2L,
#   lang     = "pt"
# )
# 
# # Ver definição enriquecida da categoria populista
# cat(codebook_enriquecido$categories$populista$definition)
# cat("\nReferências:\n")
# print(codebook_enriquecido$categories$populista$references)

## ----codebook-merge-----------------------------------------------------------
# codebook_retorico <- ac_qual_codebook(
#   name         = "estilo_retorico",
#   instructions = "Identifique o estilo retórico dominante.",
#   categories   = list(
#     pathos = list(
#       definition   = "Apelo emocional predominante.",
#       examples_pos = c("Não podemos trair a esperança do povo brasileiro.")
#     ),
#     logos = list(
#       definition   = "Apelo racional e argumentativo predominante.",
#       examples_pos = c("Os dados do IBGE confirmam redução de 12% no emprego.")
#     )
#   )
# )
# 
# # Fundir: posicionamento + estilo retórico
# codebook_completo <- ac_qual_codebook_merge(
#   cb1          = codebook_enriquecido,
#   cb2          = codebook_retorico,
#   name         = "posicionamento_e_estilo",
#   on_conflict  = "rename_second",
#   instructions = paste(
#     "Classifique o posicionamento e o estilo retórico do texto.",
#     "Use Populista para apelo emocional sem argumentação."
#   )
# )

## ----codebook-prompt----------------------------------------------------------
# # Gerar system prompt para uso com ellmer
# prompt <- as_prompt(
#   codebook_enriquecido,
#   reasoning        = TRUE,
#   reasoning_length = "short"
# )
# 
# # Inspecionar todas as modificações feitas no codebook
# ac_qual_codebook_history(codebook_enriquecido)

## ----codebook-save------------------------------------------------------------
# ac_qual_save_codebook(
#   codebook_enriquecido,
#   path = "codebook_proposicoes_v1.yaml"
# )
# 
# # Em outra sessão ou para outro pesquisador:
# # codebook <- ac_qual_load_codebook("codebook_proposicoes_v1.yaml")

## ----classificar--------------------------------------------------------------
# chat_obj <- chat_groq(
#   model = "llama-3.3-70b-versatile",
#   echo  = "none"
# )
# 
# resultado <- ac_qual_code(
#   corpus           = corpus,
#   codebook         = codebook_enriquecido,
#   chat             = chat_obj,
#   confidence       = "total",
#   k_consistency    = 3L,
#   reasoning        = TRUE,
#   reasoning_length = "short"
# )

## ----validacao----------------------------------------------------------------
# # Exportar amostra priorizando casos incertos
# amostra <- ac_qual_sample(
#   resultado,
#   n        = 5,
#   strategy = "uncertainty"
# )
# 
# ac_qual_export_for_review(
#   sample = amostra,
#   path   = "revisao_proposicoes.xlsx",
#   corpus = corpus
# )
# 
# # Após preenchimento da coluna categoria_humano no Excel:
# humano <- ac_qual_import_human(
#   path    = "revisao_proposicoes.xlsx",
#   cat_col = "categoria_humano",
#   id_col  = "doc_id"
# )
# 
# concordancia <- ac_qual_irr(
#   gold      = humano,
#   predicted = resultado,
#   method    = "all",
#   id_col    = "doc_id",
#   cat_col   = "categoria"
# )
# 
# print(concordancia)

## ----analise------------------------------------------------------------------
# # Distribuição de categorias por tema
# resultado |>
#   count(tema, categoria) |>
#   arrange(tema, desc(n))
# 
# # Verificar se ementas são sempre neutro_tecnico
# resultado |>
#   filter(tipo == "ementa") |>
#   select(doc_id, tema, categoria, confidence_score)

## ----exportar-----------------------------------------------------------------
# # CSV para análise posterior
# ac_export(resultado, formato = "csv", arquivo = "proposicoes_codificadas.csv")
# 
# # Excel para compartilhamento
# ac_export(resultado, formato = "xlsx", arquivo = "proposicoes_codificadas.xlsx")
# 
# # LaTeX para inclusão em artigo
# ac_export(resultado, formato = "latex", arquivo = "proposicoes_codificadas.tex")

