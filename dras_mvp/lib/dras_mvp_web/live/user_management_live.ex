defmodule DrasMvpWeb.UserManagementLive do
  use DrasMvpWeb, :live_view
  alias DrasMvp.Accounts

  @impl true
  def mount(_params, _session, socket) do
    users = Accounts.list_users()

    {:ok,
     socket
     |> assign(:users, users)
     |> assign(:show_create_form, false)
     |> assign(:show_edit_form, false)
     |> assign(:selected_user, nil)
     |> assign(:form, to_form(%{}))}
  end

  @impl true
  def handle_event("show_create_form", _params, socket) do
    {:noreply, assign(socket, :show_create_form, true)}
  end

  @impl true
  def handle_event("hide_create_form", _params, socket) do
    {:noreply, assign(socket, :show_create_form, false)}
  end

  @impl true
  def handle_event("show_edit_form", %{"id" => id}, socket) do
    user = Enum.find(socket.assigns.users, fn u -> u.id == String.to_integer(id) end)

    {:noreply,
     socket
     |> assign(:show_edit_form, true)
     |> assign(:selected_user, user)}
  end

  @impl true
  def handle_event("hide_edit_form", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_edit_form, false)
     |> assign(:selected_user, nil)}
  end

  @impl true
  def handle_event("create_user", params, socket) do
    %{
      "email" => email,
      "password" => password,
      "role" => _role,
      "department" => _department,
      "full_name" => _full_name
    } = params

    case Accounts.register_user(%{
           email: email,
           password: password
         }) do
      {:ok, _user} ->
        # In a real implementation, we'd update user with role/department
        users = Accounts.list_users()

        {:noreply,
         socket
         |> assign(:users, users)
         |> assign(:show_create_form, false)
         |> put_flash(:info, "User created successfully!")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Error creating user")}
    end
  end

  @impl true
  def handle_event("delete_user", %{"id" => id}, socket) do
    user = Enum.find(socket.assigns.users, fn u -> u.id == String.to_integer(id) end)

    case Accounts.delete_user(user) do
      {:ok, _} ->
        users = Accounts.list_users()

        {:noreply,
         socket
         |> assign(:users, users)
         |> put_flash(:info, "User deleted successfully!")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Error deleting user")}
    end
  end

  @impl true
  def handle_event("toggle_status", %{"id" => id}, socket) do
    user = Enum.find(socket.assigns.users, fn u -> u.id == String.to_integer(id) end)
    _new_status = if get_user_status(user) == "active", do: "inactive", else: "active"

    # In a real implementation, we'd update the user status
    users = Accounts.list_users()

    {:noreply,
     socket
     |> assign(:users, users)
     |> put_flash(:info, "User status updated!")}
  end

  # Helper functions for user management
  # Stub - would get from user record
  defp get_user_role(_user), do: "Administrator"
  # Stub - would get from user record
  defp get_user_department(_user), do: "Medicine"
  # Stub - would get from user record
  defp get_user_status(_user), do: "active"

  defp get_user_full_name(user),
    do: String.split(user.email, "@") |> List.first() |> String.capitalize()

  # Stub - would get from user record
  defp get_user_last_login(_user), do: "2024-01-15"

  defp format_role(role) do
    case role do
      "admin" -> "Administrator"
      "lecturer" -> "Lecturer"
      "coordinator" -> "Program Coordinator"
      "staff" -> "Administrative Staff"
      _ -> "User"
    end
  end

  defp role_badge_color(role) do
    case role do
      "admin" -> "bg-purple-100 text-purple-800"
      "lecturer" -> "bg-blue-100 text-blue-800"
      "coordinator" -> "bg-green-100 text-green-800"
      "staff" -> "bg-gray-100 text-gray-800"
      _ -> "bg-gray-100 text-gray-600"
    end
  end

  defp status_badge_color(status) do
    case status do
      "active" -> "bg-green-100 text-green-800"
      "inactive" -> "bg-red-100 text-red-800"
      "pending" -> "bg-yellow-100 text-yellow-800"
      _ -> "bg-gray-100 text-gray-600"
    end
  end
end
