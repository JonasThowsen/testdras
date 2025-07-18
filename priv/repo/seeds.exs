# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     DrasMvp.Repo.insert!(%DrasMvp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias DrasMvp.{Repo, Academic}
alias DrasMvp.Academic.{AcademicYear, Course, Staff}

# Create an academic year if it doesn't exist
academic_year =
  case Academic.get_current_academic_year() do
    nil ->
      {:ok, year} =
        Academic.create_academic_year(%{
          name: "2024-2025",
          start_date: ~D[2024-08-01],
          end_date: ~D[2025-07-31],
          status: "active",
          is_active: true
        })

      year

    existing_year ->
      existing_year
  end

# Create sample courses for CSV import testing
sample_courses = [
  %{
    code: "MED-1001",
    name: "Introduction to Medicine",
    description: "Basic principles of medical practice",
    credits: Decimal.new("6.0"),
    department: "Medicine",
    level: "Bachelor",
    semester: "Fall",
    status: "active",
    academic_year_id: academic_year.id
  },
  %{
    code: "MED-2001",
    name: "Advanced Clinical Practice",
    description: "Advanced medical procedures and patient care",
    credits: Decimal.new("4.5"),
    department: "Medicine",
    level: "Bachelor",
    semester: "Spring",
    status: "active",
    academic_year_id: academic_year.id
  },
  %{
    code: "BIO-1001",
    name: "Fundamental Biochemistry",
    description: "Basic biochemical processes and molecular biology",
    credits: Decimal.new("3.0"),
    department: "Biomedical Sciences",
    level: "Bachelor",
    semester: "Fall",
    status: "active",
    academic_year_id: academic_year.id
  },
  %{
    code: "BIO-2001",
    name: "Advanced Biochemistry",
    description: "Advanced biochemical research and techniques",
    credits: Decimal.new("4.0"),
    department: "Biomedical Sciences",
    level: "Master",
    semester: "Spring",
    status: "active",
    academic_year_id: academic_year.id
  }
]

# Insert courses, skipping if they already exist
Enum.each(sample_courses, fn course_attrs ->
  existing_course = Academic.find_course_by_code(course_attrs.code, academic_year.id)

  if is_nil(existing_course) do
    case Academic.create_course(course_attrs) do
      {:ok, course} ->
        IO.puts("Created course: #{course.code} - #{course.name}")

      {:error, changeset} ->
        IO.puts("Failed to create course #{course_attrs.code}: #{inspect(changeset.errors)}")
    end
  else
    IO.puts("Course #{course_attrs.code} already exists, skipping...")
  end
end)

IO.puts("\n✅ Sample data seeding complete!")
IO.puts("📊 Academic Year: #{academic_year.name}")
IO.puts("📚 Sample courses created for CSV import testing")
IO.puts("\n🧪 Test CSV format:")
IO.puts("course_code,exam_date,exam_type,student_count,examiner_hours,grading_hours")
IO.puts("MED-1001,2024-12-15,written,45,8.0,12.0")
IO.puts("BIO-2001,2024-12-18,oral,25,6.5,8.5")
