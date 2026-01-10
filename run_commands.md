conda create -n miniswe python=3.12
conda activate miniswe
pip install -e .

cp .env.example .env

mini-extra swebench \
    --config gptoss_20b_try.yaml \
    --subset verified \
    --split test \
    --filter "^(matplotlib__matplotlib-24149|sympy__sympy-17630)$" \
    --slice ":1" \
    --output test/ \
    --redo-existing

export HF_HOME="/scratch/muh5jn/models"
echo "HF_HOME set to $HF_HOME"

module load miniforge apptainer
conda activate miniswe

mini-extra swebench \
    --config qwen3.yaml \
    --subset verified \
    --split test \
    --filter "^(scikit-learn__scikit-learn-25232|sympy__sympy-17630)$" \
    --slice ":1" \
    --output test_qwen3/ \
    --sif-cache sif_cache/ \
    --redo-existing

vllm serve /home/cche/projects/models/models--Qwen--Qwen3-1.7B/snapshots/70d244cc86ccca08cf5af4e1e306ecf908b1ad5e --served-model-name qwen3