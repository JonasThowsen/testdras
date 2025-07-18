defmodule DrasMvpWeb.AcademicYearLive do
  use DrasMvpWeb, :live_view
  alias DrasMvp.Academic

  def mount(_params, _session, socket) do
    academic_years = Academic.list_academic_years()
    current_year = Academic.get_current_academic_year()

    {:ok,
     socket
     |> assign(:academic_years, academic_years)
     |> assign(:current_year, current_year)
     |> assign(:page_title, "Academic Years")
     |> assign(:show_form, false)
     |> assign(:form, to_form(Academic.AcademicYear.changeset(%Academic.AcademicYear{}, %{})))}
  end

  def handle_event("new_year", _params, socket) do
    changeset = Academic.AcademicYear.changeset(%Academic.AcademicYear{}, %{})
    {:noreply, assign(socket, :show_form, true) |> assign(:form, to_form(changeset))}
  end

  def handle_event("cancel", _params, socket) do
    {:noreply, assign(socket, :show_form, false)}
  end

  def handle_event("validate", %{"academic_year" => params}, socket) do
    changeset =
      %Academic.AcademicYear{}
      |> Academic.AcademicYear.changeset(params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event("save", %{"academic_year" => params}, socket) do
    case Academic.create_academic_year(params) do
      {:ok, _academic_year} ->
        academic_years = Academic.list_academic_years()

        {:noreply,
         socket
         |> assign(:academic_years, academic_years)
         |> assign(:show_form, false)
         |> put_flash(:info, "Academic year created successfully")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("set_active", %{"id" => id}, socket) do
    academic_year = Academic.get_academic_year!(id)

    case Academic.set_active_academic_year(academic_year) do
      {:ok, _result} ->
        academic_years = Academic.list_academic_years()
        current_year = Academic.get_current_academic_year()

        {:noreply,
         socket
         |> assign(:academic_years, academic_years)
         |> assign(:current_year, current_year)
         |> put_flash(:info, "Active academic year updated")}

      {:error, _reason} ->
        {:noreply, put_flash(socket, :error, "Failed to update active academic year")}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    academic_year = Academic.get_academic_year!(id)

    case Academic.delete_academic_year(academic_year) do
      {:ok, _academic_year} ->
        academic_years = Academic.list_academic_years()

        {:noreply,
         socket
         |> assign(:academic_years, academic_years)
         |> put_flash(:info, "Academic year deleted successfully")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to delete academic year")}
    end
  end
end
