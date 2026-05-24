#!/usr/bin/env bash
set -euo pipefail

# --------------------------------------------------------------------------------------
# AMIA Challenge 3 notebook launcher for VHIO/GEB.
# Starts the Jupyter/Geb services; open the notebook manually and run it from Jupyter Lab.
# --------------------------------------------------------------------------------------

PROJECT_ROOT="${PROJECT_ROOT:-/home/osiris-user/Desktop/amia_project/AMIA_final_project}"
CONDA_ENV="${CONDA_ENV:-AMIA_5090}"
DATA_ROOT="${DATA_ROOT:-/home/osiris-user/Desktop/amia_project/dataset/challenge_dataset}"
KERNEL_NAME="${KERNEL_NAME:-AMIA_5090}"
KERNEL_DISPLAY_NAME="${KERNEL_DISPLAY_NAME:-AMIA 5090}"
JUPYTER_PASSWORD="${JUPYTER_PASSWORD:-password123}"
PUBLIC_KEY="${PUBLIC_KEY:-password123}"

export AMIA_PROJECT_DIR="${PROJECT_ROOT}"
export AMIA_BASE_DIR="${DATA_ROOT}"
export AMIA_WORKSPACE_DIR="${PROJECT_ROOT}/challenge3_outputs"
export AMIA_RUN_TRAINING="${AMIA_RUN_TRAINING:-true}"
export AMIA_RUN_GRID_SEARCH="${AMIA_RUN_GRID_SEARCH:-true}"
export AMIA_SKIP_FINISHED_RUNS="${AMIA_SKIP_FINISHED_RUNS:-false}"
export AMIA_YOLO_GRID_EPOCHS="${AMIA_YOLO_GRID_EPOCHS:-80}"
export AMIA_RTDETR_GRID_EPOCHS="${AMIA_RTDETR_GRID_EPOCHS:-60}"
export AMIA_FASTER_RCNN_GRID_EPOCHS="${AMIA_FASTER_RCNN_GRID_EPOCHS:-20}"
export AMIA_ULTRALYTICS_PATIENCE="${AMIA_ULTRALYTICS_PATIENCE:-15}"
export AMIA_FASTER_RCNN_PATIENCE="${AMIA_FASTER_RCNN_PATIENCE:-5}"
export AMIA_SUBMISSION_CONF="${AMIA_SUBMISSION_CONF:-0.25}"
export AMIA_EVAL_IOU_THRESHOLD="${AMIA_EVAL_IOU_THRESHOLD:-0.4}"

echo "=== AMIA notebook session ==="
date
echo "PROJECT_ROOT: ${PROJECT_ROOT}"
echo "DATA_ROOT: ${DATA_ROOT}"
echo "CONDA_ENV: ${CONDA_ENV}"
echo "JUPYTER_PASSWORD: ${JUPYTER_PASSWORD}"
echo "PUBLIC_KEY: ${PUBLIC_KEY}"
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
python -m ipykernel install --user --name "${KERNEL_NAME}" --display-name "${KERNEL_DISPLAY_NAME}" || true
echo

cd "${PROJECT_ROOT}"

echo "=== Project files ==="
pwd
ls -lah
echo

if [[ ! -d "${DATA_ROOT}" ]]; then
  echo "WARNING: DATA_ROOT does not exist: ${DATA_ROOT}" >&2
  echo "Update DATA_ROOT in the GEB YAML before running the notebook." >&2
fi

export JUPYTER_PASSWORD
export PUBLIC_KEY

echo "=== Starting VHIO notebook services ==="
. /start.sh
