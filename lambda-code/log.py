import sys
import traceback
from os import getpid
from os.path import relpath
from typing import Any


def fmt(fs):
    return (
        './'
        + relpath(fs.filename)
        + f':{fs.lineno}'
        + f' in {fs.name}\n'
        + f'    {fs.line}\n'
    )


def format_exception(e):
    return ''.join(traceback.format_exception(type(e), e, e.__traceback__))


def format_exception_only(e):
    return ''.join(traceback.format_exception_only(type(e), e)).strip()


def format_trace(e: Exception) -> str:
    trace: Any = traceback.extract_tb(e.__traceback__)
    fmt_trace: str = ''.join(fmt(f) for f in trace)
    stack: Any = traceback.extract_stack()

    for i, f in enumerate(reversed(stack)):
        if (f.filename, f.name) == (trace[0].filename, trace[0].name):
            stack = stack[:-i]
            break  # skip the log.py part of stack
    for i, f in enumerate(reversed(stack)):
        if 'site-packages' in f.filename:
            stack = stack[-i:]
            break  # skip the flask part of stack
    fmt_stack = ''.join(fmt(f) for f in stack)

    a: str = (
        fmt_stack
        + '--- printed exception w/ trace ---\n'
        + fmt_trace
        + format_exception_only(e)
    )

    pid = getpid()
    return f'[{pid}] {a}'
