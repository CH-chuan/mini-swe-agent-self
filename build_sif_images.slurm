#!/bin/bash

#SBATCH --time=03:00:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=8
#SBATCH --gres=gpu:a100:2
#SBATCH --constraint=a100_80gb
#SBATCH --partition=gpu
#SBATCH -J "build-sif-images"
#SBATCH --mail-user=muh5jn@virginia.edu
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH --account=jingjing_lab

# =============================================================================
# Configuration
# =============================================================================
set -euo pipefail

module load miniforge apptainer

export APPTAINER_DOCKER_USERNAME="somename"
export APPTAINER_DOCKER_PASSWORD="docker pat"

echo "$APPTAINER_DOCKER_PASSWORD" | apptainer registry login \
  --username "$APPTAINER_DOCKER_USERNAME" \
  --password-stdin \
  docker://docker.io

export APPTAINER_CACHEDIR=/scratch/muh5jn/apptainer_cache
mkdir -p "$APPTAINER_CACHEDIR"

source ~/.bashrc
conda activate miniswe

SIF_CACHE="${SLURM_SUBMIT_DIR}/sif_cache"
mkdir -p "${SIF_CACHE}"

CONFIG="${SLURM_SUBMIT_DIR}/qwen3.yaml"

SWEBENCH_FILTER="^CHANGE_ME_FILTER$"

mini-extra swebench \
  --config "${CONFIG}" \
  --subset verified \
  --split test \
  --filter "${SWEBENCH_FILTER}" \
  --output "${SLURM_SUBMIT_DIR}/sif_build_logs" \
  --environment-class singularity \
  --sif-cache "${SIF_CACHE}" \
  --prepare-sif-only
