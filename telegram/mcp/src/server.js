const { McpServer } = require("@modelcontextprotocol/sdk/server/mcp.js");
const { StdioServerTransport } = require("@modelcontextprotocol/sdk/server/stdio.js");
const { z } = require("zod");

const TOKEN = process.env.TELEGRAM_BOT_TOKEN;

if (!TOKEN) {
  console.error("[mcp] TELEGRAM_BOT_TOKEN is not set");
  process.exit(1);
}

const API_BASE = `https://api.telegram.org/bot${TOKEN}`;

// Send a message via Bot API
async function sendMessage(chatId, text) {
  const res = await fetch(`${API_BASE}/sendMessage`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      chat_id: chatId,
      text: text,
      parse_mode: "Markdown",
    }),
  });

  const data = await res.json();
  if (!data.ok) {
    throw new Error(`Telegram API error: ${data.description}`);
  }
  return data.result;
}

// Create MCP server
const server = new McpServer({
  name: "telegram-reply",
  version: "1.0.0",
});

server.tool(
  "telegram_reply",
  "Send a reply message to a Telegram chat. Use this to respond to messages from the Telegram bridge.",
  {
    chat_id: z.string().describe("The Telegram chat ID to send the message to"),
    text: z.string().describe("The message text to send (Markdown supported)"),
  },
  async ({ chat_id, text }) => {
    try {
      const result = await sendMessage(chat_id, text);
      return {
        content: [
          {
            type: "text",
            text: `Message sent (id: ${result.message_id})`,
          },
        ],
      };
    } catch (err) {
      return {
        content: [
          {
            type: "text",
            text: `Failed to send: ${err.message}`,
          },
        ],
        isError: true,
      };
    }
  }
);

// Start stdio transport
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
  console.error("[mcp] Telegram MCP server running on stdio");
}

main().catch((err) => {
  console.error("[mcp] Fatal:", err);
  process.exit(1);
});
