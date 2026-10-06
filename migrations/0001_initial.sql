PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS users (
  id TEXT PRIMARY KEY,
  email TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  password_hash TEXT NOT NULL,
  password_salt TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'user' CHECK (role IN ('user','agency','admin')),
  created_at TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS sessions (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  token_hash TEXT NOT NULL UNIQUE,
  created_at TEXT NOT NULL,
  expires_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_sessions_token ON sessions(token_hash);
CREATE INDEX IF NOT EXISTS idx_sessions_user ON sessions(user_id);

CREATE TABLE IF NOT EXISTS agency_memberships (
  user_id TEXT NOT NULL,
  department_key TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('member','manager')),
  created_at TEXT NOT NULL,
  PRIMARY KEY (user_id, department_key),
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS reports (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  category TEXT NOT NULL,
  description TEXT NOT NULL,
  location TEXT NOT NULL,
  department_key TEXT NOT NULL,
  visibility TEXT NOT NULL DEFAULT 'public' CHECK (visibility IN ('public','private')),
  latitude REAL,
  longitude REAL,
  accuracy INTEGER,
  status TEXT NOT NULL DEFAULT 'Submitted' CHECK (status IN ('Submitted','Received','Investigating','Closed')),
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_reports_user ON reports(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reports_public ON reports(visibility, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reports_department ON reports(department_key, created_at DESC);

CREATE TABLE IF NOT EXISTS report_updates (
  id TEXT PRIMARY KEY,
  report_id TEXT NOT NULL,
  user_id TEXT,
  text TEXT NOT NULL,
  official INTEGER NOT NULL DEFAULT 0,
  status TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS idx_updates_report ON report_updates(report_id, created_at ASC);

CREATE TABLE IF NOT EXISTS media (
  id TEXT PRIMARY KEY,
  report_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL,
  size INTEGER NOT NULL,
  r2_key TEXT NOT NULL UNIQUE,
  created_at TEXT NOT NULL,
  FOREIGN KEY (report_id) REFERENCES reports(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_media_report ON media(report_id, created_at ASC);
