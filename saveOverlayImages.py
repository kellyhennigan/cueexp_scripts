#!/usr/bin/python

# TO DO: 

# add functionality to define viewIdx as global variable

import os,sys,glob


##################### define global variables ##################################
# EDIT AS NEEDED:

dataDir = os.path.join(os.path.expanduser('~'),'cueexp','data')

inDir = os.path.join(dataDir,'results_cue_afni')

outDir = 'overlay_images' # must be relative to inDir

underlay_file = 'TT_N27.nii' # file should be in inDir

overlays = ['Zdrug-food'] # overlays

sub_vols = [1,3,5] # maps of interest to plot
sub_volnames = ['pvc','patients','controls'] # corresponding labels for maps of interest


# which slice to plot? 
#viewStr,slCoord,slStr,coordStr = whichSlice()	
print('save overlays in which view?\n')
print('\t1) sagittal')
print('\t2) coronal')
print('\t3) axial')

viewIdx = input('enter 1,2, or 3: ') # task index

slCoord = raw_input('which tlrc coordinate? ') # slice coordinate 

if viewIdx==1:
	viewStr = 'sagittal'
	slStr = 'x'
	coordStr = slCoord+' 0 0'
elif viewIdx==2:
	viewStr = 'coronal'
	slStr = 'y'
	coordStr = '0 '+slCoord+' 0'
elif viewIdx==3:
	viewStr = 'axial'
	slStr = 'z'
	coordStr = '0 0 '+slCoord

# e.g., viewStr='axial', slCoord = '10', slStr = 'z', and coordStr = '0 0 10'
print 'viewStr= '+viewStr
print 'slice Coord= '+slCoord
print 'slice string= '+slStr
print 'coord string= '+coordStr


print 'execute commands?'
xc = bool(input('enter 1 for yes, or 0 to only print: '))



###############################################################################
############################### DO IT #########################################
###############################################################################
###### HOPEFULLY DON T HAVE TO EDIT BELOW HERE. OR THATS THE PLAN ANYWAY. #####
###############################################################################



#########  print commands & execute if xc is True, otherwise just print them
def doCommand(cmd):
	
	print cmd+'\n'
	if xc is True:
		os.system(cmd)



#########  have user define desired view & coordinate to plot
# def whichSlice():
	
# 	print('save overlays in which view?\n')
# 	print('\t1) sagittal')
# 	print('\t2) coronal')
# 	print('\t3) axial')

# 	viewIdx = raw_input('enter 1,2, or 3: ') # task index

# 	slCoord = input('which tlrc coordinate?') # slice coordinate 

# 	if viewIdx==1:
# 		viewStr = 'sagittal'
# 		slStr = 'x'
# 		coordStr = slCoord+' 0 0'
# 	elif viewIdx==2:
# 		viewStr = 'coronal'
# 		slStr = 'y'
# 		coordStr = '0 '+slCoord+' 0'
# 	elif viewIdx==3:
# 		viewStr = 'axial'
# 		slStr = 'x'
# 		coordStr = '0 0 '+slCoord
	
# 	# e.g., viewStr='axial', slCoord = '10', slStr = 'z', and coordStr = '0 0 10'
# 	print 'viewStr= '+viewStr
# 	print 'slice Coord= '+slCoord
# 	print 'slice string= '+slStr
# 	print 'coord string= '+coordStr

# 	return viewStr,slCoord,slStr,coordStr



#########  command line(s) to start afni
def startAfniCmd():
	
	cmd = ('afni -yesplugouts & sleep 4')
	doCommand(cmd)



#########  command line(s) to display underlay 
def dispUnderlay():

	cmd = ('plugout_drive '
		'-com "OPEN_WINDOW A.'+viewStr+'image geom=600x600+800+600" '
		'-com "SWITCH_UNDERLAY '+underlay_file+'" '
		'-quit\n')
	doCommand(cmd)
	
	# cmd = ('plugout_drive -com "OPEN_WINDOW A.'+viewStr+'image geom=600x600+800+600" -com "SWITCH_UNDERLAY '+underlay_file+'" -quit\n')
	# doCommand(cmd)
	

#########  command line(s) to display overlay 
def dispOverlay(overlay,sub_vol,outname):

	cmd = ('plugout_drive '
		'-com "SET_FUNC_RANGE A.10" '
		'-com "SWITCH_OVERLAY '+overlay+'+tlrc" '
		'-com "SET_THRESHOLD A.2575 1" '
		'-com "SET_SUBBRICKS A -1 '+str(sub_vol)+' '+str(sub_vol)+'" '
		'-com "SET_DICOM_XYZ A '+coordStr+'" '
		'-com "SET_FUNC_RANGE 10" '
		'-com "SET_XHAIRS OFF" '
		'-com "SET_FUNC_RESAM A.NN.Cu" '
		'-com "SET_PBAR_ALL A.-9 1=yellow 0.44172=oran-yell 0.38906=orange 0.32905=oran-red 0.25758=none -0.25758=dk-blue -0.32905=blue -0.38906=lt-blue1 -0.48916=blue-cyan" '
		'-com "SAVE_JPEG A.'+viewStr+'image '+outDir+'/'+outname+'.jpg blowup=3" '
		'-quit')
	doCommand(cmd)

	# cmd = ('plugout_drive -com "SET_FUNC_RANGE A.10" -com "SWITCH_OVERLAY '+overlay+'+tlrc" -com "SET_THRESHOLD A.2575 1" -com "SET_SUBBRICKS A -1 '+str(sub_vol)+' '+str(sub_vol)+'" -com "SET_DICOM_XYZ A '+coordStr+'" -com "SET_FUNC_RANGE 10" -com "SET_XHAIRS OFF" -com "SET_FUNC_RESAM A.NN.Cu" -com "SET_PBAR_ALL A.-9 1=yellow 0.44172=oran-yell 0.38906=orange 0.32905=oran-red 0.25758=none -0.25758=dk-blue -0.32905=blue -0.38906=lt-blue1 -0.48916=blue-cyan" -com "SAVE_JPEG A.'+viewStr+'image '+outDir+'/'+outname+'.jpg blowup=3" -quit\n')
	# doCommand(cmd)
	
	


if __name__ == '__main__':
    

	print '\nsaving overlay images...\n'

	# cd to inDir 
	print 'cd '+inDir+'\n'
	os.chdir(inDir)		
	
	# make out dir if doesn't already exist 
	if os.path.exists(outDir):
		print '\n'+outDir+' already exists...\n'
	else:
		print 'making out dir: '+outDir+'\n'
		os.makedirs(outDir)
	

	# # which slice to plot? 
	# viewIdx,viewStr,slCoord,slStr = whichSlice()

	# command to start afni
	startAfniCmd()

	# plugout drive commands for underlay
	dispUnderlay()


	for overlay in overlays:

		for i in range(0,len(sub_vols)):
			
			sub_vol = sub_vols[i]
			sub_volname = sub_volnames[i]

			outname = overlay+'_'+sub_volname+'_'+slStr+slCoord

			# plugout commands for overlay(s)
			dispOverlay(overlay,sub_vol,outname)

			
	# command to quit plugout drive 
	cmd = ('plugout_drive -com "QUIT"\n')
	doCommand(cmd)


