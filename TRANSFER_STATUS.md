# Source transfer status

The verified ReportLocal source package was rebuilt from the existing project files on October 6, 2026.

The current GitHub connector can write UTF-8 text files but cannot consume the exported ZIP/file reference directly. Core deployment scaffolding has been committed, but the repository is **not yet a complete deployable copy** until the remaining large application files are transferred:

- `worker/index.js`
- `public/index.html`
- `public/app.js`
- `public/styles.css`
- `public/data/agencies.json`

The verified package contains all of these files and preserves all 10,171 department records.

Do not deploy this partial repository as-is. Use the verified ReportLocal source ZIP as the complete source package.
