#!/bin/tcsh

#===========================================
# Montage code
#
# For a given project, with params as specified in user params, create image
# montages for each subject of UNDERLAY/OVERLAY pairs with default color
# settings from openafni. Probably most useful for regressions/ttests.
# This will probably take a while to run (maybe an hour or two) for 30-40
# subjects.
#
# -nb 6/2017
#===========================================

#++++++++++  USER PARAMS ++++++++++#

# Directory containing subjects
set SUBJECTS_DIR = '/Users/span/projects/conjointfmri/subjects/'

# CAUTION: OUTPUT_DIR will be destroyed if it already exists
set OUTPUT_DIR    = 'ratings_montage'

#The names corresponding to indices in a regression. Must be same length.
set OVERLAYS      = ( 'complete_package' 'rate_period' 'rating' )
set INDICES       = ('26' '29' '32' )

# Subject name file containing all subjects you want to use, one per line
set SUBJECT_NAMES  = '/Users/span/projects/conjointfmri/rating_subjects.txt'

set UNDERLAY_FILE = 'anat.nii'
set OVERLAY_FILE  = 'zrating_reg_csfwm_masked+orig'


#++++++++++ MONTAGE CODE - NO NEED TO TOUCH ++++++++++#

set N  = $#INDICES

if( N!=$#OVERLAYS ) then
    echo "** ERROR: OVERLAYS AND INDICES MUST BE THE SAME LENGTH"
    exit 1
endif

# Much of this taken from @snapshot_volreg (use that to check alignment)
setenv AFNI_NOSPLASH          YES
setenv AFNI_SPLASH_MELT       NO
setenv AFNI_LEFT_IS_LEFT      NO
setenv AFNI_IMAGE_LABEL_MODE  5
setenv AFNI_IMAGE_LABEL_SIZE  2
setenv AFNI_ENVIRON_WARNINGS  NO
setenv AFNI_COMPRESSOR        NONE

# reinitialize xvfb
unset xdisplay
unset killX

set ranval = `count -dig 1 1 999999 R1`

if( $?xdisplay == 0 )then
    set killX     = 1
    set ntry      = 1
    set Xnotfound = 1
    while( $Xnotfound )
        set xdisplay = `count -dig 1 3 999 R1`
        if( -e /tmp/.X${xdisplay}-lock ) continue
        echo " -- trying to start Xvfb :${xdisplay}"
        Xvfb :${xdisplay} -screen 0 1024x768x24 >& /dev/null &
        sleep 1
        jobs > zzerm.$ranval.txt
        grep -q Xvfb zzerm.$ranval.txt
        set Xnotfound = $status
        \rm -f zzerm.$ranval.txt
        if( $Xnotfound == 0 )break ;
        @ ntry++
        if( $ntry > 99 )then
            echo "** ERROR: can't start Xvfb -- exiting"
            exit 1
        endif
    end
endif

setenv DISPLAY :${xdisplay}


foreach subject (` cat ${SUBJECT_NAMES} `)
    cd $SUBJECTS_DIR/$subject
    rm -rf $OUTPUT_DIR
    mkdir $OUTPUT_DIR

    foreach i (`seq 1 $N`)
        pwd
        set outputName="${OVERLAYS[$i]}"
        set filename="${OUTPUT_DIR}/${outputName}"

        afni -no_detach -noplugins \
            -com "OPEN_WINDOW A.sagittalimage mont=9x4:3 geom=2000x2000+800+600" \
            -com "OPEN_WINDOW A.coronalimage mont=9x4:3 geom=2000x2000+800+600" \
            -com "OPEN_WINDOW A.axialimage mont=9x4:3 geom=2000x2000+800+600" \
            -com "SWITCH_UNDERLAY ${UNDERLAY_FILE}" \
            -com "SET_FUNC_RANGE A.10" \
            -com "SWITCH_OVERLAY ${OVERLAY_FILE}" \
            -com 'SET_THRESHOLD A.2575 1' \
            -com "SET_SUBBRICKS A -1 ${INDICES[$i]} ${INDICES[$i]}" \
            -com 'SET_FUNC_RANGE 10' \
            -com 'SET_FUNC_VISIBLE A.+' \
            -com 'SET_XHAIRS OFF' \
            -com 'SET_FUNC_RESAM A.NN.Cu' \
            -com 'SET_PBAR_ALL A.-9 1.000=yellow .386973=yell-oran .325670=orange .25000=red .05000=none -.05000=dk-blue -.250000=lt-blue1 -.325670=blue-cyan -.394636=cyan' \
            -com "SAVE_JPEG A.sagittalimage ${filename}_sagittal.jpg blowup=2" \
            -com "SAVE_JPEG A.coronalimage ${filename}_coronal.jpg blowup=2" \
            -com "SAVE_JPEG A.axialimage ${filename}_axial.jpg blowup=2" \
            -com "QUITT"

        end
    end
end

# stop Xvfb if we started it ourselves
if( $?killX ) kill %1

exit 0

