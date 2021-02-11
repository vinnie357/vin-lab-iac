#!/bin/bash
echo "---installing pre-commit---"
# pre commit
pip install pre-commit
pre-commit install
echo "---pre-commit done---"