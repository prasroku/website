# Projects

Things I've built outside work, mostly to understand how something actually works instead of just reading about it.

---

## Hybrid RAG with LangGraph

<p align="left">
  <a href="https://github.com/prasroku/hybrid-rag-langgraph">
    <img src="https://img.shields.io/badge/View_on_GitHub-181717?style=for-the-badge&logo=github&logoColor=white" alt="View on GitHub">
  </a>
</p>

A retrieval-augmented generation pipeline built from scratch. It reads a PDF, stores embedded chunks in Supabase, and answers questions using hybrid search, a LangGraph retry loop and Gemini.

**Stack:** Python, Supabase (pgvector), sentence-transformers, LangGraph, Gemini, Streamlit

```mermaid
flowchart LR
    PDF[PDF] --> Chunk[Chunk + embed]
    Chunk --> DB[(Supabase<br/>pgvector)]
    Q[Question] --> Search[Hybrid search<br/>+ rerank]
    DB --> Search
    Search -- low confidence --> Rewrite[Gemini rewrites<br/>question]
    Rewrite --> Search
    Search --> Answer[Gemini answer]
```

---

## Outbound Traffic Monitor

<p align="left">
  <a href="https://github.com/prasroku/outbound-traffic-monitor">
    <img src="https://img.shields.io/badge/View_on_GitHub-181717?style=for-the-badge&logo=github&logoColor=white" alt="View on GitHub">
  </a>
</p>

A Python tool that logs which processes on my machine connect to which countries, then flags unusual traffic with an anomaly model and per-country baselines.

**Stack:** Python, psutil, scikit-learn, SQLite, matplotlib

```mermaid
flowchart LR
    Conn[Open connections<br/>psutil] --> Geo[Country lookup<br/>ipinfo.io]
    Geo --> DB[(SQLite)]
    DB --> Model[IsolationForest<br/>anomaly score]
    DB --> Baseline[Per-country<br/>baseline check]
    Model --> Alert[Alerts]
    Baseline --> Alert
```
