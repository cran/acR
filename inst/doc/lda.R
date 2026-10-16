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
has_topicmodels <- requireNamespace("topicmodels", quietly = TRUE)

## ----aviso-topicmodels, echo=FALSE, results="asis", eval=!has_topicmodels-----
# cat(
#   "> **Nota:** o pacote `topicmodels` não está instalado neste ambiente.",
#   "Os trechos a seguir que dependem dele foram omitidos; instale com",
#   "`install.packages(\"topicmodels\")` para reproduzir a vignette completa.",
#   sep = "\n"
# )

## ----corpus-------------------------------------------------------------------
textos <- c(
  # Tema 1: reforma tributária (8 documentos)
  "A reforma tributária simplifica o sistema de impostos e reduz a carga fiscal para empresas. O governo federal estima ganho de arrecadacao com menos sonegacao. Tributaristas pedem cautela na transicao entre os dois sistemas de impostos.",
  "O IVA dual substitui PIS, COFINS e ICMS no novo modelo de arrecadacao federal. Estados e municipios temem perder receita com o fim do ICMS. A transicao do imposto sobre consumo levara anos de ajuste fiscal.",
  "Deputados debatem aliquotas e excecoes tributárias para setores economicos. Cada setor pede tratamento diferenciado no novo imposto. O relator da reforma tributária resiste a ampliar as excecoes fiscais.",
  "A reforma tributária unifica impostos indiretos e simplifica obrigacoes das empresas. Contadores esperam menos custo para apurar tributos. A cobranca do imposto no destino muda a disputa fiscal entre estados.",
  "Empresários criticam a alta carga tributária brasileira sobre o consumo popular. O peso dos impostos indiretos recai sobre os mais pobres. A proposta de cashback devolve parte do tributo as familias de baixa renda.",
  "O relator propoe aliquotas diferenciadas para produtos essenciais no novo IVA. A cesta básica tera aliquota zero de imposto. Economistas calculam o efeito das excecoes sobre a aliquota padrao do tributo.",
  "A reforma tributária promete reduzir litigios fiscais e aumentar a arrecadacao. O contencioso tributário bilionario trava empresas e governo. Regras simples de imposto diminuem disputas judiciais sobre tributos.",
  "Congresso avalia impacto da reforma tributária sobre pequenas empresas e servicos. O Simples Nacional sera mantido com ajustes de aliquota. O setor de servicos teme aumento da carga de impostos sobre a folha.",
  # Tema 2: IA e proteção de dados (8 documentos)
  "O marco legal da inteligência artificial regulamenta o uso de algoritmos e dados. O projeto classifica sistemas de IA por nivel de risco. Algoritmos de alto risco exigirao avaliação de impacto antes do uso.",
  "Privacidade e seguranca de dados pessoais sao prioridades da nova lei de IA. Vazamentos de dados expõem milhoes de usuarios. A lei preve multas para empresas que tratarem dados pessoais sem consentimento.",
  "Algoritmos de inteligência artificial precisam de transparência e auditoria pública. Decisoes automatizadas devem ser explicaveis ao cidadao. Auditores independentes poderao inspecionar o codigo e os dados de treinamento.",
  "A LGPD estabelece regras para tratamento de dados pessoais por empresas e governo. O titular pode pedir acesso e exclusao dos seus dados. Empresas precisam nomear um encarregado de protecao de dados pessoais.",
  "Modelos de IA generativa levantam questoes eticas sobre direitos autorais e dados. Artistas reclamam do uso de obras no treinamento de algoritmos. O projeto de lei de IA preve remuneracao por dados protegidos.",
  "A ANPD fiscaliza o cumprimento das regras de protecao de dados no Brasil. A autoridade aplicou as primeiras sancoes por vazamento de dados pessoais. Plataformas digitais devem relatar incidentes de seguranca em prazo curto.",
  "Especialistas defendem regulamentacao de algoritmos preditivos usados por bancos. Sistemas de credito com inteligência artificial podem discriminar clientes. A transparência dos algoritmos permite contestar decisoes automatizadas.",
  "Inteligência artificial na saude requer protocolos de seguranca e privacidade. Algoritmos de diagnostico usam dados pessoais sensiveis de pacientes. Hospitais precisam de consentimento para treinar modelos de IA com esses dados.",
  # Tema 3: habitação e cidade (8 documentos)
  "O programa habitacional amplia recursos federais para moradia popular urbana. O governo pretende contratar milhares de novas unidades habitacionais. Prefeituras disputam terrenos urbanos bem localizados para as obras.",
  "O deficit habitacional afeta milhoes de familias de baixa renda nas cidades. O aluguel caro consome boa parte da renda das familias. Coabitacao e moradia precária concentram o deficit nas periferias urbanas.",
  "Urbanizacao de favelas e regularizacao fundiária avancam em municipios brasileiros. Moradores recebem titulos de propriedade e obras de saneamento. A urbanizacao das favelas leva infraestrutura e transporte aos bairros.",
  "Moradia digna e direito social garantido pela Constituicao federal de 1988. Movimentos de moradia ocupam imoveis vazios no centro das cidades. A funcao social da propriedade urbana orienta a politica habitacional.",
  "Assentamentos precários crescem nas periferias metropolitanas do pais. Familias constroem moradias em areas de risco sem infraestrutura urbana. Deslizamentos e enchentes atingem bairros sem planejamento habitacional.",
  "O programa Minha Casa Minha Vida entrega novas unidades habitacionais populares. Conjuntos habitacionais distantes do centro dificultam o acesso ao emprego. O programa retoma a faixa de moradia para familias de baixa renda.",
  "Especialistas em urbanismo debatem alugueis abusivos nas grandes cidades. O aluguel social atende familias despejadas de suas moradias. Imoveis ociosos no centro urbano poderiam virar habitacao popular.",
  "Politicas de habitacao popular incluem regularizacao fundiária e infraestrutura urbana. Saneamento, transporte e moradia precisam de planejamento conjunto nas cidades. Municipios recebem recursos para urbanizacao de bairros periféricos.",
  # Tema 4: educação (8 documentos)
  "A educacao básica recebe novos recursos do Fundeb ampliado pelo Congresso. Redes municipais de ensino ampliam vagas em creches e escolas. A complementacao federal prioriza municipios com menor investimento por aluno.",
  "Alfabetizacao na idade certa e meta central do novo Plano Nacional de Educacao. Avaliacoes mostram atraso na leitura dos alunos apos a pandemia. Escolas recebem material didático e formacao de professores alfabetizadores.",
  "Professores debatem remuneracao e condicoes de trabalho nas escolas públicas. Salas lotadas e falta de estrutura prejudicam o ensino. Sindicatos de professores cobram plano de carreira nas redes de educacao.",
  "O ensino médio integrado ao técnico expande vagas em institutos federais. Alunos combinam formacao geral e curso profissionalizante na escola. A reforma do ensino médio redefine o curriculo e a carga horaria.",
  "A avaliação Prova Brasil mede aprendizagem em português e matemática. Os resultados do Saeb orientam metas das escolas e redes de ensino. Professores usam os indicadores de aprendizagem para planejar as aulas.",
  "Politicas de permanência estudantil ampliam bolsas para universitários pobres. Alunos de baixa renda abandonam o ensino superior por falta de apoio. Universidades públicas ampliam moradia estudantil e restaurantes para estudantes.",
  "O piso salarial nacional dos professores e reajustado pelo governo federal. Municipios alegam falta de recursos para pagar o piso do magisterio. A valorizacao dos professores e meta do Plano Nacional de Educacao.",
  "A formacao continuada de professores e desafio permanente da educacao básica. Cursos de capacitacao ajudam docentes a usar tecnologia em sala de aula. Escolas com professores bem formados apresentam melhor aprendizagem dos alunos."
)

