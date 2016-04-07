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

  file.print "
  \\nonstopmode
  \\documentclass[a4paper, 10pt]{scrartcl}
  \\usepackage[utf8]{inputenc}
  \\usepackage[ngerman]{babel}
  \\usepackage{amsfonts}
  \\usepackage{amssymb}
  \\usepackage{amsmath}
  \\usepackage{geometry}

  \\geometry{a4paper,left=20mm,right=20mm, top=2cm, bottom=3cm}
  \\pagenumbering{gobble}

  \\begin{document}"

  # generate multiple pages, if you have more than MAX_GROUPS_PER_PAGE
  pages = groups.size / MAX_GROUPS_PER_PAGE
  pages = pages - 1 if groups.size % MAX_GROUPS_PER_PAGE == 0
  for page in (0..pages)
    $groups_left = groups.size - (MAX_GROUPS_PER_PAGE * (page + 1)) >= 0 ? 10 : groups.size - MAX_GROUPS_PER_PAGE * page
    file.print "
      \\Large{#{course} Testat Blatt #{sheet_number}}\\\\"

      #print a little smaller if groups are 2 digits long
      $groups_counter = MAX_GROUPS_PER_PAGE * page
      file.print "
      #{($groups_counter > 0 and $groups_left == 10) ? '\\small\\\\' : '\\normalsize\\\\'}"
      file.print "
      \\begin{tabular}{|p{8cm}||#{'c|' * ($groups_left + 1)}}\\hline

      & \\textbf{Pkt}"

      for i in (1..$groups_left)
        file.print " & \\textbf{#{i + $groups_counter}}"
      end

      file.print "\\\\\\hline \\hline\n"

      for i in (0...exercises.size)
        file.print "
        \\textbf{Aufgabe #{i+1}: #{exercises[i]['text']}} & #{exercises[i]['points']} #{'& ' * $groups_left}"
        file.print "\\\\\\hline\\hline"
        for j in (0...exercises[i]['subtasks'].size)
          subtask = exercises[i]['subtasks'][j]
          file.print "
          #{subtask['text']} & #{subtask['points']} #{'& ' * $groups_left} \\\\\\hline"
        end
        file.print "\\hline\n"
      end

      file.print "
        \\textbf{Summe}    & 100    #{'& ' * $groups_left} \\\\\\hline

      \\end{tabular}
      \\newline
      \\newline
      \\newline
      \\newline
	\\small"

      #table of names under the points table
      names_rows = ($groups_left + 1) / 2
      names_columns = 2

      file.print "
      \\begin{tabular}{#{'l ' * names_columns}}"

      cnt = 0
      for i in (0...names_rows)
        for j in (0...names_columns)
          cnt = cnt + 1
          if cnt <= $groups_left
            index = (i * 2) + j + $groups_counter
            group = groups[index]
            file.print "
            \\textbf{G#{index + 1}:} #{group['date']}: #{group['name1']}, #{group['name2']}#{' & 'if (j == 0 and names_columns == 2)}"
          end
        end
        file.print "\\\\"
      end

      file.print"
      \\end{tabular}"

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
system "pdflatex #{file_name} >/dev/null"

puts
puts "READY... You can open #{course}_Blatt_#{sheet_number}.pdf now."
