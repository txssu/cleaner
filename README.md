# Cleaner

## Running

For docker compose example see [docker-compose.yml](docker-compose.yml)

| Variable         | Description                                | Default Value                                    |
| ---------------- | ------------------------------------------ | ------------------------------------------------ |
| `DATABASE_URL`   | URL for the PostgreSQL database connection | `ecto://postgres:postgres@database/cleaner_prod` |
| `TELEGRAM_TOKEN` | Token for the Telegram bot                 |                                                  |
| `OPENAI_URL`     | API endpoint for OpenAI services           | `https://api.openai.com/v1`                      |
| `OPENAI_KEY`     | API key for OpenAI authentication          |                                                  |

Ensure that all required variables are set before running the application.

