# Projects

Things I've built outside work, mostly to understand how something actually works instead of just reading about it.

---

## Hybrid RAG with LangGraph

<p align="left">
  <a href="https://github.com/prasroku/hybrid-rag-langgraph">
    <img src="https://img.shields.io/badge/View_on_GitHub-181717?style=for-the-badge&logo=github&logoColor=white" alt="View on GitHub">
  </a>
</p>

A retrieval-augmented generation pipeline I built from scratch to learn what's really going on under the hood. It reads a PDF, splits it into chunks, embeds them, stores everything in Supabase, and answers questions about the document through a small Streamlit app. Fittingly, the PDF I tested it on is a book about building LLMs.

**Stack:** Python, Supabase (Postgres + pgvector + Storage), sentence-transformers, LangGraph, Gemini, Streamlit

### How it works

1. **Ingest:** extract text from the PDF, chunk it, and embed each chunk locally with `all-MiniLM-L6-v2` (384 dimensions).
2. **Hybrid search:** run a keyword search (Postgres full-text) and a semantic search (pgvector cosine) side by side, then merge the two ranked lists with Reciprocal Rank Fusion.
3. **Rerank (optional):** pull 20 candidates and rescore each question/chunk pair with a cross-encoder, keeping the best 5.
4. **Self-correcting retrieval:** a LangGraph state machine checks the results. If nothing comes back with enough confidence, Gemini rewrites the question and it tries once more.
5. **Answer:** Gemini answers the question using only the retrieved chunks.

### Things I learned along the way

- **Embeddings are bad at exact tokens.** Acronyms, error codes and version numbers often get missed by semantic search, which is why the keyword half of hybrid search matters.
- **"RAG" and "retrieval-augmented generation" are not the same to an embedding model.** They scored a similarity of just 0.13, while a genuine paraphrase scored 0.95. My semantic cache uses a 0.92 threshold, so it catches rewording but won't treat an acronym as its spelled-out form.
- **Local embeddings beat a free API tier.** I started with Gemini's embedding API, hit the rate limit within a handful of requests, and switched to sentence-transformers. No key and no waiting.
- **Tell the model to stick to the context.** Without that instruction it mixes in what it already "knows", which quietly defeats the point of RAG.
- **Searching is free, answering costs money.** Retrieval runs locally, and generating an answer is a separate button so only that step spends an API call.
