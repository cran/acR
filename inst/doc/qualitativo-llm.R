## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  eval     = FALSE
)

## ----instalacao---------------------------------------------------------------
# # Instalar acR
# remotes::install_github("andersonheri/acR")
# 
# # Instalar ellmer
# install.packages("ellmer")
# 
# # Configurar chave de API (exemplo: Anthropic)
# Sys.setenv(ANTHROPIC_API_KEY = "sk-ant-...")

## ----codebook-manual, eval = TRUE---------------------------------------------
library(acR)

cb <- ac_qual_codebook(
  name         = "tom_discurso",
  instructions = "Classifique o tom geral do discurso parlamentar.",
  categories   = list(
    positivo = list(
      definition   = "Discurso com tom propositivo e colaborativo.",
      examples_pos = c("Proponho que trabalhemos juntos nesta agenda."),
      examples_neg = c("Este governo é um desastre completo."),
      weight       = 1
    ),
    negativo = list(
      definition   = "Discurso com tom crítico ou confrontacional.",
      examples_pos = c("Esta proposta vai arruinar o país."),
      examples_neg = c("Apresento esta emenda para melhorar o texto."),
      weight       = 1.5  # categoria mais difícil: peso maior no prompt
    ),
    neutro = list(
      definition   = "Discurso descritivo, sem posicionamento claro.",
      examples_pos = c("O projeto foi apresentado na sessão de hoje."),
      weight       = 1
    )
  ),
  multilabel = FALSE,   # cada doc recebe UMA categoria
  lang       = "pt"
)

print(cb)

## ----codebook-add-remove------------------------------------------------------
# # Adicionar categoria iterativamente
# cb <- ac_qual_codebook_add(cb,
#   tecnico = list(
#     definition   = "Discurso com linguagem técnica e referências normativas.",
#     examples_pos = c("Conforme o art. 37 da CF, a administração pública..."),
#     weight       = 1
#   )
# )
# 
# # Remover se necessário
# cb <- ac_qual_codebook_remove(cb, "tecnico")

## ----codebook-hybrid----------------------------------------------------------
# cb_hybrid <- ac_qual_codebook_hybrid(
#   codebook = cb,
#   model    = "anthropic/claude-sonnet-4-5",
#   journals = "default",  # periódicos de CP/CS brasileiros e internacionais
#   n_refs   = 3L,
#   lang     = "pt"
# )
# 
# # Ver definição enriquecida da categoria "negativo"
# cat(cb_hybrid$categories$negativo$definition)
# cat("\nReferências:\n")
# print(cb_hybrid$categories$negativo$references)

## ----codebook-literature------------------------------------------------------
# cb_lit <- ac_qual_codebook(
#   name         = "frames_politicos",
#   instructions = "Identifique o frame predominante no discurso.",
#   categories   = list(
#     conflito    = list(definition = "", concept = "conflict framing politics"),
#     consenso    = list(definition = "", concept = "consensus framing politics"),
#     moralidade  = list(definition = "", concept = "moral framing political discourse")
#   ),
#   mode  = "literature",
#   model = "anthropic/claude-sonnet-4-5",
#   lang  = "pt"
# )

## ----codebook-merge-----------------------------------------------------------
# cb_estilo <- ac_qual_codebook(
#   name         = "estilo_retórico",
#   instructions = "Classifique o estilo retórico dominante.",
#   categories   = list(
#     pathos  = list(definition = "Apelo emocional predominante."),
#     logos   = list(definition = "Apelo racional/argumentativo predominante."),
#     ethos   = list(definition = "Apelo à autoridade ou credibilidade do orador.")
#   )
# )
# 
# # Fundir: tom + estilo retórico em um único codebook
# cb_completo <- ac_qual_codebook_merge(
#   cb1          = cb_hybrid,
#   cb2          = cb_estilo,
#   name         = "discurso_parlamentar",
#   on_conflict  = "rename_second",
#   instructions = "Classifique o tom e o estilo retórico do discurso."
# )

## ----codebook-translate-------------------------------------------------------
# cb_en <- ac_qual_codebook_translate(
#   codebook           = cb_completo,
#   to                 = "en",
#   model              = "anthropic/claude-sonnet-4-5",
#   translate_examples = TRUE
# )

## ----codebook-history---------------------------------------------------------
# # Ver todas as modificações feitas no codebook
# ac_qual_codebook_history(cb_completo)

## ----as-prompt----------------------------------------------------------------
# # Gerar system prompt para uso direto com ellmer
# prompt <- as_prompt(
#   cb_completo,
#   reasoning        = TRUE,           # pede raciocinio estruturado
#   reasoning_length = "medium"        # "short" | "medium" | "detailed"
# )
# 
# # O prompt pode ser passado diretamente a um objeto Chat:
# # chat$set_system_prompt(prompt)

## ----corpus-------------------------------------------------------------------
# library(ellmer)
# 
# # Coletar e estruturar corpus
# discursos <- ac_fetch_camara(
#   id_deputado = 204379,
#   data_inicio = "2023-01-01",
#   data_fim    = "2023-06-30"
# )
# corpus <- ac_corpus(discursos, text_col = "transcricao", id_col = "id")

## ----classificar--------------------------------------------------------------
# # Classificar
# chat <- chat_anthropic(model = "claude-sonnet-4-5")
# 
# resultado <- ac_qual_code(
#   corpus        = corpus,
#   codebook      = cb_completo,
#   chat          = chat,
#   k_consistency = 3,               # self-consistency
#   live          = "terminal"       # ver a maquina classificando ao vivo
# )
# 
# head(resultado)

## ----live-terminal------------------------------------------------------------
# resultado <- ac_qual_code(
#   corpus, cb_completo, chat = chat,
#   live = "terminal"
# )
# # 42/120 | ============>              35% | ETA 2m10s
# #   doc_042 -> populista  (conf 1.00) "Apela ao povo contra elite..."

## ----save-load----------------------------------------------------------------
# # Salvar em YAML para replicabilidade
# ac_qual_save_codebook(cb_completo, path = "codebook_discurso.yaml")
# 
# # Carregar em outra sessão
# cb_recarregado <- ac_qual_load_codebook("codebook_discurso.yaml")

## ----validacao----------------------------------------------------------------
# # Amostrar 30 documentos priorizando os incertos
# amostra <- ac_qual_sample(resultado, n = 30, strategy = "uncertainty")
# ac_qual_export_for_review(amostra, path = "revisao.xlsx", corpus = corpus)
# 
# # Após preenchimento manual, calcular IRR
# revisado <- ac_qual_import_human("revisao_preenchida.xlsx")
# irr      <- ac_qual_reliability(llm = resultado, human = revisado)
# print(irr)

## ----report-minimal-----------------------------------------------------------
# # Apos ter o resultado da classificacao
# ac_qual_report(
#   coded     = resultado,
#   codebook  = cb_completo,
#   chat      = chat,                     # opcional: extrai provedor/modelo
#   author    = "Anderson Henrique",
#   path      = "relatorio_metodo.md"
# )

## ----report-full--------------------------------------------------------------
# irr <- ac_qual_reliability(llm = resultado, human = revisado)
# 
# ac_qual_report(
#   coded       = resultado,
#   codebook    = cb_completo,
#   reliability = irr,
#   chat        = chat,
#   title       = "Codificação do posicionamento parlamentar - 57ª legislatura",
#   author      = "Silva, A.; Souza, B.",
#   method      = "Discursos coletados via API da Câmara (jan-jun/2023, n=847).",
#   format      = "html",
#   path        = "metodo_apendice.html",
#   lang        = "pt"       # ou "en" para submissao internacional
# )

