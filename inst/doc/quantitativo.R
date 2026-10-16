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
  "O governo anunciou nova politica fiscal para reduzir o deficit público.",
  "A oposicao critica o aumento dos gastos e da divida pública no orcamento.",
  "Parlamentares debatem a reforma tributária e o imposto de renda das familias.",
  "O presidente vetou o projeto que ampliava beneficios sociais para os pobres.",
  "O Senado aprovou o marco legal para investimentos em infraestrutura logistica.",
  "Deputados votam pela reducao da carga tributária para pequenas empresas.",
  "A politica monetária do Banco Central eleva a taxa de juros para conter inflacao.",
  "A inflacao acima da meta preocupa economistas e o mercado financeiro.",
  "O relator defendeu emendas ao texto do orcamento com foco em saude e educacao.",
  "A comissao aprovou o projeto que amplia beneficios sociais no interior.",
  "O ministro afirmou que a reforma tributária simplifica o sistema para empresas.",
  "Lideres da oposicao pediram vistas ao projeto na comissao de constituicao."
)

meta <- data.frame(
  text = textos,
  tema = c("fiscal","fiscal","tributário","social","infraestrutura",
           "tributário","monetário","monetário","fiscal","social",
           "tributário","fiscal"),
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

## ----frequência---------------------------------------------------------------
contagem <- ac_count(corpus_limpo)
contagem

## ----top-termos, fig.height=6-------------------------------------------------
top <- ac_top_terms(contagem, n = 12)
ac_plot_top_terms(top) +
  ggplot2::labs(
    title    = "Termos mais frequentes no corpus",
    subtitle = "Discursos legislativos - 12 documentos fabricados",
    caption  = "acR - vignette Análise Quantitativa"
  )

## ----wordcloud, fig.height=6--------------------------------------------------
ac_wordcloud(contagem, max_words = 40, title = "Panorama do corpus")

## ----wordcloud-comp, fig.height=6---------------------------------------------
# Nosso corpus tem 5 temas distintos: todos entram na comparativa.
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
freq_2grupos  <- freq_tema[freq_tema$tema %in% c("fiscal", "tributário"), ]

kn <- ac_keyness(freq_2grupos, group = "tema", target = "fiscal")

ac_plot_keyness(kn, n = 10) +
  ggplot2::labs(
    title    = "Palavras distintivas: 'fiscal' vs. 'tributário'",
    subtitle = "Barras positivas = distintivas do tema 'fiscal'"
  )

## ----coocorrência, fig.height=7-----------------------------------------------
cooc <- ac_cooccurrence(corpus_limpo, window = 5L, min_count = 2L)

if (requireNamespace("ggraph", quietly = TRUE)) {
  ac_plot_cooccurrence(cooc, top_n = 25) +
    ggplot2::labs(
      title    = "Rede de coocorrência (janela = 5, freq mínima = 2)",
      subtitle = "Arestas conectam termos que co-ocorrem no mesmo contexto"
    )
}

## ----coocorrência-pmi, fig.height=7-------------------------------------------
if (requireNamespace("ggraph", quietly = TRUE)) {
  ac_plot_cooccurrence(cooc, top_n = 25, weight = "pmi") +
    ggplot2::labs(
      title    = "Rede de coocorrência ponderada por PMI",
      subtitle = "Destaca pares associados além do esperado por acaso"
    )
}

## ----coocorrência-circle, fig.height=7----------------------------------------
if (requireNamespace("ggraph", quietly = TRUE)) {
  ac_plot_cooccurrence(cooc, top_n = 25, layout = "circle") +
    ggplot2::labs(
      title    = "Rede de coocorrência: layout circular",
      subtitle = "Todas as palavras num anel; arestas mostram o grafo cru"
    )
}

## ----coocorrência-heatmap, fig.height=6---------------------------------------
top_tokens <- ac_top_terms(ac_count(corpus_limpo), n = 12)$token
cooc_mat   <- cooc[cooc$word1 %in% top_tokens & cooc$word2 %in% top_tokens, ]

ggplot2::ggplot(cooc_mat,
                ggplot2::aes(word1, word2, fill = cooc)) +
  ggplot2::geom_tile(color = "white") +
  ggplot2::scale_fill_gradient(low = "#F1F5F9", high = ac_palette(1)) +
  ggplot2::labs(
    title    = "Matriz de coocorrência (top 12 termos)",
    subtitle = "Alternativa ao grafo quando a rede fica densa",
    x = NULL, y = NULL, fill = "cooc."
  ) +
  theme_ac() +
  ggplot2::theme(
    axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
  )

## ----readability-setup--------------------------------------------------------
avaliacoes <- data.frame(
  id = paste0("rev", 1:4),
  texto = c(
    "Este produto é incrível. Funciona perfeitamente bem e chegou rápido.",
    "O manual técnico especifica que a calibração requer ajuste periódico do sensor piezoelétrico conforme a norma vigente, o que demanda qualificação especializada do operador responsável pela manutenção preventiva do equipamento.",
    "Bom. Chegou. Funciona. Recomendo.",
    "A experiência de uso revelou inconsistências na usabilidade da interface, comprometendo a jornada do consumidor e gerando fricção considerável ao longo do processo de integração do dispositivo ao ecossistema existente."
  ),
  stringsAsFactors = FALSE
)
corpus_aval <- ac_corpus(avaliacoes, text = texto, docid = id)

## ----readability--------------------------------------------------------------
ac_readability(corpus_aval)

## ----lexical-diversity--------------------------------------------------------
ac_lexical_diversity(corpus_aval)

## ----lexical-diversity-plot, fig.height=4-------------------------------------
ac_plot_lexical_diversity(ac_lexical_diversity(corpus_aval), group_col = "doc_id",
                           metric = "mtld", type = "bar")

## ----readability-scatter, fig.height=4.5--------------------------------------
leg  <- ac_readability(corpus_aval)
div  <- ac_lexical_diversity(corpus_aval)
cruz <- merge(leg, div, by = "doc_id")

ggplot2::ggplot(cruz, ggplot2::aes(x = flesch, y = mtld, label = doc_id)) +
  ggplot2::geom_point(color = ac_palette(1), size = 3) +
  ggplot2::geom_text(vjust = -1, size = 3.2) +
  ggplot2::labs(
    title = "Legibilidade vs. diversidade lexical",
    subtitle = "Cada ponto é um documento; eixos sem relação necessária entre si",
    x = "Flesch (legibilidade)", y = "MTLD (diversidade lexical)"
  ) +
  theme_ac()

## ----zipf---------------------------------------------------------------------
freq_aval <- ac_count(corpus_aval, drop_punct = TRUE)
ac_plot_zipf(freq_aval)

## ----zipf-grupo---------------------------------------------------------------
grupos_zipf <- data.frame(
  id = paste0("doc", 1:12),
  texto = c(
    "O presidente anunciou um pacote de medidas economicas para estimular o crescimento.",
    "A prefeitura inaugurou um novo parque publico no bairro central da cidade.",
    "Cientistas descobriram uma nova especie de inseto na floresta amazonica.",
    "O time local venceu a partida decisiva do campeonato estadual de futebol.",
    "A exposicao de arte contemporanea atraiu milhares de visitantes no fim de semana.",
    "Pesquisadores desenvolveram uma vacina experimental contra uma doenca rara.",
    "O sistema deve ser configurado conforme o manual tecnico do equipamento.",
    "Configure o equipamento tecnico seguindo o manual de configuracao tecnica.",
    "O manual tecnico especifica a configuracao tecnica do sistema tecnico.",
    "Consulte o manual tecnico para configurar corretamente o sistema tecnico.",
    "A configuracao tecnica do equipamento segue o manual tecnico padrao.",
    "O equipamento tecnico requer configuracao conforme manual tecnico oficial."
  ),
  fonte = rep(c("noticias", "manual_tecnico"), each = 6),
  stringsAsFactors = FALSE
)
corpus_zipf_grupo <- ac_corpus(grupos_zipf, text = texto, docid = id, meta = fonte)
freq_zipf_grupo   <- ac_count(corpus_zipf_grupo, by = "fonte", drop_punct = TRUE)
ac_plot_zipf(freq_zipf_grupo, by = "fonte")

## ----kwic-corpus--------------------------------------------------------------
atendimento <- data.frame(
  id = paste0("call", 1:3),
  texto = c(
    "o cliente reclamou que o produto chegou com defeito de fabrica",
    "outro cliente relatou defeito no produto depois de uma semana de uso",
    "o produto sem defeito foi elogiado pelo cliente no final da ligacao"
  ),
  stringsAsFactors = FALSE
)
corpus_atend <- ac_corpus(atendimento, text = texto, docid = id)

## ----kwic---------------------------------------------------------------------
ac_kwic(corpus_atend, pattern = "defeito", window = 4)

## ----collocations-------------------------------------------------------------
ac_collocations(corpus_atend, n = 2, measure = "pmi", min_count = 1)

## ----collocations-plot, fig.height=4------------------------------------------
colocacoes <- ac_collocations(corpus_atend, n = 2, measure = "pmi", min_count = 1)
colocacoes_top <- utils::head(colocacoes, 8)

ggplot2::ggplot(colocacoes_top,
                ggplot2::aes(x = association, y = reorder(collocation, association))) +
  ggplot2::geom_col(fill = ac_palette(1)) +
  ggplot2::labs(
    title = "Colocações mais associadas (PMI)",
    x = "PMI", y = NULL
  ) +
  theme_ac()

## ----temporal-----------------------------------------------------------------
noticias <- data.frame(
  data       = as.Date("2024-01-01") + c(0, 10, 20, 35, 50, 65, 80, 95),
  sentimento = c(0.2, 0.1, -0.1, -0.4, -0.3, 0.0, 0.3, 0.5)
)
serie <- ac_temporal(noticias, date_col = "data", value_col = "sentimento",
                      unit = "month", stat = "mean")
serie

## ----plot-temporal------------------------------------------------------------
ac_plot_temporal(serie, ylab = "Sentimento médio")

## ----temporal-bar, fig.height=4-----------------------------------------------
ggplot2::ggplot(serie, ggplot2::aes(x = period, y = value)) +
  ggplot2::geom_col(fill = ac_palette(1)) +
  ggplot2::geom_hline(yintercept = 0, color = "grey40", linetype = "dashed") +
  ggplot2::labs(
    title = "Sentimento médio por mês",
    subtitle = "Barras tornam mais fácil comparar período a período",
    x = NULL, y = "Sentimento médio"
  ) +
  theme_ac()

## ----wordscores---------------------------------------------------------------
resenhas <- data.frame(
  id = paste0("r", 1:9),
  texto = c(
    # Referencia: nota 5
    "produto excelente, superou todas as expectativas, qualidade impecavel, recomendo muito a todos",
    "amei esse produto, chegou rapido, funciona perfeitamente, melhor compra que fiz esse ano",
    # Referencia: nota 4
    "muito bom, chegou no prazo e funciona bem, pequenos detalhes a melhorar mas vale a pena",
    # Referencia: nota 3
    "produto regular, cumpre o basico, nada de especial mas tambem nao decepciona",
    # Referencia: nota 2
    "nao funcionou muito bem, qualidade deixou a desejar, esperava mais pelo preco pago",
    # Referencia: nota 1
    "pessimo, quebrado na caixa, com defeito serio, decepcao total com essa compra",
    "produto horrivel, nao recomendo a ninguem, dinheiro jogado fora, qualidade pessima",
    # "Virgens": sem nota, a estimar so pelo vocabulario
    "simplesmente perfeito, superou expectativas, qualidade impecavel, recomendo de olhos fechados",
    "produto ok, atende o basico, nem bom nem ruim, mediano"
  ),
  stringsAsFactors = FALSE
)
corpus_resenhas <- ac_corpus(resenhas, text = texto, docid = id)

# r1, r2, r3, r4, r5, r6, r7 tem nota conhecida; r8 e r9 sao "virgens"
notas <- c(r1 = 5, r2 = 5, r3 = 4, r4 = 3, r5 = 2, r6 = 1, r7 = 1)
wordscores <- ac_wordscores(corpus_resenhas, notas, rescale = "mv")
wordscores

## ----wordscores-plot, fig.height=4--------------------------------------------
ac_plot_wordscores(wordscores)

## ----wordscores-bar, fig.height=4---------------------------------------------
wordscores$doc_id <- factor(wordscores$doc_id, levels = wordscores$doc_id[order(wordscores$score)])

ggplot2::ggplot(wordscores, ggplot2::aes(x = score, y = doc_id, fill = is_reference)) +
  ggplot2::geom_col() +
  ggplot2::scale_fill_manual(
    values = c(`TRUE` = "#1b7837", `FALSE` = "#737373"),
    labels = c(`TRUE` = "Referência", `FALSE` = "Estimado"),
    name = NULL
  ) +
  ggplot2::labs(title = "Escores Wordscores (barras)", x = "Escore", y = NULL) +
  theme_ac()

## ----dictionary-corpus--------------------------------------------------------
atendimento2 <- data.frame(
  id = paste0("call", 1:6),
  texto = c(
    "a entrega atrasou muito e o rastreio nao atualizava ha dias",
    "o produto chegou com defeito e veio quebrado da fabrica",
    "entrega rapida produto excelente superou expectativas",
    "o rastreio mostrava entrega prevista mas o pacote nunca chegou",
    "produto perfeito funciona bem sem nenhum problema",
    "entrega no prazo mas o produto veio com defeito de fabricacao"
  ),
  stringsAsFactors = FALSE
)
corpus_atend2 <- ac_corpus(atendimento2, text = texto, docid = id)

## ----dictionary---------------------------------------------------------------
dict <- ac_build_dictionary(
  entrega = c("entrega", "atrasou", "atrasada", "rapida", "rastreio", "prazo"),
  produto = c("defeito", "quebrado", "perfeito", "excelente")
)
resultado_dict <- ac_dictionary(corpus_atend2, dict)
resultado_dict

## ----dictionary-plot, fig.height=4--------------------------------------------
long_dict <- data.frame(
  doc_id   = rep(resultado_dict$doc_id, 2),
  categoria = rep(c("entrega", "produto"), each = nrow(resultado_dict)),
  prop      = c(resultado_dict$entrega_prop, resultado_dict$produto_prop)
)

ggplot2::ggplot(long_dict, ggplot2::aes(x = doc_id, y = prop, fill = categoria)) +
  ggplot2::geom_col(position = "stack") +
  ggplot2::scale_fill_manual(values = ac_palette(2)) +
  ggplot2::labs(
    title = "Composição temática por documento",
    x = NULL, y = "Proporção de tokens", fill = "Categoria"
  ) +
  theme_ac()

## ----emotion------------------------------------------------------------------
lexico_emocao <- data.frame(
  termo  = c("excelente", "perfeito", "defeito", "quebrado", "atrasou"),
  emocao = c("alegria",   "alegria",  "tristeza", "raiva",   "raiva"),
  stringsAsFactors = FALSE
)
ac_emotion(corpus_atend2, lexicon = lexico_emocao)

## ----dictionary-validate------------------------------------------------------
humano <- tibble::tibble(
  doc_id    = resultado_dict$doc_id,
  categoria = c("produto", "produto", "entrega|produto", "entrega", "produto", "entrega|produto")
)
ac_dictionary_validate(resultado_dict, humano)

## ----ca-----------------------------------------------------------------------
categorias <- data.frame(
  id = paste0("d", 1:9),
  texto = c(
    "entrega atrasou rastreio sumiu pedido",
    "pedido atrasou entrega demora atendimento",
    "rastreio parado entrega demora pedido",
    "produto quebrado defeito troca",
    "produto defeito demora troca atendimento",
    "veio quebrado produto troca defeito",
    "atendimento educado resolveu rapido",
    "suporte resolveu troca rapido atendimento",
    "atendimento demora mas resolveu educado"
  ),
  categoria = rep(c("entrega", "produto", "atendimento"), each = 3),
  stringsAsFactors = FALSE
)
corpus_cat <- ac_corpus(categorias, text = texto, docid = id, meta = categoria)
ca <- ac_ca(corpus_cat, by = "categoria", min_count = 2)
ac_plot_ca(ca)

## ----ca-groups-only, fig.height=4---------------------------------------------
ggplot2::ggplot(ca$row_coords, ggplot2::aes(x = dim1, y = dim2, label = unit)) +
  ggplot2::geom_hline(yintercept = 0, color = "grey80") +
  ggplot2::geom_vline(xintercept = 0, color = "grey80") +
  ggplot2::geom_point(color = ac_palette(1), size = 4) +
  ggplot2::geom_text(vjust = -1, fontface = "bold") +
  ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = 0.25)) +
  ggplot2::scale_y_continuous(expand = ggplot2::expansion(mult = 0.25)) +
  ggplot2::labs(
    title = "Análise de correspondência: só grupos",
    subtitle = "Distância entre pontos reflete dissimilaridade de vocabulário"
  ) +
  theme_ac()

