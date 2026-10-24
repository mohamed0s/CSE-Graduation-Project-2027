# Pre-launch checklist

- [ ] Replace the test ChatGPT server: HTTPS (or private network/VPN), authentication, confirmed owner, uptime/rate-limit info, no message logging or a known retention policy.
- [ ] Gemini (if still used): paid account instead of the free tier (20 requests/day).
- [ ] Privacy decision with the team: what text may be sent to Jev, Gemini/ChatGPT; retention policies; redaction of phone numbers and emails before external calls.
- [ ] Jev: JEV_MODEL pinned to a versioned ID (never jev-latest); re-run scripts/run_classifier_eval.py before any model or criteria change.
- [ ] Service-to-service auth (X-API-Key), service not exposed directly to the internet, secrets from a secret manager, not .env files on the server.
- [ ] Reliability: circuit breaker per provider, per-user rate limit, overall request time budget (REQUEST_TIMEOUT_SECONDS), health checks.
- [ ] Logging and metrics: structured logs, no full user text, fallback/error/latency counters.
- [ ] CI: tests on every push; Jev eval on changes to criteria, lists or thresholds.
- [ ] RAG: replace NullAppHelpHandler with the real handler (contract from the RAG owner).
- [ ] Closed lists from the backend (categories, areas) so Jev can extract them; update the eval set to list keys.
- [ ] Decide with the team who executes the search (this service via POST /search, or the backend from next_action); write docs/response_contract.md.
- [ ] Extend eval/eval_set.csv with real (anonymized) user messages, especially low-confidence ones.
