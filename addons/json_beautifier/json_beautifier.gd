#-----------------------------------------------------------------------------#
# JSON Beautifier                                                             #
# Copyright (c) 2018 Michael Alexsander Silva Dias                            #
#                                                                             #
# Permission is hereby granted, free of charge, to any person obtaining a     #
# copy of this software and associated documentation files (the "Software"),  #
# to deal in the Software without restriction, including without limitation   #
# the rights to use, copy, modify, merge, publish, distribute, sublicense,    #
# and/or sell copies of the Software, and to permit persons to whom the       #
# Software is furnished to do so, subject to the following conditions:        #
#                                                                             #
# The above copyright notice and this permission notice shall be included in  #
# all copies or substantial portions of the Software.                         #
#                                                                             #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     #
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         #
# DEALINGS IN THE SOFTWARE.                                                   #
#-----------------------------------------------------------------------------#

extends Node

# Takes valid JSON (if invalid, it will return a error according with Godot's
# 'validade_json' method) and a number of spaces for indentation (default is
# '0', in which it will use tabs instead)
static func beautify_json(json, spaces = 0):
	var error_message = validate_json(json)
	if not error_message.empty():
		return error_message
	
	# Remove pre-existing formating
	json = json.replace(" ", "")
	json = json.replace("\n", "")
	json = json.replace("\t", "")
	
	json = json.replace("{", "{\n")
	json = json.replace("}", "\n}")
	json = json.replace("{\n\n}", "{}") # Fix newlines in empty brackets
	json = json.replace("[", "[\n")
	json = json.replace("]", "\n]")
	json = json.replace("[\n\n]", "[]") # Same as above
	json = json.replace(":", ": ")
	json = json.replace(",", ",\n")
	
	var indentation = ""
	if spaces > 0:
		for i in spaces:
			indentation += " "
	else:
		indentation = "\t"
	
	var begin
	var end
	var bracket_count
	for i in [["{", "}"], ["[", "]"]]:
		begin = json.find(i[0])
		while begin != -1:
			end = json.find("\n", begin)
			bracket_count = 0
			while end != - 1:
				if json[end - 1] == i[0]:
					bracket_count += 1
				elif json[end + 1] == i[1]:
					bracket_count -= 1
				
				# Move through the indentation to see if there is a match
				while json[end + 1] == indentation:
					end += 1
					
					if json[end + 1] == i[1]:
						bracket_count -= 1
				
				if bracket_count <= 0:
					break
				
				end = json.find("\n", end + 1)
			
			# Skip one newline so the end bracket doesn't get indented
			end = json.rfind("\n", json.rfind("\n", end) - 1)
			while end > begin:
				json = json.insert(end + 1, indentation)
				end = json.rfind("\n", end - 1)
			
			begin = json.find(i[0], begin + 1)
	
	return json
