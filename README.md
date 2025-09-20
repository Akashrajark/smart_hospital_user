# Smart Hospital – AIML Chest X-ray Report System

Monorepo:
- `app/smart_hospital/` – Flutter app (Patient/Doctor/Admin)
- `ai/` – Training & inference (PyTorch)
- `supabase/` – Edge functions + config

## Do not commit large datasets or secrets
- Datasets under `ai/data/` are excluded by `.gitignore`
- Put API keys (OpenAI, Supabase service) in environment/secrets, not in source
git add .
