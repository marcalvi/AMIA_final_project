#!/usr/bin/env bash
set -euo pipefail

# PIC defaults. Override any of these before running if your checkout/env differs.
PROJECT_ROOT="${PROJECT_ROOT:-/data/mhedas/common/jjuan/AMIA}"
DATA_ROOT="${DATA_ROOT:-/data/mhedas/common/challenge_dataset}"
CONDA_ENV="${CONDA_ENV:-AMIA_5090}"
NOTEBOOK="${NOTEBOOK:-AMIA_Albesa-Fite-Juan_part3.ipynb}"

export AMIA_PROJECT_DIR="${AMIA_PROJECT_DIR:-${PROJECT_ROOT}}"
export AMIA_BASE_DIR="${AMIA_BASE_DIR:-${DATA_ROOT}}"
export AMIA_WORKSPACE_DIR="${AMIA_WORKSPACE_DIR:-${PROJECT_ROOT}/challenge3_outputs_pic}"
export AMIA_RUN_TRAINING="${AMIA_RUN_TRAINING:-true}"
export AMIA_RUN_GRID_SEARCH="${AMIA_RUN_GRID_SEARCH:-true}"
export AMIA_SKIP_FINISHED_RUNS="${AMIA_SKIP_FINISHED_RUNS:-false}"
export AMIA_YOLO_GRID_EPOCHS="${AMIA_YOLO_GRID_EPOCHS:-80}"
export AMIA_RTDETR_GRID_EPOCHS="${AMIA_RTDETR_GRID_EPOCHS:-60}"
export AMIA_FASTER_RCNN_GRID_EPOCHS="${AMIA_FASTER_RCNN_GRID_EPOCHS:-20}"
export AMIA_ULTRALYTICS_PATIENCE="${AMIA_ULTRALYTICS_PATIENCE:-15}"
export AMIA_FASTER_RCNN_PATIENCE="${AMIA_FASTER_RCNN_PATIENCE:-5}"
export AMIA_EVAL_IOU_THRESHOLD="${AMIA_EVAL_IOU_THRESHOLD:-0.4}"
export AMIA_SUBMISSION_CONF="${AMIA_SUBMISSION_CONF:-0.25}"

echo "=== AMIA Challenge 3 PIC launcher ==="
date
echo "PROJECT_ROOT=${PROJECT_ROOT}"
echo "DATA_ROOT=${DATA_ROOT}"
echo "WORKSPACE=${AMIA_WORKSPACE_DIR}"
echo "CONDA_ENV=${CONDA_ENV}"
echo "NOTEBOOK=${NOTEBOOK}"

if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi || true
fi

if [[ -f "${HOME}/anaconda3/etc/profile.d/conda.sh" ]]; then
  source "${HOME}/anaconda3/etc/profile.d/conda.sh"
elif [[ -f "/opt/conda/etc/profile.d/conda.sh" ]]; then
  source "/opt/conda/etc/profile.d/conda.sh"
fi

if command -v conda >/dev/null 2>&1; then
  conda activate "${CONDA_ENV}"
fi

cd "${PROJECT_ROOT}"

python - <<'PY'
import torch
print("torch", torch.__version__)
print("cuda available", torch.cuda.is_available())
print("cuda runtime", torch.version.cuda)
print("gpu", torch.cuda.get_device_name(0) if torch.cuda.is_available() else "none")
PY

python -m ipykernel install --user --name "${CONDA_ENV}" --display-name "${CONDA_ENV}" || true

mkdir -p logs executed_notebooks "${AMIA_WORKSPACE_DIR}"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT_NOTEBOOK="executed_notebooks/${NOTEBOOK%.ipynb}_executed_pic_${STAMP}.ipynb"
LOG_FILE="logs/challenge3_pic_${STAMP}.log"

echo "Output notebook: ${OUT_NOTEBOOK}"
echo "Log: ${LOG_FILE}"

jupyter nbconvert \
  --to notebook \
  --execute "${NOTEBOOK}" \
  --ExecutePreprocessor.timeout=-1 \
  --ExecutePreprocessor.kernel_name="${CONDA_ENV}" \
  --output "${OUT_NOTEBOOK}" \
  2>&1 | tee "${LOG_FILE}"
