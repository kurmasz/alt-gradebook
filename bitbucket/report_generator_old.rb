def self.generate_report_old(dir_name, gradebook, student)
    
  core_total = { e: 0, m: 0, p: 0, x: 0, future: 0 }
  all_total = { e: 0, m: 0, p: 0, x: 0, future: 0 }
  lab_total = { e: 0, m: 0, p: 0, x: 0, future: 0 }
  le_total = { e: 0, m: 0, p: 0, x: 0, future: 0 }

  category_grades = []

  # out = File.open("#{dir_name}/#{student.username}.md", "w")

  return if student.github.nil? || student.github.empty? || student.github == '<unknown>'

  directory = "#{dir_name}/#{student.github}"
  unless dir_name.nil? || File.exist?(directory)
    $stderr.puts "No such directory #{directory}" 
    return
  end

  if (dir_name.nil?) 
    out = File.open("/tmp/test_#{student.github}.md", "w")
  else
    out = File.open("#{directory}/README.md", "w")
  end

  out.puts "# Progress Report for #{student.full_name}"
  out.puts
  out.puts "## Learning Objectives"
  out.puts
  out.puts "| Objective | Core | Status |"
  out.puts "|-----------|------|--------|"

  gradebook.learning_objectives.each do |lo|
    is_core = gradebook.core_learning_objectives.include?(lo)
    core_str = (is_core ? "Core" : "")
    mark = student.get_mark(lo)
    mark_sym = mark_to_sym(mark) # mark.nil? ? :future : mark.downcase.to_sym
    out.puts "| #{lo} | #{core_str} | #{mark_to_string(mark)}|"

    unless core_total.has_key?(mark_sym)
      puts "#{student.username} has unknown #{mark_sym} for #{lo}"
    end
    core_total[mark_sym] += 1 if is_core
    all_total[mark_sym] += 1
  end

  category_grades << report_category(out, 'Core Learning Objectives', core_total, $g[:total_core_objectives], :core_master, :core_progressing )
  category_grades << report_category(out, 'All Learning Objectives', all_total, $g[:total_objectives], :all_master, :all_progressing )

  out.puts "## Labs"
  out.puts
  out.puts "| Lab | Engagement | Deliverable |"
  out.puts "|-----------|------|--------|"

  gradebook.lab_deliverables.each do |ld|
      mark = student.get_mark(ld)
      mark_sym = mark_to_sym(mark) #  mark.nil? ? :future : mark.downcase.to_sym

      ld =~ /\s*L(\d+)D/
      $stderr.puts "Problem with LD key #{ld}" if $1.nil?
      le = "L#{$1}E"
      unless gradebook.lab_engagement.include?(le)
          le_mark = "--"
      else
          le_mark =  student.get_mark(le)
          le_mark_sym = le_mark.nil? ? :future :  mark_to_sym(le_mark)
          le_total[le_mark_sym] += 1
      end
      
      out.puts "| #{ld} | #{mark_to_string(le_mark)} | #{mark_to_string(mark)}|"

      unless lab_total.has_key?(mark_sym)
        puts "#{student.username} has unknown #{mark_sym} for #{ld}"
      end
      lab_total[mark_sym] += 1
    end

  category_grades << report_category(out, 'Lab Deliverables', lab_total, $g[:total_labs], :lab_m, :lab_r )
  category_grades << report_category(out, 'Lab Engagement', le_total, $g[:total_labs], :lab_engage, nil )

  out.puts "## Homework"
  out.puts
  out.puts "| HW |  |  "
  out.puts "|-----------|------|"



  gradebook.homework.each do |hw|
    mark = student.get_mark(hw)
    mark_sym = mark_to_sym(mark) #  mark.nil? ? :future : mark.downcase.to_sym

    if (mark.nil?)
      $stderr.puts "#{student.full_name} has a nil for #{hw}"
    end

    out.puts "| #{hw} |  #{mark_to_string(mark)}|"

    #unless lab_total.has_key?(mark_sym)
    #  puts "#{student.username} has unknown #{mark_sym} for #{ld}"
    #end
    #lab_total[mark_sym] += 1
  end

  projected_grades = category_grades.map { |i| i.first }  
  current_grades = category_grades.map { |i| i[1] }

  projected_grade = min_grade(*projected_grades)
  current_grade = min_grade(*current_grades)

  out.puts "## Summary"
  out.puts ""
  out.puts "Projected Grade: #{grade_to_string(projected_grade)}"
  out.puts "Current Grade: #{grade_to_string(current_grade)}"


  out.close

  `(cd #{directory}; git add .; git commit -m "Updated grade report"; git push)` unless dir_name.nil?
end