defmodule DrasMvp.Academic.ExamRecord do
  use Ecto.Schema
  import Ecto.Changeset

  schema "exam_records" do
    field :exam_date, :date
    field :exam_type, :string
    field :student_count, :integer, default: 0
    field :examiner_hours, :decimal, default: Decimal.new("0.0")
    field :grading_hours, :decimal, default: Decimal.new("0.0")
    field :import_batch_id, :string
    field :status, :string, default: "imported"

    belongs_to :course, DrasMvp.Academic.Course

    timestamps()
  end

  def changeset(exam_record, attrs) do
    exam_record
    |> cast(attrs, [
      :course_id,
      :exam_date,
      :exam_type,
      :student_count,
      :examiner_hours,
      :grading_hours,
      :import_batch_id,
      :status
    ])
    |> validate_required([:course_id])
    |> validate_inclusion(:status, ["imported", "validated", "processed"])
    |> validate_number(:student_count, greater_than_or_equal_to: 0)
  end
end
