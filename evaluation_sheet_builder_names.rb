#!/usr/bin/env ruby

require 'json'

puts
puts "json2TeX Evaluation Sheet Builder"
puts "================================================="

#get the data from a JSON file
if ARGV[0]
  source_file = File.read(ARGV[0])
  data = JSON.parse(source_file)
else
  puts "usage: evaluation_sheet.rb <JSON-file>"
  puts "       (for the correct format see \'example.json\')"
  exit
end

# The data arrays needed from the JSON-File
course = data['course']
sheet_number = data['sheet_number']
exercises = data['exercises']
groups = data['groups']

# some variables
MAX_GROUPS_PER_PAGE = 15
$groups_counter = 0
$groups_left = groups.size

puts "Producing..."
puts "#{course} Exercise Sheet #{sheet_number}"
puts "Number of Exercises: #{exercises.size}"
puts "Number of groups: #{groups.size}"

#write the file
file_name = "#{course}_Blatt_#{sheet_number}.tex"
File.open(file_name , 'w') do |file|

  file.print '
  \documentclass[a4paper, 10pt]{scrartcl}
  \usepackage[utf8]{inputenc}
  \usepackage[ngerman]{babel}
  \usepackage{amsfonts}
  \usepackage{amssymb}
  \usepackage{amsmath}
  \usepackage{geometry}
  \usepackage{longtable}
  \usepackage{colortbl}
  \usepackage{xcolor}
  \geometry{a4paper,left=1cm,right=1cm, top=0.5cm, bottom=0.5cm}
  \pagenumbering{gobble}
  \begin{document}' + "\n"

  # generate multiple pages, if you have more than MAX_GROUPS_PER_PAGE
  pages = groups.size / MAX_GROUPS_PER_PAGE
  pages = pages - 1 if groups.size % MAX_GROUPS_PER_PAGE == 0
point_cnt = 0
  for page in (0..pages)
    $groups_left = groups.size - (MAX_GROUPS_PER_PAGE * (page + 1)) >= 0 ? 10 : groups.size - MAX_GROUPS_PER_PAGE * page
#    file.print('\ttfamily \huge{' + course.to_s + '} Testat Blatt ' + sheet_number.to_s)

      #print a little smaller if groups are 2 digits long
      $groups_counter = MAX_GROUPS_PER_PAGE * page
      file.print(' \ttfamily')
      file.print "
      #{($groups_counter > 0 and $groups_left == 10) ? '\tiny' : '\small'} \n"
      file.print '\begin{longtable}{|p{10.5cm}|' + "c|" * ($groups_left + 1) + '}\\hline'

      file.print "\n" + '& \\textbf{P}'

      for i in (1..$groups_left)
	group = groups[i-1]
        file.print ' & \textbf{'+ group['name1'][0] +'+' + group['name2'][0]+ '}'
      end
      file.print ' \\\\ \hline\hline' 
      file.print "\n" + '& '

      for i in (1..$groups_left)
	group = groups[i-1]
        file.print ' &'+ group['date'][5...8]+ ''
      end
      file.print ' \\\\ \hline\hline' 
      file.print "\n"


      for i in (0...exercises.size)
        file.print '\rowcolor{gray!50}\textbf{Aufgabe ' + (i+1).to_s + ':' + exercises[i]['text'].to_s + '} & ' + exercises[i]['points'].to_s + ("& " * $groups_left) + ' \\\\'
        file.print '\hline' * 2
        file.print "\n"
        for j in (0...exercises[i]['subtasks'].size)
          subtask = exercises[i]['subtasks'][j]
          if subtask['points'] == 0
		file.print subtask['text'].to_s + '& ---' + ('& ---' * $groups_left) + ' \\\\ \hline' + "\n"
	  else
		file.print subtask['text'].to_s + '& ' + subtask['points'].to_s + ('& ' * $groups_left) + ' \\\\ \hline' + "\n"
		point_cnt = point_cnt + subtask['points']
	  end
        end
      end

      file.print "\n"
      file.print '\rowcolor{gray!10}\textbf{Summe} & ' + point_cnt.to_s + ('& ' * $groups_left)  + ' \\\\ \hline' + "\n" + '\end{longtable}' + "\n"

      #table of names under the points table
      names_rows = $groups_left
      names_columns = 3

     
      if groups.size - (MAX_GROUPS_PER_PAGE * (page + 1)) > 0
        file.print "
        \\newpage"
      end
  end
  file.print "
  \\end{document}"
end

puts
puts "The File \'#{course}_Blatt_#{sheet_number}\' is now ready."
puts
puts "pdflatex #{course}_Blatt_#{sheet_number}.tex"

# pdflatex runs silently, but you also don't see errors this way
system "pdflatex '#{file_name}' "
system "pdflatex '#{file_name}' >/dev/null"

puts
puts "READY... You can open #{course}_Blatt_#{sheet_number}.pdf now."
