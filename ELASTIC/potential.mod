# NOTE: This script can be modified for different pair styles 
# See in.elastic for more info.

# Choose potential

#pair_style      polymorphic
#pair_coeff      * * /home/lei/software/lammps/potentials/FeCH_BOP_I.poly Fe C H

pair_style      quip
pair_coeff      * * /data/lei/New_GAP/potential_train_GAP/train_all_addDB10/gap_Fe_test.xml "Potential xml_label=GAP_2021_6_26_120_9_53_32_35" 26

