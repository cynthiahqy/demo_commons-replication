library(commons)

load("data/dta.RData")   # provides `dta`

hamel <- data_source(
  dta = dta,
  dictionary = "data-dict.yaml"
)

agent <- commons(
  client = ellmer::chat("anthropic/claude-sonnet-5"),
  data_sources = list(hamel = hamel),
  semantic_layer = semantic_layer("measures"),
  context_layer = context_layer("context/paper.md"),
  instructions = paste(
    "You are answering questions about a published paper's analysis.",
    "Prefer the trusted measures: they are the authors' own Table 1",
    "specifications. Never silently re-specify a model. If a question cannot be",
    "answered by a trusted measure, say so before computing anything yourself."
  )
)

commons_app(agent)
