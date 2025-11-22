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

export HF_HOME="/project/jingjing_storage/persona_coder/models"
echo "HF_HOME set to $HF_HOME"

module load miniforge apptainer
conda activate miniswe

mini-extra swebench \
    --config qwen3coder_30b_try.yaml \
    --subset verified \
    --split test \
    --filter "^(scikit-learn__scikit-learn-25232|sympy__sympy-17630)$" \
    --slice ":1" \
    --output test_qwen3coder/ \
    --redo-existing