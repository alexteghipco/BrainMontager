# BrainMontager
Make brain montages with and without outlines of segmentations. This is still a work in progress.

Here is an example of output with contours:
<br/>
<img align="center" width="900" height="1000" src="https://i.imgur.com/T3iHSgs.png">
<br/>
<br/>

Here is an example of output without contours (same data):
<br/>
<img align="center" width="1100" height="900" src="https://i.imgur.com/2JXaoLV.png">
<br/>
<br/>

Another example with an ROI on higher-res non-segmented data (i.e., spm152.nii.gz). Note, for non-segmented maps, you should loop through the con output and change the LevelList to something appropriate for your data and faithful to wm/gm boundaries etc...For example: 

	>> [~,cont,~,~] = brainMontager('/Users/alex/Downloads/spm152.nii.gz','/Users/alex/Downloads/output_resampled_bin.nii.gz',[1:9:215 215],5,[],'gray',[],[1 1 1],true,1000,[],'jet',[],0.3,'ud',true,false);
	>> for i = 1:length(cont)
	>>     cont{i}.LevelList = [20 100 160];
	>> end
 
<br/>
<img align="center" width="800" height="1000" src="https://i.imgur.com/0oAau7U.png">
<br/>
<br/>

Editing the lineWidth in the contour maps can also help with images like the above which have a lot of sharp edges. For fun, this is a segmented version of spm152 but it typically shows the same kind of jagged edge artifacts at larger line widths (same code as above but lineWidth property lowered manually): 
<br/>
<img align="center" width="900" height="1000" src="https://i.imgur.com/fJMHPoe.png">
<br/>
<br/>

Finally, you can flip the arguments to generate an outline over a normal T1 like so:

	>> [tmp1,tmp2,tmp3,tmp4] = brainMontager('/Users/alex/Downloads/output_resampled_bin.nii.gz','/Users/alex/Downloads/spm152.nii.gz',[1:9:215 215],5,[],'jet',[],[1 1 1],false,1000,[],'gray',[],0.3,'ud',true,false);
 
<br/>
<img align="center" width="900" height="700" src="https://i.imgur.com/GuiO8xo.png">
<br/>
<br/>

And if you pass in multiple underlays as a cell array they will all be outlined in different colors based on the colormap you've selected. For example:

	>> [tmp1,tmp2,tmp3,tmp4] = brainMontager({'/Users/alex/Documents/GitHub/brainSurfer-v2/brainMapsforTesting/multidim/semantics.nii.gz_specificity_z_FDR_0.01.nii.gz';'/Users/alex/Documents/GitHub/brainSurfer-v2/brainMapsforTesting/multidim/default_mode.nii.gz_specificity_z_FDR_0.01.nii.gz'},'/usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz',[1:5:91],5,[],'jet',[],[1 1 1],false,1000,[],'gray',[],0.3,'ud',true,false,'viridis');
<br/>
<img align="center" width="900" height="700" src="https://i.imgur.com/7NxlyGa.png">
<br/>
<br/>
