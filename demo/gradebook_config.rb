OUTPUT_BASE = "#{File.dirname(__FILE__)}/progressReports"

grade_info = {
  learningObjectives: {
     total: 13
  },
  homework: {
    total: 13,
  }
}

{
  gradebook_file: "#{File.dirname(__FILE__)}/demo_grades.xlsx",
  output_file: lambda {|github_dir| "#{OUTPUT_BASE}/#{github_dir}/README.md"  },
  info_sheet_name: "info",
  categories: [{
    key: :learningObjectives,
    title: "Learning Objectives",
    short_name: "LO",
  },
               {
    key: :homework,
    title: "Homework",
    short_name: "H",
  }],

  # very dumb algorithm as proof of concept.
  # I also don't like the name "calc_grade"
  calc_grade: lambda do |student, category: nil, final_grade: true|
    if (category.nil? && !final_grade) 
      puts "If final_grade is false, you must either specify a category"
      exit 5
    end
    
    # puts "Calculating #{final_grade ? 'final' : category} grade for #{student.full_name}"

    categories = category.nil? ? [:learningObjectives, :homework] : [category]

    m_or_better = 0
    categories.each do |cat|
      m_or_better += student.get_marks(cat).select { |m| m =~ /m|e/}.count
    end

    m_or_better >= 4 * categories.length ? 'A' : 'B'
  end
}
