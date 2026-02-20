#!/usr/bin/env node
// Claude Code Statusline - Vibes Edition
// Shows: model | repo@branch | relative dir | current task | context brain meter

const fs = require('fs');
const path = require('path');
const os = require('os');
const { execSync } = require('child_process');

// Git helper - runs git commands silently, returns empty string on failure
function git(cmd, cwd) {
  try {
    return execSync(`git ${cmd}`, { cwd, encoding: 'utf8', stdio: ['pipe', 'pipe', 'ignore'] }).trim();
  } catch { return ''; }
}

// Pick a silly model name + extract version from model id
function sillyModel(name, id) {
  // Extract version from id like "claude-opus-4-6" -> "4.6"
  const version = (id || '').match(/(\d+)-(\d+)(?:-\d+)?$/);
  const ver = version ? ` ${version[1]}.${version[2]}` : '';

  const m = (name || '').toLowerCase();
  if (m.includes('opus'))   return `🎹 Opus${ver}`;
  if (m.includes('sonnet')) return `📝 Sonnet${ver}`;
  if (m.includes('haiku'))  return `🍃 Haiku${ver}`;
  return `🤖 ${name || 'Claude'}${ver}`;
}

// Pick a silly branch vibe
function branchFlair(branch) {
  if (!branch) return '';
  if (branch === 'main' || branch === 'master') return '👑';
  if (branch.startsWith('feat'))    return '✨';
  if (branch.startsWith('fix'))     return '🔧';
  if (branch.startsWith('hotfix'))  return '🔥';
  if (branch.startsWith('chore'))   return '🧹';
  if (branch.startsWith('refactor'))return '♻️';
  if (branch.startsWith('release')) return '🚀';
  if (branch.startsWith('wip'))     return '🚧';
  return '🌿';
}

// Context brain - how full is the noggin?
function contextBrain(remaining) {
  if (remaining == null) return '';

  const rem = Math.round(remaining);
  const rawUsed = Math.max(0, Math.min(100, 100 - rem));
  // Scale: 80% real usage = 100% displayed (Claude Code enforces 80% limit)
  const used = Math.min(100, Math.round((rawUsed / 80) * 100));

  const filled = Math.floor(used / 10);
  const bar = '█'.repeat(filled) + '░'.repeat(10 - filled);

  // Different brain states
  if (used < 30) {
    return ` \x1b[32m🧠 ${bar} ${used}% fresh\x1b[0m`;
  } else if (used < 63) {
    return ` \x1b[32m🧠 ${bar} ${used}% vibing\x1b[0m`;
  } else if (used < 81) {
    return ` \x1b[33m🤔 ${bar} ${used}% thinking hard\x1b[0m`;
  } else if (used < 95) {
    return ` \x1b[38;5;208m🥵 ${bar} ${used}% sweating\x1b[0m`;
  } else {
    return ` \x1b[5;31m💀 ${bar} ${used}% brain full\x1b[0m`;
  }
}

// Read JSON from stdin
let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  try {
    const data = JSON.parse(input);
    const model = data.model?.display_name || 'Claude';
    const modelId = data.model?.id || '';
    const dir = data.workspace?.current_dir || process.cwd();
    const session = data.session_id || '';
    const remaining = data.context_window?.remaining_percentage;
    const homeDir = os.homedir();

    // Model display
    const modelStr = `\x1b[1;35m${sillyModel(model, modelId)}\x1b[0m`;

    // Git info
    const repoRoot = git('rev-parse --show-toplevel', dir);
    const branch = git('branch --show-current', dir);
    let repoStr = '';
    let dirStr = '';

    if (repoRoot) {
      const repoName = path.basename(repoRoot);
      const flair = branchFlair(branch);

      repoStr = ` \x1b[36m${repoName}\x1b[0m\x1b[2m@\x1b[0m${flair}\x1b[33m${branch}\x1b[0m`;

      // Relative directory from repo root
      let relPath = dir.substring(repoRoot.length).replace(/^\//, '');
      if (relPath) {
        dirStr = ` \x1b[2m📂 ./${relPath}\x1b[0m`;
      }
    } else {
      // Not in a git repo - just show directory name
      dirStr = ` \x1b[2m📂 ${path.basename(dir)}\x1b[0m`;
    }

    // Context brain meter
    const ctx = contextBrain(remaining);

    // Current task from todos
    let task = '';
    const todosDir = path.join(homeDir, '.claude', 'todos');
    if (session && fs.existsSync(todosDir)) {
      try {
        const files = fs.readdirSync(todosDir)
          .filter(f => f.startsWith(session) && f.includes('-agent-') && f.endsWith('.json'))
          .map(f => ({ name: f, mtime: fs.statSync(path.join(todosDir, f)).mtime }))
          .sort((a, b) => b.mtime - a.mtime);

        if (files.length > 0) {
          try {
            const todos = JSON.parse(fs.readFileSync(path.join(todosDir, files[0].name), 'utf8'));
            const inProgress = todos.find(t => t.status === 'in_progress');
            if (inProgress) task = inProgress.activeForm || '';
          } catch (e) {}
        }
      } catch (e) {}
    }

    // GSD update available?
    let gsdUpdate = '';
    const cacheFile = path.join(homeDir, '.claude', 'cache', 'gsd-update-check.json');
    if (fs.existsSync(cacheFile)) {
      try {
        const cache = JSON.parse(fs.readFileSync(cacheFile, 'utf8'));
        if (cache.update_available) {
          gsdUpdate = '\x1b[33m⬆ /gsd:update\x1b[0m │ ';
        }
      } catch (e) {}
    }

    // Assemble the masterpiece
    const parts = [gsdUpdate, modelStr];

    if (repoStr) parts.push('│' + repoStr);
    if (dirStr) parts.push(dirStr);
    if (task) parts.push(`│ \x1b[1;37m⚡ ${task}\x1b[0m`);
    if (ctx) parts.push('│' + ctx);

    process.stdout.write(parts.join(' '));
  } catch (e) {
    // Silent fail - don't break statusline on parse errors
  }
});
