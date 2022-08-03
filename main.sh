#/bin/bash
#------------------------------
# This is a main/controlling code.
# Rewritten in bash script.
# DATE: 1 Dec 2021
# AUTHOR: lei.zhang@rug.nl
#------------------------------
# Attention: Please read through READMD.md file carefully before using the script.
#------------------------------

# Enter your email address
eaddress="lei.zhang@rug.nl"

# Full path to LAMMPS, cores for running testings
echo "Please input the name for current GAP"
read potential_name

#potential_name="GAP_doubleSOAP_cracks"

LMMP=/data/lei/nequip_2022_07_05/lammps/build/lmp
Ncores=1

# check of the results.txt file is exist
if [ -f results.txt ]
then
        rm results.txt
else
        echo "No results file is found!"
fi

rm flag*
# Grep the potential version and echo to results file
touch results.txt
echo '===========================' | tee -a  results.txt
echo 'GAP basis set:' ${potential_name} | tee -a results.txt
echo '<--GAP identity-->' | tee -a results.txt
awk '/^pair_coeff*/' ./potential.in | tee -a results.txt
echo '===========================' | tee -a results.txt

mkdir ${potential_name}

# load the dependent modules.
module restore set-gap

# E-V curve ------------------------------------------------------
cd ENERGYVOLUME
mpirun -n 1 $LMMP -in in.eos 
# fit EOS
python3 eos-fit.py
cp volume.dat ../PLOT_DATA/eos_gap_lei.csv
# read lattice paramter
a1=$(grep 'a0 =' ../results.txt | awk '{print $3}')
echo 'EOS Generated!'

# Bain path calculation.------------------------------------------
cd ../BAINPATH
rm slurm*
rm dump*
sbatch submit $LMMP $a1

# Stacking fault energy---------------------------------------------
cd ../SFE
rm slurm*
rm dump*
sbatch submit_111 $LMMP $a1
sbatch submit_112 $LMMP $a1

# Calculation of vacancy formation energy.-------------------------
cd ../VACANCY
mpirun -n $Ncores $LMMP -in in.vac -v lat $a1

# Calculation of elastic constants.--------------------------------
cd ../ELASTIC
mpirun -n $Ncores $LMMP -in in.elastic -v lat $a1

# Calculation of surface energies.---------------------------------
cd ../SURFACEENERGY
rm log.* dump*
# (100) plane
mpirun -n $Ncores $LMMP -in in.surf1 -v lat $a1
mv log.lammps log.surf100
# (110) plane
mpirun -n $Ncores $LMMP -in in.surf2 -v lat $a1
mv log.lammps log.surf110
# (111) plane
mpirun -n $Ncores $LMMP -in in.surf3 -v lat $a1
mv log.lammps log.surf111
# (112) plane
mpirun -n $Ncores $LMMP -in in.surf4 -v lat $a1
mv log.lammps log.surf112

# Mail the results ---------------------------------------------------
cd ..
mail -s "Basic Properties of iron predicted by GAP"  -a results.txt "${eaddress}" <<EOF
Please check the performance of GAP version: ${potential_name}
EOF

# Loop while wait for the signal for submitted job to be finished. 
i=0
while [ ! -f flag_sfe_111 ] || [ ! -f flag_sfe_112 ] || [ ! -f flag_bp ]
    do
    sleep 60
    i=$((i+1))
    echo "Waiting time (min):" $i    
    done

# Exacute python script to do the plots.py------------------------------
cd PLOT_DATA
# Plot E-V curve and Bain path
python3 Plot_eos_bain.py
cp gap21_eos_bp.png ../${potential_name}
#python3 sfe.py
#cp sfe_110plane.png ${potential_name}
# Copy all the dump file to final.
cd ..
cp -r BAINPATH ${potential_name}
cp -r SURFACEENERGY ${potential_name}
cp -r results.txt ${potential_name}
#cp -r SFE ${potential_name}

cd ${potential_name}
# Send email of the plots as the attached file.
mail -s "EOS, Bain path, and SFE of iron predicted by GAP:"  -a gap21_eos_bp.png "${eaddress}" <<EOF
Please check the performance of GAP version:  ${potential_name}.
EOF
