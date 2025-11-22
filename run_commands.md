# first time
```bash
module load miniforge
conda create -n miniswe python=3.12
conda activate miniswe
pip install -e .

pip install datasets
```

```bash
export HF_HOME="/project/jingjing_storage/persona_coder/models"
echo "HF_HOME set to $HF_HOME"

module load miniforge apptainer
conda activate miniswe

cd /project/jingjing_storage/persona_coder/mini-swe-agent-self

mini-extra swebench \
    --config qwen3coder_try.yaml \
    --subset verified \
    --split test \
    --filter "^(django__django-12125|astropy__astropy-7336)$" \
    --slice ":1" \
    --output test_qwen3coder/ \
    --redo-existing

mini-extra swebench \
    --config gptoss_120b_try.yaml \
    --subset verified \
    --split test \
    --filter "^(django__django-12125|astropy__astropy-7336)$" \
    --slice ":1" \
    --output test_120b/ \
    --redo-existing

```