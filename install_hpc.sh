#!/bin/bash
# Adapted from https://github.com/21tesla/PXDesign/blob/main/install_blackwell.sh
# Setup to work for CUDA 12.8

set -e  # Exit on error

# --- Configuration ---
ENV_NAME="pxdesign3"
PYTHON_VER="3.12"
CUDA_VER="cu128"

#echo ">>> Starting HPC Installation Protocol..."

# 1. Create Conda Environment
echo ">>> Creating Conda Environment: $ENV_NAME..."
conda create -n $ENV_NAME python=$PYTHON_VER -y
conda activate $ENV_NAME

# 2. Install PyTorch Nightly (Blackwell Required)
echo ">>> Installing PyTorch Nightly for $CUDA_VER..."
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128

# 3. Install JAX & DeepSpeed (Modern Hardware Support)
echo ">>> Installing JAX and DeepSpeed..."
pip install -U "jax[cuda12_local]"
pip install deepspeed ninja

# 4. Install Common Dependencies (Preventing downgrade loops)
echo ">>> Installing Scientific Stack..."
pip install scipy biopython==1.86 einops tqdm pyyaml transformers pandas \
    natsort fire omegaconf joblib dm-haiku chex optax ml-collections \
    cuequivariance-torch cuequivariance-ops-torch-cu12

# 5. Install Protenix (Manual Fixes)
echo ">>> Cloning & Patching Protenix..."
if [ ! -d "Protenix" ]; then
    git clone https://github.com/bytedance/Protenix.git
fi
cd Protenix

pip install --no-deps -e .
cd ..

# 6. Install PXDesign (Manual Fixes)
echo ">>> Cloning & Patching PXDesign..."
if [ ! -d "PXDesign" ]; then
    git clone https://github.com/bytedance/PXDesign.git
fi
cd PXDesign

pip install --no-deps -e .
cd ..

# 7. Install PXDesignBench (Manual Fixes)
echo ">>> Cloning & Patching PXDesignBench..."
if [ ! -d "PXDesignBench" ]; then
    git clone https://github.com/bytedance/PXDesignBench.git
fi
cd PXDesignBench

# Downgrade Biotite specifically for Protenix legacy requirement
#pip install biotite==1.0.1
pip install --no-deps -e .
cd ..

# 8. Install ColabDesign (JAX Fix)
echo ">>> Cloning & Patching ColabDesign..."
if [ ! -d "ColabDesign" ]; then
    git clone https://github.com/sokrypton/ColabDesign.git
fi
cd ColabDesign

pip install --no-deps -e .
cd ..

echo ">>> Downloading Weights (This may take time)..."
cd PXDesign
bash download_tool_weights.sh

echo "=========================================================="
echo "  INSTALLATION COMPLETE"
echo "  Environment: $ENV_NAME"
echo ""
echo "  To run a job, use the flags below to disable incompatible kernels:"
echo "  pxdesign pipeline -i <INPUT.yaml> -o <OUT_DIR> --N_sample 1 --dtype bf16 --use_fast_ln False --use_deepspeed_evo_attention False"
echo "=========================================================="

