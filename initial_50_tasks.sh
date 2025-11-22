
#!/bin/bash

# Configuration
INSTANCE_FILTER="^(django__django-12125|django__django-15380|astropy__astropy-7336|sphinx-doc__sphinx-9320|matplotlib__matplotlib-20859|pytest-dev__pytest-7982|scikit-learn__scikit-learn-13779|pytest-dev__pytest-7205|scikit-learn__scikit-learn-13496|scikit-learn__scikit-learn-25232|django__django-13794|astropy__astropy-7166|django__django-10097|django__django-12419|sphinx-doc__sphinx-9711|sphinx-doc__sphinx-9230|pytest-dev__pytest-5262|pallets__flask-5014|django__django-12308|psf__requests-5414|sphinx-doc__sphinx-8459|sphinx-doc__sphinx-8269|astropy__astropy-14309|django__django-14089|sphinx-doc__sphinx-9281|django__django-14792|django__django-16145|pytest-dev__pytest-10081|pydata__xarray-4629|sphinx-doc__sphinx-7889|pylint-dev__pylint-6903|django__django-14608|django__django-11179|django__django-17029|django__django-13297|django__django-10880|sphinx-doc__sphinx-9367|sympy__sympy-13480|django__django-15104|matplotlib__matplotlib-22719|django__django-11163|django__django-16801|sphinx-doc__sphinx-9258|django__django-14915|pydata__xarray-4075|sympy__sympy-23534|django__django-14580|psf__requests-1142|django__django-16569|django__django-10999)$"
SLICE_PARAM=":50"  # Change this to process different slices (e.g., ":10" for first 10, "10:20" for 10-20, "" for all)
CONFIG_FILE="gptoss_20b_try.yaml"
OUTPUT_DIR="test/"

# Set HF_HOME
export HF_HOME="$PWD/models"
echo "HF_HOME set to $HF_HOME"

# Load modules
module load miniforge apptainer

# Activate vllm environment and start server in background
source activate vllm_env

echo "Starting vLLM server in background..."
apptainer run --nv \
    --bind /project/jingjing_storage/persona_coder/models:/models \
    --env HF_HOME=/models \
    --env PATH=$HOME/.conda/envs/vllm_env/bin:$PATH \
    --env CPATH=/usr/lib/gcc/x86_64-linux-gnu/14/include \
    ubuntu-25.04.sif \
    vllm serve openai/gpt-oss-120b \
    --served-model-name gptoss-120b \
    --tensor-parallel-size 2 &

VLLM_PID=$!
echo "vLLM server started with PID: $VLLM_PID"

# Wait for vLLM server to be ready
echo "Waiting for vLLM server to be ready..."
while ! curl -s http://localhost:8000/health > /dev/null 2>&1; do
    echo "Waiting for server..."
    sleep 5
done
echo "vLLM server is ready!"

# Switch to miniswe environment
conda deactivate
conda activate miniswe

# Run mini-extra swebench
echo "Running mini-extra swebench..."
mini-extra swebench \
    --config ${CONFIG_FILE} \
    --subset verified \
    --split test \
    --filter "${INSTANCE_FILTER}" \
    --slice "${SLICE_PARAM}" \
    --output ${OUTPUT_DIR} \
    --redo-existing

echo "Done!"