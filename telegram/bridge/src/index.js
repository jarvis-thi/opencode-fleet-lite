const { Bot } = require("grammy");
const { execSync } = require("child_process");
const fs = require("fs");
const path = require("path");
const os = require("os");

// Load env from fleet root
const fleetDir = process.env.FLEET_DIR || path.resolve(__dirname, "../../..");
const envPath = path.join(fleetDir, ".env");
if (fs.existsSync(envPath)) {
  require("dotenv").config({ path: envPath });
}

const TOKEN = process.env.TELEGRAM_BOT_TOKEN;
const ALLOWED_CHAT_ID = process.env.TELEGRAM_CHAT_ID;

if (!TOKEN) {
  console.error("[bridge] TELEGRAM_BOT_TOKEN is not set");
  process.exit(1);
}

const bot = new Bot(TOKEN);

// Check if a tmux session exists
function sessionExists(name) {
  try {
    execSync(`tmux has-session -t ${name} 2>/dev/null`);
    return true;
  } catch {
    return false;
  }
}

// Send text into a tmux session via temp file + load-buffer
function sendToTmux(session, text) {
  const tmpFile = path.join(os.tmpdir(), `fleet-tg-${Date.now()}.txt`);
  try {
    fs.writeFileSync(tmpFile, text);
    execSync(`tmux load-buffer "${tmpFile}"`);
    execSync(`tmux paste-buffer -t ${session}`);
    execSync(`tmux send-keys -t ${session} Enter`);
  } finally {
    try {
      fs.unlinkSync(tmpFile);
    } catch {}
  }
}

// Authorize sender
function isAllowed(chatId) {
  if (!ALLOWED_CHAT_ID) return true; // No restriction if not set
  return String(chatId) === String(ALLOWED_CHAT_ID);
}

/** Session names from apex/comms/roster.sh (forge, prism, vikki, …) — no hardcoded fleet list */
function rosterAgentSessions() {
  const rosterPath = path.join(fleetDir, "apex/comms/roster.sh");
  if (!fs.existsSync(rosterPath)) return [];
  const content = fs.readFileSync(rosterPath, "utf8");
  const names = [];
  for (const line of content.split("\n")) {
    const t = line.trim();
    if (!t || t.startsWith("#")) continue;
    const m = t.match(/\[([a-zA-Z0-9_-]+)\]=/);
    if (m) names.push(m[1]);
  }
  return names;
}

/** Safe for XML-ish attribute */
function escapeAttr(s) {
  return String(s)
    .replace(/&/g, "&amp;")
    .replace(/"/g, "&quot;")
    .replace(/</g, "&lt;");
}

function displayName(from) {
  if (!from) return "user";
  const parts = [from.first_name, from.last_name].filter(Boolean);
  const full = parts.join(" ").trim();
  if (full) return full;
  if (from.username) return `@${from.username}`;
  return "user";
}

// /start command -- health check
bot.command("start", async (ctx) => {
  if (!isAllowed(ctx.chat.id)) return;

  const roster = rosterAgentSessions();
  const sessions = ["apex", ...roster];
  const lines = sessions.map((s) => {
    const up = sessionExists(s);
    return `  ${s}: ${up ? "UP" : "DOWN"}`;
  });

  await ctx.reply(`Fleet status:\n${lines.join("\n")}`);
});

// /stop command -- stop the fleet
bot.command("stop", async (ctx) => {
  if (!isAllowed(ctx.chat.id)) return;

  await ctx.reply("Stopping fleet...");
  try {
    execSync(`bash "${path.join(fleetDir, "stop.sh")}"`, { timeout: 15000 });
    await ctx.reply("Fleet stopped.");
  } catch (err) {
    await ctx.reply(`Stop failed: ${err.message}`);
  }
});

// Regular messages -- forward to Apex
bot.on("message:text", async (ctx) => {
  if (!isAllowed(ctx.chat.id)) return;

  const chatId = ctx.chat.id;
  const messageId = ctx.message.message_id;
  const from = ctx.from;
  const user = escapeAttr(displayName(from));
  const ts = new Date(ctx.message.date * 1000).toISOString();
  const text = ctx.message.text;

  const bridgeHint = [
    `[Bridge] Telegram → Apex only (replies do not go out from this pane).`,
    `To send a Telegram reply, from the apex directory run:`,
    `  bash scripts/telegram-reply.sh "your message"`,
    `(${fleetDir}/.env supplies the bot token and chat id. Optional: wire telegram/mcp for a telegram_reply tool.)`,
  ].join("\n");

  // Wrap in tagged format
  const wrapped = [
    `<telegram chat_id="${chatId}" message_id="${messageId}" user="${user}" ts="${ts}">`,
    text,
    `</telegram>`,
    ``,
    bridgeHint,
  ].join("\n");

  if (!sessionExists("apex")) {
    await ctx.reply("Apex is not running. Start the fleet first.");
    return;
  }

  // Show typing indicator
  await ctx.replyWithChatAction("typing");

  // Send to Apex
  try {
    sendToTmux("apex", wrapped);
  } catch (err) {
    await ctx.reply(`Failed to relay message: ${err.message}`);
  }
});

// Start polling
console.log("[bridge] Telegram bridge starting...");
console.log(`[bridge] Chat ID filter: ${ALLOWED_CHAT_ID || "none (all allowed)"}`);

bot.start({
  onStart: () => console.log("[bridge] Polling for messages..."),
});

// Graceful shutdown
function shutdown() {
  console.log("[bridge] Shutting down...");
  bot.stop();
  process.exit(0);
}

process.on("SIGINT", shutdown);
process.on("SIGTERM", shutdown);
