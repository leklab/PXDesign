#!/bin/bash
# Adapted from https://github.com/21tesla/PXDesign/blob/main/install_blackwell.sh
# Setup to work for CUDA 12.8

set -e  # Exit on error

# --- Configuration ---
ENV_NAME="pxdesign5"
PYTHON_VER="3.12"
CUDA_VER="cu128"

#echo ">>> Starting HPC Installation Protocol..."

# 1. Create Conda Environment
echo ">>> Creating Conda Environment: $ENV_NAME..."
source $(conda info --base)/etc/profile.d/conda.sh
conda create -n $ENV_NAME python=$PYTHON_VER -y
conda activate $ENV_NAME

# 2. Install PyTorch Nightly (Blackwell Required)
echo ">>> Installing PyTorch Nightly for $CUDA_VER..."
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/$CUDA_VER

# 3. Install JAX & DeepSpeed (Modern Hardware Support)
echo ">>> Installing JAX and DeepSpeed..."
pip install -U "jax[cuda12_local]"
pip install deepspeed ninja

# 4. Install Common Dependencies (Preventing downgrade loops)
echo ">>> Installing Scientific Stack..."
pip install scipy biopython==1.86 einops tqdm pyyaml transformers pandas \
    natsort fire omegaconf joblib dm-haiku chex optax ml-collections \
    cuequivariance-torch cuequivariance-ops-torch-cu12

# 5. Install Protenix v2
echo ">>> Cloning & Patching Protenix..."
if [ ! -d "Protenix" ]; then
    git clone https://github.com/leklab/Protenix.git
fi
cd Protenix

pip install --no-deps -e .
cd ..

# 6. Install PXDesign
echo ">>> Cloning & Patching PXDesign..."
if [ ! -d "PXDesign" ]; then
    git clone https://github.com/leklab/PXDesign.git
fi
cd PXDesign

pip install --no-deps -e .
cd ..

# 7. Install PXDesignBench
echo ">>> Cloning & Patching PXDesignBench..."
if [ ! -d "PXDesignBench" ]; then
    git clone -b protenix-2.0-compat https://github.com/leklab/PXDesignBench.git
fi
cd PXDesignBench

pip install --no-deps -e .
cd ..

# 8. Install ColabDesign
echo ">>> Cloning & Patching ColabDesign..."
if [ ! -d "ColabDesign" ]; then
    git clone https://github.com/leklab/ColabDesign.git
fi
cd ColabDesign

pip install --no-deps -e .
cd ..

# 9. Installing some dependencies miss due to using --nodeps
echo ">>> Installing last set of dependencies"
pip install --no-deps \
    fair-esm icecream ipdb ipywidgets matplotlib==3.9.2 \
    modelcif==0.7 optree protobuf==3.20.2 py3Dmol rdkit \
    scikit-learn scikit-learn-extra wandb \
    narwhals threadpoolctl joblib \
    dm-tree ml-collections mock stringcase \
    pyparsing kiwisolver pillow cycler packaging contourpy fonttools

pip install --no-deps \
    fair-esm==2.0.0 \
    gemmi==0.6.7 \
    icecream==2.1.7 \
    ipdb==0.13.13 \
    ipywidgets==8.1.7 \
    matplotlib==3.10.5 \
    modelcif==1.4 \
    optree==0.17.0 \
    pdbeccdutils==1.0.0 \
    protobuf==6.31.1 \
    py3Dmol==2.5.2 \
    rdkit==2025.9.3 \
    scikit-learn==1.7.1 \
    scikit-learn-extra==0.3.0 \
    wandb==0.21.1 \
    biotite==1.4.0 \
    requests

echo ">>> Downloading Weights (This may take time)..."
#cd PXDesign
#bash download_tool_weights.sh

echo "=========================================================="
echo "  INSTALLATION COMPLETE"
echo "  Environment: $ENV_NAME"
echo ""
echo "  To run a job, use the flags below to disable incompatible kernels:"
echo "  pxdesign pipeline -i <INPUT.yaml> -o <OUT_DIR> --N_sample 1 --dtype bf16 --use_fast_ln False --use_deepspeed_evo_attention False"
echo "=========================================================="

