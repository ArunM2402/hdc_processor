# import os
# import subprocess
# from concurrent.futures import ThreadPoolExecutor

# # Configuration
# TCL_DIR = "tcl_scripts"
# SIM_DIR = "sim_files"
# TEMPLATE = "/home/arunp24/RISCHD/codes/vivado/run_vivado.tcl"
# COE_DIR = "/home/arunp24/RISCHD/csv_files/mnist/temp/X_val_coe_files"
# TOTAL_RUNS = 11200
# BATCH_SIZE = 20
# MAX_PARALLEL_JOBS = 20

# os.makedirs(TCL_DIR, exist_ok=True)
# os.makedirs(SIM_DIR,exist_ok=True)
# # Load base template
# with open(TEMPLATE, "r") as f:
#     base_tcl = f.read()

# def generate_20_tcl(batch_start):
#     """Generate 20 TCL scripts (reused) with new COE file references."""
#     for i in range(BATCH_SIZE):
#         idx = batch_start + i
#         if idx > TOTAL_RUNS:
#             break
#         coe_path = os.path.join(COE_DIR, f"row_{idx}.coe")
#         new_script = base_tcl.replace("<COE_PATH>", coe_path)
#         tcl_name = f"run_row_{i}.tcl"
#         with open(os.path.join(TCL_DIR, tcl_name), "w") as f:
#             f.write(new_script)

# def run_tcl(tcl_file):
#     log_file = tcl_file.replace(".tcl", ".log")
#     vivado_env = "/home/arunp24/vivado/Vivado/2023.1/bin/vivado"  # ← change this
#     bash_cmd = [vivado_env,"-mode", "batch", "-source",tcl_file]
#     with open(log_file, "w") as log:
#         subprocess.run(bash_cmd, check=True,stdout=log, stderr=log)

# def copy_and_cleanup_artifacts():
#     for ext in [".jou", ".log", ".wdb"]:
#         for f in os.listdir(TCL_DIR):
#             if f.endswith(ext):
#                 os.remove(os.path.join(TCL_DIR, f))
#     # Optional Vivado folders
#     for d in ["*.cache", "*.hw", "*.sim"]:
#         os.system(f"rm -rf {d}")


# def run_batch(batch_start):
#     generate_20_tcl(batch_start)
#     tcl_files = [os.path.join(TCL_DIR, f"run_row_{i}.tcl") for i in range(BATCH_SIZE)]
#     with ThreadPoolExecutor(max_workers=MAX_PARALLEL_JOBS) as executor:
#         executor.map(run_tcl, tcl_files)
#     # copy_and_cleanup_artifacts()





# # Main Loop
# if __name__ == "__main__":
#     for batch_start in range(1, TOTAL_RUNS + 1, BATCH_SIZE):
#         print(f"🚀 Running batch {batch_start} to {min(batch_start + BATCH_SIZE - 1, TOTAL_RUNS)}")
#         run_batch(batch_start)
#         print(f"✅ Finished batch {batch_start}")

import os
import subprocess
from concurrent.futures import ThreadPoolExecutor

# Configuration
TCL_DIR = "tcl_scripts"
LOG_DIR = "log_files"
TEMPLATE = "/home/arunp24/RISCHD/codes/vivado/run_vivado.tcl"
COE_DIR = "/home/arunp24/RISCHD/csv_files/mnist/temp/X_val_coe_files"
VIVADO_PATH = "/home/arunp24/vivado/Vivado/2023.1/bin/vivado"
TOTAL_RUNS = 11200
BATCH_SIZE = 5
MAX_PARALLEL_JOBS = 20

# Ensure required directories exist
os.makedirs(TCL_DIR, exist_ok=True)
os.makedirs(LOG_DIR, exist_ok=True)


# Load base TCL template
with open(TEMPLATE, "r") as f:
    base_tcl = f.read()

def generate_tcl(batch_start):
    """Generate reusable TCL scripts, one per parallel slot."""
    for i in range(BATCH_SIZE):
        idx = batch_start + i
        if idx > TOTAL_RUNS:
            break
        coe_path = os.path.join(COE_DIR, f"row_{idx}.coe")
        script = base_tcl.replace("<COE_PATH>", coe_path)
        tcl_name = f"run_row_{i}.tcl"
        with open(os.path.join(TCL_DIR, tcl_name), "w") as f:
            f.write(script)

def run_tcl(args):
    """Run a single Vivado TCL file and redirect output to a unique log file."""
    tcl_file, run_idx = args
    log_path = os.path.join(LOG_DIR, f"run_row_{run_idx}.log")
    bash_cmd = [VIVADO_PATH, "-mode", "batch", "-source", tcl_file]

    with open(log_path, "w") as log:
        subprocess.run(bash_cmd, check=True, stdout=log, stderr=log)
    
def copy_and_cleanup_artifacts():
    """Optional cleanup if needed."""
    for ext in [".jou", ".log", ".wdb"]:
        for f in os.listdir(TCL_DIR):
            if f.endswith(ext):
                os.remove(os.path.join(TCL_DIR, f))
    for d in ["*.cache", "*.hw", "*.sim"]:
        os.system(f"rm -rf {d}")

def run_batch(batch_start):
    """Run simulations in parallel, each writing a unique log file."""
    generate_tcl(batch_start)
    tcl_files = []
    run_indices = []

    for i in range(BATCH_SIZE):
        idx = batch_start + i
        if idx > TOTAL_RUNS:
            break
        tcl_files.append(os.path.join(TCL_DIR, f"run_row_{i}.tcl"))
        run_indices.append(idx)

    with ThreadPoolExecutor(max_workers=MAX_PARALLEL_JOBS) as executor:
        executor.map(run_tcl, zip(tcl_files, run_indices))

    # Optional: cleanup after every batch
    copy_and_cleanup_artifacts()

# Main Loop
if __name__ == "__main__":
    for batch_start in range(1, TOTAL_RUNS + 1, BATCH_SIZE):
        print(f"🚀 Running batch {batch_start} to {min(batch_start + BATCH_SIZE - 1, TOTAL_RUNS)}")
        run_batch(batch_start)
        print(f"✅ Finished batch {batch_start}")
