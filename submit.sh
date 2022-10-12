#!/bin/bash
#------------------------------
# This is a main/controlling code.
# Rewritten in bash script.
# DATE: 1 Dec 2021
# AUTHOR: lei.zhang@rug.nl
#-------------------------------
# Updates: 11 Oct 2022: New function
# Major change: all calculations are submitted by SLURM.
#------------------------------
# Attention: Please read through READMD.md file carefully before using the script.
#------------------------------
#SBATCH --job-name=IAP_test
#SBATCH --ntasks=32
#SBATCH --cpus-per-task=1
#SBATCH --time=10:00:00
#SBATCH --error=slurm-%j.stderr
#SBATCH --output=slurm-%j.stdout
#SBATCH --mail-type=ALL
#SBATCH --mail-user=lei.zhang@rug.nl

# Enter your email address
eaddress="lei.zhang@rug.nl"

# load the dependent modules.
module restore set-gap

# Name of the folder storing every file.
echo "Please input the name for current Potential"
#read potential_name
potential_name="GAP_NNIP_R6.5"
mkdir ${potential_name}

# Full path to LAMMPS excutable. 
LMMP="/home/zhanglei1/software/lammps/src/lmp_mpi"
Ncores=4

# check of the results.txt file is exist
if [ -f results.txt ]
then
        rm results.txt
else
        echo "No results file is found!"
fi

# Grep the potential version and echo to results file
touch results.txt
echo '===========================' | tee -a  results.txt
echo 'GAP basis set:' ${potential_name} | tee -a results.txt
awk '/^pair_style*/' ./potential.in | tee -a results.txt
awk '/^pair_coeff*/' ./potential.in | tee -a results.txt
echo '===========================' | tee -a results.txt

# E-V curve ------------------------------------------------------
cd ENERGYVOLUME
mpirun -np 4 $LMMP -in in.eos 
# fit EOS
python eos-fit.py
cp volume.dat ../PLOT_DATA/eos_gap_lei.csv
# read lattice paramter
a1=$(grep 'a0 =' ../results.txt | awk '{print $3}')
echo 'EOS Generated!'

# Bain path calculation.------------------------------------------
cd ../BAINPATH
rm slurm*
rm dump*
mpirun -np 2 $LMMP -in in.bain_path -v lat $a1

# Stacking fault energy---------------------------------------------
cd ../SFE
rm slurm*
rm dump*
mpirun -np 32 $LMMP -in in.bain_path -v lat $a1
mpirun -np 32 $LMMP -in in.bain_path -v lat $a1

# Calculation of vacancy formation energy.-------------------------
cd ../VACANCY
mpirun -n 32 $LMMP -in in.vac -v lat $a1

# Calculation of elastic constants.--------------------------------
cd ../ELASTIC
mpirun -n 32  $LMMP -in in.elastic -v lat $a1

# Calculation of surface energies.---------------------------------
cd ../SURFACEENERGY
rm log.* dump*
# (100) plane
mpirun -n 32  $LMMP -in in.surf1 -v lat $a1
mv log.lammps log.surf100
# (110) plane
mpirun -n 32 $LMMP -in in.surf2 -v lat $a1
mv log.lammps log.surf110
# (111) plane
mpirun -n 32 $LMMP -in in.surf3 -v lat $a1
mv log.lammps log.surf111
# (112) plane
mpirun -n 32 $LMMP -in in.surf4 -v lat $a1
mv log.lammps log.surf112

# Mail the results ---------------------------------------------------
cd ..
mail -s "Basic Properties of iron predicted by IAP"  -a results.txt "${eaddress}" <<EOF
Please check the performance of interatomic potential: ${potential_name}
EOF

# Exacute python script to do the plots.py------------------------------
cd PLOT_DATA
# Plot E-V curve and Bain path
python Plot_eos_bain.py
cp gap21_eos_bp.png ../${potential_name}
python sfe.py
cp sfe_110plane.png ../${potential_name}
# Copy all the dump file to final.
cd ..
cp results.txt ${potential_name}
cp -r SFE ${potential_name}

# Send email of the plots as the attached file.
cd ${potential_name}
mail -s "EOS, Bain path, and SFE of iron predicted by GAP:"  -a gap21_eos_bp.png -a sfe_110plane.png "${eaddress}" <<EOF
Please check the performance of GAP version:  ${potential_name}.
EOF
