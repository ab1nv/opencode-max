import { tool } from "@opencode-ai/plugin"
import path from "path"
import { promises as fs } from "node:fs"

const HANDOFF_FILE = ".opencode/state/session-handoff.md"

function buildSection(title: string, value?: string): string {
  if (!value || !value.trim()) {
    return ""
  }

  return `\n### ${title}\n${value.trim()}\n`
}

export const save = tool({
  description:
    "Save a structured handoff note that can be loaded in future sessions",
  args: {
    summary: tool.schema
      .string()
      .describe("Short summary of what was completed in this session"),
    decisions: tool.schema
      .string()
      .optional()
      .describe("Optional key decisions made"),
    nextSteps: tool.schema
      .string()
      .optional()
      .describe("Optional next steps for the next session"),
  },
  async execute(args, context) {
    const filePath = path.join(context.worktree, HANDOFF_FILE)
    const dirPath = path.dirname(filePath)

    await fs.mkdir(dirPath, { recursive: true })

    const timestamp = new Date().toISOString()
    const entry = [
      `## Handoff ${timestamp}`,
      "",
      `### Summary`,
      args.summary.trim(),
      buildSection("Decisions", args.decisions).trimEnd(),
      buildSection("Next Steps", args.nextSteps).trimEnd(),
      "",
    ]
      .filter(Boolean)
      .join("\n")

    await fs.appendFile(filePath, `${entry}\n\n`, "utf8")
    return `Saved handoff to ${HANDOFF_FILE}`
  },
})

export const load = tool({
  description:
    "Load recent handoff notes to restore context from previous sessions",
  args: {
    maxLines: tool.schema
      .number()
      .int()
      .positive()
      .max(2000)
      .optional()
      .describe("How many lines from the end of the handoff file to return"),
  },
  async execute(args, context) {
    const filePath = path.join(context.worktree, HANDOFF_FILE)

    try {
      const content = await fs.readFile(filePath, "utf8")
      const maxLines = args.maxLines ?? 300
      const lines = content.split("\n")
      return lines.slice(-maxLines).join("\n")
    } catch (error) {
      return `No handoff file found at ${HANDOFF_FILE}.`
    }
  },
})
