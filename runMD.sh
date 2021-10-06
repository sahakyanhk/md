#!/bin/bash
mkdir md equil minim solv_box traj
echo enter your protein name
read prot_name
echo 1 | gmx pdb2gmx -f $prot_name.pdb -o $prot_name.gro -water tip3p -ignh
echo 1 | gmx editconf -f $prot_name.gro -o  solv_box/$prot_name.box.gro -c -d 1.0  -bt triclinic -princ
gmx solvate -cp solv_box/$prot_name.box.gro  -cs spc216.gro -o solv_box/$prot_name.solv.gro -p topol.top
gmx grompp  -f mdp/ions.mdp -c solv_box/$prot_name.solv.gro -o solv_box/ions.tpr -p topol.top
echo 13 | gmx genion -s  solv_box/ions.tpr    -o  solv_box/$prot_name.solv.ion.gro    -pname K   -nname Cl   -conc   0.1  -neutral   -p topol.top 
gmx grompp -f mdp/em.mdp -c solv_box/$prot_name.solv.ion.gro  -p topol.top -o minim/$prot_name.em.tpr -maxwarn 1
gmx mdrun -v -deffnm minim/$prot_name.em
gmx grompp -f mdp/nvt.mdp -c minim/$prot_name.em.gro  -p topol.top -o equil/$prot_name.nvt.tpr -r minim/$prot_name.em.gro
gmx mdrun -v -deffnm equil/$prot_name.nvt -gpu_id 0
gmx grompp -f mdp/npt.mdp -c equil/$prot_name.nvt.gro  -p topol.top -o equil/$prot_name.npt.tpr -r equil/$prot_name.nvt.gro -t equil/$prot_name.nvt.cpt
gmx mdrun -v -deffnm equil/$prot_name.npt -gpu_id 0
echo q | gmx make_ndx -f equil/$prot_name.npt.gro
gmx grompp -f mdp/md.mdp -c equil/$prot_name.npt.gro  -p topol.top -o md/free.$prot_name.md.tpr -r equil/$prot_name.npt.gro -t equil/$prot_name.npt.cpt -n index.ndx

nohup gmx mdrun -v -deffnm md/$prot_name.md  -gpu_id 0 &
