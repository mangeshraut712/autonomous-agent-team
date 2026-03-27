# 🧠 Always-On Memory Agent — Intel Brief

_Google Cloud Tech announced Gemini 3.1 Flash-Lite (2026-03-05)_
_Gemini Live Agent Challenge — 12 days remaining_
_Prize: $25,000 Grand Prize + Google Cloud Next 2026 tickets_

---

## 🎯 The Strategy: Build Around the Official Example, Win With Depth

Google's team released an open-source "Always-On Memory Agent" built on Google ADK + Gemini 3.1 Flash-Lite as the **example project** in their announcement tweet. This is a massive signal — judges will be evaluating submissions in this exact space. Our advantage: **build a production-grade, more complete version** that shows exactly what the article describes, plus extra.

---

## 📋 Contest Requirements (Confirmed from Devpost)

**Eligible Category:** Live Agents 🗣️ OR Creative Storyteller ✍️  
**Mandatory tech:** Gemini Live API OR Google ADK — **hosted on Google Cloud**  
**Video required:** Demo of multimodal/agentic features working in real-time (no mockups)  
**Bonus points:**

- Published blog/podcast/video with `#GeminiLiveAgentChallenge`
- Automated Cloud Deployment (IaC scripts / Terraform in public repo)
- Google Developer Group membership link

---

## 🏗️ What We're Building: Always-On Memory Agent (AOMA)

**Core concept from Google's announcement:**

> "Most AI agents suffer from amnesia. This project solves that by giving agents a persistent, evolving memory that runs 24/7 as a lightweight background process."

**Our differentiation angle:**

- Use Gemini 3.1 Flash-Lite for background processing (cheap + fast — exactly what Google said it's for)
- Add a **real-time Gemini Live API voice interface** to query memory (satisfies Live Agents category AND their demo requirement)
- 27+ file types supported via multimodal
- Deploy to Cloud Run with Terraform (bonus points for IaC)

---

## 🔑 Gemini 3.1 Flash-Lite Model Details

- **API ID:** `gemini-3.1-flash-lite-preview` (via Google AI Studio or Vertex AI)
- **Benchmarks:** 1432 Elo, 86.9% GPQA Diamond, 76.8% MMMU Pro
- **Best for:** High-volume, cost-sensitive workflows, background processing, RAG ranking
- **Adaptive thinking:** Adjustable reasoning budget via Vertex AI (light/medium/deep)
- **Multimodal:** 27+ file types (text, images, audio, video)
- **Key selling point:** Ultra-low latency + near-zero cost for 24/7 operation

**API key is already in** `~/.openclaw/.env` as `GEMINI_API_KEY=AIzaSy...`

---

## 🏛️ Architecture — Three Agents

```
┌─────────────────────────────────────────────────────────┐
│                    Always-On Memory Agent                │
├──────────────────┬──────────────────┬────────────────────┤
│   IngestAgent    │ ConsolidateAgent  │   QueryAgent       │
│                  │                  │                    │
│ Watches /input   │ Runs on timer    │ Gemini Live API    │
│ folder (5-10s)   │ (every 15 min)   │ voice interface    │
│                  │                  │                    │
│ Extracts from    │ Finds cross-     │ Voice → search     │
│ 27+ file types   │ cutting insights │ → cited answer     │
│                  │ between memories │ → voice response   │
└──────────────────┴──────────────────┴────────────────────┘
         ↓                  ↓                  ↓
    ChromaDB / SQLite    ChromaDB           Streaming TTS
    (local vector store) consolidation      (real-time)
```

---

## 📁 Project Location

```
/Users/mangeshraut/Downloads/Gemini Live Agent Challenge/
```

_(Check if folder exists and what's there. Agents: DO NOT assume empty.)_

---

## 🛠️ Tech Stack

| Component         | Technology             | Why                              |
| ----------------- | ---------------------- | -------------------------------- |
| Background agents | Google ADK (Python)    | Required by contest              |
| Memory model      | Gemini 3.1 Flash-Lite  | Cheap, fast — 24/7 viable        |
| Voice interface   | Gemini Live API        | Satisfies "Live Agents" category |
| Vector store      | ChromaDB (local) + GCS | Persistent across restarts       |
| File watching     | `watchdog` (Python)    | Real-time file ingestion         |
| Deployment        | Cloud Run + Terraform  | Bonus points for IaC             |
| Frontend          | HTML/JS WebSocket UI   | Demo-able, real-time             |

---

## 📦 Dependencies (Python)

```bash
pip install google-adk google-genai chromadb watchdog fastapi uvicorn
pip install python-multipart pillow pypdf2 python-docx openpyxl
pip install google-cloud-storage google-cloud-run
```

---

## 🗓️ 12-Day Execution Plan

| Day           | Agent        | Task                                                            |
| ------------- | ------------ | --------------------------------------------------------------- |
| Day 1 (today) | Ross         | Set up project structure, FastAPI + ADK scaffold                |
| Day 1         | Dwight       | Research ADK best practices, ChromaDB setup guide               |
| Day 2         | Ross         | Implement IngestAgent (watchdog + Gemini multimodal extraction) |
| Day 3         | Ross         | Implement ConsolidateAgent (timer + cross-cutting insights)     |
| Day 4         | Ross         | Implement QueryAgent using Gemini Live API for voice            |
| Day 5         | Ross         | Build WebSocket frontend for real-time demo                     |
| Day 6         | Ross         | ChromaDB vector storage + persistence                           |
| Day 7         | Ross         | Cloud Run deployment + Dockerfile                               |
| Day 8         | Ross         | Terraform IaC scripts for automated deployment                  |
| Day 8         | Pam          | Write blog post draft for bonus points                          |
| Day 9         | Ross         | Integration testing + demo prep                                 |
| Day 10        | Kelly+Rachel | Social posts with #GeminiLiveAgentChallenge                     |
| Day 11        | Pam          | Final README, Devpost narrative                                 |
| Day 12        | ALL          | Record demo video + submit                                      |

---

## 🎬 Demo Script (for video)

1. **Open terminal** — show `aoma serve` starting the agent system
2. **Drop a PDF** into `/input` folder — show console: "Ingested in 4.2s, extracted 847 entities"
3. **Drop an image** — show multimodal extraction working
4. **Open voice interface** — speak: "What do you know about machine learning from my documents?"
5. **Show real-time streaming response** with source citations
6. **Show ConsolidateAgent** running: "Found 3 cross-cutting insights between files"
7. **Show Cloud Run dashboard** — 24/7 uptime, near-zero cost

---

## 🏆 Winning Angle for Judges

1. **Uses official example** — validates Google's own reference architecture
2. **Adds what Google didn't** — full voice interface using Gemini Live API
3. **Production-ready** — Terraform, Cloud Run, proper error handling
4. **Cost proof** — attach actual Cloud Run billing: 24/7 = ~$3-5/month
5. **27 file types** — show images, audio, PDF, DOCX all working
6. **Open source** — clear code, great README, reproducible

---

## 📋 Current Project Status

Check: `/Users/mangeshraut/Downloads/Gemini Live Agent Challenge/`

- If project exists from previous sessions → Ross should review and continue
- If empty → Ross should scaffold from scratch using the architecture above

**Priority next action for Monica:** Dispatch Ross immediately to check the existing project state and begin/continue building.
