#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
export OPENBLAS_NUM_THREADS=1
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
mkdir -p logs
python experiments/check_bounds.py | tee logs/check_bounds.log
python experiments/check_auxiliary.py | tee logs/check_auxiliary.log
python experiments/sgd_cpu.py | tee logs/sgd_cpu.log
