defmodule DrasMvp.Repo.Migrations.CreateDrasCoreTabels do
  use Ecto.Migration

  def change do
    # Academic Years table
    create table(:academic_years) do
      add :name, :string, null: false
      add :start_date, :date, null: false
      add :end_date, :date, null: false
      add :status, :string, default: "planning"
      add :is_active, :boolean, default: false
      add :course_setup_count, :integer, default: 0
      add :staff_assignment_count, :integer, default: 0
      add :resource_allocation_count, :integer, default: 0

      timestamps()
    end

    create unique_index(:academic_years, [:name])
    create index(:academic_years, [:is_active])

    # Staff table
    create table(:staff) do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email, :string, null: false
      add :title, :string
      add :department, :string
      add :role, :string, default: "lecturer"
      add :workload_limit, :decimal, precision: 5, scale: 2, default: 100.0
      add :is_active, :boolean, default: true

      timestamps()
    end

    create unique_index(:staff, [:email])
    create index(:staff, [:department])
    create index(:staff, [:is_active])

    # Courses table
    create table(:courses) do
      add :code, :string, null: false
      add :name, :string, null: false
      add :description, :text
      add :credits, :decimal, precision: 4, scale: 2
      add :department, :string
      add :level, :string
      add :semester, :string
      add :status, :string, default: "draft"
      add :academic_year_id, references(:academic_years, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:courses, [:code, :academic_year_id])
    create index(:courses, [:academic_year_id])
    create index(:courses, [:department])
    create index(:courses, [:status])

    # Staff Assignments table
    create table(:staff_assignments) do
      add :staff_id, references(:staff, on_delete: :delete_all), null: false
      add :course_id, references(:courses, on_delete: :delete_all), null: false
      # "lecturer", "examiner", "assistant"
      add :assignment_type, :string, null: false
      add :workload_percentage, :decimal, precision: 5, scale: 2, default: 0.0
      add :hours_allocated, :decimal, precision: 6, scale: 2, default: 0.0
      add :status, :string, default: "pending"
      add :notes, :text

      timestamps()
    end

    create index(:staff_assignments, [:staff_id])
    create index(:staff_assignments, [:course_id])
    create index(:staff_assignments, [:assignment_type])
    create unique_index(:staff_assignments, [:staff_id, :course_id, :assignment_type])

    # Exam Records table (for CSV import functionality)
    create table(:exam_records) do
      add :course_id, references(:courses, on_delete: :delete_all), null: false
      add :exam_date, :date
      add :exam_type, :string
      add :student_count, :integer, default: 0
      add :examiner_hours, :decimal, precision: 6, scale: 2, default: 0.0
      add :grading_hours, :decimal, precision: 6, scale: 2, default: 0.0
      add :import_batch_id, :string
      add :status, :string, default: "imported"

      timestamps()
    end

    create index(:exam_records, [:course_id])
    create index(:exam_records, [:exam_date])
    create index(:exam_records, [:import_batch_id])
  end
end
