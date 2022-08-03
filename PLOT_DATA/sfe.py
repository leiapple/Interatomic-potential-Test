import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

# Read the data for <111>{110} stacking fault energy.
sfe_111_dft = pd.read_csv("../REF_DATA/sfe_111_dft.csv",delimiter=",",decimal=".",header=0,names=["dis","energyeV"])
sfe_111_gap18 = pd.read_csv("../REF_DATA/sfe_iron_111.csv",delimiter=" ",decimal=".",header=0,names=["dis","energyeV","energyJ"])
sfe_111_gap21 = pd.read_csv("./sfe_iron_111_lei.csv",delimiter=" ",decimal=".",header=0,names=["dis","energyeV","energyJ"])

# Read the data for <112>{110} stacking fault energy.
sfe_112_gap18 = pd.read_csv("../REF_DATA/sfe_iron_112.csv",delimiter=" ",decimal=".",header=0,names=["dis","energyeV","energyJ"])
sfe_112_gap21 = pd.read_csv("./sfe_iron_112_lei.csv",delimiter=" ",decimal=".",header=0,names=["dis","energyeV","energyJ"])

# plot data
fig, (ax, bx) = plt.subplots(nrows=1, ncols=2, figsize=(15,7))
plt.rcParams['font.size'] = '16'

# Plot for <111>{110}.
ax.grid(c='gainsboro',ls='--',lw=0.7)
ax.set_title('<111>{110}',fontsize=16)
ax.scatter(sfe_111_dft["dis"]*2.834*np.sqrt(3)/2, sfe_111_dft["energyeV"], s=30, marker='s', c='red', label='DFT')
ax.scatter(sfe_111_gap18["dis"], sfe_111_gap18["energyeV"]*1000, s=30, marker='o', c='blue', label='GAP18')
ax.scatter(sfe_111_gap21["dis"], sfe_111_gap21["energyeV"]*1000, s=30, marker='o', c='lime', label='GAP21')
ax.plot(sfe_111_dft["dis"]*2.834*np.sqrt(3)/2, sfe_111_dft["energyeV"],c='red',lw=1.5,ls='--')
ax.plot(sfe_111_gap18["dis"], sfe_111_gap18["energyeV"]*1000,c='blue',lw=1.5,ls='--')
ax.plot(sfe_111_gap21["dis"], sfe_111_gap21["energyeV"]*1000,c='lime',lw=1.5,ls='--')

ax.set_xlim([0,2.45])
ax.set_ylim([0,80])
ax.set_xlabel('Displacements, [$\AA$]', fontsize=16)
ax.set_ylabel('Stacking Fault Energy, [meV])', fontsize=16)
ax.legend(loc='upper right',fontsize=16)

# Plot for <112>{110}
bx.grid(c='gainsboro',ls='--',lw=0.7)
bx.set_title('<112>{110}',fontsize=16)
#bx.scatter(sfe_112_dft["dis"]*2.834*np.sqrt(3)/2, sfe_112_dft["energyeV"], s=30, marker='s', c='red', label='DFT')
bx.scatter(sfe_112_gap18["dis"], sfe_112_gap18["energyeV"]*1000, s=30, marker='o', c='blue', label='GAP18')
bx.scatter(sfe_112_gap21["dis"], sfe_112_gap21["energyeV"]*1000, s=30, marker='o', c='lime', label='GAP21')
#bx.plot(sfe_112_dft["dis"]*2.834*np.sqrt(3)/2, sfe_112_dft["energyeV"],c='red',lw=1.5,ls='--')
bx.plot(sfe_112_gap18["dis"], sfe_112_gap18["energyeV"]*1000,c='blue',lw=1.5,ls='--')
bx.plot(sfe_112_gap21["dis"], sfe_112_gap21["energyeV"]*1000,c='lime',lw=1.5,ls='--')

bx.set_xlim([0,5])
bx.set_ylim([0,150])
bx.set_xlabel('Displacements, [$\AA$]', fontsize=16)
bx.set_ylabel('Stacking Fault Energy, [meV])', fontsize=16)
bx.legend(loc='upper right',fontsize=16)

#plt.show()
fig.savefig('sfe_110plane.png',dpi=300)