#!/bin/bash -l
#SBATCH --job-name=depewt-eval-skipthought
#SBATCH --time=12:0:0
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH -o /home-3/nkim43@jhu.edu/log/naacl/probe/depewt-eval-skipthought.log
#SBATCH -p gpup100 --gres=gpu:1
#SBATCH -A t2-skhudan1
#SBATCH --cpus-per-task=6
#SBATCH –reservation=JSALT
#SBATCH --export=ALL
#SBATCH --mail-type=end
#SBATCH --mail-user=nkim43@jhu.edu

module load python/3.6-anaconda
module load cuda
module load gcc/5.5.0
module load openmpi/3.1

source deactivate
conda deactivate
source activate jiant
source path_config_naacl.sh


export NFS_PROJECT_PREFIX=${PROBE_DIR}
export JIANT_PROJECT_PREFIX=${NFS_PROJECT_PREFIX}

EXP_NAME=depewt
RUN_NAME=skipthought

#PROBING_TASK="edges-srl-conll2005"
#PROBING_TASK="edges-srl-conll2012"
PROBING_TASK="edges-dep-labeling-ewt"
#PROBING_TASK="edges-constituent-ontonotes"
#PROBING_TASK="edges-spr2"

MODEL_DIR=${TRAIN_DIR}/${RUN_NAME}/${RUN_NAME}-train
PARAM_FILE=${MODEL_DIR}"/params.conf"
MODEL_FILE=${MODEL_DIR}"/model_state_main_epoch_266.best_macro.th"

# use this for random init models
#MODEL_FILE=${MODEL_DIR}"/model_state_main_epoch_0.th"

OVERRIDES="load_eval_checkpoint = ${MODEL_FILE}"
OVERRIDES+=", exp_name = ${EXP_NAME}"
OVERRIDES+=", run_name = ${RUN_NAME}"
OVERRIDES+=", target_tasks = ${PROBING_TASK}"
OVERRIDES+=", use_classifier = ${PROBING_TASK}"
OVERRIDES+=", cuda = ${CUDA_VISIBLE_DEVICES}, load_model=1, reload_vocab=0, do_target_task_training=1"
#OVERRIDES+=", scaling_method=uniform"

python main.py -c config/final.conf ${PARAM_FILE} config/edgeprobe_existing.conf config/naacl_additional.conf -o "${OVERRIDES}"

