#!/bin/zsh

###############################################################################
#Written by Michael Aumeerally, October 2022
#This script demonstrats the handling and processing of JSON using Zsh and Ruby
#It will run on a vanilla macOS install without the need to install any
#dependencies such as Apple Developer Tools, Homebrew or Macports
###############################################################################

#Adjust environment variable for unpacking the Stdout from Ruby by newlines.
IFS=$'\n'

#Set up global variables
declare -A get_keys
declare -i key_count
declare keys
declare json

#Import JSON Data for associated JSON file
json=$(<staff.json)

#Count how many keys there are
function extract_key_count()
  {
      #Condition check on whether a path parameter was passed
      if [[ "${1}" ]]; then
        #Count keys under a designated path
        object="object${1}.size"
      else
        #Count keys at the root
        object="object.size"
      fi
        #Use Ruby to count the keys
        key_count=$(
         ruby -e "require 'json'; \
         object=JSON.parse('$json'); \
         puts $object")
    }

#Extract the JSON provided and the associated keys
function extract_keys()
  {
      #Condition check on whether a path parameter was passed
      if [[ "${1}" ]]; then
         #Extract the JSON at the requested path
	 sub_json=$(
          ruby -e "require 'json'; \
          object=JSON.parse('$json'); \
          puts object${1}.to_json")
         #Use Ruby to extract the keys from path
         keys=($(
          ruby -e "require 'json'; \
          object=JSON.parse('$sub_json'); \
          puts object.keys"))
         #Call function to extract values from the keys
         extract_values sub_json keys
      else
         #Use Ruby to extract the keys from Root
         keys=(
          $(ruby -e "require 'json'; \
          object=JSON.parse('$json'); \
          puts object.keys"))
         #Call funtion to extract values from the keys
         extract_values json keys
      fi
    }

#Extract values from the keys
function extract_values()
  {
      #Loop through every key extracted from the JSON
      for key in ${(P)${2}}; do
          get_keys[$key]=$(
            ruby -e "require 'json'; \
            object=JSON.parse('${(P)${1}}'); \
            puts object['$key']")
      done
    }

#Call the function to extract all the keys from the root
extract_keys
#Get the names of all the Departments stored at the root
departments=( ${(kv)keys} )
#Loop through each Department
for department in $departments; do
  #Get the number of employees for each Department
  extract_key_count "['$department']"
  employee_count=0
  #Loop through all the employees in a Department
  while [[ $employee_count < $key_count ]]; do
   #Get and print out an employee entry
   extract_keys "['$department'][$employee_count]"
   echo "Employee number $(($employee_count + 1)) in $department is:" \
    $get_keys[firstName] $get_keys[lastName]
   employee_count=$(($employee_count + 1))
  done
done
