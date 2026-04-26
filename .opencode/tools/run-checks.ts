// OpenCode MAX — .opencode/tools/run-checks.ts
// https://github.com/ab1nv/opencode-max
// Author: Abhinav Singh (ab1nv) · v0.1.0
// Tool: run verification commands (tests, lint, typecheck) in sequence with a compact report.

import { tool } from "@opencode-ai/plugin"

async function runCommand(command: string) {
  const proc = Bun.spawn(["bash", "-lc", command], {
    stdout: "pipe",
    stderr: "pipe",
  })

  const [exitCode, stdout, stderr] = await Promise.all([
    proc.exited,
    new Response(proc.stdout).text(),
    new Response(proc.stderr).text(),
  ])

  return {
    command,
    exitCode,
    stdout: stdout.trim(),
    stderr: stderr.trim(),
  }
}

function trimOutput(text: string, maxLines: number): string {
  if (!text) {
    return ""
  }

  const lines = text.split("\n")
  if (lines.length <= maxLines) {
    return text
  }

  return lines.slice(-maxLines).join("\n")
}

export default tool({
  description:
    "Run verification commands (tests, lint, typecheck) in order and return a compact report",
  args: {
    commands: tool.schema
      .array(tool.schema.string())
      .min(1)
      .describe("Commands to execute in sequence"),
    stopOnFailure: tool.schema
      .boolean()
      .optional()
      .describe("Stop execution after the first failing command (default: true)"),
    maxOutputLines: tool.schema
      .number()
      .int()
      .positive()
      .max(500)
      .optional()
      .describe("Maximum output lines to return per command (default: 40)"),
  },
  async execute(args) {
    const stopOnFailure = args.stopOnFailure ?? true
    const maxOutputLines = args.maxOutputLines ?? 40
    const results: Array<{
      command: string
      exitCode: number
      stdout: string
      stderr: string
    }> = []

    for (const command of args.commands) {
      const result = await runCommand(command)
      results.push(result)

      if (stopOnFailure && result.exitCode !== 0) {
        break
      }
    }

    const lines: string[] = []
    lines.push("## Verification Report")

    for (const result of results) {
      const status = result.exitCode === 0 ? "PASS" : "FAIL"
      lines.push("")
      lines.push(`### ${status} (${result.exitCode})`)
      lines.push(`Command: ${result.command}`)

      const combinedOutput = [result.stdout, result.stderr]
        .filter(Boolean)
        .join("\n")
      const trimmed = trimOutput(combinedOutput, maxOutputLines)

      if (trimmed) {
        lines.push("Output:")
        lines.push("```text")
        lines.push(trimmed)
        lines.push("```")
      }
    }

    const failed = results.filter((r) => r.exitCode !== 0).length
    lines.push("")
    lines.push(
      `Summary: ${results.length - failed} passed, ${failed} failed, ${results.length} total.`
    )

    return lines.join("\n")
  },
})
