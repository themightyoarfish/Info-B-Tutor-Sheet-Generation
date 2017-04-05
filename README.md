# Info-B-Tutor-Sheet-Generation
Code modified from Manuel Schwarz. Needs the ex sheet as json data.

# Requirements
You need Ruby and LaTeX installed.

# Usage
* Make executable with `chmod +x evaluation_sheet_builder.rb`.
* Then run `./evaluation_sheet_builder.rb <json-file>` to generate the sheet.
* `evaluation_sheet_builder.rb` will label group columns with numbers which are mapped to groups at the bottom of the sheet, while `evaluation_sheet_builder_names.rb` uses the group's initials and drops the bottom table.
