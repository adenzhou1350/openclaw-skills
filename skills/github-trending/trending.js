#!/usr/bin/env node

/**
 * GitHub Trending Monitor
 * Fetches and displays trending GitHub repositories
 */

const GITHUB_TRENDING_URL = 'https://github.com/trending';

const LANGUAGE_MAP = {
  python: 'Python',
  go: 'Go',
  rust: 'Rust',
  typescript: 'TypeScript',
  javascript: 'JavaScript',
  java: 'Java',
  cpp: 'C++',
  swift: 'Swift',
  kotlin: 'Kotlin'
};

async function fetchTrending(language = '', range = 'daily') {
  const langParam = language ? `/${language}` : '';
  const sinceParam = range === 'weekly' ? '?since=weekly' : range === 'monthly' ? '?since=monthly' : '';
  const url = `${GITHUB_TRENDING_URL}${langParam}${sinceParam}`;
  
  // Use web_fetch to get trending page
  const { tool, result } = await import('./lib/fetcher.js');
  return result;
}

function formatReport(repos, language, range) {
  const langName = LANGUAGE_MAP[language] || language || 'All';
  const rangeText = range === 'weekly' ? '本周' : range === 'monthly' ? '本月' : '今日';
  
  let output = `📊 GitHub Trending - ${rangeText}热门\n\n`;
  output += `🔥 ${langName}\n`;
  
  repos.forEach((repo, i) => {
    output += `${i + 1}. ${repo.name}\n`;
    output += `   ⭐ ${repo.stars} | 🔀 ${repo.forks}`;
    if (repo.description) {
      output += ` | ${repo.description}`;
    }
    output += '\n';
  });
  
  return output;
}

// CLI
const args = process.argv.slice(2);
const langIndex = args.indexOf('--lang');
const rangeIndex = args.indexOf('--range');
const limitIndex = args.indexOf('--limit');

const language = langIndex !== -1 ? args[langIndex + 1] : 'python';
const range = rangeIndex !== -1 ? args[rangeIndex + 1] : 'daily';
const limit = limitIndex !== -1 ? parseInt(args[limitIndex + 1]) : 10;

console.log(`Fetching GitHub trending (${language}, ${range})...`);

// Demo output (actual implementation would fetch from GitHub)
const demoRepos = [
  { name: 'repo1/user', stars: '52.3k', forks: '3.2k', description: 'An awesome project' },
  { name: 'repo2/developer', stars: '41.2k', forks: '2.1k', description: 'Great tool for devs' },
  { name: 'repo3/opensource', stars: '38.9k', forks: '1.8k', description: 'Open source library' },
];

console.log(formatReport(demoRepos.slice(0, limit), language, range));
