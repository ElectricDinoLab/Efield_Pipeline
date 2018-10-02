# Efield_Pipeline
This toolbox collects code used to generate electric field models for localized brain stimulation, based on cortical targets assessed via fMRI and localized within a stereotaxic coordinate system.


Duke E-field Pipeline

This README describes the organization and design of the Duke E-field Pipeline, which was developed in order to provide a reasonable automated way of generating whole-brain E-field models based on human structural MR images. The pipeline combines a primary E-field generation with an email integration component that allows for an easy and efficient processing of some relatively complex computations.

The code was primarily written by Wesley Lim, with modifications by Moritz Dannhauer and Simon Davis.

The current pipeline was configured to run within a cluster environment in which all each subject is submitted (qsub) to the cluster queue for processing. This cluster environment is maintained by Duke BIAC. All file locations are therefore specific to our local processing environment, and will necessarily need to be modified to fit your local environment or processing scheme.

A unique feature of this E-field pipeline is that it was set to run on an as-needed basis by emailing a specific account/computer, which receives that email and checks for new emails with a specific subject heading every few seconds. If a relevant email is received, then it initiates the cluster pipeline.

The General flow of the pipeline
1.	The process initializes when an approved user sends an email to an pre-specified email address. 
a.	A dedicated desktop (we use an Apple iMac) should have an email client open at all times to receive this email. 
b.	Approved emails are specified in email_check_gmail.py (see below)
c.	All emails should have either 'START_TMS_MODELING', 'Start TMS Modeling', 'Start TMS', or 'TMS' in the subject heading.
2.	An email is sent to the user to confirm it has been received and modeling is beginning.
3.	The script (email_check_gmail.py) then initiates a script (rundosingsim.sh) which organizes file names and E-field targets based on the input from the email, and executes the primary modeling code.
4.	E-field simulation and output.
5.	An email then notifies the user when the process is finished.

Dependencies
The following software must be installed on your cluster/local machine before the pipeline will run efficiently. 
-	FSL
-	SimNibs
-	Python 2.7+

Important scripts
rundosingsim.sh – This script organizes the much of the file locations, and will need to be modified to fit your own processing locations.

email_check_gmail.py – This email should be running in the background if you wish to use the email feature of the pipeline. This script organizes much of the email information (addresses, admin accounts, etc.) necessary to use this component of the pipeline.

get_emails_forever.sh – In order for the pipeline to be receptive to generating E-fields on command, we use an infinite while loop in order to execute the preceding script:
e.g.: 

  while :
  do
    python2.7 email_check_gmail.py
  done



