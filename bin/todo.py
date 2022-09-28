#!/usr/bin/env python3
import dataclasses as dc
import pathlib
import click
from typing import Set

@dc.dataclass
class TodoItem:
    text: str
    tags: Set[str]

@click.group()
@click.option("-f", "todo_file", default='TODO.txt')
@click.pass_context
def main(ctx: click.Context, todo_file: str) -> None:
    todos = ctx.ensure_object(list)
    with open(todo_file, 'r') as stream:
        for line in stream:
            if not line.strip():
                continue
            tags = set()
            tokens = line.strip().split()
            for idx, token in enumerate(reversed(tokens)):
                if token.startswith("#"):
                    tags.add(token[1:])
                elif idx:
                    tokens = tokens[:-idx]
                    break
                else:
                    break

            todos.append(TodoItem(text=" ".join(tokens), tags=tags))

@main.command(name='t')
@click.pass_context
def by_tags(ctx: click.Context):
    todos = ctx.find_object(list)
    tags = {}
    for todo in todos:
        if not todo.tags:
            tags.setdefault('<NO TAG>', []).append(todo)
        for tag in todo.tags:
            tags.setdefault(tag, []).append(todo)

    for tag in sorted(tags):
        print(f"#{tag}")
        for todo in tags[tag]:
            print(todo.text)
        print("")

if __name__ == "__main__":
    main()
