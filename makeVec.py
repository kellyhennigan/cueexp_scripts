#!/usr/bin/env python
# Stephanie Greer 07-26-07
# Last modified 02-01-11 by Kiefer Katovich


Usage = """This script is for creating vectors from master matrix files and vector description files."""

import string
import sys
import os
import re

def generateVector(header, masterMat, conditions, codes):
	toReturn = []
	print "This vector will be ", len(masterMat), " entrys long"
	
	for i in range(len(masterMat)):
		toReturn.insert(i, "0")
		for c in range(len(conditions)):
			cur = conditions[c]
			#used to check each comparator.  Defalt is one incase there are no entries for a comparator.
			checks = [1, 1, 1]; 
			mark = "0"
			for e in cur["="]:
				ind = header.index(e[0])
				if(not masterMat[i][ind].strip(" \t\n:\"") in e[1]):
					checks[0] = 0
					break
			for e in cur[">"]:
				ind = header.index(e[0])
				#NOTICE: this converts to INTEGERS--if the csv contains decimals and you are checking that this must
				#be changed to support floats
				if(float(masterMat[i][ind].strip(" \t\n:\"")) <= float(e[1][0])):
					checks[1] = 0
					#print masterMat[i][ind].strip(" \t\n:\"") 					
					break
			for e in cur["<"]:
				ind = header.index(e[0])
				#NOTICE: this converts to INTEGERS--if the csv contains decimals and you are checking that this must
				#be changed to support floats
				if(float(masterMat[i][ind].strip(" \t\n:\"")) >= float(e[1][0])):
					checks[2] = 0
					break
			
			if(not 0 in checks): #this means that all of the checks are still 1 and all conditions succeded
				mark = codes[c].strip(" \t\n:\"")
				if("$" in mark): #use a field instead of a number
					col = mark.strip("$")
					if(col in header):
						ind = header.index(col)
						mark = masterMat[i][ind]
					else:
						print "ERROR: The code \"", col, "\" is not in the set of columns."
						return []
			if(mark != "0"):
				if(toReturn[i] != "0"):
					print "Warning: row ", i, "matches code: ", toReturn[i], " and code: ", mark
				toReturn[i] = mark
	
	#sanity check on the codings:
	for elm in codes:
		if((not "$" in elm) & (not elm.strip(" \t\n:\"") in toReturn)):
			print "Warning: code \"", elm.strip(" \t\n:\""), "\" never appears in the output"
	#return the new vector
	return toReturn

""" checkClean is called form ParesVector used to make sure that the contitions and fields to match are acceptable values.  It also strips all the leading and trailing whitespace from each field."""
def checkClean(condition, header, masterMat, splitter):
	toReturn = condition
	toReturn[0] = condition[0].strip(" \t\n:\"")
	if(not toReturn[0] in header):
		print "ERROR: The label \"", toReturn[0], "\" is not in the set of columns."
		return []
	
	
	matches = condition[1].split(",")
	#print matches
	for n in range(len(matches)):
		matches[n] = matches[n].strip(" \t\n:\"")
		if splitter == '=':
			if(not matches[n] in masterMat):
				print "Warning: The value \"", matches[n], "\" does not appear anywhere in the origional matrix. (check for misspelling or missing commas.)"
				matches.remove(matches[n])
	
	toReturn[1] = tuple(matches)
	
	return toReturn


""" takes a vector discription and returns the conditions and codes needed for generate Vector"""
def getConditions(vec, header, matFile):
	conditions = []
	codes = []
	
	vecDef = vec.split("MARK")
	for i in range(len(vecDef))[1:]: #skip the first entry because it will be the header info
		cur = vecDef[i].split("WITH")
		if(len(cur) < 2):
			print "ERROR: \"MARK\" key followed by no \"WITH\" key"
		elif(len(cur) > 2):
			print "ERROR: more than one \"WITH\" key for one \"MARK\" key"
		else:
			codes.insert(i, cur[1])
			withinCond = cur[0].split("AND")
			#conditions will be a dictionary with =, < amd < as keys for easy matching in "generateVector"
			conditions.insert(i - 1, {"=":[], ">":[], "<":[]})
			for j in range(len(withinCond)):
				if(withinCond[j].find("=") != -1):
					spliter = "="
				elif(withinCond[j].find(">") != -1):
					spliter = ">"
				elif(withinCond[j].find("<") != -1):
					spliter = "<"
				else:
					print "comparator must be either \"=\", \">\" or \"<\""
					return
				#prepares the condition for "generateVector" using "checkClean"
				cleanCond = checkClean(withinCond[j].split(spliter), header, ("").join(matFile), spliter)
				if(cleanCond != []):
					conditions[i - 1][spliter].append(cleanCond)
				else:
					return
	return [conditions, codes]


def striplist(listIn):
    return([x.strip() for x in listIn])

