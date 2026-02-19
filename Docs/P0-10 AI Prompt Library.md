# AI Prompt Library – Caddy Stats

Purpose:
Define stat-grounded AI prompt templates and execution constraints.

Core Rule:
AI never generates statistics independently.
AI only operates on injected structured data.

All prompts must:
1. Receive structured JSON input
2. Separate narrative from computed values
3. Log model version
4. Store output in ai_output_log

---

# 1️⃣ AI Architecture Overview

AI inputs originate from:

- projections table
- betting_edge_view
- rolling_form_view
- leaderboard_view
- model_accuracy_metrics (future)

Injection Path:

DB → stat_service.py → structured JSON → AI prompt → response → logged

---

# 2️⃣ Global Prompt Guardrails

All prompts must include:

SYSTEM INSTRUCTION:

"You are an analytics explanation engine.
Only reference the provided structured data.
Do not fabricate statistics.
If a value is missing, state that explicitly.
Separate narrative commentary from computed values."

---

# 3️⃣ Tournament Preview Generator

Use Case:
TournamentPreviewTemplate.tsx

Input JSON:

{
  "tournament_name": "...",
  "field_strength": ...,
  "top_projections": [...],
  "course_fit_metrics": [...],
  "betting_edges": [...]
}

Output Sections:

1. Field Overview
2. Top Projection Summary
3. Edge Highlights
4. Risk Notes
5. Confidence Summary

Prompt Template:

"Using the structured projection data below,
summarize the tournament outlook.

Data:
<JSON>

Rules:
- Reference exact win probabilities.
- Do not invent statistics.
- Explain top 3 edges.
- Identify highest confidence player.
- Provide structured markdown sections."

---

# 4️⃣ Betting Edge Explanation Prompt

Use Case:
BettingCardTemplate

Input JSON:

{
  "golfer": "...",
  "projected_probability": ...,
  "implied_probability": ...,
  "edge": ...,
  "confidence_score": ...
}

Prompt:

"Explain why the model identifies a positive edge.
Compare projected probability vs implied probability.
Explain what confidence_score indicates.
Do not fabricate past performance data."

Output:

- Edge Explanation
- Risk Factors
- Confidence Tier Description

---

# 5️⃣ Player Momentum Summary Prompt

Use Case:
PlayerDeepDiveTemplate

Input JSON:

{
  "rolling_form_avg_finish": ...,
  "strokes_gained_trend": ...,
  "last_5_results": [...]
}

Prompt:

"Summarize player momentum based on rolling form metrics.
Highlight trend direction.
Avoid qualitative speculation not supported by data."

Output:

- Trend Summary
- Statistical Strengths
- Consistency Assessment

---

# 6️⃣ SEO Headline Optimizer Prompt

Use Case:
Editor assist

Input:
{
  "title": "...",
  "primary_keyword": "...",
  "category": "..."
}

Prompt:

"Optimize the headline for search visibility.
Keep within 60 characters.
Maintain factual integrity.
Do not exaggerate performance claims."

Output:
- Optimized Title
- Character Count

---

# 7️⃣ Meta Description Generator Prompt

Input:
{
  "excerpt": "...",
  "primary_keyword": "..."
}

Prompt:

"Generate a 150-character meta description.
Include the primary keyword once.
Do not introduce new statistics."

Output:
- Meta Description
- Character Count

---

# 8️⃣ Newsletter Draft Generator Prompt

Use Case:
Weekly Recap

Input:
{
  "top_edges": [...],
  "best_projection_hit": ...,
  "roi_summary": ...
}

Prompt:

"Generate a weekly recap email.
Summarize results.
Reference ROI using exact values.
Avoid adding non-provided statistics."

Sections:
- Opening Summary
- Best Hit
- Lessons Learned
- Upcoming Event Teaser

---

# 9️⃣ Social Media Auto-Post Prompt

Use Case:
Auto tweet or post

Input:
{
  "top_edge": ...,
  "win_probability": ...,
  "confidence_score": ...
}

Prompt:

"Create a concise social post (under 280 chars).
Include win probability.
Include confidence tier.
No additional stats."

---

# 🔟 Model Accuracy Analysis Prompt (Premium)

Use Case:
Dashboard narrative

Input:
{
  "model_version": "...",
  "roi": ...,
  "average_projection_error": ...,
  "hit_rate": ...
}

Prompt:

"Analyze the performance of model_version.
Explain ROI.
Explain projection error trend.
Do not exaggerate performance."

Output:
- Performance Overview
- Risk Assessment
- Suggested Calibration

---

# 11️⃣ Logging & Transparency

Every AI output must log:

ai_output_id
model_version
input_reference_id
output_text
created_at

Table (future):
app_schema.ai_output_log

---

# 12️⃣ AI Failure Protocol

If AI response:

- References unknown statistic
- Adds non-provided metric
- Fails structured section requirement

System must:
- Reject output
- Log failure
- Retry with stricter instruction

---

# 13️⃣ Versioning Policy

Each AI call must include:

- model_version
- prompt_version
- schema_version

Stored with output.

---

# 14️⃣ Future Enhancements

- Confidence calibration narrative
- Dynamic FAQ generation
- Structured betting card PDF generation
- Projection anomaly detection explanation

---

# 15️⃣ Non-Negotiable Rule

AI is an explanation layer.

It is not the data source.

All numeric values must originate from PostgreSQL.
