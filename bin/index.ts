#!/usr/bin/env node
import { parseArgs } from "node:util"
import { test } from "~/bin/commands/test"
import { author, name, version } from "~/package.json"

const helpMessage = `Version:
  ${name}@${version}

Usage:
  $ ${name} <command> [options]

Commands:
  test           Test command

Options:
  -v, --version  Display version
  -h, --help     Display help for <command>

Author:
  ${author.name} <${author.email}> (${author.url})`

const main = async () => {
  try {
    const args = process.argv.slice(2)

    // Parse arguments first
    const { positionals, values } = parseArgs({
      allowPositionals: true,
      options: {
        help: { type: "boolean", short: "h" },
        version: { type: "boolean", short: "v" },
      },
      args,
    })

    // Handle global flags (help/version) when no command is provided
    if (!positionals.length) {
      if (values.version) {
        console.log(`${name}@${version}`)
        process.exit(0)
      }
      if (values.help || !args.length) {
        console.log(helpMessage)
        process.exit(0)
      }
    }

    // Handle commands
    const command = positionals[0]
    const commandArgs = positionals.slice(1)

    switch (command) {
      case "test":
        test(commandArgs)
        break
      default:
        console.error(`unknown command: ${command || "(none)"}`)
        console.error(`\n${helpMessage}\n`)
        process.exit(1)
    }
  } catch (err: any) {
    console.error(helpMessage)
    if (err.message) {
      console.error(`\n${err.message}\n`)
    }
    process.exit(1)
  }
}

main()
