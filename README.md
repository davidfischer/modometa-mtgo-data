# modometa-mtgo-data

This repository contains tournament and league decklist data scraped from [MTGO](https://www.mtgo.com) (Magic: The Gathering Online) for [MODOMeta](https://modometa.com/), an MTGO metagame analyzer.

Data is automatically scraped, normalized, and updated every ~8 hours using [`modometa-scraper`](https://github.com/davidfischer/modometa-scraper).

If you're looking to explore MTGO tournament data, the database for MODOMeta is public. If you know SQL, you can download and explore the database yourself at https://data.modometa.com/modometa.db

---

## Directory Structure

Data files are organized by tournament date in the following hierarchy:

```text
Tournaments/
└── MTGO/
    └── <YYYY>/
        └── <MM>/
            └── <DD>/
                ├── modern-challenge-32-<timestamp>.json
                ├── standard-league-<timestamp>.json
                └── ...
```

- `<YYYY>`: 4-digit year (e.g. `2026`)
- `<MM>`: 2-digit month (e.g. `09`)
- `<DD>`: 2-digit day (e.g. `10`)
- Filenames correspond to sanitized event slugs from mtgo.com.

---

## JSON Format

Each tournament JSON file follows the format established by [`MTG_decklistcache`](https://github.com/fbettega/MTG_decklistcache) with normalized Scryfall card names:

```json
{
  "Tournament": {
    "Date": "2026-09-10",
    "Name": "Modern Challenge 64",
    "Uri": "https://www.mtgo.com/decklist/modern-challenge-64-2026-09-1012854060",
    "Formats": "Modern",
    "PlayerCount": 93
  },
  "Decks": [
    {
      "Date": "2026-09-10T13:00:00+00:00",
      "Player": "Alice",
      "Result": "1st Place",
      "AnchorUri": "https://www.mtgo.com/decklist/modern-challenge-64-2026-09-1012854060#deck_Alice",
      "Mainboard": [
        { "Count": 4, "CardName": "Lightning Bolt" }
      ],
      "Sideboard": [
        { "Count": 2, "CardName": "Pyroblast" }
      ]
    }
  ],
  "Rounds": [
    {
      "RoundName": "Finals",
      "Matches": [
        { "Player1": "Alice", "Player2": "Bob", "Result": "2-1-0" }
      ]
    }
  ],
  "Standings": [
    {
      "Rank": 1,
      "Player": "Alice",
      "Points": 18,
      "Wins": 6,
      "Losses": 0,
      "Draws": 0,
      "OMWP": 0.67,
      "GWP": 0.75,
      "OGWP": 0.61
    }
  ]
}
```

---

## Automated Updates

A GitHub Action (`.github/workflows/update-data.yml`) runs on a recurring schedule:
- **Frequency:** Every 8 hours, at 15 minutes past the hour (`15 */8 * * *` UTC: 00:15, 08:15, 16:15 UTC). GitHub cron task run times are approximate.
- **Operation:** Runs `modometa-scraper` with `--auto-resume` and a 2-day lookback window.
- **Commits:** If new tournaments or updated 5-0 league decklists are found, changes are committed and pushed automatically.
- **Manual Trigger:** The workflow can also be triggered manually via GitHub's `workflow_dispatch`.
- **Required Secret:** Requires a `USER_AGENT` repository secret to be configured in GitHub (**Settings > Secrets and variables > Actions**). If this secret is not present, the workflow job is skipped automatically to prevent unconfigured forks or clones from duplicating the scraping.

---

## Running the Scraper Locally

You can manually update or backfill data using the bundled [`scripts/update.sh`](scripts/update.sh) script.

### Prerequisites

- [uv](https://docs.astral.sh/uv/) installed.

### Usage

```bash
# Auto-resume from latest cached date (default):
./scripts/update.sh

# Sync a specific date range:
./scripts/update.sh --start-date 2026-09-01 --end-date 2026-09-11

# Force re-download of tournaments in the window:
./scripts/update.sh --force

# Exclude league events:
./scripts/update.sh --skip-leagues

# View all options:
./scripts/update.sh --help
```

The script automatically detects if a local checkout of `../modometa-scraper` exists (useful for development); if not, it runs the scraper directly from [GitHub](https://github.com/davidfischer/modometa-scraper.git).

---

## License

This repository is licensed under the [MIT License](LICENSE.md).

The license applies to the repository only, not the tournament data. The tournament metadata and decklist data themselves may be simple facts ineligible for copyright depending on your jurisdiction.
