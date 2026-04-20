# Server Package Workflow

## Purpose
Use one stable zip file for server transfer instead of copying the whole PBIP folder every time.

## Standard Output
- Folder: `/Users/baqer/Dropbox/Work/Microsoft Platform/Power BI/Reports/Finance/Exports/Server Packages`
- Package file: `Financial Report - ready.zip`

## Routine
1. Finish report edits in the PBIP project.
2. Run the packaging script:
   `./scripts/package-report.sh`
3. Copy `Exports/Server Packages/Financial Report - ready.zip` to the server.
4. Unzip it on the server.
5. Run or review the report there.

## Why This Is Better
- One predictable file name every time
- Faster copy and paste than moving the whole PBIP folder
- Keeps transfer artifacts out of the main project root
- Avoids committing large export zips into Git history

## Notes
- The zip contains the full `Financial Report` folder, not only the `.pbip` file.
- The export folder is part of the project structure, but the generated zip files are ignored by Git.
