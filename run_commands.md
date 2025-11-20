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