"""Never imported. The runner loads every step module in this directory
except this one, and every runner test would fail if it did not."""

raise RuntimeError("the BDD runner imported a steps __init__.py")
