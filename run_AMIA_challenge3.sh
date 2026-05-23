#!/usr/bin/env bash
set -euo pipefail

# --------------------------------------------------------------------------------------
# AMIA Challenge 3 launcher for VHIO/GEB
#
# Runs AMIA_Albesa-Fite-Juan_part3.ipynb as a batch job, saving an executed copy under
# ${PROJECT_ROOT}/executed_notebooks and logs under ${PROJECT_ROOT}/logs.
# --------------------------------------------------------------------------------------

PROJECT_ROOT="${PROJECT_ROOT:-/home/osiris-user/Desktop/AMIA_final_project}"
CONDA_ENV="${CONDA_ENV:-AMIA_5090}"
NOTEBOOK="${NOTEBOOK:-AMIA_Albesa-Fite-Juan_part3.ipynb}"
DATA_ROOT="${DATA_ROOT:-/home/osiris-user/Desktop/amia_project/dataset/challenge_dataset}"
KERNEL_NAME="${KERNEL_NAME:-AMIA_5090}"

export AMIA_PROJECT_DIR="${AMIA_PROJECT_DIR:-${PROJECT_ROOT}}"
export AMIA_BASE_DIR="${AMIA_BASE_DIR:-${DATA_ROOT}}"
export AMIA_RUN_TRAINING="${AMIA_RUN_TRAINING:-true}"
export AMIA_RUN_GRID_SEARCH="${AMIA_RUN_GRID_SEARCH:-true}"
export AMIA_SKIP_FINISHED_RUNS="${AMIA_SKIP_FINISHED_RUNS:-false}"
export AMIA_YOLO_GRID_EPOCHS="${AMIA_YOLO_GRID_EPOCHS:-25}"
export AMIA_RTDETR_GRID_EPOCHS="${AMIA_RTDETR_GRID_EPOCHS:-20}"
export AMIA_FASTER_RCNN_GRID_EPOCHS="${AMIA_FASTER_RCNN_GRID_EPOCHS:-7}"
export AMIA_SUBMISSION_CONF="${AMIA_SUBMISSION_CONF:-0.25}"
export AMIA_EVAL_IOU_THRESHOLD="${AMIA_EVAL_IOU_THRESHOLD:-0.4}"

echo "=== AMIA Challenge 3 launcher ==="
date
echo "PROJECT_ROOT=${PROJECT_ROOT}"
echo "DATA_ROOT=${DATA_ROOT}"
echo "CONDA_ENV=${CONDA_ENV}"
echo "NOTEBOOK=${NOTEBOOK}"
echo

echo "=== GPU ==="
nvidia-smi || true
echo

echo "=== Conda ==="
source /home/osiris-user/anaconda3/etc/profile.d/conda.sh
conda activate "${CONDA_ENV}"
python -V
python - <<'PY'
import torch
print("torch", torch.__version__)
print("cuda available", torch.cuda.is_available())
print("cuda runtime", torch.version.cuda)
print("gpu", torch.cuda.get_device_name(0) if torch.cuda.is_available() else "none")
PY
echo

cd "${PROJECT_ROOT}"

if [[ ! -f "${NOTEBOOK}" ]]; then
  echo "Notebook not found: ${PROJECT_ROOT}/${NOTEBOOK}" >&2
  exit 1
fi

if [[ ! -d "${DATA_ROOT}" ]]; then
  echo "Dataset directory not found: ${DATA_ROOT}" >&2
  echo "Set DATA_ROOT or AMIA_BASE_DIR in the GEB YAML to the VHIO dataset path." >&2
  exit 1
fi

mkdir -p logs executed_notebooks
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT_NAME="${NOTEBOOK%.ipynb}_executed_${STAMP}.ipynb"
LOG_PATH="logs/challenge3_${STAMP}.log"

echo "=== Running notebook ==="
echo "Output notebook: executed_notebooks/${OUT_NAME}"
echo "Log: ${LOG_PATH}"

jupyter nbconvert \
  --to notebook \
  --execute "${NOTEBOOK}" \
  --output "${OUT_NAME}" \
  --output-dir executed_notebooks \
  --ExecutePreprocessor.timeout=-1 \
  --ExecutePreprocessor.kernel_name="${KERNEL_NAME}" \
  2>&1 | tee "${LOG_PATH}"

echo
echo "=== Finished ==="
date
