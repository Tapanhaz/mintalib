# pylint: disable=import-error
# pyright: reportMissingImports=false


import os
import nox
import tempfile

ENVDIR = os.path.join(tempfile.gettempdir(), "nox")

nox.options.envdir = ENVDIR


@nox.session
def lint(session):
    session.install("flake8")
    session.run("flake8", "src")


@nox.session(python=["3.9", "3.10", "3.11"])
def tests(session: nox.Session):
    session.install(".", "pytest", "pytest-sugar")
    session.run("pytest")
