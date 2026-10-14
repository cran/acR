## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>",
  eval     = FALSE
)

## -----------------------------------------------------------------------------
# library(acR)
# 
# # LM Studio, servindo um modelo na porta padrao (1234)
# chat_local <- ac_chat_local(model = "qwen2.5-14b-instruct")
# 
# # llama.cpp (llama-server), porta customizada
# chat_llama <- ac_chat_local(
#   model    = "modelo-local",
#   base_url = "http://localhost:8080/v1"
# )

## -----------------------------------------------------------------------------
# coded <- ac_qual_code(corpus, codebook, chat = chat_local)

## -----------------------------------------------------------------------------
# tamanhos <- ac_estimate_tokens(corpus$text)
# summary(tamanhos)
# 
# # Quantos documentos provavelmente excedem uma janela de 8k tokens?
# sum(tamanhos > 8000)

## -----------------------------------------------------------------------------
# chat_factory <- function(temperature, system_prompt) {
#   ac_chat_local(model = "qwen2.5-14b-instruct",
#                temperature = temperature, system_prompt = system_prompt)
# }
# 
# razao <- ac_calibrate_tokens(chat_factory, sample(corpus$text, 10))
# tamanhos_calibrados <- ac_estimate_tokens(corpus$text, chars_per_token = razao)

## -----------------------------------------------------------------------------
# coded <- ac_qual_code(
#   corpus, codebook,
#   chat           = chat_local,
#   checkpoint_dir = "checkpoints/rodada_2026_10",
#   max_retries    = 2L,
#   live           = "progress"
# )

## -----------------------------------------------------------------------------
# table(coded$status)
# # ok                 -- classificado normalmente
# # resposta_invalida  -- o servidor respondeu, mas nao em JSON valido
# # estouro_contexto   -- documento excedeu a janela de contexto
# # timeout            -- servidor nao respondeu a tempo
# # erro_servidor      -- outro erro de rede/servidor

## -----------------------------------------------------------------------------
# rel <- ac_qual_reliability(
#   llm    = coded,
#   human  = humano_df,
#   by_variable    = TRUE,
#   exclude_status = c("estouro_contexto", "timeout", "erro_servidor")
# )
# 
# attr(rel, "by_variable")

## -----------------------------------------------------------------------------
# amostra <- ac_qual_sample(
#   coded, n = 100,
#   strategy = "proportional", strata = "especie_normativa"
# )

## -----------------------------------------------------------------------------
# info <- attr(coded, "run_info")
# info$model
# info$params_efetivos$temperature   # a temperatura que o PROVEDOR confirmou
# info$temperatura_pedida            # a temperatura que voce PEDIU
# info$codebook_hash