corpus <- ac_corpus(
  data.frame(
    text = textos,
    tema = rep(c("tributário","tecnologia","habitacao","educacao"), each = 8L),
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

## ----controle-lda-------------------------------------------------------------
controle <- list(alpha = 0.1, iter = 2000, burnin = 500)

## ----tune, eval=has_topicmodels-----------------------------------------------
tune <- ac_lda_tune(
  corpus_limpo,
  k_range = 2:8,
  seed    = 42L,
  method  = "Gibbs",
  control = controle
)
tune

## ----plot-tune, eval=has_topicmodels------------------------------------------
ac_plot_lda_tune(tune) +
  ggplot2::labs(
    title    = "Perplexidade fora da amostra por número de tópicos (K)",
    subtitle = "Validação cruzada em 5 partes; menor = melhor previsão de documentos novos",
    caption  = "acR - ac_lda_tune()"
  )

## ----lda, eval=has_topicmodels------------------------------------------------
modelo <- ac_lda(
  corpus_limpo,
  k       = 4L,
  seed    = 42L,
  method  = "Gibbs",
  control = controle
)
modelo

## ----beta, eval=has_topicmodels-----------------------------------------------
beta <- modelo$terms
head(beta, 10)

## ----plot-topics, eval=has_topicmodels, fig.height=7--------------------------
ac_plot_lda_topics(modelo, top_n = 10L) +
  ggplot2::labs(
    title    = "Top 10 termos por tópico (LDA, K=4)",
    subtitle = "Beta = probabilidade do termo dado o tópico"
  )

## ----plot-topics-alt, eval=has_topicmodels && requireNamespace("ggwordcloud", quietly = TRUE), fig.height=6----
topico_escolhido <- 1L

beta |>
  dplyr::filter(topic == topico_escolhido) |>
  dplyr::slice_max(beta, n = 25L, with_ties = FALSE) |>
  ggplot2::ggplot(ggplot2::aes(label = term, size = beta, color = beta)) +
  ggwordcloud::geom_text_wordcloud() +
  ggplot2::scale_size_area(max_size = 14) +
  ggplot2::scale_color_gradient(low = ac_palette(1), high = ac_palette(2)) +
  ggplot2::labs(
    title = paste("Nuvem de termos do tópico", topico_escolhido)
  ) +
  theme_ac()

## ----gamma, eval=has_topicmodels----------------------------------------------
gamma <- modelo$documents
head(gamma, 12)

## ----dominante, eval=has_topicmodels------------------------------------------
dominante <- gamma |>
  dplyr::group_by(doc_id) |>
  dplyr::slice_max(gamma, n = 1L, with_ties = FALSE) |>
  dplyr::ungroup() |>
  dplyr::rename(topico_dominante = topic, prob = gamma)

head(dominante, 12)

## ----validacao, eval=has_topicmodels------------------------------------------
# Recuperar o metadado 'tema' e cruzar com o tópico dominante
tema_real <- corpus[, c("doc_id", "tema")]
comparacao <- merge(dominante, tema_real, by = "doc_id")

# Tabela de contingência: tópico dominante x tema real
table(comparacao$topico_dominante, comparacao$tema)

## ----rotulos, eval=has_topicmodels--------------------------------------------
top_terms_por_topico <- beta |>
  dplyr::group_by(topic) |>
  dplyr::slice_max(beta, n = 7L, with_ties = FALSE) |>
  dplyr::summarise(
    top_termos = paste(term, collapse = ", "),
    .groups    = "drop"
  )

top_terms_por_topico

## ----gamma-heatmap, eval=has_topicmodels, fig.height=6------------------------
gamma_ord <- gamma |>
  # ordem numérica (doc_1 no topo), para os 4 temas aparecerem em blocos
  dplyr::mutate(doc_id = factor(doc_id, levels = paste0("doc_", 32:1)))

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
    subtitle = "Cores mais fortes = maior peso do tópico no documento",
    x        = "Tópico",
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