def getBuildConditions(vec, buildFile, header, matFile):
	buildHeader = striplist(buildFile[0].split(","))
	buildFile = buildFile[1:]
	#this will parse the input matrix and turn it into a list of lists
	buildMat = makeMat(buildFile)
	
	conditions = []
	codes = []
	title = ''
	vecDef = vec.split("MARK")
	if(len(vecDef) > 2):
		print "WARNING: You can only have one MARK statement in your BUILD_FROM vector. Only the first one will be used."
	
	splitWith = vecDef[1].split("WITH")
	if(len(splitWith) < 2):
		print "ERROR: \"MARK\" key followed by no \"WITH\" key"
	elif(len(splitWith) > 2):
		print "ERROR: more than one \"WITH\" key for one \"MARK\" key"
	else:
		
		insertCol = splitWith[1].strip()
		if(insertCol in buildHeader):
			insertInd = buildHeader.index(insertCol)
		else:
			print "ERROR: The name, ", insertCol, ", never appears in the BUILD_FROM file."
		
		withinCond = splitWith[0].split("AND")
		matchCols = []
		matchInds = []
		for w in range(len(withinCond)):
			cur = withinCond[w].strip()
			if(cur in buildHeader):
				matchCols.insert(w, cur)
				matchInds.insert(w, buildHeader.index(cur))
			else:
				print "ERROR: The name, ", matchCol, ", never appears in the BUILD_FROM file."
		
		for i in range(len(buildMat)):
			conditions.insert(i, {"=":[], ">":[], "<":[]})
			for m in range(len(matchInds)):
				cleanCond = checkClean([matchCols[m], buildMat[i][matchInds[m]]], header, ("").join(matFile))
				if(cleanCond != []):
					conditions[i]["="].append(cleanCond)
				codes.insert(i, buildMat[i][insertInd])
	title = insertCol
	return [conditions, codes, title]
			
def makeMat(matFile):
	mat = []
	for i in range(len(matFile)):
		curItem = matFile[i].split(",")
		if(curItem[0] != ""):
			mat.insert(i, curItem)
		elif (len(curItem) != 1): #ignore all the lines with nothing on them (like extra lines at ethe end of a file)
			mat.insert(i, curItem)
	return mat

"""ParseVector takes a string that includes all the information for one vector and parses the contents of that string.  It is called from the main loop on each vector individually."""
def ParseVector(vec):
	vecIO = vec.split("\"")
	inKey = vecIO[0].strip(" \t\n:")
	if (inKey != "INPUT"):
		print "Skipping vector because there is no \"INPUT\" file.  (check for missing quotes around filename)"
		return
	infile = vecIO[1].strip(" \t\n")
	
	outKey = vecIO[2].strip(" \t\n:")
	outfile = ""
	append = False
	build = False
	title = ""
	if (outKey == "OUTPUT"):
		outfile = vecIO[3].strip(" \t\n")
		print "Vector will be savd as ", outfile
	elif(outKey == "BUILD_FROM"):
		buildfile = vecIO[3].strip(" \t\n")
		outfile = infile
		build = True
		print "Vector will added as a column in the file:", infile	
	elif(outKey == "APPEND_TO"):
		outfile = vecIO[3].strip(" \t\n")
		append = True
		if(vecIO[4].strip(" \t\n:") == "TITLE"):
			title = vecIO[5].strip(" \t\n")
		print "Vector will added as a column in the file:", outfile
	else:
		print "No output given (check for missing quotes around filename). \nVector will be saved as \"vector.1D\""
		outfile = "vector.1D"
	
	matFile = open(infile).read().split("\n") #matFile is a list containing each line of the input matrix
	if (len(matFile) == 1):
		matFile = open(infile).read().split('\r')
	header = matFile[0].split(",") #header now contains a list of the column headers (first line) in the input matrix
	
	for n in range(len(header)):
		header[n] = header[n].strip(" \t\n:\"")

	#this will parse the input matrix and turn it into a list of lists

	matFile = matFile[1:]
	mat = makeMat(matFile)
	
	if(build):
		buildFile = open(buildfile).read().split("\n")
		cond_output = getBuildConditions(vec, buildFile, header, matFile)
		title = cond_output[2]
	else:
		cond_output = getConditions(vec, header, matFile)
	
	conditions = cond_output[0]
	codes = cond_output[1]
	
	#print conditions
	#print codes
	finalvec = generateVector(header, mat, conditions, codes)
	
	#save the new vector returned from generateVector
	if(append | build):
		out = open(outfile, "r")
		outText = out.read().split("\n")
		out.close()
		
		if(len(outText) < len(finalvec)):
			print "Warning: output vector and file to append to do not match in length. Output will be saved as \"vector.1D\""
			outfile = "vector.1D"
		elif(title in outText[0]):
			print "WARNING: the column, ",  title.strip(), ", already exists.  It will be overwriten."
			header = striplist(outText[0].split(','))
			ind = header.index(title)
			outMat = makeMat(outText[1:])
			for i in range(len(finalvec)):
				outMat[i][ind] = finalvec[i]
				finalvec[i] = ",".join(outMat[i])
			finalvec.insert(0, outText[0])
				
		elif(title != ""):
			finalvec.insert(0, title)
			for i in range(len(finalvec)):
				finalvec[i] = outText[i] + "," + finalvec[i]


	out = open(outfile, "w")
	out.write("\n".join(finalvec))
        out.close()

##### Flow of control starts here ######

#start by getting the input
if (len(sys.argv) < 1 ):
        print Usage
	
File = sys.argv[1]
fid = open(File)
mat2v = fid.read() #mat2v now stores the file contents for parsing
fid.close()

#split on "BEGIN_VEC"
beginVec = mat2v.split("BEGIN_VEC")

#loops through each individual vector
count = 1
for cur in beginVec[1:]:
	oneVec = cur.split("END_VEC")[0] #oneVec now contains all info between one "BEGIN_VEC" and "END_VEC" pair.
	print "Vector", count, ":" 
	ParseVector(oneVec)
	count = count + 1
	print "\n"

